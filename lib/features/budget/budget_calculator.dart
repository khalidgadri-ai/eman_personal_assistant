import 'models/budget_plan.dart';
import 'models/expense_entry.dart';

/// دورة ميزانية واحدة: تبدأ يوم نزول الراتب وتنتهي قبل يوم الراتب التالي. حسابات خالصة بلا
/// ذكاء اصطناعي ولا تخزين.
class BudgetCycle {
  const BudgetCycle._(this.start, this.endExclusive);

  /// أول يوم في الدورة (الساعة 00:00).
  final DateTime start;

  /// بداية الدورة التالية (لا تدخل في هذه الدورة).
  final DateTime endExclusive;

  /// يوم الراتب في شهر ما؛ راتب يوم 31 يقع في آخر يوم من الأشهر الأقصر.
  static DateTime _paydayIn(int year, int month, int payday) {
    final last = DateTime(year, month + 1, 0).day;
    return DateTime(year, month, payday < last ? payday : last);
  }

  /// الدورة التي يقع فيها [date] لمن يتقاضى راتبه في [payday].
  factory BudgetCycle.containing(DateTime date, int payday) {
    final day = DateTime(date.year, date.month, date.day);
    var start = _paydayIn(day.year, day.month, payday);
    if (day.isBefore(start)) start = _paydayIn(day.year, day.month - 1, payday);
    final next = _paydayIn(start.year, start.month + 1, payday);
    return BudgetCycle._(start, next);
  }

  /// مفتاح ثابت للدورة (تاريخ بدايتها) يُحفظ مع "دُفع هذه الدورة".
  String get key =>
      '${start.year.toString().padLeft(4, '0')}-${start.month.toString().padLeft(2, '0')}-${start.day.toString().padLeft(2, '0')}';

  static int _dayNumber(DateTime d) => DateTime.utc(d.year, d.month, d.day).millisecondsSinceEpoch ~/ Duration.millisecondsPerDay;

  /// عدد أيام الدورة كلها.
  int get totalDays => _dayNumber(endExclusive) - _dayNumber(start);

  /// الأيام المتبقية في الدورة **بما فيها اليوم**. لا تقل عن 1 داخل الدورة.
  int daysLeft(DateTime today) {
    final left = _dayNumber(endExclusive) - _dayNumber(today);
    return left < 1 ? 1 : (left > totalDays ? totalDays : left);
  }

  bool contains(DateTime date) => !date.isBefore(start) && date.isBefore(endExclusive);

  /// آخر يوم داخل الدورة (للعرض).
  DateTime get lastDay => DateTime(endExclusive.year, endExclusive.month, endExclusive.day - 1);
}

enum BudgetLevel { ok, near, over }

/// حالة فئة واحدة مقابل حدّها.
class CategoryStatus {
  const CategoryStatus({required this.category, required this.spent, this.limit});

  final ExpenseCategory category;
  final double spent;

  /// null: لا حد لهذه الفئة.
  final double? limit;

  double? get ratio => limit == null ? null : spent / limit!;

  /// يقترب عند 80٪ من الحد ويتجاوز بعد 100٪.
  BudgetLevel get level {
    final r = ratio;
    if (r == null) return BudgetLevel.ok;
    if (r > 1) return BudgetLevel.over;
    if (r >= nearThreshold) return BudgetLevel.near;
    return BudgetLevel.ok;
  }

  double get overBy => limit == null || spent <= limit! ? 0 : spent - limit!;

  static const double nearThreshold = 0.8;
}

/// أرقام الميزانية الحالية جاهزة للعرض.
class BudgetSnapshot {
  const BudgetSnapshot({
    required this.cycle,
    required this.income,
    required this.fixedTotal,
    required this.savings,
    required this.available,
    required this.spent,
    required this.remaining,
    required this.daysLeft,
    required this.dailyAvailable,
    required this.overcommitted,
    required this.categories,
  });

  final BudgetCycle cycle;
  final double income;
  final double fixedTotal;
  final double savings;

  /// المتاح للصرف = الدخل − الثابتة − الادخار.
  final double available;

  /// مجموع المصاريف المسجَّلة في الدورة الحالية.
  final double spent;

