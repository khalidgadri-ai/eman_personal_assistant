import 'package:eman_life_app/core/services/database_service.dart';
import 'package:eman_life_app/features/goals_and_tasks/goals_tasks_screen.dart';
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

  Future<DatabaseService> db() => DatabaseService.getInstance();

  group('daily tasks', () {
    testWidgets('start empty and offer the add button', (tester) async {
      await pumpScreen(tester, const GoalsTasksScreen());

      expect(find.text('لا توجد مهام بعد. اضغط + لإضافة مهمة أو استخدم المذكرة الصوتية.'), findsOneWidget);
      expect(find.byTooltip('إضافة مهمة'), findsOneWidget);
    });

    testWidgets('a new task shows up at once and is saved', (tester) async {
      await pumpScreen(tester, const GoalsTasksScreen());

      await tester.tap(find.byTooltip('إضافة مهمة'));
      await tester.pumpAndSettle();
      await fillDialog(tester, {'المهمة': 'شراء خبز'});

      expect(find.text('شراء خبز'), findsOneWidget);
      expect(find.text('لا توجد مهام بعد. اضغط + لإضافة مهمة أو استخدم المذكرة الصوتية.'), findsNothing);
      final saved = (await db()).getDailyTasks().single;
      expect(saved['title'], 'شراء خبز');
      expect(saved['category'], 'شخصي');
      expect(saved['done'], false);
    });

    testWidgets('an empty title is not accepted', (tester) async {
      await pumpScreen(tester, const GoalsTasksScreen());

      await tester.tap(find.byTooltip('إضافة مهمة'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('إضافة'));
      await tester.pumpAndSettle();

      expect(find.text('هذا الحقل مطلوب'), findsOneWidget);
      expect((await db()).getDailyTasks(), isEmpty);
    });

    testWidgets('a huge Arabic title is cut to 120 characters instead of breaking the list', (tester) async {
      await pumpScreen(tester, const GoalsTasksScreen());

      await tester.tap(find.byTooltip('إضافة مهمة'));
      await tester.pumpAndSettle();
      await fillDialog(tester, {'المهمة': 'ن' * 5000});

      expect((await db()).getDailyTasks().single['title'], 'ن' * 120);
      expect(tester.takeException(), isNull);
    });

    testWidgets('ticking a task is saved, and deleting removes it for good', (tester) async {
      await pumpScreen(tester, const GoalsTasksScreen());
      await tester.tap(find.byTooltip('إضافة مهمة'));
      await tester.pumpAndSettle();
      await fillDialog(tester, {'المهمة': 'مهمة للاختبار'});

      await tester.tap(find.byType(Checkbox));
      await tester.pump();
      expect((await db()).getDailyTasks().single['done'], true);

      await tester.tap(find.byTooltip('حذف المهمة'));
      await tester.pump();
      expect(find.text('مهمة للاختبار'), findsNothing);
      expect((await db()).getDailyTasks(), isEmpty);
    });

    testWidgets('tasks are still there when the screen is opened again', (tester) async {
      await pumpScreen(tester, const GoalsTasksScreen());
      await tester.tap(find.byTooltip('إضافة مهمة'));
      await tester.pumpAndSettle();
      await fillDialog(tester, {'المهمة': 'تبقى بعد الإغلاق'});

      await tester.pumpWidget(const SizedBox());
      await pumpScreen(tester, const GoalsTasksScreen());

      expect(find.text('تبقى بعد الإغلاق'), findsOneWidget);
    });
  });

  group('goals', () {
    Future<void> openGoalsTab(WidgetTester tester) async {
      await pumpScreen(tester, const GoalsTasksScreen());
      await openTab(tester, 'الأهداف الهرمية');
    }

    testWidgets('start empty, and the add button becomes "إضافة هدف" on this tab', (tester) async {
      await openGoalsTab(tester);

      expect(find.text('لا توجد أهداف بعد. اضغط + لإضافة هدفك الأول.'), findsOneWidget);
      expect(find.byTooltip('إضافة هدف'), findsOneWidget);
      expect(find.byTooltip('إضافة مهمة'), findsNothing);
    });

    testWidgets('a new goal starts at 0%, can be moved, and is saved', (tester) async {
      await openGoalsTab(tester);

      await tester.tap(find.byTooltip('إضافة هدف'));
      await tester.pumpAndSettle();
      await fillDialog(tester, {'الهدف': 'قراءة كتاب'});

      expect(find.text('قراءة كتاب'), findsOneWidget);
      expect(find.text('هدف عام'), findsOneWidget);
      expect(find.text('0%'), findsOneWidget);

      await tester.drag(find.byType(Slider), const Offset(150, 0));
      await tester.pumpAndSettle();
      final progress = (await db()).getGoals().single['progress'] as double;
      expect(progress, greaterThan(0));
      expect(progress, lessThanOrEqualTo(1));
    });

    testWidgets('a goal can be deleted', (tester) async {
      await openGoalsTab(tester);
      await tester.tap(find.byTooltip('إضافة هدف'));
      await tester.pumpAndSettle();
      await fillDialog(tester, {'الهدف': 'هدف مؤقت'});

      await tester.tap(find.byTooltip('حذف الهدف'));
      await tester.pump();

      expect(find.text('هدف مؤقت'), findsNothing);
      expect((await db()).getGoals(), isEmpty);
    });
  });

  group('Quran tracker', () {
    Future<void> openQuranTab(WidgetTester tester) async {
      await pumpScreen(tester, const GoalsTasksScreen());
      await openTab(tester, 'الورد والتتبع');
    }

    testWidgets('starts at page 0 for a new user', (tester) async {
      await openQuranTab(tester);

      expect(find.text('الصفحة الحالية: 0'), findsOneWidget);
      expect(find.text('المتبقي لإتمام الختمة: 604 صفحة'), findsOneWidget);
    });

    testWidgets('+1 moves forward and is saved', (tester) async {
      await openQuranTab(tester);

      await tester.tap(find.text('تم قراءة صفحة (+1)'));
      await tester.pump();

      expect(find.text('الصفحة الحالية: 1'), findsOneWidget);
      expect((await db()).getQuranPage(), 1);
    });

    testWidgets('the page can be set directly, even with Arabic-Indic digits', (tester) async {
      await openQuranTab(tester);

      await tester.tap(find.text('تحديد الصفحة'));
      await tester.pumpAndSettle();
      await fillDialog(tester, {'رقم الصفحة (0 - 604)': '١٤٢'}, confirm: 'حفظ');

      expect(find.text('الصفحة الحالية: 142'), findsOneWidget);
      expect((await db()).getQuranPage(), 142);
    });

    testWidgets('a page outside 0..604 is rejected with a clear message', (tester) async {
      await openQuranTab(tester);

      await tester.tap(find.text('تحديد الصفحة'));
      await tester.pumpAndSettle();
      await fillDialog(tester, {'رقم الصفحة (0 - 604)': '700'}, confirm: 'حفظ');

      expect(find.text('أدخل رقمًا من 0 إلى 604'), findsOneWidget);
      expect((await db()).getQuranPage(), 0);
    });

    testWidgets('at page 604 the khatma is complete and +1 is disabled (no negative remainder)', (tester) async {
      await openQuranTab(tester);
      await tester.tap(find.text('تحديد الصفحة'));
      await tester.pumpAndSettle();
      await fillDialog(tester, {'رقم الصفحة (0 - 604)': '604'}, confirm: 'حفظ');

      expect(find.textContaining('أتممت الختمة'), findsOneWidget);
      final plusOne = tester.widget<ButtonStyleButton>(
        find.ancestor(of: find.text('تم قراءة صفحة (+1)'), matching: find.bySubtype<ButtonStyleButton>()),
      );
      expect(plusOne.onPressed, isNull);
    });
  });
}
