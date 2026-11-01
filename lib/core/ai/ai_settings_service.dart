import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/database_service.dart';
import 'ai_provider.dart';
import 'provider_presets.dart';

/// إعداد مزوّد الذكاء الاصطناعي المختار. الإعداد (عناوين وأسماء موديلات) في SharedPreferences،
/// و**كل مفتاح في flutter_secure_storage** باسم `ai_key_<المزوّد>`: مفتاح لكل مزوّد، ولا يُرسل
/// إلا إلى مزوّده، ولا يدخل النسخة الاحتياطية ولا السجلات. "مسح كل بياناتي" يمسحه.
class AiSettingsService {
  static const String _keyPrefix = 'ai_key_';
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static Future<AiSettingsService>? _pending;

  AiSettingsService._(this._db);

  final DatabaseService _db;
  String? _selectedId;
  final Map<String, AiProviderConfig> _configs = {};

  static Future<AiSettingsService> getInstance() => _pending ??= _create();

  static Future<AiSettingsService> _create() async {
    try {
      final db = await DatabaseService.getInstance();
      final service = AiSettingsService._(db).._load();
      await service._migrateLegacyKey();
      return service;
    } catch (_) {
      _pending = null;
      rethrow;
    }
  }

  /// يُنسى الإعداد المحفوظ في الذاكرة (بعد مسح بيانات المستخدم، وفي الاختبارات).
  static void reset() => _pending = null;

  @visibleForTesting
  static void resetForTesting() => reset();

  void _load() {
    _selectedId = null;
    _configs.clear();
    final raw = _db.getAiConfigJson();
    if (raw.isEmpty) return;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return;
      final providers = decoded['providers'];
      if (providers is Map) {
        for (final value in providers.values) {
          final config = AiProviderConfig.fromJson(value);
          if (config != null && AiPresets.exists(config.id)) _configs[config.id] = config;
        }
      }
      final selected = decoded['selected'];
      if (selected is String && AiPresets.exists(selected)) _selectedId = selected;
    } catch (_) {
      // إعداد تالف: نبدأ فارغين بدل أن يتوقف التطبيق.
    }
  }

  Future<void> _persist() {
    return _db.saveAiConfigJson(jsonEncode({
      'selected': _selectedId,
      'providers': {for (final e in _configs.entries) e.key: e.value.toJson()},
    }));
  }

  String? get selectedId => _selectedId;

  /// المزوّد المختار حاليًا، أو null إن لم يختر المستخدم بعد.
  AiProviderConfig? get selected {
    final id = _selectedId;
    return id == null ? null : configFor(id);
  }

  /// إعداد المزوّد المحفوظ، وإلا الإعداد الابتدائي من القائمة الجاهزة.
  AiProviderConfig configFor(String presetId) =>
      _configs[presetId] ?? AiPresets.byId(presetId).defaultConfig;

  /// يحفظ [config] (بعد التحقق من العنوان واسم الموديل) ويختاره مزوّدًا فعّالًا.
  Future<void> save(AiProviderConfig config, {bool select = true}) async {
    config.validate();
    _configs[config.id] = config;
    if (select) _selectedId = config.id;
    await _persist();
  }

  Future<String> readKey(String providerId) async {
    try {
      return ((await _storage.read(key: '$_keyPrefix$providerId')) ?? '').trim();
    } catch (e) {
      debugPrint('AiSettingsService: could not read key (${e.runtimeType})');
      return '';
    }
  }

  Future<bool> hasKey(String providerId) async => (await readKey(providerId)).isNotEmpty;

  /// مفتاح فارغ = حذف.
  Future<void> saveKey(String providerId, String key) async {
    final clean = key.trim();
    if (clean.isEmpty) {
      await deleteKey(providerId);
      return;
    }
    await _storage.write(key: '$_keyPrefix$providerId', value: clean);
  }

  Future<void> deleteKey(String providerId) => _storage.delete(key: '$_keyPrefix$providerId');

  /// آخر 4 أحرف فقط؛ عرض أكثر من ذلك يسهّل تخمين المفتاح.
  Future<String> keyPreview(String providerId) async {
    final key = await readKey(providerId);
    if (key.isEmpty) return '';
    return key.length <= 8 ? '••••' : '••••${key.substring(key.length - 4)}';
  }

  /// مفتاح Gemini كان في SharedPreferences (غير مشفّرة وتدخل النسخ التلقائي لـ Google).
  /// ينتقل لمرة واحدة إلى التخزين الآمن ثم يُمسح من مكانه القديم. لو فشلت الكتابة يبقى
  /// حيث هو وتُعاد المحاولة في التشغيل التالي.
  Future<void> _migrateLegacyKey() async {
    final legacy = _db.readLegacyGeminiKey();
    if (legacy.isEmpty) return;
    try {
      if (!await hasKey(AiPresets.geminiId)) await saveKey(AiPresets.geminiId, legacy);
      if (_selectedId == null) {
        _configs.putIfAbsent(AiPresets.geminiId, () => AiPresets.byId(AiPresets.geminiId).defaultConfig);
        _selectedId = AiPresets.geminiId;
        await _persist();
      }
      await _db.removeLegacyGeminiKey();
    } catch (e) {
      debugPrint('AiSettingsService: legacy key migration deferred (${e.runtimeType})');
    }
  }
}
