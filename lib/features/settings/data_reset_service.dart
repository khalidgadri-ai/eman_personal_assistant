import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import '../../core/ai/ai_settings_service.dart';
import '../../core/app_events.dart';
import '../../core/services/database_service.dart';
import '../../core/services/encrypted_boxes.dart';
import '../../core/services/profile_service.dart';
import '../awareness/usage_service.dart';
import '../budget/budget_plan_service.dart';
import '../budget/budget_service.dart';
import '../coach/coach_session_service.dart';
import '../health_and_fitness/health_service.dart';
import '../reminders/reminder_service.dart';

/// "مسح كل بياناتي": يحذف من هذا الجهاز كل ما أدخله المستخدم، ثم يعود التطبيق لحالة
/// أول تشغيل (شاشة الترحيب).
class DataResetService {
  /// صناديق Hive لبيانات المستخدم. صندوق `subscription` خارجها عمدًا: هو نسخة مؤقتة من
  /// حالة اشتراك Google Play (المرجع الحقيقي عند Google) وليس من بيانات المستخدم.
  /// أي صندوق بيانات جديد يُضاف هنا، وإلى ملفات النسخ الاحتياطي في android/.../res/xml.
  static const List<String> userBoxes = [
    'coach_sessions_enc',
    'expenses_enc',
    'budget_plan_enc',
    'profile_enc',
    'health_enc',
    'exercise_images_enc',
    'app_usage',
  ];

  /// صناديق غير مشفّرة كانت تُستعمل قبل التشفير (تُنقل ثم تُحذف عادة؛ نحذفها احتياطًا).
  static const List<String> _legacyBoxes = ['coach_sessions', 'expenses'];

  static Future<void> eraseEverything() async {
    for (final name in [...userBoxes, ..._legacyBoxes]) {
      if (Hive.isBoxOpen(name)) {
        await Hive.box(name).deleteFromDisk();
      } else if (await Hive.boxExists(name)) {
        await Hive.deleteBoxFromDisk(name);
      }
    }
    final db = await DatabaseService.getInstance();
    await db.eraseAll();
    await _clearPickedImages();
    // المفتاح آخرًا: لو فشلت خطوة سابقة تبقى البيانات قابلة للقراءة بدل أن تضيع بلا مفتاح.
    await const FlutterSecureStorage().deleteAll();

    EncryptedBoxes.reset();
    AiSettingsService.reset();
    await ReminderService.cancelAll();
    BudgetService.reset();
    BudgetPlanService.reset();
    CoachSessionService.reset();
    ProfileService.reset();
    HealthService.reset();
    UsageService.reset();
    AppEvents.dataErased.value++;
  }

  /// صور حلّلها المستخدم (تمارين، علب أدوية) تبقى في مجلد الكاش المؤقت لمنتقي الصور.
  static Future<void> _clearPickedImages() async {
    if (kIsWeb) return;
    try {
      final cacheDir = await getTemporaryDirectory();
      await for (final entity in cacheDir.list()) {
        final segments = entity.uri.pathSegments.where((s) => s.isNotEmpty);
        if (entity is File && segments.isNotEmpty && segments.last.contains('image_picker')) {
          await entity.delete();
        }
      }
    } catch (e) {
      debugPrint('DataResetService: could not clear picked images (${e.runtimeType})');
    }
  }
}
