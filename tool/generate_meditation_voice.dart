// يولّد صوت المرشد لجلسات التأمل من docs/meditation_recording_script.md بصوت Gemini الآلي.
// يعمل على جهاز المطوّر فقط، ولا يدخل التطبيق: التطبيق يشغّل الملفات الناتجة بلا إنترنت.
//
// التشغيل (من أي مجلد):
//   dart tool/generate_meditation_voice.dart --sample          عيّنة من مقطع واحد بعدة أصوات
//   dart tool/generate_meditation_voice.dart --voice=Achernar  كل المقاطع بصوت واحد
//   dart tool/generate_meditation_voice.dart --voice=Sulafat --lang=en
//       النسخة الإنجليزية من docs/meditation_recording_script_en.md إلى build/meditation_voice/wav/en
//
// المفتاح: يُنسخ قبل التشغيل فيُقرأ من الحافظة ثم تُفرَّغ (أو من متغير البيئة GEMINI_API_KEY).
// لا يُطبع ولا يُحفظ، ويسافر في الترويسة x-goog-api-key فقط. النص المرسَل هو نص المقاطع وحده.
//
// المرجع: https://ai.google.dev/gemini-api/docs/speech-generation (Interactions API،
// الرد WAV ‏24kHz أحادي 16-bit). الموديل مراجَع في 21 نوفمبر 2026؛ لا تغيّره بالتخمين.
//
// الناتج في build/meditation_voice/ (خارج git). التحويل إلى m4a ووضعه في assets خطوة منفصلة:
//   powershell -ExecutionPolicy Bypass -File tool/wav_to_m4a.ps1
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

const String model = 'gemini-3.8-flash-tts';
const List<String> sampleVoices = ['Achernar', 'Vindemiatrix', 'Sulafat', 'Algieba'];
const String sampleClip = 'breathing_01';
const Map<String, String> styles = {
  'ar': 'Calm, slow, soft and warm meditation guide. Gentle, unhurried delivery '
      'in Modern Standard Arabic, with relaxed pauses between sentences.',
  'en': 'Calm, slow, soft and warm meditation guide. Gentle, unhurried delivery '
      'in clear English, with relaxed pauses between sentences.',
};
String style = styles['ar']!;

const int sampleRate = 24000;
const Duration pauseBetweenRequests = Duration(seconds: 8);

final Uri endpoint = Uri.parse('https://generativelanguage.googleapis.com/v1beta/interactions');

class Clip {
  Clip(this.session, this.id, this.text);
  final String session;
  final String id;
  final String text;
}

