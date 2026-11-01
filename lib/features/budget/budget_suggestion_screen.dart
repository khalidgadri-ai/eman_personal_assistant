import 'package:flutter/material.dart';
import '../../core/ai/ai_service.dart';
import '../../core/ai/ai_settings_service.dart';
import '../../core/ai/provider_presets.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/ai_provider_screen.dart';
import 'budget_calculator.dart';
import 'budget_format.dart';
import 'budget_plan_service.dart';
import 'models/budget_plan.dart';
import 'models/budget_suggestion.dart';
import 'models/expense_entry.dart';

/// يحصل على [AiService] جاهز (وقد يعرض شاشة إعداد المزوّد)، أو null. يُستبدل في الاختبارات.
typedef AiResolver = Future<AiService?> Function(BuildContext context);

/// اقتراح ميزانية: حدود للفئات تُحسب محليًا بقاعدة بسيطة دائمًا، واقتراح بالذكاء الاصطناعي
/// اختياري. **لا يُرسل أي رقم مالي إلى المزوّد إلا بعد موافقة صريحة في كل مرة** تعرض ما سيُرسل
/// بالضبط. أي اقتراح يُحفظ كحدود للفئات بضغطة واحدة ويُعدَّل لاحقًا من "تعديل الخطة".
/// ترجّع true إذا حُفظت الحدود.
class BudgetSuggestionScreen extends StatefulWidget {
  const BudgetSuggestionScreen({super.key, required this.plan, this.aiResolver = requireAiService});

  final BudgetPlan plan;
  final AiResolver aiResolver;

  @override
  State<BudgetSuggestionScreen> createState() => _BudgetSuggestionScreenState();
}

class _BudgetSuggestionScreenState extends State<BudgetSuggestionScreen> {
  BudgetSuggestion? _ai;
  String? _aiFailure;
  bool _asking = false;
  bool _saving = false;

  BudgetPlan get _plan => widget.plan;
  String get _symbol => _plan.currency.symbol;

