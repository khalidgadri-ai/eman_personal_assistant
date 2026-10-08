import 'dart:convert';
import 'dart:io';

import 'package:eman_life_app/core/services/encrypted_boxes.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  late Directory hiveDir;
  const secret = 'إجابة خاصة جدًا عن الميزانية';

  setUp(() {
    hiveDir = Directory.systemTemp.createTempSync('encrypted_boxes_test');
    Hive.init(hiveDir.path);
    FlutterSecureStorage.setMockInitialValues({});
    EncryptedBoxes.resetForTesting();
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    hiveDir.deleteSync(recursive: true);
  });

  /// يبحث عن النص كبايتات UTF-8 داخل ملف الصندوق كما هو على القرص.
  bool fileContains(String boxName, String text) {
    final raw = latin1.decode(File('${hiveDir.path}/$boxName.hive').readAsBytesSync());
    return raw.contains(latin1.decode(utf8.encode(text)));
  }

  /// يحاكي إعادة تشغيل التطبيق: الصناديق تُغلق والمفتاح يبقى في التخزين الآمن فقط.
  Future<void> restartApp() async {
    await Hive.close();
    EncryptedBoxes.resetForTesting();
  }

  test('writes nothing readable to disk, unlike a plain box', () async {
    final plain = await Hive.openBox('plain_control');
    await plain.add({'answerText': secret});
    final box = await EncryptedBoxes.open('coach_sessions');
    await box.add({'answerText': secret});
    await Hive.close();

    expect(fileContains('plain_control', secret), isTrue);
    expect(fileContains('coach_sessions_enc', secret), isFalse);
  });

  test('moves an existing plain box into the encrypted one and deletes the plain file', () async {
    final legacy = await Hive.openBox('expenses');
    await legacy.add({'amount': 45.5, 'note': secret, 'date': DateTime(2026, 10, 1)});
    await legacy.add({'amount': 120.0, 'note': null, 'date': DateTime(2026, 10, 15)});
    await legacy.close();

    final box = await EncryptedBoxes.open('expenses');

    expect(box.keys.toList(), [0, 1]);
    expect((box.get(0) as Map)['note'], secret);
    expect((box.get(1) as Map)['date'], DateTime(2026, 10, 15));
    expect(await Hive.boxExists('expenses'), isFalse);
    expect(await box.add({'amount': 1.0}), 2, reason: 'new entries must not overwrite migrated ones');
  });

  test('reopens the same data after a restart with the stored key', () async {
    final box = await EncryptedBoxes.open('coach_sessions');
    await box.add({'answerText': secret});
    await restartApp();

    final reopened = await EncryptedBoxes.open('coach_sessions');
    expect((reopened.get(0) as Map)['answerText'], secret);
  });

  test('concurrent first opens share one box and one key', () async {
    final opened = await Future.wait([
      EncryptedBoxes.open('coach_sessions'),
      EncryptedBoxes.open('coach_sessions'),
      EncryptedBoxes.open('expenses'),
    ]);
    expect(identical(opened[0], opened[1]), isTrue);
    await opened[0].add({'answerText': secret});
    await opened[2].add({'amount': 10.0});
    await restartApp();

    // مفتاحان مختلفان كانا سيجعلان أحد الصندوقين غير قابل للفك بعد إعادة التشغيل.
    expect(((await EncryptedBoxes.open('coach_sessions')).get(0) as Map)['answerText'], secret);
    expect(((await EncryptedBoxes.open('expenses')).get(0) as Map)['amount'], 10.0);
  });

  test('an interrupted migration is redone from the plain copy on the next start', () async {
    final partial = await EncryptedBoxes.open('coach_sessions');
    await partial.add({'answerText': 'نسخة ناقصة من محاولة سابقة'});
    await Hive.close();
    final legacy = await Hive.openBox('coach_sessions');
    await legacy.add({'answerText': secret});
    await restartApp();

    final box = await EncryptedBoxes.open('coach_sessions');
    expect(box.values.map((e) => (e as Map)['answerText']).toList(), [secret]);
    expect(await Hive.boxExists('coach_sessions'), isFalse);
  });
}
