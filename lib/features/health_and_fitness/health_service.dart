import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../../core/services/encrypted_boxes.dart';
import 'models/exercise.dart';
import 'models/health_entry.dart';

/// تمرين محذوف مع صورته، لإرجاعه بزر "تراجع" إلى موضعه نفسه.
class RemovedExercise {
  const RemovedExercise(this.key, this.record, this.image);

  final int key;
  final Map<String, dynamic> record;
  final Uint8List? image;
}

/// بيانات صحية خاصة (أدوية وروتين عناية وتمارين وسجل التمرين) في صندوق Hive مشفّر واحد. كل
/// سجل فيه حقل `kind` يحدد نوعه. صور التمارين في صندوق مشفّر ثانٍ بمعرّف التمرين. لا توجد
/// بيانات افتراضية: كل ما يظهر أدخله المستخدم.
class HealthService {
  static const String _boxName = 'health';
  static const String imagesBoxName = 'exercise_images';
  static const String _medication = 'medication';
  static const String _beauty = 'beauty';
  static const String _exercise = 'exercise';
  static const String _workout = 'workout';
  static const int maxTextLength = 120;

  static HealthService? _instance;
  static Box? _box;
  static Box? _images;

  HealthService._();

  static Future<HealthService> getInstance() async {
    _instance ??= HealthService._();
    _box ??= await EncryptedBoxes.open(_boxName);
    _images ??= await EncryptedBoxes.open(imagesBoxName);
    return _instance!;
  }

  /// يُنسى الصندوق المفتوح (بعد مسح بيانات المستخدم يُفتح صندوق جديد عند الطلب).
  static void reset() {
    _instance = null;
    _box = null;
    _images = null;
  }

  @visibleForTesting
  static void resetForTesting() => reset();

  static String _dayKey(DateTime day) => '${day.year}-${day.month}-${day.day}';

  static String _clean(String? input, [int max = maxTextLength]) {
    final cleaned = (input ?? '').replaceAll(RegExp(r'\s+'), ' ').trim();
    return String.fromCharCodes(cleaned.runes.take(max));
  }

  /// نص متعدد الأسطر (ملاحظات): يُقصّ ويُنظَّف من محارف التحكم دون أن تُحذف الأسطر.
  static String _cleanText(String? input, int max) {
    final cleaned = (input ?? '')
        .replaceAll(RegExp(r'[\u0000-\u0008\u000B\u000C\u000E-\u001F\u007F]'), '')
        .trim();
    return String.fromCharCodes(cleaned.runes.take(max));
  }

  /// سجلات نوع واحد بترتيب الإضافة.
  List<MapEntry<int, Map>> _ofKind(String kind) {
    return [
      for (final entry in _box!.toMap().entries)
        if (entry.key is int && entry.value is Map && (entry.value as Map)['kind'] == kind)
          MapEntry(entry.key as int, entry.value as Map),
    ]..sort((a, b) => a.key.compareTo(b.key));
  }

  /// وقت تذكير بصيغة `HH:mm` أو فارغ؛ أي شيء آخر يُهمَل.
  static String cleanReminder(String? input) {
    final match = RegExp(r'^([01]?\d|2[0-3]):([0-5]\d)$').firstMatch((input ?? '').trim());
    if (match == null) return '';
    return '${match.group(1)!.padLeft(2, '0')}:${match.group(2)}';
  }

  // --- الأدوية والمكملات ---

  List<Medication> medications({DateTime? now}) {
    final today = _dayKey(now ?? DateTime.now());
    return [
      for (final e in _ofKind(_medication))
        Medication(
          id: e.key.toString(),
          name: (e.value['name'] as String?) ?? '',
          time: (e.value['time'] as String?) ?? '',
          reminder: cleanReminder(e.value['reminder'] as String?),
          takenToday: e.value['takenOn'] == today,
        ),
    ];
  }

  Future<void> addMedication({required String name, String time = '', String reminder = ''}) async {
    final cleanName = _clean(name);
    if (cleanName.isEmpty) return;
    await _box!.add({
      'kind': _medication,
      'name': cleanName,
      'time': _clean(time),
      'reminder': cleanReminder(reminder),
      'takenOn': null,
    });
  }

