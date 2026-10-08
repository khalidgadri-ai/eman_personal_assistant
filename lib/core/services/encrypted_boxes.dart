import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';

/// يفتح صناديق Hive الحساسة (سجل المدرب والمصاريف) مشفّرة بـ AES-256.
///
/// المفتاح عشوائي (256-bit) يُولَّد مرة واحدة عند أول تشغيل ويُحفظ عبر
/// flutter_secure_storage (Android Keystore)، لا بجانب البيانات.
///
/// الصندوق المشفّر ملفه باسم `<name>_enc`: لو فُتح ملف غير مشفّر بمفتاح لاعتبره
/// Hive تالفًا وقصّه بصمت. لذلك تُنسخ بيانات الصندوق القديم غير المشفّر إليه ثم
/// يُحذف ملفه، ولو انقطع النسخ في المنتصف يبقى الملف القديم ويُعاد النسخ كاملًا في
/// التشغيل التالي.
///
/// الملفان المشفّران ومخزن المفتاح مستثناة من النسخ الاحتياطي لأندرويد
/// (`res/xml/backup_rules.xml` و`data_extraction_rules.xml`): مفتاح Keystore لا
/// ينتقل لجوال جديد، فالنسخة المستعادة لا يمكن فكّها. أي صندوق مشفّر جديد يُضاف
/// هناك أيضًا.
class EncryptedBoxes {
  static const String _keyName = 'hive_aes_key';
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static Future<List<int>>? _key;
  static final Map<String, Future<Box>> _opening = {};

  EncryptedBoxes._();

  /// يرجّع نفس الصندوق لكل من يطلبه، حتى لو طُلب من خدمتين في نفس اللحظة.
  static Future<Box> open(String name) {
    final encryptedName = '${name}_enc';
    if (Hive.isBoxOpen(encryptedName)) return Future.value(Hive.box(encryptedName));
    // جسم بأقواس لا سهم: remove يرجّع نفس الـ Future، وwhenComplete ينتظر أي Future
    // يرجّعه الـ callback، فيصير الـ Future ينتظر نفسه للأبد.
    return _opening[name] ??= _openAndMigrate(name, encryptedName).whenComplete(() {
      _opening.remove(name);
    });
  }

  static Future<Box> _openAndMigrate(String name, String encryptedName) async {
    final box = await Hive.openBox(
      encryptedName,
      encryptionCipher: HiveAesCipher(await _encryptionKey()),
    );
    if (await Hive.boxExists(name)) {
      final legacy = await Hive.openBox(name);
      await box.clear();
      await box.putAll(legacy.toMap());
      await legacy.deleteFromDisk();
    }
    return box;
  }

  /// مفتاح واحد مشترك: لو ولّدت خدمتان مفتاحين معًا لكُتب أحدهما فوق الآخر وضاع
  /// صندوق الأولى. وإذا فشلت القراءة تُعاد المحاولة في الطلب التالي.
  static Future<List<int>> _encryptionKey() async {
    final pending = _key ??= _loadOrCreateKey();
    try {
      return await pending;
    } catch (_) {
      if (identical(_key, pending)) _key = null;
      rethrow;
    }
  }

  static Future<List<int>> _loadOrCreateKey() async {
    final stored = await _storage.read(key: _keyName);
    if (stored != null) return base64Url.decode(stored);
    final key = Hive.generateSecureKey();
    await _storage.write(key: _keyName, value: base64UrlEncode(key));
    return key;
  }

  @visibleForTesting
  static void resetForTesting() {
    _key = null;
    _opening.clear();
  }
}
