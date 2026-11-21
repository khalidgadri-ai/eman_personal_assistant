import 'dart:convert';
import 'dart:io';

import 'package:eman_life_app/core/config/app_locale.dart';
import 'package:eman_life_app/core/services/database_service.dart';
import 'package:eman_life_app/core/theme/app_theme.dart';
import 'package:eman_life_app/features/goals_and_tasks/goals_tasks_screen.dart';
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
        locale: AppLocale.resolve(choice, null),
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

  group('choosing the language', () {
    test('the phone language decides only when the user has not chosen', () {
      expect(AppLocale.resolve(AppLanguage.ar, const Locale('en')), AppLocale.arabic);
      expect(AppLocale.resolve(AppLanguage.en, const Locale('ar')), AppLocale.english);
      expect(AppLocale.resolve(AppLanguage.system, const Locale('ar', 'SA')), AppLocale.arabic);
      expect(
        AppLocale.resolve(AppLanguage.system, const Locale('fr')),
        AppLocale.englishReady ? AppLocale.english : AppLocale.arabic,
        reason: 'until every screen is translated a non-Arabic phone still gets Arabic',
      );
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
