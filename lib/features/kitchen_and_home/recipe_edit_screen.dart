import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/quantity.dart';
import 'kitchen_constants.dart';
import 'kitchen_store.dart';
import 'models/recipe.dart';

class _IngredientRow {
  _IngredientRow({String name = '', String amount = '', String unit = ''})
      : name = TextEditingController(text: name),
        amount = TextEditingController(text: amount),
        unit = TextEditingController(text: unit);

  final TextEditingController name;
  final TextEditingController amount;
  final TextEditingController unit;
  String? nameError;
  String? amountError;

  void dispose() {
    name.dispose();
    amount.dispose();
    unit.dispose();
  }
}

/// إضافة وصفة أو تعديلها: الاسم والنوع والحصص ومقادير منظّمة (اسم، كمية، وحدة) وخطوات وملاحظات.
/// تحفظ في المخزن وترجّع true.
class RecipeEditScreen extends StatefulWidget {
  const RecipeEditScreen({super.key, required this.store, this.recipe});

  final KitchenStore store;
  final Recipe? recipe;

  @override
  State<RecipeEditScreen> createState() => _RecipeEditScreenState();
}

class _RecipeEditScreenState extends State<RecipeEditScreen> {
  static const int _maxIngredients = 60;
  static const int _maxSteps = 40;

  late final TextEditingController _title;
  late final TextEditingController _notes;
  late String _category;
  late int _servings;
  late String _legacyText;
  final List<_IngredientRow> _ingredients = [];
  final List<TextEditingController> _steps = [];
  String? _titleError;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final r = widget.recipe;
    _title = TextEditingController(text: r?.title ?? '');
    _notes = TextEditingController(text: r?.notes ?? '');
    _category = r?.category ?? recipeCategories.first;
    _servings = r?.servings ?? Recipe.defaultServings;
    _legacyText = r?.ingredientsText ?? '';
    for (final i in r?.ingredients ?? const <RecipeIngredient>[]) {
      _ingredients.add(_IngredientRow(
        name: i.name,
        amount: i.amount == null ? '' : formatQuantity(i.amount!),
        unit: i.unit,
      ));
    }
    if (_ingredients.isEmpty && _legacyText.isEmpty) _ingredients.add(_IngredientRow());
    for (final s in r?.steps ?? const <String>[]) {
      _steps.add(TextEditingController(text: s));
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _notes.dispose();
    for (final row in _ingredients) {
      row.dispose();
    }
    for (final c in _steps) {
      c.dispose();
    }
    super.dispose();
  }

