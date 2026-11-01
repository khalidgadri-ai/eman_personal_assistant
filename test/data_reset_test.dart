import 'dart:io';

import 'package:eman_life_app/core/ai/ai_settings_service.dart';
import 'package:eman_life_app/core/app_events.dart';
import 'package:eman_life_app/core/services/database_service.dart';
import 'package:eman_life_app/core/services/profile_service.dart';
import 'package:eman_life_app/features/budget/budget_plan_service.dart';
import 'package:eman_life_app/features/budget/budget_service.dart';
import 'package:eman_life_app/features/budget/models/budget_plan.dart';
import 'package:eman_life_app/features/budget/models/expense_entry.dart';
import 'package:eman_life_app/features/coach/coach_session_service.dart';
import 'package:eman_life_app/features/coach/models/coach_question.dart';
import 'package:eman_life_app/features/health_and_fitness/health_service.dart';
import 'package:eman_life_app/features/settings/data_reset_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/test_storage.dart';

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  late TestStorage storage;
  late Directory cacheDir;

  setUp(() {
    storage = TestStorage.create();
    cacheDir = Directory.systemTemp.createTempSync('eman_cache');
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (call) async => call.method == 'getTemporaryDirectory' ? cacheDir.path : null,
    );
  });

  tearDown(() async {
    binding.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('plugins.flutter.io/path_provider'), null);
    await storage.dispose();
    cacheDir.deleteSync(recursive: true);
  });

  /// يملأ كل مخازن المستخدم ببيانات، ويفتح صندوق الاشتراك ليتأكد أنه لا يُمسح.
  Future<void> fillEverything() async {
    final profile = await ProfileService.getInstance();
    await profile.save(UserProfile.sanitized(name: 'اسم', interests: ['القراءة'], goals: ['هدف']));

    final health = await HealthService.getInstance();
    await health.addMedication(name: 'دواء');
    await health.addBeautyItem(item: 'منتج');

    final budget = await BudgetService.getInstance();
    await budget.addExpense(amount: 25, category: ExpenseCategory.food);
    await (await BudgetPlanService.getInstance()).save(const BudgetPlan(income: 9000, payday: 27));

    final coach = await CoachSessionService.getInstance();
    await coach.saveSession(
      question: const CoachQuestion(id: 'q1', domain: CoachDomain.beliefs, text: 'سؤال'),
      answerText: 'إجابة خاصة',
    );

    final usage = await Hive.openBox('app_usage');
    await usage.put('today', {'day': '2026-10-16', 'minutes': {'whatsapp': 30}});

    final db = await DatabaseService.getInstance();
    await db.saveDailyTasks([
      {'title': 'مهمة', 'category': 'شخصي', 'done': false},
    ]);
    await db.saveGoals([
      {'title': 'هدف', 'type': 'هدف عام', 'progress': 0.5},
    ]);
    final ai = await AiSettingsService.getInstance();
    await ai.save(ai.configFor('gemini'));
    await ai.saveKey('gemini', 'AIzaSyFAKEFAKEFAKEFAKEFAKEFAKE1234abcd');
    await db.saveShopping([
      {'id': 's1', 'name': 'حليب', 'qty': '', 'done': false, 'source': ''},
    ]);

    const FlutterSecureStorage();
    await const FlutterSecureStorage().write(key: 'other_secret', value: 'x');

    final subscription = await Hive.openBox('subscription');
    await subscription.put('status', {'active': true});
  }

  test('erases every store and brings the app back to the first-run state', () async {
    await fillEverything();
    final oldKey = await const FlutterSecureStorage().read(key: 'hive_aes_key');
    expect(oldKey, isNotNull);
    final before = AppEvents.dataErased.value;

    await DataResetService.eraseEverything();

    // الملفات حُذفت.
    for (final name in DataResetService.userBoxes) {
      expect(await Hive.boxExists(name), isFalse, reason: '$name should be gone');
    }
    // SharedPreferences والتخزين الآمن فارغان (يشمل مفتاح Gemini ومفتاح التشفير).
    expect((await SharedPreferences.getInstance()).getKeys(), isEmpty);
    expect(await const FlutterSecureStorage().readAll(), isEmpty);
    // البوابة تُبلَّغ لتعرض الترحيب.
    expect(AppEvents.dataErased.value, before + 1);

    // الخدمات تفتح من جديد فارغة تمامًا.
    expect((await ProfileService.getInstance()).onboarded, isFalse);
    expect((await HealthService.getInstance()).medications(), isEmpty);
    expect((await HealthService.getInstance()).beautyItems(), isEmpty);
    expect((await BudgetService.getInstance()).getTotalForMonth(DateTime.now()), 0);
    expect((await BudgetPlanService.getInstance()).plan.isConfigured, isFalse, reason: 'the budget plan is erased');
    expect((await CoachSessionService.getInstance()).getSessions(), isEmpty);
    final db = await DatabaseService.getInstance();
    expect(db.getDailyTasks(), isEmpty);
    expect(db.getGoals(), isEmpty);
    final ai = await AiSettingsService.getInstance();
    expect(ai.selected, isNull, reason: 'the chosen provider is forgotten');
    expect(await ai.hasKey('gemini'), isFalse, reason: 'the key is gone from secure storage');
    expect(db.getShopping(), isEmpty);
  });

  test('the app keeps working after an erase and uses a brand-new encryption key', () async {
    await fillEverything();
    final oldKey = await const FlutterSecureStorage().read(key: 'hive_aes_key');

    await DataResetService.eraseEverything();
    final budget = await BudgetService.getInstance();
    await budget.addExpense(amount: 10, category: ExpenseCategory.transport);

    expect(budget.getTotalForMonth(DateTime.now()), 10);
    final newKey = await const FlutterSecureStorage().read(key: 'hive_aes_key');
    expect(newKey, isNotNull);
    expect(newKey, isNot(oldKey));
  });

  test('the subscription cache is not user data and is left alone', () async {
    await fillEverything();

    await DataResetService.eraseEverything();

    expect(Hive.isBoxOpen('subscription'), isTrue);
    expect(Hive.box('subscription').get('status'), {'active': true});
  });

  test('picked images in the cache folder are removed, other cache files stay', () async {
    File('${cacheDir.path}/image_picker_1234.jpg').writeAsBytesSync([1, 2, 3]);
    File('${cacheDir.path}/scaled_image_picker_5678.jpg').writeAsBytesSync([4, 5, 6]);
    File('${cacheDir.path}/unrelated.cache').writeAsBytesSync([7]);

    await DataResetService.eraseEverything();

    final names = cacheDir.listSync().map((e) => e.uri.pathSegments.last).toList();
    expect(names, ['unrelated.cache']);
  });

  test('erasing a brand-new install is harmless', () async {
    await DataResetService.eraseEverything();
    await DataResetService.eraseEverything();

    expect((await ProfileService.getInstance()).onboarded, isFalse);
  });
}
