import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'budget_service.dart';
import 'models/expense_entry.dart';

/// يرجع true عند حفظ مصروف حتى تُحدّث الشاشة السابقة.
class ExpenseEntryScreen extends StatefulWidget {
  const ExpenseEntryScreen({super.key});

  @override
  State<ExpenseEntryScreen> createState() => _ExpenseEntryScreenState();
}

class _ExpenseEntryScreenState extends State<ExpenseEntryScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  ExpenseCategory? _category;
  bool _saving = false;

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
    await budget.addExpense(
      amount: amount,
      category: category,
      note: _noteController.text,
    );
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('تسجيل مصروف')),
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
                decoration: const InputDecoration(
                  labelText: 'المبلغ',
                  labelStyle: TextStyle(color: AppTheme.subTextColor),
                  suffixText: 'ر.س',
                  suffixStyle: TextStyle(color: AppTheme.subTextColor, fontSize: 18),
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
              TextField(
                controller: _noteController,
                maxLines: 2,
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
