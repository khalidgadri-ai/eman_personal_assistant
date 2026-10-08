import 'dart:convert';
import 'dart:io';

import 'package:eman_life_app/features/coach/coach_ai_service.dart';
import 'package:eman_life_app/features/coach/coach_safety.dart';
import 'package:eman_life_app/features/coach/coach_session_service.dart';
import 'package:eman_life_app/features/coach/models/coach_question.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('containsCrisisSignals', () {
    test('detects explicit Arabic phrasing', () {
      expect(containsCrisisSignals('والله تعبت وأفكر في الانتحار'), isTrue);
    });

    test('detects Gulf colloquial phrasing with hamza variants', () {
      expect(containsCrisisSignals('صراحة ودي أختفي من كل شي'), isTrue);
      expect(containsCrisisSignals('أبغى أموت وأرتاح'), isTrue);
    });

    test('detects English phrasing regardless of case', () {
      expect(containsCrisisSignals('Sometimes I want to DIE'), isTrue);
    });

    test('ignores diacritics and tatweel', () {
      expect(containsCrisisSignals('أُفَكِّرُ فِي الِانْتِحَار'), isTrue);
      expect(containsCrisisSignals('انتحـــار'), isTrue);
    });

    test('does not flag an ordinary reflective answer', () {
      expect(containsCrisisSignals('كان يوم متعب في الشغل بس مرّ على خير'), isFalse);
    });

    test('does not flag empty input', () {
      expect(containsCrisisSignals('   '), isFalse);
    });
  });

  group('containsAdviceLanguage', () {
    void expectAll(List<String> texts, Matcher matcher) {
      for (final text in texts) {
        expect(containsAdviceLanguage(text), matcher, reason: text);
      }
    }

    test('flags the direct-advice phrases from the spec', () {
      expectAll([
        'يُنصح بأن تنام مبكرًا',
        'يجب عليك أن تتكلم معه',
        'الحل هو أن تبدأ من جديد',
        'جرّب أن تكتب أفكارك كل يوم',
        'أقترح عليك تقسيم المهمة',
      ], isTrue);
    });

    test('flags conjunction prefixes and pronoun or feminine suffixes', () {
      expectAll([
        'فالحل بسيط',
        'ويجب أن تهتم بنفسك',
        'أنصحكِ بالراحة',
        'جربي تمشين كل يوم',
      ], isTrue);
    });

    test('flags advice disguised as a question', () {
      expectAll([
        'ألا تعتقد أنه من الأفضل أن تتكلم مع مختص؟',
        'ما رأيك أن تأخذ إجازة؟',
      ], isTrue);
    });

    test('passes genuine reflective questions', () {
      expectAll([
        'وش اللي خلاك تحس بهذا الشعور اليوم؟',
        'لو صديقك قال نفس الكلام، وش بترد عليه؟',
      ], isFalse);
    });

    test('does not reject words that merely contain an advice word', () {
      expectAll([
        'وش الحلم اللي تأجل أكثر شي؟',
        'وش اللي يجبرك تكمل؟',
        'وش جربته هذا الأسبوع ولقيته يشتغل؟',
        'وش الحلول اللي جربتها قبل؟',
      ], isFalse);
    });

    test('no question in the local bank trips either filter', () {
      final List bank = jsonDecode(File('assets/coach_questions.json').readAsStringSync());
      for (final entry in bank) {
        final text = entry['text'] as String;
        expect(containsAdviceLanguage(text), isFalse, reason: text);
        expect(containsCrisisSignals(text), isFalse, reason: text);
      }
    });
  });

  group('CoachAiService.requestFollowUp', () {
    const question = CoachQuestion(
      id: 'emotions_01',
      domain: CoachDomain.emotions,
      text: 'وش بالضبط اسم هذا الشعور؟',
    );
    late Directory hiveDir;

    setUp(() {
      hiveDir = Directory.systemTemp.createTempSync('coach_hive_test');
      Hive.init(hiveDir.path);
      CoachSessionService.resetForTesting();
    });

    tearDown(() async {
      await Hive.deleteFromDisk();
      CoachSessionService.resetForTesting();
      hiveDir.deleteSync(recursive: true);
    });

    CoachAiService serviceReturning(Future<String> Function() reply) {
      return CoachAiService(
        generator: ({required systemPrompt, required userContent}) => reply(),
      );
    }

    test('never calls the model when the answer contains crisis signals', () async {
      var calls = 0;
      final service = serviceReturning(() async {
        calls++;
        return 'وش أول مرة لاحظت هذا؟';
      });

      final result = await service.requestFollowUp(
        question: question,
        answer: 'ودي أختفي من كل شي',
      );

      expect(result, isA<CrisisDetected>());
      expect(calls, 0);
    });

    test('sends the strict Socratic system prompt with the domain filled in', () async {
      String? sentPrompt;
      final service = CoachAiService(
        generator: ({required systemPrompt, required userContent}) async {
          sentPrompt = systemPrompt;
          return 'وش أول مرة لاحظت هذا الشعور؟';
        },
      );

      await service.requestFollowUp(question: question, answer: 'حاسس بضيق');

      expect(sentPrompt, contains('ممنوع تمامًا: تقديم نصيحة مباشرة'));
      expect(sentPrompt, contains('ضمن نفس مجال المشاعر'));
      expect(sentPrompt, contains('لا ترد بأي شيء غير السؤال نفسه'));
      expect(sentPrompt, contains('حتى لو لم تتطابق مع كلمة مفتاحية واضحة'));
      expect(sentPrompt, endsWith('ولا شيء غيرها: CRISIS_DETECTED'));
    });

    test('treats the model crisis sentinel as a crisis, not a question', () async {
      for (final reply in ['CRISIS_DETECTED', '  CRISIS_DETECTED\n', '`CRISIS_DETECTED`.']) {
        final service = serviceReturning(() async => reply);

        final result = await service.requestFollowUp(
          question: question,
          answer: 'ما أدري، كل شي صار ثقيل',
        );

        expect(result, isA<CrisisDetected>(), reason: reply);
      }
    });

    test('the bank fallback never repeats the question just answered', () async {
      final service = serviceReturning(() async => 'الحل أن ترتاح');

      for (var i = 0; i < 20; i++) {
        final result = await service.requestFollowUp(question: question, answer: 'حاسس بضيق');
        expect((result as FollowUpQuestion).question.id, isNot(question.id));
      }
    });

    test('returns the model question when it contains no advice', () async {
      final service = serviceReturning(() async => '  وش أول مرة لاحظت هذا الشعور؟  ');

      final result = await service.requestFollowUp(question: question, answer: 'حاسس بضيق');

      final followUp = (result as FollowUpQuestion).question;
      expect(followUp.id, CoachAiService.aiFollowUpId);
      expect(followUp.text, 'وش أول مرة لاحظت هذا الشعور؟');
      expect(followUp.domain, CoachDomain.emotions);
    });

    test('replaces an advice reply with a local bank question from the same domain', () async {
      final service = serviceReturning(() async => 'يجب عليك أن تتكلم مع شخص تثق فيه');

      final result = await service.requestFollowUp(question: question, answer: 'حاسس بضيق');

      final followUp = (result as FollowUpQuestion).question;
      expect(followUp.id, startsWith('emotions_'));
      expect(followUp.domain, CoachDomain.emotions);
    });

    test('falls back to the local bank when the model call fails', () async {
      final service = serviceReturning(() async => throw Exception('network down'));

      final result = await service.requestFollowUp(question: question, answer: 'حاسس بضيق');

      final followUp = (result as FollowUpQuestion).question;
      expect(followUp.id, startsWith('emotions_'));
    });
  });
}
