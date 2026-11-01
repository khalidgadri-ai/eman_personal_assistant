import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../../core/services/encrypted_boxes.dart';
import 'models/budget_plan.dart';
import 'models/expense_entry.dart';

/// خطة الميزانية الشهرية في صندوق Hive مشفّر (`budget_plan_enc`) بمفتاح التشفير نفسه
/// الذي تستعمله باقي الصناديق. سجل واحد تحت المفتاح [_key]. لا بيانات افتراضية: بلا خطة
/// محفوظة تُرجَع خطة فارغة (دخل صفر) فتعرض الشاشة دعوة لإعدادها.
///
/// الصندوق مشمول في النسخة الاحتياطية المشفّرة (`BackupService.boxNames`) وفي "مسح كل بياناتي"
/// (`DataResetService.userBoxes`)، ومستثنى من نسخ أندرويد التلقائي (res/xml).
class BudgetPlanService {
  static const String boxName = 'budget_plan';
  static const String _key = 'plan';

  static BudgetPlanService? _instance;
  static Box? _box;

  BudgetPlanService._();

  static Future<BudgetPlanService> getInstance() async {
    _instance ??= BudgetPlanService._();
    _box ??= await EncryptedBoxes.open(boxName);
    return _instance!;
  }

  /// يُنسى الصندوق المفتوح (بعد مسح بيانات المستخدم يُفتح صندوق جديد عند الطلب).
  static void reset() {
    _instance = null;
    _box = null;
  }

  @visibleForTesting
  static void resetForTesting() => reset();

  /// الخطة المحفوظة، أو خطة فارغة إن لم توجد أو كان المحفوظ تالفًا.
  BudgetPlan get plan => BudgetPlan.fromMap(_box!.get(_key));

  /// يحفظ [plan] كاملة. يرمي [ArgumentError] لأي قيمة خارج الحدود ولا يكتب شيئًا حينها.
  Future<void> save(BudgetPlan plan) async {
    plan.validate();
    await _box!.put(_key, plan.toMap());
  }

  /// يضع علامة "دُفع في هذه الدورة" على مصروف ثابت (أو يزيلها). null إن لم يوجد المصروف.
  Future<BudgetPlan?> setPaid(String fixedId, bool paid, {required String cycleKey}) async {
    final current = plan;
    if (!current.fixed.any((f) => f.id == fixedId)) return null;
    final updated = current.copyWith(
      fixed: [
        for (final item in current.fixed)
          if (item.id == fixedId) (paid ? item.copyWith(paidCycle: cycleKey) : item.copyWith(clearPaid: true)) else item,
      ],
    );
    await save(updated);
    return updated;
  }

  /// يحفظ حدود الفئات فقط (من اقتراح الميزانية) ويُبقي باقي الخطة كما هي.
  Future<BudgetPlan> saveLimits(Map<ExpenseCategory, double> limits) async {
    final updated = plan.copyWith(limits: Map.of(limits));
    await save(updated);
    return updated;
  }
}
