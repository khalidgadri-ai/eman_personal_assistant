import 'dart:async';

import 'package:eman_life_app/core/ai/ai_models.dart';
import 'package:eman_life_app/core/ai/ai_provider.dart';
import 'package:eman_life_app/core/ai/ai_service.dart';
import 'package:eman_life_app/features/budget/budget_plan_service.dart';
import 'package:eman_life_app/features/budget/budget_service.dart';
import 'package:eman_life_app/features/budget/budget_summary_screen.dart';
import 'package:eman_life_app/features/budget/budget_suggestion_screen.dart';
import 'package:eman_life_app/features/budget/models/budget_plan.dart';
import 'package:eman_life_app/features/budget/models/expense_entry.dart';
import 'package:eman_life_app/features/financial/financial_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/test_storage.dart';
import 'helpers/widget_helpers.dart';

/// مزوّد وهمي: يسجّل كل ما يُرسَل إليه ويردّ بما يحدده الاختبار.
class _FakeProvider extends AiProvider {
  _FakeProvider(this.handler)
      : super(
          const AiProviderConfig(
            id: 'fake',
            kind: AiProviderKind.openAiCompatible,
            baseUrl: 'https://fake.example.com',
            model: 'm',
          ),
          'key',
        );

  final FutureOr<AiReply> Function(AiRequest request) handler;
  final List<AiRequest> sent = [];

  @override
  Future<AiReply> send(AiRequest request) async {
    sent.add(request);
    return handler(request);
  }

  @override
  Future<List<AiModelInfo>> listModels() async => const [];
}

const BudgetPlan _base = BudgetPlan(
  income: 9000,
  payday: 27,
  fixed: [FixedExpense(id: 'f1', name: 'إيجار', amount: 3000, dueDay: 1)],
  savings: SavingsGoal(value: 1000),
);

// 18 أكتوبر 2026: الدورة من 27 سبتمبر إلى 26 أكتوبر، وباقي 9 أيام بما فيها اليوم.
final DateTime _today = DateTime(2026, 10, 18, 10);

