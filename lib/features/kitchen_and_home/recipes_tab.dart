import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/ai_provider_screen.dart';
import '../../core/widgets/undo_snackbar.dart';
import 'kitchen_constants.dart';
import 'kitchen_store.dart';
import 'models/recipe.dart';
import 'recipe_details_screen.dart';
import 'recipe_edit_screen.dart';

Future<void> startAddRecipe(BuildContext context, KitchenStore store) async {
  await Navigator.of(context).push<bool>(
    MaterialPageRoute(builder: (_) => RecipeEditScreen(store: store)),
  );
}

/// عنوان وصفة من رد الذكاء الاصطناعي: سطر "اسم الوجبة: ..." إن وُجد، وإلا [fallback].
String recipeTitleFromAiText(String text, String fallback) {
  for (final line in text.split('\n')) {
    final match = RegExp(r'^[\s#*\-•]*(?:اسم\s+الوجبة|اسم\s+الوصفة|الاسم)\s*[:：]\s*(.+)$').firstMatch(line);
    if (match == null) continue;
    final title = match.group(1)!.replaceAll(RegExp(r'[*#_`]'), '').trim();
    if (title.isNotEmpty && title.length <= 80) return title;
  }
  return fallback;
}

/// "الوصفات والوجبات": توليد وصفة بالذكاء الاصطناعي، وقائمة الوصفات المحفوظة (المثبّتة أولًا)
/// ويفتح كل منها صفحة تفاصيل.
class RecipesTab extends StatefulWidget {
  const RecipesTab({super.key, required this.store});

  final KitchenStore store;

  @override
  State<RecipesTab> createState() => _RecipesTabState();
}

class _RecipesTabState extends State<RecipesTab> {
  final TextEditingController _ingredientsController = TextEditingController();
  bool _isGenerating = false;

  @override
  void dispose() {
    _ingredientsController.dispose();
    super.dispose();
  }

  KitchenStore get _store => widget.store;

  Future<void> _generateWithAI() async {
    final ingredientsText = _ingredientsController.text.trim();
    final ingredients = ingredientsText
        .split(RegExp(r'[,،\n]+'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    if (ingredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ يرجى كتابة المكونات أولاً'), backgroundColor: Colors.orange),
      );
      return;
    }

    final ai = await requireAiService(context);
    if (ai == null || !mounted) return;

    setState(() => _isGenerating = true);
    final result = await ai.suggestRecipes(ingredients);
    if (!mounted) return;
    setState(() => _isGenerating = false);

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: AppTheme.cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.restaurant_menu_rounded, color: AppTheme.accentColor),
              SizedBox(width: 8),
              Text('وصفة مقترحة 🍽️', style: TextStyle(color: AppTheme.textColor)),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Text(result, style: const TextStyle(color: AppTheme.subTextColor, fontSize: 14, height: 1.6)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('إغلاق', style: TextStyle(color: AppTheme.subTextColor)),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
              icon: const Icon(Icons.add_circle_outline, color: Colors.white, size: 18),
              label: const Text('حفظ في الوصفات', style: TextStyle(color: Colors.white)),
              onPressed: () async {
                // نص الوصفة المولَّدة كاملًا يُحفظ في الملاحظات، فلا يضيع عند إغلاق النافذة.
                await _store.addRecipe(Recipe(
                  id: '',
                  title: recipeTitleFromAiText(result, 'وصفة ذكية: ${ingredients.first}'),
                  category: aiRecipeCategory,
                  ingredients: [for (final name in ingredients) RecipeIngredient(name: name)],
                  notes: result,
                ));
                if (!dialogContext.mounted) return;
                _ingredientsController.clear();
                Navigator.pop(dialogContext);
                if (mounted) showInfoSnackBar(context, '✅ تمت إضافة الوصفة');
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _delete(Recipe recipe) async {
    final removed = await _store.removeRecipe(recipe.id);
    if (removed == null || !mounted) return;
    showUndoSnackBar(context, 'حُذفت «${recipe.title}»', () => _store.restoreRecipe(removed));
  }

  void _open(Recipe recipe) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => RecipeDetailsScreen(store: _store, recipeId: recipe.id)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _store,
      builder: (context, _) {
        final recipes = _store.recipes;
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          children: [
            _aiCard(),
            const KitchenSectionTitle('موسوعة الوصفات وتفاصيل المقادير'),
            const SizedBox(height: 12),
            if (recipes.isEmpty)
              const KitchenEmptyNote('لا توجد وصفات بعد. اضغط + لإضافة وصفة، أو دع الذكاء الاصطناعي يقترح لك.'),
            for (final recipe in recipes) _card(recipe),
          ],
        );
      },
    );
  }

