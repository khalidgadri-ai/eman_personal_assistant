import 'dart:convert';
import 'dart:io';

import 'package:eman_life_app/core/ai/ai_errors.dart';
import 'package:eman_life_app/core/ai/ai_service.dart';
import 'package:eman_life_app/core/ai/provider_presets.dart';
import 'package:eman_life_app/core/config/app_locale.dart';
import 'package:eman_life_app/core/services/assistant_prompt.dart';
import 'package:eman_life_app/core/widgets/ai_provider_screen.dart';
import 'package:eman_life_app/features/coach/coach_ai_service.dart';
import 'package:eman_life_app/features/coach/coach_safety.dart';
import 'package:eman_life_app/features/coach/coach_session_service.dart';
import 'package:eman_life_app/features/coach/models/coach_question.dart';
import 'package:eman_life_app/features/coach/tools/belief_check_screen.dart';
import 'package:eman_life_app/features/coach/tools/coach_tools_screen.dart';
import 'package:eman_life_app/features/coach/tools/decision_screen.dart';
import 'package:eman_life_app/features/coach/tools/habit_change_screen.dart';
import 'package:eman_life_app/features/coach/tools/inner_voice_screen.dart';
import 'package:eman_life_app/features/coach/tools/emotion_checkin_screen.dart';
import 'package:eman_life_app/features/coach/tools/wheel_of_life_screen.dart';
import 'package:eman_life_app/core/services/database_service.dart';
import 'package:eman_life_app/core/theme/app_theme.dart';
import 'package:eman_life_app/features/ai_assistant/ai_assistant_screen.dart';
import 'package:eman_life_app/features/awareness/models/social_app.dart';
import 'package:eman_life_app/features/awareness/usage_awareness_screen.dart';
import 'package:eman_life_app/features/budget/budget_plan_service.dart';
import 'package:eman_life_app/features/budget/budget_service.dart';
import 'package:eman_life_app/features/budget/models/budget_plan.dart';
import 'package:eman_life_app/features/budget/models/expense_entry.dart';
import 'package:eman_life_app/features/financial/financial_screen.dart';
import 'package:eman_life_app/features/goals_and_tasks/goals_tasks_screen.dart';
import 'package:eman_life_app/features/kitchen_and_home/kitchen_home_screen.dart';
import 'package:eman_life_app/features/onboarding/app_tour_screen.dart';
import 'package:eman_life_app/features/onboarding/onboarding_screen.dart';
import 'package:eman_life_app/features/settings/settings_screen.dart';
import 'package:eman_life_app/l10n/l10n.dart';
import 'package:eman_life_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/test_storage.dart';
import 'helpers/widget_helpers.dart';

Map<String, dynamic> _arb(String lang) =>
    jsonDecode(File('lib/l10n/app_$lang.arb').readAsStringSync()) as Map<String, dynamic>;

Iterable<String> _keys(Map<String, dynamic> arb) => arb.keys.where((k) => !k.startsWith('@'));

final RegExp _arabicLetter = RegExp('[؀-ۿ]');

/// مثل التطبيق نفسه: MaterialApp تتبع اختيار اللغة فورًا.
Widget _app(Widget home) => ValueListenableBuilder<AppLanguage>(
      valueListenable: AppLocale.choice,
      builder: (_, choice, _) => MaterialApp(
        theme: AppTheme.darkTheme,
        locale: AppLocale.resolve(choice, WidgetsBinding.instance.platformDispatcher.locale),
        supportedLocales: AppLocale.supported,
        localizationsDelegates: AppLocale.delegates,
        home: home,
      ),
    );