  /// يحوّل نص المقادير القديم إلى صفوف (اسم لكل سطر أو فاصلة)، والكميات يضيفها المستخدم.
  void _convertLegacy() {
    final names = _legacyText
        .split(RegExp(r'[\n،,]+'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .take(_maxIngredients);
    setState(() {
      for (final name in names) {
        _ingredients.add(_IngredientRow(name: name));
      }
      _legacyText = '';
    });
  }

  Future<void> _save() async {
    final title = _title.text.trim();
    if (title.isEmpty) {
      setState(() => _titleError = 'هذا الحقل مطلوب');
      return;
    }

    final ingredients = <RecipeIngredient>[];
    var valid = true;
    for (final row in _ingredients) {
      final name = row.name.text.replaceAll(RegExp(r'\s+'), ' ').trim();
      final amountText = row.amount.text.trim();
      final unit = row.unit.text.replaceAll(RegExp(r'\s+'), ' ').trim();
      row.nameError = null;
      row.amountError = null;
      if (name.isEmpty && amountText.isEmpty && unit.isEmpty) continue;
      if (name.isEmpty) {
        row.nameError = 'اسم المكوّن مطلوب';
        valid = false;
        continue;
      }
      double? amount;
      if (amountText.isNotEmpty) {
        amount = parseQuantity(amountText);
        if (amount == null) {
          row.amountError = 'كمية غير صالحة';
          valid = false;
          continue;
        }
      }
      ingredients.add(RecipeIngredient(name: name, amount: amount, unit: unit));
    }
    if (!valid) {
      setState(() {});
      return;
    }

    final steps = _steps.map((c) => c.text.trim()).where((s) => s.isNotEmpty).toList();
    setState(() => _saving = true);
    final existing = widget.recipe;
    if (existing == null) {
      await widget.store.addRecipe(Recipe(
        id: '',
        title: title,
        category: _category,
        servings: _servings,
        ingredients: ingredients,
        steps: steps,
        notes: _notes.text.trim(),
        ingredientsText: _legacyText,
      ));
    } else {
      await widget.store.updateRecipe(existing.copyWith(
        title: title,
        category: _category,
        servings: _servings,
        ingredients: ingredients,
        steps: steps,
        notes: _notes.text.trim(),
        ingredientsText: _legacyText,
      ));
    }
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  InputDecoration _decoration(String label, {String? error, String? hint}) {
    return InputDecoration(labelText: label, hintText: hint, errorText: error, counterText: '');
  }

  @override
  Widget build(BuildContext context) {
    final categories = recipeCategories.contains(_category) ? recipeCategories : [...recipeCategories, _category];
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.recipe == null ? 'إضافة وصفة' : 'تعديل الوصفة'),
          actions: [
            TextButton(
              onPressed: _saving ? null : _save,
              child: const Text('حفظ', style: TextStyle(color: AppTheme.accentColor, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextField(
              controller: _title,
              maxLength: 80,
              style: const TextStyle(color: AppTheme.textColor),
              decoration: _decoration('اسم الوجبة', error: _titleError),
              onChanged: (_) {
                if (_titleError != null) setState(() => _titleError = null);
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _category,
              isExpanded: true,
              dropdownColor: AppTheme.cardColor,
              decoration: const InputDecoration(labelText: 'النوع'),
              items: [
                for (final c in categories)
                  DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(color: AppTheme.textColor))),
              ],
              onChanged: (v) => setState(() => _category = v ?? _category),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('عدد الحصص', style: TextStyle(color: AppTheme.textColor)),
                const Spacer(),
                IconButton(
                  tooltip: 'تقليل الحصص',
                  icon: const Icon(Icons.remove_circle_outline_rounded),
                  onPressed: _servings > 1 ? () => setState(() => _servings--) : null,
                ),
                Text('$_servings', style: const TextStyle(color: AppTheme.textColor, fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(
                  tooltip: 'زيادة الحصص',
                  icon: const Icon(Icons.add_circle_outline_rounded),
                  onPressed: _servings < Recipe.maxServings ? () => setState(() => _servings++) : null,
                ),
              ],
            ),
            const Divider(height: 32),
            const KitchenSectionTitle('المقادير'),
            if (_legacyText.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppTheme.cardColor, borderRadius: BorderRadius.circular(10)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('مقادير مكتوبة كنص حر:', style: TextStyle(color: AppTheme.subTextColor, fontSize: 12)),
                    const SizedBox(height: 4),
                    Text(_legacyText, style: const TextStyle(color: AppTheme.textColor)),
                    TextButton(
                      onPressed: _convertLegacy,
                      child: const Text('تحويل إلى مقادير منظّمة'),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 8),
            for (var i = 0; i < _ingredients.length; i++) _ingredientRow(i),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton.icon(
                onPressed: _ingredients.length >= _maxIngredients
                    ? null
                    : () => setState(() => _ingredients.add(_IngredientRow())),
                icon: const Icon(Icons.add_rounded),
                label: const Text('إضافة مكوّن'),
              ),
            ),
            const Divider(height: 32),
            const KitchenSectionTitle('خطوات التحضير'),
            const SizedBox(height: 8),
            for (var i = 0; i < _steps.length; i++) _stepRow(i),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton.icon(
                onPressed: _steps.length >= _maxSteps
                    ? null
                    : () => setState(() => _steps.add(TextEditingController())),
                icon: const Icon(Icons.add_rounded),
                label: const Text('إضافة خطوة'),
              ),
            ),
            const Divider(height: 32),
            TextField(
              controller: _notes,
              maxLength: 2000,
              maxLines: 4,
              style: const TextStyle(color: AppTheme.textColor),
              decoration: _decoration('ملاحظات (اختياري)'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _ingredientRow(int index) {
    final row = _ingredients[index];
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: TextField(
              controller: row.name,
              maxLength: 60,
              style: const TextStyle(color: AppTheme.textColor),
              decoration: _decoration('المكوّن', error: row.nameError),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: TextField(
              controller: row.amount,
              maxLength: 12,
              keyboardType: TextInputType.text,
              textDirection: TextDirection.ltr,
              style: const TextStyle(color: AppTheme.textColor),
              decoration: _decoration('الكمية', error: row.amountError, hint: '1/2'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: TextField(
              controller: row.unit,
              maxLength: 20,
              style: const TextStyle(color: AppTheme.textColor),
              decoration: _decoration('الوحدة', hint: 'كوب'),
            ),
          ),
          IconButton(
            tooltip: 'حذف المكوّن',
            icon: const Icon(Icons.close_rounded, color: AppTheme.subTextColor),
            onPressed: () => setState(() {
              _ingredients.removeAt(index).dispose();
            }),
          ),
        ],
      ),
    );
  }

  Widget _stepRow(int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 14, left: 8),
            child: Text('${index + 1}.', style: const TextStyle(color: AppTheme.accentColor, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: TextField(
              controller: _steps[index],
              maxLength: 400,
              maxLines: null,
              style: const TextStyle(color: AppTheme.textColor),
              decoration: _decoration('الخطوة ${index + 1}'),
            ),
          ),
          IconButton(
            tooltip: 'حذف الخطوة',
            icon: const Icon(Icons.close_rounded, color: AppTheme.subTextColor),
            onPressed: () => setState(() {
              _steps.removeAt(index).dispose();
            }),
          ),
        ],
      ),
    );
  }
}
