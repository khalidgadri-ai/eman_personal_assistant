import 'dart:convert';
import 'dart:io';

import 'package:eman_life_app/core/services/encrypted_boxes.dart';
import 'package:eman_life_app/features/budget/budget_plan_service.dart';
import 'package:eman_life_app/features/budget/models/budget_plan.dart';
import 'package:eman_life_app/features/budget/models/expense_entry.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'helpers/test_storage.dart';

const BudgetPlan _plan = BudgetPlan(
  income: 9000.5,
  payday: 27,
  currencyCode: 'AED',
  fixed: [
    FixedExpense(id: 'a', name: 'إيجار الشقة', amount: 2500, dueDay: 1),
    FixedExpense(id: 'b', name: 'قسط السيارة', amount: 800.75, dueDay: 5, paidCycle: '2026-09-27'),
  ],
  savings: SavingsGoal(mode: SavingsMode.percent, value: 10),
  limits: {ExpenseCategory.food: 1500, ExpenseCategory.transport: 400},
);

void main() {
  late TestStorage storage;

  setUp(() => storage = TestStorage.create());
  tearDown(() => storage.dispose());

  /// يُغلق كل الصناديق ويفتحها من القرص من جديد بالمفتاح نفسه في التخزين الآمن، كما عند إغلاق
  /// التطبيق وفتحه.
  Future<BudgetPlanService> closeAndReopen() async {
    await Hive.close();
    BudgetPlanService.resetForTesting();
    EncryptedBoxes.resetForTesting();
    Hive.init(storage.directory!.path);
    return BudgetPlanService.getInstance();
  }

  test('a fresh install has no plan: nothing is invented', () async {
    final service = await BudgetPlanService.getInstance();

    expect(service.plan.isConfigured, isFalse);
    expect(service.plan.fixed, isEmpty);
    expect(service.plan.limits, isEmpty);
    expect(service.plan.currency.code, 'SAR', reason: 'Saudi riyal by default');
    expect(service.plan.payday, 1);
  });

  test('the plan survives closing the box and opening it again from disk', () async {
    final service = await BudgetPlanService.getInstance();
    await service.save(_plan);

    final reopened = await closeAndReopen();

    expect(reopened.plan.toMap(), _plan.toMap());
    expect(reopened.plan.income, 9000.5);
    expect(reopened.plan.payday, 27);
    expect(reopened.plan.fixed.map((f) => f.name), ['إيجار الشقة', 'قسط السيارة']);
    expect(reopened.plan.fixed.last.paidCycle, '2026-09-27');
    expect(reopened.plan.savings.mode, SavingsMode.percent);
    expect(reopened.plan.limits[ExpenseCategory.transport], 400);
  });

  test('the file on disk is encrypted: no plan text is readable in it', () async {
    final service = await BudgetPlanService.getInstance();
    await service.save(_plan);
    await Hive.close();

    final file = File('${storage.directory!.path}/budget_plan_enc.hive');
    expect(file.existsSync(), isTrue, reason: 'the encrypted box file is budget_plan_enc.hive');
    final bytes = file.readAsBytesSync();
    expect(bytes, isNotEmpty);
    for (final secret in ['إيجار الشقة', 'قسط السيارة', 'income', 'payday', 'AED']) {
      expect(_contains(bytes, utf8.encode(secret)), isFalse, reason: secret);
    }
    expect(File('${storage.directory!.path}/budget_plan.hive').existsSync(), isFalse, reason: 'no plain copy');
  });

  test('saving again replaces the plan; it does not pile up records', () async {
    final service = await BudgetPlanService.getInstance();
    await service.save(_plan);
    await service.save(_plan.copyWith(income: 12000));

    expect(service.plan.income, 12000);
    expect(Hive.box('budget_plan_enc').length, 1);
  });

  test('values outside the limits are refused and the saved plan stays intact', () async {
    final service = await BudgetPlanService.getInstance();
    await service.save(_plan);

    for (final bad in [
      _plan.copyWith(income: -1),
      _plan.copyWith(income: double.nan),
      _plan.copyWith(income: double.infinity),
      _plan.copyWith(income: ExpenseEntry.maxAmount + 1),
      _plan.copyWith(payday: 0),
      _plan.copyWith(payday: 32),
      _plan.copyWith(currencyCode: 'ZZZ'),
      _plan.copyWith(savings: const SavingsGoal(mode: SavingsMode.percent, value: 150)),
      _plan.copyWith(limits: {ExpenseCategory.food: -5}),
      _plan.copyWith(fixed: [const FixedExpense(id: 'x', name: 'x', amount: 0, dueDay: 1)]),
    ]) {
      await expectLater(service.save(bad), throwsArgumentError);
    }

    expect(service.plan.toMap(), _plan.toMap());
  });

  test('"paid this cycle" is set and cleared on one fixed expense only', () async {
    final service = await BudgetPlanService.getInstance();
    await service.save(_plan);

    final paid = await service.setPaid('a', true, cycleKey: '2026-10-27');
    expect(paid!.fixed.first.isPaidIn('2026-10-27'), isTrue);
    expect(paid.fixed.last.paidCycle, '2026-09-27', reason: 'the other one is untouched');

    final cleared = await service.setPaid('a', false, cycleKey: '2026-10-27');
    expect(cleared!.fixed.first.paidCycle, isNull);

    expect(await service.setPaid('nope', true, cycleKey: '2026-10-27'), isNull);
  });

  test('a paid tick survives a restart, and is gone in the next cycle', () async {
    var service = await BudgetPlanService.getInstance();
    await service.save(_plan);
    await service.setPaid('a', true, cycleKey: '2026-10-27');

    service = await closeAndReopen();

    expect(service.plan.fixed.first.isPaidIn('2026-10-27'), isTrue);
    expect(service.plan.fixed.first.isPaidIn('2026-11-27'), isFalse);
    expect(service.plan.fixed.length, 2, reason: 'the plan itself stays');
  });

  test('saving suggested limits keeps everything else in the plan', () async {
    final service = await BudgetPlanService.getInstance();
    await service.save(_plan);

    await service.saveLimits({ExpenseCategory.shopping: 300, ExpenseCategory.food: 2000});

    expect(service.plan.limits, {ExpenseCategory.shopping: 300, ExpenseCategory.food: 2000});
    expect(service.plan.income, _plan.income);
    expect(service.plan.fixed.length, 2);
    expect(service.plan.currencyCode, 'AED');
  });

  test('a damaged record reads as a safe empty plan instead of crashing the screen', () async {
    final service = await BudgetPlanService.getInstance();
    final box = Hive.box('budget_plan_enc');

    await box.put('plan', 'not a map');
    expect(service.plan.isConfigured, isFalse);

    await box.put('plan', {'income': 'lots', 'payday': 'x', 'fixed': 5, 'limits': 'no'});
    expect(service.plan.isConfigured, isFalse);
    expect(service.plan.payday, 1);
  });
}

bool _contains(List<int> haystack, List<int> needle) {
  for (var i = 0; i + needle.length <= haystack.length; i++) {
    var matched = true;
    for (var j = 0; j < needle.length; j++) {
      if (haystack[i + j] != needle[j]) {
        matched = false;
        break;
      }
    }
    if (matched) return true;
  }
  return false;
}
