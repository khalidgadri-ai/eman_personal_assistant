import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/widgets.dart' show WidgetsBinding;

import 'expense_entry.dart';

/// عملة عرض الميزانية. المستخدم يختارها من شاشة الخطة؛ قبل إعداد خطة تُقترح عملة بلد الهاتف.
/// [symbol] و[arabicName] للواجهة العربية، و[englishName] و[latinSymbol] (أو الرمز الدولي [code])
/// للّغات الأخرى، فلا يظهر «ر.س» في واجهة إنجليزية.
class BudgetCurrency {
  const BudgetCurrency(this.code, this.symbol, this.arabicName, this.englishName, [this.latinSymbol]);

  final String code;
  final String symbol;
  final String arabicName;
  final String englishName;
  final String? latinSymbol;

  String symbolFor(String lang) => lang == 'ar' ? symbol : latinSymbol ?? code;

  String nameFor(String lang) => lang == 'ar' ? arabicName : englishName;

  static const BudgetCurrency sar = BudgetCurrency('SAR', 'ر.س', 'ريال سعودي', 'Saudi riyal');
  static const BudgetCurrency usd = BudgetCurrency('USD', r'$', 'دولار أمريكي', 'US dollar', r'$');

  static const List<BudgetCurrency> all = [
    sar,
    BudgetCurrency('AED', 'د.إ', 'درهم إماراتي', 'UAE dirham'),
    BudgetCurrency('KWD', 'د.ك', 'دينار كويتي', 'Kuwaiti dinar'),
    BudgetCurrency('QAR', 'ر.ق', 'ريال قطري', 'Qatari riyal'),
    BudgetCurrency('BHD', 'د.ب', 'دينار بحريني', 'Bahraini dinar'),
    BudgetCurrency('OMR', 'ر.ع', 'ريال عماني', 'Omani rial'),
    BudgetCurrency('EGP', 'ج.م', 'جنيه مصري', 'Egyptian pound'),
    BudgetCurrency('JOD', 'د.أ', 'دينار أردني', 'Jordanian dinar'),
    BudgetCurrency('IQD', 'د.ع', 'دينار عراقي', 'Iraqi dinar'),
    BudgetCurrency('LBP', 'ل.ل', 'ليرة لبنانية', 'Lebanese pound'),
    BudgetCurrency('SYP', 'ل.س', 'ليرة سورية', 'Syrian pound'),
    BudgetCurrency('YER', 'ر.ي', 'ريال يمني', 'Yemeni rial'),
    BudgetCurrency('SDG', 'ج.س', 'جنيه سوداني', 'Sudanese pound'),
    BudgetCurrency('LYD', 'د.ل', 'دينار ليبي', 'Libyan dinar'),
    BudgetCurrency('TND', 'د.ت', 'دينار تونسي', 'Tunisian dinar'),
    BudgetCurrency('DZD', 'د.ج', 'دينار جزائري', 'Algerian dinar'),
    BudgetCurrency('MAD', 'د.م', 'درهم مغربي', 'Moroccan dirham'),
    usd,
    BudgetCurrency('EUR', '€', 'يورو', 'Euro', '€'),
    BudgetCurrency('GBP', '£', 'جنيه إسترليني', 'British pound', '£'),
    BudgetCurrency('CAD', r'C$', 'دولار كندي', 'Canadian dollar', r'C$'),
    BudgetCurrency('AUD', r'A$', 'دولار أسترالي', 'Australian dollar', r'A$'),
    BudgetCurrency('CHF', 'CHF', 'فرنك سويسري', 'Swiss franc'),
    BudgetCurrency('TRY', '₺', 'ليرة تركية', 'Turkish lira', '₺'),
    BudgetCurrency('INR', '₹', 'روبية هندية', 'Indian rupee', '₹'),
    BudgetCurrency('PKR', 'PKR', 'روبية باكستانية', 'Pakistani rupee'),
    BudgetCurrency('BDT', 'BDT', 'تاكا بنغلاديشية', 'Bangladeshi taka'),
    BudgetCurrency('MYR', 'RM', 'رينغيت ماليزي', 'Malaysian ringgit', 'RM'),
    BudgetCurrency('IDR', 'Rp', 'روبية إندونيسية', 'Indonesian rupiah', 'Rp'),
    BudgetCurrency('NGN', '₦', 'نايرا نيجيرية', 'Nigerian naira', '₦'),
    BudgetCurrency('JPY', '¥', 'ين ياباني', 'Japanese yen', '¥'),
    BudgetCurrency('CNY', 'CN¥', 'يوان صيني', 'Chinese yuan', 'CN¥'),
  ];

  static bool isKnown(Object? code) => all.any((c) => c.code == code);

  /// رمز غير معروف (ملف تالف أو نسخة قديمة) يعود إلى الريال السعودي.
  static BudgetCurrency byCode(Object? code) => all.firstWhere((c) => c.code == code, orElse: () => sar);

  static const Set<String> _euroRegions = {
    'AT', 'BE', 'CY', 'DE', 'EE', 'ES', 'FI', 'FR', 'GR', 'HR', 'IE', 'IT', 'LT', 'LU', 'LV', 'MT', 'NL', 'PT', 'SI', 'SK',
  };

  static const Map<String, String> _regionCurrency = {
    'SA': 'SAR', 'AE': 'AED', 'KW': 'KWD', 'QA': 'QAR', 'BH': 'BHD', 'OM': 'OMR', 'EG': 'EGP', 'JO': 'JOD',
    'IQ': 'IQD', 'LB': 'LBP', 'SY': 'SYP', 'YE': 'YER', 'SD': 'SDG', 'LY': 'LYD', 'TN': 'TND', 'DZ': 'DZD',
    'MA': 'MAD', 'US': 'USD', 'GB': 'GBP', 'CA': 'CAD', 'AU': 'AUD', 'CH': 'CHF', 'TR': 'TRY', 'IN': 'INR',
    'PK': 'PKR', 'BD': 'BDT', 'MY': 'MYR', 'ID': 'IDR', 'NG': 'NGN', 'JP': 'JPY', 'CN': 'CNY',
  };

  /// عملة بلد الهاتف ([countryCode] مثل "SA")، أو بلد الهاتف الحالي إن لم يُعطَ. بلا بلد معروف:
  /// الريال السعودي؛ بلد ليست عملته في القائمة: الدولار الأمريكي.
  static BudgetCurrency forRegion([String? countryCode]) {
    final region = (countryCode ?? _deviceRegion())?.toUpperCase();
    if (region == null || region.isEmpty) return sar;
    if (_euroRegions.contains(region)) return byCode('EUR');
    final code = _regionCurrency[region];
    return code == null ? usd : byCode(code);
  }

  /// بلد الهاتف من ربط Flutter (فيتبع ما تضبطه الاختبارات)، أو من المنصة مباشرة قبل تهيئته.
  static String? _deviceRegion() {
    try {
      return WidgetsBinding.instance.platformDispatcher.locale.countryCode;
    } catch (_) {
      return PlatformDispatcher.instance.locale.countryCode;
    }
  }
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

  /// العملة التي تُعرض بها المبالغ: عملة الخطة إن أُعدَّت، وإلا عملة بلد الهاتف (لم يختر المستخدم بعد).
  BudgetCurrency displayCurrency([String? countryCode]) =>
      isConfigured ? currency : BudgetCurrency.forRegion(countryCode);

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
