import 'package:flutter/foundation.dart';
import '../../core/services/database_service.dart';
import '../../core/utils/arabic_text.dart';
import '../../core/utils/ids.dart';
import '../../core/utils/quantity.dart';
import 'models/laundry_entry.dart';
import 'models/pantry_item.dart';
import 'models/recipe.dart';
import 'models/shopping_item.dart';

/// عنصر محذوف مع مكانه، لإرجاعه بزر "تراجع".
class Removed<T> {
  const Removed(this.item, this.index);

  final T item;
  final int index;
}

class ShoppingAddResult {
  const ShoppingAddResult({required this.added, required this.merged});

  /// بنود جديدة أُضيفت.
  final int added;

  /// بنود موجودة في القائمة أصلًا (جُمعت كميتها أو تُركت كما هي).
  final int merged;
}

/// كل بيانات المطبخ والمنزل (وصفات، مؤونة ومستلزمات، مشتريات، غسيل) في مكان واحد تقرؤه
/// الشاشات ويستعمله الوكيل لاحقًا. التخزين نصوص JSON في [DatabaseService]، والمخزن يمنح
/// كل عنصر معرّفًا ثابتًا ويحفظه فور القراءة إن غاب (البيانات القديمة بلا معرّفات).
class KitchenStore extends ChangeNotifier {
  KitchenStore(this._db) {
    _load();
  }

  static Future<KitchenStore> open() async => KitchenStore(await DatabaseService.getInstance());

  static const String outOfStockSource = 'نفد من المؤونة';
  static const String defaultPantryCategory = 'أخرى';

  final DatabaseService _db;
  List<Recipe> _recipes = [];
  List<PantryItem> _pantry = [];
  List<ShoppingItem> _shopping = [];
  List<LaundryEntry> _laundry = [];

  /// المثبّتة أولًا ثم بترتيب الحفظ (الأحدث أولًا).
  List<Recipe> get recipes => _pinnedFirst(_recipes, (r) => r.pinned);
  List<PantryItem> get pantry => List.unmodifiable(_pantry);
  List<ShoppingItem> get shopping => List.unmodifiable(_shopping);
  List<LaundryEntry> get laundry => List.unmodifiable(_laundry);

  static List<T> _pinnedFirst<T>(List<T> items, bool Function(T) pinned) {
    return [...items.where(pinned), ...items.where((i) => !pinned(i))];
  }

  void _load() {
    final rawRecipes = _db.getRecipes();
    final rawPantry = _db.getPantry();
    final rawShopping = _db.getShopping();
    final rawLaundry = _db.getLaundrySchedule();
    _recipes = [for (final m in rawRecipes) Recipe.fromMap(m)];
    _pantry = [for (final m in rawPantry) PantryItem.fromMap(m)];
    _shopping = [for (final m in rawShopping) ShoppingItem.fromMap(m)];
    _laundry = [for (final m in rawLaundry) LaundryEntry.fromMap(m)];
    // معرّفات أُنشئت الآن للبيانات القديمة: تُحفظ فورًا حتى لا تتغير عند القراءة التالية.
    if (rawRecipes.any((m) => m['id'] == null)) _saveRecipes();
    if (rawPantry.any((m) => m['id'] == null)) _savePantry();
    if (rawShopping.any((m) => m['id'] == null)) _saveShopping();
    if (rawLaundry.any((m) => m['id'] == null)) _saveLaundry();
  }

  Future<void> _saveRecipes() => _db.saveRecipes([for (final r in _recipes) r.toMap()]);
  Future<void> _savePantry() => _db.savePantry([for (final p in _pantry) p.toMap()]);
  Future<void> _saveShopping() => _db.saveShopping([for (final s in _shopping) s.toMap()]);
  Future<void> _saveLaundry() => _db.saveLaundrySchedule([for (final l in _laundry) l.toMap()]);

  // --- الوصفات ---

  Recipe? recipeById(String id) => _recipes.where((r) => r.id == id).firstOrNull;

  Future<Recipe> addRecipe(Recipe recipe) async {
    final saved = Recipe(
      id: recipe.id.isEmpty ? newId() : recipe.id,
      title: recipe.title,
      category: recipe.category,
      servings: recipe.servings,
      ingredients: recipe.ingredients,
      steps: recipe.steps,
      notes: recipe.notes,
      ingredientsText: recipe.ingredientsText,
      pinned: recipe.pinned,
      createdAt: recipe.createdAt.isEmpty ? DateTime.now().toIso8601String() : recipe.createdAt,
    );
    _recipes.insert(0, saved);
    notifyListeners();
    await _saveRecipes();
    return saved;
  }

