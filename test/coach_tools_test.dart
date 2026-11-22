import 'package:eman_life_app/core/app_events.dart';
import 'package:eman_life_app/core/services/database_service.dart';
import 'package:eman_life_app/features/coach/coach_ai_service.dart';
import 'package:eman_life_app/features/coach/coach_history_screen.dart';
import 'package:eman_life_app/features/coach/coach_screen.dart';
import 'package:eman_life_app/features/coach/coach_session_service.dart';
import 'package:eman_life_app/features/coach/models/coach_question.dart';
import 'package:eman_life_app/features/coach/tools/coach_step_task.dart';
import 'package:eman_life_app/features/coach/tools/coach_tool_record.dart';
import 'package:eman_life_app/features/coach/tools/emotion_checkin_screen.dart';
import 'package:eman_life_app/features/coach/tools/wheel_of_life_screen.dart';
import 'package:eman_life_app/features/goals_and_tasks/goals_tasks_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/test_storage.dart';
import 'helpers/widget_helpers.dart';

CoachToolRecord _wheel(DateTime date, {String? step, Map<String, int>? scores, bool followedUp = false}) => CoachToolRecord(
      id: '',
      kind: CoachToolKind.wheel,
      date: date,
      data: {
        'scores': scores ?? {for (final a in WheelArea.values) a.name: 5},
        'focus': 'health',
        'answers': const ['', '', ''],
      },
      step: step,
      followedUp: followedUp,
    );

CoachToolRecord _emotion(DateTime date, Feeling feeling, int intensity) => CoachToolRecord(
      id: '',
      kind: CoachToolKind.emotion,
      date: date,
      data: {'feeling': feeling.name, 'intensity': intensity, 'body': const <String>[]},
    );

