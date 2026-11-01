import 'package:eman_life_app/features/budget/budget_service.dart';
import 'package:eman_life_app/features/budget/budget_summary_screen.dart';
import 'package:eman_life_app/features/budget/models/expense_entry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/test_storage.dart';
import 'helpers/widget_helpers.dart';

void main() {
  late TestStorage storage;

  setUp(() async {
    storage = await TestStorage.inMemory();
  });
  tearDown(() => storage.dispose());

  Future<BudgetService> budget() => BudgetService.getInstance();

  group('BudgetService edit and delete', () {
    test('an expense can be corrected: amount, category, note and date', () async {
      final b = await budget();
      final saved = await b.addExpense(amount: 25, category: ExpenseCategory.food, note: 'غداء', date: DateTime(2026, 10, 15, 9));
      await b.addExpense(amount: 10, category: ExpenseCategory.transport, date: DateTime(2026, 10, 16));

      final updated = await b.updateExpense(
        saved.id,
        amount: 40.5,
        category: ExpenseCategory.shopping,
        note: '  سوق  ',
        date: DateTime(2026, 10, 14, 9),
      );

      expect(updated!.id, saved.id);
      final entries = b.getExpensesForMonth(DateTime(2026, 10));
      final back = entries.firstWhere((e) => e.id == saved.id);
      expect(back.amount, 40.5);
      expect(back.category, ExpenseCategory.shopping);
      expect(back.note, 'سوق');
      expect(back.date, DateTime(2026, 10, 14, 9));
      expect(entries, hasLength(2), reason: 'edited, not duplicated');
      expect(b.getTotalForMonth(DateTime(2026, 10)), 50.5);
    });

    test('moving the date to another month moves it out of the old month', () async {
      final b = await budget();
      final saved = await b.addExpense(amount: 5, category: ExpenseCategory.food, date: DateTime(2026, 10, 3));

      await b.updateExpense(saved.id, amount: 5, category: ExpenseCategory.food, date: DateTime(2026, 9, 28));

      expect(b.getTotalForMonth(DateTime(2026, 10)), 0);
      expect(b.getTotalForMonth(DateTime(2026, 9)), 5);
    });

    test('editing something that does not exist changes nothing', () async {
      final b = await budget();
      await b.addExpense(amount: 5, category: ExpenseCategory.food);

      expect(await b.updateExpense('999', amount: 1, category: ExpenseCategory.food, date: DateTime.now()), isNull);
      expect(await b.updateExpense('abc', amount: 1, category: ExpenseCategory.food, date: DateTime.now()), isNull);
      expect(b.getTotalForMonth(DateTime.now()), 5);
    });

    test('delete returns the expense and restore brings it back with the same id', () async {
      final b = await budget();
      final a = await b.addExpense(amount: 25, category: ExpenseCategory.food, note: 'غداء', date: DateTime(2026, 10, 15));
      await b.addExpense(amount: 10, category: ExpenseCategory.bills, date: DateTime(2026, 10, 16));

      final removed = await b.deleteExpense(a.id);
      expect(removed!.amount, 25);
      expect(b.getTotalForMonth(DateTime(2026, 10)), 10);
      expect(await b.deleteExpense(a.id), isNull, reason: 'already gone');

      await b.restoreExpense(removed);
      final back = b.getExpensesSince(DateTime(2026)).firstWhere((e) => e.id == a.id);
      expect(back.note, 'غداء');
      expect(back.date, DateTime(2026, 10, 15));
      expect(b.getTotalForMonth(DateTime(2026, 10)), 35);
    });

    test('amounts outside the allowed range are refused everywhere', () async {
      final b = await budget();
      final saved = await b.addExpense(amount: 5, category: ExpenseCategory.food);

      for (final bad in [0.0, -1.0, double.nan, double.infinity, ExpenseEntry.maxAmount + 1]) {
        expect(() => b.addExpense(amount: bad, category: ExpenseCategory.food), throwsArgumentError, reason: '$bad');
        expect(
          () => b.updateExpense(saved.id, amount: bad, category: ExpenseCategory.food, date: DateTime.now()),
          throwsArgumentError,
          reason: '$bad',
        );
      }
      expect(b.getTotalForMonth(DateTime.now()), 5);
      expect(parseAmount('1000000001'), isNull);
      expect(parseAmount('1000000000'), 1000000000);
    });

    test('a long note is cut and a blank note becomes none', () async {
      final b = await budget();

      final long = await b.addExpense(amount: 1, category: ExpenseCategory.food, note: 'ن' * 500);
      final blank = await b.addExpense(amount: 1, category: ExpenseCategory.food, note: '   ');

      expect(long.note!.runes.length, ExpenseEntry.maxNoteLength);
      expect(blank.note, isNull);
    });
  });

  group('monthly screen', () {
    Future<void> openSummary(WidgetTester tester) async {
      tester.view.physicalSize = const Size(900, 3000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await pumpScreen(tester, const BudgetSummaryScreen());
    }

    Future<void> addThroughForm(WidgetTester tester, String amount, String category, {String note = ''}) async {
      await tester.tap(find.text('سجّل مصروف'));
      await tester.pumpAndSettle();
      await tester.enterText(find.widgetWithText(TextField, 'المبلغ'), amount);
      await tester.tap(find.text(category));
      await tester.pump();
      if (note.isNotEmpty) await tester.enterText(find.widgetWithText(TextField, 'ملاحظة (اختياري)'), note);
      await tester.tap(find.text('حفظ'));
      await tester.pumpAndSettle();
    }

    testWidgets('a new expense shows up at once as its own line, with the total', (tester) async {
      await openSummary(tester);
      expect(find.text('لا توجد مصاريف مسجلة في هذا الشهر'), findsOneWidget);

      await addThroughForm(tester, '25.5', 'طعام', note: 'غداء مع الأسرة');

      expect(find.text('مصروفات الشهر'), findsOneWidget);
      expect(find.text('غداء مع الأسرة'), findsOneWidget);
      expect(find.text('25.5 ر.س'), findsWidgets);
      expect((await budget()).getExpensesSince(DateTime(2000)).single.amount, 25.5);
    });

    testWidgets('tapping an expense opens it filled in, and saving updates the line and the total', (tester) async {
      final b = await budget();
      await b.addExpense(amount: 25, category: ExpenseCategory.food, note: 'غداء');
      await openSummary(tester);

      await tester.tap(find.text('غداء'));
      await tester.pumpAndSettle();
      expect(find.text('تعديل مصروف'), findsOneWidget);
      expect(tester.widget<TextField>(find.widgetWithText(TextField, 'المبلغ')).controller!.text, '25');

      await tester.enterText(find.widgetWithText(TextField, 'المبلغ'), '40');
      await tester.enterText(find.widgetWithText(TextField, 'ملاحظة (اختياري)'), 'عشاء');
      await tester.tap(find.text('حفظ'));
      await tester.pumpAndSettle();

      expect(find.text('عشاء'), findsOneWidget);
      expect(find.text('غداء'), findsNothing);
      expect(find.text('40 ر.س'), findsWidgets);
      final entries = b.getExpensesSince(DateTime(2000));
      expect(entries, hasLength(1));
      expect(entries.single.amount, 40);
    });

    testWidgets('deleting removes the line and the total, and "تراجع" brings it back', (tester) async {
      final b = await budget();
      await b.addExpense(amount: 25, category: ExpenseCategory.food, note: 'غداء');
      await openSummary(tester);

      await tester.tap(find.byTooltip('حذف المصروف'));
      await tester.pumpAndSettle();
      expect(find.text('غداء'), findsNothing);
      expect(find.text('لا توجد مصاريف مسجلة في هذا الشهر'), findsOneWidget);
      expect(b.getExpensesSince(DateTime(2000)), isEmpty);

      await tester.tap(find.text('تراجع'));
      await tester.pumpAndSettle();
      expect(find.text('غداء'), findsOneWidget);
      expect(b.getExpensesSince(DateTime(2000)).single.note, 'غداء');
    });

    testWidgets('the date can be changed from the form (the picker opens and keeps a valid date)', (tester) async {
      await openSummary(tester);
      await tester.tap(find.text('سجّل مصروف'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('تغيير التاريخ'));
      await tester.pumpAndSettle();
      expect(find.byType(DatePickerDialog), findsOneWidget);
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(find.textContaining('التاريخ:'), findsOneWidget);
    });

    testWidgets('an amount over the limit keeps the save button disabled', (tester) async {
      await openSummary(tester);
      await tester.tap(find.text('سجّل مصروف'));
      await tester.pumpAndSettle();

      await tester.enterText(find.widgetWithText(TextField, 'المبلغ'), '99999999999');
      await tester.tap(find.text('طعام'));
      await tester.pump();

      final button = tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'حفظ'));
      expect(button.onPressed, isNull);
    });
  });
}
