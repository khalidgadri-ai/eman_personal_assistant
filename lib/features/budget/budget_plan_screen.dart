import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/arabic_numbers.dart';
import '../../core/utils/ids.dart';
import '../../core/widgets/entry_dialog.dart';
import '../../core/widgets/undo_snackbar.dart';
import 'budget_format.dart';
import 'budget_plan_service.dart';
import 'models/budget_plan.dart';
import 'models/expense_entry.dart';

/// إعداد خطة الميزانية: الدخل ويوم الراتب والعملة والمصروفات الثابتة وهدف الادخار وحدود الفئات.
/// لا يُحفظ شيء حتى يضغط المستخدم "حفظ الخطة"، وإن خرج بتعديلات غير محفوظة يُسأل أولًا.
/// ترجّع true إذا حُفظت الخطة.
class BudgetPlanScreen extends StatefulWidget {
  const BudgetPlanScreen({super.key});

  @override
  State<BudgetPlanScreen> createState() => _BudgetPlanScreenState();
}

class _BudgetPlanScreenState extends State<BudgetPlanScreen> {
  static const String _invalidAmount = 'أدخل مبلغًا صحيحًا أكبر من صفر';

  final TextEditingController _income = TextEditingController();
  final TextEditingController _savings = TextEditingController();
  final Map<ExpenseCategory, TextEditingController> _limits = {
    for (final c in ExpenseCategory.values) c: TextEditingController(),
  };

