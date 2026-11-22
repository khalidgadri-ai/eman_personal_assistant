import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:eman_life_app/core/services/database_service.dart';
import 'package:eman_life_app/core/theme/app_theme.dart';
import 'package:eman_life_app/features/coach/coach_safety.dart';
import 'package:eman_life_app/features/coach/coach_screen.dart';
import 'package:eman_life_app/features/coach/coach_session_service.dart';
import 'package:eman_life_app/features/coach/models/coach_question.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/test_storage.dart';
import 'helpers/widget_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final List bank = jsonDecode(File('assets/coach_questions.json').readAsStringSync()) as List;

  group('the question bank', () {
    test('has at least 50 questions in every domain', () {
      for (final domain in CoachDomain.values) {
        final count = bank.where((q) => q['domain'] == domain.name).length;
        expect(count, greaterThanOrEqualTo(50), reason: domain.name);
      }
    });

    test('ids are unique and texts are unique after normalizing', () {
      final ids = bank.map((q) => q['id'] as String).toList();
      expect(ids.toSet().length, ids.length);
      final texts = bank.map((q) => normalizeArabic(q['text'] as String).trim()).toList();
      expect(texts.toSet().length, texts.length);
    });

    test('every question is short and has a follow-up hint', () {
      for (final q in bank) {
        final text = q['text'] as String;
        expect(text.length, lessThanOrEqualTo(140), reason: text);
        expect((q['followUpPromptHint'] as String? ?? '').trim(), isNotEmpty, reason: q['id'] as String);
      }
    });

    test('the original 40 questions keep their ids', () {
      for (final domain in CoachDomain.values) {
        final count = domain == CoachDomain.budget || domain == CoachDomain.skills ? 6 : 7;
        for (var i = 1; i <= count; i++) {
          final id = '${domain.name}_${i.toString().padLeft(2, '0')}';
          expect(bank.any((q) => q['id'] == id), isTrue, reason: id);
        }
      }
    });
  });

  group('choosing without repeats', () {
    List<CoachQuestion> domainOf(int size, [CoachDomain domain = CoachDomain.goals]) => [
          for (var i = 0; i < size; i++) CoachQuestion(id: '${domain.name}_$i', domain: domain, text: 'q$i'),
        ];

    test('within a cycle every question appears exactly once', () {
      final questions = domainOf(50);
      final shown = <String>[];
      final random = Random(7);
      for (var i = 0; i < questions.length; i++) {
        shown.add(CoachSessionService.chooseQuestion(inDomain: questions, shownIds: shown, random: random).id);
      }
      expect(shown.toSet().length, questions.length);
    });

    test('a new cycle does not start with the last 10 questions shown', () {
      final questions = domainOf(50);
      final shown = [for (final q in questions) q.id]; // دورة كاملة انتهت للتو
      final lastTen = shown.sublist(40).toSet();
      for (var seed = 0; seed < 30; seed++) {
        final next = CoachSessionService.chooseQuestion(inDomain: questions, shownIds: shown, random: Random(seed));
        expect(lastTen.contains(next.id), isFalse);
      }
    });

    test('one domain\'s history does not affect another domain', () {
      final goals = domainOf(5);
      final skills = domainOf(5, CoachDomain.skills);
      final shown = [for (final q in goals) q.id, goals.first.id];
      final picked = {
        for (var seed = 0; seed < 40; seed++)
          CoachSessionService.chooseQuestion(inDomain: skills, shownIds: shown, random: Random(seed)).id,
      };
      expect(picked, {for (final q in skills) q.id});
    });

    test('the excluded question is never picked', () {
      final questions = domainOf(3);
      for (var seed = 0; seed < 20; seed++) {
        final next = CoachSessionService.chooseQuestion(
          inDomain: questions,
          shownIds: const [],
          random: Random(seed),
          excludeId: questions.first.id,
        );
        expect(next.id, isNot(questions.first.id));
      }
    });
  });

  group('the service', () {
    late TestStorage storage;

    setUp(() => storage = TestStorage.create());
    tearDown(() => storage.dispose());

    test('shows every question of a domain once before any repeats', () async {
      final service = await CoachSessionService.getInstance();
      final size = service.questionsForDomain(CoachDomain.emotions).length;
      final seen = <String>{};
      for (var i = 0; i < size; i++) {
        seen.add((await service.showNextQuestion(CoachDomain.emotions)).id);
      }
      expect(seen.length, size);
    });

    test('the shown history is saved and survives a restart of the service', () async {
      final first = await (await CoachSessionService.getInstance()).showNextQuestion(CoachDomain.goals);
      CoachSessionService.reset();
      final service = await CoachSessionService.getInstance();
      for (var i = 0; i < 20; i++) {
        expect(service.pickQuestion(CoachDomain.goals, random: Random(i)).id, isNot(first.id));
      }
      final stored = (await DatabaseService.getInstance()).getCoachSeenQuestions()!;
      expect(stored.single['id'], first.id);
      expect(stored.single.keys.toSet(), {'id', 'at'});
    });

    test('a follow-up question from the model is not recorded', () async {
      final service = await CoachSessionService.getInstance();
      await service.recordShown(
        const CoachQuestion(id: 'ai_followup', domain: CoachDomain.goals, text: 'سؤال من الموديل'),
      );
      expect((await DatabaseService.getInstance()).getCoachSeenQuestions(), isNull);
    });

    test('an existing user\'s answered questions count as already shown', () async {
      final service = await CoachSessionService.getInstance();
      final answered = service.questionsForDomain(CoachDomain.budget).first;
      await service.saveSession(question: answered, answerText: 'جواب', date: DateTime(2026, 1, 1));
      for (var i = 0; i < 30; i++) {
        expect(service.pickQuestion(CoachDomain.budget, random: Random(i)).id, isNot(answered.id));
      }
    });

    test('a corrupt stored history reads as empty and does not crash', () async {
      final db = await DatabaseService.getInstance();
      await db.saveCoachSeenQuestions([]);
      final service = await CoachSessionService.getInstance();
      for (final raw in ['not json', '{"id": 1}', '[1, 2, 3]']) {
        // نكتب القيمة التالفة كما هي، كما لو أفسدها شيء آخر.
        await (await SharedPreferences.getInstance()).setString(DatabaseService.coachSeenQuestionsKey, raw);
        expect(() => service.pickQuestion(CoachDomain.skills), returnsNormally);
        await service.showNextQuestion(CoachDomain.skills);
      }
    });

    test('"erase all my data" clears the shown history', () async {
      final service = await CoachSessionService.getInstance();
      await service.showNextQuestion(CoachDomain.skills);
      final db = await DatabaseService.getInstance();
      expect(db.getCoachSeenQuestions(), isNotEmpty);
      await db.eraseAll();
      expect(db.getCoachSeenQuestions(), isNull);
    });

    test('the shown history is part of the backup', () async {
      final service = await CoachSessionService.getInstance();
      await service.showNextQuestion(CoachDomain.goals);
      final db = await DatabaseService.getInstance();
      expect(DatabaseService.backupListKeys, contains(DatabaseService.coachSeenQuestionsKey));
      expect(db.exportBackupData().keys, contains(DatabaseService.coachSeenQuestionsKey));
    });
  });

  group('the coach screen', () {
    late TestStorage storage;

    setUp(() async => storage = await TestStorage.inMemory());
    tearDown(() => storage.dispose());

    /// نص السؤال المعروض: أول نص في الشاشة موجود في البنك.
    Future<String> openCoachAndReadQuestion(WidgetTester tester) async {
      await tester.runAsync(CoachSessionService.getInstance);
      await pumpScreen(tester, const CoachScreen());
      return tester
          .widgetList<Text>(find.byType(Text))
          .map((t) => t.data ?? '')
          .firstWhere((text) => bank.any((q) => q['text'] == text), orElse: () => '');
    }

    testWidgets('leaving and opening again shows a different question', (tester) async {
      final first = await openCoachAndReadQuestion(tester);
      await tester.pumpWidget(const SizedBox());
      final second = await openCoachAndReadQuestion(tester);
      expect(first, isNotEmpty);
      expect(second, isNot(first));
    });

    testWidgets('on a small phone with the keyboard open both buttons stay fully visible', (tester) async {
      tester.view.physicalSize = const Size(720, 1440);
      tester.view.devicePixelRatio = 2; // 360×720
      tester.view.viewInsets = const FakeViewPadding(bottom: 600); // لوحة مفاتيح بارتفاع 300
      addTearDown(tester.view.reset);

      await tester.runAsync(CoachSessionService.getInstance);
      await tester.pumpWidget(MaterialApp(theme: AppTheme.darkTheme, home: const CoachScreen()));
      await settle(tester);
      await tester.enterText(find.byType(TextField), 'جواب قصير');
      await tester.pump();

      final visibleBottom = 720 - 300.0;
      for (final label in ['التالي', 'عمّق أكثر', 'متبقٍ 5 من 5 مجانًا هذا الشهر']) {
        final rect = tester.getRect(find.text(label));
        expect(rect.bottom, lessThanOrEqualTo(visibleBottom), reason: label);
        expect(rect.top, greaterThanOrEqualTo(0), reason: label);
      }
    });
  });
}
