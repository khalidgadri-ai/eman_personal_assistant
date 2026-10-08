import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'models/expense_entry.dart';

/// إدخال يدوي فقط: لا ربط بنكي ولا بطاقات ولا أي API مالي خارجي.
class BudgetService {
  static const String _boxName = 'expenses';

  static BudgetService? _instance;
  static Box? _box;

  BudgetService._();

  static Future<BudgetService> getInstance() async {
    _instance ??= BudgetService._();
    _box ??= await Hive.openBox(_boxName);
    return _instance!;
  }

  @visibleForTesting
  static void resetForTesting() {
    _instance = null;
    _box = null;
  }

  Future<ExpenseEntry> addExpense({
    required double amount,
    required ExpenseCategory category,
    String? note,
    DateTime? date,
  }) async {
    final trimmedNote = note?.trim();
    final data = {
      'amount': amount,
      'category': category.name,
      'note': (trimmedNote == null || trimmedNote.isEmpty) ? null : trimmedNote,
      'date': date ?? DateTime.now(),
    };
    final key = await _box!.add(data);
    return ExpenseEntry.fromMap(key.toString(), data);
  }

  List<ExpenseEntry> getExpensesForMonth(DateTime month) {
    return _newestFirst(
      (e) => e.date.year == month.year && e.date.month == month.month,
    );
  }

  List<ExpenseEntry> getExpensesSince(DateTime from) {
    return _newestFirst((e) => !e.date.isBefore(from));
  }

  List<ExpenseEntry> _newestFirst(bool Function(ExpenseEntry) test) {
    return _box!
        .toMap()
        .entries
        .map((e) => ExpenseEntry.fromMap(e.key.toString(), e.value as Map))
        .where(test)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  /// الفئات التي لا صرف فيها خلال الشهر لا تظهر في النتيجة.
  Map<ExpenseCategory, double> getTotalByCategory(DateTime month) {
    final totals = <ExpenseCategory, double>{};
    for (final entry in getExpensesForMonth(month)) {
      totals[entry.category] = (totals[entry.category] ?? 0) + entry.amount;
    }
    return totals;
  }

  double getTotalForMonth(DateTime month) {
    return getExpensesForMonth(month).fold(0, (sum, entry) => sum + entry.amount);
  }
}
