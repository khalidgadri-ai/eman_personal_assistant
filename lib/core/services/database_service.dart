import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// تخزين بسيط للقوائم غير الحساسة (مفتاح → نص JSON). لا توجد بيانات افتراضية:
/// أول تشغيل يبدأ فارغًا تمامًا، وكل ما يظهر في الشاشات أدخله المستخدم بنفسه.
class DatabaseService {
  /// عدد صفحات المصحف (طبعة المدينة) لمتتبع الورد.
  static const int quranPages = 604;

  /// مفاتيح SharedPreferences التي تدخل النسخة الاحتياطية المشفّرة (BackupService): القوائم
  /// المخزّنة كنص JSON وصفحة الورد. مفتاح Gemini خارجها عمدًا: سرّ لا يُكتب في ملف.
  /// أي مجال جديد يُضاف هنا ليدخل النسخة.
  static const List<String> backupListKeys = [
    'daily_tasks',
    'goals',
    'pantry',
    'recipes',
    'laundry_schedule',
    'shopping',
  ];
  static const String quranPageKey = 'quran_page';

  static DatabaseService? _instance;
  static SharedPreferences? _prefs;

  DatabaseService._();

  static Future<DatabaseService> getInstance() async {
    _instance ??= DatabaseService._();
    if (_prefs == null) {
      final prefs = await SharedPreferences.getInstance();
      // ملاحظات المطوّر القديمة: الزر حُذف (صار "تواصل معنا" يفتح البريد) ولا شاشة تقرؤها.
      await prefs.remove('feedback_entries');
      _prefs = prefs;
    }
    return _instance!;
  }

  /// Clears the cached singleton so tests can start from a fresh
  /// SharedPreferences.setMockInitialValues() state between cases.
  @visibleForTesting
  static void resetForTesting() {
    _instance = null;
    _prefs = null;
  }

  /// قائمة مخزّنة كنص JSON. غير الموجود أو التالف يرجع قائمة فارغة بدل أن يوقف التطبيق.
  List<Map<String, dynamic>> _readList(String key) {
    final raw = _prefs?.getString(key);
    if (raw == null) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];
      return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _writeList(String key, List<Map<String, dynamic>> items) async {
    await _prefs?.setString(key, jsonEncode(items));
  }

  // --- Daily Tasks ---
  List<Map<String, dynamic>> getDailyTasks() => _readList('daily_tasks');

  Future<void> saveDailyTasks(List<Map<String, dynamic>> tasks) => _writeList('daily_tasks', tasks);

  // --- Goals (title, type, progress 0..1) ---
  List<Map<String, dynamic>> getGoals() => _readList('goals');

  Future<void> saveGoals(List<Map<String, dynamic>> goals) => _writeList('goals', goals);

  // --- Quran Page ---
  int getQuranPage() {
    return (_prefs?.getInt(quranPageKey) ?? 0).clamp(0, quranPages);
  }

  Future<void> saveQuranPage(int page) async {
    await _prefs?.setInt(quranPageKey, page.clamp(0, quranPages));
  }

  // --- Pantry Inventory ---
  List<Map<String, dynamic>> getPantry() => _readList('pantry');

  Future<void> savePantry(List<Map<String, dynamic>> pantry) => _writeList('pantry', pantry);

  // --- Recipes (title, category, ingredients) ---
  List<Map<String, dynamic>> getRecipes() => _readList('recipes');

  Future<void> saveRecipes(List<Map<String, dynamic>> recipes) => _writeList('recipes', recipes);

  // --- Laundry schedule (day, type, care) ---
  List<Map<String, dynamic>> getLaundrySchedule() => _readList('laundry_schedule');

  Future<void> saveLaundrySchedule(List<Map<String, dynamic>> items) =>
      _writeList('laundry_schedule', items);

  // --- Shopping list (name, qty, done, source) ---
  List<Map<String, dynamic>> getShopping() => _readList('shopping');

  Future<void> saveShopping(List<Map<String, dynamic>> items) => _writeList('shopping', items);

  // --- إعداد مزوّد الذكاء الاصطناعي (AiSettingsService) ---
  // الإعداد غير سرّي (عناوين وأسماء موديلات). **المفاتيح لا تُخزَّن هنا أبدًا**: مكانها
  // flutter_secure_storage، لأن SharedPreferences غير مشفّرة وتدخل النسخ التلقائي لـ Google.
  String getAiConfigJson() => _prefs?.getString('ai_config') ?? '';

  Future<void> saveAiConfigJson(String json) async {
    await _prefs?.setString('ai_config', json);
  }

  /// مفتاح Gemini القديم (كان هنا قبل نقل المفاتيح للتخزين الآمن). يُقرأ لمرة واحدة ويُمسح.
  String readLegacyGeminiKey() => (_prefs?.getString(legacyGeminiKeyName) ?? '').trim();

  Future<void> removeLegacyGeminiKey() async {
    await _prefs?.remove(legacyGeminiKeyName);
  }

  static const String legacyGeminiKeyName = 'gemini_api_key';

  // --- Backup (BackupService) ---
  /// القيم الموجودة فقط من [backupListKeys] وصفحة الورد، كما هي مخزّنة.
  Map<String, Object> exportBackupData() {
    final data = <String, Object>{};
    for (final key in backupListKeys) {
      final raw = _prefs?.getString(key);
      if (raw != null) data[key] = raw;
    }
    final page = _prefs?.getInt(quranPageKey);
    if (page != null) data[quranPageKey] = page;
    return data;
  }

  /// يستبدل مفاتيح النسخة الاحتياطية بما في [data]؛ الغائب منها يُمسح. لا يمسّ مفتاح Gemini.
  Future<void> replaceBackupData(Map<String, Object> data) async {
    for (final key in backupListKeys) {
      final raw = data[key];
      if (raw is String) {
        await _prefs?.setString(key, raw);
      } else {
        await _prefs?.remove(key);
      }
    }
    final page = data[quranPageKey];
    if (page is int) {
      await _prefs?.setInt(quranPageKey, page.clamp(0, quranPages));
    } else {
      await _prefs?.remove(quranPageKey);
    }
  }

  /// يمسح كل ما في SharedPreferences: المهام والأهداف والمطبخ والملاحظات والمفتاح وغيرها.
  Future<void> eraseAll() async {
    await _prefs?.clear();
  }
}
