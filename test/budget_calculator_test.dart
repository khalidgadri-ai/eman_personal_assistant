import 'package:eman_life_app/features/budget/budget_calculator.dart';
import 'package:eman_life_app/features/budget/models/budget_plan.dart';
import 'package:eman_life_app/features/budget/models/budget_suggestion.dart';
import 'package:eman_life_app/features/budget/models/expense_entry.dart';
import 'package:flutter_test/flutter_test.dart';

ExpenseEntry _expense(double amount, DateTime date, {ExpenseCategory category = ExpenseCategory.food, String id = 'e'}) =>
    ExpenseEntry(id: id, amount: amount, category: category, date: date);

void main() {
  group('budget cycle (starts on payday)', () {
    test('before payday the cycle began last month; on payday a new one starts', () {
      final before = BudgetCycle.containing(DateTime(2026, 10, 18), 27);
      expect(before.start, DateTime(2026, 9, 27));
      expect(before.endExclusive, DateTime(2026, 10, 27));
      expect(before.key, '2026-09-27');
      expect(before.totalDays, 30);
      expect(before.daysLeft(DateTime(2026, 10, 18)), 9, reason: 'today counts: 18..26');
      expect(before.lastDay, DateTime(2026, 10, 26));

      final onPayday = BudgetCycle.containing(DateTime(2026, 10, 27), 27);
      expect(onPayday.start, DateTime(2026, 10, 27));
      expect(onPayday.endExclusive, DateTime(2026, 11, 27));
      expect(onPayday.key, '2026-10-27');
      expect(onPayday.totalDays, 31);
      expect(onPayday.daysLeft(DateTime(2026, 10, 27)), 31);
    });

    test('the last day of a cycle has exactly one day left, never zero', () {
      final cycle = BudgetCycle.containing(DateTime(2026, 10, 26, 23, 59), 27);
      expect(cycle.start, DateTime(2026, 9, 27));
      expect(cycle.daysLeft(DateTime(2026, 10, 26, 23, 59)), 1);
    });

    test('a cycle crosses the new year', () {
      final c = BudgetCycle.containing(DateTime(2026, 1, 5), 27);
      expect(c.start, DateTime(2025, 12, 27));
      expect(c.endExclusive, DateTime(2026, 1, 27));
      expect(BudgetCycle.containing(DateTime(2026, 12, 30), 27).endExclusive, DateTime(2027, 1, 27));
    });

    test('payday 31 falls on the last day of shorter months', () {
      expect(BudgetCycle.containing(DateTime(2026, 3, 1), 31).start, DateTime(2026, 2, 28));
      expect(BudgetCycle.containing(DateTime(2026, 2, 28), 31).endExclusive, DateTime(2026, 3, 31));
      expect(BudgetCycle.containing(DateTime(2026, 2, 27), 31).start, DateTime(2026, 1, 31));
      expect(BudgetCycle.containing(DateTime(2026, 2, 27), 31).endExclusive, DateTime(2026, 2, 28));
      expect(BudgetCycle.containing(DateTime(2026, 5, 15), 31).start, DateTime(2026, 4, 30));
    });

    test('a leap year February is respected', () {
      expect(BudgetCycle.containing(DateTime(2028, 3, 2), 30).start, DateTime(2028, 2, 29));
      expect(BudgetCycle.containing(DateTime(2026, 3, 2), 30).start, DateTime(2026, 2, 28));
    });

    test('payday 1 is the calendar month', () {
      final c = BudgetCycle.containing(DateTime(2026, 10, 18), 1);
      expect(c.start, DateTime(2026, 10, 1));
      expect(c.endExclusive, DateTime(2026, 11, 1));
    });

    test('contains: start is inside, the next payday is outside', () {
      final c = BudgetCycle.containing(DateTime(2026, 10, 18), 27);
      expect(c.contains(DateTime(2026, 9, 27)), isTrue);
      expect(c.contains(DateTime(2026, 9, 26, 23, 59)), isFalse);
      expect(c.contains(DateTime(2026, 10, 26, 23, 59)), isTrue);
      expect(c.contains(DateTime(2026, 10, 27)), isFalse);
    });
  });

  group('budget figures', () {
    const plan = BudgetPlan(
      income: 9000,
      payday: 27,
      fixed: [
        FixedExpense(id: 'a', name: 'إيجار', amount: 2500, dueDay: 1),
        FixedExpense(id: 'b', name: 'قسط', amount: 500, dueDay: 5),
      ],
      savings: SavingsGoal(value: 1000),
    );
    final today = DateTime(2026, 10, 18);

    test('available = income - fixed - savings', () {
      final s = BudgetCalculator.compute(plan, const [], today);
      expect(s.income, 9000);
      expect(s.fixedTotal, 3000);
      expect(s.savings, 1000);
      expect(s.available, 5000);
      expect(s.spent, 0);
      expect(s.remaining, 5000);
      expect(s.overcommitted, isFalse);
    });

    test('spent counts only the current cycle, remaining and daily follow', () {
      final s = BudgetCalculator.compute(
        plan,
        [
          _expense(1000, DateTime(2026, 9, 27), id: '1'),
          _expense(250, DateTime(2026, 10, 18, 14), category: ExpenseCategory.transport, id: '2'),
          _expense(500, DateTime(2026, 9, 26, 23, 59), id: '3'),
          _expense(700, DateTime(2026, 10, 27), id: '4'),
        ],
        today,
      );
      expect(s.spent, 1250, reason: 'the 26 Sep and the 27 Oct expenses belong to other cycles');
      expect(s.remaining, 3750);
      expect(s.daysLeft, 9);
      expect(s.dailyAvailable, closeTo(3750 / 9, 1e-9));
      expect(s.ratio, closeTo(0.25, 1e-9));
      expect(s.level, BudgetLevel.ok);
    });

    test('the bar goes green, then amber from 70%, then red at 100%', () {
      BudgetLevel levelFor(double spent) =>
          BudgetCalculator.compute(plan, [_expense(spent, DateTime(2026, 10, 1))], today).level;

      expect(levelFor(3499), BudgetLevel.ok);
      expect(levelFor(3500), BudgetLevel.near);
      expect(levelFor(4999), BudgetLevel.near);
      expect(levelFor(5000), BudgetLevel.over);
      expect(levelFor(6500), BudgetLevel.over);
    });

    test('overspending gives a negative remaining and no daily allowance', () {
      final s = BudgetCalculator.compute(plan, [_expense(6000, DateTime(2026, 10, 1))], today);
      expect(s.remaining, -1000);
      expect(s.dailyAvailable, 0);
      expect(s.level, BudgetLevel.over);
    });

    test('a percentage savings goal is taken from the income', () {
      const p = BudgetPlan(income: 10000, savings: SavingsGoal(mode: SavingsMode.percent, value: 15));
      expect(p.savingsAmount, 1500);
      expect(p.available, 8500);
    });

    test('fixed + savings above income is flagged and the plan is red', () {
      const p = BudgetPlan(
        income: 1000,
        fixed: [FixedExpense(id: 'a', name: 'إيجار', amount: 800, dueDay: 1)],
        savings: SavingsGoal(value: 300),
      );
      final s = BudgetCalculator.compute(p, const [], today);
      expect(p.overcommitted, isTrue);
      expect(s.overcommitted, isTrue);
      expect(s.available, -100);
      expect(s.level, BudgetLevel.over);
      expect(s.dailyAvailable, 0);
    });

    test('exactly zero available with no spending is not an alarm', () {
      const p = BudgetPlan(income: 1000, savings: SavingsGoal(value: 1000));
      final s = BudgetCalculator.compute(p, const [], today);
      expect(s.available, 0);
      expect(s.ratio, 0);
      expect(s.level, BudgetLevel.ok);
      expect(p.overcommitted, isFalse);
    });

    test('a category warns at 80% of its limit and is over after 100%', () {
      BudgetSnapshot afterFood(double foodSpent) => BudgetCalculator.compute(
            const BudgetPlan(income: 9000, limits: {ExpenseCategory.food: 1000}),
            [_expense(foodSpent, DateTime(2026, 10, 18))],
            today,
          );

      expect(afterFood(790).categories.single.level, BudgetLevel.ok);
      expect(afterFood(800).categories.single.level, BudgetLevel.near);
      expect(afterFood(1000).categories.single.level, BudgetLevel.near);
      expect(afterFood(1001).categories.single.level, BudgetLevel.over);
      expect(afterFood(1250).categories.single.overBy, 250);
      expect(afterFood(790).alerts, isEmpty);
      expect(afterFood(1250).alerts.single.category, ExpenseCategory.food);
    });

    test('categories list those with a limit or with spending, biggest first', () {
      final s = BudgetCalculator.compute(
        const BudgetPlan(income: 9000, limits: {ExpenseCategory.shopping: 500}),
        [
          _expense(50, DateTime(2026, 10, 18), category: ExpenseCategory.transport, id: '1'),
          _expense(300, DateTime(2026, 10, 18), category: ExpenseCategory.food, id: '2'),
        ],
        today,
      );
      expect(s.categories.map((c) => c.category), [ExpenseCategory.food, ExpenseCategory.transport, ExpenseCategory.shopping]);
      expect(s.categories.last.limit, 500);
      expect(s.categories.last.spent, 0);
      expect(s.categories.first.limit, isNull);
    });

    test('"paid this cycle" resets itself when a new cycle starts', () {
      const item = FixedExpense(id: 'a', name: 'إيجار', amount: 1, dueDay: 1, paidCycle: '2026-09-27');
      final thisCycle = BudgetCycle.containing(DateTime(2026, 10, 18), 27);
      final nextCycle = BudgetCycle.containing(DateTime(2026, 10, 27), 27);
      expect(item.isPaidIn(thisCycle.key), isTrue);
      expect(item.isPaidIn(nextCycle.key), isFalse, reason: 'the plan stays, the paid tick does not');
    });
  });

  group('local suggestion', () {
    test('splits the available amount over the six categories and adds up', () {
      final limits = BudgetCalculator.suggestLimits(5000);
      expect(limits.keys.toSet(), ExpenseCategory.values.toSet());
      expect(limits[ExpenseCategory.food], 1750);
      expect(limits.values.reduce((a, b) => a + b), closeTo(5000, 3));
    });

    test('nothing to suggest without a positive available amount', () {
      expect(BudgetCalculator.suggestLimits(0), isEmpty);
      expect(BudgetCalculator.suggestLimits(-50), isEmpty);
      expect(BudgetCalculator.suggestLimits(double.nan), isEmpty);
    });

    test('the rule can be changed with other weights', () {
      final limits = BudgetCalculator.suggestLimits(
        1000,
        weights: {ExpenseCategory.food: 3, ExpenseCategory.other: 1},
      );
      expect(limits, {ExpenseCategory.food: 750, ExpenseCategory.other: 250});
    });

    test('the default weights add up to one', () {
      expect(defaultLimitWeights.values.reduce((a, b) => a + b), closeTo(1, 1e-9));
    });
  });

  group('amounts typed by the user', () {
    test('Arabic-Indic digits and the Arabic decimal separator are accepted', () {
      expect(parseAmount('٩٠٠٠'), 9000);
      expect(parseAmount('١٢٣٫٥٠'), 123.5);
      expect(parseAmount('٠٫٥'), 0.5);
      expect(parseAmount('١٬٢٥٠'), 1250);
      expect(parseAmount('١،٢٥٠٫٧٥'), 1250.75);
      expect(parseAmount('1,250.5'), 1250.5);
      expect(parseAmount('  ٧٥  '), 75);
    });

    test('anything that is not a plain positive number is refused', () {
      for (final bad in ['', '   ', 'abc', '-5', '٠', '0', '1e5', '0x10', 'NaN', 'Infinity', '12٫٣٫٤', '١٠٠٠٠٠٠٠٠٠٠٠']) {
        expect(parseAmount(bad), isNull, reason: '"$bad"');
      }
    });

    test('zero is accepted only when asked for', () {
      expect(parseAmount('٠', allowZero: true), 0);
      expect(parseAmount('0', allowZero: true), 0);
      expect(parseAmount('-1', allowZero: true), isNull);
    });
  });

  group('the plan as stored', () {
    test('round-trips through its map', () {
      const plan = BudgetPlan(
        income: 9000.5,
        payday: 27,
        currencyCode: 'KWD',
        fixed: [FixedExpense(id: 'a', name: 'إيجار', amount: 2500, dueDay: 1, paidCycle: '2026-09-27')],
        savings: SavingsGoal(mode: SavingsMode.percent, value: 12.5),
        limits: {ExpenseCategory.food: 1500, ExpenseCategory.other: 200},
      );
      final back = BudgetPlan.fromMap(plan.toMap());
      expect(back.toMap(), plan.toMap());
      expect(back.currency.symbol, 'د.ك');
      expect(back.fixed.single.paidCycle, '2026-09-27');
    });

    test('garbage on disk becomes safe defaults instead of a crash', () {
      expect(BudgetPlan.fromMap(null).isConfigured, isFalse);
      expect(BudgetPlan.fromMap('text').isConfigured, isFalse);
      final back = BudgetPlan.fromMap({
        'income': -5,
        'payday': 99,
        'currency': 'XXX',
        'fixed': [
          {'id': 'a', 'name': 'ok', 'amount': 10, 'dueDay': 3},
          {'id': 'a', 'name': 'duplicate id', 'amount': 10, 'dueDay': 3},
          {'id': 'b', 'name': 'bad amount', 'amount': -1, 'dueDay': 3},
          {'id': 'c', 'name': 'bad day', 'amount': 1, 'dueDay': 40},
          'not a map',
        ],
        'savingsMode': 'percent',
        'savingsValue': 500,
        'limits': {'food': -3, 'other': 'x', 'bills': 40},
      });
      expect(back.income, 0);
      expect(back.payday, 1);
      expect(back.currencyCode, 'SAR');
      expect(back.fixed.map((f) => f.id), ['a']);
      expect(back.savings.value, 0, reason: 'a percentage above 100 is dropped');
      expect(back.limits, {ExpenseCategory.bills: 40});
    });

    test('validate refuses values outside the limits', () {
      expect(() => const BudgetPlan(income: -1).validate(), throwsArgumentError);
      expect(() => const BudgetPlan(income: double.nan).validate(), throwsArgumentError);
      expect(() => BudgetPlan(income: ExpenseEntry.maxAmount + 1).validate(), throwsArgumentError);
      expect(() => const BudgetPlan(payday: 0).validate(), throwsArgumentError);
      expect(() => const BudgetPlan(payday: 32).validate(), throwsArgumentError);
      expect(() => const BudgetPlan(currencyCode: 'XXX').validate(), throwsArgumentError);
      expect(() => const BudgetPlan(savings: SavingsGoal(mode: SavingsMode.percent, value: 101)).validate(), throwsArgumentError);
      expect(() => const BudgetPlan(savings: SavingsGoal(value: -1)).validate(), throwsArgumentError);
      expect(() => const BudgetPlan(limits: {ExpenseCategory.food: 0}).validate(), throwsArgumentError);
      expect(
        () => const BudgetPlan(fixed: [FixedExpense(id: 'a', name: '  ', amount: 1, dueDay: 1)]).validate(),
        throwsArgumentError,
      );
      expect(
        () => const BudgetPlan(fixed: [FixedExpense(id: 'a', name: 'x', amount: 1, dueDay: 32)]).validate(),
        throwsArgumentError,
      );
      expect(
        () => const BudgetPlan(fixed: [
          FixedExpense(id: 'a', name: 'x', amount: 1, dueDay: 1),
          FixedExpense(id: 'a', name: 'y', amount: 1, dueDay: 1),
        ]).validate(),
        throwsArgumentError,
      );
      expect(const BudgetPlan(income: 100, payday: 31).validate, returnsNormally);
    });
  });

  group('AI reply is untrusted data', () {
    test('plain JSON, fenced JSON and JSON inside prose all parse', () {
      const json = '{"limits": {"food": 1500, "transport": 600.5}, "note": "توزيع متوازن"}';
      for (final raw in [json, '```json\n$json\n```', 'تفضل الاقتراح:\n$json\nأتمنى أن يفيدك']) {
        final s = BudgetSuggestion.tryParse(raw)!;
        expect(s.limits, {ExpenseCategory.food: 1500, ExpenseCategory.transport: 600.5});
        expect(s.note, 'توزيع متوازن');
        expect(s.total, 2100.5);
      }
    });

    test('unknown categories, negative, zero, huge and non-numeric values are dropped', () {
      final s = BudgetSuggestion.tryParse(
        '{"limits": {"food": "٩٠٠", "transport": -5, "bills": 0, "shopping": 1e12, "travel": 400, "other": "abc", "entertainment": 120}}',
      )!;
      expect(s.limits, {ExpenseCategory.food: 900, ExpenseCategory.entertainment: 120});
    });

    test('nothing usable gives null, never a half-filled suggestion', () {
      for (final raw in [
        '',
        'لا أستطيع المساعدة',
        '{"limits": {}}',
        '{"limits": {"travel": 5}}',
        '{"limits": [1, 2]}',
        '{"limits"',
        '[1, 2, 3]',
        '{"note": "x"}',
      ]) {
        expect(BudgetSuggestion.tryParse(raw), isNull, reason: raw);
      }
    });

    test('the note loses control characters and is cut to the limit', () {
      final s = BudgetSuggestion.tryParse('{"limits": {"food": 10}, "note": "a\\u0000b ${'ن' * 500}"}')!;
      expect(s.note.contains('\u0000'), isFalse);
      expect(s.note.runes.length, BudgetSuggestion.maxNoteLength);
    });
  });
}
