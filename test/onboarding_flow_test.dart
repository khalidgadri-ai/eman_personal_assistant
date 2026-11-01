import 'package:eman_life_app/core/app_events.dart';
import 'package:eman_life_app/core/services/database_service.dart';
import 'package:eman_life_app/core/services/profile_service.dart';
import 'package:eman_life_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'helpers/seed_phrases.dart';
import 'helpers/test_storage.dart';

void main() {
  late TestStorage storage;

  setUp(() async {
    storage = await TestStorage.inMemory();
  });
  tearDown(() => storage.dispose());

  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  Future<void> launch(WidgetTester tester) async {
    await tester.pumpWidget(const EmanLifeApp());
    await settle(tester);
  }

  Future<void> finishOnboarding(WidgetTester tester, {String name = 'نورة'}) async {
    await tester.enterText(find.byKey(const ValueKey('onboarding_name')), name);
    await tester.tap(find.text('التالي'));
    await settle(tester);
    await tester.tap(find.text('ابدأ'));
    await settle(tester);
  }

  testWidgets('first launch shows the welcome screen instead of the app', (tester) async {
    await launch(tester);

    expect(find.text('أهلًا بك في إيمان'), findsOneWidget);
    expect(find.byType(BottomNavigationBar), findsNothing);
  });

  testWidgets('name, then interests and goals, then the app opens and the profile is saved', (tester) async {
    await launch(tester);

    await tester.enterText(find.byKey(const ValueKey('onboarding_name')), '  نورة  ');
    await tester.tap(find.text('التالي'));
    await settle(tester);

    expect(find.text('ما الذي يهمّك؟'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilterChip, 'القراءة'));
    await tester.pump();
    await tester.enterText(find.byKey(const ValueKey('onboarding_goal')), 'إنهاء كتاب');
    await tester.tap(find.byTooltip('إضافة هدف'));
    await tester.pump();
    expect(find.widgetWithText(InputChip, 'إنهاء كتاب'), findsOneWidget);

    await tester.tap(find.text('ابدأ'));
    await settle(tester);

    expect(find.byType(BottomNavigationBar), findsOneWidget);
    final profile = (await ProfileService.getInstance()).profile!;
    expect(profile.name, 'نورة');
    expect(profile.interests, ['القراءة']);
    expect(profile.goals, ['إنهاء كتاب']);
    // الهدف الذي كتبه يظهر في تبويب الأهداف (بيانات المستخدم لا بيانات جاهزة).
    final goals = (await DatabaseService.getInstance()).getGoals();
    expect(goals.single['title'], 'إنهاء كتاب');
    expect(goals.single['progress'], 0.0);
  });

  testWidgets('a goal typed but not added with + is not lost', (tester) async {
    await launch(tester);
    await tester.tap(find.text('التالي'));
    await settle(tester);

    await tester.enterText(find.byKey(const ValueKey('onboarding_goal')), 'هدف بلا زر');
    await tester.tap(find.text('ابدأ'));
    await settle(tester);

    expect((await ProfileService.getInstance()).profile!.goals, ['هدف بلا زر']);
  });

  testWidgets('"back" returns to the name step and keeps what was typed', (tester) async {
    await launch(tester);
    await tester.enterText(find.byKey(const ValueKey('onboarding_name')), 'ليلى');
    await tester.tap(find.text('التالي'));
    await settle(tester);

    await tester.tap(find.text('رجوع'));
    await settle(tester);

    final field = tester.widget<TextField>(find.byKey(const ValueKey('onboarding_name')));
    expect(field.controller!.text, 'ليلى');
  });

  testWidgets('skip opens the app with an empty profile, and the welcome never comes back', (tester) async {
    await launch(tester);

    await tester.tap(find.text('تخطي'));
    await settle(tester);

    expect(find.byType(BottomNavigationBar), findsOneWidget);
    final service = await ProfileService.getInstance();
    expect(service.onboarded, isTrue);
    expect(service.profile!.isEmpty, isTrue);
    expect((await DatabaseService.getInstance()).getGoals(), isEmpty);

    // إعادة تشغيل التطبيق: لا ترحيب.
    await tester.pumpWidget(const SizedBox());
    await launch(tester);
    expect(find.text('أهلًا بك في إيمان'), findsNothing);
    expect(find.byType(BottomNavigationBar), findsOneWidget);
  });

  testWidgets('a name made of emoji and a very long name are handled', (tester) async {
    await launch(tester);

    await finishOnboarding(tester, name: '😀' * 80);

    final name = (await ProfileService.getInstance()).profile!.name;
    expect(name.runes.length, lessThanOrEqualTo(UserProfile.maxNameLength));
    expect(find.byType(BottomNavigationBar), findsOneWidget);
  });

  testWidgets('a new user sees none of the former demo data on any screen', (tester) async {
    await launch(tester);
    await tester.tap(find.text('تخطي'));
    await settle(tester);

    final seen = <String>{};
    void collect() {
      for (final text in tester.widgetList<Text>(find.byType(Text))) {
        final value = text.data ?? text.textSpan?.toPlainText();
        if (value != null) seen.add(value);
      }
    }

    Future<void> visit(String bottomLabel, [List<String> innerTabs = const []]) async {
      await tester.tap(find.text(bottomLabel));
      await settle(tester);
      collect();
      for (final inner in innerTabs) {
        await tester.tap(find.text(inner));
        await settle(tester);
        collect();
      }
    }

    await visit('الأهداف والمهام', ['الأهداف الهرمية', 'الورد والتتبع']);
    await visit('الصحة واللياقة', ['جدول الأدوية', 'العناية بالبشرة']);
    await visit('المطبخ والمنازل', ['المؤونة والمستلزمات', 'جدول الغسيل']);
    await visit('الميزانية');
    await visit('المساعد الذكي');

    for (final phrase in [...kFormerSeedPhrases, ...kFormerDemoAmounts]) {
      expect(seen.where((s) => s.contains(phrase)), isEmpty, reason: '"$phrase" must not be shown');
    }
    // وبدلها رسائل الحالة الفارغة.
    expect(seen, containsAll(<String>[
      'لا توجد مهام بعد. اضغط + لإضافة مهمة أو استخدم المذكرة الصوتية.',
      'لا توجد أهداف بعد. اضغط + لإضافة هدفك الأول.',
      'الصفحة الحالية: 0',
      'لم تُضف أدوية أو مكملات بعد. اضغط + للإضافة.',
      'لم تُضف منتجات بعد. اضغط + للإضافة.',
      'المؤونة فارغة. اضغط + لإضافة أول صنف.',
      'لا توجد مواعيد غسيل بعد. اضغط + لإضافة موعد.',
    ]));
  });

  testWidgets('the assistant greets by the name the user typed, and by nothing else', (tester) async {
    await launch(tester);
    await finishOnboarding(tester, name: 'نورة');

    await tester.tap(find.text('المساعد الذكي'));
    await settle(tester);

    expect(find.textContaining('أهلًا بك يا نورة!'), findsOneWidget);
  });

  testWidgets('the profile can be edited from settings', (tester) async {
    await launch(tester);
    await finishOnboarding(tester, name: 'نورة');

    await tester.tap(find.byTooltip('الإعدادات'));
    await settle(tester);
    expect(find.text('نورة'), findsOneWidget);

    await tester.tap(find.text('تعديل ملفي'));
    await settle(tester);
    final field = tester.widget<TextField>(find.byKey(const ValueKey('onboarding_name')));
    expect(field.controller!.text, 'نورة');
    await tester.enterText(find.byKey(const ValueKey('onboarding_name')), 'ليلى');
    await tester.tap(find.text('التالي'));
    await settle(tester);
    await tester.tap(find.text('حفظ'));
    await settle(tester);

    expect(find.text('ليلى'), findsOneWidget);
    expect((await ProfileService.getInstance()).profile!.name, 'ليلى');
  });

  testWidgets('after "erase all my data" the welcome screen comes back', (tester) async {
    await launch(tester);
    await tester.tap(find.text('تخطي'));
    await settle(tester);
    expect(find.byType(BottomNavigationBar), findsOneWidget);

    // نحاكي نتيجة المسح (الملف الشخصي اختفى) ثم الإشارة التي يرسلها المسح الحقيقي.
    await Hive.box('profile_enc').clear();
    AppEvents.dataErased.value++;
    await settle(tester);

    expect(find.text('أهلًا بك في إيمان'), findsOneWidget);
    expect(find.byType(BottomNavigationBar), findsNothing);
  });
}
