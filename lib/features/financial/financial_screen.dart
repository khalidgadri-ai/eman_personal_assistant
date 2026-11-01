import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/ai_provider_screen.dart';
import '../../core/widgets/undo_snackbar.dart';
import '../budget/budget_calculator.dart';
import '../budget/budget_format.dart';
import '../budget/budget_plan_screen.dart';
import '../budget/budget_plan_service.dart';
import '../budget/budget_service.dart';
import '../budget/budget_suggestion_screen.dart';
import '../budget/budget_summary_screen.dart';
import '../budget/expense_entry_screen.dart';
import '../budget/models/budget_plan.dart';
import '../budget/models/expense_entry.dart';
import '../settings/settings_button.dart';

const Color _green = Color(0xFF22C55E);
const Color _amber = Color(0xFFF59E0B);
const Color _red = Color(0xFFEF4444);

Color _levelColor(BudgetLevel level) => switch (level) {
      BudgetLevel.ok => _green,
      BudgetLevel.near => _amber,
      BudgetLevel.over => _red,
    };

/// تبويب الميزانية: بطاقة واضحة بالدخل والثابتة والادخار والمتاح والمصروف والمتبقي والمتاح يوميًا،
/// ثم توزيع الصرف على الفئات مقابل حدودها، ثم آخر المصاريف. كل الحسابات محلية بلا ذكاء اصطناعي،
/// والخطة تُحفظ في صندوق مشفّر ([BudgetPlanService]).
class FinancialScreen extends StatefulWidget {
  /// [now] و[aiResolver] يُستبدلان في الاختبارات فقط.
  const FinancialScreen({super.key, this.now = DateTime.now, this.aiResolver = requireAiService});

  final DateTime Function() now;
  final AiResolver aiResolver;

  @override
  State<FinancialScreen> createState() => _FinancialScreenState();
}

