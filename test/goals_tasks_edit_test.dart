import 'package:eman_life_app/core/services/database_service.dart';
import 'package:eman_life_app/features/goals_and_tasks/goals_tasks_screen.dart';
import 'package:eman_life_app/features/reminders/reminder_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/test_storage.dart';
import 'helpers/widget_helpers.dart';

class _Recorder implements ReminderGateway {
  final List<PlannedReminder> scheduled = [];
  int permissionAsks = 0;

  @override
  Future<void> cancelAll() async => scheduled.clear();

  @override
  Future<bool> requestPermission() async {
    permissionAsks++;
    return true;
  }

  @override
  Future<void> schedule(PlannedReminder reminder, DateTime firstFire) async => scheduled.add(reminder);
}

void main() {
  late TestStorage storage;
  late _Recorder reminders;

  setUp(() async {
    storage = await TestStorage.inMemory();
    reminders = _Recorder();
    ReminderService.gatewayOverride = reminders;
  });
  tearDown(() async {
    ReminderService.gatewayOverride = null;
    await storage.dispose();
  });

  Future<DatabaseService> db() => DatabaseService.getInstance();

  Future<void> open(WidgetTester tester) async {
    tester.view.physicalSize = const Size(900, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await pumpScreen(tester, const GoalsTasksScreen());
  }

  group('tasks', () {
    testWidgets('tasks saved by the old version get ids once and keep their data', (tester) async {
      await (await db()).saveDailyTasks([
        {'title': 'قديمة', 'category': 'المنزل', 'done': true},
      ]);

      await open(tester);

      final saved = (await db()).getDailyTasks().single;
      expect(saved['id'], isA<String>());
      expect(saved['id'], isNotEmpty);
      expect(saved['title'], 'قديمة');
      expect(saved['done'], true);
    });

    testWidgets('tapping a task edits its title, category and reminder', (tester) async {
      await (await db()).saveDailyTasks([
        {'id': 't1', 'title': 'شراء خبز', 'category': 'شخصي', 'done': false},
      ]);
      await open(tester);

      await tester.tap(find.text('شراء خبز'));
      await tester.pumpAndSettle();
      await tester.enterText(find.widgetWithText(TextField, 'المهمة'), 'شراء خبز وحليب');
      await tester.tap(find.text('ضبط تذكير'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('حفظ'));
      await tester.pumpAndSettle();

      final saved = (await db()).getDailyTasks().single;
      expect(saved['id'], 't1', reason: 'editing keeps the same task');
      expect(saved['title'], 'شراء خبز وحليب');
      expect(saved['reminder'], '09:00');
      expect(find.text('شراء خبز وحليب'), findsOneWidget);
      expect(find.text('⏰ 09:00'), findsOneWidget);
    });

    testWidgets('a task reminder is scheduled once, and the permission is asked only then', (tester) async {
      await open(tester);

      await tester.tap(find.byTooltip('إضافة مهمة'));
      await tester.pumpAndSettle();
      await tester.enterText(find.widgetWithText(TextField, 'المهمة'), 'اتصال بالطبيب');
      await tester.tap(find.text('ضبط تذكير'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('إضافة'));
      await tester.pumpAndSettle();

      expect(reminders.scheduled, hasLength(1));
      expect(reminders.scheduled.single.body, 'اتصال بالطبيب');
      expect(reminders.scheduled.single.repeatsDaily, isFalse);
      expect(reminders.permissionAsks, 1);
    });

    testWidgets('a task without a reminder never asks about notifications', (tester) async {
      await open(tester);

      await tester.tap(find.byTooltip('إضافة مهمة'));
      await tester.pumpAndSettle();
      await fillDialog(tester, {'المهمة': 'بلا تذكير'});

      expect(reminders.permissionAsks, 0);
      expect(reminders.scheduled, isEmpty);
    });

    testWidgets('ticking a task cancels its reminder and unticking brings it back', (tester) async {
      await (await db()).saveDailyTasks([
        {'id': 't1', 'title': 'مهمة', 'category': 'شخصي', 'done': false, 'reminder': '10:00'},
      ]);
      await open(tester);
      await ReminderService.syncAll();
      expect(reminders.scheduled, hasLength(1));

      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();
      expect(reminders.scheduled, isEmpty);

      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();
      expect(reminders.scheduled, hasLength(1));
    });

    testWidgets('pinning floats a task to the top and the pin is saved', (tester) async {
      await (await db()).saveDailyTasks([
        {'id': 'a', 'title': 'الأولى', 'category': 'شخصي', 'done': false},
        {'id': 'b', 'title': 'الثانية', 'category': 'شخصي', 'done': false},
      ]);
      await open(tester);
      expect(tester.getTopLeft(find.text('الأولى')).dy, lessThan(tester.getTopLeft(find.text('الثانية')).dy));

      await tester.tap(find.descendant(of: find.byKey(const ValueKey('task_b')), matching: find.byTooltip('تثبيت المهمة')));
      await tester.pumpAndSettle();

      expect(tester.getTopLeft(find.text('الثانية')).dy, lessThan(tester.getTopLeft(find.text('الأولى')).dy));
      expect((await db()).getDailyTasks().firstWhere((t) => t['id'] == 'b')['pinned'], true);
      expect(find.byTooltip('إلغاء تثبيت المهمة'), findsOneWidget);
    });

    testWidgets('deleting can be undone and the task returns to its place', (tester) async {
      await (await db()).saveDailyTasks([
        {'id': 'a', 'title': 'الأولى', 'category': 'شخصي', 'done': false},
        {'id': 'b', 'title': 'الثانية', 'category': 'شخصي', 'done': false},
        {'id': 'c', 'title': 'الثالثة', 'category': 'شخصي', 'done': false},
      ]);
      await open(tester);

      await tester.tap(find.descendant(of: find.byKey(const ValueKey('task_b')), matching: find.byTooltip('حذف المهمة')));
      await tester.pumpAndSettle();
      expect(find.text('الثانية'), findsNothing);
      expect((await db()).getDailyTasks().map((t) => t['id']), ['a', 'c']);

      await tester.tap(find.text('تراجع'));
      await tester.pumpAndSettle();
      expect(find.text('الثانية'), findsOneWidget);
      expect((await db()).getDailyTasks().map((t) => t['id']), ['a', 'b', 'c']);
    });
  });

  group('goals', () {
    Future<void> openGoals(WidgetTester tester) async {
      await open(tester);
      await openTab(tester, 'الأهداف الهرمية');
    }

    testWidgets('a goal can be edited, keeping its progress', (tester) async {
      await (await db()).saveGoals([
        {'id': 'g1', 'title': 'قراءة', 'type': 'هدف عام', 'progress': 0.5},
      ]);
      await openGoals(tester);

      await tester.tap(find.byTooltip('تعديل الهدف'));
      await tester.pumpAndSettle();
      await tester.enterText(find.widgetWithText(TextField, 'الهدف'), 'قراءة 20 صفحة');
      await tester.tap(find.text('حفظ'));
      await tester.pumpAndSettle();

      final saved = (await db()).getGoals().single;
      expect(saved['id'], 'g1');
      expect(saved['title'], 'قراءة 20 صفحة');
      expect(saved['progress'], 0.5);
      expect(find.text('50%'), findsOneWidget);
    });

    testWidgets('pin and undo-delete work for goals too', (tester) async {
      await (await db()).saveGoals([
        {'id': 'a', 'title': 'الأول', 'type': 'هدف عام', 'progress': 0.0},
        {'id': 'b', 'title': 'الثاني', 'type': 'هدف عام', 'progress': 0.0},
      ]);
      await openGoals(tester);

      await tester.tap(find.descendant(of: find.byKey(const ValueKey('goal_b')), matching: find.byTooltip('تثبيت الهدف')));
      await tester.pumpAndSettle();
      expect(tester.getTopLeft(find.text('الثاني')).dy, lessThan(tester.getTopLeft(find.text('الأول')).dy));

      await tester.tap(find.descendant(of: find.byKey(const ValueKey('goal_a')), matching: find.byTooltip('حذف الهدف')));
      await tester.pumpAndSettle();
      expect(find.text('الأول'), findsNothing);
      await tester.tap(find.text('تراجع'));
      await tester.pumpAndSettle();
      expect(find.text('الأول'), findsOneWidget);
      expect((await db()).getGoals().map((g) => g['id']), ['a', 'b']);
    });

    testWidgets('goals saved by the old version get ids once', (tester) async {
      await (await db()).saveGoals([
        {'title': 'قديم', 'type': 'هدف عام', 'progress': 0.2},
      ]);

      await openGoals(tester);

      expect((await db()).getGoals().single['id'], isNotEmpty);
    });
  });
}
