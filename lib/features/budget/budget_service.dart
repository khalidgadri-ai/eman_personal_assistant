import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../../core/services/encrypted_boxes.dart';
import 'models/expense_entry.dart';

/// إدخال يدوي فقط: لا ربط بنكي ولا بطاقات ولا أي API مالي خارجي.
class BudgetService {
  static const String _boxName = 'expenses';

  static BudgetService? _instance;
  static Box? _box;

  BudgetService._();

  static Future<BudgetService> getInstance() async {
    _instance ??= BudgetService._();
    _box ??= await EncryptedBoxes.open(_boxName);
    return _instance!;
  }

  /// يُنسى الصندوق المفتوح (بعد مسح بيانات المستخدم يُفتح صندوق جديد عند الطلب).
  static void reset() {
    _instance = null;
    _box = null;
  }

  @visibleForTesting
  static void resetForTesting() => reset();

  static String? _cleanNote(String? note) {
    final trimmed = note?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return String.fromCharCodes(trimmed.runes.take(ExpenseEntry.maxNoteLength));
  }

  static void _checkAmount(double amount) {
    if (!amount.isFinite || amount <= 0 || amount > ExpenseEntry.maxAmount) {
      throw ArgumentError.value(amount, 'amount', 'must be a positive amount within the limit');
    }
  }

  Future<ExpenseEntry> addExpense({
    required double amount,
    required ExpenseCategory category,
    String? note,
    DateTime? date,
  }) async {
    _checkAmount(amount);
    final data = {
      'amount': amount,
      'category': category.name,
      'note': _cleanNote(note),
      'date': date ?? DateTime.now(),
    };
    final key = await _box!.add(data);
    return ExpenseEntry.fromMap(key.toString(), data);
  }

  /// يعدّل مصروفًا محفوظًا (المبلغ والفئة والملاحظة والتاريخ). null إن لم يوجد.
  Future<ExpenseEntry?> updateExpense(
    String id, {
    required double amount,
    required ExpenseCategory category,
    String? note,
    required DateTime date,
  }) async {
    _checkAmount(amount);
    final key = int.tryParse(id);
    if (key == null || _box!.get(key) is! Map) return null;
    final data = {
      'amount': amount,
      'category': category.name,
      'note': _cleanNote(note),
      'date': date,
    };
    await _box!.put(key, data);
    return ExpenseEntry.fromMap(id, data);
  }

  /// يحذف مصروفًا ويرجّعه لاستعماله في "تراجع". null إن لم يوجد.
  Future<ExpenseEntry?> deleteExpense(String id) async {
    final key = int.tryParse(id);
    final current = key == null ? null : _box!.get(key);
    if (key == null || current is! Map) return null;
    final removed = ExpenseEntry.fromMap(id, current);
    await _box!.delete(key);
    return removed;
  }

  /// يعيد مصروفًا محذوفًا بمعرّفه نفسه.
  Future<void> restoreExpense(ExpenseEntry entry) async {
    final key = int.tryParse(entry.id);
    if (key != null) await _box!.put(key, entry.toMap());
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