Future<void> main(List<String> args) async {
  final root = File.fromUri(Platform.script).parent.parent;
  final sample = args.contains('--sample');
  final force = args.contains('--force');
  final voiceArg = args.where((a) => a.startsWith('--voice=')).map((a) => a.substring(8)).firstOrNull;
  final lang = args.where((a) => a.startsWith('--lang=')).map((a) => a.substring(7)).firstOrNull ?? 'ar';
  if (!styles.containsKey(lang)) {
    stderr.writeln('Unknown --lang=$lang (use ar or en).');
    exit(64);
  }
  style = styles[lang]!;
  final scriptName = lang == 'ar' ? 'meditation_recording_script.md' : 'meditation_recording_script_$lang.md';

  final clips = parseScript(File('${root.path}/docs/$scriptName').readAsStringSync());
  final limits = clipLimits(File('${root.path}/assets/meditation/sessions.json').readAsStringSync());
  if (clips.isEmpty) {
    stderr.writeln('No clips found in docs/$scriptName');
    exit(1);
  }
  if (args.contains('--list')) {
    for (final clip in clips) {
      stdout.writeln('${clip.session}/${clip.id}  max ${limits[clip.id] ?? '?'} s  ${clip.text.length} chars');
    }
    stdout.writeln('${clips.length} clips. Nothing was sent.');
    return;
  }
  if (!sample && (voiceArg == null || voiceArg.isEmpty)) {
    stdout.writeln('Usage: dart tool/generate_meditation_voice.dart --sample');
    stdout.writeln('   or: dart tool/generate_meditation_voice.dart --voice=<VoiceName> [--force]');
    exit(64);
  }

  final key = readKey();
  if (key.isEmpty) {
    stderr.writeln('No key entered. Nothing was sent.');
    exit(2);
  }

  final client = HttpClient()..connectionTimeout = const Duration(seconds: 30);
  try {
    if (sample) {
      final clip = clips.firstWhere((c) => c.id == sampleClip);
      final dir = Directory('${root.path}/build/meditation_voice/samples${lang == 'ar' ? '' : '/$lang'}')
        ..createSync(recursive: true);
      for (final (i, voice) in sampleVoices.indexed) {
        if (i > 0) await Future<void>.delayed(pauseBetweenRequests);
        final file = File('${dir.path}/$voice.wav');
        final seconds = await synthesizeTo(client, key, clip, voice, file);
        if (seconds == null) exit(3);
        stdout.writeln('sample $voice: ${seconds.toStringAsFixed(1)} s');
      }
      stdout.writeln('Done. Samples are in build/meditation_voice/samples');
      return;
    }

    final voice = voiceArg!;
    // العربية في wav/<session>/، وكل لغة أخرى في wav/<lang>/<session>/ (مثل مجلدات التطبيق).
    final out = Directory('${root.path}/build/meditation_voice/wav${lang == 'ar' ? '' : '/$lang'}');
    var made = 0;
    var warnings = 0;
    for (final clip in clips) {
      final file = File('${out.path}/${clip.session}/${clip.id}.wav');
      if (file.existsSync() && !force) {
        stdout.writeln('${clip.id}: already made, skipped');
        continue;
      }
      if (made > 0) await Future<void>.delayed(pauseBetweenRequests);
      file.parent.createSync(recursive: true);
      final seconds = await synthesizeTo(client, key, clip, voice, file);
      if (seconds == null) {
        stdout.writeln('Stopped. $made new clip(s) kept. Run the same command again later to continue.');
        exit(3);
      }
      made++;
      final limit = limits[clip.id];
      final tooLong = limit != null && seconds > limit;
      if (tooLong) warnings++;
      stdout.writeln('${clip.id}: ${seconds.toStringAsFixed(1)} s'
          '${tooLong ? '  WARNING: longer than the $limit s before the next clip' : ''}');
    }
    stdout.writeln('Done. $made new clip(s), ${clips.length} in all, $warnings warning(s).');
  } finally {
    client.close(force: true);
  }
}

/// المفتاح من متغير البيئة، وإلا من الحافظة (ينسخه المستخدم قبل التشغيل). لا يُكتب المفتاح في
/// الطرفية أبدًا: اللصق فيها يمرّ بعلامات "اللصق المحاط" ويُظهر المفتاح إن لُصق في المكان الخطأ.
/// الحافظة تُفرَّغ بعد القراءة حتى لا يُلصق المفتاح بالخطأ لاحقًا.
String readKey() {
  final fromEnv = cleanKey(Platform.environment['GEMINI_API_KEY'] ?? '');
  if (fromEnv != null) return fromEnv;
  if (!Platform.isWindows) {
    stderr.writeln('Set GEMINI_API_KEY first.');
    return '';
  }
  final clip = Process.runSync('powershell.exe', ['-NoProfile', '-Command', 'Get-Clipboard -Raw'],
      stdoutEncoding: utf8);
  final key = clip.exitCode == 0 ? cleanKey('${clip.stdout}') : null;
  if (key == null) {
    stderr.writeln('Copy your Gemini key first (only the key), then run this command again.');
    return '';
  }
  Process.runSync('cmd', ['/c', 'type nul | clip']);
  stdout.writeln('Key read from the clipboard. The clipboard is now empty.');
  return key;
}

/// يرجع المفتاح بلا مسافات ولا علامات لصق، أو null إن لم يكن شكله شكل مفتاح.
String? cleanKey(String raw) {
  final key = raw.replaceAll('\x1b[200~', '').replaceAll('\x1b[201~', '').trim();
  return RegExp(r'^[A-Za-z0-9._\-]{20,200}$').hasMatch(key) ? key : null;
}

