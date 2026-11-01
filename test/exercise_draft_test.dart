import 'package:eman_life_app/features/health_and_fitness/models/exercise.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ExerciseDraft.tryParse (AI output is untrusted data)', () {
    test('reads a clean JSON object', () {
      final draft = ExerciseDraft.tryParse(
        '{"name":"ضغط الصدر","muscles":"الصدر","steps":["استلقِ","ادفع"],"sets":4,"reps":"8-10","notes":"انتبه للظهر"}',
      )!;

      expect(draft.name, 'ضغط الصدر');
      expect(draft.muscles, 'الصدر');
      expect(draft.steps, ['استلقِ', 'ادفع']);
      expect(draft.sets, 4);
      expect(draft.reps, '8-10');
      expect(draft.notes, 'انتبه للظهر');
    });

    test('accepts JSON inside a code fence or surrounded by chatty text', () {
      const fenced = 'تفضل:\n```json\n{"name":"سحب","muscles":"الظهر"}\n```\nبالتوفيق!';

      final draft = ExerciseDraft.tryParse(fenced)!;

      expect(draft.name, 'سحب');
      expect(draft.sets, Exercise.defaultSets, reason: 'missing sets fall back to the default');
      expect(draft.reps, Exercise.defaultReps);
    });

    test('numbers may arrive as text or decimals', () {
      expect(ExerciseDraft.tryParse('{"name":"أ","sets":"5","reps":12}')!.sets, 5);
      expect(ExerciseDraft.tryParse('{"name":"أ","sets":"5","reps":12}')!.reps, '12');
      expect(ExerciseDraft.tryParse('{"name":"أ","sets":3.0}')!.sets, 3);
    });

    test('out-of-range sets fall back instead of being trusted', () {
      for (final bad in ['0', '-4', '9999', '"كثير"', 'null', '[3]']) {
        expect(ExerciseDraft.tryParse('{"name":"أ","sets":$bad}')!.sets, Exercise.defaultSets, reason: bad);
      }
    });

    test('over-long fields are cut and too many steps are dropped', () {
      final steps = [for (var i = 0; i < 60; i++) '"خطوة $i"'].join(',');
      final draft = ExerciseDraft.tryParse(
        '{"name":"${'ا' * 500}","muscles":"${'م' * 500}","steps":[$steps],"notes":"${'ن' * 5000}","reps":"${'1' * 100}"}',
      )!;

      expect(draft.name.runes.length, Exercise.maxNameLength);
      expect(draft.muscles.runes.length, Exercise.maxMusclesLength);
      expect(draft.steps, hasLength(Exercise.maxSteps));
      expect(draft.notes.runes.length, Exercise.maxNotesLength);
      expect(draft.reps.runes.length, Exercise.maxRepsLength);
    });

    test('wrong types are ignored, not crashed on', () {
      final draft = ExerciseDraft.tryParse(
        '{"name":{"x":1},"muscles":["a"],"steps":"not a list","notes":true,"sets":{}}',
      );

      expect(draft, isNull, reason: 'nothing useful survived');
      final partly = ExerciseDraft.tryParse('{"name":"سليم","muscles":123,"steps":[1,null,{"a":1},"ثلاثة"]}')!;
      expect(partly.name, 'سليم');
      expect(partly.muscles, '123');
      expect(partly.steps, ['1', 'ثلاثة']);
    });

    test('control characters are stripped', () {
      final draft = ExerciseDraft.tryParse('{"name":"ضغط\\u0000\\u0007 الصدر","notes":"سطر\\u001f"}')!;

      expect(draft.name, 'ضغط الصدر');
      expect(draft.notes, 'سطر');
    });

    test('returns null for anything that is not a useful exercise', () {
      expect(ExerciseDraft.tryParse(''), isNull);
      expect(ExerciseDraft.tryParse('هذا نص عادي بلا JSON'), isNull);
      expect(ExerciseDraft.tryParse('{"name":'), isNull);
      expect(ExerciseDraft.tryParse('{}'), isNull);
      expect(ExerciseDraft.tryParse('{"name":"","muscles":"","steps":[]}'), isNull);
      expect(ExerciseDraft.tryParse('[1,2,3]'), isNull);
      expect(ExerciseDraft.tryParse('{"sets":4}'), isNull, reason: 'no text field at all');
    });

    test('a "not recognised" reply still gives the user its note', () {
      final draft = ExerciseDraft.tryParse('{"name":"","notes":"الصورة غير واضحة"}')!;

      expect(draft.name, isEmpty);
      expect(draft.notes, 'الصورة غير واضحة');
    });

    test('the display text lists what was understood', () {
      const draft = ExerciseDraft(
        name: 'سحب',
        muscles: 'الظهر',
        steps: ['اسحب', 'ارجع'],
        sets: 3,
        reps: '10',
        notes: 'ببطء',
      );

      final text = draft.toDisplayText();

      expect(text, contains('التمرين: سحب'));
      expect(text, contains('العضلات: الظهر'));
      expect(text, contains('3 × 10'));
      expect(text, contains('1. اسحب'));
      expect(text, contains('ملاحظات: ببطء'));
    });
  });
}
