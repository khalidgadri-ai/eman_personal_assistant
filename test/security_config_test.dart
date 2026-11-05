import 'dart:io';

import 'package:eman_life_app/features/settings/backup_service.dart';
import 'package:flutter_test/flutter_test.dart';

/// فحوص أمان ثابتة على ملفات المشروع نفسها: لا مفتاح حقيقي في أي ملف يُشحن، ولا صلاحية
/// أندرويد غير متوقعة، والصناديق المشفّرة ومخزن مفاتيحها خارج النسخ الاحتياطي التلقائي.
void main() {
  group('no real-looking secret is shipped', () {
    // مفتاح Google الحقيقي: AIza + 35 حرفًا. مفاتيح OpenAI وAnthropic تبدأ بـ sk-.
    final secretPatterns = [
      RegExp(r'AIza[0-9A-Za-z_\-]{35}'),
      RegExp(r'sk-ant-[0-9A-Za-z_\-]{20,}'),
      RegExp(r'sk-(proj-)?[0-9A-Za-z]{32,}'),
    ];

    List<File> filesUnder(String path) {
      final entity = FileSystemEntity.typeSync(path);
      if (entity == FileSystemEntityType.file) return [File(path)];
      if (entity != FileSystemEntityType.directory) return [];
      return Directory(path)
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => !f.path.contains('${Platform.pathSeparator}build${Platform.pathSeparator}'))
          .toList();
    }

    test('in the app code, assets, Android sources and web files', () {
      final files = [
        for (final path in ['lib', 'assets', 'android/app/src', 'web', 'pubspec.yaml']) ...filesUnder(path),
      ];
      expect(files, isNotEmpty);
      for (final file in files) {
        final String text;
        try {
          text = file.readAsStringSync();
        } on FileSystemException {
          continue; // صورة أو ملف ثنائي.
        }
        for (final pattern in secretPatterns) {
          // لا نطبع المطابقة نفسها: اسم الملف يكفي.
          expect(pattern.hasMatch(text), isFalse, reason: 'a key-like string is in ${file.path}');
        }
      }
    });
  });

  group('AndroidManifest.xml', () {
    final manifest = File('android/app/src/main/AndroidManifest.xml').readAsStringSync();

    test('declares only the three expected permissions', () {
      final declared = RegExp(r'<uses-permission\s+android:name="([^"]+)"')
          .allMatches(manifest)
          .map((m) => m.group(1))
          .toSet();
      expect(declared, {
        'android.permission.INTERNET',
        'android.permission.PACKAGE_USAGE_STATS',
        'android.permission.RECEIVE_BOOT_COMPLETED',
      });
    });

    test('never asks for exact alarms, all packages, camera, photos or the microphone', () {
      for (final forbidden in [
        'SCHEDULE_EXACT_ALARM',
        'USE_EXACT_ALARM',
        'QUERY_ALL_PACKAGES',
        'CAMERA',
        'READ_MEDIA_IMAGES',
        'READ_EXTERNAL_STORAGE',
        'RECORD_AUDIO',
      ]) {
        expect(manifest.contains('permission.$forbidden'), isFalse, reason: forbidden);
      }
    });

    test('allows no plain-http traffic and exports only the launcher activity', () {
      expect(manifest.contains('usesCleartextTraffic="true"'), isFalse);
      final receivers = RegExp(r'<receiver\b[^>]*>').allMatches(manifest).map((m) => m.group(0)!).toList();
      expect(receivers, isNotEmpty);
      for (final receiver in receivers) {
        expect(receiver, contains('android:exported="false"'));
      }
      expect(RegExp(r'android:exported="true"').allMatches(manifest).length, 1);
    });
  });

  group('Auto Backup and device transfer', () {
    final backupRules = File('android/app/src/main/res/xml/backup_rules.xml').readAsStringSync();
    final extraction = File('android/app/src/main/res/xml/data_extraction_rules.xml').readAsStringSync();

    String section(String tag) {
      final match = RegExp('<$tag>(.*?)</$tag>', dotAll: true).firstMatch(extraction);
      expect(match, isNotNull, reason: '<$tag> is missing');
      return match!.group(1)!;
    }

    // يُبنى داخل كل اختبار: expect خارج test() غير مسموح.
    Map<String, String> sections() => {
          'backup_rules.xml': backupRules,
          'cloud-backup': section('cloud-backup'),
          'device-transfer': section('device-transfer'),
        };

    test('exclude every encrypted box, since its Keystore key cannot move to a new phone', () {
      for (final MapEntry(key: where, value: rules) in sections().entries) {
        for (final box in BackupService.boxNames) {
          expect(rules, contains('path="app_flutter/${box}_enc.hive"'), reason: '$box in $where');
        }
      }
    });

    test('exclude the secure storage that holds the encryption and provider keys', () {
      for (final MapEntry(key: where, value: rules) in sections().entries) {
        expect(rules, contains('path="FlutterSecureStorage.xml"'), reason: where);
        expect(rules, contains('path="FlutterSecureKeyStorage.xml"'), reason: where);
      }
    });
  });
}
