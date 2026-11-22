import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'models/meditation_session.dart';
import 'tone_generator.dart';

/// ملفات WAV المولَّدة، تُكتب مرة واحدة في مجلد التطبيق المؤقت ويُعاد استعمالها.
class ToneFiles {
  const ToneFiles({
    required this.binaural,
    required this.isochronic,
    required this.silence,
    required this.bell,
  });

  final String binaural;
  final String isochronic;
  final String silence;
  final String bell;

  /// رفع الرقم يعيد توليد الملفات بعد تغيير المولِّد.
  static const int version = 1;

  String loopFor(ToneBackground background) => switch (background) {
        ToneBackground.none => silence,
        ToneBackground.gammaBinaural => binaural,
        ToneBackground.gammaIsochronic => isochronic,
      };

  static Future<ToneFiles> ensure() async {
    final dir = await getTemporaryDirectory();
    Future<String> write(String name, Uint8List Function() build) async {
      final file = File('${dir.path}${Platform.pathSeparator}meditation_${name}_v$version.wav');
      if (!await file.exists()) {
        await file.writeAsBytes(build(), flush: true);
      }
      return file.path;
    }

    return ToneFiles(
      binaural: await write('gamma_binaural', ToneGenerator.binauralGamma),
      isochronic: await write('gamma_isochronic', ToneGenerator.isochronicGamma),
      silence: await write('silence', ToneGenerator.silence),
      bell: await write('bell', ToneGenerator.bell),
    );
  }
}