/// يقرأ المقاطع: سطر اسم الملف بخط عريض (`**breathing_01.m4a**`) ثم سطر النص، وكل مقطع تحت
/// عنوان جلسته الذي ينتهي بمعرّفها بين قوسين، مثل `## 1. تنفّس هادئ (calm_breathing)`.
List<Clip> parseScript(String markdown) {
  final clips = <Clip>[];
  String? session;
  String? pending;
  final heading = RegExp(r'^##\s.*\(`([a-z_]+)`\)\s*$');
  final clipLine = RegExp(r'^\*\*([a-z0-9_]+)\.m4a\*\*\s*$');
  for (final raw in const LineSplitter().convert(markdown)) {
    final line = raw.trim();
    final h = heading.firstMatch(line);
    if (h != null) {
      session = h.group(1);
      pending = null;
      continue;
    }
    final c = clipLine.firstMatch(line);
    if (c != null) {
      pending = c.group(1);
      continue;
    }
    if (pending != null && line.isNotEmpty && session != null) {
      clips.add(Clip(session, pending, line));
      pending = null;
    }
  }
  return clips;
}

/// أطول مدة مسموحة لكل مقطع بالثواني: حتى المقطع التالي في المرحلة نفسها، أو حتى نهايتها.
Map<String, int> clipLimits(String sessionsJson) {
  final limits = <String, int>{};
  for (final session in jsonDecode(sessionsJson) as List) {
    for (final phase in (session as Map)['phases'] as List? ?? const []) {
      final cues = [...((phase as Map)['cues'] as List? ?? const [])]
        ..sort((a, b) => ((a as Map)['atSec'] as int).compareTo((b as Map)['atSec'] as int));
      for (var i = 0; i < cues.length; i++) {
        final at = (cues[i] as Map)['atSec'] as int;
        final end = i + 1 < cues.length ? (cues[i + 1] as Map)['atSec'] as int : phase['durationSec'] as int;
        limits[(cues[i] as Map)['clip'] as String] = end - at;
      }
    }
  }
  return limits;
}

/// وقفة قصيرة بعد كل جملة، فالتأمل بطيء.
String prepareText(String text) => text.replaceAll(RegExp(r'\.\s+'), '. <short pause> ');

/// يطلب المقطع ويكتبه WAV مع ثانية صمت في أوله وآخره. يرجع مدته بالثواني، أو null عند الفشل.
Future<double?> synthesizeTo(HttpClient client, String key, Clip clip, String voice, File file) async {
  final body = jsonEncode({
    'model': model,
    'input': [
      {
        'type': 'user_input',
        'content': [
          {
            'type': 'text',
            'text': prepareText(clip.text),
            'annotations': [
              {'type': 'speech_metadata', 'style': style},
            ],
          },
        ],
      },
    ],
    'response_format': {'type': 'audio'},
    'generation_config': {
      'speech_config': [
        {'voice': voice},
      ],
    },
  });

  for (var attempt = 1; attempt <= 4; attempt++) {
    final (status, text) = await post(client, key, body);
    if (status == 200) {
      final audio = findAudio(jsonDecode(text));
      if (audio == null) {
        stderr.writeln('${clip.id}: the reply had no audio.');
        return null;
      }
      final pcm = pcmFromWav(base64Decode(audio));
      final silence = Uint8List(sampleRate * 2);
      final all = BytesBuilder(copy: false)
        ..add(silence)
        ..add(pcm)
        ..add(silence);
      file.writeAsBytesSync(wavFromPcm(all.takeBytes()));
      return (pcm.length / 2 + sampleRate * 2) / sampleRate;
    }
    // حد اليوم (المجاني 10 طلبات يوميًا لهذا الموديل) لا يفيده الانتظار دقيقة؛ حد الدقيقة يفيده.
    final dailyLimit = status == 429 && text.contains('per day');
    final wait = switch (status) {
      429 when !dailyLimit => const Duration(seconds: 65),
      >= 500 => const Duration(seconds: 15),
      _ => null,
    };
    stderr.writeln('${clip.id}: HTTP $status ${errorSummary(text)}');
    if (status == 401 || status == 403) {
      stderr.writeln('The key was refused. Copy the whole Gemini key again, then run the same command.');
    }
    if (wait == null || attempt == 4) return null;
    stderr.writeln('  waiting ${wait.inSeconds} s, then trying again ($attempt/3)');
    await Future<void>.delayed(wait);
  }
  return null;
}

