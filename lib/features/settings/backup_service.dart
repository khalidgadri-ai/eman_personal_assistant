import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart';
import '../../core/services/database_service.dart';
import '../../core/services/encrypted_boxes.dart';
import '../reminders/reminder_service.dart';

/// سبب فشل النسخ الاحتياطي أو الاستعادة. الرسالة للمستخدم ثابتة بالعربية: لا نص خطأ خام
/// ولا مسارات ولا كلمة المرور تصل إلى الشاشة.
enum BackupFailure {
  weakPassword('كلمة المرور قصيرة: يلزم ${BackupService.minPasswordLength} أحرف على الأقل.'),
  notABackup('هذا الملف ليس نسخة احتياطية من هذا التطبيق.'),
  unsupportedVersion('هذه النسخة أحدث من إصدار التطبيق الحالي. يرجى تحديث التطبيق ثم إعادة المحاولة.'),
  wrongPasswordOrCorrupt('كلمة المرور غير صحيحة، أو أن الملف تالف.'),
  restoreFailed('تعذّرت الاستعادة، وأُعيدت البيانات كما كانت.'),
  restoreFailedUnsafe('تعذّرت الاستعادة وقد تكون البيانات ناقصة. يرجى إعادة المحاولة بنفس الملف.');

  const BackupFailure(this.message);
  final String message;
}

class BackupException implements Exception {
  const BackupException(this.reason);

  final BackupFailure reason;

  String get message => reason.message;

  @override
  String toString() => 'BackupException(${reason.name})';
}

/// نسخة احتياطية مشفّرة بكلمة مرور يحفظها المستخدم بنفسه (ملف `.emanbak`).
///
/// الملف: `EMANBK` + رقم الإصدار (1 بايت) + عدد دورات PBKDF2 (4 بايت) + salt (16) + nonce (12)
/// ثم النص المشفّر بـ AES-256-GCM وعلامة التحقق (16 بايت). الترويسة كلها جزء من البيانات
/// المصادَق عليها (AAD)، فأي تعديل فيها أو في المحتوى يفشل فكّه. المفتاح يُشتق من كلمة
/// المرور بـ PBKDF2-HMAC-SHA256، وكلمة المرور لا تُحفظ في أي مكان.
///
/// المشمول: الملف الشخصي والصحة (الأدوية والعناية والتمارين وسجلها وصورها) والمصاريف وجلسات المدرب (الصناديق المشفّرة) والمهام والأهداف
/// والمطبخ والغسيل والملاحظات وصفحة الورد. **غير المشمول عمدًا:** مفاتيح الذكاء الاصطناعي (سرّ المستخدم
/// ويُدخل من جديد في ثوانٍ)، حالة الاشتراك (مرجعها Google Play)، ولقطة وعي الاستخدام لليوم.
class BackupService {
  static const int minPasswordLength = 8;
  static const int formatVersion = 1;

  /// توصية OWASP لـ PBKDF2-HMAC-SHA256. الرقم يُكتب في الملف، فيمكن رفعه لاحقًا دون كسر القديم.
  static const int defaultIterations = 600000;

  /// صناديق Hive المشفّرة المشمولة. تتبع `DataResetService.userBoxes` (بدون `app_usage`).
  static const List<String> boxNames = [
    'profile',
    'health',
    'expenses',
    'budget_plan',
    'coach_sessions',
    'exercise_images',
  ];

  static const String fileExtension = 'emanbak';

  /// أكبر ملف يُقرأ في الذاكرة؛ النسخة الحقيقية بضع عشرات من الكيلوبايت، وما فوق هذا خطأ في اختيار الملف.
  static const int maxFileBytes = 50 * 1024 * 1024;

  static final List<int> _magic = utf8.encode('EMANBK');
  static const int _saltLength = 16;
  static const int _nonceLength = 12;
  static const int _macLength = 16;
  static const int _maxIterations = 10000000;
  static final int _headerLength = _magic.length + 1 + 4 + _saltLength + _nonceLength;

  BackupService._();

  /// اسم ملف مقترح بتاريخ اليوم.
  static String suggestedFileName([DateTime? now]) {
    final d = now ?? DateTime.now();
    String two(int n) => n.toString().padLeft(2, '0');
    return 'eman-backup-${d.year}-${two(d.month)}-${two(d.day)}.$fileExtension';
  }

  /// يبني ملف نسخة احتياطية مشفّر من بيانات الجهاز الحالية.
  /// [iterations] يتغيّر في الاختبارات فقط.
  static Future<Uint8List> createBackup(
    String password, {
    int iterations = defaultIterations,
    DateTime? now,
  }) async {
    _checkPassword(password);
    final snapshot = await _snapshot(createdAt: now);
    final plain = utf8.encode(jsonEncode(snapshot));

    final salt = _randomBytes(_saltLength);
    final nonce = _randomBytes(_nonceLength);
    final header = _buildHeader(iterations, salt, nonce);
    final key = await _deriveKey(password, salt, iterations);
    final box = await AesGcm.with256bits().encrypt(
      plain,
      secretKey: key,
      nonce: nonce,
      aad: header,
    );
    return Uint8List.fromList([...header, ...box.cipherText, ...box.mac.bytes]);
  }

