import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'models/meditation_session.dart';
import 'session_planner.dart';
import 'timeline_cursor.dart';
import 'tone_files.dart';
import 'tone_generator.dart';

/// حالة الجلسة كما تراها الشاشة.
class MeditationProgress {
  const MeditationProgress({
    required this.elapsedSec,
    required this.totalSec,
    required this.phase,
    required this.playing,
    this.finished = false,
  });

  final int elapsedSec;
  final int totalSec;
  final PlannedPhase phase;
  final bool playing;
  final bool finished;

  int get remainingSec => (totalSec - elapsedSec).clamp(0, totalSec);
}

/// ما تحتاجه شاشة الجلسة من المشغّل. الحقيقي [AudioMeditationPlayer]، وفي الاختبارات بديل وهمي.
abstract class MeditationPlayer {
  Stream<MeditationProgress> get progress;
  Future<void> start(SessionPlan plan, {required double toneVolume});
  Future<void> pause();
  Future<void> resume();

  /// ينهي الجلسة ويطفئ كل الأصوات والإشعار.
  Future<void> stop();
  Future<void> setToneVolume(double volume);
}

/// المستوى الافتراضي لنغمة جاما: 30% من مستوى الجهاز.
const double defaultToneVolume = 0.3;

/// المشغّل الحقيقي: خدمة audio_service واحدة (تستمر والشاشة مطفأة) وفيها ثلاثة مشغّلات.
class AudioMeditationPlayer implements MeditationPlayer {
  static Future<MeditationAudioHandler>? _handler;

  /// تُهيَّأ الخدمة عند أول جلسة فقط، لا عند فتح التطبيق.
  static Future<MeditationAudioHandler> _ensureHandler() => _handler ??= AudioService.init(
        builder: MeditationAudioHandler.new,
        config: const AudioServiceConfig(
          androidNotificationChannelId: 'com.khalidibrahimgadri.eman.meditation',
          androidNotificationChannelName: 'جلسات التأمل',
          // الإعداد الافتراضي عمدًا (true): بعد الإيقاف أو الإنهاء تخرج الخدمة من المقدمة وتُفلت
          // قفل الإيقاظ ويُزال الإشعار. مع false تبقى الخدمة في المقدمة بعد «إنهاء» (النشاط
          // مرتبط بها فلا تُدمَّر)، فيبقى الإشعار ويستهلك البطارية. الاستئناف من زر الإشعار
          // مسموح في أندرويد 12+ لأنه تفاعل من المستخدم.
          androidStopForegroundOnPause: true,
        ),
      );

  @override
  Stream<MeditationProgress> get progress async* {
    final handler = await _ensureHandler();
    yield* handler.progress;
  }

  @override
  Future<void> start(SessionPlan plan, {required double toneVolume}) async {
    final handler = await _ensureHandler();
    await handler.startSession(plan, toneVolume: toneVolume, tones: await ToneFiles.ensure());
  }

  @override
  Future<void> pause() async => (await _ensureHandler()).pause();

  @override
  Future<void> resume() async => (await _ensureHandler()).play();

  @override
  Future<void> stop() async => (await _ensureHandler()).stop();

  @override
  Future<void> setToneVolume(double volume) async => (await _ensureHandler()).setToneVolume(volume);
}

