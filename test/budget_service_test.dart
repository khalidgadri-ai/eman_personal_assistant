import 'dart:io';

import 'package:eman_life_app/core/services/encrypted_boxes.dart';
import 'package:eman_life_app/features/budget/budget_service.dart';
import 'package:eman_life_app/features/budget/models/expense_entry.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  late Directory hiveDir;
  late BudgetService budget;
  final october = DateTime(2026, 10);

  setUp(() async {
    hiveDir = Directory.systemTemp.createTempSync('budget_hive_test');
    Hive.init(hiveDir.path);
    FlutterSecureStorage.setMockInitialValues({});
    EncryptedBoxes.resetForTesting();
    BudgetService.resetForTesting();
    budget = await BudgetService.getInstance();
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    BudgetService.resetForTesting();
    hiveDir.deleteSync(recursive: true);
  });

  Future<void> seedOctoberWithNeighbours() async {
    await budget.addExpense(amount: 45.5, category: ExpenseCategory.food, date: DateTime(2026, 10, 1, 8));
    await budget.addExpense(amount: 120, category: ExpenseCategory.food, date: DateTime(2026, 10, 15));
    await budget.addExpense(amount: 60, category: ExpenseCategory.transport, date: DateTime(2026, 10, 20));
    await budget.addExpense(amount: 300, category: ExpenseCategory.bills, date: DateTime(2026, 10, 31, 23, 59));
    // خارج أكتوبر 2026: آخر لحظة في سبتمبر، أول يوم في نوفمبر، ونفس الشهر في سنة أخرى.
    await budget.addExpense(amount: 999, category: ExpenseCategory.food, date: DateTime(2026, 9, 30, 23, 59));
    await budget.addExpense(amount: 888, category: ExpenseCategory.bills, date: DateTime(2026, 11, 1));
    await budget.addExpense(amount: 777, category: ExpenseCategory.shopping, date: DateTime(2025, 10, 10));
  }

  group('monthly total', () {
    test('sums only that month, including its first and last day', () async {
      await seedOctoberWithNeighbours();

      expect(budget.getTotalForMonth(october), 525.5);
    });

    test('is zero for a month with no expenses', () async {
      await seedOctoberWithNeighbours();

      expect(budget.getTotalForMonth(DateTime(2026, 8)), 0);
      expect(budget.getTotalByCategory(DateTime(2026, 8)), isEmpty);
    });
  });

  group('totals by category', () {
    test('groups the month entries and omits categories with no spend', () async {
      await seedOctoberWithNeighbours();

      expect(budget.getTotalByCategory(october), {
        ExpenseCategory.food: 165.5,
        ExpenseCategory.transport: 60.0,
        ExpenseCategory.bills: 300.0,
      });
    });

    test('add up to the monthly total', () async {
      await seedOctoberWithNeighbours();

      final sumOfCategories = budget.getTotalByCategory(october).values.fold(0.0, (a, b) => a + b);
      expect(sumOfCategories, budget.getTotalForMonth(october));
    });
  });

  group('addExpense and getExpensesForMonth', () {
    test('lists the month newest first', () async {
      await seedOctoberWithNeighbours();

      final amounts = budget.getExpensesForMonth(october).map((e) => e.amount).toList();
      expect(amounts, [300.0, 60.0, 120.0, 45.5]);
    });

    test('stores a blank note as no note and keeps a real one trimmed', () async {
      final blank = await budget.addExpense(amount: 10, category: ExpenseCategory.other, note: '   ');
      final noted = await budget.addExpense(amount: 20, category: ExpenseCategory.other, note: ' قهوة ');

      expect(blank.note, isNull);
      expect(noted.note, 'قهوة');
      expect(blank.id, isNot(noted.id));
    });
  });

  group('parseAmount', () {
    test('accepts Western and Arabic-Indic digits and both decimal separators', () {
      expect(parseAmount('45.5'), 45.5);
      expect(parseAmount('١٢٫٥'), 12.5);
      expect(parseAmount(' 1,250 '), 1250);
      expect(parseAmount('٢٬٥٠٠'), 2500);
    });

    test('rejects empty, zero, negative and non-numeric input', () {
      for (final input in ['', '0', '-5', 'abc', 'Infinity']) {
        expect(parseAmount(input), isNull, reason: input);
      }
    });
  });
}