void main() {
  group('the text files', () {
    final ar = _arb('ar');
    final en = _arb('en');

    test('Arabic and English have exactly the same texts', () {
      expect(_keys(en).toSet(), _keys(ar).toSet());
    });

    test('no text is empty, and every Arabic text is Arabic', () {
      for (final key in _keys(ar)) {
        expect((ar[key] as String).trim(), isNotEmpty, reason: 'ar: $key');
        expect((en[key] as String).trim(), isNotEmpty, reason: 'en: $key');
        if (key != 'languageEnglish') {
          expect(_arabicLetter.hasMatch(ar[key] as String), isTrue, reason: 'ar: $key');
        }
      }
    });

    test('a placeholder in one language is in the other', () {
      final placeholder = RegExp(r'\{(\w+)');
      for (final key in _keys(ar)) {
        final inAr = placeholder.allMatches(ar[key] as String).map((m) => m.group(1)).toSet();
        final inEn = placeholder.allMatches(en[key] as String).map((m) => m.group(1)).toSet();
        expect(inEn.where((p) => p == 'count'), inAr.where((p) => p == 'count'), reason: key);
      }
    });
  });

  test('every ready-made interest has its own label in both languages', () {
    final ar = lookupAppLocalizations(AppLocale.arabic);
    final en = lookupAppLocalizations(AppLocale.english);
    for (final stored in kInterestOptions) {
      expect(interestLabel(ar, stored), stored, reason: 'Arabic shows what is stored');
      expect(interestLabel(en, stored), isNot(stored), reason: '$stored has an English label');
    }
    expect(interestLabel(en, 'هواية قديمة'), 'هواية قديمة', reason: 'an unknown old value shows as saved');
  });

  test('task categories and goal types saved in Arabic show in the app language', () {
    final ar = lookupAppLocalizations(AppLocale.arabic);
    final en = lookupAppLocalizations(AppLocale.english);
    for (final stored in ['شخصي', 'المنزل', 'العمل', 'العائلة']) {
      expect(taskCategoryLabel(ar, stored), stored);
      expect(taskCategoryLabel(en, stored), isNot(stored));
    }
    for (final stored in ['هدف عام', 'هدف سنوي', 'هدف شهري', 'هدف أسبوعي']) {
      expect(goalTypeLabel(ar, stored), stored);
      expect(goalTypeLabel(en, stored), isNot(stored));
    }
  });

  test('Arabic page counts follow the number rules in the text files too', () {
    final ar = lookupAppLocalizations(AppLocale.arabic);
    expect(ar.wirdRemaining(604), 'المتبقي لإتمام الختمة: 604 صفحات');
    expect(ar.wirdRemaining(11), 'المتبقي لإتمام الختمة: 11 صفحة');
    expect(ar.wirdRemaining(2), 'المتبقي لإتمام الختمة: صفحتان');
    expect(ar.wirdRemaining(1), 'المتبقي لإتمام الختمة: صفحة واحدة');
  });

  test('Arabic day and item counts follow the number rules (3-10 plural, 11-99 accusative, 100 singular)', () {
    final ar = lookupAppLocalizations(AppLocale.arabic);
    const days = {
      1: 'باقي يوم واحد', 2: 'باقي يومان', 3: 'باقي 3 أيام', 10: 'باقي 10 أيام', 11: 'باقي 11 يومًا',
      31: 'باقي 31 يومًا', 100: 'باقي 100 يوم', 102: 'باقي 102 يوم', 105: 'باقي 105 أيام',
    };
    days.forEach((n, text) => expect(ar.daysLeft(n), text));
    expect(ar.servingsCount(4), '4 حصص');
    expect(ar.movedToPantry(12), 'نُقل 12 بندًا إلى المؤونة');
    expect(ar.movedToPantry(100), 'نُقل 100 بند إلى المؤونة');
    final en = lookupAppLocalizations(AppLocale.english);
    expect(en.daysLeft(1), '1 day left');
    expect(en.daysLeft(9), '9 days left');
  });

  group('AI requests and the coach bank follow the language', () {
    tearDown(() => AppLocale.choice.value = AppLanguage.system);

    test('every coach question has an English text with no Arabic in it', () {
      final bank = jsonDecode(File('assets/coach_questions.json').readAsStringSync()) as List;
      expect(bank, hasLength(300));
      for (final raw in bank) {
        final q = CoachQuestion.fromJson(Map<String, dynamic>.from(raw as Map));
        expect(q.textEn, isNotNull, reason: q.id);
        expect(q.textEn!.trim(), isNotEmpty, reason: q.id);
        expect(q.textEn, isNot(contains(_arabicLetter)), reason: q.id);
        expect(q.textFor('en'), q.textEn);
        expect(q.textFor('ar'), q.text);
      }
    });

    test('a follow-up question from the model has no translation and shows as it came', () {
      const q = CoachQuestion(id: 'ai_followup', domain: CoachDomain.goals, text: 'What matters most here?');
      expect(q.textFor('en'), 'What matters most here?');
      expect(q.textFor('ar'), 'What matters most here?');
    });

    test('in English the prompts ask for English replies; in Arabic they stay Arabic', () {
      expect(AiService.exerciseAnalysisPrompt, contains('بالعربية'));
      expect(buildAssistantSystemPrompt(null), contains('بالعربية'));
      expect(assistantGreeting(''), startsWith('أهلًا بك!'));
      expect(CoachAiService.buildSystemPrompt(CoachDomain.goals), contains('الأهداف والتخطيط'));

      AppLocale.choice.value = AppLanguage.en;
      expect(AiService.exerciseAnalysisPrompt, contains('in English'));
      expect(AiService.exerciseAnalysisPrompt, isNot(contains(_arabicLetter)));
      final prompt = buildAssistantSystemPrompt(null);
      expect(prompt, contains('Answer in clear English'));
      expect(prompt, isNot(contains(_arabicLetter)));
      expect(assistantGreeting('Sam'), startsWith('Welcome, Sam!'));
      final coach = CoachAiService.buildSystemPrompt(CoachDomain.goals, lang: 'en');
      expect(coach, contains('Goals & planning'));
      expect(coach, contains(CoachAiService.crisisSentinel));
      expect(coach, isNot(contains(_arabicLetter)));
    });

    test('English advice in a coach reply is caught like Arabic advice', () {
      expect(containsAdviceLanguage('You should write it down.'), isTrue);
      expect(containsAdviceLanguage('I suggest a short walk.'), isTrue);
      expect(containsAdviceLanguage('What would change if you wrote it down?'), isFalse);
      expect(containsAdviceLanguage('ما الذي سيتغير لو كتبته؟'), isFalse);
    });
  });

  group('choosing the language', () {
    test('the phone language decides only when the user has not chosen', () {
      expect(AppLocale.resolve(AppLanguage.ar, const Locale('en')), AppLocale.arabic);
      expect(AppLocale.resolve(AppLanguage.en, const Locale('ar')), AppLocale.english);
      expect(AppLocale.resolve(AppLanguage.system, const Locale('ar', 'SA')), AppLocale.arabic);
      expect(AppLocale.resolve(AppLanguage.system, const Locale('fr')), AppLocale.english,
          reason: 'a phone in any other language gets English');
      expect(AppLocale.resolve(AppLanguage.system, const Locale('en', 'US')), AppLocale.english);
    });

    test('English is on for everyone and the language tile shows in release builds too', () {
      expect(AppLocale.englishReady, isTrue);
      expect(AppLocale.languagePickerVisible, isTrue);
    });

    testWidgets('an English phone opens the app in English unless Arabic was chosen', (tester) async {
      tester.platformDispatcher.localeTestValue = const Locale('en', 'US');
      addTearDown(() => tester.platformDispatcher.localeTestValue = const Locale('ar', 'SA'));
      addTearDown(() => AppLocale.choice.value = AppLanguage.system);
      expect(AppLocale.current, AppLocale.english);
      expect(AppLocale.texts.settingsTitle, 'Settings');
      AppLocale.choice.value = AppLanguage.ar;
      expect(AppLocale.current, AppLocale.arabic);
    });

    test('a missing or unknown saved value means the phone language', () {
      expect(AppLocale.parse(null), AppLanguage.system);
      expect(AppLocale.parse('xx'), AppLanguage.system);
      expect(AppLocale.parse('en'), AppLanguage.en);
    });
  });

  group('the app in two languages', () {
    late TestStorage storage;

    setUp(() async {
      storage = await TestStorage.inMemory();
      AppLocale.choice.value = AppLanguage.system;
    });
    tearDown(() async {
      AppLocale.choice.value = AppLanguage.system;
      await storage.dispose();
    });

    testWidgets('settings can switch to English and back; the choice is saved and the direction follows',
        (tester) async {
      tester.view.physicalSize = const Size(900, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(_app(SettingsScreen(eraser: () async {})));
      await settle(tester);
      expect(find.text('الإعدادات'), findsOneWidget);
      expect(Directionality.of(tester.element(find.byType(Scaffold))), TextDirection.rtl);

      await tester.tap(find.text('اللغة'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('English'));
      await tester.pumpAndSettle();

      expect(AppLocale.choice.value, AppLanguage.en);
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Erase all my data'), findsOneWidget);
      expect(Directionality.of(tester.element(find.byType(Scaffold))), TextDirection.ltr);
      final saved = await tester.runAsync(() async => (await DatabaseService.getInstance()).getAppLanguage());
      expect(saved, 'en');

      await tester.tap(find.text('Language'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('العربية'));
      await tester.pumpAndSettle();
      expect(find.text('الإعدادات'), findsOneWidget);
    });

    testWidgets('the welcome screen speaks English and shows the interests in English', (tester) async {
      AppLocale.choice.value = AppLanguage.en;
      await tester.pumpWidget(_app(OnboardingScreen(onFinished: () {})));
      await settle(tester);
      expect(find.text('Welcome to Eman'), findsOneWidget);

      await tester.tap(find.text('Next'));
      await settle(tester);
      expect(find.text('What matters to you?'), findsOneWidget);
      expect(find.text('Health & fitness'), findsOneWidget);
      expect(find.text('الصحة واللياقة'), findsNothing);
    });

    testWidgets('the tour and its key guide speak English', (tester) async {
      AppLocale.choice.value = AppLanguage.en;
      await tester.pumpWidget(_app(AppTourScreen(mandatory: false, linkOpener: (_) async => true)));
      await settle(tester);
      expect(find.text('Page 1 of 10'), findsOneWidget);
      expect(find.text('A short tour'), findsOneWidget);

      for (var i = 0; i < 8; i++) {
        await tester.tap(find.text('Next'));
        await settle(tester);
      }
      expect(find.text('AI key'), findsOneWidget);
      expect(find.text('Steps with Google Gemini:'), findsOneWidget);
      expect(find.text('Open the keys page'), findsOneWidget);
    });

    testWidgets('goals & tasks speaks English, and a task saved with an Arabic category shows it in English',
        (tester) async {
      await tester.runAsync(() async {
        final db = await DatabaseService.getInstance();
        await db.saveDailyTasks([
          {'id': 't1', 'title': 'Buy bread', 'category': 'شخصي', 'done': false},
        ]);
      });
      AppLocale.choice.value = AppLanguage.en;
      await tester.pumpWidget(_app(const GoalsTasksScreen()));
      await settle(tester);

      expect(find.text('Daily tasks'), findsOneWidget);
      expect(find.text('Buy bread'), findsOneWidget);
      expect(find.text('Personal'), findsOneWidget);
      expect(find.text('شخصي'), findsNothing);

      await tester.tap(find.text('Quran reading'));
      await tester.pumpAndSettle();
      expect(find.text('Left to finish: 604 pages'), findsOneWidget);
    });

    testWidgets('the kitchen speaks English, and sections, days and sources saved in Arabic show in English',
        (tester) async {
      tester.view.physicalSize = const Size(900, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.runAsync(() async {
        final db = await DatabaseService.getInstance();
        await db.saveRecipes([
          {
            'id': 'r1',
            'title': 'Dough',
            'category': 'فطور',
            'servings': 4,
            'ingredients': [
              {'name': 'Flour', 'amount': 2.0, 'unit': 'cup'},
            ],
            'steps': ['Knead'],
          },
        ]);
        await db.savePantry([
          {'id': 'p1', 'name': 'Lentils', 'qty': '1 kg', 'category': 'الحبوب والبقوليات'},
        ]);
        await db.saveShopping([
          {'id': 's1', 'name': 'Milk', 'qty': '', 'done': false, 'source': 'نفد من المؤونة'},
        ]);
        await db.saveLaundrySchedule([
          {'id': 'l1', 'day': 'السبت', 'type': 'Whites', 'care': ''},
        ]);
      });
      AppLocale.choice.value = AppLanguage.en;
      await tester.pumpWidget(_app(const KitchenHomeScreen()));
      await settle(tester);

      expect(find.widgetWithText(Tab, 'Recipes'), findsOneWidget);
      expect(find.text('Dough'), findsOneWidget);
      expect(find.text('Breakfast'), findsOneWidget);
      expect(find.text('4 servings · 1 ingredient · 1 step'), findsOneWidget);
      expect(find.text('فطور'), findsNothing);

      await tester.tap(find.widgetWithText(Tab, 'Pantry & supplies'));
      await settle(tester);
      expect(find.text('Lentils'), findsOneWidget);
      expect(find.text('Grains & legumes'), findsWidgets);
      expect(find.text('الحبوب والبقوليات'), findsNothing);

      await tester.tap(find.byTooltip('Add item'));
      await tester.pumpAndSettle();
      expect(find.text('Other'), findsOneWidget, reason: 'a new item starts in "Other", shown in English');
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(Tab, 'Shopping'));
      await settle(tester);
      expect(find.text('From: Ran out in the pantry'), findsOneWidget);

      await tester.tap(find.widgetWithText(Tab, 'Laundry'));
      await settle(tester);
      expect(find.text('Saturday: Whites'), findsOneWidget);
    });

    testWidgets('the budget tab speaks English, with the currency code instead of the Arabic symbol', (tester) async {
      tester.view.physicalSize = const Size(900, 3200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await (await BudgetPlanService.getInstance()).save(const BudgetPlan(income: 9000, payday: 27));
      await (await BudgetService.getInstance())
          .addExpense(amount: 40, category: ExpenseCategory.food, date: DateTime(2026, 10, 12));
      AppLocale.choice.value = AppLanguage.en;
      await tester.pumpWidget(_app(FinancialScreen(now: () => DateTime(2026, 10, 18))));
      await settle(tester);

      expect(find.text("This cycle's budget"), findsOneWidget);
      expect(find.text('9 days left'), findsOneWidget);
      expect(find.text('27 September to 26 October'), findsOneWidget);
      expect(tester.widget<Text>(find.byKey(const Key('income_value'))).data, '9,000 SAR');
      expect(find.text('Food'), findsWidgets);
      expect(find.textContaining('ر.س'), findsNothing);

      await tester.tap(find.byTooltip('My monthly expenses'));
      await settle(tester);
      expect(find.text('October 2026'), findsOneWidget);
      expect(find.text('Breakdown by category'), findsOneWidget);
    });

    testWidgets('the AI provider screen speaks English, with the labels the key guide quotes', (tester) async {
      tester.view.physicalSize = const Size(900, 3200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      AppLocale.choice.value = AppLanguage.en;
      await tester.pumpWidget(_app(const AiProviderScreen()));
      await settle(tester);

      expect(find.text('AI provider'), findsWidgets);
      // دليل المفتاح بالإنجليزية يقول: «Key» ثم «Save and activate».
      expect(find.text('Key'), findsOneWidget);
      expect(find.text('Save and activate'), findsOneWidget);
      expect(find.textContaining(_arabicLetter), findsNothing);
    });

    test('AI failure messages and the custom provider follow the app language', () {
      expect(AiFailure.network.message, contains('الإنترنت'));
      expect(AiPresets.byId(AiPresets.customId).displayLabel, 'مخصص (متوافق مع OpenAI)');
      AppLocale.choice.value = AppLanguage.en;
      expect(AiFailure.network.message, "Couldn't connect to the internet. Check your connection, then try again.");
      expect(AiService.missingKeyMessage, 'Set up the AI provider and its key in Settings first.');
      expect(AiPresets.byId(AiPresets.customId).displayLabel, 'Custom (OpenAI-compatible)');
      expect(AiPresets.byId(AiPresets.geminiId).displayLabel, AiPresets.byId(AiPresets.geminiId).label);
    });

    testWidgets('usage awareness speaks English; social apps have English names', (tester) async {
      AppLocale.choice.value = AppLanguage.en;
      await tester.pumpWidget(_app(const UsageAwarenessScreen()));
      await settle(tester);
      expect(find.text('Usage awareness'), findsOneWidget);
      expect(find.textContaining(_arabicLetter), findsNothing);
      for (final app in socialApps) {
        expect(app.nameFor('en'), isNot(contains(_arabicLetter)));
        expect(app.nameFor('ar'), app.arabicName);
      }
    });

    testWidgets('the assistant greeting follows a language change while no chat has started', (tester) async {
      await tester.pumpWidget(_app(const AIAssistantScreen()));
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 300)));
      await settle(tester);
      expect(find.textContaining('أهلًا بك!'), findsOneWidget);

      AppLocale.choice.value = AppLanguage.en;
      await settle(tester);
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 300)));
      await settle(tester);
      expect(find.textContaining('Welcome!'), findsOneWidget);
      expect(find.textContaining('أهلًا بك!'), findsNothing);
    });

    testWidgets('the coach tools speak English, with no Arabic left on screen', (tester) async {
      tester.view.physicalSize = const Size(900, 4200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      AppLocale.choice.value = AppLanguage.en;
      await tester.pumpWidget(_app(const CoachToolsScreen()));
      await settle(tester);
      expect(find.text('Coach tools'), findsOneWidget);
      expect(find.textContaining(_arabicLetter), findsNothing);

      await tester.runAsync(CoachSessionService.getInstance);
      await tester.pumpWidget(_app(const WheelOfLifeScreen()));
      await settle(tester);
      expect(find.text('Save the wheel'), findsOneWidget);
      expect(find.textContaining(_arabicLetter), findsNothing);

      await tester.pumpWidget(_app(const EmotionCheckinScreen()));
      await settle(tester);
      expect(find.text('Which feeling is closest right now?'), findsOneWidget);
      expect(find.textContaining(_arabicLetter), findsNothing);

      for (final screen in const [BeliefCheckScreen(), InnerVoiceScreen(), DecisionScreen(), HabitChangeScreen()]) {
        await tester.pumpWidget(_app(screen));
        await settle(tester);
        expect(find.textContaining(_arabicLetter), findsNothing, reason: '${screen.runtimeType}');
      }
    });

    testWidgets('the main tabs and the coach button speak the chosen language', (tester) async {
      AppLocale.choice.value = AppLanguage.en;
      await tester.pumpWidget(_app(const MainNavigationScreen()));
      await settle(tester);

      expect(find.text('Goals & tasks'), findsOneWidget);
      expect(find.text('Assistant'), findsOneWidget);
      expect(find.byTooltip('Life coach'), findsOneWidget);
    });
  });
}