  Future<void> _saveLimits(Map<ExpenseCategory, double> limits) async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      final service = await BudgetPlanService.getInstance();
      await service.saveLimits(limits);
    } catch (e) {
      debugPrint('BudgetSuggestionScreen: save failed (${e.runtimeType})');
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تعذّر حفظ الحدود. حاول مرة أخرى')));
      return;
    }
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  Future<String> _providerLabel() async {
    try {
      final settings = await AiSettingsService.getInstance();
      final id = settings.selectedId;
      final preset = AiPresets.all.where((p) => p.id == id).firstOrNull;
      if (preset != null) return preset.label;
    } catch (_) {}
    return 'مزوّد الذكاء الاصطناعي الذي اخترته';
  }

  Future<void> _askAi() async {
    final ai = await widget.aiResolver(context);
    if (ai == null || !mounted) return;

    final provider = await _providerLabel();
    if (!mounted) return;
    final consent = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: AppTheme.cardColor,
          title: const Text('إرسال بياناتك المالية؟', style: TextStyle(color: AppTheme.textColor)),
          content: SingleChildScrollView(
            child: Text(
              'سيُرسل إلى «$provider» الأرقام التالية فقط:\n'
              '• الدخل الشهري: ${formatWithCurrency(_plan.income, _symbol)}\n'
              '• مجموع المصروفات الثابتة: ${formatWithCurrency(_plan.fixedTotal, _symbol)}\n'
              '• هدف الادخار: ${formatWithCurrency(_plan.savingsAmount, _symbol)}\n'
              '• المتاح للصرف: ${formatWithCurrency(_plan.available, _symbol)}\n\n'
              'لن تُرسل أسماء مصروفاتك الثابتة ولا مصاريفك المسجَّلة. ما يُرسل يخضع لسياسة هذا المزوّد. '
              'نسألك في كل مرة، ولا شيء يُرسل قبل موافقتك.',
              style: const TextStyle(color: AppTheme.subTextColor, height: 1.7),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('إلغاء', style: TextStyle(color: AppTheme.subTextColor)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('أوافق وأرسل هذه المرة', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
    if (consent != true || !mounted) return;

    setState(() {
      _asking = true;
      _ai = null;
      _aiFailure = null;
    });
    final reply = await ai.suggestBudgetLimits(
      income: _plan.income,
      fixedTotal: _plan.fixedTotal,
      savings: _plan.savingsAmount,
      available: _plan.available,
      currencyName: _plan.currency.arabicName,
    );
    if (!mounted) return;
    final parsed = BudgetSuggestion.tryParse(reply);
    setState(() {
      _asking = false;
      _ai = parsed;
      _aiFailure = parsed == null
          ? 'لم أتمكن من قراءة الاقتراح كحدود للفئات. ${String.fromCharCodes(reply.trim().runes.take(200))}'
          : null;
    });
  }

  Widget _limitsTable(Map<ExpenseCategory, double> limits) {
    return Column(
      children: [
        for (final entry in limits.entries)
          ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: Icon(entry.key.icon, color: AppTheme.accentColor),
            title: Text(entry.key.arabicLabel, style: const TextStyle(color: AppTheme.textColor)),
            trailing: Text(
              formatWithCurrency(entry.value, _symbol),
              style: const TextStyle(color: AppTheme.textColor, fontWeight: FontWeight.w600),
            ),
          ),
      ],
    );
  }

  Widget _saveButton(Map<ExpenseCategory, double> limits) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          padding: const EdgeInsets.symmetric(vertical: 13),
        ),
        onPressed: _saving ? null : () => _saveLimits(limits),
        child: const Text('حفظ كحدود للفئات', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _card(List<Widget> children) {
    return Card(
      color: AppTheme.cardColor,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
      ),
    );
  }

  static String _ruleText() {
    return defaultLimitWeights.entries
        .map((e) => '${e.key.arabicLabel} ${(e.value * 100).round()}٪')
        .join('، ');
  }

  @override
  Widget build(BuildContext context) {
    final available = _plan.available;
    final local = BudgetCalculator.suggestLimits(available);
    final ai = _ai;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('اقتراح ميزانية')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _card([
              const Text('المتاح للصرف شهريًا', style: TextStyle(color: AppTheme.subTextColor, fontSize: 13)),
              const SizedBox(height: 4),
              Text(
                formatWithCurrency(available, _symbol),
                style: const TextStyle(color: AppTheme.accentColor, fontSize: 26, fontWeight: FontWeight.bold),
              ),
            ]),
            if (local.isEmpty)
              _card(const [
                Text(
                  'لا يوجد متاح للصرف في خطتك الآن، فلا يمكن اقتراح حدود. عدّل الدخل أو المصروفات الثابتة أو الادخار أولًا.',
                  style: TextStyle(color: Colors.orangeAccent, height: 1.6),
                ),
              ])
            else ...[
              _card([
                const Text(
                  'اقتراح محلي (بلا إنترنت)',
                  style: TextStyle(color: AppTheme.textColor, fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 4),
                Text(
                  'قاعدة بسيطة توزّع المتاح هكذا: ${_ruleText()}. بعد الحفظ تعدّل أي حد من «تعديل الخطة».',
                  style: const TextStyle(color: AppTheme.subTextColor, fontSize: 12, height: 1.6),
                ),
                const SizedBox(height: 8),
                _limitsTable(local),
                const SizedBox(height: 8),
                _saveButton(local),
              ]),
              _card([
                const Text(
                  'اقتراح بالذكاء الاصطناعي (اختياري)',
                  style: TextStyle(color: AppTheme.textColor, fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 4),
                const Text(
                  'يرسل أرقام خطتك المالية إلى المزوّد الذي اخترته، ولا يُرسل شيء إلا بموافقتك في كل مرة.',
                  style: TextStyle(color: AppTheme.subTextColor, fontSize: 12, height: 1.6),
                ),
                const SizedBox(height: 12),
                if (_asking)
                  const Center(child: CircularProgressIndicator(color: AppTheme.accentColor))
                else
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _askAi,
                      icon: const Icon(Icons.auto_awesome, color: AppTheme.accentColor),
                      label: const Text('اطلب اقتراحًا بالذكاء الاصطناعي'),
                    ),
                  ),
                if (_aiFailure != null) ...[
                  const SizedBox(height: 12),
                  Text(_aiFailure!, style: const TextStyle(color: Colors.orangeAccent, height: 1.6)),
                ],
                if (ai != null) ...[
                  const SizedBox(height: 12),
                  if (ai.note.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(ai.note, style: const TextStyle(color: AppTheme.subTextColor, height: 1.6)),
                    ),
                  _limitsTable(ai.limits),
                  if (ai.total > available)
                    Padding(
                      padding: const EdgeInsets.only(top: 4, bottom: 4),
                      child: Text(
                        'مجموع هذا الاقتراح (${formatWithCurrency(ai.total, _symbol)}) أكبر من المتاح للصرف. عدّله بعد الحفظ.',
                        style: const TextStyle(color: Colors.orangeAccent, height: 1.6),
                      ),
                    ),
                  const SizedBox(height: 8),
                  _saveButton(ai.limits),
                ],
              ]),
            ],
          ],
        ),
      ),
    );
  }
}