  Future<void> updateRecipe(Recipe recipe) async {
    final i = _recipes.indexWhere((r) => r.id == recipe.id);
    if (i < 0) return;
    _recipes[i] = recipe;
    notifyListeners();
    await _saveRecipes();
  }

  Future<void> toggleRecipePin(String id) async {
    final recipe = recipeById(id);
    if (recipe != null) await updateRecipe(recipe.copyWith(pinned: !recipe.pinned));
  }

  Future<Removed<Recipe>?> removeRecipe(String id) async {
    final i = _recipes.indexWhere((r) => r.id == id);
    if (i < 0) return null;
    final removed = Removed(_recipes.removeAt(i), i);
    notifyListeners();
    await _saveRecipes();
    return removed;
  }

  Future<void> restoreRecipe(Removed<Recipe> removed) async {
    _recipes.insert(removed.index.clamp(0, _recipes.length), removed.item);
    notifyListeners();
    await _saveRecipes();
  }

  // --- المؤونة والمستلزمات المنزلية ---

  PantryItem? pantryById(String id) => _pantry.where((p) => p.id == id).firstOrNull;

  /// هل في المؤونة صنف بهذا الاسم (مع توحيد الكتابة العربية)؟
  bool pantryHas(String name) => _pantry.any((p) => sameArabicItem(p.name, name));

  Future<PantryItem> addPantryItem({required String name, String qty = '', required String category}) async {
    final item = PantryItem(id: newId(), name: name, qty: qty, category: category);
    _pantry.add(item);
    notifyListeners();
    await _savePantry();
    return item;
  }

  Future<void> updatePantryItem(PantryItem item) async {
    final i = _pantry.indexWhere((p) => p.id == item.id);
    if (i < 0) return;
    _pantry[i] = item;
    notifyListeners();
    await _savePantry();
  }

  Future<void> togglePantryPin(String id) async {
    final item = pantryById(id);
    if (item != null) await updatePantryItem(item.copyWith(pinned: !item.pinned));
  }

  /// يزيد الكمية أو ينقصها بمقدار [delta] إن كانت رقمية؛ غير ذلك لا يغيّر شيئًا.
  Future<void> adjustPantryQty(String id, int delta) async {
    final item = pantryById(id);
    final next = item?.adjusted(delta);
    if (item != null && next != null) await updatePantryItem(item.copyWith(qty: next));
  }

  Future<Removed<PantryItem>?> removePantryItem(String id) async {
    final i = _pantry.indexWhere((p) => p.id == id);
    if (i < 0) return null;
    final removed = Removed(_pantry.removeAt(i), i);
    notifyListeners();
    await _savePantry();
    return removed;
  }

  Future<void> restorePantryItem(Removed<PantryItem> removed) async {
    _pantry.insert(removed.index.clamp(0, _pantry.length), removed.item);
    notifyListeners();
    await _savePantry();
  }

  /// "نفد": ينقل الصنف من المؤونة إلى المشتريات. يرجّع ما يلزم للتراجع.
  Future<({Removed<PantryItem> pantry, ShoppingItem? shopping})?> markOutOfStock(String id) async {
    final removed = await removePantryItem(id);
    if (removed == null) return null;
    final existing = _shopping.where((s) => !s.done && sameArabicItem(s.name, removed.item.name)).firstOrNull;
    ShoppingItem? added;
    if (existing == null) {
      added = await addShoppingItem(name: removed.item.name, qty: removed.item.qty, source: outOfStockSource);
    }
    return (pantry: removed, shopping: added);
  }

  Future<void> undoOutOfStock(({Removed<PantryItem> pantry, ShoppingItem? shopping}) moved) async {
    final shopping = moved.shopping;
    if (shopping != null) await removeShoppingItem(shopping.id);
    await restorePantryItem(moved.pantry);
  }

  // --- المشتريات ---

  Future<ShoppingItem> addShoppingItem({required String name, String qty = '', String source = ''}) async {
    final item = ShoppingItem(id: newId(), name: name, qty: qty, source: source);
    _shopping.add(item);
    notifyListeners();
    await _saveShopping();
    return item;
  }

  Future<void> updateShoppingItem(ShoppingItem item) async {
    final i = _shopping.indexWhere((s) => s.id == item.id);
    if (i < 0) return;
    _shopping[i] = item;
    notifyListeners();
    await _saveShopping();
  }

  Future<void> toggleShoppingDone(String id) async {
    final item = _shopping.where((s) => s.id == id).firstOrNull;
    if (item != null) await updateShoppingItem(item.copyWith(done: !item.done));
  }