  /// المتبقي = المتاح − المصروف (سالب عند التجاوز).
  final double remaining;
  final int daysLeft;

  /// المتاح يوميًا = المتبقي ÷ الأيام المتبقية؛ صفر إذا لم يبق شيء.
  final double dailyAvailable;

  /// الثابتة + الادخار أكبر من الدخل.
  final bool overcommitted;

  /// الفئات التي لها حد أو صرف في الدورة، الأكثر صرفًا أولًا.
  final List<CategoryStatus> categories;

  /// نسبة المصروف من المتاح. عند عدم وجود متاح وفيه صرف تُعدّ تجاوزًا كاملًا.
  double get ratio {
    if (available <= 0) return spent > 0 || available < 0 ? 1.5 : 0;
    return spent / available;
  }

  /// أخضر حتى 70٪، ثم أصفر حتى 100٪، ثم أحمر. خطة غير قائمة (متاح سالب) حمراء.
  BudgetLevel get level {
    if (ratio >= 1) return BudgetLevel.over;
    if (ratio >= warnThreshold) return BudgetLevel.near;
    return BudgetLevel.ok;
  }

  static const double warnThreshold = 0.7;

  List<CategoryStatus> get alerts => [for (final c in categories) if (c.level != BudgetLevel.ok) c];
}

/// وزن كل فئة في الاقتراح المحلي (المجموع 1.0). قاعدة بسيطة يعدّل المستخدم نتيجتها بعد حفظها.
const Map<ExpenseCategory, double> defaultLimitWeights = {
  ExpenseCategory.food: 0.35,
  ExpenseCategory.transport: 0.15,
  ExpenseCategory.entertainment: 0.10,
  ExpenseCategory.bills: 0.10,
  ExpenseCategory.shopping: 0.15,
  ExpenseCategory.other: 0.15,
};

abstract final class BudgetCalculator {
  /// يحسب أرقام الدورة التي تضم [today]. [expenses] كل المصاريف المحفوظة (تُصفّى هنا بحدود الدورة).
  static BudgetSnapshot compute(BudgetPlan plan, Iterable<ExpenseEntry> expenses, DateTime today) {
    final cycle = BudgetCycle.containing(today, plan.payday);
    final inCycle = [for (final e in expenses) if (cycle.contains(e.date)) e];

    final spent = inCycle.fold(0.0, (sum, e) => sum + e.amount);
    final available = plan.available;
    final remaining = available - spent;
    final left = cycle.daysLeft(today);

    final byCategory = <ExpenseCategory, double>{};
    for (final e in inCycle) {
      byCategory[e.category] = (byCategory[e.category] ?? 0) + e.amount;
    }
    final categories = <CategoryStatus>[
      for (final category in ExpenseCategory.values)
        if (byCategory.containsKey(category) || plan.limits.containsKey(category))
          CategoryStatus(category: category, spent: byCategory[category] ?? 0, limit: plan.limits[category]),
    ]..sort((a, b) => b.spent.compareTo(a.spent));

    return BudgetSnapshot(
      cycle: cycle,
      income: plan.income,
      fixedTotal: plan.fixedTotal,
      savings: plan.savingsAmount,
      available: available,
      spent: spent,
      remaining: remaining,
      daysLeft: left,
      dailyAvailable: remaining > 0 ? remaining / left : 0,
      overcommitted: plan.overcommitted,
      categories: categories,
    );
  }

  /// الاقتراح المحلي: يوزّع [available] على الفئات بأوزان [weights]، مقرّبًا إلى أقرب وحدة.
  /// فارغ إن لم يكن هناك متاح موجب.
  static Map<ExpenseCategory, double> suggestLimits(
    double available, {
    Map<ExpenseCategory, double> weights = defaultLimitWeights,
  }) {
    if (!available.isFinite || available <= 0) return const {};
    final total = weights.values.fold(0.0, (a, b) => a + b);
    if (total <= 0) return const {};
    final result = <ExpenseCategory, double>{};
    for (final entry in weights.entries) {
      if (entry.value <= 0) continue;
      final amount = (available * entry.value / total).roundToDouble();
      if (amount > 0) result[entry.key] = amount;
    }
    return result;
  }
}
