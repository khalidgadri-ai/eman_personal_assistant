import 'dart:convert';
import 'dart:typed_data';

import 'package:eman_life_app/core/ai/ai_settings_service.dart';
import 'package:eman_life_app/core/services/database_service.dart';
import 'package:eman_life_app/core/services/profile_service.dart';
import 'package:eman_life_app/features/budget/budget_plan_service.dart';
import 'package:eman_life_app/features/budget/budget_service.dart';
import 'package:eman_life_app/features/budget/models/budget_plan.dart';
import 'package:eman_life_app/features/budget/models/expense_entry.dart';
import 'package:eman_life_app/features/coach/coach_session_service.dart';
import 'package:eman_life_app/features/coach/models/coach_question.dart';
import 'package:eman_life_app/features/health_and_fitness/health_service.dart';
import 'package:eman_life_app/features/health_and_fitness/models/exercise.dart';
import 'package:eman_life_app/features/settings/backup_service.dart';
import 'package:eman_life_app/features/settings/data_reset_service.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/test_storage.dart';

/// دورات PBKDF2 قليلة في الاختبارات فقط؛ التطبيق يستعمل `BackupService.defaultIterations`.
const int _fastIterations = 1000;
const String _password = 'كلمة سر قوية 2026';

/// PNG صغير: صورة تمرين حقيقية الشكل تمر بالنسخة الاحتياطية بايتًا ببايت.
final Uint8List _photo = Uint8List.fromList(List.generate(4000, (i) => (i * 7) % 256));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late TestStorage storage;

  setUp(() => storage = TestStorage.create());
  tearDown(() async {
    BackupService.beforeBoxWrite = null;
    await storage.dispose();
  });

  /// جهاز جديد تمامًا: مجلد Hive آخر ومفتاح تشفير آخر، كما لو انتقل المستخدم لجوال جديد.
  Future<void> switchToNewPhone() async {
    await storage.dispose();
    storage = TestStorage.create();
  }

  Future<void> fillSampleData() async {
    final profile = await ProfileService.getInstance();
    await profile.save(
      UserProfile.sanitized(name: 'خالد', interests: ['القراءة', 'المشي'], goals: ['حفظ جزء']),
    );

    final health = await HealthService.getInstance();
    await health.addMedication(name: 'فيتامين د', time: 'بعد الفطور');
    await health.addBeautyItem(item: 'مرطب', time: 'مساءً', step: 'بعد الغسيل', reminder: '21:30');
    final exercise = await health.addExercise(
      const Exercise(id: '', name: 'سحب علوي', muscles: 'الظهر', steps: ['اسحب'], sets: 4, reps: '8-10', pinned: true),
      image: _photo,
    );
    await health.logWorkout(exercise: exercise!, sets: 4, reps: '8', weight: '30 كجم', day: DateTime(2026, 10, 12));

    final budget = await BudgetService.getInstance();
    await budget.addExpense(
      amount: 25.5,
      category: ExpenseCategory.food,
      note: 'غداء',
      date: DateTime(2026, 10, 15, 9, 30),
    );
    await budget.addExpense(
      amount: 100,
      category: ExpenseCategory.transport,
      date: DateTime(2026, 10, 16, 18, 5),
    );

    final plans = await BudgetPlanService.getInstance();
    await plans.save(
      const BudgetPlan(
        income: 9000.5,
        payday: 27,
        currencyCode: 'AED',
        fixed: [FixedExpense(id: 'f1', name: 'إيجار الشقة', amount: 3000, dueDay: 1, paidCycle: '2026-09-27')],
        savings: SavingsGoal(mode: SavingsMode.percent, value: 10),
        limits: {ExpenseCategory.food: 1500, ExpenseCategory.shopping: 400.25},
      ),
    );

    final coach = await CoachSessionService.getInstance();
    await coach.saveSession(
      question: const CoachQuestion(id: 'q1', domain: CoachDomain.beliefs, text: 'سؤال'),
      answerText: 'إجابة خاصة جدًا',
      date: DateTime(2026, 10, 14, 21, 0),
    );

    final db = await DatabaseService.getInstance();
    await db.saveDailyTasks([
      {'title': 'مهمة', 'category': 'شخصي', 'done': true},
    ]);
    await db.saveGoals([
      {'title': 'هدف', 'type': 'هدف عام', 'progress': 0.5},
    ]);
    await db.savePantry([
      {'name': 'أرز', 'quantity': '2 كجم'},
    ]);
    await db.saveRecipes([
      {'title': 'كبسة', 'category': 'غداء', 'ingredients': 'أرز، دجاج'},
    ]);
    await db.saveLaundrySchedule([
      {'day': 'السبت', 'type': 'ملابس', 'care': 'ماء بارد'},
    ]);
    await db.saveQuranPage(42);
    await db.saveShopping([
      {'id': 's1', 'name': 'حليب', 'qty': '2 لتر', 'done': false, 'source': ''},
    ]);
    final ai = await AiSettingsService.getInstance();
    await ai.save(ai.configFor('gemini'));
    await ai.saveKey('gemini', 'AIzaSyFAKEFAKEFAKEFAKEFAKEFAKE1234abcd');
  }

  /// كل ما يظهر للمستخدم، بشكل يقبل المقارنة (بدون مفاتيح الذكاء الاصطناعي: خارج النسخة عمدًا).
  Future<Map<String, Object?>> readState() async {
    final profile = (await ProfileService.getInstance()).profile;
    final health = await HealthService.getInstance();
    final budget = await BudgetService.getInstance();
    final coach = await CoachSessionService.getInstance();
    final db = await DatabaseService.getInstance();
    return {
      'profile': profile?.toMap(),
      'meds': [for (final m in health.medications()) [m.id, m.name, m.time, m.takenToday]],
      'beauty': [for (final b in health.beautyItems()) [b.id, b.item, b.time, b.step, b.reminder]],
      'exercises': [
        for (final e in health.exercises())
          [e.id, e.name, e.muscles, e.steps, e.setsAndReps, e.pinned, e.hasImage, health.exerciseImage(e.id)],
      ],
      'workouts': [
        for (final w in health.workouts()) [w.id, w.exerciseName, w.date, w.sets, w.reps, w.weight],
      ],
      'expenses': [
        for (final e in budget.getExpensesSince(DateTime(2000)))
          [e.id, e.amount, e.category.name, e.note, e.date.toIso8601String()],
      ],
      'budgetPlan': (await BudgetPlanService.getInstance()).plan.toMap(),
      'sessions': [
        for (final s in coach.getSessions())
          [s['questionId'], s['domain'], s['answerText'], (s['date'] as DateTime).toIso8601String()],
      ],
      'tasks': db.getDailyTasks(),
      'goals': db.getGoals(),
      'pantry': db.getPantry(),
      'recipes': db.getRecipes(),
      'laundry': db.getLaundrySchedule(),
      'quran': db.getQuranPage(),
      'shopping': db.getShopping(),
    };
  }

  bool containsSequence(List<int> haystack, List<int> needle) {
    for (var i = 0; i + needle.length <= haystack.length; i++) {
      var matched = true;
      for (var j = 0; j < needle.length; j++) {
        if (haystack[i + j] != needle[j]) {
          matched = false;
          break;
        }
      }
      if (matched) return true;
    }
    return false;
  }

  Future<BackupFailure> failureOf(Future<Object?> Function() action) async {
    try {
      await action();
    } on BackupException catch (e) {
      return e.reason;
    }
    fail('expected a BackupException');
  }

  test('a backup restores everything on a brand-new phone, with the same types and keys', () async {
    await fillSampleData();
    final before = await readState();
    final bytes = await BackupService.createBackup(_password, iterations: _fastIterations);

    await switchToNewPhone();
    expect((await readState())['expenses'], isEmpty, reason: 'the new phone starts empty');
    expect((await BudgetPlanService.getInstance()).plan.isConfigured, isFalse);

    final createdAt = await BackupService.restoreBackup(bytes, _password);

    expect(createdAt, isNotNull);
    expect(await readState(), before);
    final plan = (await BudgetPlanService.getInstance()).plan;
    expect(plan.income, 9000.5);
    expect(plan.payday, 27);
    expect(plan.currencyCode, 'AED');
    expect(plan.fixed.single.name, 'إيجار الشقة');
    expect(plan.fixed.single.paidCycle, '2026-09-27');
    expect(plan.limits[ExpenseCategory.shopping], 400.25);
  });

  test('the file is encrypted: no readable user text appears in it', () async {
    await fillSampleData();

    final bytes = await BackupService.createBackup(_password, iterations: _fastIterations);

    for (final secret in ['خالد', 'إجابة خاصة جدًا', 'فيتامين د', 'غداء', 'كبسة', 'eman', 'expenses', 'سحب علوي', 'إيجار الشقة', 'budget_plan']) {
      expect(containsSequence(bytes, utf8.encode(secret)), isFalse, reason: secret);
    }
    expect(utf8.decode(bytes.sublist(0, 6)), 'EMANBK');
  });

  test('AI keys and provider settings never go into the file and are not touched by a restore', () async {
    await fillSampleData();
    final bytes = await BackupService.createBackup(_password, iterations: _fastIterations);

    await switchToNewPhone();
    final ai = await AiSettingsService.getInstance();
    await ai.save(ai.configFor('openai').copyWith(model: 'some-model'));
    await ai.saveKey('openai', 'sk-THEKEYONTHENEWPHONE000000000000');
    await BackupService.restoreBackup(bytes, _password);

    final after = await AiSettingsService.getInstance();
    expect(await after.readKey('openai'), 'sk-THEKEYONTHENEWPHONE000000000000');
    expect(await after.hasKey('gemini'), isFalse, reason: 'the old phone key does not travel');
    expect(after.selectedId, 'openai');
  });

  test('a restore replaces what is on the phone instead of mixing with it', () async {
    await fillSampleData();
    final bytes = await BackupService.createBackup(_password, iterations: _fastIterations);

    final budget = await BudgetService.getInstance();
    await budget.addExpense(amount: 999, category: ExpenseCategory.other);
    final db = await DatabaseService.getInstance();
    await db.saveGoals([
      {'title': 'هدف دخيل', 'type': 'هدف عام', 'progress': 0.1},
    ]);

    await BackupService.restoreBackup(bytes, _password);

    final state = await readState();
    expect((state['expenses'] as List), hasLength(2));
    expect((state['goals'] as List).single, containsPair('title', 'هدف'));
  });

  test('new records after a restore get fresh keys and do not overwrite restored ones', () async {
    await fillSampleData();
    final bytes = await BackupService.createBackup(_password, iterations: _fastIterations);
    await switchToNewPhone();
    await BackupService.restoreBackup(bytes, _password);

    final budget = await BudgetService.getInstance();
    await budget.addExpense(amount: 7, category: ExpenseCategory.food);
    final health = await HealthService.getInstance();
    await health.addMedication(name: 'دواء جديد');

    expect(budget.getExpensesSince(DateTime(2000)), hasLength(3));
    expect(health.medications().map((m) => m.name), containsAll(['فيتامين د', 'دواء جديد']));
  });

  test('a wrong password is refused and the phone data stays exactly as it was', () async {
    await fillSampleData();
    final bytes = await BackupService.createBackup(_password, iterations: _fastIterations);
    final budget = await BudgetService.getInstance();
    await budget.addExpense(amount: 5, category: ExpenseCategory.food);
    final before = await readState();

    final failure = await failureOf(() => BackupService.restoreBackup(bytes, 'كلمة سر خاطئة'));

    expect(failure, BackupFailure.wrongPasswordOrCorrupt);
    expect(await readState(), before);
  });

  test('any changed byte (header, content, tag) makes the file unreadable', () async {
    await fillSampleData();
    final bytes = await BackupService.createBackup(_password, iterations: _fastIterations);
    final before = await readState();

    // 7..10 عدد الدورات، 11..26 salt، 27..38 nonce، بعدها المحتوى، وآخر 16 بايت العلامة.
    for (final index in [8, 15, 30, 45, bytes.length ~/ 2, bytes.length - 1]) {
      final tampered = Uint8List.fromList(bytes)..[index] ^= 0x01;
      final failure = await failureOf(() => BackupService.restoreBackup(tampered, _password));
      expect(
        failure,
        anyOf(BackupFailure.wrongPasswordOrCorrupt, BackupFailure.notABackup),
        reason: 'byte $index',
      );
    }
    expect(await readState(), before);
  });

  test('a file that is not a backup is recognised as such', () async {
    expect(
      await failureOf(() => BackupService.restoreBackup(Uint8List(0), _password)),
      BackupFailure.notABackup,
    );
    expect(
      await failureOf(() => BackupService.restoreBackup(Uint8List.fromList(utf8.encode('{"tasks":[]}' * 10)), _password)),
      BackupFailure.notABackup,
    );
    final bytes = await BackupService.createBackup(_password, iterations: _fastIterations);
    final wrongMagic = Uint8List.fromList(bytes)..[0] = 0x58;
    expect(
      await failureOf(() => BackupService.restoreBackup(wrongMagic, _password)),
      BackupFailure.notABackup,
    );
  });

  test('a backup from a newer app version asks the user to update', () async {
    final bytes = await BackupService.createBackup(_password, iterations: _fastIterations);
    final future = Uint8List.fromList(bytes)..[6] = BackupService.formatVersion + 1;

    expect(
      await failureOf(() => BackupService.restoreBackup(future, _password)),
      BackupFailure.unsupportedVersion,
    );
  });

  test('absurd iteration counts in the header are rejected before any heavy work', () async {
    final bytes = await BackupService.createBackup(_password, iterations: _fastIterations);
    final hostile = Uint8List.fromList(bytes)..setRange(7, 11, [0xFF, 0xFF, 0xFF, 0xFF]);

    final watch = Stopwatch()..start();
    final failure = await failureOf(() => BackupService.restoreBackup(hostile, _password));

    expect(failure, BackupFailure.notABackup);
    expect(watch.elapsed, lessThan(const Duration(seconds: 2)));
  });

  test('a short password is refused before anything is created', () async {
    expect(
      await failureOf(() => BackupService.createBackup('1234567', iterations: _fastIterations)),
      BackupFailure.weakPassword,
    );
    expect(
      await failureOf(() => BackupService.createBackup('', iterations: _fastIterations)),
      BackupFailure.weakPassword,
    );
    // 8 أحرف عربية تكفي (العدّ بالأحرف لا بالبايتات).
    await BackupService.createBackup('كلمةسرّي', iterations: _fastIterations);
  });

  test('two backups of the same data differ (fresh salt and nonce each time)', () async {
    await fillSampleData();

    final a = await BackupService.createBackup(_password, iterations: _fastIterations);
    final b = await BackupService.createBackup(_password, iterations: _fastIterations);

    expect(a, isNot(b));
  });

  test('a failure half-way through a restore puts the previous data back', () async {
    await fillSampleData();
    final bytes = await BackupService.createBackup(_password, iterations: _fastIterations);

    // حالة الجهاز الآن مختلفة عن النسخة: ملف شخصي آخر ومصروف آخر.
    final profile = await ProfileService.getInstance();
    await profile.save(UserProfile.sanitized(name: 'شخص آخر', interests: [], goals: []));
    final budget = await BudgetService.getInstance();
    await budget.addExpense(amount: 1, category: ExpenseCategory.food);
    final before = await readState();

    var failedOnce = false;
    BackupService.beforeBoxWrite = (name) async {
      // يفشل أول كتابة لصندوق المصاريف (بعد أن كُتب الملف الشخصي والصحة) ثم يسمح بالتراجع.
      if (name == 'expenses' && !failedOnce) {
        failedOnce = true;
        throw StateError('disk full');
      }
    };

    final failure = await failureOf(() => BackupService.restoreBackup(bytes, _password));

    expect(failure, BackupFailure.restoreFailed);
    expect(await readState(), before);
  });

  test('the file name carries the date and the app extension', () {
    expect(BackupService.suggestedFileName(DateTime(2026, 3, 5)), 'eman-backup-2026-03-05.emanbak');
  });

  test('every backed-up box is also wiped by "مسح كل بياناتي"', () {
    for (final name in BackupService.boxNames) {
      expect(DataResetService.userBoxes, contains('${name}_enc'));
    }
  });

  test('the real iteration count finishes in a reasonable time', () async {
    await fillSampleData();

    final watch = Stopwatch()..start();
    final bytes = await BackupService.createBackup(_password);
    final createTime = watch.elapsed;
    watch.reset();
    await BackupService.restoreBackup(bytes, _password);
    final restoreTime = watch.elapsed;

    printOnFailure('create $createTime, restore $restoreTime');
    // سقف واسع: جهاز التطوير أسرع من الهاتف. القياس على الهاتف في خطوة التجربة اليدوية.
    expect(createTime, lessThan(const Duration(seconds: 60)));
    expect(restoreTime, lessThan(const Duration(seconds: 60)));
  }, timeout: const Timeout(Duration(minutes: 3)));
}