  Future<Removed<ShoppingItem>?> removeShoppingItem(String id) async {
    final i = _shopping.indexWhere((s) => s.id == id);
    if (i < 0) return null;
    final removed = Removed(_shopping.removeAt(i), i);
    notifyListeners();
    await _saveShopping();
    return removed;
  }

  Future<void> restoreShoppingItem(Removed<ShoppingItem> removed) async {
    _shopping.insert(removed.index.clamp(0, _shopping.length), removed.item);
    notifyListeners();
    await _saveShopping();
  }

  /// يضيف مكوّنات [recipe] (المحسوبة لحصصها الحالية) المختارة بفهارسها. البند الموجود غير
  /// المشترى يُجمع إن اتفقت وحدته وإلا يُترك كما هو، حتى لا تتكرر القائمة.
  Future<ShoppingAddResult> addRecipeToShopping(Recipe recipe, Iterable<int> indexes) async {
    var added = 0;
    var merged = 0;
    for (final i in indexes) {
      if (i < 0 || i >= recipe.ingredients.length) continue;
      final ingredient = recipe.ingredients[i];
      final existing = _shopping.indexWhere((s) => !s.done && sameArabicItem(s.name, ingredient.name));
      if (existing < 0) {
        _shopping.add(ShoppingItem(
          id: newId(),
          name: ingredient.name,
          qty: ingredient.quantityText,
          source: recipe.title,
        ));
        added++;
      } else {
        final sum = _sumQuantities(_shopping[existing].qty, ingredient.quantityText);
        if (sum != null) _shopping[existing] = _shopping[existing].copyWith(qty: sum);
        merged++;
      }
    }
    if (added > 0 || merged > 0) {
      notifyListeners();
      await _saveShopping();
    }
    return ShoppingAddResult(added: added, merged: merged);
  }

  /// "2 كجم" + "1 كجم" = "3 كجم". null إن اختلفت الوحدة أو لم تكن رقمية.
  static String? _sumQuantities(String a, String b) {
    final x = splitQuantityText(a);
    final y = splitQuantityText(b);
    if (x.amount == null || y.amount == null || x.unit != y.unit) return null;
    return joinQuantity(x.amount! + y.amount!, x.unit);
  }

  Future<int> clearDoneShopping() async {
    final before = _shopping.length;
    _shopping.removeWhere((s) => s.done);
    final removed = before - _shopping.length;
    if (removed > 0) {
      notifyListeners();
      await _saveShopping();
    }
    return removed;
  }

  /// ينقل المشتراة إلى المؤونة (يجمع الكمية مع الصنف الموجود إن اتفقت الوحدة) ويحذفها من القائمة.
  Future<int> moveBoughtToPantry() async {
    final bought = _shopping.where((s) => s.done).toList();
    if (bought.isEmpty) return 0;
    for (final item in bought) {
      final i = _pantry.indexWhere((p) => sameArabicItem(p.name, item.name));
      if (i < 0) {
        _pantry.add(PantryItem(id: newId(), name: item.name, qty: item.qty, category: defaultPantryCategory));
      } else {
        final sum = _sumQuantities(_pantry[i].qty, item.qty);
        if (sum != null) _pantry[i] = _pantry[i].copyWith(qty: sum);
      }
    }
    _shopping.removeWhere((s) => s.done);
    notifyListeners();
    await _savePantry();
    await _saveShopping();
    return bought.length;
  }

  // --- الغسيل ---

  Future<LaundryEntry> addLaundry({required String day, required String type, String care = ''}) async {
    final entry = LaundryEntry(id: newId(), day: day, type: type, care: care);
    _laundry.add(entry);
    notifyListeners();
    await _saveLaundry();
    return entry;
  }

  Future<void> updateLaundry(LaundryEntry entry) async {
    final i = _laundry.indexWhere((l) => l.id == entry.id);
    if (i < 0) return;
    _laundry[i] = entry;
    notifyListeners();
    await _saveLaundry();
  }

  Future<Removed<LaundryEntry>?> removeLaundry(String id) async {
    final i = _laundry.indexWhere((l) => l.id == id);
    if (i < 0) return null;
    final removed = Removed(_laundry.removeAt(i), i);
    notifyListeners();
    await _saveLaundry();
    return removed;
  }

  Future<void> restoreLaundry(Removed<LaundryEntry> removed) async {
    _laundry.insert(removed.index.clamp(0, _laundry.length), removed.item);
    notifyListeners();
    await _saveLaundry();
  }
}