class _FinancialScreenState extends State<FinancialScreen> {
  BudgetPlanService? _planService;
  BudgetService? _expenses;
  BudgetPlan _plan = const BudgetPlan();
  BudgetSnapshot? _snapshot;
  List<ExpenseEntry> _recent = const [];
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _failed = false);
    try {
      final planService = await BudgetPlanService.getInstance();
      final expenses = await BudgetService.getInstance();
      if (!mounted) return;
      _planService = planService;
      _expenses = expenses;
      _refresh();
    } catch (e) {
      debugPrint('FinancialScreen: could not open budget data (${e.runtimeType})');
      if (mounted) setState(() => _failed = true);
    }
  }

  /// يعيد قراءة الخطة والمصاريف ويحسب أرقام الدورة الحالية.
  void _refresh() {
    final planService = _planService;
    final expenses = _expenses;
    if (planService == null || expenses == null) return;
    final plan = planService.plan;
    final today = widget.now();
    final cycle = BudgetCycle.containing(today, plan.payday);
    final inCycle = [for (final e in expenses.getExpensesSince(cycle.start)) if (cycle.contains(e.date)) e];
    setState(() {
      _plan = plan;
      _snapshot = BudgetCalculator.compute(plan, inCycle, today);
      _recent = inCycle.take(5).toList();
    });
  }

  String get _symbol => _plan.currency.symbol;

  Future<void> _openPlan() async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const BudgetPlanScreen()),
    );
    _refresh();
    if (saved == true && mounted) showInfoSnackBar(context, 'حُفظت خطة الميزانية');
  }

  Future<void> _openSuggestion() async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => BudgetSuggestionScreen(plan: _plan, aiResolver: widget.aiResolver)),
    );
    _refresh();
    if (saved == true && mounted) showInfoSnackBar(context, 'حُفظت الحدود. عدّلها من «تعديل الخطة»');
  }

  Future<void> _addExpense() async {
    await Navigator.of(context).push<ExpenseEntry>(
      MaterialPageRoute(builder: (_) => const ExpenseEntryScreen()),
    );
    _refresh();
  }

  Future<void> _openMonthlyExpenses() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(builder: (_) => const BudgetSummaryScreen()),
    );
    _refresh();
  }

  Future<void> _setPaid(FixedExpense item, bool paid) async {
    final snapshot = _snapshot;
    if (snapshot == null) return;
    await _planService!.setPaid(item.id, paid, cycleKey: snapshot.cycle.key);
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = _snapshot;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('💰 المحفظة المالية والميزانية'),
          actions: [
            IconButton(
              tooltip: 'مصاريفي الشهرية',
              icon: const Icon(Icons.receipt_long_rounded, color: AppTheme.accentColor),
              onPressed: _openMonthlyExpenses,
            ),
            const SettingsButton(),
          ],
        ),
        body: _failed
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('تعذّر فتح بيانات الميزانية', style: TextStyle(color: AppTheme.subTextColor)),
                    const SizedBox(height: 12),
                    ElevatedButton(onPressed: _load, child: const Text('إعادة المحاولة')),
                  ],
                ),
              )
            : snapshot == null
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                    children: [
                      if (_plan.isConfigured) ...[
                        _buildBudgetCard(snapshot),
                        if (_plan.fixed.isNotEmpty) _buildFixedCard(snapshot),
                        _buildCategoriesCard(snapshot),
                      ] else
                        _buildSetupCard(),
                      _buildRecentCard(),
                    ],
                  ),
      ),
    );
  }

  // --- البطاقات ---

  Widget _card(List<Widget> children) {
    return Card(
      color: AppTheme.surfaceColor,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
      ),
    );
  }

  Widget _buildSetupCard() {
    return _card([
      const Row(
        children: [
          Icon(Icons.account_balance_wallet_rounded, color: AppTheme.accentColor),
          SizedBox(width: 8),
          Text('ابدأ بإعداد ميزانيتك', style: TextStyle(color: AppTheme.textColor, fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
      const SizedBox(height: 8),
      const Text(
        'أدخل دخلك الشهري ويوم نزول الراتب ومصروفاتك الثابتة، وسنحسب لك كم يبقى لك وكم تصرف يوميًا. '
        'تُحفظ كل بياناتك على جهازك مشفّرة.',
        style: TextStyle(color: AppTheme.subTextColor, height: 1.6),
      ),
      const SizedBox(height: 12),
      SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor, padding: const EdgeInsets.symmetric(vertical: 13)),
          onPressed: _openPlan,
          icon: const Icon(Icons.tune_rounded, color: Colors.white),
          label: const Text('إعداد الميزانية', style: TextStyle(color: Colors.white)),
        ),
      ),
    ]);
  }

  Widget _row(String label, double value, {required Key valueKey, Color? color, bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(color: AppTheme.subTextColor))),
          Text(
            formatWithCurrency(value, _symbol),
            key: valueKey,
            style: TextStyle(color: color ?? AppTheme.textColor, fontWeight: bold ? FontWeight.bold : FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _warning(String text, {Color color = _amber}) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: TextStyle(color: color, height: 1.5))),
        ],
      ),
    );
  }

  Widget _buildBudgetCard(BudgetSnapshot s) {
    final level = s.level;
    final color = _levelColor(level);
    final percent = (s.ratio * 100).round();
    return _card([
      Row(
        children: [
          const Icon(Icons.pie_chart_rounded, color: AppTheme.accentColor),
          const SizedBox(width: 8),
          const Expanded(
            child: Text('ميزانية الدورة الحالية', style: TextStyle(color: AppTheme.textColor, fontWeight: FontWeight.bold, fontSize: 15)),
          ),
          Text('باقي ${s.daysLeft} يوم', key: const Key('days_left'), style: const TextStyle(color: AppTheme.subTextColor, fontSize: 12)),
        ],
      ),
      const SizedBox(height: 2),
      Text(
        'من ${formatDayMonth(s.cycle.start)} إلى ${formatDayMonth(s.cycle.lastDay)}',
        style: const TextStyle(color: AppTheme.subTextColor, fontSize: 12),
      ),
      const SizedBox(height: 14),
      const Text('المتبقي', style: TextStyle(color: AppTheme.subTextColor, fontSize: 13)),
      FittedBox(
        fit: BoxFit.scaleDown,
        alignment: AlignmentDirectional.centerStart,
        child: Text(
          formatWithCurrency(s.remaining, _symbol),
          key: const Key('remaining_value'),
          style: TextStyle(color: s.remaining < 0 ? _red : AppTheme.textColor, fontSize: 34, fontWeight: FontWeight.bold),
        ),
      ),
      const SizedBox(height: 10),
      ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: LinearProgressIndicator(
          key: const Key('budget_progress'),
          value: s.ratio.clamp(0.0, 1.0),
          minHeight: 12,
          color: color,
          backgroundColor: AppTheme.cardColor,
        ),
      ),
      const SizedBox(height: 6),
      Text(
        'صرفت $percent٪ من المتاح',
        key: const Key('budget_percent'),
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: 10),
      _row('الدخل', s.income, valueKey: const Key('income_value')),
      _row('المصروفات الثابتة', s.fixedTotal, valueKey: const Key('fixed_value')),
      _row('الادخار', s.savings, valueKey: const Key('savings_value')),
      const Divider(color: AppTheme.cardColor),
      _row('المتاح للصرف', s.available, valueKey: const Key('available_value'), color: AppTheme.accentColor, bold: true),
      _row('المصروف حتى الآن', s.spent, valueKey: const Key('spent_value')),
      const SizedBox(height: 8),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: AppTheme.cardColor, borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            const Icon(Icons.today_rounded, color: AppTheme.accentColor),
            const SizedBox(width: 8),
            const Expanded(child: Text('المتاح يوميًا', style: TextStyle(color: AppTheme.textColor))),
            Text(
              formatWithCurrency(s.dailyAvailable, _symbol),
              key: const Key('daily_value'),
              style: const TextStyle(color: AppTheme.accentColor, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
      ),
      if (s.overcommitted)
        _warning(
          'المصروفات الثابتة والادخار (${formatWithCurrency(s.fixedTotal + s.savings, _symbol)}) أكبر من دخلك. عدّل الخطة.',
          color: _red,
        ),
      if (!s.overcommitted && s.remaining < 0)
        _warning('تجاوزت المتاح في هذه الدورة بمقدار ${formatWithCurrency(-s.remaining, _symbol)}.', color: _red),
      if (!s.overcommitted && s.remaining >= 0 && level == BudgetLevel.near)
        _warning('اقتربت من نهاية المتاح: صرفت $percent٪ ويبقى ${formatWithCurrency(s.remaining, _symbol)}.'),
      const SizedBox(height: 12),
      Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _openPlan,
              icon: const Icon(Icons.tune_rounded, size: 18),
              label: const Text('تعديل الخطة'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _openSuggestion,
              icon: const Icon(Icons.auto_awesome, size: 18),
              label: const Text('اقتراح ميزانية'),
            ),
          ),
        ],
      ),
    ]);
  }

  Widget _buildFixedCard(BudgetSnapshot s) {
    final paidCount = _plan.fixed.where((f) => f.isPaidIn(s.cycle.key)).length;
    return _card([
      Row(
        children: [
          const Icon(Icons.event_repeat_rounded, color: AppTheme.accentColor),
          const SizedBox(width: 8),
          const Expanded(
            child: Text('المصروفات الثابتة', style: TextStyle(color: AppTheme.textColor, fontWeight: FontWeight.bold, fontSize: 15)),
          ),
          Text('دُفع $paidCount من ${_plan.fixed.length}', style: const TextStyle(color: AppTheme.subTextColor, fontSize: 12)),
        ],
      ),
      for (final item in _plan.fixed)
        CheckboxListTile(
          key: ValueKey('paid_${item.id}'),
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          activeColor: AppTheme.primaryColor,
          value: item.isPaidIn(s.cycle.key),
          onChanged: (v) => _setPaid(item, v ?? false),
          title: Text(
            item.name,
            style: TextStyle(
              color: item.isPaidIn(s.cycle.key) ? AppTheme.subTextColor : AppTheme.textColor,
              decoration: item.isPaidIn(s.cycle.key) ? TextDecoration.lineThrough : null,
            ),
          ),
          subtitle: Text(
            'يوم ${item.dueDay} من الشهر · ${formatWithCurrency(item.amount, _symbol)}',
            style: const TextStyle(color: AppTheme.subTextColor, fontSize: 12),
          ),
        ),
    ]);
  }

  Widget _buildCategoriesCard(BudgetSnapshot s) {
    final alerts = s.alerts;
    return _card([
      const Row(
        children: [
          Icon(Icons.category_rounded, color: AppTheme.accentColor),
          SizedBox(width: 8),
          Text('الصرف حسب الفئة', style: TextStyle(color: AppTheme.textColor, fontWeight: FontWeight.bold, fontSize: 15)),
        ],
      ),
      if (s.categories.isEmpty)
        const Padding(
          padding: EdgeInsets.only(top: 8),
          child: Text(
            'لا صرف مسجَّل في هذه الدورة ولا حدود للفئات. يمكنك اقتراح حدود من «اقتراح ميزانية».',
            style: TextStyle(color: AppTheme.subTextColor, height: 1.6),
          ),
        ),
      for (final alert in alerts)
        _warning(
          alert.level == BudgetLevel.over
              ? 'تجاوزت حد «${alert.category.arabicLabel}» بمقدار ${formatWithCurrency(alert.overBy, _symbol)}.'
              : 'اقتربت من حد «${alert.category.arabicLabel}»: صرفت ${(alert.ratio! * 100).round()}٪ منه.',
          color: alert.level == BudgetLevel.over ? _red : _amber,
        ),
      const SizedBox(height: 8),
      for (final c in s.categories) _categoryRow(c),
    ]);
  }

  Widget _categoryRow(CategoryStatus c) {
    final limit = c.limit;
    final color = _levelColor(c.level);
    return Padding(
      key: ValueKey('category_${c.category.name}'),
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(c.category.icon, size: 18, color: AppTheme.accentColor),
              const SizedBox(width: 8),
              Expanded(child: Text(c.category.arabicLabel, style: const TextStyle(color: AppTheme.textColor))),
              Text(
                limit == null
                    ? formatWithCurrency(c.spent, _symbol)
                    : '${formatMoney(c.spent)} / ${formatWithCurrency(limit, _symbol)}',
                style: TextStyle(color: limit == null ? AppTheme.textColor : color, fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ],
          ),
          if (limit != null) ...[
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: (c.ratio ?? 0).clamp(0.0, 1.0),
                minHeight: 8,
                color: color,
                backgroundColor: AppTheme.cardColor,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRecentCard() {
    return _card([
      const Row(
        children: [
          Icon(Icons.receipt_long_rounded, color: AppTheme.accentColor),
          SizedBox(width: 8),
          Text('آخر المصاريف', style: TextStyle(color: AppTheme.textColor, fontWeight: FontWeight.bold, fontSize: 15)),
        ],
      ),
      const SizedBox(height: 8),
      if (_recent.isEmpty)
        const Text('لا مصاريف مسجَّلة في هذه الدورة بعد.', style: TextStyle(color: AppTheme.subTextColor)),
      for (final e in _recent)
        ListTile(
          key: ValueKey('recent_${e.id}'),
          dense: true,
          contentPadding: EdgeInsets.zero,
          leading: Icon(e.category.icon, color: AppTheme.accentColor),
          title: Text(
            e.note == null || e.note!.isEmpty ? e.category.arabicLabel : e.note!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppTheme.textColor),
          ),
          subtitle: Text(
            '${e.category.arabicLabel} · ${e.date.day}/${e.date.month}',
            style: const TextStyle(color: AppTheme.subTextColor, fontSize: 12),
          ),
          trailing: Text(
            formatWithCurrency(e.amount, _symbol),
            style: const TextStyle(color: AppTheme.textColor, fontWeight: FontWeight.w600),
          ),
        ),
      const SizedBox(height: 8),
      Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
              onPressed: _addExpense,
              icon: const Icon(Icons.add_rounded, color: Colors.white),
              label: const Text('سجّل مصروف', style: TextStyle(color: Colors.white)),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton(onPressed: _openMonthlyExpenses, child: const Text('كل المصاريف')),
          ),
        ],
      ),
    ]);
  }
}
