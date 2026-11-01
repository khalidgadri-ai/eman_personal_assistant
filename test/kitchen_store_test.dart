import 'package:eman_life_app/core/services/database_service.dart';
import 'package:eman_life_app/features/kitchen_and_home/kitchen_store.dart';
import 'package:eman_life_app/features/kitchen_and_home/models/pantry_item.dart';
import 'package:eman_life_app/features/kitchen_and_home/models/recipe.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Future<KitchenStore> openStore([Map<String, Object> prefs = const {}]) async {
    SharedPreferences.setMockInitialValues({...prefs});
    DatabaseService.resetForTesting();
    return KitchenStore.open();
  }

  /// يفتح مخزنًا جديدًا فوق نفس البيانات المحفوظة، كما لو أُعيد فتح التطبيق.
  Future<KitchenStore> reopen() async {
    DatabaseService.resetForTesting();
    return KitchenStore.open();
  }

  group('recipes', () {
    test('an old recipe with free-text ingredients is read as it was, and gets a stable id', () async {
      final store = await openStore({
        'recipes': '[{"title":"شوربة عدس","category":"غداء","ingredients":"عدس، ماء، ملح"}]',
      });

      final recipe = store.recipes.single;
      expect(recipe.title, 'شوربة عدس');
      expect(recipe.ingredientsText, 'عدس، ماء، ملح');
      expect(recipe.ingredients, isEmpty);
      expect(recipe.servings, Recipe.defaultServings);
      expect(recipe.id, isNotEmpty);

      final again = await reopen();
      expect(again.recipes.single.id, recipe.id, reason: 'the id was saved the first time it was created');
    });

    test('add, update, pin, remove and undo, all persisted', () async {
      final store = await openStore();
      final saved = await store.addRecipe(const Recipe(id: '', title: 'كبسة', category: 'غداء', servings: 4));
      await store.addRecipe(const Recipe(id: '', title: 'سلطة', category: 'عشاء'));

      expect(store.recipes.map((r) => r.title), ['سلطة', 'كبسة'], reason: 'newest first');
      expect(saved.createdAt, isNotEmpty);

      await store.updateRecipe(store.recipeById(saved.id)!.copyWith(title: 'كبسة دجاج', steps: ['اغسل الأرز']));
      await store.toggleRecipePin(saved.id);
      expect(store.recipes.first.title, 'كبسة دجاج', reason: 'pinned recipes come first');

      var reopened = await reopen();
      expect(reopened.recipes.first.pinned, isTrue);
      expect(reopened.recipes.first.steps, ['اغسل الأرز']);

      final removed = await reopened.removeRecipe(saved.id);
      expect(reopened.recipes.map((r) => r.title), ['سلطة']);
      await reopened.restoreRecipe(removed!);
      reopened = await reopen();
      expect(reopened.recipes.map((r) => r.title), containsAll(['سلطة', 'كبسة دجاج']));
    });

    test('changing the servings rescales numeric amounts and leaves "to taste" alone', () {
      const recipe = Recipe(
        id: 'r',
        title: 'عجين',
        category: 'أخرى',
        servings: 4,
        ingredients: [
          RecipeIngredient(name: 'دقيق', amount: 2, unit: 'كوب'),
          RecipeIngredient(name: 'ملح', amount: 0.5, unit: 'ملعقة صغيرة'),
          RecipeIngredient(name: 'بهارات', unit: 'حسب الذوق'),
        ],
      );

      final six = recipe.scaledTo(6);

      expect(six.servings, 6);
      expect(six.ingredients[0].amount, 3);
      expect(six.ingredients[1].amount, 0.75);
      expect(six.ingredients[1].quantityText, '¾ ملعقة صغيرة');
      expect(six.ingredients[2].amount, isNull);
      expect(six.ingredients[2].quantityText, 'حسب الذوق');
      expect(recipe.ingredients[0].amount, 2, reason: 'the original is untouched');
      expect(recipe.scaledTo(2).ingredients[0].amount, 1);
      expect(recipe.scaledTo(0).servings, 1, reason: 'servings never go below one');
      expect(recipe.scaledTo(1000).servings, Recipe.maxServings);
    });

    test('ingredients survive a save and load round trip', () async {
      final store = await openStore();
      await store.addRecipe(const Recipe(
        id: '',
        title: 'خبز',
        category: 'فطور',
        servings: 2,
        ingredients: [RecipeIngredient(name: 'طحين', amount: 1.5, unit: 'كوب')],
        steps: ['اعجن', 'اخبز'],
        notes: 'يؤكل ساخنًا',
      ));

      final back = (await reopen()).recipes.single;

      expect(back.ingredients.single.name, 'طحين');
      expect(back.ingredients.single.amount, 1.5);
      expect(back.steps, ['اعجن', 'اخبز']);
      expect(back.notes, 'يؤكل ساخنًا');
      expect(back.servings, 2);
    });
  });

  group('pantry and home supplies', () {
    test('old items without ids or pin are read, given ids once, and keep their data', () async {
      final store = await openStore({
        'pantry': '[{"name":"أرز","qty":"2 كجم","category":"الحبوب والبقوليات"},{"name":"منظف","qty":"","category":"مستلزمات التنظيف"}]',
      });

      expect(store.pantry.map((p) => p.name), ['أرز', 'منظف']);
      expect(store.pantry.every((p) => p.id.isNotEmpty && !p.pinned), isTrue);
      final ids = store.pantry.map((p) => p.id).toList();

      expect((await reopen()).pantry.map((p) => p.id), ids);
    });

    test('add, edit, pin and remove with undo at the same place', () async {
      final store = await openStore();
      final rice = await store.addPantryItem(name: 'أرز', qty: '2 كجم', category: 'الحبوب والبقوليات');
      await store.addPantryItem(name: 'سكر', category: 'أخرى');
      await store.addPantryItem(name: 'ملح', category: 'أخرى');

      await store.updatePantryItem(rice.copyWith(name: 'أرز بسمتي', qty: '3 كجم'));
      await store.togglePantryPin(rice.id);
      expect((await reopen()).pantry.first.pinned, isTrue);

      final removed = await store.removePantryItem(store.pantry[1].id);
      expect(store.pantry.map((p) => p.name), ['أرز بسمتي', 'ملح']);
      await store.restorePantryItem(removed!);
      expect(store.pantry.map((p) => p.name), ['أرز بسمتي', 'سكر', 'ملح']);
    });

    test('plus and minus keep the unit, never go below zero, and ignore text quantities', () async {
      final store = await openStore();
      final milk = await store.addPantryItem(name: 'حليب', qty: '2 لتر', category: 'الألبان واللحوم');
      final blank = await store.addPantryItem(name: 'بيض', category: 'الألبان واللحوم');
      final lots = await store.addPantryItem(name: 'بهارات', qty: 'كثير', category: 'أخرى');

      await store.adjustPantryQty(milk.id, 1);
      expect(store.pantryById(milk.id)!.qty, '3 لتر');
      await store.adjustPantryQty(milk.id, -5);
      expect(store.pantryById(milk.id)!.qty, '0 لتر');
      await store.adjustPantryQty(blank.id, 1);
      expect(store.pantryById(blank.id)!.qty, '1');
      await store.adjustPantryQty(lots.id, 1);
      expect(store.pantryById(lots.id)!.qty, 'كثير', reason: 'a text quantity is left alone');
      expect(store.pantryById(lots.id)!.canAdjust, isFalse);
      expect(store.pantryById(milk.id)!.canAdjust, isTrue);
    });

    test('pantryHas understands Arabic spelling variants', () async {
      final store = await openStore();
      await store.addPantryItem(name: 'الطماطم', category: 'الخضار والفواكه');

      expect(store.pantryHas('طماطم'), isTrue);
      expect(store.pantryHas('بصل'), isFalse);
    });

    test('running out moves the item to the shopping list, and undo puts everything back', () async {
      final store = await openStore();
      final sugar = await store.addPantryItem(name: 'سكر', qty: '1 كجم', category: 'أخرى');

      final moved = await store.markOutOfStock(sugar.id);

      expect(store.pantry, isEmpty);
      expect(store.shopping.single.name, 'سكر');
      expect(store.shopping.single.source, KitchenStore.outOfStockSource);

      await store.undoOutOfStock(moved!);
      expect(store.pantry.single.name, 'سكر');
      expect(store.shopping, isEmpty);
    });

    test('running out of something already on the list does not duplicate it', () async {
      final store = await openStore();
      await store.addShoppingItem(name: 'سكر');
      final sugar = await store.addPantryItem(name: 'السكر', category: 'أخرى');

      final moved = await store.markOutOfStock(sugar.id);

      expect(store.shopping, hasLength(1));
      expect(moved!.shopping, isNull);
    });

    test('adding to the pantry keeps old data intact in the saved JSON shape', () async {
      final store = await openStore();
      await store.addPantryItem(name: 'أرز', qty: '2 كجم', category: 'أخرى');

      final raw = (await DatabaseService.getInstance()).getPantry().single;

      expect(raw['name'], 'أرز');
      expect(raw['qty'], '2 كجم');
      expect(raw['category'], 'أخرى');
      expect(PantryItem.fromMap(raw).id, raw['id']);
    });
  });

  group('shopping list', () {
    test('add, tick, edit, remove and undo', () async {
      final store = await openStore();
      final milk = await store.addShoppingItem(name: 'حليب', qty: '2 لتر');
      await store.addShoppingItem(name: 'خبز');

      await store.toggleShoppingDone(milk.id);
      await store.updateShoppingItem(store.shopping.first.copyWith(name: 'حليب كامل الدسم'));
      expect((await reopen()).shopping.first.done, isTrue);

      final removed = await store.removeShoppingItem(milk.id);
      expect(store.shopping.map((s) => s.name), ['خبز']);
      await store.restoreShoppingItem(removed!);
      expect(store.shopping.map((s) => s.name), ['حليب كامل الدسم', 'خبز']);
    });

    test('a recipe adds its scaled ingredients, merging what is already on the list', () async {
      final store = await openStore();
      await store.addShoppingItem(name: 'دقيق', qty: '1 كوب');
      await store.addShoppingItem(name: 'ملح', qty: 'قليل');
      const recipe = Recipe(
        id: 'r',
        title: 'كعك',
        category: 'حلويات',
        servings: 4,
        ingredients: [
          RecipeIngredient(name: 'الدقيق', amount: 2, unit: 'كوب'),
          RecipeIngredient(name: 'ملح', amount: 1, unit: 'ملعقة'),
          RecipeIngredient(name: 'سكر', amount: 0.5, unit: 'كوب'),
        ],
      );

      final result = await store.addRecipeToShopping(recipe.scaledTo(8), [0, 1, 2]);

      expect(result.added, 1);
      expect(result.merged, 2);
      expect(store.shopping.firstWhere((s) => s.name == 'دقيق').qty, '5 كوب', reason: '1 + (2 × 2)');
      expect(store.shopping.firstWhere((s) => s.name == 'ملح').qty, 'قليل', reason: 'different units are not summed');
      final sugar = store.shopping.firstWhere((s) => s.name == 'سكر');
      expect(sugar.qty, '1 كوب');
      expect(sugar.source, 'كعك');
    });

    test('only the chosen ingredients are added, and bad indexes are ignored', () async {
      final store = await openStore();
      const recipe = Recipe(
        id: 'r',
        title: 'شوربة',
        category: 'غداء',
        ingredients: [RecipeIngredient(name: 'عدس'), RecipeIngredient(name: 'ماء')],
      );

      final result = await store.addRecipeToShopping(recipe, [1, 7, -1]);

      expect(result.added, 1);
      expect(store.shopping.single.name, 'ماء');
    });

    test('clearing the bought items keeps the rest', () async {
      final store = await openStore();
      final a = await store.addShoppingItem(name: 'أ');
      await store.addShoppingItem(name: 'ب');
      await store.toggleShoppingDone(a.id);

      expect(await store.clearDoneShopping(), 1);
      expect(store.shopping.map((s) => s.name), ['ب']);
      expect(await store.clearDoneShopping(), 0);
    });

    test('bought items move to the pantry, adding to what is already there', () async {
      final store = await openStore();
      await store.addPantryItem(name: 'أرز', qty: '1 كجم', category: 'الحبوب والبقوليات');
      final rice = await store.addShoppingItem(name: 'أرز', qty: '2 كجم');
      final tea = await store.addShoppingItem(name: 'شاي', qty: '1 علبة');
      await store.addShoppingItem(name: 'لم يُشترَ بعد');
      await store.toggleShoppingDone(rice.id);
      await store.toggleShoppingDone(tea.id);

      expect(await store.moveBoughtToPantry(), 2);

      expect(store.shopping.map((s) => s.name), ['لم يُشترَ بعد']);
      expect(store.pantry.firstWhere((p) => p.name == 'أرز').qty, '3 كجم');
      final newTea = store.pantry.firstWhere((p) => p.name == 'شاي');
      expect(newTea.qty, '1 علبة');
      expect(newTea.category, KitchenStore.defaultPantryCategory);
      expect((await reopen()).pantry, hasLength(2));
    });
  });

  group('laundry', () {
    test('add, edit, remove with undo, persisted', () async {
      final store = await openStore();
      final entry = await store.addLaundry(day: 'السبت', type: 'ملابس ملونة', care: 'ماء بارد');
      await store.addLaundry(day: 'الأحد', type: 'مفروشات');

      await store.updateLaundry(entry.copyWith(day: 'الاثنين', type: 'ملابس بيضاء'));
      expect((await reopen()).laundry.first.day, 'الاثنين');

      final removed = await store.removeLaundry(entry.id);
      expect(store.laundry.map((l) => l.type), ['مفروشات']);
      await store.restoreLaundry(removed!);
      expect(store.laundry.first.type, 'ملابس بيضاء');
    });

    test('old entries without ids are read and keep their data', () async {
      final store = await openStore({
        'laundry_schedule': '[{"day":"السبت","type":"ملابس ملونة","care":"ماء بارد"}]',
      });

      expect(store.laundry.single.day, 'السبت');
      expect(store.laundry.single.care, 'ماء بارد');
      expect(store.laundry.single.id, isNotEmpty);
    });
  });

  test('every change notifies listeners so open screens refresh', () async {
    final store = await openStore();
    var calls = 0;
    store.addListener(() => calls++);

    await store.addRecipe(const Recipe(id: '', title: 'أ', category: 'أخرى'));
    await store.addPantryItem(name: 'ب', category: 'أخرى');
    await store.addShoppingItem(name: 'ج');
    await store.addLaundry(day: 'السبت', type: 'د');

    expect(calls, 4);
  });

  test('the shopping list is part of the encrypted backup', () {
    expect(DatabaseService.backupListKeys, contains('shopping'));
    expect(DatabaseService.backupListKeys, isNot(contains('feedback_entries')));
  });
}