  BudgetPlanService? _service;
  int _payday = 1;
  String _currencyCode = BudgetCurrency.sar.code;
  SavingsMode _mode = SavingsMode.amount;
  List<FixedExpense> _fixed = [];
  bool _dirty = false;
  bool _saving = false;
  String? _incomeError;
  String? _savingsError;
  final Map<ExpenseCategory, String?> _limitErrors = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _income.dispose();
    _savings.dispose();
    for (final c in _limits.values) {
      c.dispose();
    }
    super.dispose();
  }

  static String _plain(double v) => v == v.roundToDouble() ? v.toInt().toString() : v.toString();

  Future<void> _load() async {
    final service = await BudgetPlanService.getInstance();
    if (!mounted) return;
    final plan = service.plan;
    setState(() {
      _service = service;
      _income.text = plan.income > 0 ? _plain(plan.income) : '';
      _payday = plan.payday;
      _currencyCode = plan.currencyCode;
      _mode = plan.savings.mode;
      _savings.text = plan.savings.value > 0 ? _plain(plan.savings.value) : '';
      _fixed = List.of(plan.fixed);
      for (final entry in plan.limits.entries) {
        _limits[entry.key]!.text = _plain(entry.value);
      }
    });
  }

  void _touch() => setState(() => _dirty = true);

  BudgetCurrency get _currency => BudgetCurrency.byCode(_currencyCode);

  /// خطة للعرض الحي فقط: القيم غير الصالحة تُحتسب صفرًا ولا تظهر أخطاء قبل الحفظ.
  BudgetPlan get _lenient {
    final income = parseAmount(_income.text) ?? 0;
    final savingsValue = parseAmount(_savings.text, allowZero: true) ?? 0;
    return BudgetPlan(
      income: income,
      payday: _payday,
      currencyCode: _currencyCode,
      fixed: _fixed,
      savings: SavingsGoal(mode: _mode, value: _mode == SavingsMode.percent && savingsValue > 100 ? 0 : savingsValue),
      limits: {
        for (final e in _limits.entries) e.key: ?parseAmount(e.value.text),
      },
    );
  }

  /// يتحقق من كل الحقول ويعرض أخطاءها؛ null إن وُجد خطأ.
  BudgetPlan? _buildStrict() {
    final income = parseAmount(_income.text);
    final savingsText = _savings.text.trim();
    final savingsValue = savingsText.isEmpty ? 0.0 : parseAmount(savingsText, allowZero: true);
    final limits = <ExpenseCategory, double>{};
    final limitErrors = <ExpenseCategory, String?>{};
    for (final entry in _limits.entries) {
      final text = entry.value.text.trim();
      if (text.isEmpty) continue;
      final v = parseAmount(text, allowZero: true);
      if (v == null) {
        limitErrors[entry.key] = _invalidAmount;
      } else if (v > 0) {
        limits[entry.key] = v;
      }
    }
    final savingsInvalid = savingsValue == null || (_mode == SavingsMode.percent && savingsValue > 100);

    setState(() {
      _incomeError = income == null ? _invalidAmount : null;
      _savingsError = savingsInvalid
          ? (_mode == SavingsMode.percent ? 'أدخل نسبة بين 0 و100' : 'أدخل مبلغًا صحيحًا (أو اتركه فارغًا)')
          : null;
      _limitErrors
        ..clear()
        ..addAll(limitErrors);
    });
    if (income == null || savingsInvalid || limitErrors.isNotEmpty) return null;

    return BudgetPlan(
      income: income,
      payday: _payday,
      currencyCode: _currencyCode,
      fixed: _fixed,
      savings: SavingsGoal(mode: _mode, value: savingsValue),
      limits: limits,
    );
  }

  Future<bool> _save() async {
    final plan = _buildStrict();
    if (plan == null) {
      showInfoSnackBar(context, 'راجع الحقول المعلَّمة بالأحمر ثم احفظ مرة أخرى');
      return false;
    }
    setState(() => _saving = true);
    try {
      await _service!.save(plan);
    } catch (e) {
      debugPrint('BudgetPlanScreen: save failed (${e.runtimeType})');
      if (!mounted) return false;
      setState(() => _saving = false);
      showInfoSnackBar(context, 'تعذّر حفظ الخطة. حاول مرة أخرى');
      return false;
    }
    if (!mounted) return true;
    _dirty = false;
    Navigator.of(context).pop(true);
    return true;
  }

  Future<void> _onBackWithChanges() async {
    final choice = await showDialog<String>(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: AppTheme.cardColor,
          title: const Text('تعديلات غير محفوظة', style: TextStyle(color: AppTheme.textColor)),
          content: const Text(
            'لم تحفظ التغييرات على خطة الميزانية. هل تحفظها قبل الخروج؟',
            style: TextStyle(color: AppTheme.subTextColor, height: 1.6),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, 'stay'),
              child: const Text('متابعة التعديل', style: TextStyle(color: AppTheme.subTextColor)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, 'discard'),
              child: const Text('خروج بلا حفظ', style: TextStyle(color: Colors.redAccent)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
              onPressed: () => Navigator.pop(dialogContext, 'save'),
              child: const Text('حفظ الخطة', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
    if (!mounted) return;
    if (choice == 'save') {
      await _save();
    } else if (choice == 'discard') {
      setState(() => _dirty = false);
      Navigator.of(context).pop(false);
    }
  }

  // --- المصروفات الثابتة ---

  Future<void> _editFixed({FixedExpense? existing}) async {
    final values = await showEntryDialog(
      context,
      title: existing == null ? 'مصروف ثابت جديد' : 'تعديل المصروف الثابت',
      confirmLabel: existing == null ? 'إضافة' : 'حفظ',
      fields: [
        EntryField(
          key: 'name',
          label: 'اسم المصروف',
          hint: 'مثال: إيجار',
          required: true,
          maxLength: FixedExpense.maxNameLength,
          initial: existing?.name,
        ),
        EntryField(
          key: 'amount',
          label: 'المبلغ',
          required: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          maxLength: 15,
          initial: existing == null ? null : _plain(existing.amount),
          validator: (v) => parseAmount(v) == null ? _invalidAmount : null,
        ),
        EntryField(
          key: 'day',
          label: 'يوم الاستحقاق (من 1 إلى 31)',
          required: true,
          keyboardType: TextInputType.number,
          maxLength: 2,
          initial: existing?.dueDay.toString(),
          validator: (v) {
            final day = parseInteger(v);
            return day == null || day < 1 || day > 31 ? 'أدخل يومًا من 1 إلى 31' : null;
          },
        ),
      ],
    );
    if (values == null || !mounted) return;
    final amount = parseAmount(values['amount']!);
    final day = parseInteger(values['day']!);
    if (amount == null || day == null) return;
    final name = String.fromCharCodes(values['name']!.runes.take(FixedExpense.maxNameLength));
    setState(() {
      _dirty = true;
      if (existing == null) {
        _fixed = [..._fixed, FixedExpense(id: newId(), name: name, amount: amount, dueDay: day)];
      } else {
        _fixed = [
          for (final f in _fixed)
            if (f.id == existing.id) f.copyWith(name: name, amount: amount, dueDay: day) else f,
        ];
      }
    });
  }

  void _removeFixed(FixedExpense item) {
    final index = _fixed.indexWhere((f) => f.id == item.id);
    if (index < 0) return;
    setState(() {
      _dirty = true;
      _fixed = [..._fixed]..removeAt(index);
    });
    showUndoSnackBar(context, 'حُذف «${item.name}»', () async {
      if (!mounted) return;
      setState(() {
        _dirty = true;
        _fixed = [..._fixed]..insert(index.clamp(0, _fixed.length), item);
      });
    });
  }

  // --- البناء ---

  @override
  Widget build(BuildContext context) {
    final plan = _lenient;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: PopScope(
        canPop: !_dirty,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) _onBackWithChanges();
        },
        child: Scaffold(
          appBar: AppBar(title: const Text('خطة الميزانية')),
          bottomNavigationBar: _service == null
              ? null
              : SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: _saving ? null : _save,
                        child: const Text('حفظ الخطة', style: TextStyle(color: Colors.white, fontSize: 16)),
                      ),
                    ),
                  ),
                ),
          body: _service == null
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  children: [
                    _buildIncomeCard(),
                    const SizedBox(height: 12),
                    _buildFixedCard(plan),
                    const SizedBox(height: 12),
                    _buildSavingsCard(plan),
                    const SizedBox(height: 12),
                    _buildLimitsCard(),
                    const SizedBox(height: 12),
                    _buildSummaryCard(plan),
                  ],
                ),
        ),
      ),
    );
  }

  InputDecoration _decoration(String label, {String? suffix, String? error, String? helper}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppTheme.subTextColor),
      suffixText: suffix,
      suffixStyle: const TextStyle(color: AppTheme.subTextColor),
      errorText: error,
      helperText: helper,
      helperMaxLines: 2,
      counterText: '',
    );
  }

  Widget _section(String title, List<Widget> children) {
    return Card(
      color: AppTheme.cardColor,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: AppTheme.textColor, fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildIncomeCard() {
    return _section('الدخل والدورة', [
      TextField(
        controller: _income,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        maxLength: 15,
        style: const TextStyle(color: AppTheme.textColor),
        decoration: _decoration('الدخل الشهري', suffix: _currency.symbol, error: _incomeError),
        onChanged: (_) {
          _incomeError = null;
          _touch();
        },
      ),
      const SizedBox(height: 12),
      DropdownButtonFormField<int>(
        initialValue: _payday,
        isExpanded: true,
        dropdownColor: AppTheme.cardColor,
        decoration: _decoration('يوم نزول الراتب', helper: 'تبدأ دورة الميزانية من هذا اليوم كل شهر'),
        items: [
          for (var d = 1; d <= 31; d++)
            DropdownMenuItem(value: d, child: Text('$d', style: const TextStyle(color: AppTheme.textColor))),
        ],
        onChanged: (v) {
          if (v == null) return;
          setState(() {
            _payday = v;
            _dirty = true;
          });
        },
      ),
      const SizedBox(height: 12),
      DropdownButtonFormField<String>(
        initialValue: _currencyCode,
        isExpanded: true,
        dropdownColor: AppTheme.cardColor,
        decoration: _decoration('العملة'),
        items: [
          for (final c in BudgetCurrency.all)
            DropdownMenuItem(
              value: c.code,
              child: Text('${c.arabicName} (${c.symbol})', style: const TextStyle(color: AppTheme.textColor)),
            ),
        ],
        onChanged: (v) {
          if (v == null) return;
          setState(() {
            _currencyCode = v;
            _dirty = true;
          });
        },
      ),
    ]);
  }

  Widget _buildFixedCard(BudgetPlan plan) {
    final symbol = _currency.symbol;
    return _section('المصروفات الثابتة', [
      if (_fixed.isEmpty)
        const Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: Text(
            'أضف ما يتكرر كل شهر: إيجار، أقساط، اشتراكات، فواتير.',
            style: TextStyle(color: AppTheme.subTextColor, fontSize: 13),
          ),
        ),
      for (final item in _fixed)
        ListTile(
          key: ValueKey('fixed_${item.id}'),
          contentPadding: EdgeInsets.zero,
          title: Text(item.name, style: const TextStyle(color: AppTheme.textColor)),
          subtitle: Text(
            'يوم ${item.dueDay} من الشهر',
            style: const TextStyle(color: AppTheme.subTextColor, fontSize: 12),
          ),
          onTap: () => _editFixed(existing: item),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                formatWithCurrency(item.amount, symbol),
                style: const TextStyle(color: AppTheme.textColor, fontWeight: FontWeight.w600),
              ),
              IconButton(
                tooltip: 'حذف ${item.name}',
                icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.subTextColor),
                onPressed: () => _removeFixed(item),
              ),
            ],
          ),
        ),
      if (_fixed.isNotEmpty)
        Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 4),
          child: Text(
            'المجموع: ${formatWithCurrency(plan.fixedTotal, symbol)}',
            style: const TextStyle(color: AppTheme.accentColor, fontWeight: FontWeight.bold),
          ),
        ),
      Align(
        alignment: AlignmentDirectional.centerStart,
        child: TextButton.icon(
          onPressed: _fixed.length >= BudgetPlan.maxFixedExpenses ? null : () => _editFixed(),
          icon: const Icon(Icons.add_rounded),
          label: const Text('إضافة مصروف ثابت'),
        ),
      ),
    ]);
  }

  Widget _buildSavingsCard(BudgetPlan plan) {
    final percent = _mode == SavingsMode.percent;
    return _section('هدف الادخار الشهري', [
      SegmentedButton<SavingsMode>(
        segments: const [
          ButtonSegment(value: SavingsMode.amount, label: Text('مبلغ')),
          ButtonSegment(value: SavingsMode.percent, label: Text('نسبة من الدخل')),
        ],
        selected: {_mode},
        onSelectionChanged: (s) => setState(() {
          _mode = s.first;
          _savingsError = null;
          _dirty = true;
        }),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: _savings,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        maxLength: 15,
        style: const TextStyle(color: AppTheme.textColor),
        decoration: _decoration(
          percent ? 'نسبة الادخار' : 'مبلغ الادخار',
          suffix: percent ? '٪' : _currency.symbol,
          error: _savingsError,
          helper: percent && plan.income > 0 ? 'يساوي ${formatWithCurrency(plan.savingsAmount, _currency.symbol)} شهريًا' : null,
        ),
        onChanged: (_) {
          _savingsError = null;
          _touch();
        },
      ),
    ]);
  }

  Widget _buildLimitsCard() {
    return _section('حدود الفئات (اختياري)', [
      const Text(
        'حدّ أقصى للصرف في كل فئة خلال الدورة. اتركه فارغًا لعدم وضع حد.',
        style: TextStyle(color: AppTheme.subTextColor, fontSize: 13),
      ),
      const SizedBox(height: 12),
      for (final category in ExpenseCategory.values)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: TextField(
            controller: _limits[category],
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            maxLength: 15,
            style: const TextStyle(color: AppTheme.textColor),
            decoration: _decoration('حد ${category.arabicLabel}', suffix: _currency.symbol, error: _limitErrors[category]),
            onChanged: (_) {
              _limitErrors[category] = null;
              _touch();
            },
          ),
        ),
    ]);
  }

  Widget _buildSummaryCard(BudgetPlan plan) {
    final symbol = _currency.symbol;
    final warnings = <String>[
      if (plan.income > 0 && plan.overcommitted)
        'المصروفات الثابتة والادخار (${formatWithCurrency(plan.fixedTotal + plan.savingsAmount, symbol)}) أكبر من الدخل (${formatWithCurrency(plan.income, symbol)}). لن يبقى شيء للصرف.',
      if (plan.income > 0 && !plan.overcommitted && plan.limitsTotal > plan.available)
        'مجموع حدود الفئات (${formatWithCurrency(plan.limitsTotal, symbol)}) أكبر من المتاح للصرف (${formatWithCurrency(plan.available, symbol)}).',
    ];
    Widget row(String label, double value, {bool bold = false}) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(
            children: [
              Expanded(child: Text(label, style: const TextStyle(color: AppTheme.subTextColor))),
              Text(
                formatWithCurrency(value, symbol),
                style: TextStyle(
                  color: bold ? AppTheme.accentColor : AppTheme.textColor,
                  fontWeight: bold ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ],
          ),
        );
    return _section('ملخص الخطة', [
      row('الدخل', plan.income),
      row('المصروفات الثابتة', plan.fixedTotal),
      row('الادخار', plan.savingsAmount),
      const Divider(color: AppTheme.surfaceColor),
      row('المتاح للصرف', plan.available, bold: true),
      for (final w in warnings)
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.orangeAccent, size: 20),
              const SizedBox(width: 8),
              Expanded(child: Text(w, style: const TextStyle(color: Colors.orangeAccent, height: 1.5))),
            ],
          ),
        ),
    ]);
  }
}