  /// يفكّ [bytes] بكلمة المرور ويستبدل بيانات الجهاز بما فيها. لا يُكتب شيء قبل نجاح الفك
  /// والتحقق من الشكل كاملًا، ولو فشلت الكتابة تُعاد البيانات السابقة. يرجّع تاريخ إنشاء النسخة.
  static Future<DateTime?> restoreBackup(Uint8List bytes, String password) async {
    if (bytes.length > maxFileBytes) throw const BackupException(BackupFailure.notABackup);
    final snapshot = await _decrypt(bytes, password);
    final incoming = _Snapshot.parse(snapshot);

    final previous = await _snapshot();
    try {
      await _apply(incoming);
    } catch (e) {
      debugPrint('BackupService: restore failed (${e.runtimeType})');
      try {
        await _apply(_Snapshot.parse(previous));
      } catch (rollbackError) {
        debugPrint('BackupService: rollback failed (${rollbackError.runtimeType})');
        throw const BackupException(BackupFailure.restoreFailedUnsafe);
      }
      throw const BackupException(BackupFailure.restoreFailed);
    }
    // التذكيرات تتبع البيانات المستعادة: القديمة تُلغى وتُجدول تذكيرات النسخة.
    await ReminderService.syncAll();
    return incoming.createdAt;
  }

  // --- الترميز ---

  static void _checkPassword(String password) {
    if (password.runes.length < minPasswordLength) {
      throw const BackupException(BackupFailure.weakPassword);
    }
  }

  static List<int> _buildHeader(int iterations, List<int> salt, List<int> nonce) {
    final iter = ByteData(4)..setUint32(0, iterations);
    return [..._magic, formatVersion, ...iter.buffer.asUint8List(), ...salt, ...nonce];
  }

  static Future<Map<String, dynamic>> _decrypt(Uint8List bytes, String password) async {
    if (bytes.length < _headerLength + _macLength) {
      throw const BackupException(BackupFailure.notABackup);
    }
    for (var i = 0; i < _magic.length; i++) {
      if (bytes[i] != _magic[i]) throw const BackupException(BackupFailure.notABackup);
    }
    final version = bytes[_magic.length];
    if (version > formatVersion) throw const BackupException(BackupFailure.unsupportedVersion);
    if (version < 1) throw const BackupException(BackupFailure.notABackup);

    final iterations = ByteData.sublistView(bytes, _magic.length + 1, _magic.length + 5).getUint32(0);
    // رقم خارج المعقول ملف تالف أو مصنوع لإرهاق الجهاز.
    if (iterations < 1 || iterations > _maxIterations) {
      throw const BackupException(BackupFailure.notABackup);
    }

    final saltStart = _magic.length + 5;
    final salt = bytes.sublist(saltStart, saltStart + _saltLength);
    final nonce = bytes.sublist(saltStart + _saltLength, _headerLength);
    final header = bytes.sublist(0, _headerLength);
    final cipherText = bytes.sublist(_headerLength, bytes.length - _macLength);
    final mac = Mac(bytes.sublist(bytes.length - _macLength));

    final key = await _deriveKey(password, salt, iterations);
    final List<int> plain;
    try {
      plain = await AesGcm.with256bits().decrypt(
        SecretBox(cipherText, nonce: nonce, mac: mac),
        secretKey: key,
        aad: header,
      );
    } on SecretBoxAuthenticationError {
      throw const BackupException(BackupFailure.wrongPasswordOrCorrupt);
    }

    try {
      final decoded = jsonDecode(utf8.decode(plain));
      if (decoded is Map<String, dynamic>) return decoded;
    } catch (_) {
      // يسقط إلى الخطأ أدناه.
    }
    throw const BackupException(BackupFailure.notABackup);
  }

  static Future<SecretKey> _deriveKey(String password, List<int> salt, int iterations) async {
    // 600 ألف دورة عمل ثقيل: خارج خيط الواجهة حتى لا تتجمّد الشاشة.
    final keyBytes = await compute(
      _deriveKeyBytes,
      _KdfParams(password, Uint8List.fromList(salt), iterations),
    );
    return SecretKey(keyBytes);
  }

  static List<int> _randomBytes(int length) {
    final random = SecureRandom.defaultRandom;
    return List<int>.generate(length, (_) => random.nextInt(256));
  }

  // --- قراءة البيانات الحالية وكتابتها ---

  static Future<Map<String, dynamic>> _snapshot({DateTime? createdAt}) async {
    final db = await DatabaseService.getInstance();
    final boxes = <String, dynamic>{};
    for (final name in boxNames) {
      final box = await EncryptedBoxes.open(name);
      boxes[name] = [
        for (final entry in box.toMap().entries) [_encodeKey(entry.key), _encode(entry.value)],
      ];
    }
    return {
      'app': 'eman',
      'created': (createdAt ?? DateTime.now()).toUtc().toIso8601String(),
      'prefs': db.exportBackupData(),
      'boxes': boxes,
    };
  }

