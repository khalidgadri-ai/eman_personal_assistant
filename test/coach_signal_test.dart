import 'dart:io';
import 'dart:math';

import 'package:eman_life_app/core/services/encrypted_boxes.dart';
import 'package:eman_life_app/features/budget/budget_service.dart';
import 'package:eman_life_app/features/budget/models/expense_entry.dart';
import 'package:eman_life_app/features/coach/coach_session_service.dart';
import 'package:eman_life_app/features/coach/coach_signal_service.dart';
import 'package:eman_life_app/features/coach/models/coach_question.dart';
import 'package:eman_life_app/features/coach/models/coach_signals.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

class _FixedRandom implements Random {
  _FixedRandom(this.value);
  final int value;

  @override
  int nextInt(int max) => value;

  @override
  double nextDouble() => 0;

  @override
  bool nextBool() => false;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final now = DateTime(2026, 10, 20, 12);
  final signals = CoachSignalService(now: () => now);
  late Directory hiveDir;
  late BudgetService budget;
  late CoachSessionService sessions;

  setUp(() async {
    hiveDir = Directory.systemTemp.createTempSync('coach_signal_test');
    Hive.init(hiveDir.path);
    FlutterSecureStorage.setMockInitialValues({});
    EncryptedBoxes.resetForTesting();
    BudgetService.resetForTesting();
    CoachSessionService.resetForTesting();
    budget = await BudgetService.getInstance();
    sessions = await CoachSessionService.getInstance();
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    BudgetService.resetForTesting();
    CoachSessionService.resetForTesting();
    hiveDir.deleteSync(recursive: true);
  });

  Future<void> spend(ExpenseCategory category, {String? note, required int daysAgo}) {
    return budget.addExpense(
      amount: 50,
      category: category,
      note: note,
      date: now.subtract(Duration(days: daysAgo)),
    );
  }

  group('getBudgetSignal', () {
    test('active: three "other" expenses this week, even with notes', () async {
      await spend(ExpenseCategory.other, note: 'هدية', daysAgo: 1);
      await spend(ExpenseCategory.other, note: 'صيانة', daysAgo: 3);
      await spend(ExpenseCategory.other, note: 'غرامة', daysAgo: 6);

      expect(await signals.getBudgetSignal(), isTrue);
    });

    test('active: three expenses without a note this week, in any category', () async {
      await spend(ExpenseCategory.food, daysAgo: 0);
      await spend(ExpenseCategory.shopping, daysAgo: 2);
      await spend(ExpenseCategory.entertainment, daysAgo: 4);

      expect(await signals.getBudgetSignal(), isTrue);
    });

    test('inactive: only two unplanned among several planned expenses', () async {
      await spend(ExpenseCategory.other, note: 'هدية', daysAgo: 1);
      await spend(ExpenseCategory.food, daysAgo: 2);
      await spend(ExpenseCategory.food, note: 'مقاضي الأسبوع', daysAgo: 1);
      await spend(ExpenseCategory.bills, note: 'كهرباء', daysAgo: 2);
      await spend(ExpenseCategory.transport, note: 'بنزين', daysAgo: 3);

      expect(await signals.getBudgetSignal(), isFalse);
    });

    test('inactive: unplanned expenses older than seven days do not count', () async {
      await spend(ExpenseCategory.other, daysAgo: 8);
      await spend(ExpenseCategory.other, daysAgo: 10);
      await spend(ExpenseCategory.other, daysAgo: 7);

      // The third one sits exactly on the 7-day edge, so only one is in the window.
      expect(await signals.getBudgetSignal(), isFalse);
    });

    test('inactive: no expenses at all', () async {
      expect(await signals.getBudgetSignal(), isFalse);
    });
  });

