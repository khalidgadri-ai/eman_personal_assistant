import 'package:flutter/foundation.dart';
import '../../core/services/database_service.dart';
import '../../core/services/notification_service.dart';
import '../health_and_fitness/health_service.dart';
import '../health_and_fitness/models/health_entry.dart';

/// تذكير واحد مخطَّط: ما يظهر وفي أي وقت وهل يتكرر يوميًا.
class PlannedReminder {
  const PlannedReminder({
    required this.id,
    required this.title,
    required this.body,
    required this.hour,
    required this.minute,
    required this.repeatsDaily,
  });

  final int id;
  final String title;
  final String body;
  final int hour;
  final int minute;
  final bool repeatsDaily;

  /// أول موعد: اليوم عند الساعة المضبوطة إن لم تفت، وإلا غدًا.
  DateTime nextFire(DateTime now) {
    final today = DateTime(now.year, now.month, now.day, hour, minute);
    return today.isAfter(now) ? today : today.add(const Duration(days: 1));
  }
}

/// ما يحتاجه [ReminderService] من النظام. يُستبدل في الاختبارات.
abstract class ReminderGateway {
  Future<void> cancelAll();
  Future<bool> requestPermission();

  /// هل إشعارات التطبيق مفعّلة في النظام؟ `null` إن تعذّر الفحص.
  Future<bool?> areNotificationsEnabled();

  /// يرجّع `true` إن قبل النظام التذكير و`false` إن فشلت جدولته.
  Future<bool> schedule(PlannedReminder reminder, DateTime firstFire);
}

class PlatformReminderGateway implements ReminderGateway {
  const PlatformReminderGateway();

  @override
  Future<void> cancelAll() => NotificationService.cancelAll();

  @override
  Future<bool> requestPermission() => NotificationService.requestPermission();

  @override
  Future<bool?> areNotificationsEnabled() => NotificationService.areNotificationsEnabled();

  @override
  Future<bool> schedule(PlannedReminder reminder, DateTime firstFire) {
    return NotificationService.schedule(
      id: reminder.id,
      title: reminder.title,
      body: reminder.body,
      firstFire: firstFire,
      repeatsDaily: reminder.repeatsDaily,
    );
  }
}

/// يحوّل بيانات المستخدم إلى قائمة تذكيرات (دالة نقية، قابلة للاختبار بلا نظام).
abstract final class ReminderPlanner {
  static const String medicationTitle = 'تذكير بالدواء';
  static const String routineTitle = 'تذكير بالعناية';
  static const String taskTitle = 'تذكير بمهمة';

  /// معرّف إشعار ثابت بين التشغيلات (FNV-1a)؛ `String.hashCode` غير مضمون الثبات.
  static int stableId(String kind, String id) {
    var hash = 0x811C9DC5;
    for (final unit in '$kind:$id'.codeUnits) {
      hash ^= unit;
      hash = (hash * 0x01000193) & 0xFFFFFFFF;
    }
    return hash & 0x7FFFFFFF;
  }

  static ({int hour, int minute})? parseTime(String? value) {
    final match = RegExp(r'^(\d{2}):(\d{2})$').firstMatch((value ?? '').trim());
    if (match == null) return null;
    final h = int.parse(match.group(1)!);
    final m = int.parse(match.group(2)!);
    return h < 24 && m < 60 ? (hour: h, minute: m) : null;
  }

  static List<PlannedReminder> plan({
    required List<Medication> medications,
    required List<BeautyItem> beauty,
    required List<Map<String, dynamic>> tasks,
  }) {
    final result = <PlannedReminder>[];
    for (final med in medications) {
      final t = parseTime(med.reminder);
      if (t == null) continue;
      result.add(PlannedReminder(
        id: stableId('med', med.id),
        title: medicationTitle,
        body: med.name,
        hour: t.hour,
        minute: t.minute,
        repeatsDaily: true,
      ));
    }
    for (final item in beauty) {
      final t = parseTime(item.reminder);
      if (t == null) continue;
      result.add(PlannedReminder(
        id: stableId('beauty', item.id),
        title: routineTitle,
        body: item.item,
        hour: t.hour,
        minute: t.minute,
        repeatsDaily: true,
      ));
    }
    for (final task in tasks) {
      final id = task['id'];
      final t = parseTime(task['reminder'] as String?);
      if (t == null || id is! String || task['done'] == true) continue;
      result.add(PlannedReminder(
        id: stableId('task', id),
        title: taskTitle,
        body: '${task['title'] ?? ''}',
        hour: t.hour,
        minute: t.minute,
        repeatsDaily: false,
      ));
    }
    return result;
  }
}

