import 'package:eman_life_app/features/health_and_fitness/health_fitness_screen.dart';
import 'package:eman_life_app/features/health_and_fitness/health_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/test_storage.dart';
import 'helpers/widget_helpers.dart';

void main() {
  late TestStorage storage;

  setUp(() async {
    storage = await TestStorage.inMemory();
  });
  tearDown(() => storage.dispose());

  Future<HealthService> health() => HealthService.getInstance();

  testWidgets('the exercises tab starts without anyone else\'s exercises', (tester) async {
    await pumpScreen(tester, const HealthFitnessScreen());

    expect(find.text('لم تُضف تمارين بعد.'), findsOneWidget);
    expect(find.textContaining('Lat Pulldown'), findsNothing);
  });

  group('medications', () {
    Future<void> openMedsTab(WidgetTester tester) async {
      await pumpScreen(tester, const HealthFitnessScreen());
      await openTab(tester, 'جدول الأدوية');
    }

    testWidgets('start empty with a clear message', (tester) async {
      await openMedsTab(tester);

      expect(find.text('لم تُضف أدوية أو مكملات بعد. اضغط + للإضافة.'), findsOneWidget);
      expect(find.byTooltip('إضافة دواء'), findsOneWidget);
    });

    testWidgets('a medication appears at once, can be ticked for today, and deleted', (tester) async {
      await openMedsTab(tester);

      await tester.tap(find.byTooltip('إضافة دواء'));
      await tester.pumpAndSettle();
      await fillDialog(tester, {'الاسم': 'مكمل تجريبي', 'الوقت (اختياري)': '08:00 صباحاً'});

      expect(find.text('مكمل تجريبي'), findsOneWidget);
      expect(find.text('08:00 صباحاً'), findsOneWidget);

      await tester.tap(find.byType(Switch));
      await tester.pump();
      await tester.pump();
      expect((await health()).medications().single.takenToday, isTrue);

      await tester.tap(find.byTooltip('حذف الدواء'));
      await tester.pump();
      await tester.pump();
      expect(find.text('مكمل تجريبي'), findsNothing);
      expect((await health()).medications(), isEmpty);
    });

    testWidgets('an empty name is not accepted', (tester) async {
      await openMedsTab(tester);

      await tester.tap(find.byTooltip('إضافة دواء'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('إضافة'));
      await tester.pumpAndSettle();

      expect(find.text('هذا الحقل مطلوب'), findsOneWidget);
      expect((await health()).medications(), isEmpty);
    });

    testWidgets('data is still there when the screen is opened again', (tester) async {
      await openMedsTab(tester);
      await tester.tap(find.byTooltip('إضافة دواء'));
      await tester.pumpAndSettle();
      await fillDialog(tester, {'الاسم': 'يبقى بعد الإغلاق'});

      await tester.pumpWidget(const SizedBox());
      await openMedsTab(tester);

      expect(find.text('يبقى بعد الإغلاق'), findsOneWidget);
    });
  });

  group('skin and hair routine', () {
    Future<void> openRoutineTab(WidgetTester tester) async {
      await pumpScreen(tester, const HealthFitnessScreen());
      await openTab(tester, 'العناية بالبشرة');
    }

    testWidgets('start empty', (tester) async {
      await openRoutineTab(tester);

      expect(find.text('لم تُضف منتجات بعد. اضغط + للإضافة.'), findsOneWidget);
    });

    testWidgets('a product keeps its time and steps, and can be deleted', (tester) async {
      await openRoutineTab(tester);

      await tester.tap(find.byTooltip('إضافة منتج'));
      await tester.pumpAndSettle();
      await fillDialog(tester, {'المنتج': 'مرطب', 'طريقة الاستخدام (اختياري)': 'بعد التنظيف'});

      expect(find.text('مرطب'), findsOneWidget);
      expect(find.text('صباحاً - بعد التنظيف'), findsOneWidget);

      await tester.tap(find.byTooltip('حذف المنتج'));
      await tester.pump();
      await tester.pump();
      expect((await health()).beautyItems(), isEmpty);
    });
  });
}