  /// للاختبارات فقط: يُستدعى قبل كتابة كل صندوق، ليُحاكي فشل القرص في منتصف الاستعادة.
  @visibleForTesting
  static Future<void> Function(String boxName)? beforeBoxWrite;

  static Future<void> _apply(_Snapshot snapshot) async {
    final db = await DatabaseService.getInstance();
    await db.replaceBackupData(snapshot.prefs);
    for (final name in boxNames) {
      await beforeBoxWrite?.call(name);
      final box = await EncryptedBoxes.open(name);
      await box.clear();
      await box.putAll(snapshot.boxes[name] ?? const {});
    }
  }

  static Object _encodeKey(dynamic key) {
    if (key is int || key is String) return key as Object;
    throw StateError('Unsupported box key type');
  }

  /// Hive يخزّن Map وList وأرقامًا ونصوصًا وتواريخ: التاريخ وحده يحتاج وسمًا في JSON.
  static Object? _encode(Object? value) {
    if (value == null || value is bool || value is int || value is String) return value;
    if (value is double) {
      if (!value.isFinite) throw StateError('Unsupported number');
      return value;
    }
    if (value is DateTime) {
      return {_dateTag: value.microsecondsSinceEpoch, if (value.isUtc) _utcTag: true};
    }
    // صور التمارين: بايتات خام في صندوق مشفّر، تُحمل في الملف base64 (والملف كله مشفّر).
    if (value is Uint8List) return {_bytesTag: base64Encode(value)};
    if (value is List) return [for (final item in value) _encode(item)];
    if (value is Map) {
      final result = <String, Object?>{};
      for (final entry in value.entries) {
        final key = entry.key;
        if (key is! String) throw StateError('Unsupported map key type');
        result[key] = _encode(entry.value);
      }
      return result;
    }
    throw StateError('Unsupported value type');
  }

  static Object? _decode(Object? value) {
    if (value is List) return [for (final item in value) _decode(item)];
    if (value is Map) {
      final bytes = value[_bytesTag];
      if (bytes is String) return Uint8List.fromList(base64Decode(bytes));
      final micros = value[_dateTag];
      if (micros is int) {
        return DateTime.fromMicrosecondsSinceEpoch(micros, isUtc: value[_utcTag] == true);
      }
      return {for (final entry in value.entries) entry.key as String: _decode(entry.value)};
    }
    return value;
  }

  static const String _dateTag = r'$dt';
  static const String _utcTag = r'$utc';
  static const String _bytesTag = r'$b64';
}

class _KdfParams {
  const _KdfParams(this.password, this.salt, this.iterations);

  final String password;
  final Uint8List salt;
  final int iterations;
}

/// دالة عليا لأن `compute` يشغّلها في خيط آخر.
Future<List<int>> _deriveKeyBytes(_KdfParams params) async {
  final key = await Pbkdf2(
    macAlgorithm: Hmac.sha256(),
    iterations: params.iterations,
    bits: 256,
  ).deriveKeyFromPassword(password: params.password, nonce: params.salt);
  return key.extractBytes();
}

/// محتوى الملف بعد فكّه والتحقق من أنواعه، جاهز للكتابة.
class _Snapshot {
  _Snapshot(this.createdAt, this.prefs, this.boxes);

  final DateTime? createdAt;
  final Map<String, Object> prefs;
  final Map<String, Map<dynamic, dynamic>> boxes;

  static const List<String> _listKeys = DatabaseService.backupListKeys;

  static _Snapshot parse(Map<String, dynamic> json) {
    try {
      if (json['app'] != 'eman') throw const FormatException('not eman');
      final created = DateTime.tryParse((json['created'] as String?) ?? '');

      final prefs = <String, Object>{};
      final rawPrefs = (json['prefs'] as Map?) ?? const {};
      for (final key in _listKeys) {
        final raw = rawPrefs[key];
        if (raw == null) continue;
        if (raw is! String || jsonDecode(raw) is! List) throw FormatException('bad $key');
        prefs[key] = raw;
      }
      final page = rawPrefs[DatabaseService.quranPageKey];
      if (page != null) {
        if (page is! int) throw const FormatException('bad quran_page');
        prefs[DatabaseService.quranPageKey] = page;
      }

      final boxes = <String, Map<dynamic, dynamic>>{};
      final rawBoxes = (json['boxes'] as Map?) ?? const {};
      for (final name in BackupService.boxNames) {
        final entries = rawBoxes[name];
        if (entries == null) continue;
        final map = <dynamic, dynamic>{};
        for (final entry in entries as List) {
          final pair = entry as List;
          final key = pair[0];
          if (key is! int && key is! String) throw const FormatException('bad key');
          map[key] = BackupService._decode(pair[1]);
        }
        boxes[name] = map;
      }
      return _Snapshot(created, prefs, boxes);
    } on BackupException {
      rethrow;
    } catch (_) {
      throw const BackupException(BackupFailure.notABackup);
    }
  }
}
