import 'models/meditation_session.dart';

/// مرحلة في الخط الزمني للجلسة بالثواني من بدايتها.
class PlannedPhase {
  const PlannedPhase({required this.startSec, required this.endSec, required this.phase, required this.background});

  final int startSec;
  final int endSec;
  final MeditationPhase phase;
  final ToneBackground background;

  int get lengthSec => endSec - startSec;
}

/// مقطع مرشد في الخط الزمني.
class PlannedCue {
  const PlannedCue({required this.atSec, required this.asset, required this.phaseId});

  final int atSec;
  final String asset;
  final String phaseId;
}

/// الخط الزمني الكامل: المراحل، والأجراس، والمقاطع. المشغّل ينفّذه فقط.
class SessionPlan {
  const SessionPlan({
    required this.session,
    required this.totalSec,
    required this.phases,
    required this.bells,
    required this.cues,
    this.lang = 'ar',
  });

  final MeditationSession session;

  /// لغة الجلسة: نصوص المراحل في الشاشة والإشعار، ومجلد صوت المرشد.
  final String lang;
  final int totalSec;
  final List<PlannedPhase> phases;
  final List<int> bells;
  final List<PlannedCue> cues;

  bool get usesGamma => phases.any((p) => p.background.isGamma);

  /// المرحلة الجارية عند [sec]. بعد النهاية تبقى الأخيرة.
  PlannedPhase phaseAt(int sec) {
    for (final phase in phases) {
      if (sec < phase.endSec) return phase;
    }
    return phases.last;
  }
}

/// يحوّل الجلسة والمدة المختارة إلى خط زمني.
///
/// - المراحل تمتد بالنسبة نفسها من أقصر مدة إلى المدة المختارة، والباقي من التقريب يذهب
///   لأطول مرحلة، فمجموعها يساوي المدة بالضبط.
/// - الجرس في البداية والنهاية وبين كل مرحلتين.
/// - المقطع في موضعه من بداية مرحلته (أو من نهايتها إن كان fromEnd).
/// - [background] يستبدل خلفية كل المراحل (اختيار المستخدم في المؤقت الصامت وجلسة جاما).
SessionPlan planSession(MeditationSession session, {required int minutes, ToneBackground? background, String lang = 'ar'}) {
  if (!session.durations.contains(minutes)) {
    throw ArgumentError.value(minutes, 'minutes', 'not one of ${session.durations}');
  }
  final totalSec = minutes * 60;
  final baseSec = session.durations.first * 60;

  final lengths = [for (final p in session.phases) p.durationSec * totalSec ~/ baseSec];
  final remainder = totalSec - lengths.fold<int>(0, (a, b) => a + b);
  var longest = 0;
  for (var i = 1; i < lengths.length; i++) {
    if (lengths[i] > lengths[longest]) longest = i;
  }
  lengths[longest] += remainder;

  final phases = <PlannedPhase>[];
  final cues = <PlannedCue>[];
  var start = 0;
  for (var i = 0; i < session.phases.length; i++) {
    final phase = session.phases[i];
    final end = start + lengths[i];
    phases.add(PlannedPhase(
      startSec: start,
      endSec: end,
      phase: phase,
      background: background ?? phase.background,
    ));
    for (final cue in phase.cues) {
      final at = cue.fromEnd ? end - cue.atSec : start + cue.atSec;
      cues.add(PlannedCue(
        atSec: at.clamp(start, end).toInt(),
        asset: MeditationSession.clipAsset(session.id, cue.clip, lang: lang),
        phaseId: phase.id,
      ));
    }
    start = end;
  }
  cues.sort((a, b) => a.atSec.compareTo(b.atSec));

  final bells = <int>[0, for (final p in phases.skip(1)) p.startSec, totalSec];
  return SessionPlan(session: session, totalSec: totalSec, phases: phases, bells: bells, cues: cues, lang: lang);
}
