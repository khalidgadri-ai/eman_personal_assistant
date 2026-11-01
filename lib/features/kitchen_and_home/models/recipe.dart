import '../../../core/utils/ids.dart';
import '../../../core/utils/quantity.dart';

/// مكوّن في وصفة. [amount] null للمقادير غير الرقمية مثل "حسب الذوق" فلا تتغير مع الحصص.
class RecipeIngredient {
  const RecipeIngredient({required this.name, this.amount, this.unit = ''});

  final String name;
  final double? amount;
  final String unit;

  RecipeIngredient scaled(double factor) {
    final a = amount;
    return RecipeIngredient(name: name, amount: a == null ? null : a * factor, unit: unit);
  }

  /// الكمية والوحدة كما تُعرض: "2 كوب"، أو الوحدة وحدها إن لم تكن هناك كمية رقمية.
  String get quantityText {
    final a = amount;
    if (a == null) return unit;
    return joinQuantity(a, unit);
  }

  Map<String, dynamic> toMap() => {'name': name, 'amount': amount, 'unit': unit};

  static RecipeIngredient? fromMap(Object? raw) {
    if (raw is! Map) return null;
    final name = '${raw['name'] ?? ''}'.trim();
    if (name.isEmpty) return null;
    final amount = raw['amount'];
    return RecipeIngredient(
      name: name,
      amount: amount is num && amount.isFinite && amount >= 0 ? amount.toDouble() : null,
      unit: '${raw['unit'] ?? ''}',
    );
  }
}

/// وصفة محفوظة. الوصفات القديمة (مقادير نص حر بلا خطوات ولا حصص) تُقرأ كما هي: نصها في
/// [ingredientsText] وتبقى [ingredients] فارغة حتى يحوّلها المستخدم.
class Recipe {
  const Recipe({
    required this.id,
    required this.title,
    required this.category,
    this.servings = defaultServings,
    this.ingredients = const [],
    this.steps = const [],
    this.notes = '',
    this.ingredientsText = '',
    this.pinned = false,
    this.createdAt = '',
  });

  static const int defaultServings = 4;
  static const int maxServings = 100;

  final String id;
  final String title;
  final String category;
  final int servings;
  final List<RecipeIngredient> ingredients;
  final List<String> steps;
  final String notes;

  /// نص المقادير الحر للوصفات التي حُفظت قبل المقادير المنظّمة.
  final String ingredientsText;
  final bool pinned;
  final String createdAt;

  Recipe copyWith({
    String? title,
    String? category,
    int? servings,
    List<RecipeIngredient>? ingredients,
    List<String>? steps,
    String? notes,
    String? ingredientsText,
    bool? pinned,
  }) {
    return Recipe(
      id: id,
      title: title ?? this.title,
      category: category ?? this.category,
      servings: servings ?? this.servings,
      ingredients: ingredients ?? this.ingredients,
      steps: steps ?? this.steps,
      notes: notes ?? this.notes,
      ingredientsText: ingredientsText ?? this.ingredientsText,
      pinned: pinned ?? this.pinned,
      createdAt: createdAt,
    );
  }

  /// نفس الوصفة بمقادير مضروبة في (الحصص الجديدة ÷ الحصص الحالية).
  Recipe scaledTo(int newServings) {
    final target = newServings.clamp(1, maxServings);
    if (servings <= 0 || target == servings) return copyWith(servings: target);
    final factor = target / servings;
    return copyWith(
      servings: target,
      ingredients: [for (final i in ingredients) i.scaled(factor)],
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'category': category,
        'servings': servings,
        'ingredients': [for (final i in ingredients) i.toMap()],
        'ingredientsText': ingredientsText,
        'steps': steps,
        'notes': notes,
        'pinned': pinned,
        'createdAt': createdAt,
      };

  factory Recipe.fromMap(Map map) {
    final id = map['id'];
    final rawIngredients = map['ingredients'];
    final servings = map['servings'];
    final steps = map['steps'];
    return Recipe(
      id: id is String && id.isNotEmpty ? id : newId(),
      title: '${map['title'] ?? ''}',
      category: '${map['category'] ?? 'أخرى'}',
      servings: servings is int && servings >= 1 && servings <= maxServings ? servings : defaultServings,
      ingredients: rawIngredients is List
          ? [
              for (final raw in rawIngredients) ?RecipeIngredient.fromMap(raw),
            ]
          : const [],
      // الشكل القديم: 'ingredients' نص حر.
      ingredientsText: rawIngredients is String ? rawIngredients : '${map['ingredientsText'] ?? ''}',
      steps: steps is List
          ? [for (final s in steps) '$s'.trim()].where((s) => s.isNotEmpty).toList()
          : const [],
      notes: '${map['notes'] ?? ''}',
      pinned: map['pinned'] == true,
      createdAt: '${map['createdAt'] ?? ''}',
    );
  }
}