void main() {
  late TestStorage storage;

  setUp(() async {
    storage = await TestStorage.inMemory();
  });
  tearDown(() => storage.dispose());

  final now = DateTime(2026, 11, 22, 10);

  group('records and rules', () {
    test('a record survives saving and reading back, and is not mistaken for a question session', () async {
      final service = await CoachSessionService.getInstance();
      await service.saveSession(
        question: const CoachQuestion(id: 'beliefs_01', domain: CoachDomain.beliefs, text: 'سؤال'),
        answerText: 'إجابة',
        date: now,
      );
      final saved = await service.saveToolRecord(_wheel(now, step: 'مشي عشر دقائق'));

      expect(saved.id, isNotEmpty);
      final back = service.toolRecords().single;
      expect(back.kind, CoachToolKind.wheel);
      expect(back.step, 'مشي عشر دقائق');
      expect(wheelScores(back)[WheelArea.health], 5);
      expect(service.getSessions(), hasLength(1), reason: 'the history of questions ignores tool records');
      expect(service.getSessions().single['answerText'], 'إجابة');
    });

    test('a tool record can be deleted and restored like a session', () async {
      final service = await CoachSessionService.getInstance();
      final saved = await service.saveToolRecord(_emotion(now, Feeling.calm, 3));
      final removed = await service.deleteSession(saved.id);
      expect(service.toolRecords(), isEmpty);
      await service.restoreSession(removed!);
      expect(recordFeeling(service.toolRecords().single), Feeling.calm);
    });

    test('the last step is asked about only from the next day, only once, and only the newest one', () {
      final yesterday = now.subtract(const Duration(days: 1));
      final older = _wheel(yesterday.subtract(const Duration(days: 3)), step: 'قديمة');
      final latest = _wheel(yesterday, step: 'جديدة');

      expect(pendingFollowUp([_wheel(now, step: 'اليوم')], now), isNull, reason: 'not on the day it was set');
      expect(pendingFollowUp([older, latest], now)?.step, 'جديدة');
      expect(pendingFollowUp([older, latest.copyWith(followedUp: true)], now), isNull,
          reason: 'once answered, older steps are not brought back');
      expect(pendingFollowUp([_wheel(yesterday)], now), isNull, reason: 'no step, nothing to ask');
    });

    test('scores outside 0..10 are ignored, and the weakest area is the default focus', () {
      final record = _wheel(now, scores: {'health': 7, 'money': 2, 'work': 11, 'fun': -1});
      expect(wheelScores(record), {WheelArea.health: 7, WheelArea.money: 2});
      expect(lowestArea({for (final a in WheelArea.values) a: 6, WheelArea.family: 3}), WheelArea.family);
    });

    test('the most frequent feeling counts only the last 30 days', () {
      final records = [
        _emotion(now, Feeling.anxious, 6),
        _emotion(now.subtract(const Duration(days: 2)), Feeling.anxious, 4),
        _emotion(now.subtract(const Duration(days: 3)), Feeling.calm, 3),
        for (var i = 0; i < 5; i++) _emotion(now.subtract(const Duration(days: 40)), Feeling.sad, 5),
      ];
      expect(mostFrequentFeeling(records, now), Feeling.anxious);
      expect(mostFrequentFeeling(const [], now), isNull);
    });
  });

  group('screens', () {
    Future<void> tall(WidgetTester tester) async {
      tester.view.physicalSize = const Size(900, 4200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
    }

    /// الشاشة تُفتح فوق صفحة أخرى، كما في التطبيق، فيعمل الرجوع بعد الحفظ.
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

    void slide(WidgetTester tester, Finder within, double value) {
      final slider = tester.widget<Slider>(find.descendant(of: within, matching: find.byType(Slider), matchRoot: true));
      slider.onChanged!(value);
    }

    testWidgets('wheel of life: the weakest area becomes the focus, and the step is saved and added to tasks',
        (tester) async {
      await tall(tester);
      final before = AppEvents.tasksChanged.value;
      await pushScreen(tester, WheelOfLifeScreen(now: () => now));

      slide(tester, find.byKey(const ValueKey('wheel_slider_health')), 2);
      await tester.pump();
      expect(find.text('ما الذي يجعل «الصحة» عند 2 وليس أقل؟'), findsOneWidget);

      await tester.enterText(find.byKey(const ValueKey('wheel_answer_0')), 'أمشي أحيانًا');
      await tester.enterText(find.byKey(const ValueKey('wheel_answer_3')), 'مشي عشر دقائق بعد العشاء');
      await tester.pump();
      await tester.tap(find.text('حفظ العجلة'));
      await settle(tester);

      final record = (await tester.runAsync(() async => (await CoachSessionService.getInstance()).toolRecords()))!.single;
      expect(wheelScores(record)[WheelArea.health], 2);
      expect(record.data['focus'], 'health');
      expect(record.step, 'مشي عشر دقائق بعد العشاء');
      final tasks = (await tester.runAsync(() async => (await DatabaseService.getInstance()).getDailyTasks()))!;
      expect(tasks.single['title'], 'مشي عشر دقائق بعد العشاء');
      expect(tasks.single['category'], coachTaskCategory);
      expect(AppEvents.tasksChanged.value, before + 1);
      expect(find.text('open'), findsOneWidget, reason: 'the screen closes after saving');
    });

    testWidgets('the next wheel starts from the last one and shows it for comparison', (tester) async {
      await tall(tester);
      await tester.runAsync(() async {
        final service = await CoachSessionService.getInstance();
        await service.saveToolRecord(_wheel(now.subtract(const Duration(days: 7)), scores: {
          for (final a in WheelArea.values) a.name: a == WheelArea.money ? 3 : 6,
        }));
      });
      await pushScreen(tester, WheelOfLifeScreen(now: () => now));

      expect(find.textContaining('المرة السابقة'), findsOneWidget);
      expect(find.text('ما الذي يجعل «المال» عند 3 وليس أقل؟'), findsOneWidget, reason: 'starts from last time');
      slide(tester, find.byKey(const ValueKey('wheel_slider_money')), 5);
      await tester.pump();
      expect(find.text('كان 3'), findsOneWidget);
    });

    testWidgets('crisis words in a wheel answer bring up the help dialog', (tester) async {
      await tall(tester);
      await pushScreen(tester, WheelOfLifeScreen(now: () => now));
      await tester.enterText(find.byKey(const ValueKey('wheel_answer_2')), 'أفكر في الانتحار');
      await tester.tap(find.text('حفظ العجلة'));
      await settle(tester);
      expect(find.text('مهم'), findsOneWidget);
    });

    testWidgets('naming a strong feeling saves it to the log and offers the calm breathing session', (tester) async {
      await tall(tester);
      var opened = 0;
      await pushScreen(
        tester,
        EmotionCheckinScreen(now: () => now, openMeditation: (_) async => opened++),
      );
      expect(find.text('لا مشاعر مسجّلة بعد.'), findsOneWidget);

      await tester.tap(find.widgetWithText(ChoiceChip, 'قلق'));
      await tester.pump();
      slide(tester, find.byKey(const ValueKey('emotion_intensity')), 8);
      await tester.tap(find.widgetWithText(FilterChip, 'الصدر'));
      await tester.enterText(find.byKey(const ValueKey('emotion_trigger')), 'موعد مهم غدًا');
      await tester.pump();
      await tester.tap(find.text('حفظ'));
      await settle(tester);

      expect(find.textContaining('تنفّس هادئ'), findsOneWidget);
      await tester.tap(find.text('فتح التأمل'));
      await settle(tester);
      expect(opened, 1);
      expect(find.text('قلق · 8 من 10'), findsOneWidget);
      expect(find.text('الأكثر تكرارًا في آخر 30 يومًا: قلق'), findsOneWidget);
      final record = (await tester.runAsync(() async => (await CoachSessionService.getInstance()).toolRecords()))!.single;
      expect(record.data['body'], ['chest']);
      expect(record.data['trigger'], 'موعد مهم غدًا');
    });

    testWidgets('a mild feeling is saved without the breathing suggestion', (tester) async {
      await tall(tester);
      await pushScreen(tester, EmotionCheckinScreen(now: () => now, openMeditation: (_) async {}));
      await tester.tap(find.widgetWithText(ChoiceChip, 'هدوء'));
      await tester.pump();
      await tester.tap(find.text('حفظ'));
      await settle(tester);
      expect(find.textContaining('تنفّس هادئ'), findsNothing);
      expect(find.text('هدوء · 5 من 10'), findsOneWidget);
    });

    testWidgets('the coach asks about yesterday\'s step once, and remembers the answer', (tester) async {
      await tall(tester);
      await tester.runAsync(() async {
        final service = await CoachSessionService.getInstance();
        await service.saveToolRecord(_wheel(now.subtract(const Duration(days: 1)), step: 'ترتيب المكتب'));
      });
      await tester.runAsync(CoachSessionService.getInstance);
      await pumpScreen(
        tester,
        CoachScreen(
          aiService: CoachAiService(generator: ({required systemPrompt, required userContent}) async => 'سؤال؟'),
          clock: () => now,
          aiAccess: (_) async => true,
          countryCode: () => 'SA',
        ),
      );

      expect(find.text('«ترتيب المكتب». كيف سارت؟'), findsOneWidget);
      await tester.tap(find.text('تمّت'));
      await settle(tester);
      expect(find.byKey(const ValueKey('coach_follow_up')), findsNothing);
      final record = (await tester.runAsync(() async => (await CoachSessionService.getInstance()).toolRecords()))!.single;
      expect(record.followedUp, isTrue);
      expect(record.stepDone, isTrue);
    });

    testWidgets('the history lists tool entries next to question sessions', (tester) async {
      await tall(tester);
      await tester.runAsync(() async {
        final service = await CoachSessionService.getInstance();
        await service.saveToolRecord(_emotion(now, Feeling.grateful, 4));
        await service.saveToolRecord(_wheel(now, step: 'اتصال بصديق'));
      });
      await pumpScreen(tester, const CoachHistoryScreen());
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
      await settle(tester);

      expect(find.text('أدوات المدرب'), findsOneWidget);
      expect(find.text('امتنان · 4 من 10'), findsOneWidget);
      expect(find.textContaining('الخطوة: اتصال بصديق'), findsOneWidget);
    });

    testWidgets('a step added from the coach shows up in the tasks tab at once', (tester) async {
      await tall(tester);
      await pumpScreen(tester, const GoalsTasksScreen());
      await tester.runAsync(() => addCoachStepAsTask('قراءة عشر صفحات'));
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
      await settle(tester);
      expect(find.text('قراءة عشر صفحات'), findsOneWidget);
    });
  });
}
