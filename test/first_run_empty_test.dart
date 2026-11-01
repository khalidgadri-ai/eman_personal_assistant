// أول تشغيل يجب أن يبدأ فارغًا تمامًا: لا بيانات خاصة بأي شخص في التخزين ولا في الكود.
import 'dart:io';

import 'package:eman_life_app/core/services/database_service.dart';
import 'package:eman_life_app/core/ai/ai_service.dart';
import 'package:eman_life_app/core/ai/ai_settings_service.dart';
import 'package:eman_life_app/core/services/profile_service.dart';
import 'package:eman_life_app/features/budget/budget_service.dart';
import 'package:eman_life_app/features/coach/coach_session_service.dart';
import 'package:eman_life_app/features/health_and_fitness/health_service.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/seed_phrases.dart';
import 'helpers/test_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late TestStorage storage;

  setUp(() => storage = TestStorage.create());
  tearDown(() => storage.dispose());

  test('nothing is stored in SharedPreferences-backed lists', () async {
    final db = await DatabaseService.getInstance();

    expect(db.getDailyTasks(), isEmpty);
    expect(db.getGoals(), isEmpty);
    expect(db.getPantry(), isEmpty);
    expect(db.getRecipes(), isEmpty);
    expect(db.getLaundrySchedule(), isEmpty);
    expect(db.getShopping(), isEmpty);
    expect(db.getQuranPage(), 0, reason: 'no reading progress belongs to a new user');
    expect(db.readLegacyGeminiKey(), isEmpty);
  });

  test('nothing is stored in the encrypted boxes', () async {
    final profile = await ProfileService.getInstance();
    final health = await HealthService.getInstance();
    final budget = await BudgetService.getInstance();
    final coach = await CoachSessionService.getInstance();

    expect(profile.onboarded, isFalse);
    expect(profile.profile, isNull);
    expect(health.medications(), isEmpty);
    expect(health.beautyItems(), isEmpty);
    expect(budget.getExpensesForMonth(DateTime.now()), isEmpty);
    expect(budget.getTotalForMonth(DateTime.now()), 0);
    expect(coach.getSessions(), isEmpty);
  });

  test('there is no AI key and no model until the user adds one', () async {
    final ai = await AiService.create();
    final settings = await AiSettingsService.getInstance();

    expect(ai.isConfigured, isFalse);
    expect(settings.selected, isNull);
    expect(await settings.hasKey('gemini'), isFalse);
  });

  group('no personal seed data is left anywhere in lib/', () {
    final sources = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))
        .map((f) => (path: f.path.replaceAll('\\', '/'), text: f.readAsStringSync()))
        .toList();

    void expectAbsent(List<String> needles, {required String why}) {
      for (final needle in needles) {
        final hits = sources.where((s) => s.text.contains(needle)).map((s) => s.path).toList();
        expect(hits, isEmpty, reason: '"$needle" ($why) found in $hits');
      }
    }

    test('former default tasks, medications, pantry, recipes, laundry and routine', () {
      expectAbsent(kFormerSeedPhrases, why: 'seed data of one specific person');
    });

    test('former demo amounts', () {
      expectAbsent(const [
        "text: '10000'",
        "text: '3500'",
        "text: '2000'",
        '3,500 ر.س',
        '1,500 ر.س',
      ], why: 'demo amounts shown as if real');
    });

    test('copy is not addressed to one gender', () {
      expectAbsent(const [
        'اكتبي',
        'اضغطي',
        'تريدين',
        'التقطي',
        'شاركينا',
        'تأكدي',
        'احصلي',
        'استخدمي',
        'لديكِ',
        '🏋️‍♀️',
      ], why: 'feminine-only wording');
    });

    test('the app name is the only place the brand name appears as text for the user', () {
      // الاسم التجاري "إيمان" يبقى: عنوان التطبيق وشاشة الترحيب وملصق أندرويد فقط.
      final hits = sources
          .where((s) => s.text.contains('إيمان'))
          .map((s) => s.path)
          .toList()
        ..sort();
      expect(hits, [
        'lib/features/awareness/usage_awareness_screen.dart',
        'lib/features/onboarding/onboarding_screen.dart',
        'lib/main.dart',
      ]);
    });
  });
}
