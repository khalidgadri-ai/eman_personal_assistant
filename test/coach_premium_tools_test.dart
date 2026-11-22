import 'package:eman_life_app/core/services/database_service.dart';
import 'package:eman_life_app/features/coach/coach_history_screen.dart';
import 'package:eman_life_app/features/coach/coach_session_service.dart';
import 'package:eman_life_app/features/coach/tools/belief_check_screen.dart';
import 'package:eman_life_app/features/coach/tools/coach_tool_record.dart';
import 'package:eman_life_app/features/coach/tools/coach_tools_screen.dart';
import 'package:eman_life_app/features/coach/tools/decision_screen.dart';
import 'package:eman_life_app/features/coach/tools/habit_change_screen.dart';
import 'package:eman_life_app/features/coach/tools/inner_voice_screen.dart';
import 'package:eman_life_app/features/reminders/reminder_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/test_storage.dart';
import 'helpers/widget_helpers.dart';

CoachToolRecord _habit(DateTime start, {String id = '7', List<String> checkins = const [], bool stopped = false, String? reminder}) =>
    CoachToolRecord(
      id: id,
      kind: CoachToolKind.habit,
      date: start,
      data: {
        'habit': 'السهر',
        'dailyStep': 'إطفاء الجوال الساعة 11',
        'checkins': checkins,
        'stopped': ?(stopped ? true : null),
        'reminder': ?reminder,
      },
    );

