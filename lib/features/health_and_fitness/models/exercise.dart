import 'dart:convert';

/// تمرين محفوظ: الاسم والعضلات والخطوات والمجموعات والتكرار والملاحظات. الصورة (إن وُجدت)
/// تُحفظ مشفّرة في صندوق منفصل بمعرّف التمرين، و[hasImage] علامة وجودها فقط.
class Exercise {
  const Exercise({
    required this.id,
    required this.name,
    this.muscles = '',
    this.steps = const [],
    this.sets = defaultSets,
    this.reps = defaultReps,
    this.notes = '',
    this.pinned = false,
    this.hasImage = false,
    this.createdAt = '',
  });

  static const int defaultSets = 3;
  static const String defaultReps = '10';
  static const int maxSets = 20;
  static const int maxNameLength = 80;
  static const int maxMusclesLength = 120;
  static const int maxRepsLength = 20;
  static const int maxStepLength = 300;
  static const int maxSteps = 20;
  static const int maxNotesLength = 1000;

  final String id;
  final String name;
  final String muscles;
  final List<String> steps;
  final int sets;
  final String reps;
  final String notes;
  final bool pinned;
  final bool hasImage;
  final String createdAt;

  /// "3 × 10" كما تُعرض.
  String get setsAndReps => '$sets × $reps';

  Exercise copyWith({
    String? name,
    String? muscles,
    List<String>? steps,
    int? sets,
    String? reps,
    String? notes,
    bool? pinned,
    bool? hasImage,
  }) {
    return Exercise(
      id: id,
      name: name ?? this.name,
      muscles: muscles ?? this.muscles,
      steps: steps ?? this.steps,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      notes: notes ?? this.notes,
      pinned: pinned ?? this.pinned,
      hasImage: hasImage ?? this.hasImage,
      createdAt: createdAt,
    );
  }

  /// سجل الصندوق المشفّر (بدون `id`: هو مفتاح السجل نفسه).
  Map<String, dynamic> toRecord() => {
        'kind': 'exercise',
        'name': name,
        'muscles': muscles,
        'steps': steps,
        'sets': sets,
        'reps': reps,
        'notes': notes,
        'pinned': pinned,
        'hasImage': hasImage,
        'createdAt': createdAt,
      };

  factory Exercise.fromRecord(String id, Map record) {
    final steps = record['steps'];
    final sets = record['sets'];
    return Exercise(
      id: id,
      name: '${record['name'] ?? ''}',
      muscles: '${record['muscles'] ?? ''}',
      steps: steps is List ? [for (final s in steps) '$s'] : const [],
      sets: sets is int && sets >= 1 && sets <= maxSets ? sets : defaultSets,
      reps: '${record['reps'] ?? defaultReps}',
      notes: '${record['notes'] ?? ''}',
      pinned: record['pinned'] == true,
      hasImage: record['hasImage'] == true,
      createdAt: '${record['createdAt'] ?? ''}',
    );
  }
}

/// تمرين مُسجَّل في يوم: المجموعات والتكرار والوزن. يحمل نسخة من اسم التمرين فيبقى السجل
/// مفهومًا حتى لو حُذف التمرين نفسه.
class WorkoutEntry {
  const WorkoutEntry({
    required this.id,
    required this.exerciseId,
    required this.exerciseName,
    required this.date,
    required this.sets,
    required this.reps,
    this.weight = '',
    this.note = '',
  });

  final String id;
  final String exerciseId;
  final String exerciseName;

  /// يوم التمرين بصيغة `yyyy-MM-dd`.
  final String date;
  final int sets;
  final String reps;
  final String weight;
  final String note;

  Map<String, dynamic> toRecord() => {
        'kind': 'workout',
        'exerciseId': exerciseId,
        'exerciseName': exerciseName,
        'date': date,
        'sets': sets,
        'reps': reps,
        'weight': weight,
        'note': note,
      };

