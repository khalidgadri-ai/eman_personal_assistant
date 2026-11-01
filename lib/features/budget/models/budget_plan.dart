import 'expense_entry.dart';

/// عملة عرض الميزانية. الافتراضية الريال السعودي، والمستخدم يغيّرها من شاشة الخطة.
class BudgetCurrency {
  const BudgetCurrency(this.code, this.symbol, this.arabicName);

  final String code;
  final String symbol;
  final String arabicName;

  static const BudgetCurrency sar = BudgetCurrency('SAR', 'ر.س', 'ريال سعودي');

  static const List<BudgetCurrency> all = [
    sar,
    BudgetCurrency('AED', 'د.إ', 'درهم إماراتي'),
    BudgetCurrency('KWD', 'د.ك', 'دينار كويتي'),
    BudgetCurrency('QAR', 'ر.ق', 'ريال قطري'),
    BudgetCurrency('BHD', 'د.ب', 'دينار بحريني'),
    BudgetCurrency('OMR', 'ر.ع', 'ريال عماني'),
    BudgetCurrency('EGP', 'ج.م', 'جنيه مصري'),
    BudgetCurrency('JOD', 'د.أ', 'دينار أردني'),
    BudgetCurrency('USD', r'$', 'دولار أمريكي'),
    BudgetCurrency('EUR', '€', 'يورو'),
  ];

  static bool isKnown(Object? code) => all.any((c) => c.code == code);

  /// رمز غير معروف (ملف تالف أو نسخة قديمة) يعود إلى الريال السعودي.
  static BudgetCurrency byCode(Object? code) => all.firstWhere((c) => c.code == code, orElse: () => sar);
}

/// مصروف ثابت يتكرر كل دورة (إيجار، قسط، اشتراك...).
class FixedExpense {
  static const int maxNameLength = 60;

  const FixedExpense({
    required this.id,
    required this.name,
    required this.amount,
    required this.dueDay,
    this.paidCycle,
  });

  final String id;
  final String name;
  final double amount;

  /// يوم الشهر (1-31) الذي يحل فيه الاستحقاق.
  final int dueDay;

  /// مفتاح الدورة التي دُفع فيها آخر مرة (تاريخ بدايتها). "مدفوعة" تعني أنه يساوي مفتاح الدورة
  /// الحالية، فتُصفَّر كلها وحدها حين تبدأ دورة جديدة دون أي عملية تنظيف.
  final String? paidCycle;

  bool isPaidIn(String cycleKey) => paidCycle == cycleKey;

  FixedExpense copyWith({String? name, double? amount, int? dueDay, String? paidCycle, bool clearPaid = false}) {
    return FixedExpense(
      id: id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      dueDay: dueDay ?? this.dueDay,
      paidCycle: clearPaid ? null : (paidCycle ?? this.paidCycle),
    );
  }

  void validate() {
    if (id.isEmpty) throw ArgumentError.value(id, 'id', 'must not be empty');
    if (name.trim().isEmpty || name.runes.length > maxNameLength) {
      throw ArgumentError.value(name, 'name', 'must be 1..$maxNameLength characters');
    }
    if (!amount.isFinite || amount <= 0 || amount > ExpenseEntry.maxAmount) {
      throw ArgumentError.value(amount, 'amount', 'must be a positive amount within the limit');
    }
    if (dueDay < 1 || dueDay > 31) throw ArgumentError.value(dueDay, 'dueDay', 'must be 1..31');
  }

  Map<String, Object?> toMap() => {
        'id': id,
        'name': name,
        'amount': amount,
        'dueDay': dueDay,
        'paidCycle': paidCycle,
      };

  /// null لأي سجل لا يصلح (نوع خاطئ أو قيمة خارج الحد): الخطة تُقرأ من قرص قد يكون تالفًا.
  static FixedExpense? fromMap(Object? raw) {
    if (raw is! Map) return null;
    final id = raw['id'];
    final name = raw['name'];
    final amount = raw['amount'];
    final dueDay = raw['dueDay'];
    final paid = raw['paidCycle'];
    if (id is! String || id.isEmpty || name is! String || amount is! num || dueDay is! int) return null;
    final item = FixedExpense(
      id: id,
      name: String.fromCharCodes(name.trim().runes.take(maxNameLength)),
      amount: amount.toDouble(),
      dueDay: dueDay,
      paidCycle: paid is String && paid.isNotEmpty ? paid : null,
    );
    try {
      item.validate();
    } on ArgumentError {
      return null;
    }
    return item;
  }
}

enum SavingsMode { amount, percent }

/// هدف الادخار الشهري: مبلغ ثابت، أو نسبة من الدخل.
class SavingsGoal {
  const SavingsGoal({this.mode = SavingsMode.amount, this.value = 0});

  final SavingsMode mode;
  final double value;

  double amountFor(double income) {
    return switch (mode) {
      SavingsMode.amount => value,
      SavingsMode.percent => income * value / 100,
    };
  }

  void validate() {
    final max = mode == SavingsMode.percent ? 100.0 : ExpenseEntry.maxAmount;
    if (!value.isFinite || value < 0 || value > max) {
      throw ArgumentError.value(value, 'savings', 'must be between 0 and $max');
    }
  }
}

/// خطة الميزانية الشهرية. تُحفظ في صندوق مشفّر ([BudgetPlanService]) وتدخل النسخة الاحتياطية.
class BudgetPlan {
  static const int maxFixedExpenses = 50;

