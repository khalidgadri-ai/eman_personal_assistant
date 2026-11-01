import 'dart:io';
import 'dart:typed_data';

import 'package:eman_life_app/features/health_and_fitness/health_service.dart';
import 'package:eman_life_app/features/health_and_fitness/models/exercise.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'helpers/test_storage.dart';

void main() {
  late TestStorage storage;
  late HealthService health;

  setUp(() async {
    storage = TestStorage.create();
    health = await HealthService.getInstance();
  });
  tearDown(() => storage.dispose());

  Future<Exercise> add(String name, {Uint8List? image, int sets = 3, String reps = '10'}) async {
    final saved = await health.addExercise(
      Exercise(id: '', name: name, muscles: 'الصدر', sets: sets, reps: reps),
      image: image,
    );
    return saved!;
  }

  group('exercises', () {
    test('a fresh install has none', () {
      expect(health.exercises(), isEmpty);
      expect(health.workouts(), isEmpty);
    });

    test('are saved with every field and listed newest first', () async {
      final bench = await health.addExercise(const Exercise(
        id: '',
        name: 'ضغط الصدر',
        muscles: 'الصدر والكتف',
        steps: ['استلقِ', 'ادفع الثقل'],
        sets: 4,
        reps: '8-10',
        notes: 'لا تقفل المرفقين\nحافظ على الظهر',
      ));
      await add('سحب');

      final list = health.exercises();

      expect(list.map((e) => e.name), ['سحب', 'ضغط الصدر']);
      final back = list.last;
      expect(back.id, bench!.id);
      expect(back.muscles, 'الصدر والكتف');
      expect(back.steps, ['استلقِ', 'ادفع الثقل']);
      expect(back.setsAndReps, '4 × 8-10');
      expect(back.notes, 'لا تقفل المرفقين\nحافظ على الظهر', reason: 'line breaks in notes are kept');
      expect(back.createdAt, isNotEmpty);
      expect(back.hasImage, isFalse);
    });

    test('a blank name is refused', () async {
      expect(await health.addExercise(const Exercise(id: '', name: '   ')), isNull);
      expect(health.exercises(), isEmpty);
    });

    test('values are cleaned and bounded whatever they come with', () async {
      final saved = await health.addExercise(Exercise(
        id: '',
        name: '  ضغط   ${'ط' * 300}',
        muscles: 'م' * 500,
        steps: [for (var i = 0; i < 50; i++) 'خطوة $i', '   '],
        sets: 999,
        reps: '   ',
        notes: 'ن' * 5000,
      ));

      expect(saved!.name.runes.length, Exercise.maxNameLength);
      expect(saved.muscles.runes.length, Exercise.maxMusclesLength);
      expect(saved.steps.length, Exercise.maxSteps);
      expect(saved.sets, Exercise.maxSets);
      expect(saved.reps, Exercise.defaultReps);
      expect(saved.notes.runes.length, Exercise.maxNotesLength);
    });

    test('editing changes the saved exercise and keeps its place and pin', () async {
      final a = await add('أ');
      await add('ب');
      await health.toggleExercisePin(a.id);

      await health.updateExercise(health.exerciseById(a.id)!.copyWith(name: 'أ معدّل', sets: 5, reps: '6'));

      final back = health.exerciseById(a.id)!;
      expect(back.name, 'أ معدّل');
      expect(back.setsAndReps, '5 × 6');
      expect(back.pinned, isTrue);
      expect(health.exercises().first.id, a.id, reason: 'pinned exercises come first');
    });

    test('pin toggles and an edit with a blank name changes nothing', () async {
      final a = await add('أ');

      await health.toggleExercisePin(a.id);
      expect(health.exerciseById(a.id)!.pinned, isTrue);
      await health.toggleExercisePin(a.id);
      expect(health.exerciseById(a.id)!.pinned, isFalse);

      await health.updateExercise(health.exerciseById(a.id)!.copyWith(name: '  '));
      expect(health.exerciseById(a.id)!.name, 'أ');
    });

    test('medications and routine items are not mistaken for exercises', () async {
      await health.addMedication(name: 'دواء');
      await health.addBeautyItem(item: 'مرطب');
      await add('تمرين');

      expect(health.exercises().map((e) => e.name), ['تمرين']);
      expect(health.medications().map((m) => m.name), ['دواء']);
      expect(health.beautyItems().map((b) => b.item), ['مرطب']);
    });
  });

  group('exercise images', () {
    final photo = Uint8List.fromList(List.generate(2000, (i) => i % 251));

    test('the image is saved with the exercise and read back byte for byte', () async {
      final e = await add('تمرين بصورة', image: photo);

      expect(e.hasImage, isTrue);
      expect(health.exerciseImage(e.id), photo);
      expect(health.exerciseById(e.id)!.hasImage, isTrue);
    });

    test('an exercise without an image has none', () async {
      final e = await add('بلا صورة');

      expect(health.exerciseImage(e.id), isNull);
    });

    test('an image can be replaced, kept through an edit, and removed', () async {
      final e = await add('تمرين', image: photo);
      final other = Uint8List.fromList([9, 9, 9]);

      await health.updateExercise(e.copyWith(name: 'اسم جديد'));
      expect(health.exerciseImage(e.id), photo, reason: 'editing text keeps the picture');

      await health.updateExercise(e, image: other);
      expect(health.exerciseImage(e.id), other);

      await health.updateExercise(e, removeImage: true);
      expect(health.exerciseImage(e.id), isNull);
      expect(health.exerciseById(e.id)!.hasImage, isFalse);
    });

    test('deleting removes the picture too, and undo brings both back in place', () async {
      final a = await add('أ', image: photo);
      final b = await add('ب');

      final removed = await health.deleteExercise(a.id);

      expect(health.exercises().map((e) => e.id), [b.id]);
      expect(health.exerciseImage(a.id), isNull);

      await health.restoreExercise(removed!);
      expect(health.exercises().map((e) => e.name), ['ب', 'أ']);
      expect(health.exerciseImage(a.id), photo);
    });

    test('deleting a bogus id or something that is not an exercise does nothing', () async {
      await health.addMedication(name: 'دواء');
      final med = health.medications().single;

      expect(await health.deleteExercise('999'), isNull);
      expect(await health.deleteExercise('abc'), isNull);
      expect(await health.deleteExercise(med.id), isNull);
      expect(health.medications(), hasLength(1));
    });

    test('the picture is encrypted on disk, not readable in the box file', () async {
      final marker = Uint8List.fromList(List.filled(300, 0x41)); // "AAAA..." is easy to spot
      await add('تمرين', image: marker);
      await Hive.close();

      final file = File('${storage.directory!.path}/exercise_images_enc.hive');
      final bytes = file.readAsBytesSync();

      expect(bytes.length, greaterThan(300));
      final text = String.fromCharCodes(bytes);
      expect(text.contains('A' * 50), isFalse);
    });
  });

  group('workout log', () {
    test('records sets, reps, weight and a note under the day, newest first', () async {
      final e = await add('ضغط');

      await health.logWorkout(exercise: e, sets: 3, reps: '10', weight: '40 كجم', note: 'سهل', day: DateTime(2026, 10, 1));
      await health.logWorkout(exercise: e, sets: 4, reps: '8', day: DateTime(2026, 10, 3));
      await health.logWorkout(exercise: e, sets: 2, reps: '12', day: DateTime(2026, 10, 3));

      final log = health.workouts();
      expect(log.map((w) => '${w.date} ${w.sets}×${w.reps}'), ['2026-10-03 2×12', '2026-10-03 4×8', '2026-10-01 3×10']);
      expect(log.last.weight, '40 كجم');
      expect(log.last.note, 'سهل');
      expect(log.last.exerciseName, 'ضغط');
    });

    test('can be filtered to one exercise', () async {
      final a = await add('أ');
      final b = await add('ب');
      await health.logWorkout(exercise: a, sets: 3, reps: '10');
      await health.logWorkout(exercise: b, sets: 3, reps: '10');

      expect(health.workouts(exerciseId: a.id), hasLength(1));
      expect(health.workouts(exerciseId: a.id).single.exerciseName, 'أ');
      expect(health.workouts(), hasLength(2));
    });

    test('the history survives deleting the exercise and shows its name', () async {
      final e = await add('تمرين محذوف');
      await health.logWorkout(exercise: e, sets: 3, reps: '10');

      await health.deleteExercise(e.id);

      expect(health.workouts().single.exerciseName, 'تمرين محذوف');
    });

    test('an entry can be deleted and restored in place', () async {
      final e = await add('تمرين');
      final first = await health.logWorkout(exercise: e, sets: 3, reps: '10', day: DateTime(2026, 10, 1));
      await health.logWorkout(exercise: e, sets: 3, reps: '12', day: DateTime(2026, 10, 2));

      final removed = await health.deleteWorkout(first.id);
      expect(health.workouts(), hasLength(1));
      await health.restoreWorkout(removed!);

      expect(health.workouts().map((w) => w.reps), ['12', '10']);
    });

    test('out-of-range values are clamped', () async {
      final e = await add('تمرين');

      final entry = await health.logWorkout(exercise: e, sets: 500, reps: ' ', weight: 'و' * 100);

      expect(entry.sets, Exercise.maxSets);
      expect(entry.reps, Exercise.defaultReps);
      expect(entry.weight.runes.length, Exercise.maxRepsLength);
    });
  });

  group('medication and routine editing + reminder times', () {
    test('editing a medication keeps its taken state and id', () async {
      await health.addMedication(name: 'فيتامين', time: 'صباحًا');
      final med = health.medications().single;
      await health.setMedicationTaken(med.id, true);

      await health.updateMedication(med.id, name: 'فيتامين د', time: 'مساءً', reminder: '21:30');

      final back = health.medications().single;
      expect(back.id, med.id);
      expect(back.name, 'فيتامين د');
      expect(back.time, 'مساءً');
      expect(back.reminder, '21:30');
      expect(back.takenToday, isTrue);
    });

    test('editing a routine item keeps its place', () async {
      await health.addBeautyItem(item: 'أ');
      await health.addBeautyItem(item: 'ب');
      final first = health.beautyItems().first;

      await health.updateBeautyItem(first.id, item: 'أ معدّل', time: 'مساءً', step: 'بعد الغسيل', reminder: '22:00');

      final items = health.beautyItems();
      expect(items.map((i) => i.item), ['أ معدّل', 'ب']);
      expect(items.first.reminder, '22:00');
      expect(items.first.step, 'بعد الغسيل');
    });

    test('a blank name and a wrong kind change nothing', () async {
      await health.addMedication(name: 'دواء');
      final med = health.medications().single;
      final e = await add('تمرين');

      await health.updateMedication(med.id, name: '   ');
      await health.updateMedication(e.id, name: 'غزو');
      await health.updateBeautyItem(med.id, item: 'غزو');

      expect(health.medications().single.name, 'دواء');
      expect(health.exerciseById(e.id)!.name, 'تمرين');
    });

    test('reminder times are normalised and anything else is dropped', () {
      expect(HealthService.cleanReminder('9:05'), '09:05');
      expect(HealthService.cleanReminder('21:30'), '21:30');
      expect(HealthService.cleanReminder(' 07:00 '), '07:00');
      expect(HealthService.cleanReminder('24:00'), '');
      expect(HealthService.cleanReminder('12:60'), '');
      expect(HealthService.cleanReminder('صباحاً'), '');
      expect(HealthService.cleanReminder(null), '');
    });

    test('a medication saved before reminders existed reads with no reminder', () async {
      final box = await Hive.openBox('legacy_probe');
      await box.close();
      await health.addMedication(name: 'قديم');

      expect(health.medications().single.reminder, '');
    });
  });
}
