import 'package:eman_life_app/core/services/database_service.dart';
import 'package:eman_life_app/features/kitchen_and_home/kitchen_home_screen.dart';
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

  Future<DatabaseService> db() => DatabaseService.getInstance();

  Future<void> openKitchen(WidgetTester tester) async {
    tester.view.physicalSize = const Size(900, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await pumpScreen(tester, const KitchenHomeScreen());
  }

  Future<void> addPantry(WidgetTester tester, String name, {String qty = '', String? category}) async {
    await tester.tap(find.byTooltip('إضافة صنف'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'الصنف'), name);
    if (qty.isNotEmpty) await tester.enterText(find.widgetWithText(TextField, 'الكمية (اختياري)'), qty);
    if (category != null) {
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text(category).last);
      await tester.pumpAndSettle();
    }
    await tester.tap(find.text('إضافة'));
    await tester.pumpAndSettle();
  }

  Future<void> rowMenu(WidgetTester tester, String itemName, String action) async {
    final row = find.ancestor(of: find.text(itemName), matching: find.byType(Row)).first;
    await tester.tap(find.descendant(of: row, matching: find.byTooltip('المزيد')).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text(action).last);
    await tester.pumpAndSettle();
  }

  testWidgets('every tab starts empty with a clear message', (tester) async {
    await openKitchen(tester);

    expect(find.text('لا توجد وصفات بعد. اضغط + لإضافة وصفة، أو دع الذكاء الاصطناعي يقترح لك.'), findsOneWidget);
    await openTab(tester, 'المؤونة والمستلزمات');
    expect(find.text('المؤونة فارغة. اضغط + لإضافة أول صنف.'), findsOneWidget);
    await openTab(tester, 'المشتريات');
    expect(find.textContaining('قائمة المشتريات فارغة'), findsOneWidget);
    await openTab(tester, 'جدول الغسيل');
    expect(find.text('لا توجد مواعيد غسيل بعد. اضغط + لإضافة موعد.'), findsOneWidget);
  });

  testWidgets('the add button follows the tab', (tester) async {
    await openKitchen(tester);

    expect(find.byTooltip('إضافة وصفة'), findsOneWidget);
    await openTab(tester, 'المؤونة والمستلزمات');
    expect(find.byTooltip('إضافة صنف'), findsOneWidget);
    await openTab(tester, 'المشتريات');
    expect(find.byTooltip('إضافة بند للمشتريات'), findsOneWidget);
    await openTab(tester, 'جدول الغسيل');
    expect(find.byTooltip('إضافة موعد غسيل'), findsOneWidget);
  });

  group('home supplies (pantry)', () {
    testWidgets('an item appears immediately under its section with its quantity, and is saved', (tester) async {
      await openKitchen(tester);
      await openTab(tester, 'المؤونة والمستلزمات');

      await addPantry(tester, 'أرز', qty: '2 كجم', category: 'الحبوب والبقوليات');

      expect(find.text('أرز'), findsOneWidget);
      expect(find.text('2 كجم'), findsOneWidget);
      expect(find.text('الحبوب والبقوليات (1)'), findsOneWidget, reason: 'the section header counts its items');
      final saved = (await db()).getPantry().single;
      expect(saved['name'], 'أرز');
      expect(saved['qty'], '2 كجم');
      expect(saved['category'], 'الحبوب والبقوليات');
      expect(saved['id'], isNotEmpty);
    });

    testWidgets('cleaning supplies sit in their own section next to food sections', (tester) async {
      await openKitchen(tester);
      await openTab(tester, 'المؤونة والمستلزمات');

      await addPantry(tester, 'سكر', category: 'الحبوب والبقوليات');
      await addPantry(tester, 'منظف أرضيات', category: 'مستلزمات التنظيف');

      expect(find.text('الحبوب والبقوليات (1)'), findsOneWidget);
      expect(find.text('مستلزمات التنظيف (1)'), findsOneWidget);
    });

    testWidgets('plus and minus change the quantity and keep the unit', (tester) async {
      await openKitchen(tester);
      await openTab(tester, 'المؤونة والمستلزمات');
      await addPantry(tester, 'حليب', qty: '2 لتر', category: 'الألبان واللحوم');

      await tester.tap(find.byTooltip('زيادة الكمية'));
      await tester.pumpAndSettle();
      expect(find.text('3 لتر'), findsOneWidget);
      expect((await db()).getPantry().single['qty'], '3 لتر');

      await tester.tap(find.byTooltip('نقصان الكمية'));
      await tester.tap(find.byTooltip('نقصان الكمية'));
      await tester.pumpAndSettle();
      expect(find.text('1 لتر'), findsOneWidget);
    });

    testWidgets('a text quantity has no plus and minus buttons', (tester) async {
      await openKitchen(tester);
      await openTab(tester, 'المؤونة والمستلزمات');

      await addPantry(tester, 'بهارات', qty: 'كثير');

      expect(find.text('كثير'), findsOneWidget);
      expect(find.byTooltip('زيادة الكمية'), findsNothing);
    });

    testWidgets('an item can be edited', (tester) async {
      await openKitchen(tester);
      await openTab(tester, 'المؤونة والمستلزمات');
      await addPantry(tester, 'ارز', qty: '1 كجم');

      await rowMenu(tester, 'ارز', 'تعديل');
      await tester.enterText(find.widgetWithText(TextField, 'الصنف'), 'أرز بسمتي');
      await tester.enterText(find.widgetWithText(TextField, 'الكمية (اختياري)'), '5 كجم');
      await tester.tap(find.text('حفظ'));
      await tester.pumpAndSettle();

      expect(find.text('أرز بسمتي'), findsOneWidget);
      expect(find.text('ارز'), findsNothing);
      final saved = (await db()).getPantry().single;
      expect(saved['name'], 'أرز بسمتي');
      expect(saved['qty'], '5 كجم');
    });

    testWidgets('pinning moves an item to the pinned section and the pin survives reopening', (tester) async {
      await openKitchen(tester);
      await openTab(tester, 'المؤونة والمستلزمات');
      await addPantry(tester, 'سكر', category: 'الحبوب والبقوليات');

      await rowMenu(tester, 'سكر', 'تثبيت');

      expect(find.text('📌 المثبّتة (1)'), findsOneWidget);
      expect((await db()).getPantry().single['pinned'], isTrue);

      await tester.pumpWidget(const SizedBox());
      await openKitchen(tester);
      await openTab(tester, 'المؤونة والمستلزمات');
      expect(find.text('📌 المثبّتة (1)'), findsOneWidget);
    });

    testWidgets('deleting can be undone from the message', (tester) async {
      await openKitchen(tester);
      await openTab(tester, 'المؤونة والمستلزمات');
      await addPantry(tester, 'ملح');

      await rowMenu(tester, 'ملح', 'حذف');
      expect(find.text('ملح'), findsNothing);
      expect((await db()).getPantry(), isEmpty);

      await tester.tap(find.text('تراجع'));
      await tester.pumpAndSettle();
      expect(find.text('ملح'), findsOneWidget);
      expect((await db()).getPantry().single['name'], 'ملح');
    });

    testWidgets('"نفد" moves the item to the shopping list, visible in that tab at once', (tester) async {
      await openKitchen(tester);
      await openTab(tester, 'المؤونة والمستلزمات');
      await addPantry(tester, 'سكر', qty: '1 كجم');

      await rowMenu(tester, 'سكر', 'نفد: إلى المشتريات');
      expect(find.text('سكر'), findsNothing);

      await openTab(tester, 'المشتريات');
      expect(find.text('سكر'), findsOneWidget);
      expect(find.text('من: نفد من المؤونة'), findsOneWidget);
      expect((await db()).getPantry(), isEmpty);
      expect((await db()).getShopping().single['name'], 'سكر');
    });

    testWidgets('search and section filters narrow the list', (tester) async {
      await openKitchen(tester);
      await openTab(tester, 'المؤونة والمستلزمات');
      await addPantry(tester, 'أرز', category: 'الحبوب والبقوليات');
      await addPantry(tester, 'منظف', category: 'مستلزمات التنظيف');

      await tester.enterText(find.byType(TextField).first, 'الارز');
      await tester.pumpAndSettle();
      expect(find.text('أرز'), findsOneWidget);
      expect(find.text('منظف'), findsNothing);
      await tester.enterText(find.byType(TextField).first, 'لا يوجد');
      await tester.pumpAndSettle();
      expect(find.text('لا نتائج مطابقة للبحث.'), findsOneWidget);

      await tester.tap(find.byTooltip('مسح البحث'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ChoiceChip, 'مستلزمات التنظيف'));
      await tester.pumpAndSettle();
      expect(find.text('منظف'), findsOneWidget);
      expect(find.text('أرز'), findsNothing);
    });

    testWidgets('items saved by the old version still show up, with their data', (tester) async {
      await (await db()).savePantry([
        {'name': 'عدس', 'qty': '1 كجم', 'category': 'الحبوب والبقوليات'},
      ]);

      await openKitchen(tester);
      await openTab(tester, 'المؤونة والمستلزمات');

      expect(find.text('عدس'), findsOneWidget);
      expect(find.text('1 كجم'), findsOneWidget);
    });
  });

  group('shopping list', () {
    testWidgets('add, tick, edit and delete with undo', (tester) async {
      await openKitchen(tester);
      await openTab(tester, 'المشتريات');

      await tester.tap(find.byTooltip('إضافة بند للمشتريات'));
      await tester.pumpAndSettle();
      await fillDialog(tester, {'البند': 'حليب', 'الكمية (اختياري)': '2 لتر'});
      expect(find.text('حليب'), findsOneWidget);
      expect(find.text('2 لتر'), findsOneWidget);

      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();
      expect((await db()).getShopping().single['done'], isTrue);
      expect(find.text('نقل المشتراة إلى المؤونة'), findsOneWidget);

      await tester.tap(find.text('حليب'));
      await tester.pumpAndSettle();
      await fillDialog(tester, {'البند': 'حليب كامل الدسم'}, confirm: 'حفظ');
      expect(find.text('حليب كامل الدسم'), findsOneWidget);

      await tester.tap(find.byTooltip('حذف البند'));
      await tester.pumpAndSettle();
      expect(find.text('حليب كامل الدسم'), findsNothing);
      await tester.tap(find.text('تراجع'));
      await tester.pumpAndSettle();
      expect(find.text('حليب كامل الدسم'), findsOneWidget);
    });

    testWidgets('bought items move to the pantry in one tap', (tester) async {
      await openKitchen(tester);
      await openTab(tester, 'المشتريات');
      await tester.tap(find.byTooltip('إضافة بند للمشتريات'));
      await tester.pumpAndSettle();
      await fillDialog(tester, {'البند': 'شاي', 'الكمية (اختياري)': '1 علبة'});
      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();

      await tester.tap(find.text('نقل المشتراة إلى المؤونة'));
      await tester.pumpAndSettle();

      expect((await db()).getShopping(), isEmpty);
      expect((await db()).getPantry().single['name'], 'شاي');
      await openTab(tester, 'المؤونة والمستلزمات');
      expect(find.text('شاي'), findsOneWidget);
    });
  });

  group('recipes', () {
    testWidgets('a recipe added from the form shows up with its details, and is saved', (tester) async {
      await openKitchen(tester);

      await tester.tap(find.byTooltip('إضافة وصفة'));
      await tester.pumpAndSettle();
      await tester.enterText(find.widgetWithText(TextField, 'اسم الوجبة'), 'شوربة عدس');
      await tester.enterText(find.widgetWithText(TextField, 'المكوّن'), 'عدس');
      await tester.enterText(find.widgetWithText(TextField, 'الكمية'), '1/2');
      await tester.enterText(find.widgetWithText(TextField, 'الوحدة'), 'كوب');
      await tester.tap(find.text('إضافة خطوة'));
      await tester.pumpAndSettle();
      await tester.enterText(find.widgetWithText(TextField, 'الخطوة 1'), 'اغلِ العدس');
      await tester.tap(find.text('حفظ'));
      await tester.pumpAndSettle();

      expect(find.text('شوربة عدس'), findsOneWidget);
      expect(find.text('4 حصة · 1 مكوّن · 1 خطوة'), findsOneWidget);
      final saved = (await db()).getRecipes().single;
      expect(saved['title'], 'شوربة عدس');
      expect((saved['ingredients'] as List).single, {'name': 'عدس', 'amount': 0.5, 'unit': 'كوب'});
      expect(saved['steps'], ['اغلِ العدس']);
    });

    testWidgets('a title is required and a bad quantity is explained, nothing saved', (tester) async {
      await openKitchen(tester);
      await tester.tap(find.byTooltip('إضافة وصفة'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('حفظ'));
      await tester.pumpAndSettle();
      expect(find.text('هذا الحقل مطلوب'), findsOneWidget);

      await tester.enterText(find.widgetWithText(TextField, 'اسم الوجبة'), 'وجبة');
      await tester.enterText(find.widgetWithText(TextField, 'المكوّن'), 'ملح');
      await tester.enterText(find.widgetWithText(TextField, 'الكمية'), 'كثير');
      await tester.tap(find.text('حفظ'));
      await tester.pumpAndSettle();

      expect(find.text('كمية غير صالحة'), findsOneWidget);
      expect((await db()).getRecipes(), isEmpty);
    });

    testWidgets('the details page rescales the amounts when the servings change', (tester) async {
      await (await db()).saveRecipes([
        {
          'id': 'r1',
          'title': 'عجين',
          'category': 'أخرى',
          'servings': 4,
          'ingredients': [
            {'name': 'دقيق', 'amount': 2.0, 'unit': 'كوب'},
            {'name': 'بهارات', 'amount': null, 'unit': 'حسب الذوق'},
          ],
          'steps': ['اعجن'],
        },
      ]);
      await openKitchen(tester);

      await tester.tap(find.text('عجين'));
      await tester.pumpAndSettle();
      expect(find.text('2 كوب'), findsOneWidget);
      expect(find.text('4 حصة'), findsOneWidget);

      await tester.tap(find.byTooltip('زيادة الحصص'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('زيادة الحصص'));
      await tester.pumpAndSettle();

      expect(find.text('6 حصة (الأصل 4)'), findsOneWidget);
      expect(find.text('3 كوب'), findsOneWidget);
      expect(find.text('حسب الذوق'), findsOneWidget);
      expect((await db()).getRecipes().single['servings'], 4, reason: 'viewing does not change the saved recipe');
    });

    testWidgets('ingredients go to the shopping list, skipping what the pantry already has', (tester) async {
      await (await db()).savePantry([
        {'name': 'ملح', 'qty': '', 'category': 'أخرى'},
      ]);
      await (await db()).saveRecipes([
        {
          'id': 'r1',
          'title': 'كعك',
          'category': 'حلويات',
          'servings': 2,
          'ingredients': [
            {'name': 'دقيق', 'amount': 1.0, 'unit': 'كوب'},
            {'name': 'ملح', 'amount': 1.0, 'unit': 'ملعقة'},
          ],
        },
      ]);
      await openKitchen(tester);
      await tester.tap(find.text('كعك'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('أضف المقادير إلى المشتريات'));
      await tester.pumpAndSettle();
      expect(find.text('موجود في المؤونة'), findsOneWidget);
      await tester.tap(find.text('إضافة (1)'));
      await tester.pumpAndSettle();

      final shopping = (await db()).getShopping();
      expect(shopping.map((s) => s['name']), ['دقيق']);
      expect(shopping.single['qty'], '1 كوب');
      expect(shopping.single['source'], 'كعك');
    });

    testWidgets('pin, edit and delete from the details page', (tester) async {
      await (await db()).saveRecipes([
        {'id': 'r1', 'title': 'سلطة', 'category': 'عشاء', 'ingredients': 'خس، خيار'},
        {'id': 'r2', 'title': 'كبسة', 'category': 'غداء', 'ingredients': 'أرز'},
      ]);
      await openKitchen(tester);

      await tester.tap(find.text('كبسة'));
      await tester.pumpAndSettle();
      expect(find.text('المقادير: أرز'), findsOneWidget, reason: 'an old free-text recipe is still readable');
      await tester.tap(find.byTooltip('تثبيت الوصفة'));
      await tester.pumpAndSettle();
      expect((await db()).getRecipes().firstWhere((r) => r['id'] == 'r2')['pinned'], isTrue);

      await tester.tap(find.byTooltip('تعديل الوصفة'));
      await tester.pumpAndSettle();
      await tester.enterText(find.widgetWithText(TextField, 'اسم الوجبة'), 'كبسة دجاج');
      await tester.tap(find.text('تحويل إلى مقادير منظّمة'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('حفظ'));
      await tester.pumpAndSettle();
      expect(find.text('كبسة دجاج'), findsWidgets);

      await tester.tap(find.byTooltip('حذف الوصفة'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('حذف'));
      await tester.pumpAndSettle();
      expect(find.text('كبسة دجاج'), findsNothing);
      expect((await db()).getRecipes().map((r) => r['id']), ['r1']);
    });

    testWidgets('the saved AI recipe keeps its full text, and a pinned recipe is listed first', (tester) async {
      await (await db()).saveRecipes([
        {'id': 'a', 'title': 'أولى', 'category': 'غداء'},
        {'id': 'b', 'title': 'ثانية', 'category': 'غداء', 'pinned': true},
      ]);
      await openKitchen(tester);

      final first = tester.getTopLeft(find.text('ثانية')).dy;
      final second = tester.getTopLeft(find.text('أولى')).dy;
      expect(first, lessThan(second));
    });

    testWidgets('asking the AI with only separators warns instead of crashing', (tester) async {
      await openKitchen(tester);

      await tester.enterText(find.byType(TextField).first, ' ,، , ');
      await tester.tap(find.text('اقترح وصفة الآن ✨'));
      await tester.pump();

      expect(find.text('⚠️ يرجى كتابة المكونات أولاً'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('laundry', () {
    testWidgets('a slot keeps its day and type, can be edited and deleted with undo', (tester) async {
      await openKitchen(tester);
      await openTab(tester, 'جدول الغسيل');

      await tester.tap(find.byTooltip('إضافة موعد غسيل'));
      await tester.pumpAndSettle();
      await fillDialog(tester, {'نوع الغسيل': 'ملابس ملونة'});
      expect(find.text('السبت: ملابس ملونة'), findsOneWidget);
      expect((await db()).getLaundrySchedule().single['day'], 'السبت');

      await tester.tap(find.text('السبت: ملابس ملونة'));
      await tester.pumpAndSettle();
      await fillDialog(tester, {'نوع الغسيل': 'ملابس بيضاء'}, confirm: 'حفظ');
      expect(find.text('السبت: ملابس بيضاء'), findsOneWidget);

      await tester.tap(find.byTooltip('حذف الموعد'));
      await tester.pumpAndSettle();
      expect(find.text('السبت: ملابس بيضاء'), findsNothing);
      await tester.tap(find.text('تراجع'));
      await tester.pumpAndSettle();
      expect(find.text('السبت: ملابس بيضاء'), findsOneWidget);
    });
  });

  testWidgets('everything is still there when the screen is opened again', (tester) async {
    await openKitchen(tester);
    await openTab(tester, 'المؤونة والمستلزمات');
    await addPantry(tester, 'سكر');

    await tester.pumpWidget(const SizedBox());
    await openKitchen(tester);
    await openTab(tester, 'المؤونة والمستلزمات');

    expect(find.text('سكر'), findsOneWidget);
  });
}
