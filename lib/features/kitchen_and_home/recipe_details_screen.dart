import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/undo_snackbar.dart';
import 'kitchen_constants.dart';
import 'kitchen_store.dart';
import 'models/recipe.dart';
import 'recipe_edit_screen.dart';
import '../../l10n/l10n.dart';

/// تفاصيل وصفة محفوظة: المقادير والخطوات، تغيير عدد الحصص مع إعادة حساب المقادير (للعرض فقط،
/// لا يُغيّر الوصفة المحفوظة)، تثبيت، تعديل، حذف، وإضافة المقادير إلى قائمة المشتريات.
class RecipeDetailsScreen extends StatefulWidget {
  const RecipeDetailsScreen({super.key, required this.store, required this.recipeId});

  final KitchenStore store;
  final String recipeId;

  @override
  State<RecipeDetailsScreen> createState() => _RecipeDetailsScreenState();
}

class _RecipeDetailsScreenState extends State<RecipeDetailsScreen> {
  int? _servings;

  Future<void> _edit(Recipe recipe) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => RecipeEditScreen(store: widget.store, recipe: recipe)),
    );
    // بعد التعديل يعود العرض إلى حصص الوصفة المحفوظة.
    if (saved == true && mounted) setState(() => _servings = null);
  }

  Future<void> _confirmDelete(Recipe recipe) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        title: Text(context.l10n.recipeDeleteAsk, style: TextStyle(color: AppTheme.textColor)),
        content: Text(context.l10n.recipeDeleteBody(recipe.title), style: const TextStyle(color: AppTheme.subTextColor)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(context.l10n.cancel, style: TextStyle(color: AppTheme.subTextColor)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(context.l10n.deleteAction, style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final removed = await widget.store.removeRecipe(recipe.id);
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop();
    if (removed != null) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text(context.l10n.recipeDeleted(recipe.title)),
          action: SnackBarAction(label: context.l10n.undo, onPressed: () => widget.store.restoreRecipe(removed)),
        ));
    }
  }

  Future<void> _addToShopping(Recipe scaled) async {
    final picked = await showModalBottomSheet<List<int>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.cardColor,
      builder: (_) => _ShoppingPicker(recipe: scaled, store: widget.store),
    );
    if (picked == null || picked.isEmpty || !mounted) return;
    final result = await widget.store.addRecipeToShopping(scaled, picked);
    if (!mounted) return;
    final parts = <String>[
      if (result.added > 0) context.l10n.addedToShopping(result.added),
      if (result.merged > 0) context.l10n.alreadyInList(result.merged),
    ];
    showInfoSnackBar(context, parts.join(' · '));
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.store,
      builder: (context, _) {
        final recipe = widget.store.recipeById(widget.recipeId);
        if (recipe == null) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final servings = _servings ?? recipe.servings;
        final scaled = recipe.scaledTo(servings);
        return Scaffold(
          appBar: AppBar(
            title: Text(recipe.title),
            actions: [
              IconButton(
                tooltip: recipe.pinned ? context.l10n.recipeUnpin : context.l10n.recipePin,
                icon: Icon(recipe.pinned ? Icons.push_pin_rounded : Icons.push_pin_outlined, color: AppTheme.accentColor),
                onPressed: () => widget.store.toggleRecipePin(recipe.id),
              ),
              IconButton(
                tooltip: context.l10n.recipeEdit,
                icon: const Icon(Icons.edit_rounded, color: AppTheme.accentColor),
                onPressed: () => _edit(recipe),
              ),
              IconButton(
                tooltip: context.l10n.recipeDelete,
                icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.subTextColor),
                onPressed: () => _confirmDelete(recipe),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Chip(
                  label: Text(recipeCategoryLabel(context.l10n, recipe.category), style: const TextStyle(color: Colors.white, fontSize: 12)),
                  backgroundColor: recipe.category == aiRecipeCategory ? Colors.purple : AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              _servingsBar(recipe, servings),
              const SizedBox(height: 16),
              KitchenSectionTitle(context.l10n.ingredientsHeader),
              const SizedBox(height: 8),
              if (scaled.ingredients.isNotEmpty)
                for (final i in scaled.ingredients)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        const Text('• ', style: TextStyle(color: AppTheme.accentColor)),
                        Expanded(child: Text(i.name, style: const TextStyle(color: AppTheme.textColor))),
                        Text(i.quantityText, style: const TextStyle(color: AppTheme.accentColor, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  )
              else if (recipe.ingredientsText.isNotEmpty)
                Text(context.l10n.ingredientsLine(recipe.ingredientsText), style: const TextStyle(color: AppTheme.subTextColor))
              else
                Text(context.l10n.noIngredients, style: TextStyle(color: AppTheme.subTextColor)),
              if (scaled.ingredients.isNotEmpty) ...[
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () => _addToShopping(scaled),
                  icon: const Icon(Icons.add_shopping_cart_rounded, size: 18),
                  label: Text(context.l10n.addIngredientsToShopping),
                ),
              ],
              if (recipe.steps.isNotEmpty) ...[
                const SizedBox(height: 20),
                KitchenSectionTitle(context.l10n.prepSteps),
                const SizedBox(height: 8),
                for (var n = 0; n < recipe.steps.length; n++)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${n + 1}. ', style: const TextStyle(color: AppTheme.accentColor, fontWeight: FontWeight.bold)),
                        Expanded(child: Text(recipe.steps[n], style: const TextStyle(color: AppTheme.textColor, height: 1.6))),
                      ],
                    ),
                  ),
              ],
              if (recipe.notes.isNotEmpty) ...[
                const SizedBox(height: 20),
                KitchenSectionTitle(context.l10n.notesHeader),
                const SizedBox(height: 8),
                // نص عادي فقط: ما يولّده الذكاء الاصطناعي لا يُفسَّر Markdown ولا روابط.
                SelectableText(recipe.notes, style: const TextStyle(color: AppTheme.subTextColor, height: 1.7)),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _servingsBar(Recipe recipe, int servings) {
    final changed = servings != recipe.servings;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(color: AppTheme.cardColor, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          const Icon(Icons.people_alt_rounded, color: AppTheme.accentColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              changed ? context.l10n.servingsScaled(servings, recipe.servings) : context.l10n.servingsCount(servings),
              style: const TextStyle(color: AppTheme.textColor, fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(
            tooltip: context.l10n.servingsLess,
            icon: const Icon(Icons.remove_circle_outline_rounded),
            onPressed: servings > 1 ? () => setState(() => _servings = servings - 1) : null,
          ),
          IconButton(
            tooltip: context.l10n.servingsMore,
            icon: const Icon(Icons.add_circle_outline_rounded),
            onPressed: servings < Recipe.maxServings ? () => setState(() => _servings = servings + 1) : null,
          ),
        ],
      ),
    );
  }
}

/// اختيار المقادير التي تُضاف للمشتريات. ما هو موجود في المؤونة يأتي غير محدد وعليه علامة.
class _ShoppingPicker extends StatefulWidget {
  const _ShoppingPicker({required this.recipe, required this.store});

  final Recipe recipe;
  final KitchenStore store;

  @override
  State<_ShoppingPicker> createState() => _ShoppingPickerState();
}

class _ShoppingPickerState extends State<_ShoppingPicker> {
  late final Set<int> _chosen = {
    for (var i = 0; i < widget.recipe.ingredients.length; i++)
      if (!widget.store.pantryHas(widget.recipe.ingredients[i].name)) i,
  };

  @override
  Widget build(BuildContext context) {
    final ingredients = widget.recipe.ingredients;
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.75),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                context.l10n.whatToShopping,
                style: TextStyle(color: AppTheme.textColor, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (var i = 0; i < ingredients.length; i++)
                    CheckboxListTile(
                      value: _chosen.contains(i),
                      activeColor: AppTheme.primaryColor,
                      onChanged: (v) => setState(() => v == true ? _chosen.add(i) : _chosen.remove(i)),
                      title: Text(
                        [ingredients[i].name, ingredients[i].quantityText].where((s) => s.isNotEmpty).join(' — '),
                        style: const TextStyle(color: AppTheme.textColor),
                      ),
                      subtitle: widget.store.pantryHas(ingredients[i].name)
                          ? Text(context.l10n.inPantry, style: TextStyle(color: Colors.green, fontSize: 12))
                          : null,
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
                  onPressed: _chosen.isEmpty ? null : () => Navigator.of(context).pop(_chosen.toList()..sort()),
                  child: Text(context.l10n.addCount(_chosen.length), style: const TextStyle(color: Colors.white)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