/// نتيجة مزامنة واحدة: كم تذكيرًا خُطِّط وكم نجحت جدولته، وهل الإشعارات مفعّلة في النظام.
class ReminderSyncResult {
  const ReminderSyncResult({
    required this.planned,
    required this.scheduled,
    this.notificationsEnabled,
    this.failed = false,
  });

  static const ReminderSyncResult empty = ReminderSyncResult(planned: 0, scheduled: 0);

  final int planned;
  final int scheduled;

  /// `null` = تعذّر الفحص (لا نفترض أنها مطفأة).
  final bool? notificationsEnabled;

  /// فشلت المزامنة كلها قبل أن نعرف ما يجب جدولته (مثل تعذّر فتح البيانات).
  final bool failed;

  /// هل يحتاج المستخدم أن يعرف أن تذكيره قد لا يرن؟ (إشعارات مطفأة، أو فشلت الجدولة).
  bool get needsAttention => failed || (planned > 0 && (notificationsEnabled == false || scheduled < planned));
}

/// يجدول تذكيرات الأدوية والعناية والمهام من بيانات المستخدم الحالية: يلغي القديم ويجدول من جديد
/// في كل مرة تتغير البيانات وعند كل تشغيل للتطبيق (فيصحّ أي تغيّر في توقيت الجهاز).
class ReminderService {
  ReminderService._();

  /// رسالة للمستخدم حين لا يُضمن أن يرن تذكيره. صيغة لا تخاطب جنسًا بعينه.
  static const String notScheduledMessage =
      'لم يُضبط التذكير. يلزم تفعيل إشعارات هذا التطبيق من إعدادات الجوال ثم إعادة المحاولة.';

  @visibleForTesting
  static ReminderGateway? gatewayOverride;

  static ReminderGateway get _gateway => gatewayOverride ?? const PlatformReminderGateway();

  /// يرجّع عدد التذكيرات التي **نجحت** جدولتها فعلًا. انظر [sync] لتفاصيل أكثر.
  static Future<int> syncAll({bool askPermission = false}) async => (await sync(askPermission: askPermission)).scheduled;

  /// يعيد جدولة كل التذكيرات ويرجّع تفاصيل النتيجة. [askPermission] لا يكون true إلا بعد أن ضبط
  /// المستخدم تذكيرًا بنفسه، حتى لا يُسأل عن إذن الإشعارات دون سبب. لا يرمي أبدًا.
  static Future<ReminderSyncResult> sync({bool askPermission = false}) async {
    try {
      final health = await HealthService.getInstance();
      final db = await DatabaseService.getInstance();
      final planned = ReminderPlanner.plan(
        medications: health.medications(),
        beauty: health.beautyItems(),
        tasks: db.getDailyTasks(),
      );
      final gateway = _gateway;
      await gateway.cancelAll();
      if (planned.isEmpty) return ReminderSyncResult.empty;
      if (askPermission) await gateway.requestPermission();
      final now = DateTime.now();
      var scheduled = 0;
      for (final reminder in planned) {
        // فشل تذكير واحد لا يمنع الباقي.
        try {
          if (await gateway.schedule(reminder, reminder.nextFire(now))) scheduled++;
        } catch (e) {
          debugPrint('ReminderService.sync: one reminder failed (${e.runtimeType})');
        }
      }
      bool? enabled;
      try {
        enabled = await gateway.areNotificationsEnabled();
      } catch (e) {
        debugPrint('ReminderService.sync: notification check failed (${e.runtimeType})');
      }
      return ReminderSyncResult(planned: planned.length, scheduled: scheduled, notificationsEnabled: enabled);
    } catch (e) {
      debugPrint('ReminderService.sync: ${e.runtimeType}');
      return const ReminderSyncResult(planned: 0, scheduled: 0, failed: true);
    }
  }

  /// يلغي كل التذكيرات (بعد "مسح كل بياناتي").
  static Future<void> cancelAll() async {
    try {
      await _gateway.cancelAll();
    } catch (e) {
      debugPrint('ReminderService.cancelAll: ${e.runtimeType}');
    }
  }
}