void main() {
  late TestStorage storage;

  setUp(() async {
    storage = await TestStorage.inMemory();
  });
  tearDown(() => storage.dispose());

  final now = DateTime(2026, 11, 22, 10);

  group('habit tracking rules', () {
    test('day 1 is the start day, and the habit is active through day 21 only', () {
      final h = _habit(DateTime(2026, 11, 1, 20));
      expect(habitDayNumber(h, DateTime(2026, 11, 1, 8)), 1);
      expect(habitDayNumber(h, DateTime(2026, 11, 21, 23)), 21);
      expect(habitIsActive(h, DateTime(2026, 11, 21, 23)), isTrue);
      expect(habitIsActive(h, DateTime(2026, 11, 22)), isFalse, reason: 'day 22 is after the 21 days');
      expect(habitIsActive(_habit(DateTime(2026, 11, 20), stopped: true), now), isFalse);
    });

    test('only marks inside the 21 days count', () {
      final h = _habit(DateTime(2026, 11, 1), checkins: ['2026-10-31', '2026-11-01', '2026-11-05', '2026-11-21', '2026-11-22']);
      expect(habitDoneCount(h), 3);
    });

    test('an active habit with a time gets a daily reminder with its step', () {
      final planned = ReminderPlanner.plan(
        medications: const [],
        beauty: const [],
        tasks: const [],
        habits: [_habit(DateTime(2026, 11, 20), reminder: '22:30'), _habit(DateTime(2026, 11, 20), id: '8')],
      );
      expect(planned, hasLength(1), reason: 'a habit without a time has no reminder');
      expect(planned.single.repeatsDaily, isTrue);
      expect(planned.single.body, 'إطفاء الجوال الساعة 11');
      expect((planned.single.hour, planned.single.minute), (22, 30));
    });

    test('reminders are planned only for habits still running', () async {
      final service = await CoachSessionService.getInstance();
      await service.saveToolRecord(_habit(now.subtract(const Duration(days: 3)), reminder: '21:00'));
      await service.saveToolRecord(_habit(now.subtract(const Duration(days: 30)), reminder: '21:00'));
      await service.saveToolRecord(_habit(now.subtract(const Duration(days: 2)), stopped: true, reminder: '21:00'));
      final active = await CoachSessionService.activeHabits(now);
      expect(active, hasLength(1));
      expect(habitDayNumber(active.single, now), 4);
    });

    test('the four new tools are the subscription ones', () {
      expect(CoachToolKind.values.where((k) => k.isPremium),
          [CoachToolKind.belief, CoachToolKind.innerVoice, CoachToolKind.decision, CoachToolKind.habit]);
    });
  });

  group('screens', () {
    Future<void> tall(WidgetTester tester) async {
      tester.view.physicalSize = const Size(900, 5200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
    }

    Future<void> pushScreen(WidgetTester tester, Widget screen) async {
      await tester.runAsync(CoachSessionService.getInstance);
      await pumpScreen(
        tester,
        Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen)),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await settle(tester);
    }

    Future<List<CoachToolRecord>> records(WidgetTester tester) async =>
        (await tester.runAsync(() async => (await CoachSessionService.getInstance()).toolRecords()))!;

    testWidgets('without a subscription the four tools open the paywall; free tools open directly', (tester) async {
      await tall(tester);
      var checks = 0;
      var paywalls = 0;
      var subscribeOnPaywall = false;
      await tester.runAsync(CoachSessionService.getInstance);
      await pumpScreen(
        tester,
        CoachToolsScreen(
          checkSubscription: () async {
            checks++;
            return false;
          },
          openPaywall: (_) async {
            paywalls++;
            return subscribeOnPaywall;
          },
        ),
      );

      await tester.tap(find.text('فحص معتقد'));
      await settle(tester);
      expect(paywalls, 1);
      expect(find.byType(BeliefCheckScreen), findsNothing, reason: 'left the paywall without subscribing');

      subscribeOnPaywall = true;
      await tester.tap(find.text('تغيير عادة'));
      await settle(tester);
      expect(find.byType(HabitChangeScreen), findsOneWidget, reason: 'opens once subscribed');
      await tester.pageBack();
      await settle(tester);

      final before = checks;
      await tester.tap(find.text('عجلة الحياة'));
      await settle(tester);
      expect(checks, before, reason: 'free tools never check the subscription');
    });

    testWidgets('belief check: the sentence is required; the check and its step are saved', (tester) async {
      await tall(tester);
      await pushScreen(tester, BeliefCheckScreen(now: () => now));
      final save = find.widgetWithText(ElevatedButton, 'حفظ');
      expect(tester.widget<ElevatedButton>(save).onPressed, isNull);
      expect(find.text('كتابة الجملة أولًا'), findsOneWidget);

      await tester.enterText(find.byKey(const ValueKey('belief_field_0')), 'لا أنجح في أي شيء');
      await tester.enterText(find.byKey(const ValueKey('belief_field_4')), 'نجحت في أشياء وتعثرت في أخرى');
      await tester.enterText(find.byKey(const ValueKey('belief_field_6')), 'كتابة ثلاثة أشياء أنجزتها');
      await tester.pump();
      await tester.tap(save);
      await settle(tester);

      final r = (await records(tester)).single;
      expect(r.kind, CoachToolKind.belief);
      expect(r.data['belief'], 'لا أنجح في أي شيء');
      expect(r.data['reframe'], 'نجحت في أشياء وتعثرت في أخرى');
      expect(r.data['before'], 7);
      expect(r.step, 'كتابة ثلاثة أشياء أنجزتها');
      final tasks = (await tester.runAsync(() async => (await DatabaseService.getInstance()).getDailyTasks()))!;
      expect(tasks.single['title'], 'كتابة ثلاثة أشياء أنجزتها');
    });

    testWidgets('inner voice: the pattern, name and reworded sentence are saved', (tester) async {
      await tall(tester);
      await pushScreen(tester, InnerVoiceScreen(now: () => now));
      await tester.tap(find.byKey(const ValueKey('voice_perfectionist')));
      await tester.enterText(find.byKey(const ValueKey('voice_name')), 'المدقق');
      await tester.enterText(find.byKey(const ValueKey('voice_field_0')), 'لازم يكون كل شيء كاملًا');
      await tester.enterText(find.byKey(const ValueKey('voice_field_3')), 'الجيد بما يكفي يكفي هنا');
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('tool_add_task')));
      await tester.pump();
      await tester.tap(find.widgetWithText(ElevatedButton, 'حفظ'));
      await settle(tester);

      final r = (await records(tester)).single;
      expect(r.data['type'], 'perfectionist');
      expect(r.data['name'], 'المدقق');
      expect(r.data['reframe'], 'الجيد بما يكفي يكفي هنا');
      final tasks = (await tester.runAsync(() async => (await DatabaseService.getInstance()).getDailyTasks()))!;
      expect(tasks, isEmpty, reason: 'adding to tasks was turned off');
    });

    testWidgets('decision: questions name the options, and the choice is saved', (tester) async {
      await tall(tester);
      await pushScreen(tester, DecisionScreen(now: () => now));
      await tester.enterText(find.byKey(const ValueKey('decision_a')), 'وظيفة جديدة');
      await tester.enterText(find.byKey(const ValueKey('decision_b')), 'البقاء');
      await tester.pump();
      expect(find.text('ما الذي يُكسب مع «وظيفة جديدة»؟'), findsOneWidget);
      expect(find.text('ما الذي يُخسر مع «البقاء»؟'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('decision_regret_a')));
      await tester.tap(find.byKey(const ValueKey('decision_chosen_b')));
      await tester.pump();
      await tester.tap(find.widgetWithText(ElevatedButton, 'حفظ'));
      await settle(tester);

      final r = (await records(tester)).single;
      expect(r.data['optionA'], 'وظيفة جديدة');
      expect(r.data['regret'], 'a');
      expect(r.data['chosen'], 'b');
    });

    testWidgets('habit: starting shows the 21-day tracker; today can be marked and stopping ends it', (tester) async {
      await tall(tester);
      await pushScreen(tester, HabitChangeScreen(now: () => now));
      await tester.enterText(find.byKey(const ValueKey('habit_field_0')), 'السهر');
      await tester.enterText(find.byKey(const ValueKey('habit_field_6')), 'إطفاء الجوال الساعة 11');
      await tester.pump();
      await tester.tap(find.text('بدء 21 يومًا'));
      await settle(tester);

      expect(find.text('اليوم 1 من 21'), findsOneWidget);
      expect(find.text('الأيام المنجزة: 0 من 21'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('habit_today')));
      await settle(tester);
      expect(find.text('الأيام المنجزة: 1 من 21'), findsOneWidget);
      expect(habitCheckins((await records(tester)).single), {'2026-11-22'});

      await tester.tap(find.text('إيقاف المتابعة'));
      await settle(tester);
      await tester.tap(find.widgetWithText(TextButton, 'إيقاف المتابعة').last);
      await settle(tester);
      expect(find.text('بدء 21 يومًا'), findsOneWidget, reason: 'a new habit can start');
      expect(find.text('عادات سابقة'), findsOneWidget);
      expect((await records(tester)).single.data['stopped'], isTrue);
    });

    testWidgets('the history summarizes the new tools', (tester) async {
      await tall(tester);
      await tester.runAsync(() async {
        final service = await CoachSessionService.getInstance();
        await service.saveToolRecord(CoachToolRecord(
          id: '',
          kind: CoachToolKind.belief,
          date: now,
          data: const {'belief': 'لا أحد يهتم', 'reframe': 'بعض الناس يهتمون'},
        ));
        await service.saveToolRecord(CoachToolRecord(
          id: '',
          kind: CoachToolKind.decision,
          date: now,
          data: const {'optionA': 'السفر', 'optionB': 'البقاء'},
        ));
      });
      await pumpScreen(tester, const CoachHistoryScreen());
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
      await settle(tester);
      expect(find.text('فحص معتقد'), findsOneWidget);
      expect(find.textContaining('لا أحد يهتم'), findsOneWidget);
      expect(find.textContaining('بعض الناس يهتمون'), findsOneWidget);
      expect(find.textContaining('السفر / البقاء'), findsOneWidget);
    });
  });
}
