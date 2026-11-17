/// نوع الجلسة: مرشدة بصوت، حركية بمراحل، استماع لجاما، أو مؤقت صامت.
enum MeditationKind { guided, active, gamma, silent }

/// مجانية أو مع الاشتراك.
enum MeditationTier { free, premium }

/// ما يُسمع في الخلفية طوال المرحلة. الصمت أيضًا «صوت» يعمل، فهو ما يقود ساعة الجلسة.
enum ToneBackground {
  none('none'),
  gammaBinaural('gamma_binaural'),
  gammaIsochronic('gamma_isochronic');

  const ToneBackground(this.jsonName);
  final String jsonName;

  bool get isGamma => this != none;

  static ToneBackground parse(Object? value) => values.firstWhere(
        (b) => b.jsonName == value,
        orElse: () => throw FormatException('unknown background: $value'),
      );
}

/// مقطع صوت المرشد داخل مرحلة. [atSec] من بداية المرحلة، أو من نهايتها إن كان [fromEnd].
class MeditationCue {
  const MeditationCue({required this.atSec, required this.clip, this.fromEnd = false});

  final int atSec;
  final String clip;
  final bool fromEnd;

  factory MeditationCue.fromJson(Map<String, dynamic> json) {
    final atSec = json['atSec'];
    final clip = json['clip'];
    if (atSec is! int || atSec < 0 || clip is! String || !RegExp(r'^[a-z0-9_]+$').hasMatch(clip)) {
      throw FormatException('bad cue: $json');
    }
    return MeditationCue(atSec: atSec, clip: clip, fromEnd: json['fromEnd'] == true);
  }
}

class MeditationPhase {
  const MeditationPhase({
    required this.id,
    required this.title,
    required this.durationSec,
    this.instruction = '',
    this.background = ToneBackground.none,
    this.cues = const [],
  });

  final String id;
  final String title;

  /// نص قصير يظهر على الشاشة طوال المرحلة (بخط كبير في الجلسة الحركية).
  final String instruction;

  /// مدة المرحلة في أقصر مدة للجلسة؛ المدد الأطول تمدّ المراحل بالنسبة نفسها.
  final int durationSec;
  final ToneBackground background;
  final List<MeditationCue> cues;

  factory MeditationPhase.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final title = json['title'];
    final duration = json['durationSec'];
    if (id is! String || title is! String || title.trim().isEmpty || duration is! int || duration <= 0) {
      throw FormatException('bad phase: $json');
    }
    final cues = [
      for (final cue in (json['cues'] as List? ?? const []))
        MeditationCue.fromJson(Map<String, dynamic>.from(cue as Map)),
    ];
    for (final cue in cues) {
      if (cue.atSec > duration) throw FormatException('cue ${cue.clip} is outside phase $id');
    }
    return MeditationPhase(
      id: id,
      title: title,
      durationSec: duration,
      instruction: json['instruction'] as String? ?? '',
      background: ToneBackground.parse(json['background'] ?? 'none'),
      cues: cues,
    );
  }
}

class MeditationSession {
  const MeditationSession({
    required this.id,
    required this.title,
    required this.description,
    required this.kind,
    required this.tier,
    required this.durations,
    required this.phases,
  });

  final String id;
  final String title;
  final String description;
  final MeditationKind kind;
  final MeditationTier tier;

  /// المدد المسموحة بالدقائق، تصاعديًا. أقصرها تساوي مجموع مدد المراحل.
  final List<int> durations;
  final List<MeditationPhase> phases;

  bool get isPremium => tier == MeditationTier.premium;

  /// المستخدم يختار الخلفية بنفسه في المؤقت الصامت (صمت أو جاما) وفي جلسة جاما (نوعها).
  bool get backgroundIsChosen => kind == MeditationKind.silent || kind == MeditationKind.gamma;

  /// مكان ملف مقطع المرشد داخل التطبيق.
  static String clipAsset(String sessionId, String clip) => 'assets/meditation/voice/$sessionId/$clip.m4a';

  /// كل ملفات صوت المرشد التي تحتاجها الجلسة.
  Set<String> get clipAssets => {
        for (final phase in phases)
          for (final cue in phase.cues) clipAsset(id, cue.clip),
      };

  factory MeditationSession.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final title = json['title'];
    if (id is! String || !RegExp(r'^[a-z0-9_]+$').hasMatch(id) || title is! String || title.trim().isEmpty) {
      throw FormatException('bad session: ${json['id']}');
    }
    final kind = MeditationKind.values.firstWhere(
      (k) => k.name == json['kind'],
      orElse: () => throw FormatException('unknown kind in $id'),
    );
    final tier = MeditationTier.values.firstWhere(
      (t) => t.name == json['tier'],
      orElse: () => throw FormatException('unknown tier in $id'),
    );
    final durations = [for (final d in (json['durations'] as List? ?? const [])) d as int]..sort();
    final phases = [
      for (final phase in (json['phases'] as List? ?? const []))
        MeditationPhase.fromJson(Map<String, dynamic>.from(phase as Map)),
    ];
    if (durations.isEmpty || durations.first <= 0 || phases.isEmpty) {
      throw FormatException('session $id needs durations and phases');
    }
    final total = phases.fold(0, (sum, p) => sum + p.durationSec);
    if (total != durations.first * 60) {
      throw FormatException('phases of $id last ${total}s, not ${durations.first} minutes');
    }
    return MeditationSession(
      id: id,
      title: title,
      description: json['description'] as String? ?? '',
      kind: kind,
      tier: tier,
      durations: durations,
      phases: phases,
    );
  }
}