  factory WorkoutEntry.fromRecord(String id, Map record) {
    final sets = record['sets'];
    return WorkoutEntry(
      id: id,
      exerciseId: '${record['exerciseId'] ?? ''}',
      exerciseName: '${record['exerciseName'] ?? ''}',
      date: '${record['date'] ?? ''}',
      sets: sets is int && sets >= 1 ? sets : 1,
      reps: '${record['reps'] ?? ''}',
      weight: '${record['weight'] ?? ''}',
      note: '${record['note'] ?? ''}',
    );
  }

  static String dayKey(DateTime day) =>
      '${day.year.toString().padLeft(4, '0')}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
}

/// مسودة تمرين يستخلصها التطبيق من رد الذكاء الاصطناعي على صورة. **الرد بيانات غير موثوقة**:
/// كل حقل يُفحص نوعه ويُقصّ إلى حدّه ويُنظَّف من محارف التحكم، وما لا يصلح يُهمَل. لا تُحفظ
/// المسودة قبل أن يراجعها المستخدم في نموذج التعديل ويضغط حفظ.
class ExerciseDraft {
  const ExerciseDraft({
    this.name = '',
    this.muscles = '',
    this.steps = const [],
    this.sets = Exercise.defaultSets,
    this.reps = Exercise.defaultReps,
    this.notes = '',
  });

  final String name;
  final String muscles;
  final List<String> steps;
  final int sets;
  final String reps;
  final String notes;

  static String _clean(Object? value, int max) {
    if (value is! String && value is! num) return '';
    final text = '$value'
        .replaceAll(RegExp(r'[\u0000-\u0008\u000B\u000C\u000E-\u001F\u007F]'), '')
        .replaceAll(RegExp(r'[ \t]+'), ' ')
        .trim();
    return String.fromCharCodes(text.runes.take(max));
  }

  /// يقبل JSON صافيًا أو داخل سور كود أو بنص قبله وبعده. null إن لم يوجد كائن JSON صالح
  /// أو لم يحمل أي حقل مفيد.
  static ExerciseDraft? tryParse(String raw) {
    final start = raw.indexOf('{');
    final end = raw.lastIndexOf('}');
    if (start < 0 || end <= start) return null;
    final Object? decoded;
    try {
      decoded = jsonDecode(raw.substring(start, end + 1));
    } catch (_) {
      return null;
    }
    if (decoded is! Map) return null;

    final stepsRaw = decoded['steps'];
    final steps = <String>[
      if (stepsRaw is List)
        for (final s in stepsRaw.take(Exercise.maxSteps))
          if (_clean(s, Exercise.maxStepLength).isNotEmpty) _clean(s, Exercise.maxStepLength),
    ];
    final setsRaw = decoded['sets'];
    final sets = switch (setsRaw) {
      int n => n,
      num n => n.toInt(),
      String s => int.tryParse(s.trim()),
      _ => null,
    };

    final draft = ExerciseDraft(
      name: _clean(decoded['name'], Exercise.maxNameLength),
      muscles: _clean(decoded['muscles'], Exercise.maxMusclesLength),
      steps: steps,
      sets: sets != null && sets >= 1 && sets <= Exercise.maxSets ? sets : Exercise.defaultSets,
      reps: _clean(decoded['reps'], Exercise.maxRepsLength).isEmpty
          ? Exercise.defaultReps
          : _clean(decoded['reps'], Exercise.maxRepsLength),
      notes: _clean(decoded['notes'], Exercise.maxNotesLength),
    );
    final useful = draft.name.isNotEmpty || draft.muscles.isNotEmpty || draft.steps.isNotEmpty || draft.notes.isNotEmpty;
    return useful ? draft : null;
  }

  /// نص مقروء للعرض في نافذة النتيجة.
  String toDisplayText() {
    final lines = <String>[
      if (name.isNotEmpty) 'التمرين: $name',
      if (muscles.isNotEmpty) 'العضلات: $muscles',
      'المجموعات والتكرار: $sets × $reps',
      if (steps.isNotEmpty) ...['', 'الخطوات:', for (var i = 0; i < steps.length; i++) '${i + 1}. ${steps[i]}'],
      if (notes.isNotEmpty) ...['', 'ملاحظات: $notes'],
    ];
    return lines.join('\n');
  }
}
