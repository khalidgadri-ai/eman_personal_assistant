import 'dart:convert';
import 'dart:typed_data';

import 'package:eman_life_app/core/ai/ai_errors.dart';
import 'package:eman_life_app/core/ai/ai_models.dart';
import 'package:eman_life_app/core/ai/ai_provider.dart';
import 'package:eman_life_app/core/ai/ai_settings_service.dart';
import 'package:eman_life_app/features/health_and_fitness/health_fitness_screen.dart';
import 'package:eman_life_app/features/health_and_fitness/health_service.dart';
import 'package:eman_life_app/features/health_and_fitness/models/exercise.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/test_storage.dart';
import 'helpers/widget_helpers.dart';

/// مزوّد وهمي يرد بنص ثابت أو يرمي خطأ، ويسجل ما أُرسل إليه.
class _FakeProvider extends AiProvider {
  _FakeProvider(super.config, super.apiKey, this.reply);

  final Object reply;
  static final List<AiRequest> sent = [];

  @override
  Future<AiReply> send(AiRequest request) async {
    sent.add(request);
    final r = reply;
    if (r is Exception) throw r;
    return AiReply(r as String);
  }

  @override
  Future<List<AiModelInfo>> listModels() async => const [];
}

void main() {
  late TestStorage storage;
  // PNG حقيقي 1×1: الصور غير الصالحة تُسقط الاختبار عند فك ترميزها في Image.memory.
  final photo = base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==',
  );

  setUp(() async {
    storage = await TestStorage.inMemory();
    _FakeProvider.sent.clear();
  });
  tearDown(() => storage.dispose());

  Future<HealthService> health() => HealthService.getInstance();

  Future<void> openScreen(
    WidgetTester tester, {
    Object aiReply = 'x',
    Future<Uint8List?> Function(BuildContext)? pickImage,
  }) async {
    tester.view.physicalSize = const Size(900, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await pumpScreen(
      tester,
      HealthFitnessScreen(
        pickImage: pickImage ?? (_) async => photo,
        aiProviderBuilder: (config, key) => _FakeProvider(config, key, aiReply),
      ),
    );
  }

  Future<void> configureAi({AiSupport images = AiSupport.yes}) async {
    final settings = await AiSettingsService.getInstance();
    await settings.save(settings.configFor('openai').copyWith(model: 'some-model', images: images));
    await settings.saveKey('openai', 'sk-FAKEFAKEFAKEFAKE1234');
  }

  Future<void> addExerciseByHand(WidgetTester tester, String name, {String muscles = ''}) async {
    await tester.tap(find.byTooltip('إضافة تمرين'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'اسم التمرين'), name);
    if (muscles.isNotEmpty) await tester.enterText(find.widgetWithText(TextField, 'العضلات المستهدفة'), muscles);
    await tester.tap(find.text('حفظ'));
    await tester.pumpAndSettle();
  }

  testWidgets('the exercises tab starts empty with its add button', (tester) async {
    await openScreen(tester);

    expect(find.text('لم تُضف تمارين بعد.'), findsOneWidget);
    expect(find.byTooltip('إضافة تمرين'), findsOneWidget);
  });

  testWidgets('an exercise added by hand appears as a card with its sets and reps, and is saved', (tester) async {
    await openScreen(tester);

    await addExerciseByHand(tester, 'سحب علوي', muscles: 'الظهر');

    expect(find.text('سحب علوي'), findsOneWidget);
    expect(find.text('الظهر · 3 × 10'), findsOneWidget);
    expect(find.text('لم تُضف تمارين بعد.'), findsNothing);
    expect((await health()).exercises().single.name, 'سحب علوي');
  });

  testWidgets('a name is required', (tester) async {
    await openScreen(tester);

    await tester.tap(find.byTooltip('إضافة تمرين'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('حفظ'));
    await tester.pumpAndSettle();

    expect(find.text('هذا الحقل مطلوب'), findsOneWidget);
    expect((await health()).exercises(), isEmpty);
  });

  testWidgets('sets and steps can be edited in the form', (tester) async {
    await openScreen(tester);
    await tester.tap(find.byTooltip('إضافة تمرين'));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextField, 'اسم التمرين'), 'قرفصاء');
    await tester.tap(find.byTooltip('زيادة المجموعات'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('زيادة المجموعات'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'التكرار'), '8-10');
    await tester.tap(find.text('إضافة خطوة'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'الخطوة 1'), 'انزل ببطء');
    await tester.tap(find.text('حفظ'));
    await tester.pumpAndSettle();

    final saved = (await health()).exercises().single;
    expect(saved.setsAndReps, '5 × 8-10');
    expect(saved.steps, ['انزل ببطء']);
  });

  testWidgets('pin moves a card to the top and the pin is saved', (tester) async {
    final h = await health();
    await h.addExercise(ex('أ'));
    await h.addExercise(ex('ب'));
    await openScreen(tester);
    expect(tester.getTopLeft(find.text('ب')).dy, lessThan(tester.getTopLeft(find.text('أ')).dy), reason: 'newest first');

    await tester.tap(find.descendant(of: find.byKey(ValueKey('exercise_${h.exercises().last.id}')), matching: find.byTooltip('تثبيت التمرين')));
    await tester.pumpAndSettle();

    expect(tester.getTopLeft(find.text('أ')).dy, lessThan(tester.getTopLeft(find.text('ب')).dy));
    expect(h.exercises().first.name, 'أ');
    expect(h.exercises().first.pinned, isTrue);
  });

  testWidgets('deleting from the list can be undone, with the picture', (tester) async {
    final h = await health();
    final saved = (await h.addExercise(ex('تمرين بصورة'), image: photo))!;
    await openScreen(tester);

    await tester.tap(find.byTooltip('حذف التمرين'));
    await tester.pumpAndSettle();
    expect(find.text('تمرين بصورة'), findsNothing);
    expect(h.exerciseImage(saved.id), isNull);

    await tester.tap(find.text('تراجع'));
    await tester.pumpAndSettle();
    expect(find.text('تمرين بصورة'), findsOneWidget);
    expect(h.exerciseImage(saved.id), photo);
  });

  testWidgets('the details page can log today, shows it, and the log can be opened and cleaned', (tester) async {
    final h = await health();
    await h.addExercise(ex('ضغط', steps: ['استلقِ', 'ادفع']));
    await openScreen(tester);

    await tester.tap(find.text('ضغط'));
    await tester.pumpAndSettle();
    expect(find.text('استلقِ'), findsOneWidget);
    expect(find.text('المجموعات والتكرار: 3 × 10'), findsOneWidget);

    await tester.tap(find.text('سجّل اليوم'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'الوزن (اختياري)'), '40 كجم');
    await tester.tap(find.text('تسجيل'));
    await tester.pumpAndSettle();

    final logged = h.workouts().single;
    expect(logged.exerciseName, 'ضغط');
    expect(logged.weight, '40 كجم');
    expect(find.text('آخر التسجيلات'), findsOneWidget);

    await tester.tap(find.text('السجل'));
    await tester.pumpAndSettle();
    expect(find.textContaining('3 × 10 · 40 كجم'), findsOneWidget);

    await tester.tap(find.byTooltip('حذف التسجيل'));
    await tester.pumpAndSettle();
    expect(h.workouts(), isEmpty);
    await tester.tap(find.text('تراجع'));
    await tester.pumpAndSettle();
    expect(h.workouts(), hasLength(1));
  });

  testWidgets('logging with invalid sets is refused', (tester) async {
    final h = await health();
    await h.addExercise(ex('ضغط'));
    await openScreen(tester);
    await tester.tap(find.text('ضغط'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('سجّل اليوم'));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextField, 'المجموعات'), '99');
    await tester.tap(find.text('تسجيل'));
    await tester.pumpAndSettle();

    expect(find.textContaining('أدخل رقمًا من 1 إلى'), findsOneWidget);
    expect(h.workouts(), isEmpty);
  });

  testWidgets('editing from the details page changes the saved exercise', (tester) async {
    final h = await health();
    final saved = (await h.addExercise(ex('قديم'), image: photo))!;
    await openScreen(tester);
    await tester.tap(find.text('قديم'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('تعديل التمرين'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'اسم التمرين'), 'جديد');
    await tester.tap(find.text('إزالة الصورة'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('حفظ'));
    await tester.pumpAndSettle();

    expect(find.text('جديد'), findsWidgets);
    expect(h.exerciseById(saved.id)!.name, 'جديد');
    expect(h.exerciseImage(saved.id), isNull);
  });

  testWidgets('deleting from the details page asks first and keeps the log', (tester) async {
    final h = await health();
    final saved = (await h.addExercise(ex('سيُحذف')))!;
    await h.logWorkout(exercise: saved, sets: 3, reps: '10');
    await openScreen(tester);
    await tester.tap(find.text('سيُحذف'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('حذف التمرين'));
    await tester.pumpAndSettle();
    expect(find.text('حذف التمرين؟'), findsOneWidget);
    await tester.tap(find.text('إلغاء'));
    await tester.pumpAndSettle();
    expect(h.exercises(), hasLength(1));

    await tester.tap(find.byTooltip('حذف التمرين'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('حذف'));
    await tester.pumpAndSettle();

    expect(h.exercises(), isEmpty);
    expect(h.workouts().single.exerciseName, 'سيُحذف');
  });

  group('analysing a photo, then "حفظ كتمرين"', () {
    const jsonReply =
        '{"name":"سحب علوي","muscles":"الظهر والذراعين","steps":["اسحب","ارجع ببطء"],"sets":4,"reps":"8-10","notes":"لا تهزّ الجسم"}';

    testWidgets('the form opens pre-filled from the reply and the picture, and nothing is saved before the user says so', (tester) async {
      await configureAi();
      await openScreen(tester, aiReply: jsonReply);

      await tester.tap(find.text('تحليل صورة التمرين بالذكاء الاصطناعي'));
      await tester.pumpAndSettle();

      expect(find.textContaining('التمرين: سحب علوي'), findsOneWidget);
      expect((await health()).exercises(), isEmpty, reason: 'viewing the analysis saves nothing');
      final image = _FakeProvider.sent.single.messages.single.images.single;
      expect(image.bytes, photo);

      await tester.tap(find.text('حفظ كتمرين'));
      await tester.pumpAndSettle();
      expect(tester.widget<TextField>(find.widgetWithText(TextField, 'اسم التمرين')).controller!.text, 'سحب علوي');
      expect(find.byType(Image), findsOneWidget, reason: 'the analysed picture is attached');
      expect((await health()).exercises(), isEmpty, reason: 'still not saved until the user presses save');

      await tester.enterText(find.widgetWithText(TextField, 'اسم التمرين'), 'سحب علوي واسع');
      await tester.tap(find.text('حفظ'));
      await tester.pumpAndSettle();

      final h = await health();
      final saved = h.exercises().single;
      expect(saved.name, 'سحب علوي واسع');
      expect(saved.muscles, 'الظهر والذراعين');
      expect(saved.setsAndReps, '4 × 8-10');
      expect(saved.steps, ['اسحب', 'ارجع ببطء']);
      expect(saved.notes, 'لا تهزّ الجسم');
      expect(h.exerciseImage(saved.id), photo);
      expect(find.text('سحب علوي واسع'), findsOneWidget);
    });

    testWidgets('closing the result saves nothing', (tester) async {
      await configureAi();
      await openScreen(tester, aiReply: jsonReply);

      await tester.tap(find.text('تحليل صورة التمرين بالذكاء الاصطناعي'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('إغلاق'));
      await tester.pumpAndSettle();

      expect((await health()).exercises(), isEmpty);
    });

    testWidgets('a plain-text reply is shown as it is and can be kept as notes', (tester) async {
      await configureAi();
      await openScreen(tester, aiReply: 'هذا تمرين سحب للظهر، يُنفَّذ ببطء.');

      await tester.tap(find.text('تحليل صورة التمرين بالذكاء الاصطناعي'));
      await tester.pumpAndSettle();
      expect(find.text('هذا تمرين سحب للظهر، يُنفَّذ ببطء.'), findsOneWidget);

      await tester.tap(find.text('حفظ كتمرين'));
      await tester.pumpAndSettle();
      expect(tester.widget<TextField>(find.widgetWithText(TextField, 'اسم التمرين')).controller!.text, isEmpty);
      expect(tester.widget<TextField>(find.widgetWithText(TextField, 'ملاحظات (اختياري)')).controller!.text,
          'هذا تمرين سحب للظهر، يُنفَّذ ببطء.');
    });

    testWidgets('a provider failure shows the fixed Arabic message and offers no save', (tester) async {
      await configureAi();
      await openScreen(tester, aiReply: const AiException(AiFailure.invalidKey, statusCode: 401));

      await tester.tap(find.text('تحليل صورة التمرين بالذكاء الاصطناعي'));
      await tester.pumpAndSettle();

      expect(find.text(AiFailure.invalidKey.message), findsOneWidget);
      expect(find.text('حفظ كتمرين'), findsNothing);
    });

    testWidgets('a model marked as not supporting images is never sent the photo', (tester) async {
      await configureAi(images: AiSupport.no);
      await openScreen(tester, aiReply: jsonReply);

      await tester.tap(find.text('تحليل صورة التمرين بالذكاء الاصطناعي'));
      await tester.pumpAndSettle();

      expect(find.text(AiFailure.imageUnsupported.message), findsOneWidget);
      expect(_FakeProvider.sent, isEmpty);
    });

    testWidgets('cancelling the photo picker sends nothing', (tester) async {
      await configureAi();
      await openScreen(tester, aiReply: jsonReply, pickImage: (_) async => null);

      await tester.tap(find.text('تحليل صورة التمرين بالذكاء الاصطناعي'));
      await tester.pumpAndSettle();

      expect(_FakeProvider.sent, isEmpty);
      expect(find.byType(AlertDialog), findsNothing);
    });
  });

  group('medications and routine: edit and reminder', () {
    testWidgets('a medication can be edited and gets a reminder time', (tester) async {
      final h = await health();
      await h.addMedication(name: 'فيتامين د', time: 'صباحًا');
      await openScreen(tester);
      await openTab(tester, 'جدول الأدوية');

      await tester.tap(find.text('فيتامين د'));
      await tester.pumpAndSettle();
      await tester.enterText(find.widgetWithText(TextField, 'الاسم'), 'فيتامين د3');
      await tester.tap(find.text('ضبط تذكير'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('حفظ'));
      await tester.pumpAndSettle();

      final med = h.medications().single;
      expect(med.name, 'فيتامين د3');
      expect(med.reminder, '09:00');
      expect(find.textContaining('⏰ 09:00'), findsOneWidget);
    });

    testWidgets('the reminder can be removed again', (tester) async {
      final h = await health();
      await h.addMedication(name: 'دواء', reminder: '21:30');
      await openScreen(tester);
      await openTab(tester, 'جدول الأدوية');

      await tester.tap(find.text('دواء'));
      await tester.pumpAndSettle();
      expect(find.text('يوميًا عند 21:30'), findsOneWidget);
      await tester.tap(find.byTooltip('إزالة التذكير'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('حفظ'));
      await tester.pumpAndSettle();

      expect(h.medications().single.reminder, isEmpty);
    });

    testWidgets('a routine product can be edited', (tester) async {
      final h = await health();
      await h.addBeautyItem(item: 'مرطب', time: 'مساءً', step: 'قديم');
      await openScreen(tester);
      await openTab(tester, 'العناية بالبشرة');

      await tester.tap(find.text('مرطب'));
      await tester.pumpAndSettle();
      await tester.enterText(find.widgetWithText(TextField, 'طريقة الاستخدام (اختياري)'), 'بعد الغسيل');
      await tester.tap(find.text('حفظ'));
      await tester.pumpAndSettle();

      expect(h.beautyItems().single.step, 'بعد الغسيل');
      expect(h.beautyItems().single.time, 'مساءً', reason: 'the saved time was kept in the dropdown');
    });
  });
}

/// اختصار لبناء تمرين في الاختبارات.
Exercise ex(String name, {List<String> steps = const []}) => Exercise(id: '', name: name, steps: steps);
