import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'budget_plan_service.dart';
import 'budget_service.dart';
import 'models/budget_plan.dart';
import 'models/expense_entry.dart';

/// تسجيل مصروف جديد، أو تعديل [existing]. ترجّع المصروف المحفوظ (أو null عند الخروج بلا حفظ)
/// حتى تنتقل الشاشة السابقة إلى شهره وتُحدّث نفسها.
class ExpenseEntryScreen extends StatefulWidget {
  const ExpenseEntryScreen({super.key, this.existing});

  final ExpenseEntry? existing;

  @override
  State<ExpenseEntryScreen> createState() => _ExpenseEntryScreenState();
}

class _ExpenseEntryScreenState extends State<ExpenseEntryScreen> {
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;
  late DateTime _date;
  ExpenseCategory? _category;
  bool _saving = false;
  String _symbol = BudgetCurrency.sar.symbol;

  @override
  void initState() {
    super.initState();
    _loadSymbol();
    final e = widget.existing;
    _amountController = TextEditingController(text: e == null ? '' : _plainAmount(e.amount));
    _noteController = TextEditingController(text: e?.note ?? '');
    _date = e?.date ?? DateTime.now();
    _category = e?.category;
  }

  /// عملة الخطة (الريال السعودي إن لم تُعدَّ خطة بعد).
  Future<void> _loadSymbol() async {
    try {
      final symbol = (await BudgetPlanService.getInstance()).plan.currency.symbol;
      if (mounted) setState(() => _symbol = symbol);
    } catch (e) {
      debugPrint('ExpenseEntryScreen: currency unavailable (${e.runtimeType})');
    }
  }

  /// المبلغ للتحرير: "25" لا "25.0".
  static String _plainAmount(double value) =>
      value == value.roundToDouble() ? value.toInt().toString() : value.toString();

  static String _dateLabel(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date.isAfter(now) ? now : _date,
      firstDate: DateTime(2000),
      lastDate: now,
    );
    if (picked == null || !mounted) return;
    // يوم جديد بنفس وقت اليوم السابق: الترتيب داخل اليوم الواحد لا يتغير.
    setState(() => _date = DateTime(picked.year, picked.month, picked.day, _date.hour, _date.minute));
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final amount = parseAmount(_amountController.text);
    final category = _category;
    if (amount == null || category == null) return;

    setState(() => _saving = true);
    final budget = await BudgetService.getInstance();
    final existing = widget.existing;
    final saved = existing == null
        ? await budget.addExpense(amount: amount, category: category, note: _noteController.text, date: _date)
        : await budget.updateExpense(
            existing.id,
            amount: amount,
            category: category,
            note: _noteController.text,
            date: _date,
          );
    if (!mounted) return;
    Navigator.of(context).pop(saved);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: Text(widget.existing == null ? 'تسجيل مصروف' : 'تعديل مصروف')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _amountController,
                autofocus: true,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(
                  color: AppTheme.textColor,
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  labelText: 'المبلغ',
                  labelStyle: const TextStyle(color: AppTheme.subTextColor),
                  suffixText: _symbol,
                  suffixStyle: const TextStyle(color: AppTheme.subTextColor, fontSize: 18),
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 24),
              const Text(
                'الفئة',
                style: TextStyle(color: AppTheme.subTextColor, fontSize: 13),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final category in ExpenseCategory.values)
                    ChoiceChip(
                      avatar: Icon(
                        category.icon,
                        size: 18,
                        color: _category == category ? Colors.white : AppTheme.accentColor,
                      ),
                      label: Text(category.arabicLabel),
                      selected: _category == category,
                      selectedColor: AppTheme.primaryColor,
                      backgroundColor: AppTheme.cardColor,
                      labelStyle: TextStyle(
                        color: _category == category ? Colors.white : AppTheme.textColor,
                      ),
                      showCheckmark: false,
                      onSelected: (_) => setState(() => _category = category),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  const Icon(Icons.calendar_today_rounded, size: 18, color: AppTheme.accentColor),
                  const SizedBox(width: 8),
                  Text(
                    'التاريخ: ${_dateLabel(_date)}',
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(color: AppTheme.textColor),
                  ),
                  const Spacer(),
                  TextButton(onPressed: _pickDate, child: const Text('تغيير التاريخ')),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _noteController,
                maxLines: 2,
                maxLength: ExpenseEntry.maxNoteLength,
                style: const TextStyle(color: AppTheme.textColor),
                decoration: const InputDecoration(
                  labelText: 'ملاحظة (اختياري)',
                  labelStyle: TextStyle(color: AppTheme.subTextColor),
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: _saving ||
                          _category == null ||
                          parseAmount(_amountController.text) == null
                      ? null
                      : _save,
                  child: const Text('حفظ', style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
