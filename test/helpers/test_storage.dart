import 'dart:io';
import 'dart:typed_data';

import 'package:eman_life_app/core/ai/ai_settings_service.dart';
import 'package:eman_life_app/core/services/database_service.dart';
import 'package:eman_life_app/core/services/encrypted_boxes.dart';
import 'package:eman_life_app/core/services/profile_service.dart';
import 'package:eman_life_app/features/awareness/usage_service.dart';
import 'package:eman_life_app/features/budget/budget_plan_service.dart';
import 'package:eman_life_app/features/budget/budget_service.dart';
import 'package:eman_life_app/features/coach/coach_session_service.dart';
import 'package:eman_life_app/features/health_and_fitness/health_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// أسماء الصناديق المشفّرة التي تفتحها الخدمات (الاسم على القرص = الاسم + `_enc`).
const List<String> kEncryptedBoxFiles = [
  'profile_enc',
  'health_enc',
  'exercise_images_enc',
  'expenses_enc',
  'budget_plan_enc',
  'coach_sessions_enc',
];

/// بيئة تخزين نظيفة لكل اختبار: أول تشغيل بلا أي بيانات ولا مفاتيح.
class TestStorage {
  TestStorage._(this.directory);

  /// مجلد Hive المؤقت، أو null في وضع الذاكرة.
  final Directory? directory;

  static void _reset(Map<String, Object> prefs) {
    SharedPreferences.setMockInitialValues(prefs);
    FlutterSecureStorage.setMockInitialValues({});
    EncryptedBoxes.resetForTesting();
    AiSettingsService.resetForTesting();
    DatabaseService.resetForTesting();
    BudgetService.resetForTesting();
    BudgetPlanService.resetForTesting();
    CoachSessionService.resetForTesting();
    ProfileService.reset();
    HealthService.resetForTesting();
    UsageService.resetForTesting();
  }

  /// Hive على ملفات حقيقية في مجلد مؤقت (للاختبارات العادية `test`).
  static TestStorage create({Map<String, Object> prefs = const {}}) {
    final dir = Directory.systemTemp.createTempSync('eman_test');
    Hive.init(dir.path);
    _reset(prefs);
    return TestStorage._(dir);
  }

  /// صناديق Hive في الذاكرة بلا ملفات: تعمل داخل `testWidgets` بدون إدخال/إخراج حقيقي.
  /// الخدمات تجدها مفتوحة مسبقًا باسمها المشفّر فتستعملها كما هي.
  static Future<TestStorage> inMemory({Map<String, Object> prefs = const {}}) async {
    Hive.init(Directory.systemTemp.path);
    _reset(prefs);
    for (final name in [...kEncryptedBoxFiles, 'app_usage']) {
      await Hive.openBox(name, bytes: Uint8List(0));
    }
    return TestStorage._(null);
  }

  Future<void> dispose() async {
    await Hive.close();
    directory?.deleteSync(recursive: true);
    _reset(const {});
  }
}