/// قلب التشغيل. ساعة الجلسة = موضع مشغّل الخلفية (نغمة جاما أو صمت مقطّع إلى حلقات من 10
/// ثوانٍ)، والأجراس ومقاطع المرشد تُطلق حين يصل إليها، فلا تتأخر والشاشة مطفأة.
class MeditationAudioHandler extends BaseAudioHandler {
  MeditationAudioHandler() {
    _background.positionStream.listen((_) => _tick());
    _background.currentIndexStream.listen((_) => _tick());
    _background.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) _tick(force: true);
    });
  }

  final AudioPlayer _background = AudioPlayer(handleInterruptions: false);
  final AudioPlayer _voice = AudioPlayer(handleInterruptions: false);
  final AudioPlayer _bell = AudioPlayer(handleInterruptions: false);
  final StreamController<MeditationProgress> _progress = StreamController.broadcast();

  SessionPlan? _plan;
  TimelineCursor? _cursor;
  List<int> _chunkStarts = const [];
  PlannedPhase? _phase;
  double _toneVolume = defaultToneVolume;
  bool _ending = false;
  bool _voiceWasPlaying = false;
  bool _pausedByInterruption = false;
  StreamSubscription<AudioInterruptionEvent>? _interruptions;
  StreamSubscription<void>? _noisy;

  Stream<MeditationProgress> get progress => _progress.stream;

  Future<void> startSession(SessionPlan plan, {required double toneVolume, required ToneFiles tones}) async {
    await _stopPlayers();
    _plan = plan;
    _cursor = TimelineCursor(plan);
    _phase = plan.phases.first;
    _toneVolume = toneVolume;
    _ending = false;
    await _configureSession();

    // كل مرحلة تُقسَّم إلى حلقات من 10 ثوانٍ من ملف خلفيتها، والأخيرة تُقصّ على الباقي.
    final sources = <AudioSource>[];
    final starts = <int>[];
    for (final phase in plan.phases) {
      final path = tones.loopFor(phase.background);
      var at = phase.startSec;
      while (at < phase.endSec) {
        final length = (phase.endSec - at).clamp(0, ToneGenerator.loopSeconds);
        starts.add(at);
        sources.add(length == ToneGenerator.loopSeconds
            ? AudioSource.file(path)
            : ClippingAudioSource(child: AudioSource.file(path), end: Duration(seconds: length)));
        at += length;
      }
    }
    _chunkStarts = starts;
    await _bell.setAudioSource(AudioSource.file(tones.bell));
    await _background.setAudioSources(sources);
    await _background.setVolume(_backgroundVolume(0));

    mediaItem.add(MediaItem(
      id: plan.session.id,
      title: plan.session.title,
      artist: _phase!.phase.title,
      duration: Duration(seconds: plan.totalSec),
    ));
    _publish();
    unawaited(_background.play());
    _tick();
  }

  double get _elapsed {
    final index = _background.currentIndex ?? 0;
    final start = index < _chunkStarts.length ? _chunkStarts[index] : 0;
    return start + _background.position.inMilliseconds / 1000;
  }

  void _tick({bool force = false}) {
    final plan = _plan;
    final cursor = _cursor;
    if (plan == null || cursor == null || _ending) return;
    final elapsed = force ? plan.totalSec.toDouble() : _elapsed;
    for (final event in cursor.advanceTo(elapsed)) {
      switch (event) {
        case PhaseStartEvent(:final phase):
          _phase = phase;
          final item = mediaItem.value;
          if (item != null) mediaItem.add(item.copyWith(artist: phase.phase.title));
        case BellEvent():
          unawaited(_ringBell());
        case CueEvent(:final cue):
          unawaited(_playCue(cue.asset));
        case SessionEndEvent():
          unawaited(_finish());
      }
    }
    unawaited(_background.setVolume(_backgroundVolume(elapsed)));
    _publish(elapsed: elapsed);
  }

  /// مستوى نغمة جاما مع تلاشٍ تدريجي 5 ثوانٍ في بداية كل مرحلة جاما ونهايتها.
  double _backgroundVolume(double elapsed) {
    final plan = _plan;
    if (plan == null) return 0;
    final phase = plan.phaseAt(elapsed.floor());
    if (!phase.background.isGamma) return 1;
    const fade = 5.0;
    final fromStart = elapsed - phase.startSec;
    final toEnd = phase.endSec - elapsed;
    final ramp = [fromStart / fade, toEnd / fade, 1.0].reduce((a, b) => a < b ? a : b).clamp(0.0, 1.0);
    return _toneVolume * ramp;
  }

  Future<void> _ringBell() async {
    try {
      await _bell.seek(Duration.zero);
      await _bell.play();
    } catch (e) {
      debugPrint('Meditation bell: ${e.runtimeType}');
    }
  }

  /// مقطع غير موجود (لم يُسجَّل بعد) يُتخطّى بصمت.
  Future<void> _playCue(String asset) async {
    try {
      await _voice.setAudioSource(AudioSource.asset(asset));
      await _voice.play();
    } catch (e) {
      debugPrint('Meditation cue skipped: ${e.runtimeType}');
    }
  }

  Future<void> _finish() async {
    if (_ending) return;
    _ending = true;
    await _background.pause();
    // يُترك جرس النهاية يكتمل قبل إطفاء الخدمة.
    await Future<void>.delayed(const Duration(seconds: 4));
    final plan = _plan;
    if (plan != null && !_progress.isClosed) {
      _progress.add(MeditationProgress(
        elapsedSec: plan.totalSec,
        totalSec: plan.totalSec,
        phase: plan.phases.last,
        playing: false,
        finished: true,
      ));
    }
    await _teardown();
  }

  void _publish({double? elapsed}) {
    final plan = _plan;
    final phase = _phase;
    if (plan == null || phase == null) return;
    final seconds = (elapsed ?? _elapsed).floor().clamp(0, plan.totalSec);
    final playing = _background.playing;
    playbackState.add(PlaybackState(
      controls: [playing ? MediaControl.pause : MediaControl.play, MediaControl.stop],
      androidCompactActionIndices: const [0, 1],
      processingState: AudioProcessingState.ready,
      playing: playing,
      updatePosition: Duration(seconds: seconds),
    ));
    if (!_progress.isClosed) {
      _progress.add(MeditationProgress(
        elapsedSec: seconds,
        totalSec: plan.totalSec,
        phase: phase,
        playing: playing,
      ));
    }
  }

  Future<void> setToneVolume(double volume) async {
    _toneVolume = volume.clamp(0.0, 1.0);
    await _background.setVolume(_backgroundVolume(_elapsed));
  }

  @override
  Future<void> play() async {
    if (_plan == null || _ending) return;
    unawaited(_background.play());
    if (_voiceWasPlaying) unawaited(_voice.play());
    _voiceWasPlaying = false;
    _publish();
  }

  @override
  Future<void> pause() async {
    if (_plan == null) return;
    _voiceWasPlaying = _voice.playing;
    await Future.wait([_background.pause(), _voice.pause(), _bell.pause()]);
    _publish();
  }

  /// من زر «إنهاء» أو من الإشعار: ينهي الجلسة كما هي.
  @override
  Future<void> stop() async {
    final plan = _plan;
    if (plan != null && !_progress.isClosed) {
      final elapsed = _elapsed.floor().clamp(0, plan.totalSec);
      _progress.add(MeditationProgress(
        elapsedSec: elapsed,
        totalSec: plan.totalSec,
        phase: plan.phaseAt(elapsed),
        playing: false,
        finished: true,
      ));
    }
    await _teardown();
  }

  @override
  Future<void> onTaskRemoved() => stop();

  Future<void> _teardown() async {
    _ending = true;
    await _stopPlayers();
    await _interruptions?.cancel();
    await _noisy?.cancel();
    _interruptions = null;
    _noisy = null;
    _plan = null;
    _cursor = null;
    playbackState.add(PlaybackState(processingState: AudioProcessingState.idle, playing: false));
    await super.stop();
  }

  Future<void> _stopPlayers() async {
    await Future.wait([_background.stop(), _voice.stop(), _bell.stop()]);
  }

  /// مكالمة أو تنبيه صوتي: تتوقف الجلسة وتعود بعده. فصل السماعات يوقفها.
  Future<void> _configureSession() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
    await _interruptions?.cancel();
    _interruptions = session.interruptionEventStream.listen((event) {
      if (event.begin) {
        if (_background.playing) {
          _pausedByInterruption = true;
          unawaited(pause());
        }
      } else if (_pausedByInterruption) {
        _pausedByInterruption = false;
        if (event.type != AudioInterruptionType.unknown) unawaited(play());
      }
    });
    await _noisy?.cancel();
    _noisy = session.becomingNoisyEventStream.listen((_) => unawaited(pause()));
  }
}

/// الخلفية الافتراضية لاختيار المستخدم في الجلسة: جاما مزدوجة لجلسة جاما، وصمت للمؤقت.
ToneBackground defaultBackgroundFor(MeditationSession session) =>
    session.kind == MeditationKind.gamma ? ToneBackground.gammaBinaural : ToneBackground.none;
