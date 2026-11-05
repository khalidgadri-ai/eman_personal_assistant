import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

/// غلاف ثابت حول flutter_local_notifications للتذكيرات المحلية فقط (أدوية وعناية ومهام).
/// كل الاستدعاءات داخل try/catch وتبتلع الخطأ عمدًا: التذكير لا يجوز أن يُسقط التطبيق، ولا
/// تُسجَّل نصوص التذكيرات (قد تحمل اسم دواء).
///
/// **التنبيهات غير دقيقة عمدًا** (`inexactAllowWhileIdle`): لا صلاحية SCHEDULE_EXACT_ALARM ولا
/// USE_EXACT_ALARM، فقد يتأخر التنبيه دقائق. بعد إعادة تشغيل الهاتف يعيد المكوّن
/// ScheduledNotificationBootReceiver جدولتها (صلاحية RECEIVE_BOOT_COMPLETED).
class NotificationService {
  NotificationService._();

  static final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    try {
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );

      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _plugin.initialize(settings: initSettings);
      _initialized = true;
    } catch (e) {
      debugPrint('NotificationService.init: ${e.runtimeType}');
    }
  }

  /// يطلب إذن الإشعارات (أندرويد 13+). لا يُستدعى إلا حين يضبط المستخدم تذكيرًا بنفسه.
  static Future<bool> requestPermission() async {
    try {
      final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      return await android?.requestNotificationsPermission() ?? true;
    } catch (e) {
      debugPrint('NotificationService.requestPermission: ${e.runtimeType}');
      return false;
    }
  }

  static Future<void> cancelAll() async {
    try {
      await _plugin.cancelAll();
    } catch (e) {
      debugPrint('NotificationService.cancelAll: ${e.runtimeType}');
    }
  }

  /// هل إشعارات التطبيق مفعّلة في إعدادات الجوال؟ `null` إن تعذّر الفحص (منصة غير أندرويد أو خطأ).
  static Future<bool?> areNotificationsEnabled() async {
    try {
      final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      return await android?.areNotificationsEnabled();
    } catch (e) {
      debugPrint('NotificationService.areNotificationsEnabled: ${e.runtimeType}');
      return null;
    }
  }

  /// اسم الموقع الزمني بإزاحة ثابتة بصيغة يقبلها `java.time.ZoneId.of`: `UTC` أو `UTC+03:00`
  /// أو `UTC-04:00` أو `UTC+05:30`. المكتبة ترسل هذا الاسم كما هو إلى أندرويد، وأي اسم آخر
  /// (مثل `device`) يجعل الجدولة ترمي استثناءً.
  @visibleForTesting
  static String zoneIdFor(Duration offset) {
    final minutes = offset.inMinutes;
    if (minutes == 0) return 'UTC';
    final abs = minutes.abs();
    final hh = (abs ~/ 60).toString().padLeft(2, '0');
    final mm = (abs % 60).toString().padLeft(2, '0');
    return 'UTC${minutes < 0 ? '-' : '+'}$hh:$mm';
  }

  /// موقع زمني بإزاحة الجهاز الحالية. لا نحمّل قاعدة المناطق الزمنية (كبيرة) ولا نعرف اسم منطقة
  /// الجهاز، فنبني موقعًا ثابتًا بإزاحته؛ وتُعاد الجدولة عند كل تشغيل فيصحّ بعد تغيّر التوقيت الصيفي.
  @visibleForTesting
  static tz.Location locationFor(DateTime now) => locationForOffset(now.timeZoneOffset, now.timeZoneName);

  @visibleForTesting
  static tz.Location locationForOffset(Duration offset, String abbreviation) {
    return tz.Location(
      zoneIdFor(offset),
      [tz.minTime],
      [0],
      [tz.TimeZone(offset, isDst: false, abbreviation: abbreviation)],
    );
  }

  /// يجدول تذكيرًا أول مرة عند [firstFire]؛ [repeatsDaily] يكرره بنفس الوقت كل يوم.
  /// يرجّع `true` إن قبله النظام و`false` إن رمى استثناءً (لا يرمي هو أبدًا).
  static Future<bool> schedule({
    required int id,
    required String title,
    required String body,
    required DateTime firstFire,
    required bool repeatsDaily,
  }) async {
    try {
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'life_reminders_channel',
        'تذكيرات الحياة والمنزل',
        channelDescription: 'تذكيرات الأدوية وروتين العناية والمهام التي تضبطها بنفسك',
        importance: Importance.high,
        priority: Priority.high,
      );
      const NotificationDetails details = NotificationDetails(android: androidDetails);

      final location = locationFor(firstFire);
      final when = tz.TZDateTime(
        location,
        firstFire.year,
        firstFire.month,
        firstFire.day,
        firstFire.hour,
        firstFire.minute,
      );
      await _plugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: when,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: repeatsDaily ? DateTimeComponents.time : null,
      );
      return true;
    } catch (e) {
      debugPrint('NotificationService.schedule: ${e.runtimeType}');
      return false;
    }
  }
}
