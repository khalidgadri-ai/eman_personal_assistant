import 'package:eman_life_app/core/config/app_locale.dart';
import 'package:eman_life_app/core/services/free_quota_service.dart';
import 'package:eman_life_app/features/coach/coach_ai_service.dart';
import 'package:eman_life_app/features/coach/coach_paywall_screen.dart';
import 'package:eman_life_app/features/coach/coach_safety.dart';
import 'package:eman_life_app/features/coach/coach_screen.dart';
import 'package:eman_life_app/features/coach/coach_session_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'helpers/test_storage.dart';
import 'helpers/widget_helpers.dart';

// الوقت ثابت (يُمرَّر للشاشة): لا يتأثر الاختبار بتغيّر الشهر الحقيقي.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const feature = FreeQuotaService.coachFollowUp;
  const quotaKey = 'free_quota_coach_followup';
  final now = DateTime(2026, 11, 6, 10);
  const modelQuestion = 'ما الذي يجعل هذا الأمر مهمًا لك الآن؟';
  const answer = 'أشعر أنني مشغول طوال الوقت';

  late TestStorage storage;
  var modelCalls = 0;
  var aiAccessCalls = 0;
  var aiConfigured = true;
  late Future<String> Function() modelReply;
  String? country;
  final openedLinks = <Uri>[];

  setUp(() async {
    storage = await TestStorage.inMemory();
    modelCalls = 0;
    aiAccessCalls = 0;
    aiConfigured = true;
    modelReply = () async => modelQuestion;
    country = null;
    openedLinks.clear();
  });
  tearDown(() => storage.dispose());

  Box subscriptionBox() => Hive.box('subscription');

  int freeLeft() => FreeQuotaService.remainingFor(subscriptionBox().get(quotaKey), feature, now);

  Future<void> useUp(WidgetTester tester, [int used = 5]) async {
    await tester.runAsync(() => subscriptionBox().put(quotaKey, {'period': '2026-11', 'used': used}));
  }

  Future<void> makeSubscriber(WidgetTester tester) async {
    await tester.runAsync(
      () => subscriptionBox().put('status', {'active': true, 'lastVerified': DateTime.now()}),
    );
  }

  Future<void> openCoach(WidgetTester tester, {bool english = false}) async {
    // خدمة المدرب تقرأ ملف أسئلة من الأصول: إدخال/إخراج حقيقي يعلّق داخل testWidgets إلا في runAsync.
    await tester.runAsync(CoachSessionService.getInstance);
    tester.view.physicalSize = const Size(900, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final screen = CoachScreen(
        aiService: CoachAiService(generator: ({required systemPrompt, required userContent}) {
          modelCalls++;
          return modelReply();
        }),
        clock: () => now,
        aiAccess: (_) async {
          aiAccessCalls++;
          return aiConfigured;
        },
        countryCode: () => country,
        openLink: (url) async {
          openedLinks.add(url);
          return true;
        },
      );
    if (!english) return pumpScreen(tester, screen);
    await tester.pumpWidget(MaterialApp(
      locale: AppLocale.english,
      supportedLocales: AppLocale.supported,
      localizationsDelegates: AppLocale.delegates,
      home: screen,
    ));
    await settle(tester);
  }

  Future<void> tapDeepen(WidgetTester tester, [String text = answer]) async {
    await tester.enterText(find.byType(TextField), text);
    await tester.pump();
    await tester.tap(find.text('عمّق أكثر'));
    await settle(tester);
  }

  final paywall = find.byType(CoachPaywallScreen);

  testWidgets('in English the coach, its free-uses line and the crisis help speak English', (tester) async {
    AppLocale.choice.value = AppLanguage.en;
    addTearDown(() => AppLocale.choice.value = AppLanguage.system);
    await openCoach(tester, english: true);
    expect(find.text('Life coach'), findsOneWidget);
    expect(find.text('5 of 5 free left this month'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'I feel suicidal');
    await tester.pump();
    await tester.tap(find.text('Go deeper'));
    await settle(tester);

    expect(find.text('Important'), findsOneWidget);
    expect(find.text(crisisResponseMessage), findsOneWidget);
    expect(crisisResponseMessage, startsWith('If you are going through'));
    expect(find.text('In Saudi Arabia (official government lines):'), findsOneWidget);
    expect(find.textContaining('Red Crescent'), findsOneWidget);
    expect(find.text('Find a free helpline in your country'), findsOneWidget);
    expect(modelCalls, 0);
  });

  group('not subscribed, free uses left', () {
    testWidgets('the model question arrives without the paywall and costs one use', (tester) async {
      await openCoach(tester);
      expect(find.text('متبقٍ 5 من 5 مجانًا هذا الشهر'), findsOneWidget);

      await tapDeepen(tester);

      expect(paywall, findsNothing);
      expect(modelCalls, 1);
      expect(find.text(modelQuestion), findsOneWidget);
      expect(freeLeft(), 4);
      expect(find.text('متبقٍ 4 من 5 مجانًا هذا الشهر'), findsOneWidget);
    });

    testWidgets('the last free use is allowed, then the line says they are used up', (tester) async {
      await useUp(tester, 4);
      await openCoach(tester);
      expect(find.text('متبقٍ 1 من 5 مجانًا هذا الشهر'), findsOneWidget);

      await tapDeepen(tester);

      expect(paywall, findsNothing);
      expect(find.text(modelQuestion), findsOneWidget);
      expect(freeLeft(), 0);
      expect(
        find.text('انتهت المحاولات المجانية لهذا الشهر، وتتجدد في 1 ديسمبر'),
        findsOneWidget,
      );
    });

    testWidgets('a question that fell back to the local bank because of an error costs nothing',
        (tester) async {
      modelReply = () async => throw Exception('network down');
      await openCoach(tester);

      await tapDeepen(tester);

      expect(modelCalls, 1);
      expect(paywall, findsNothing);
      expect(find.text(modelQuestion), findsNothing);
      expect(tester.widget<TextField>(find.byType(TextField)).controller!.text, isEmpty,
          reason: 'the screen moved on to the next (bank) question');
      expect(freeLeft(), 5);
      expect(find.text('متبقٍ 5 من 5 مجانًا هذا الشهر'), findsOneWidget);
    });

    testWidgets('a model reply that gives advice is replaced by a bank question and costs nothing',
        (tester) async {
      modelReply = () async => 'جرب أن تكتب مهامك كل صباح';
      await openCoach(tester);

      await tapDeepen(tester);

      expect(modelCalls, 1);
      expect(find.text('جرب أن تكتب مهامك كل صباح'), findsNothing);
      expect(freeLeft(), 5);
    });

    testWidgets('leaving the AI provider screen without saving costs nothing and asks nothing of the model',
        (tester) async {
      aiConfigured = false;
      await openCoach(tester);

      await tapDeepen(tester);

      expect(aiAccessCalls, 1);
      expect(modelCalls, 0);
      expect(paywall, findsNothing);
      expect(find.text(modelQuestion), findsNothing);
      expect(freeLeft(), 5);
      expect(find.byType(CircularProgressIndicator), findsNothing, reason: 'the button is usable again');
    });

    testWidgets('crisis words in the answer: the helpline shows, nothing is sent, nothing is counted',
        (tester) async {
      await openCoach(tester);

      await tapDeepen(tester, 'أفكر في الانتحار');

      expect(find.text('مهم'), findsOneWidget);
      expect(find.text(crisisResponseMessage), findsOneWidget);
      expect(modelCalls, 0);
      expect(aiAccessCalls, 0);
      expect(paywall, findsNothing);
      expect(freeLeft(), 5);
    });

    testWidgets('outside Saudi Arabia the crisis help starts with the local emergency number and a helpline finder',
        (tester) async {
      country = 'EG';
      await openCoach(tester);

      await tapDeepen(tester, 'I feel suicidal');

      final general = tester.getTopLeft(find.text(crisisLocalEmergencyMessage)).dy;
      final saudi = tester.getTopLeft(find.text(crisisHelplinesNote)).dy;
      expect(general, lessThan(saudi), reason: 'Saudi lines are still shown, labelled, but after');
      expect(modelCalls, 0, reason: 'English crisis words are caught too');

      await tester.tap(find.text(crisisHelplineFinderLabel));
      await tester.pump();
      expect(openedLinks, [crisisHelplineFinderUrl]);
    });

    testWidgets('on a Saudi phone the official Saudi lines come first', (tester) async {
      country = 'SA';
      await openCoach(tester);

      await tapDeepen(tester, 'أفكر في الانتحار');

      final general = tester.getTopLeft(find.text(crisisLocalEmergencyMessage)).dy;
      final saudi = tester.getTopLeft(find.text(crisisHelplinesNote)).dy;
      expect(saudi, lessThan(general));
      expect(find.text('937'), findsOneWidget);
    });

    testWidgets('the model answering with the crisis sentinel shows the helpline and costs nothing',
        (tester) async {
      modelReply = () async => CoachAiService.crisisSentinel;
      await openCoach(tester);

      await tapDeepen(tester);

      expect(modelCalls, 1);
      expect(find.text('مهم'), findsOneWidget);
      expect(freeLeft(), 5);
    });

    testWidgets('a crisis answer comes first even when the free uses are used up', (tester) async {
      await useUp(tester);
      await openCoach(tester);

      await tapDeepen(tester, 'أفكر في الانتحار');

      expect(find.text('مهم'), findsOneWidget);
      expect(paywall, findsNothing);
      expect(modelCalls, 0);
    });
  });

  group('not subscribed, free uses used up', () {
    testWidgets('the paywall opens with the offer and the renewal date, and nothing goes to the model',
        (tester) async {
      await useUp(tester);
      await openCoach(tester);
      expect(
        find.text('انتهت المحاولات المجانية لهذا الشهر، وتتجدد في 1 ديسمبر'),
        findsOneWidget,
      );

      await tapDeepen(tester);

      expect(paywall, findsOneWidget);
      expect(find.text('تحصل مجانًا على 5 أسئلة متابعة كل شهر. الاشتراك يجعلها بلا حد.'), findsOneWidget);
      expect(find.text('تتجدد محاولاتك المجانية في 1 ديسمبر'), findsOneWidget);
      expect(modelCalls, 0);
      expect(aiAccessCalls, 0);
      expect(freeLeft(), 0);
    });

    testWidgets('going back from the paywall without subscribing changes nothing', (tester) async {
      await useUp(tester);
      await openCoach(tester);
      await tapDeepen(tester);

      Navigator.of(tester.element(paywall)).pop();
      await settle(tester);

      expect(paywall, findsNothing);
      expect(modelCalls, 0);
      expect(find.text(modelQuestion), findsNothing);
      expect(freeLeft(), 0);
    });

    testWidgets('a new month brings the free uses back', (tester) async {
      await tester.runAsync(() => subscriptionBox().put(quotaKey, {'period': '2026-10', 'used': 5}));
      await openCoach(tester);

      expect(find.text('متبقٍ 5 من 5 مجانًا هذا الشهر'), findsOneWidget);
      await tapDeepen(tester);

      expect(paywall, findsNothing);
      expect(find.text(modelQuestion), findsOneWidget);
    });

    testWidgets('a corrupt stored count is treated as used up', (tester) async {
      await tester.runAsync(() => subscriptionBox().put(quotaKey, 'oops'));
      await openCoach(tester);

      await tapDeepen(tester);

      expect(paywall, findsOneWidget);
      expect(modelCalls, 0);
    });
  });

  group('subscribed', () {
    testWidgets('no "remaining" line, no counting, and the question arrives', (tester) async {
      await makeSubscriber(tester);
      await openCoach(tester);
      expect(find.textContaining('متبقٍ'), findsNothing);
      expect(find.textContaining('المحاولات المجانية'), findsNothing);

      await tapDeepen(tester);

      expect(paywall, findsNothing);
      expect(find.text(modelQuestion), findsOneWidget);
      expect(subscriptionBox().get(quotaKey), isNull, reason: 'a subscriber never touches the counter');
      expect(find.textContaining('متبقٍ'), findsNothing);
    });

    testWidgets('unlimited: used-up free uses do not matter', (tester) async {
      await makeSubscriber(tester);
      await useUp(tester);
      await openCoach(tester);

      await tapDeepen(tester);

      expect(paywall, findsNothing);
      expect(find.text(modelQuestion), findsOneWidget);
      expect(freeLeft(), 0, reason: 'the stored count is left as it was');
    });
  });

  group('paywall screen on its own', () {
    testWidgets('shows the offer line but no renewal date when not opened because of the limit',
        (tester) async {
      await pumpScreen(tester, const CoachPaywallScreen());

      expect(find.text('تحصل مجانًا على 5 أسئلة متابعة كل شهر. الاشتراك يجعلها بلا حد.'), findsOneWidget);
      expect(find.textContaining('تتجدد محاولاتك'), findsNothing);
      expect(find.textContaining('الأسئلة المحلية'), findsOneWidget, reason: 'the free-forever sentence stays');
      expect(find.textContaining('الإلغاء في أي وقت'), findsOneWidget, reason: 'the Google Play cancel sentence stays');
    });

    testWidgets('the renewal date rolls over to January', (tester) async {
      await pumpScreen(tester, CoachPaywallScreen(quotaExhaustedAt: DateTime(2026, 12, 20)));

      expect(find.text('تتجدد محاولاتك المجانية في 1 يناير'), findsOneWidget);
    });
  });
}
