import 'dart:convert';
import 'dart:io';

import 'package:eman_life_app/core/config/app_locale.dart';
import 'package:eman_life_app/core/services/database_service.dart';
import 'package:eman_life_app/core/theme/app_theme.dart';
import 'package:eman_life_app/features/settings/settings_screen.dart';
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
