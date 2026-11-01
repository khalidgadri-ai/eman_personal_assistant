import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

const List<String> recipeCategories = ['فطور', 'غداء', 'عشاء', 'وجبة خفيفة', 'حلويات', 'أخرى'];

/// تصنيف الوصفات التي يولّدها الذكاء الاصطناعي؛ لا يظهر في قائمة الاختيار اليدوية.
const String aiRecipeCategory = 'ذكاء اصطناعي';

/// أقسام المؤونة والمستلزمات المنزلية، بترتيب العرض.
const List<String> pantryCategories = [
  'الزيوت والبهارات',
  'الحبوب والبقوليات',
  'الخضار والفواكه',
  'الألبان واللحوم',
  'المكسرات',
  'مستلزمات التنظيف',
  'أخرى',
];

const List<String> weekDays = ['السبت', 'الأحد', 'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة'];

IconData pantryCategoryIcon(String category) {
  return switch (category) {
    'الزيوت والبهارات' => Icons.opacity_rounded,
    'الحبوب والبقوليات' => Icons.grain_rounded,
    'الخضار والفواكه' => Icons.eco_rounded,
    'الألبان واللحوم' => Icons.egg_alt_rounded,
    'المكسرات' => Icons.spa_rounded,
    'مستلزمات التنظيف' => Icons.cleaning_services_rounded,
    _ => Icons.shopping_basket_rounded,
  };
}

/// ملاحظة وسط القائمة حين لا يوجد شيء.
class KitchenEmptyNote extends StatelessWidget {
  const KitchenEmptyNote(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(text, style: const TextStyle(color: AppTheme.subTextColor), textAlign: TextAlign.center),
      ),
    );
  }
}

/// عنوان قسم داخل قائمة.
class KitchenSectionTitle extends StatelessWidget {
  const KitchenSectionTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textColor),
    );
  }
}
