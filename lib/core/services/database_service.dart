import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DatabaseService {
  static DatabaseService? _instance;
  static SharedPreferences? _prefs;

  DatabaseService._();

  static Future<DatabaseService> getInstance() async {
    _instance ??= DatabaseService._();
    _prefs ??= await SharedPreferences.getInstance();
    return _instance!;
  }

  // --- Daily Tasks ---
  List<Map<String, dynamic>> getDailyTasks() {
    final String? raw = _prefs?.getString('daily_tasks');
    if (raw == null) {
      return [
        {'title': 'قراءة الورد اليومي (سورة البقرة)', 'category': 'شخصي', 'done': true},
        {'title': 'مراجعة واجبات الأطفال وتحضير حقيبة المدرسه', 'category': 'الأطفال', 'done': false},
        {'title': 'تنظيف وتعقيم غسيل الملابس البيضاء', 'category': 'المنزل', 'done': false},
        {'title': 'أخذ المكملات الغذائية وفيتامين د', 'category': 'شخصي', 'done': true},
      ];
    }
    // ✅ إصلاح: طريقة آمنة للـ Type Cast تمنع TypeError exception
    final List decoded = jsonDecode(raw);
    return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<void> saveDailyTasks(List<Map<String, dynamic>> tasks) async {
    await _prefs?.setString('daily_tasks', jsonEncode(tasks));
  }

  // --- Quran Page ---
  int getQuranPage() {
    return _prefs?.getInt('quran_page') ?? 142;
  }

  Future<void> saveQuranPage(int page) async {
    await _prefs?.setInt('quran_page', page);
  }

  // --- Medications ---
  List<Map<String, dynamic>> getMedications() {
    final String? raw = _prefs?.getString('medications');
    if (raw == null) {
      return [
        {'name': 'فيتامين د3 (5000 وحدة)', 'time': '09:00 صباحاً', 'taken': true},
        {'name': 'أوميغا 3 (زيت السمك)', 'time': '02:00 مساءً', 'taken': false},
        {'name': 'كولاجين للبشرة والشعر', 'time': '09:00 مساءً', 'taken': false},
      ];
    }
    // ✅ إصلاح: طريقة آمنة للـ Type Cast
    final List decoded = jsonDecode(raw);
    return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<void> saveMedications(List<Map<String, dynamic>> meds) async {
    await _prefs?.setString('medications', jsonEncode(meds));
  }

  // --- Pantry Inventory ---
  List<Map<String, dynamic>> getPantry() {
    final String? raw = _prefs?.getString('pantry');
    if (raw == null) {
      return [
        {'name': 'زيت زيتون بكر ممتاز', 'qty': '2 لتر', 'category': 'الزيوت والبهارات'},
        {'name': 'مكسرات مشكلة (جوز ولوز)', 'qty': '500 جرام', 'category': 'المكسرات'},
        {'name': 'منظف ومطهر الصحون', 'qty': '1 عبوة', 'category': 'مستلزمات التنظيف'},
      ];
    }
    // ✅ إصلاح: طريقة آمنة للـ Type Cast
    final List decoded = jsonDecode(raw);
    return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<void> savePantry(List<Map<String, dynamic>> pantry) async {
    await _prefs?.setString('pantry', jsonEncode(pantry));
  }

  // --- Gemini API Key (Dynamic Key Management) ---
  /// يُرجع مفتاح Gemini API المحفوظ من قِبَل المستخدم، أو سلسلة فارغة إن لم يُضبط بعد.
  String getGeminiApiKey() {
    return _prefs?.getString('gemini_api_key') ?? '';
  }

  /// يحفظ مفتاح Gemini API الذي أدخله المستخدم محلياً في SharedPreferences.
  Future<void> saveGeminiApiKey(String key) async {
    await _prefs?.setString('gemini_api_key', key.trim());
  }

  // --- User Feedback ---
  List<Map<String, dynamic>> getFeedbackEntries() {
    final String? raw = _prefs?.getString('feedback_entries');
    if (raw == null) return [];
    final List decoded = jsonDecode(raw);
    return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<void> saveFeedbackEntry(String text) async {
    final entries = getFeedbackEntries();
    entries.add({'text': text, 'date': DateTime.now().toIso8601String()});
    await _prefs?.setString('feedback_entries', jsonEncode(entries));
  }
}
