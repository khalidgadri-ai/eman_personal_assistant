import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

/// عدّاد الاستعمال المجاني المحدود للميزات المدفوعة، لكل شهر ميلادي، على هذا الجهاز فقط.
///
/// عام لأي ميزة: المفتاح اسم الميزة، والحدّ من [limits]. الفترة هي الشهر الميلادي حسب
/// ساعة الجهاز (`yyyy-MM`)، فيبدأ العدّ من صفر تلقائيًا في أول الشهر بلا مهمة تنظيف.
///
/// يُحفظ في صندوق Hive `subscription` غير المشفّر (نفس صندوق [SubscriptionService]).
/// وهذا الصندوق خارج `DataResetService.userBoxes` عمدًا: لو صُفّر العدّاد عند «مسح كل
/// بياناتي» لصار المسح طريقة سهلة لاستعمال غير محدود. وهو كذلك ليس من بيانات المستخدم،
/// فلا يدخل `BackupService` ولا النسخ الاحتياطي، ولا يغادر الجهاز.
///
/// حدود معروفة لا نعالجها: إعادة تثبيت التطبيق، أو تغيير ساعة الجوال، يعيدان العدّ. هذا
/// مقبول لأنه لا خادم عندنا، والميزة نفسها تعمل بمفتاح المستخدم نفسه عند مزوّده.
class FreeQuotaService {
  /// ميزة سؤال المتابعة الذكي في المدرب («عمّق أكثر»).
  static const String coachFollowUp = 'coach_followup';

  static const int coachFollowUpMonthlyLimit = 5;

  /// الحد الشهري المجاني لكل ميزة. ميزة غير مذكورة هنا ليس لها استعمال مجاني (حدها صفر).
  static const Map<String, int> limits = {
    coachFollowUp: coachFollowUpMonthlyLimit,
  };

  static const String _boxName = 'subscription';
  static const String _keyPrefix = 'free_quota_';
  static final RegExp _periodPattern = RegExp(r'^\d{4}-(0[1-9]|1[0-2])$');

  static Future<FreeQuotaService>? _instance;

  final Box _box;

  FreeQuotaService._(this._box);

  static Future<FreeQuotaService> getInstance() => _instance ??= _create();

  static Future<FreeQuotaService> _create() async {
    final service = FreeQuotaService._(await Hive.openBox(_boxName));
    // القيم لا تتلف إلا بين تشغيلين، فهذا أنسب وقت لإصلاحها. وفشل الإصلاح لا يمنع الخدمة.
    try {
      await service.healCorrupt(DateTime.now());
    } catch (e) {
      debugPrint('FreeQuotaService: could not repair a corrupt value (${e.runtimeType})');
    }
    return service;
  }

  @visibleForTesting
  static void resetForTesting() => _instance = null;

  // ───────────────────────── الحساب (دوال صافية، الوقت يُمرَّر من الخارج) ─────────────────────────

  /// الحد الشهري المجاني للميزة، أو 0 إن لم تكن لها استعمالات مجانية.
  static int limitOf(String feature) => limits[feature] ?? 0;

  /// مفتاح الشهر الميلادي: `2026-11`.
  static String periodKey(DateTime now) =>
      '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}';

  /// أول يوم في الشهر التالي (ديسمبر ← 1 يناير من السنة التالية).
  static DateTime renewsOn(DateTime now) => DateTime(now.year, now.month + 1);

  /// كم استعمالًا بقي من القيمة المحفوظة [raw] في شهر [now]. قيمة تالفة تُقرأ كأن شيئًا لم يبقَ.
  static int remainingFor(Object? raw, String feature, DateTime now) {
    final limit = limitOf(feature);
    final used = _usedIn(raw, limit, now);
    return used == null ? 0 : limit - used;
  }

  /// القيمة التي تُحفظ بعد استعمال واحد، دون تجاوز الحد. تالفة أو منتهية تبقى «منتهية» هذا الشهر.
  static Map<String, Object> consumedValue(Object? raw, String feature, DateTime now) {
    final limit = limitOf(feature);
    final used = _usedIn(raw, limit, now) ?? limit;
    return {'period': periodKey(now), 'used': used >= limit ? limit : used + 1};
  }

  /// المستعمل في شهر [now]: 0 إن لم يُستعمل شيء أو كانت القيمة من شهر آخر، وnull إن كانت تالفة
  /// (ليست خريطة، أو فترتها ليست `yyyy-MM`، أو عددها ليس رقمًا بين 0 والحد).
  static int? _usedIn(Object? raw, int limit, DateTime now) {
    if (raw == null) return 0;
    if (raw is! Map) return null;
    final period = raw['period'];
    if (period is! String || !_periodPattern.hasMatch(period)) return null;
    if (period != periodKey(now)) return 0;
    final used = raw['used'];
    if (used is! int || used < 0 || used > limit) return null;
    return used;
  }

  // ───────────────────────── الخدمة ─────────────────────────

  String _key(String feature) => '$_keyPrefix$feature';

  /// كم استعمالًا مجانيًا بقي هذا الشهر.
  int remaining(String feature, DateTime now) => remainingFor(_box.get(_key(feature)), feature, now);

  /// يحتسب استعمالًا واحدًا. لا يتجاوز الحد، ولا يفعل شيئًا إن لم يبقَ شيء.
  Future<void> consume(String feature, DateTime now) {
    return _box.put(_key(feature), consumedValue(_box.get(_key(feature)), feature, now));
  }

  /// قيمة تالفة تُكتب كـ«منتهية هذا الشهر»، حتى تعود صالحة في الشهر التالي بدل أن تبقى تالفة.
  @visibleForTesting
  Future<void> healCorrupt(DateTime now) async {
    for (final feature in limits.keys) {
      final limit = limitOf(feature);
      if (_usedIn(_box.get(_key(feature)), limit, now) == null) {
        await _box.put(_key(feature), {'period': periodKey(now), 'used': limit});
      }
    }
  }
}
