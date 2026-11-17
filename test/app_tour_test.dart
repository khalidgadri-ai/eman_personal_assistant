import 'package:eman_life_app/core/ai/provider_presets.dart';
import 'package:eman_life_app/core/app_events.dart';
import 'package:eman_life_app/core/services/database_service.dart';
import 'package:eman_life_app/core/services/profile_service.dart';
import 'package:eman_life_app/core/theme/app_theme.dart';
import 'package:eman_life_app/core/widgets/ai_provider_screen.dart';
import 'package:eman_life_app/features/onboarding/app_tour_screen.dart';
import 'package:eman_life_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'helpers/test_storage.dart';
import 'helpers/widget_helpers.dart';

void main() {
  late TestStorage storage;

  tearDown(() => storage.dispose());

  Future<void> launch(WidgetTester tester) async {
    await tester.pumpWidget(const EmanLifeApp());
    await settle(tester);
  }

  Future<void> saveExistingProfile() async {
    await (await ProfileService.getInstance()).save(const UserProfile(name: 'سارة'));
  }

  Finder pageLabel(int page) => find.text('صفحة $page من ${AppTourScreen.pageCount}');

  Future<void> tapNext(WidgetTester tester, {int times = 1}) async {
    for (var i = 0; i < times; i++) {
      await tester.tap(find.widgetWithText(ElevatedButton, 'التالي'));
      await tester.pump();
    }
  }

  /// يمرّ بالصفحات العشر كلها ثم يضغط زر النهاية.
  Future<void> completeTour(WidgetTester tester) async {
    for (var page = 1; page < AppTourScreen.pageCount; page++) {
      expect(pageLabel(page), findsOneWidget);
      expect(find.byType(BottomNavigationBar), findsNothing);
      await tapNext(tester);
    }
    expect(pageLabel(AppTourScreen.pageCount), findsOneWidget);
    await tester.tap(find.text('ابدأ استعمال التطبيق'));
    await settle(tester);
  }

  group('the gate', () {
    setUp(() async => storage = await TestStorage.inMemory());

    testWidgets('a new user goes welcome, then all ten tour pages, then the app', (tester) async {
      await launch(tester);
      await tester.enterText(find.byKey(const ValueKey('onboarding_name')), 'نورة');
      await tester.tap(find.text('التالي'));
      await settle(tester);
      await tester.tap(find.text('ابدأ'));
      await settle(tester);

      expect(AppTourScreen.pageCount, 10);
      await completeTour(tester);

      expect(find.byType(BottomNavigationBar), findsOneWidget);
      expect((await DatabaseService.getInstance()).getAppTourVersion(), AppTour.version);
    });

    testWidgets('"skip" on the welcome screen still leads to the tour', (tester) async {
      await launch(tester);
      await tester.tap(find.text('تخطي'));
      await settle(tester);

      expect(pageLabel(1), findsOneWidget);
      expect(find.byType(BottomNavigationBar), findsNothing);
    });

    testWidgets('an existing user sees the tour once after the update, then never again', (tester) async {
      await saveExistingProfile();
      await launch(tester);
      expect(pageLabel(1), findsOneWidget);

      await completeTour(tester);
      expect(find.byType(BottomNavigationBar), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await launch(tester);
      expect(find.byType(AppTourScreen), findsNothing);
      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });

    testWidgets('a stored version equal to or above the current one opens the app directly', (tester) async {
      await saveExistingProfile();
      await (await DatabaseService.getInstance()).saveAppTourVersion(AppTour.version + 1);
      await launch(tester);

      expect(find.byType(AppTourScreen), findsNothing);
      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });

    testWidgets('if the tour state cannot be read the app opens directly', (tester) async {
      await saveExistingProfile();
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.darkTheme,
        home: AppGate(readTourVersion: () async => throw StateError('storage unavailable')),
      ));
      await settle(tester);

      expect(find.byType(AppTourScreen), findsNothing);
      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });

    testWidgets('after "erase all my data" the welcome comes back, then the tour', (tester) async {
      await saveExistingProfile();
      await launch(tester);
      await completeTour(tester);
      expect(find.byType(BottomNavigationBar), findsOneWidget);

      // نتيجة المسح الحقيقي: الملف الشخصي وSharedPreferences فارغان، ثم الإشارة.
      await Hive.box('profile_enc').clear();
      await (await DatabaseService.getInstance()).eraseAll();
      AppEvents.dataErased.value++;
      await settle(tester);
      expect(find.text('أهلًا بك في إيمان'), findsOneWidget);

      await tester.tap(find.text('تخطي'));
      await settle(tester);
      expect(pageLabel(1), findsOneWidget);
    });
  });

  group('the tour screen', () {
    setUp(() async => storage = await TestStorage.inMemory());

    testWidgets('the mandatory tour has no skip and no close, and "back" is off on page one', (tester) async {
      await pumpScreen(tester, const AppTourScreen(mandatory: true));

      expect(find.text('تخطي'), findsNothing);
      expect(find.byTooltip('إغلاق'), findsNothing);
      final back = tester.widget<TextButton>(find.widgetWithText(TextButton, 'رجوع'));
      expect(back.onPressed, isNull);

      await tapNext(tester);
      expect(pageLabel(2), findsOneWidget);
      await tester.tap(find.widgetWithText(TextButton, 'رجوع'));
      await tester.pump();
      expect(pageLabel(1), findsOneWidget);
    });

    testWidgets('from settings it has a close button and the last page closes it', (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.darkTheme,
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const AppTourScreen(mandatory: false)),
            ),
            child: const Text('open'),
          ),
        ),
      ));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.byTooltip('إغلاق'), findsOneWidget);
      await tester.tap(find.byTooltip('إغلاق'));
      await tester.pumpAndSettle();
      expect(find.byType(AppTourScreen), findsNothing);

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tapNext(tester, times: AppTourScreen.pageCount - 1);
      await tester.tap(find.text('إنهاء'));
      await tester.pumpAndSettle();
      expect(find.byType(AppTourScreen), findsNothing);
      // من الإعدادات لا يتغير الرقم المحفوظ.
      expect((await DatabaseService.getInstance()).getAppTourVersion(), 0);
    });

    testWidgets('"I will add it later" moves on without opening the provider screen', (tester) async {
      var opened = 0;
      await pumpScreen(
        tester,
        AppTourScreen(
          mandatory: true,
          addKey: (_) async {
            opened++;
            return true;
          },
        ),
      );
      await tapNext(tester, times: 8);
      expect(pageLabel(9), findsOneWidget);

      await tester.ensureVisible(find.text('سأضيفه لاحقًا'));
      await tester.tap(find.text('سأضيفه لاحقًا'));
      await tester.pump();

      expect(pageLabel(10), findsOneWidget);
      expect(opened, 0);
      expect(find.byType(AiProviderScreen), findsNothing);
    });

    testWidgets('"add the key now" moves on once a key is saved', (tester) async {
      await pumpScreen(tester, AppTourScreen(mandatory: true, addKey: (_) async => true));
      await tapNext(tester, times: 8);

      await tester.ensureVisible(find.text('أضف المفتاح الآن'));
      await tester.tap(find.text('أضف المفتاح الآن'));
      await tester.pump();
      await tester.pump();

      expect(find.text('✓ تم حفظ المفتاح'), findsOneWidget);
      expect(pageLabel(10), findsOneWidget);
    });

    testWidgets('"add the key now" stays on the page if nothing was saved', (tester) async {
      await pumpScreen(tester, AppTourScreen(mandatory: true, addKey: (_) async => false));
      await tapNext(tester, times: 8);

      await tester.ensureVisible(find.text('أضف المفتاح الآن'));
      await tester.tap(find.text('أضف المفتاح الآن'));
      await tester.pump();

      expect(pageLabel(9), findsOneWidget);
    });

    for (final failure in ['returns false', 'throws']) {
      testWidgets('when opening the key page $failure, the link is copied', (tester) async {
        String? copied;
        tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'Clipboard.setData') {
            copied = (call.arguments as Map)['text'] as String?;
          }
          return null;
        });
        addTearDown(() => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, null));

        await pumpScreen(
          tester,
          AppTourScreen(
            mandatory: true,
            linkOpener: (_) async => failure == 'throws' ? throw StateError('no browser') : false,
          ),
        );
        await tapNext(tester, times: 8);

        await tester.ensureVisible(find.text('افتح صفحة المفاتيح'));
        await tester.tap(find.text('افتح صفحة المفاتيح'));
        await tester.pump();
        await tester.pump();

        expect(copied, AiPresets.byId(AiPresets.geminiId).keyUrl);
        expect(find.text('تم نسخ الرابط. الصقه في المتصفح.'), findsOneWidget);
      });
    }

    testWidgets('an opened key page shows no message and copies nothing', (tester) async {
      Uri? openedUri;
      await pumpScreen(
        tester,
        AppTourScreen(
          mandatory: true,
          linkOpener: (uri) async {
            openedUri = uri;
            return true;
          },
        ),
      );
      await tapNext(tester, times: 8);
      await tester.ensureVisible(find.text('افتح صفحة المفاتيح'));
      await tester.tap(find.text('افتح صفحة المفاتيح'));
      await tester.pump();

      expect(openedUri.toString(), AiPresets.byId(AiPresets.geminiId).keyUrl);
      expect(find.text('تم نسخ الرابط. الصقه في المتصفح.'), findsNothing);
    });
  });

  group('the provider screen', () {
    setUp(() async => storage = await TestStorage.inMemory());

    testWidgets('"how do I get a key?" shows for Gemini and not for a custom provider', (tester) async {
      await pumpScreen(tester, const AiProviderScreen());
      expect(find.text('كيف أحصل على مفتاح؟'), findsOneWidget);

      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AiPresets.byId(AiPresets.customId).label).last);
      await tester.pumpAndSettle();

      expect(find.text('كيف أحصل على مفتاح؟'), findsNothing);
    });

    testWidgets('the guide opens for the selected provider', (tester) async {
      await pumpScreen(tester, const AiProviderScreen());
      await tester.tap(find.text('كيف أحصل على مفتاح؟'));
      await tester.pumpAndSettle();

      expect(find.text('الخطوات مع ${AiPresets.byId(AiPresets.geminiId).label}:'), findsOneWidget);
      expect(find.text('لا تشارك مفتاحك مع أحد ولا تنشره. يُحفظ على جوالك فقط.'), findsOneWidget);
    });
  });
}