Future<(int, String)> post(HttpClient client, String key, String body) async {
  try {
    final request = await client.postUrl(endpoint);
    request.headers
      ..set('x-goog-api-key', key)
      ..contentType = ContentType('application', 'json', charset: 'utf-8');
    request.add(utf8.encode(body));
    final response = await request.close().timeout(const Duration(seconds: 180));
    final text = await response.transform(utf8.decoder).join().timeout(const Duration(seconds: 180));
    return (response.statusCode, text);
  } on TimeoutException {
    return (504, '{"error":{"message":"no reply within 180 s"}}');
  } on IOException catch (e) {
    return (503, '{"error":{"message":"${e.runtimeType}"}}');
  }
}

/// رسالة الخطأ ونوعه فقط، مقصوصة. لا تحمل المفتاح.
String errorSummary(String text) {
  try {
    final error = (jsonDecode(text) as Map)['error'];
    if (error is Map) {
      final message = '${error['status'] ?? ''} ${error['message'] ?? ''}'.trim();
      return message.length > 200 ? '${message.substring(0, 200)}...' : message;
    }
  } catch (_) {}
  return '';
}

/// آخر جزء صوتي في الرد: `{"type": "audio", "data": "<base64>"}` في أي عمق.
String? findAudio(Object? node) {
  String? found;
  void walk(Object? n) {
    if (n is Map) {
      if (n['type'] == 'audio' && n['data'] is String) found = n['data'] as String;
      n.values.forEach(walk);
    } else if (n is List) {
      n.forEach(walk);
    }
  }

  walk(node);
  return found;
}

/// عيّنات PCM من ملف WAV (جزء data)، أو البايتات كما هي إن لم تكن WAV.
Uint8List pcmFromWav(Uint8List bytes) {
  if (bytes.length < 12 || ascii.decode(bytes.sublist(0, 4), allowInvalid: true) != 'RIFF') return bytes;
  final data = ByteData.sublistView(bytes);
  var offset = 12;
  while (offset + 8 <= bytes.length) {
    final id = ascii.decode(bytes.sublist(offset, offset + 4), allowInvalid: true);
    final size = data.getUint32(offset + 4, Endian.little);
    if (id == 'fmt ') {
      final channels = data.getUint16(offset + 10, Endian.little);
      final rate = data.getUint32(offset + 12, Endian.little);
      final bits = data.getUint16(offset + 22, Endian.little);
      if (channels != 1 || rate != sampleRate || bits != 16) {
        throw FormatException('unexpected audio format: $channels ch, $rate Hz, $bits bit');
      }
    }
    if (id == 'data') {
      final end = (offset + 8 + size).clamp(0, bytes.length);
      return Uint8List.sublistView(bytes, offset + 8, end);
    }
    offset += 8 + size + (size.isOdd ? 1 : 0);
  }
  throw const FormatException('no data chunk in the WAV reply');
}

/// WAV أحادي 16-bit ‏24kHz.
Uint8List wavFromPcm(Uint8List pcm) {
  final header = ByteData(44);
  void tag(int at, String s) {
    for (var i = 0; i < 4; i++) {
      header.setUint8(at + i, s.codeUnitAt(i));
    }
  }

  tag(0, 'RIFF');
  header.setUint32(4, 36 + pcm.length, Endian.little);
  tag(8, 'WAVE');
  tag(12, 'fmt ');
  header.setUint32(16, 16, Endian.little);
  header.setUint16(20, 1, Endian.little);
  header.setUint16(22, 1, Endian.little);
  header.setUint32(24, sampleRate, Endian.little);
  header.setUint32(28, sampleRate * 2, Endian.little);
  header.setUint16(32, 2, Endian.little);
  header.setUint16(34, 16, Endian.little);
  tag(36, 'data');
  header.setUint32(40, pcm.length, Endian.little);
  return (BytesBuilder(copy: false)
        ..add(header.buffer.asUint8List())
        ..add(pcm))
      .takeBytes();
}