void main() {
  late TestStorage storage;

  setUp(() async {
    storage = await TestStorage.inMemory();
  });
  tearDown(() => storage.dispose());

  Future<void> bigScreen(WidgetTester tester) async {
    tester.view.physicalSize = const Size(900, 3200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  Future<void> openFinancial(WidgetTester tester, {DateTime? now, AiResolver? ai}) async {
    await bigScreen(tester);
    await pumpScreen(
      tester,
      FinancialScreen(now: () => now ?? _today, aiResolver: ai ?? ((_) async => null)),
    );
  }

  Future<void> savePlan(BudgetPlan plan) async => (await BudgetPlanService.getInstance()).save(plan);

  String valueOf(WidgetTester tester, String key) => tester.widget<Text>(find.byKey(Key(key))).data!;

  /// "إغلاق التطبيق وفتحه": تُهدم الشاشة وتُنسى الخدمات في الذاكرة، فلا يبقى إلا ما في الصناديق.
  Future<void> restartApp(WidgetTester tester, {DateTime? now, AiResolver? ai}) async {
    await tester.pumpWidget(const SizedBox());
    BudgetPlanService.resetForTesting();
    BudgetService.resetForTesting();
    await openFinancial(tester, now: now, ai: ai);
  }

  Future<void> pickPayday(WidgetTester tester, int day) async {
    await tester.tap(find.byType(DropdownButtonFormField<int>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('$day').last);
    await tester.pumpAndSettle();
  }

  Future<void> addFixed(WidgetTester tester, String name, String amount, String day) async {
    await tester.tap(find.text('إضافة مصروف ثابت'));
    await tester.pumpAndSettle();
    await fillDialog(
      tester,
      {'اسم المصروف': name, 'المبلغ': amount, 'يوم الاستحقاق (من 1 إلى 31)': day},
    );
  }

  Future<void> savePlanFromEditor(WidgetTester tester) async {
    await tester.tap(find.text('حفظ الخطة'));
    await tester.pumpAndSettle();
  }

  group('the reported defect: figures typed in the budget tab must be kept', () {
    testWidgets('income, fixed expenses and savings entered once are still there after restarting the app', (tester) async {
      await openFinancial(tester);
      expect(find.text('ابدأ بإعداد ميزانيتك'), findsOneWidget);

      await tester.tap(find.text('إعداد الميزانية'));
      await tester.pumpAndSettle();
      await tester.enterText(find.widgetWithText(TextField, 'الدخل الشهري'), '9000');
      await pickPayday(tester, 27);
      await addFixed(tester, 'إيجار', '3000', '1');
      await tester.enterText(find.widgetWithText(TextField, 'مبلغ الادخار'), '1000');
      await savePlanFromEditor(tester);

      expect(valueOf(tester, 'income_value'), '9,000 ر.س');
      expect(valueOf(tester, 'fixed_value'), '3,000 ر.س');
      expect(valueOf(tester, 'savings_value'), '1,000 ر.س');
      expect(valueOf(tester, 'available_value'), '5,000 ر.س');
      expect(valueOf(tester, 'spent_value'), '0 ر.س');
      expect(valueOf(tester, 'remaining_value'), '5,000 ر.س');
      expect(valueOf(tester, 'daily_value'), '555.56 ر.س', reason: '5000 ÷ 9 days left');
      expect(valueOf(tester, 'days_left'), 'باقي 9 يوم');

      // ما ظهر مكتوب فعلًا في الصندوق المشفّر، لا في ذاكرة الشاشة فقط.
      final stored = (await BudgetPlanService.getInstance()).plan;
      expect(stored.income, 9000);
      expect(stored.payday, 27);
      expect(stored.fixed.single.name, 'إيجار');
      expect(stored.savings.value, 1000);

      await restartApp(tester);

      expect(find.text('ابدأ بإعداد ميزانيتك'), findsNothing);
      expect(valueOf(tester, 'income_value'), '9,000 ر.س');
      expect(valueOf(tester, 'fixed_value'), '3,000 ر.س');
      expect(valueOf(tester, 'savings_value'), '1,000 ر.س');
      expect(valueOf(tester, 'available_value'), '5,000 ر.س');
      expect(find.text('إيجار'), findsOneWidget);
    });

    testWidgets('the plan is saved in the encrypted box and the open box still holds it after a reopen of the screen', (tester) async {
      await savePlan(_base);
      await openFinancial(tester);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getKeys(), isEmpty, reason: 'the plan never goes to the unencrypted preferences');
      expect(Hive.box('budget_plan_enc').isNotEmpty, isTrue);

      await restartApp(tester);
      expect(valueOf(tester, 'available_value'), '5,000 ر.س');
    });

    testWidgets('editing the plan again changes the saved plan, not a copy', (tester) async {
      await savePlan(_base);
      await openFinancial(tester);

      await tester.tap(find.text('تعديل الخطة'));
      await tester.pumpAndSettle();
      expect(tester.widget<TextField>(find.widgetWithText(TextField, 'الدخل الشهري')).controller!.text, '9000');
      await tester.enterText(find.widgetWithText(TextField, 'الدخل الشهري'), '10000');
      await savePlanFromEditor(tester);

      expect(valueOf(tester, 'income_value'), '10,000 ر.س');
      await restartApp(tester);
      expect(valueOf(tester, 'income_value'), '10,000 ر.س');
      expect((await BudgetPlanService.getInstance()).plan.fixed, hasLength(1), reason: 'the rest of the plan is kept');
    });
  });

  group('typing and validating amounts', () {
    testWidgets('Arabic-Indic digits and the Arabic decimal separator work in every amount field', (tester) async {
      await openFinancial(tester);
      await tester.tap(find.text('إعداد الميزانية'));
      await tester.pumpAndSettle();

      await tester.enterText(find.widgetWithText(TextField, 'الدخل الشهري'), '٩٠٠٠٫٥');
      await addFixed(tester, 'إنترنت', '١٢٣٫٥', '٢٨');
      await tester.enterText(find.widgetWithText(TextField, 'مبلغ الادخار'), '٥٠٠');
      await tester.enterText(find.widgetWithText(TextField, 'حد طعام'), '٢٠٠٠');
      await savePlanFromEditor(tester);

      final plan = (await BudgetPlanService.getInstance()).plan;
      expect(plan.income, 9000.5);
      expect(plan.fixed.single.amount, 123.5);
      expect(plan.fixed.single.dueDay, 28);
      expect(plan.savings.value, 500);
      expect(plan.limits[ExpenseCategory.food], 2000);
      expect(valueOf(tester, 'income_value'), '9,000.5 ر.س');
    });

    testWidgets('a missing or wrong income blocks the save and says why; nothing is written', (tester) async {
      await openFinancial(tester);
      await tester.tap(find.text('إعداد الميزانية'));
      await tester.pumpAndSettle();

      await savePlanFromEditor(tester);
      expect(find.text('أدخل مبلغًا صحيحًا أكبر من صفر'), findsOneWidget);
      expect(find.text('خطة الميزانية'), findsOneWidget, reason: 'still on the editor');

      for (final bad in ['abc', '-5', '0', '1e3', '99999999999']) {
        await tester.enterText(find.widgetWithText(TextField, 'الدخل الشهري'), bad);
        await savePlanFromEditor(tester);
        expect(find.text('خطة الميزانية'), findsOneWidget, reason: '"$bad" must not save');
      }
      expect((await BudgetPlanService.getInstance()).plan.isConfigured, isFalse);
    });

    testWidgets('savings percent above 100 and a bad category limit are refused', (tester) async {
      await openFinancial(tester);
      await tester.tap(find.text('إعداد الميزانية'));
      await tester.pumpAndSettle();
      await tester.enterText(find.widgetWithText(TextField, 'الدخل الشهري'), '5000');

      await tester.tap(find.text('نسبة من الدخل'));
      await tester.pumpAndSettle();
      await tester.enterText(find.widgetWithText(TextField, 'نسبة الادخار'), '150');
      await tester.enterText(find.widgetWithText(TextField, 'حد تسوق'), 'abc');
      await savePlanFromEditor(tester);

      expect(find.text('أدخل نسبة بين 0 و100'), findsOneWidget);
      expect(find.text('أدخل مبلغًا صحيحًا أكبر من صفر'), findsOneWidget, reason: 'the limit field');
      expect((await BudgetPlanService.getInstance()).plan.isConfigured, isFalse);

      await tester.enterText(find.widgetWithText(TextField, 'نسبة الادخار'), '10');
      await tester.enterText(find.widgetWithText(TextField, 'حد تسوق'), '');
      await savePlanFromEditor(tester);

      final plan = (await BudgetPlanService.getInstance()).plan;
      expect(plan.savings.mode, SavingsMode.percent);
      expect(plan.savingsAmount, 500);
      expect(plan.limits, isEmpty, reason: 'an empty limit means no limit');
    });

    testWidgets('the fixed expense dialog refuses a bad amount and a bad due day', (tester) async {
      await openFinancial(tester);
      await tester.tap(find.text('إعداد الميزانية'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('إضافة مصروف ثابت'));
      await tester.pumpAndSettle();
      await tester.enterText(find.widgetWithText(TextField, 'اسم المصروف'), 'قسط');
      await tester.enterText(find.widgetWithText(TextField, 'المبلغ'), '0');
      await tester.enterText(find.widgetWithText(TextField, 'يوم الاستحقاق (من 1 إلى 31)'), '40');
      await tester.tap(find.text('إضافة'));
      await tester.pumpAndSettle();

      expect(find.text('أدخل مبلغًا صحيحًا أكبر من صفر'), findsOneWidget);
      expect(find.text('أدخل يومًا من 1 إلى 31'), findsOneWidget);
      expect(find.text('مصروف ثابت جديد'), findsOneWidget, reason: 'the dialog stays open');
    });

    testWidgets('fixed + savings above income warns while editing and on the budget card', (tester) async {
      await openFinancial(tester);
      await tester.tap(find.text('إعداد الميزانية'));
      await tester.pumpAndSettle();
      await tester.enterText(find.widgetWithText(TextField, 'الدخل الشهري'), '1000');
      await addFixed(tester, 'إيجار', '800', '1');
      await tester.enterText(find.widgetWithText(TextField, 'مبلغ الادخار'), '300');
      await tester.pump();

      expect(find.textContaining('أكبر من الدخل'), findsOneWidget);

      await savePlanFromEditor(tester);
      expect(find.textContaining('أكبر من دخلك'), findsOneWidget);
      expect(valueOf(tester, 'available_value'), '-100 ر.س');
      expect(tester.widget<LinearProgressIndicator>(find.byKey(const Key('budget_progress'))).color, const Color(0xFFEF4444));
    });
  });

  group('leaving the editor', () {
    testWidgets('going back with unsaved changes asks first; discarding saves nothing', (tester) async {
      await openFinancial(tester);
      await tester.tap(find.text('إعداد الميزانية'));
      await tester.pumpAndSettle();
      await tester.enterText(find.widgetWithText(TextField, 'الدخل الشهري'), '7000');
      await tester.pump();

      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('تعديلات غير محفوظة'), findsOneWidget);

      await tester.tap(find.text('خروج بلا حفظ'));
      await tester.pumpAndSettle();

      expect(find.text('ابدأ بإعداد ميزانيتك'), findsOneWidget);
      expect((await BudgetPlanService.getInstance()).plan.isConfigured, isFalse);
    });

    testWidgets('going back with unsaved changes can save them instead', (tester) async {
      await openFinancial(tester);
      await tester.tap(find.text('إعداد الميزانية'));
      await tester.pumpAndSettle();
      await tester.enterText(find.widgetWithText(TextField, 'الدخل الشهري'), '7000');
      await tester.pump();

      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('تعديلات غير محفوظة'), findsOneWidget);
      await tester.tap(find.widgetWithText(ElevatedButton, 'حفظ الخطة').last);
      await tester.pumpAndSettle();

      expect(valueOf(tester, 'income_value'), '7,000 ر.س');
      expect((await BudgetPlanService.getInstance()).plan.income, 7000);
    });

    testWidgets('going back with nothing changed just leaves', (tester) async {
      await savePlan(_base);
      await openFinancial(tester);
      await tester.tap(find.text('تعديل الخطة'));
      await tester.pumpAndSettle();

      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(find.text('تعديلات غير محفوظة'), findsNothing);
      expect(find.text('ميزانية الدورة الحالية'), findsOneWidget);
    });
  });

  group('fixed expenses', () {
    testWidgets('add, edit and delete (with undo) in the editor, saved with the plan', (tester) async {
      await savePlan(_base);
      await openFinancial(tester);
      await tester.tap(find.text('تعديل الخطة'));
      await tester.pumpAndSettle();

      await addFixed(tester, 'اشتراك', '50', '15');
      expect(find.text('اشتراك'), findsOneWidget);
      expect(find.textContaining('المجموع: 3,050 ر.س'), findsOneWidget);

      await tester.tap(find.text('إيجار'));
      await tester.pumpAndSettle();
      await fillDialog(tester, {'اسم المصروف': 'إيجار الشقة', 'المبلغ': '3200'}, confirm: 'حفظ');
      expect(find.text('إيجار الشقة'), findsOneWidget);
      expect(find.text('إيجار'), findsNothing);

      await tester.tap(find.byTooltip('حذف اشتراك'));
      await tester.pumpAndSettle();
      expect(find.text('اشتراك'), findsNothing);
      await tester.tap(find.text('تراجع'));
      await tester.pumpAndSettle();
      expect(find.text('اشتراك'), findsOneWidget);
      await tester.tap(find.byTooltip('حذف اشتراك'));
      await tester.pumpAndSettle();

      await savePlanFromEditor(tester);

      final fixed = (await BudgetPlanService.getInstance()).plan.fixed;
      expect(fixed.single.name, 'إيجار الشقة');
      expect(fixed.single.amount, 3200);
      expect(fixed.single.id, 'f1', reason: 'editing keeps the same record');
      expect(valueOf(tester, 'fixed_value'), '3,200 ر.س');
    });

    testWidgets('ticking "paid" is saved at once and survives a restart', (tester) async {
      await savePlan(_base);
      await openFinancial(tester);
      expect(find.text('دُفع 0 من 1'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('paid_f1')));
      await settle(tester);
      expect(tester.widget<CheckboxListTile>(find.byKey(const ValueKey('paid_f1'))).value, isTrue);
      expect(find.text('دُفع 1 من 1'), findsOneWidget);

      await restartApp(tester);
      expect(tester.widget<CheckboxListTile>(find.byKey(const ValueKey('paid_f1'))).value, isTrue);

      await tester.tap(find.byKey(const ValueKey('paid_f1')));
      await settle(tester);
      expect(tester.widget<CheckboxListTile>(find.byKey(const ValueKey('paid_f1'))).value, isFalse);
      expect((await BudgetPlanService.getInstance()).plan.fixed.single.paidCycle, isNull);
    });

    testWidgets('when the next cycle starts the plan stays and "paid" is cleared', (tester) async {
      await savePlan(_base);
      await openFinancial(tester);
      await tester.tap(find.byKey(const ValueKey('paid_f1')));
      await settle(tester);
      expect(find.text('دُفع 1 من 1'), findsOneWidget);

      // يوم الراتب التالي: 27 أكتوبر.
      await restartApp(tester, now: DateTime(2026, 10, 27, 8));

      expect(find.text('دُفع 0 من 1'), findsOneWidget);
      expect(tester.widget<CheckboxListTile>(find.byKey(const ValueKey('paid_f1'))).value, isFalse);
      expect(valueOf(tester, 'income_value'), '9,000 ر.س', reason: 'the plan stays');
      expect(valueOf(tester, 'days_left'), 'باقي 31 يوم');
      expect(find.text('من 27 أكتوبر إلى 26 نوفمبر'), findsOneWidget);
    });
  });

  group('the budget card', () {
    testWidgets('shows spent, remaining and daily allowance for the current cycle only', (tester) async {
      await savePlan(_base);
      final b = await BudgetService.getInstance();
      await b.addExpense(amount: 1000, category: ExpenseCategory.food, date: DateTime(2026, 9, 27, 9));
      await b.addExpense(amount: 250, category: ExpenseCategory.transport, date: DateTime(2026, 10, 10, 9));
      await b.addExpense(amount: 400, category: ExpenseCategory.shopping, date: DateTime(2026, 9, 26, 9));
      await openFinancial(tester);

      expect(valueOf(tester, 'spent_value'), '1,250 ر.س', reason: 'the 26 Sep expense is last cycle');
      expect(valueOf(tester, 'remaining_value'), '3,750 ر.س');
      expect(valueOf(tester, 'daily_value'), '416.67 ر.س');
      expect(find.text('من 27 سبتمبر إلى 26 أكتوبر'), findsOneWidget);
      expect(find.text('صرفت 25٪ من المتاح'), findsOneWidget);
    });

    testWidgets('the bar is green, then amber from 70%, then red when the budget is spent', (tester) async {
      await savePlan(_base);
      final b = await BudgetService.getInstance();
      Color? barColor() => tester.widget<LinearProgressIndicator>(find.byKey(const Key('budget_progress'))).color;

      await openFinancial(tester);
      expect(barColor(), const Color(0xFF22C55E));

      await b.addExpense(amount: 3600, category: ExpenseCategory.food, date: DateTime(2026, 10, 10));
      await restartApp(tester);
      expect(barColor(), const Color(0xFFF59E0B));
      expect(find.textContaining('اقتربت من نهاية المتاح'), findsOneWidget);

      await b.addExpense(amount: 1500, category: ExpenseCategory.food, date: DateTime(2026, 10, 11));
      await restartApp(tester);
      expect(barColor(), const Color(0xFFEF4444));
      expect(valueOf(tester, 'remaining_value'), '-100 ر.س');
      expect(valueOf(tester, 'daily_value'), '0 ر.س');
      expect(find.textContaining('تجاوزت المتاح'), findsOneWidget);
    });

    testWidgets('a new expense from the card lowers the remaining amount at once', (tester) async {
      await savePlan(_base);
      await openFinancial(tester);

      await tester.tap(find.text('سجّل مصروف'));
      await tester.pumpAndSettle();
      await tester.enterText(find.widgetWithText(TextField, 'المبلغ'), '٢٥٠٫٥');
      await tester.tap(find.text('طعام'));
      await tester.pump();
      await tester.tap(find.text('حفظ'));
      await tester.pumpAndSettle();

      expect(valueOf(tester, 'spent_value'), '250.5 ر.س');
      expect(valueOf(tester, 'remaining_value'), '4,749.5 ر.س');
      expect(find.byKey(const ValueKey('category_food')), findsOneWidget);
    });

    testWidgets('the last expenses are listed with a link to all of them', (tester) async {
      await savePlan(_base);
      final b = await BudgetService.getInstance();
      await b.addExpense(amount: 40, category: ExpenseCategory.food, note: 'غداء', date: DateTime(2026, 10, 12));
      await b.addExpense(amount: 15, category: ExpenseCategory.transport, date: DateTime(2026, 10, 14));
      await openFinancial(tester);

      expect(find.text('آخر المصاريف'), findsOneWidget);
      expect(find.text('غداء'), findsOneWidget);
      expect(find.descendant(of: find.byType(ListTile), matching: find.text('40 ر.س')), findsOneWidget);
      expect(find.descendant(of: find.byType(ListTile), matching: find.text('15 ر.س')), findsOneWidget);
      expect(find.text('كل المصاريف'), findsOneWidget);
    });
  });

  group('category limits', () {
    testWidgets('a category warns near its limit and again once it is exceeded', (tester) async {
      await savePlan(_base.copyWith(limits: {ExpenseCategory.food: 1000}));
      final b = await BudgetService.getInstance();
      await openFinancial(tester);
      expect(find.textContaining('اقتربت من حد'), findsNothing);

      await b.addExpense(amount: 850, category: ExpenseCategory.food, date: DateTime(2026, 10, 10));
      await restartApp(tester);
      expect(find.text('اقتربت من حد «طعام»: صرفت 85٪ منه.'), findsOneWidget);
      expect(find.text('850 / 1,000 ر.س'), findsOneWidget);

      await b.addExpense(amount: 400, category: ExpenseCategory.food, date: DateTime(2026, 10, 11));
      await restartApp(tester);
      expect(find.text('تجاوزت حد «طعام» بمقدار 250 ر.س.'), findsOneWidget);
      expect(find.text('1,250 / 1,000 ر.س'), findsOneWidget);
    });

    testWidgets('a category with spending but no limit is listed without a warning', (tester) async {
      await savePlan(_base);
      final b = await BudgetService.getInstance();
      await b.addExpense(amount: 99, category: ExpenseCategory.entertainment, date: DateTime(2026, 10, 10));
      await openFinancial(tester);

      expect(find.byKey(const ValueKey('category_entertainment')), findsOneWidget);
      expect(find.textContaining('اقتربت من حد'), findsNothing);
      expect(find.textContaining('تجاوزت حد'), findsNothing);
    });
  });

  group('currency', () {
    testWidgets('changing the currency changes the symbol on the card, the form and the monthly screen', (tester) async {
      await savePlan(_base);
      final b = await BudgetService.getInstance();
      await b.addExpense(amount: 40, category: ExpenseCategory.food, date: DateTime(2026, 10, 12));
      await openFinancial(tester);
      expect(valueOf(tester, 'income_value'), '9,000 ر.س');

      await tester.tap(find.text('تعديل الخطة'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('درهم إماراتي (د.إ)').last);
      await tester.pumpAndSettle();
      await savePlanFromEditor(tester);

      expect(valueOf(tester, 'income_value'), '9,000 د.إ');
      expect((await BudgetPlanService.getInstance()).plan.currencyCode, 'AED');

      await tester.tap(find.text('سجّل مصروف'));
      await tester.pumpAndSettle();
      expect(tester.widget<TextField>(find.widgetWithText(TextField, 'المبلغ')).decoration!.suffixText, 'د.إ');
      await tester.pageBack();
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('مصاريفي الشهرية'));
      await tester.pumpAndSettle();
      expect(find.text('40 د.إ'), findsWidgets);
    });

    testWidgets('the monthly screen keeps the Saudi riyal when no plan exists', (tester) async {
      final b = await BudgetService.getInstance();
      await b.addExpense(amount: 25.5, category: ExpenseCategory.food, date: DateTime.now());
      await bigScreen(tester);
      await pumpScreen(tester, const BudgetSummaryScreen());

      expect(find.text('25.5 ر.س'), findsWidgets);
    });
  });

  group('budget suggestion', () {
    testWidgets('the local suggestion is saved as category limits with one tap, then shown on the main screen', (tester) async {
      await savePlan(_base);
      await openFinancial(tester);

      await tester.tap(find.text('اقتراح ميزانية'));
      await tester.pumpAndSettle();
      expect(find.text('اقتراح محلي (بلا إنترنت)'), findsOneWidget);
      expect(find.text('1,750 ر.س'), findsOneWidget, reason: 'food = 35% of 5,000');

      await tester.tap(find.text('حفظ كحدود للفئات').first);
      await tester.pumpAndSettle();

      final limits = (await BudgetPlanService.getInstance()).plan.limits;
      expect(limits.keys.toSet(), ExpenseCategory.values.toSet());
      expect(limits[ExpenseCategory.food], 1750);
      expect(find.byKey(const ValueKey('category_food')), findsOneWidget);
      expect(find.textContaining('حُفظت الحدود'), findsOneWidget);

      // وتبقى بعد إغلاق التطبيق، ويمكن تعديلها من شاشة الخطة.
      await restartApp(tester);
      expect(find.byKey(const ValueKey('category_food')), findsOneWidget);
      await tester.tap(find.text('تعديل الخطة'));
      await tester.pumpAndSettle();
      expect(tester.widget<TextField>(find.widgetWithText(TextField, 'حد طعام')).controller!.text, '1750');
      await tester.enterText(find.widgetWithText(TextField, 'حد طعام'), '1900');
      await savePlanFromEditor(tester);
      expect((await BudgetPlanService.getInstance()).plan.limits[ExpenseCategory.food], 1900);
    });

    testWidgets('with nothing available there is nothing to suggest', (tester) async {
      await savePlan(const BudgetPlan(income: 1000, savings: SavingsGoal(value: 1000)));
      await openFinancial(tester);

      await tester.tap(find.text('اقتراح ميزانية'));
      await tester.pumpAndSettle();

      expect(find.textContaining('لا يوجد متاح للصرف'), findsOneWidget);
      expect(find.text('حفظ كحدود للفئات'), findsNothing);
    });

    group('with AI', () {
      const goodReply =
          '{"limits": {"food": 1500, "transport": 700, "entertainment": 300, "shopping": 800, "unknown": 9}, "note": "ركّز على الطعام"}';

      late _FakeProvider fake;

      Future<void> openSuggestion(WidgetTester tester, {AiResolver? resolver, String reply = goodReply}) async {
        fake = _FakeProvider((_) => AiReply(reply));
        await savePlan(_base);
        await openFinancial(tester, ai: resolver ?? ((_) async => AiService.withProvider(fake)));
        await tester.tap(find.text('اقتراح ميزانية'));
        await tester.pumpAndSettle();
      }

      testWidgets('nothing is sent when the screen opens, or when the user declines', (tester) async {
        await openSuggestion(tester);
        expect(fake.sent, isEmpty, reason: 'opening the screen sends nothing');

        await tester.tap(find.text('اطلب اقتراحًا بالذكاء الاصطناعي'));
        await tester.pumpAndSettle();
        expect(find.text('إرسال بياناتك المالية؟'), findsOneWidget);
        await tester.tap(find.text('إلغاء'));
        await tester.pumpAndSettle();

        expect(fake.sent, isEmpty, reason: 'declined: no request was made');
        expect(find.text('حفظ كحدود للفئات'), findsOneWidget, reason: 'only the local suggestion is offered');
      });

      testWidgets('the consent dialog lists exactly what is sent, and only those numbers go out', (tester) async {
        await openSuggestion(tester);

        await tester.tap(find.text('اطلب اقتراحًا بالذكاء الاصطناعي'));
        await tester.pumpAndSettle();
        expect(find.textContaining('الدخل الشهري: 9,000 ر.س'), findsOneWidget);
        expect(find.textContaining('مجموع المصروفات الثابتة: 3,000 ر.س'), findsOneWidget);
        expect(find.textContaining('هدف الادخار: 1,000 ر.س'), findsOneWidget);
        expect(find.textContaining('المتاح للصرف: 5,000 ر.س'), findsOneWidget);
        expect(find.textContaining('لن تُرسل أسماء مصروفاتك الثابتة'), findsOneWidget);

        await tester.tap(find.text('أوافق وأرسل هذه المرة'));
        await tester.pumpAndSettle();

        expect(fake.sent, hasLength(1));
        final prompt = fake.sent.single.messages.single.text;
        expect(prompt, allOf(contains('9000'), contains('3000'), contains('1000'), contains('5000'), contains('ريال سعودي')));
        expect(prompt.contains('إيجار'), isFalse, reason: 'fixed expense names are not sent');
      });

      testWidgets('consent is asked again every time', (tester) async {
        await openSuggestion(tester);

        for (var i = 1; i <= 2; i++) {
          await tester.tap(find.text('اطلب اقتراحًا بالذكاء الاصطناعي'));
          await tester.pumpAndSettle();
          expect(find.text('إرسال بياناتك المالية؟'), findsOneWidget, reason: 'ask #$i');
          await tester.tap(find.text('أوافق وأرسل هذه المرة'));
          await tester.pumpAndSettle();
          expect(fake.sent, hasLength(i));
        }
      });

      testWidgets('the AI limits are read as untrusted data and saved with one tap', (tester) async {
        await openSuggestion(tester);
        await tester.tap(find.text('اطلب اقتراحًا بالذكاء الاصطناعي'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('أوافق وأرسل هذه المرة'));
        await tester.pumpAndSettle();

        expect(find.text('ركّز على الطعام'), findsOneWidget);
        expect(find.text('1,500 ر.س'), findsOneWidget);
        // أزرار الحفظ: المحلي ثم الذكي.
        final saveButtons = find.text('حفظ كحدود للفئات');
        expect(saveButtons, findsNWidgets(2));
        await tester.tap(saveButtons.last);
        await tester.pumpAndSettle();

        final limits = (await BudgetPlanService.getInstance()).plan.limits;
        expect(limits, {
          ExpenseCategory.food: 1500,
          ExpenseCategory.transport: 700,
          ExpenseCategory.entertainment: 300,
          ExpenseCategory.shopping: 800,
        });
      });

      testWidgets('an unreadable reply shows a message and offers no save', (tester) async {
        await openSuggestion(tester, reply: 'أنصحك بتقليل المصاريف عمومًا.');
        await tester.tap(find.text('اطلب اقتراحًا بالذكاء الاصطناعي'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('أوافق وأرسل هذه المرة'));
        await tester.pumpAndSettle();

        expect(find.textContaining('لم أتمكن من قراءة الاقتراح'), findsOneWidget);
        expect(find.text('حفظ كحدود للفئات'), findsOneWidget, reason: 'the local one only');
        expect((await BudgetPlanService.getInstance()).plan.limits, isEmpty);
      });

      testWidgets('leaving the provider setup without a key sends nothing and shows no dialog', (tester) async {
        await openSuggestion(tester, resolver: (_) async => null);

        await tester.tap(find.text('اطلب اقتراحًا بالذكاء الاصطناعي'));
        await tester.pumpAndSettle();

        expect(find.text('إرسال بياناتك المالية؟'), findsNothing);
        expect(fake.sent, isEmpty);
      });
    });
  });
}
