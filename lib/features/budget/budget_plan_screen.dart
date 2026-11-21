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
import '../../l10n/l10n.dart';

/// إعداد خطة الميزانية: الدخل ويوم الراتب والعملة والمصروفات الثابتة وهدف الادخار وحدود الفئات.
/// لا يُحفظ شيء حتى يضغط المستخدم "حفظ الخطة"، وإن خرج بتعديلات غير محفوظة يُسأل أولًا.
/// ترجّع true إذا حُفظت الخطة.
class BudgetPlanScreen extends StatefulWidget {
  const BudgetPlanScreen({super.key, this.countryCode});

  /// بلد الهاتف لاقتراح العملة قبل أول حفظ؛ null = بلد الهاتف الفعلي. يُستبدل في الاختبارات.
  final String? countryCode;

  @override
  State<BudgetPlanScreen> createState() => _BudgetPlanScreenState();
}

class _BudgetPlanScreenState extends State<BudgetPlanScreen> {
  String get _invalidAmount => context.l10n.invalidAmountPositive;

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
      // قبل أول حفظ تُقترح عملة بلد الهاتف؛ المستخدم يغيّرها من القائمة.
      _currencyCode = plan.displayCurrency(widget.countryCode).code;
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

  String get _symbol => _currency.symbolFor(context.appLang);

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
          ? (_mode == SavingsMode.percent ? context.l10n.percentRange : context.l10n.savingsAmountInvalid)
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
      showInfoSnackBar(context, context.l10n.checkRedFields);
      return false;
    }
    setState(() => _saving = true);
    try {
      await _service!.save(plan);
    } catch (e) {
      debugPrint('BudgetPlanScreen: save failed (${e.runtimeType})');
      if (!mounted) return false;
      setState(() => _saving = false);
      showInfoSnackBar(context, context.l10n.planSaveFailed);
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
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        title: Text(context.l10n.unsavedChanges, style: TextStyle(color: AppTheme.textColor)),
        content: Text(
          context.l10n.unsavedPlanBody,
          style: TextStyle(color: AppTheme.subTextColor, height: 1.6),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, 'stay'),
            child: Text(context.l10n.keepEditing, style: TextStyle(color: AppTheme.subTextColor)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, 'discard'),
            child: Text(context.l10n.leaveWithoutSaving, style: TextStyle(color: Colors.redAccent)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
            onPressed: () => Navigator.pop(dialogContext, 'save'),
            child: Text(context.l10n.savePlan, style: TextStyle(color: Colors.white)),
          ),
        ],
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
      title: existing == null ? context.l10n.newFixedExpense : context.l10n.editFixedExpense,
      confirmLabel: existing == null ? context.l10n.add : context.l10n.save,
      fields: [
        EntryField(
          key: 'name',
          label: context.l10n.expenseName,
          hint: context.l10n.expenseNameHint,
          required: true,
          maxLength: FixedExpense.maxNameLength,
          initial: existing?.name,
        ),
        EntryField(
          key: 'amount',
          label: context.l10n.amountLabel,
          required: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          maxLength: 15,
          initial: existing == null ? null : _plain(existing.amount),
          validator: (v) => parseAmount(v) == null ? _invalidAmount : null,
        ),
        EntryField(
          key: 'day',
          label: context.l10n.dueDayField,
          required: true,
          keyboardType: TextInputType.number,
          maxLength: 2,
          initial: existing?.dueDay.toString(),
          validator: (v) {
            final day = parseInteger(v);
            return day == null || day < 1 || day > 31 ? context.l10n.dueDayInvalid : null;
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
    showUndoSnackBar(context, context.l10n.itemDeleted(item.name), () async {
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
    return PopScope(
      canPop: !_dirty,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _onBackWithChanges();
      },
      child: Scaffold(
        appBar: AppBar(title: Text(context.l10n.budgetPlanTitle)),
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
                      child: Text(context.l10n.savePlan, style: TextStyle(color: Colors.white, fontSize: 16)),
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
    return _section(context.l10n.incomeAndCycle, [
      TextField(
        controller: _income,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        maxLength: 15,
        style: const TextStyle(color: AppTheme.textColor),
        decoration: _decoration(context.l10n.monthlyIncome, suffix: _symbol, error: _incomeError),
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
        decoration: _decoration(context.l10n.paydayField, helper: context.l10n.paydayHelper),
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
        decoration: _decoration(context.l10n.currencyField),
        items: [
          for (final c in BudgetCurrency.all)
            DropdownMenuItem(
              value: c.code,
              child: Text('${c.nameFor(context.appLang)} (${c.symbolFor(context.appLang)})', style: const TextStyle(color: AppTheme.textColor)),
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
    return _section(context.l10n.fixedExpenses, [
      if (_fixed.isEmpty)
        Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: Text(
            context.l10n.fixedEmptyHint,
            style: TextStyle(color: AppTheme.subTextColor, fontSize: 13),
          ),
        ),
      for (final item in _fixed)
        ListTile(
          key: ValueKey('fixed_${item.id}'),
          contentPadding: EdgeInsets.zero,
          title: Text(item.name, style: const TextStyle(color: AppTheme.textColor)),
          subtitle: Text(
            context.l10n.dueDayLine(item.dueDay),
            style: const TextStyle(color: AppTheme.subTextColor, fontSize: 12),
          ),
          onTap: () => _editFixed(existing: item),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                formatWithCurrency(item.amount, _symbol),
                style: const TextStyle(color: AppTheme.textColor, fontWeight: FontWeight.w600),
              ),
              IconButton(
                tooltip: context.l10n.deleteNamed(item.name),
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
            context.l10n.totalLine(formatWithCurrency(plan.fixedTotal, _symbol)),
            style: const TextStyle(color: AppTheme.accentColor, fontWeight: FontWeight.bold),
          ),
        ),
      Align(
        alignment: AlignmentDirectional.centerStart,
        child: TextButton.icon(
          onPressed: _fixed.length >= BudgetPlan.maxFixedExpenses ? null : () => _editFixed(),
          icon: const Icon(Icons.add_rounded),
          label: Text(context.l10n.addFixedExpense),
        ),
      ),
    ]);
  }

  Widget _buildSavingsCard(BudgetPlan plan) {
    final percent = _mode == SavingsMode.percent;
    return _section(context.l10n.monthlySavingsGoal, [
      SegmentedButton<SavingsMode>(
        segments: [
          ButtonSegment(value: SavingsMode.amount, label: Text(context.l10n.savingsModeAmount)),
          ButtonSegment(value: SavingsMode.percent, label: Text(context.l10n.savingsModePercent)),
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
          percent ? context.l10n.savingsPercentField : context.l10n.savingsAmountField,
          suffix: percent ? context.l10n.percentSign : _symbol,
          error: _savingsError,
          helper: percent && plan.income > 0 ? context.l10n.equalsMonthly(formatWithCurrency(plan.savingsAmount, _symbol)) : null,
        ),
        onChanged: (_) {
          _savingsError = null;
          _touch();
        },
      ),
    ]);
  }

  Widget _buildLimitsCard() {
    return _section(context.l10n.categoryLimitsOptional, [
      Text(
        context.l10n.categoryLimitsHint,
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
            decoration: _decoration(context.l10n.categoryLimitField(category.label(context.l10n)), suffix: _symbol, error: _limitErrors[category]),
            onChanged: (_) {
              _limitErrors[category] = null;
              _touch();
            },
          ),
        ),
    ]);
  }

  Widget _buildSummaryCard(BudgetPlan plan) {
    final warnings = <String>[
      if (plan.income > 0 && plan.overcommitted)
        context.l10n.planOvercommitted(
          formatWithCurrency(plan.fixedTotal + plan.savingsAmount, _symbol),
          formatWithCurrency(plan.income, _symbol),
        ),
      if (plan.income > 0 && !plan.overcommitted && plan.limitsTotal > plan.available)
        context.l10n.limitsOverAvailable(formatWithCurrency(plan.limitsTotal, _symbol), formatWithCurrency(plan.available, _symbol)),
    ];
    Widget row(String label, double value, {bool bold = false}) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(
            children: [
              Expanded(child: Text(label, style: const TextStyle(color: AppTheme.subTextColor))),
              Text(
                formatWithCurrency(value, _symbol),
                style: TextStyle(
                  color: bold ? AppTheme.accentColor : AppTheme.textColor,
                  fontWeight: bold ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ],
          ),
        );
    return _section(context.l10n.planSummary, [
      row(context.l10n.incomeLabel, plan.income),
      row(context.l10n.fixedExpenses, plan.fixedTotal),
      row(context.l10n.savingsLabel, plan.savingsAmount),
      const Divider(color: AppTheme.surfaceColor),
      row(context.l10n.availableToSpend, plan.available, bold: true),
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