  Widget _card(Recipe recipe) {
    final details = [
      '${recipe.servings} حصة',
      if (recipe.ingredients.isNotEmpty) '${recipe.ingredients.length} مكوّن',
      if (recipe.steps.isNotEmpty) '${recipe.steps.length} خطوة',
    ].join(' · ');
    return Card(
      key: ValueKey('recipe_${recipe.id}'),
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _open(recipe),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (recipe.pinned)
                    const Padding(
                      padding: EdgeInsetsDirectional.only(end: 6),
                      child: Icon(Icons.push_pin_rounded, size: 16, color: AppTheme.accentColor),
                    ),
                  Expanded(
                    child: Text(
                      recipe.title,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textColor),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Chip(
                    label: Text(recipe.category, style: const TextStyle(color: Colors.white, fontSize: 11)),
                    backgroundColor: recipe.category == aiRecipeCategory ? Colors.purple : AppTheme.primaryColor,
                    padding: EdgeInsets.zero,
                  ),
                  IconButton(
                    tooltip: recipe.pinned ? 'إلغاء تثبيت الوصفة' : 'تثبيت الوصفة',
                    icon: Icon(
                      recipe.pinned ? Icons.push_pin_rounded : Icons.push_pin_outlined,
                      color: AppTheme.subTextColor,
                    ),
                    onPressed: () => _store.toggleRecipePin(recipe.id),
                  ),
                  IconButton(
                    tooltip: 'حذف الوصفة',
                    icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.subTextColor),
                    onPressed: () => _delete(recipe),
                  ),
                ],
              ),
              Text(details, style: const TextStyle(color: AppTheme.subTextColor, fontSize: 12)),
              if (recipe.ingredients.isEmpty && recipe.ingredientsText.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  'المقادير: ${recipe.ingredientsText}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppTheme.subTextColor, fontSize: 13),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _aiCard() {
    return Card(
      color: AppTheme.surfaceColor,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.smart_toy_rounded, color: AppTheme.accentColor),
                SizedBox(width: 8),
                Text(
                  '🧑‍🍳 توليد وصفة بالذكاء الاصطناعي',
                  style: TextStyle(color: AppTheme.textColor, fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              'اكتب المكونات المتاحة في مطبخك (مفصولة بفواصل):',
              style: TextStyle(color: AppTheme.subTextColor, fontSize: 13),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _ingredientsController,
              maxLines: 2,
              maxLength: 400,
              style: const TextStyle(color: AppTheme.textColor),
              decoration: InputDecoration(
                hintText: 'مثال: دجاج، أرز، طماطم، بصل، بهارات...',
                hintStyle: const TextStyle(color: AppTheme.subTextColor, fontSize: 13),
                filled: true,
                fillColor: AppTheme.cardColor,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: _isGenerating
                  ? const Column(
                      children: [
                        CircularProgressIndicator(color: AppTheme.accentColor),
                        SizedBox(height: 8),
                        Text('جارٍ توليد الوصفة...', style: TextStyle(color: AppTheme.subTextColor, fontSize: 12)),
                      ],
                    )
                  : ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: _generateWithAI,
                      icon: const Icon(Icons.auto_awesome, color: Colors.white),
                      label: const Text('اقترح وصفة الآن ✨', style: TextStyle(color: Colors.white)),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
