import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import '../../core/theme/app_theme.dart';
import '../../core/utils/nice_axis_step.dart';
import 'budget_service.dart';
import 'expense_entry_screen.dart';
import 'models/expense_entry.dart';

const List<String> _arabicMonths = [
  'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
  'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
];

final intl.NumberFormat _money = intl.NumberFormat('#,##0.##');
final intl.NumberFormat _compact = intl.NumberFormat.compact();

// fl_chart يرسم من اليسار لليمين دائمًا، فنعكس الترتيب ليبدأ القارئ العربي من اليمين.
final List<ExpenseCategory> _chartOrder = ExpenseCategory.values.reversed.toList();

class BudgetSummaryScreen extends StatefulWidget {
  const BudgetSummaryScreen({super.key});

  @override
  State<BudgetSummaryScreen> createState() => _BudgetSummaryScreenState();
}

class _BudgetSummaryScreenState extends State<BudgetSummaryScreen> {
  BudgetService? _budget;
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);
  double _total = 0;
  Map<ExpenseCategory, double> _byCategory = const {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final budget = _budget ?? await BudgetService.getInstance();
    if (!mounted) return;
    setState(() {
      _budget = budget;
      _total = budget.getTotalForMonth(_month);
      _byCategory = budget.getTotalByCategory(_month);
    });
  }

  bool get _isCurrentMonth {
    final now = DateTime.now();
    return _month.year == now.year && _month.month == now.month;
  }

  void _shiftMonth(int delta) {
    _month = DateTime(_month.year, _month.month + delta);
    _load();
  }

  Future<void> _addExpense() async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const ExpenseEntryScreen()),
    );
    if (saved != true) return;
    final now = DateTime.now();
    _month = DateTime(now.year, now.month);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('مصاريفي الشهرية')),
        floatingActionButton: FloatingActionButton.extended(
          heroTag: 'add_expense_fab',
          backgroundColor: AppTheme.primaryColor,
          onPressed: _addExpense,
          icon: const Icon(Icons.add_rounded, color: Colors.white),
          label: const Text('سجّل مصروف', style: TextStyle(color: Colors.white)),
        ),
        body: _budget == null
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                children: [
                  _buildMonthSwitcher(),
                  const SizedBox(height: 16),
                  _buildHeroTotal(),
                  const SizedBox(height: 24),
                  if (_total == 0)
                    const Padding(
                      padding: EdgeInsets.only(top: 32),
                      child: Center(
                        child: Text(
                          'لا توجد مصاريف مسجلة في هذا الشهر',
                          style: TextStyle(color: AppTheme.subTextColor),
                        ),
                      ),
                    )
                  else ...[
                    _buildChartCard(),
                    const SizedBox(height: 16),
                    _buildBreakdown(),
                  ],
                ],
              ),
      ),
    );
  }

  Widget _buildMonthSwitcher() {
    return Row(
      children: [
        IconButton(
          tooltip: 'الشهر السابق',
          icon: const Icon(Icons.chevron_right_rounded, color: AppTheme.textColor),
          onPressed: () => _shiftMonth(-1),
        ),
        Expanded(
          child: Text(
            '${_arabicMonths[_month.month - 1]} ${_month.year}',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppTheme.textColor, fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        IconButton(
          tooltip: 'الشهر التالي',
          icon: const Icon(Icons.chevron_left_rounded),
          color: AppTheme.textColor,
          disabledColor: AppTheme.surfaceColor,
          onPressed: _isCurrentMonth ? null : () => _shiftMonth(1),
        ),
      ],
    );
  }

  Widget _buildHeroTotal() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('إجمالي الصرف', style: TextStyle(color: AppTheme.subTextColor, fontSize: 13)),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: AlignmentDirectional.centerStart,
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: _money.format(_total),
                  style: const TextStyle(
                    color: AppTheme.textColor,
                    fontSize: 48,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const TextSpan(
                  text: ' ر.س',
                  style: TextStyle(color: AppTheme.subTextColor, fontSize: 18),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChartCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'التوزيع حسب الفئة',
            style: TextStyle(color: AppTheme.textColor, fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          SizedBox(height: 220, child: _buildChart()),
        ],
      ),
    );
  }

  Widget _buildChart() {
    final values = [for (final c in _chartOrder) _byCategory[c] ?? 0.0];
    final maxValue = values.reduce(math.max);
    final step = niceAxisStep(maxValue / 4);
    final maxY = step * (maxValue / step).ceil();
    const axisStyle = TextStyle(color: AppTheme.subTextColor, fontSize: 11);

    return BarChart(
      BarChartData(
        minY: 0,
        maxY: maxY,
        alignment: BarChartAlignment.spaceAround,
        barGroups: [
          for (var i = 0; i < _chartOrder.length; i++)
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: values[i],
                  width: 20,
                  color: AppTheme.primaryColor,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                ),
              ],
            ),
        ],
        gridData: FlGridData(
          drawVerticalLine: false,
          horizontalInterval: step,
          getDrawingHorizontalLine: (_) =>
              const FlLine(color: AppTheme.surfaceColor, strokeWidth: 1),
        ),
        borderData: FlBorderData(
          show: true,
          border: const Border(bottom: BorderSide(color: AppTheme.surfaceColor)),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 44,
              interval: step,
              getTitlesWidget: (value, meta) => SideTitleWidget(
                meta: meta,
                child: Text(_compact.format(value), style: axisStyle),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (value, meta) => SideTitleWidget(
                meta: meta,
                child: Text(_chartOrder[value.toInt()].arabicLabel, style: axisStyle),
              ),
            ),
          ),
        ),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => AppTheme.surfaceColor,
            getTooltipItem: (group, groupIndex, rod, rodIndex) => BarTooltipItem(
              '${_chartOrder[group.x].arabicLabel}\n${_money.format(rod.toY)} ر.س',
              const TextStyle(color: AppTheme.textColor, fontSize: 12),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBreakdown() {
    final rows = _byCategory.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          for (final row in rows)
            ListTile(
              leading: Icon(row.key.icon, color: AppTheme.accentColor),
              title: Text(row.key.arabicLabel, style: const TextStyle(color: AppTheme.textColor)),
              subtitle: Text(
                '${(row.value / _total * 100).round()}٪ من الإجمالي',
                style: const TextStyle(color: AppTheme.subTextColor, fontSize: 12),
              ),
              trailing: Text(
                '${_money.format(row.value)} ر.س',
                style: const TextStyle(
                  color: AppTheme.textColor,
                  fontWeight: FontWeight.w600,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