  const BudgetPlan({
    this.income = 0,
    this.payday = 1,
    this.currencyCode = 'SAR',
    this.fixed = const [],
    this.savings = const SavingsGoal(),
    this.limits = const {},
  });

  /// الدخل الشهري.
  final double income;

  /// يوم نزول الراتب (1-31): تبدأ منه دورة الميزانية.
  final int payday;
  final String currencyCode;
  final List<FixedExpense> fixed;
  final SavingsGoal savings;

  /// حدود الصرف حسب الفئة (اختيارية). فئة بلا حد غير مقيَّدة.
  final Map<ExpenseCategory, double> limits;

  /// بلا دخل لا تُحسب ميزانية: الشاشة تعرض دعوة لإعداد الخطة بدل أرقام صفرية.
  bool get isConfigured => income > 0;

  BudgetCurrency get currency => BudgetCurrency.byCode(currencyCode);

  double get fixedTotal => fixed.fold(0.0, (sum, item) => sum + item.amount);

  double get savingsAmount => savings.amountFor(income);

  /// المتاح للصرف = الدخل − الثابتة − الادخار (قد يكون سالبًا).
  double get available => income - fixedTotal - savingsAmount;

  /// الثابتة + الادخار أكبر من الدخل: الخطة نفسها لا تقوم.
  bool get overcommitted => fixedTotal + savingsAmount > income;

  double get limitsTotal => limits.values.fold(0.0, (sum, v) => sum + v);

  BudgetPlan copyWith({
    double? income,
    int? payday,
    String? currencyCode,
    List<FixedExpense>? fixed,
    SavingsGoal? savings,
    Map<ExpenseCategory, double>? limits,
  }) {
    return BudgetPlan(
      income: income ?? this.income,
      payday: payday ?? this.payday,
      currencyCode: currencyCode ?? this.currencyCode,
      fixed: fixed ?? this.fixed,
      savings: savings ?? this.savings,
      limits: limits ?? this.limits,
    );
  }

  /// يرمي [ArgumentError] لأي قيمة خارج الحدود. الدخل صفر مقبول (خطة غير مُعدَّة).
  void validate() {
    if (!income.isFinite || income < 0 || income > ExpenseEntry.maxAmount) {
      throw ArgumentError.value(income, 'income', 'must be within 0..${ExpenseEntry.maxAmount}');
    }
    if (payday < 1 || payday > 31) throw ArgumentError.value(payday, 'payday', 'must be 1..31');
    if (!BudgetCurrency.isKnown(currencyCode)) throw ArgumentError.value(currencyCode, 'currencyCode');
    if (fixed.length > maxFixedExpenses) throw ArgumentError.value(fixed.length, 'fixed', 'too many');
    final ids = <String>{};
    for (final item in fixed) {
      item.validate();
      if (!ids.add(item.id)) throw ArgumentError.value(item.id, 'fixed', 'duplicate id');
    }
    savings.validate();
    for (final entry in limits.entries) {
      final v = entry.value;
      if (!v.isFinite || v <= 0 || v > ExpenseEntry.maxAmount) {
        throw ArgumentError.value(v, 'limits.${entry.key.name}', 'must be a positive amount within the limit');
      }
    }
  }

  Map<String, Object?> toMap() => {
        'income': income,
        'payday': payday,
        'currency': currencyCode,
        'fixed': [for (final item in fixed) item.toMap()],
        'savingsMode': savings.mode.name,
        'savingsValue': savings.value,
        'limits': {for (final e in limits.entries) e.key.name: e.value},
      };

  /// يقرأ ما على القرص بحذر: كل حقل يُفحص نوعه وحدوده، وما لا يصلح يعود إلى قيمته الافتراضية.
  static BudgetPlan fromMap(Object? raw) {
    if (raw is! Map) return const BudgetPlan();

    double money(Object? v, {double min = 0}) {
      if (v is! num) return min;
      final d = v.toDouble();
      return d.isFinite && d >= min && d <= ExpenseEntry.maxAmount ? d : min;
    }

    final payday = raw['payday'];
    final fixedRaw = raw['fixed'];
    final modeName = raw['savingsMode'];
    final mode = SavingsMode.values.where((m) => m.name == modeName).firstOrNull ?? SavingsMode.amount;
    final savingsValue = money(raw['savingsValue']);
    final limitsRaw = raw['limits'];

    final ids = <String>{};
    final fixed = <FixedExpense>[
      if (fixedRaw is List)
        for (final item in fixedRaw.take(maxFixedExpenses))
          if (FixedExpense.fromMap(item) case final parsed? when ids.add(parsed.id)) parsed,
    ];

    final limits = <ExpenseCategory, double>{};
    if (limitsRaw is Map) {
      for (final category in ExpenseCategory.values) {
        final v = limitsRaw[category.name];
        if (v is num && v.isFinite && v > 0 && v <= ExpenseEntry.maxAmount) limits[category] = v.toDouble();
      }
    }

    return BudgetPlan(
      income: money(raw['income']),
      payday: payday is int && payday >= 1 && payday <= 31 ? payday : 1,
      currencyCode: BudgetCurrency.isKnown(raw['currency']) ? raw['currency'] as String : BudgetCurrency.sar.code,
      fixed: fixed,
      savings: SavingsGoal(
        mode: mode,
        value: mode == SavingsMode.percent && savingsValue > 100 ? 0 : savingsValue,
      ),
      limits: limits,
    );
  }
}
