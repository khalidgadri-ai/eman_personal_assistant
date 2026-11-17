import 'dart:math';
import 'dart:typed_data';

/// أصوات التأمل تُولَّد على الجوال: لا ملفات من طرف ثالث ولا تراخيص.
/// كلها PCM ‏16-bit ستيريو 44.1kHz في ملف WAV.
abstract final class ToneGenerator {
  static const int sampleRate = 44100;
  static const int channels = 2;

  /// مدة حلقة الخلفية. كل الترددات المستعملة تكمل دوراتها في ثانية واحدة، فلا طقطقة عند التكرار.
  static const int loopSeconds = 10;

  /// أعلى مستوى للنغمات (من 1): هادئ حتى قبل شريط الصوت.
  static const double toneAmplitude = 0.25;

  static const double binauralLeftHz = 200;
  static const double binauralRightHz = 240;
  static const double isochronicCarrierHz = 300;
  static const double gammaHz = 40;

  /// جاما مزدوجة (تحتاج سماعات): 200 هرتز يسارًا و240 يمينًا، والفرق 40.
  static Uint8List binauralGamma({int seconds = loopSeconds}) => _render(seconds, (i) {
        final t = i / sampleRate;
        return (
          toneAmplitude * sin(2 * pi * binauralLeftHz * t),
          toneAmplitude * sin(2 * pi * binauralRightHz * t),
        );
      });

  /// جاما نبضية (بلا سماعات): نغمة 300 هرتز ترتفع وتنخفض بنعومة 40 مرة في الثانية، والقناتان سواء.
  static Uint8List isochronicGamma({int seconds = loopSeconds}) => _render(seconds, (i) {
        final t = i / sampleRate;
        final envelope = 0.5 * (1 - cos(2 * pi * gammaHz * t));
        final v = toneAmplitude * envelope * sin(2 * pi * isochronicCarrierHz * t);
        return (v, v);
      });

  /// صمت لمشغّل الخلفية في المؤقت الصامت: يبقي ساعة الجلسة تعمل والشاشة مطفأة.
  static Uint8List silence({int seconds = loopSeconds}) => _render(seconds, (_) => (0, 0));

  /// جرس هادئ: ترددات متراكبة تنطفئ تدريجيًا في حوالي 4 ثوانٍ.
  static Uint8List bell({double seconds = 4}) {
    const base = 432.0;
    const partials = [(1.0, 1.0), (2.0, 0.45), (2.76, 0.3), (5.4, 0.12)];
    return _render((seconds * sampleRate).round(), (i) {
      final t = i / sampleRate;
      final attack = min(1.0, t / 0.01);
      var v = 0.0;
      for (final (ratio, gain) in partials) {
        v += gain * exp(-t * (0.9 + ratio * 0.35)) * sin(2 * pi * base * ratio * t);
      }
      final s = 0.32 * attack * v;
      return (s, s);
    }, samplesGiven: true);
  }

  static Uint8List _render(
    int length,
    (double, double) Function(int sample) at, {
    bool samplesGiven = false,
  }) {
    final frames = samplesGiven ? length : length * sampleRate;
    final data = ByteData(44 + frames * channels * 2);
    _writeHeader(data, frames);
    var offset = 44;
    for (var i = 0; i < frames; i++) {
      final (left, right) = at(i);
      data.setInt16(offset, _pcm(left), Endian.little);
      data.setInt16(offset + 2, _pcm(right), Endian.little);
      offset += 4;
    }
    return data.buffer.asUint8List();
  }

  static int _pcm(double v) => (v.clamp(-1.0, 1.0) * 32767).round();

  static void _writeHeader(ByteData data, int frames) {
    final dataBytes = frames * channels * 2;
    void ascii(int at, String s) {
      for (var i = 0; i < s.length; i++) {
        data.setUint8(at + i, s.codeUnitAt(i));
      }
    }

    ascii(0, 'RIFF');
    data.setUint32(4, 36 + dataBytes, Endian.little);
    ascii(8, 'WAVE');
    ascii(12, 'fmt ');
    data.setUint32(16, 16, Endian.little); // حجم قسم fmt
    data.setUint16(20, 1, Endian.little); // PCM
    data.setUint16(22, channels, Endian.little);
    data.setUint32(24, sampleRate, Endian.little);
    data.setUint32(28, sampleRate * channels * 2, Endian.little); // بايت في الثانية
    data.setUint16(32, channels * 2, Endian.little); // بايت لكل إطار
    data.setUint16(34, 16, Endian.little); // بت لكل عيّنة
    ascii(36, 'data');
    data.setUint32(40, dataBytes, Endian.little);
  }
}
