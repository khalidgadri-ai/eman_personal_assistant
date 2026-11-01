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

  /// موقع زمني بإزاحة الجهاز الحالية. لا نحمّل قاعدة المناطق الزمنية (كبيرة) ولا نعرف اسم منطقة
  /// الجهاز، فنبني موقعًا ثابتًا بإزاحته؛ وتُعاد الجدولة عند كل تشغيل فيصحّ بعد تغيّر التوقيت الصيفي.
  @visibleForTesting
  static tz.Location locationFor(DateTime now) {
    return tz.Location(
      'device',
      [tz.minTime],
      [0],
      [tz.TimeZone(now.timeZoneOffset, isDst: false, abbreviation: now.timeZoneName)],
    );
  }

  /// يجدول تذكيرًا أول مرة عند [firstFire]؛ [repeatsDaily] يكرره بنفس الوقت كل يوم.
  static Future<void> schedule({
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
    } catch (e) {
      debugPrint('NotificationService.schedule: ${e.runtimeType}');
    }
  }
}