  Future<void> updateMedication(String id, {required String name, String time = '', String reminder = ''}) async {
    final key = int.tryParse(id);
    final current = key == null ? null : _box!.get(key);
    final cleanName = _clean(name);
    if (key == null || current is! Map || current['kind'] != _medication || cleanName.isEmpty) return;
    await _box!.put(key, {
      ...Map<String, dynamic>.from(current),
      'name': cleanName,
      'time': _clean(time),
      'reminder': cleanReminder(reminder),
    });
  }

  Future<void> setMedicationTaken(String id, bool taken, {DateTime? now}) async {
    final key = int.tryParse(id);
    final current = key == null ? null : _box!.get(key);
    if (key == null || current is! Map || current['kind'] != _medication) return;
    await _box!.put(key, {
      ...Map<String, dynamic>.from(current),
      'takenOn': taken ? _dayKey(now ?? DateTime.now()) : null,
    });
  }

  // --- روتين العناية ---

  List<BeautyItem> beautyItems() {
    return [
      for (final e in _ofKind(_beauty))
        BeautyItem(
          id: e.key.toString(),
          item: (e.value['item'] as String?) ?? '',
          time: (e.value['time'] as String?) ?? '',
          step: (e.value['step'] as String?) ?? '',
          reminder: cleanReminder(e.value['reminder'] as String?),
        ),
    ];
  }

  Future<void> addBeautyItem({
    required String item,
    String time = '',
    String step = '',
    String reminder = '',
  }) async {
    final cleanItem = _clean(item);
    if (cleanItem.isEmpty) return;
    await _box!.add({
      'kind': _beauty,
      'item': cleanItem,
      'time': _clean(time),
      'step': _clean(step),
      'reminder': cleanReminder(reminder),
    });
  }

  Future<void> updateBeautyItem(
    String id, {
    required String item,
    String time = '',
    String step = '',
    String reminder = '',
  }) async {
    final key = int.tryParse(id);
    final current = key == null ? null : _box!.get(key);
    final cleanItem = _clean(item);
    if (key == null || current is! Map || current['kind'] != _beauty || cleanItem.isEmpty) return;
    await _box!.put(key, {
      ...Map<String, dynamic>.from(current),
      'item': cleanItem,
      'time': _clean(time),
      'step': _clean(step),
      'reminder': cleanReminder(reminder),
    });
  }

  /// يحذف أي سجل (دواء أو عناية) بمعرّفه.
  Future<void> delete(String id) async {
    final key = int.tryParse(id);
    if (key != null) await _box!.delete(key);
  }

  // --- التمارين ---

  /// المثبّتة أولًا ثم الأحدث.
  List<Exercise> exercises() {
    final list = [
      for (final e in _ofKind(_exercise)) Exercise.fromRecord(e.key.toString(), e.value),
    ];
    list.sort((a, b) {
      if (a.pinned != b.pinned) return a.pinned ? -1 : 1;
      return int.parse(b.id).compareTo(int.parse(a.id));
    });
    return list;
  }

  Exercise? exerciseById(String id) => exercises().where((e) => e.id == id).firstOrNull;

  /// صورة التمرين المشفّرة، أو null.
  Uint8List? exerciseImage(String id) {
    final raw = _images!.get(id);
    if (raw is Uint8List) return raw;
    if (raw is List) return Uint8List.fromList(raw.cast<int>());
    return null;
  }

  Exercise _sanitized(Exercise e, {required bool hasImage}) {
    final steps = e.steps
        .map((s) => _clean(s, Exercise.maxStepLength))
        .where((s) => s.isNotEmpty)
        .take(Exercise.maxSteps)
        .toList();
    final reps = _clean(e.reps, Exercise.maxRepsLength);
    return Exercise(
      id: e.id,
      name: _clean(e.name, Exercise.maxNameLength),
      muscles: _clean(e.muscles, Exercise.maxMusclesLength),
      steps: steps,
      sets: e.sets.clamp(1, Exercise.maxSets),
      reps: reps.isEmpty ? Exercise.defaultReps : reps,
      notes: _cleanText(e.notes, Exercise.maxNotesLength),
      pinned: e.pinned,
      hasImage: hasImage,
      createdAt: e.createdAt.isEmpty ? DateTime.now().toIso8601String() : e.createdAt,
    );
  }