  group('getReflectionSignal', () {
    Future<void> answer(CoachDomain domain, String? text, {required int hoursAgo}) {
      return sessions.saveSession(
        question: CoachQuestion(id: '${domain.name}_test', domain: domain, text: 'سؤال'),
        answerText: text,
        date: now.subtract(Duration(hours: hoursAgo)),
      );
    }

    test('active: the same topic in the last two answers, despite "ال" and "ي"', () async {
      await answer(CoachDomain.beliefs, 'ضغط الشغل هذا الأسبوع خلاني ما أنام زين', hoursAgo: 30);
      await answer(CoachDomain.goals, 'أحس شغلي ماخذ كل وقتي', hoursAgo: 2);

      final signal = await signals.getReflectionSignal();

      expect(signal?.topic, 'شغل');
      expect(signal?.domain, CoachDomain.goals);
    });

    test('active: unanswered sessions in between do not break the streak', () async {
      await answer(CoachDomain.emotions, 'زعلت من أخوي', hoursAgo: 48);
      await answer(CoachDomain.emotions, 'كلام أخوي ما زال يضايقني', hoursAgo: 24);
      await answer(CoachDomain.beliefs, null, hoursAgo: 1);

      final signal = await signals.getReflectionSignal();

      expect(signal?.topic, 'اخو');
      expect(signal?.domain, CoachDomain.emotions);
    });

    test('inactive: the last two answers share only common words', () async {
      await answer(CoachDomain.organization, 'اليوم كان طويل في الدوام', hoursAgo: 20);
      await answer(CoachDomain.organization, 'كان عندي اجتماع اليوم', hoursAgo: 1);

      expect(await signals.getReflectionSignal(), isNull);
    });

    test('inactive: a repeat that is not in consecutive answers', () async {
      await answer(CoachDomain.goals, 'الشغل كثير', hoursAgo: 50);
      await answer(CoachDomain.emotions, 'حاسس بتعب في رجلي', hoursAgo: 25);
      await answer(CoachDomain.goals, 'مشغول بالشغل', hoursAgo: 1);

      expect(await signals.getReflectionSignal(), isNull);
    });

    test('inactive: fewer than two answers', () async {
      await answer(CoachDomain.goals, 'الشغل كثير', hoursAgo: 1);

      expect(await signals.getReflectionSignal(), isNull);
    });
  });

  group('domain weighting', () {
    test('without signals every domain has the same weight', () {
      final weights = CoachSessionService.domainWeights(CoachSignals.none);

      expect(weights.values.toSet(), {1});
      expect(weights.keys, CoachDomain.values);
    });

    test('a budget signal boosts only the budget domain', () {
      final weights = CoachSessionService.domainWeights(const CoachSignals(budget: true));

      expect(weights[CoachDomain.budget], 1 + CoachSessionService.signalBoost);
      expect(
        weights.entries.where((e) => e.key != CoachDomain.budget).map((e) => e.value).toSet(),
        {1},
      );
    });

    test('a reflection signal boosts the domain of its topic', () {
      final weights = CoachSessionService.domainWeights(const CoachSignals(
        reflection: ReflectionSignal(topic: 'شغل', domain: CoachDomain.emotions),
      ));

      expect(weights[CoachDomain.emotions], 1 + CoachSessionService.signalBoost);
      expect(weights[CoachDomain.budget], 1);
    });

    test('pickDomain maps each roll onto the weighted ranges', () {
      const boosted = CoachSignals(budget: true);
      // Order: beliefs, emotions, goals, organization (1 each), budget (4), skills (1).
      expect(CoachSessionService.pickDomain(boosted, random: _FixedRandom(3)), CoachDomain.organization);
      expect(CoachSessionService.pickDomain(boosted, random: _FixedRandom(4)), CoachDomain.budget);
      expect(CoachSessionService.pickDomain(boosted, random: _FixedRandom(7)), CoachDomain.budget);
      expect(CoachSessionService.pickDomain(boosted, random: _FixedRandom(8)), CoachDomain.skills);
    });

    test('the hint appears only when the picked domain is the signal domain', () {
      const active = CoachSignals(budget: true);

      expect(active.hintFor(CoachDomain.budget), 'لاحظنا نمط في مصاريفك هذا الأسبوع');
      expect(active.hintFor(CoachDomain.emotions), isNull);
      expect(CoachSignals.none.hintFor(CoachDomain.budget), isNull);
    });
  });
}
