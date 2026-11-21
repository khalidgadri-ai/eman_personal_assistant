import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'models/meditation_session.dart';

/// جلسات التأمل من `assets/meditation/sessions.json`، وما يظهر منها حسب التسجيلات الموجودة.
abstract final class MeditationCatalog {
  static const String asset = 'assets/meditation/sessions.json';

  /// جلسة تعريفها غير صالح تُترك (ولا يتعطل الباقي).
  static Future<List<MeditationSession>> load({AssetBundle? bundle}) async {
    final raw = await (bundle ?? rootBundle).loadString(asset);
    return parse(raw);
  }

  static List<MeditationSession> parse(String raw) {
    final sessions = <MeditationSession>[];
    for (final entry in jsonDecode(raw) as List) {
      try {
        sessions.add(MeditationSession.fromJson(Map<String, dynamic>.from(entry as Map)));
      } on FormatException catch (e) {
        debugPrint('MeditationCatalog: skipped a session (${e.message})');
      }
    }
    return sessions;
  }

  /// أسماء كل الملفات داخل التطبيق، لمعرفة أي تسجيلات وصلت.
  static Future<Set<String>> bundledAssets({AssetBundle? bundle}) async {
    final manifest = await AssetManifest.loadFromAssetBundle(bundle ?? rootBundle);
    return manifest.listAssets().toSet();
  }

  /// الجلسة المرشدة تظهر فقط حين تكتمل كل مقاطعها. الحركية تعمل بالأجراس ونص المرحلة
  /// حتى تصل التسجيلات، والمؤقت وجاما لا يحتاجان صوت مرشد.
  static List<MeditationSession> available(List<MeditationSession> all, Set<String> assets, {String lang = 'ar'}) => [
        for (final session in all)
          if (session.kind != MeditationKind.guided || session.clipAssetsFor(lang).every(assets.contains)) session,
      ];
}