  /// يضيف تمرينًا (واسمه إلزامي) مع صورة اختيارية. يرجّع التمرين بمعرّفه، أو null إن كان الاسم فارغًا.
  Future<Exercise?> addExercise(Exercise exercise, {Uint8List? image}) async {
    final clean = _sanitized(exercise, hasImage: image != null);
    if (clean.name.isEmpty) return null;
    final key = await _box!.add(clean.toRecord());
    if (image != null) await _images!.put(key.toString(), image);
    return Exercise.fromRecord(key.toString(), clean.toRecord());
  }

  /// يحدّث تمرينًا. [image] صورة جديدة، و[removeImage] تحذف الصورة الحالية.
  Future<void> updateExercise(Exercise exercise, {Uint8List? image, bool removeImage = false}) async {
    final key = int.tryParse(exercise.id);
    final current = key == null ? null : _box!.get(key);
    if (key == null || current is! Map || current['kind'] != _exercise) return;
    final hadImage = current['hasImage'] == true;
    final hasImage = image != null || (hadImage && !removeImage);
    final clean = _sanitized(exercise, hasImage: hasImage);
    if (clean.name.isEmpty) return;
    await _box!.put(key, clean.toRecord());
    if (image != null) {
      await _images!.put(exercise.id, image);
    } else if (removeImage) {
      await _images!.delete(exercise.id);
    }
  }

  Future<void> toggleExercisePin(String id) async {
    final exercise = exerciseById(id);
    if (exercise != null) await updateExercise(exercise.copyWith(pinned: !exercise.pinned));
  }

  /// يحذف التمرين وصورته. سجل التمرين السابق يبقى (يحمل اسم التمرين).
  Future<RemovedExercise?> deleteExercise(String id) async {
    final key = int.tryParse(id);
    final current = key == null ? null : _box!.get(key);
    if (key == null || current is! Map || current['kind'] != _exercise) return null;
    final removed = RemovedExercise(key, Map<String, dynamic>.from(current), exerciseImage(id));
    await _box!.delete(key);
    await _images!.delete(id);
    return removed;
  }

  Future<void> restoreExercise(RemovedExercise removed) async {
    await _box!.put(removed.key, removed.record);
    final image = removed.image;
    if (image != null) await _images!.put(removed.key.toString(), image);
  }

  // --- سجل التمرين ---

  /// الأحدث أولًا (اليوم ثم ترتيب الإضافة). [exerciseId] يقصر السجل على تمرين واحد.
  List<WorkoutEntry> workouts({String? exerciseId}) {
    final list = [
      for (final e in _ofKind(_workout)) WorkoutEntry.fromRecord(e.key.toString(), e.value),
    ];
    final filtered = exerciseId == null ? list : list.where((w) => w.exerciseId == exerciseId).toList();
    filtered.sort((a, b) {
      final byDate = b.date.compareTo(a.date);
      return byDate != 0 ? byDate : int.parse(b.id).compareTo(int.parse(a.id));
    });
    return filtered;
  }

  Future<WorkoutEntry> logWorkout({
    required Exercise exercise,
    required int sets,
    required String reps,
    String weight = '',
    String note = '',
    DateTime? day,
  }) async {
    final cleanReps = _clean(reps, Exercise.maxRepsLength);
    final record = WorkoutEntry(
      id: '',
      exerciseId: exercise.id,
      exerciseName: _clean(exercise.name, Exercise.maxNameLength),
      date: WorkoutEntry.dayKey(day ?? DateTime.now()),
      sets: sets.clamp(1, Exercise.maxSets),
      reps: cleanReps.isEmpty ? Exercise.defaultReps : cleanReps,
      weight: _clean(weight, Exercise.maxRepsLength),
      note: _cleanText(note, 300),
    ).toRecord();
    final key = await _box!.add(record);
    return WorkoutEntry.fromRecord(key.toString(), record);
  }

  Future<WorkoutEntry?> deleteWorkout(String id) async {
    final key = int.tryParse(id);
    final current = key == null ? null : _box!.get(key);
    if (key == null || current is! Map || current['kind'] != _workout) return null;
    await _box!.delete(key);
    return WorkoutEntry.fromRecord(id, current);
  }

  Future<void> restoreWorkout(WorkoutEntry entry) async {
    final key = int.tryParse(entry.id);
    if (key != null) await _box!.put(key, entry.toRecord());
  }
}
