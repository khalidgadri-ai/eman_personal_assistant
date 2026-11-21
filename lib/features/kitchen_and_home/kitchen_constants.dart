import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/l10n.dart';

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

/// التصنيفات والأيام والمصدر تُحفظ بنصها العربي (معرّفات ثابتة في بيانات المستخدم)،
/// وتُعرض بلغة التطبيق عبر هذه الدوال. قيمة غير معروفة (من نسخة قديمة أو كتبها المستخدم) تظهر كما هي.
String recipeCategoryLabel(AppLocalizations l10n, String stored) => switch (stored) {
      'فطور' => l10n.recipeBreakfast,
      'غداء' => l10n.recipeLunch,
      'عشاء' => l10n.recipeDinner,
      'وجبة خفيفة' => l10n.recipeSnack,
      'حلويات' => l10n.recipeDessert,
      'أخرى' => l10n.otherCategory,
      aiRecipeCategory => l10n.recipeAi,
      _ => stored,
    };

String pantryCategoryLabel(AppLocalizations l10n, String stored) => switch (stored) {
      'الزيوت والبهارات' => l10n.pantryOils,
      'الحبوب والبقوليات' => l10n.pantryGrains,
      'الخضار والفواكه' => l10n.pantryProduce,
      'الألبان واللحوم' => l10n.pantryDairyMeat,
      'المكسرات' => l10n.pantryNuts,
      'مستلزمات التنظيف' => l10n.pantryCleaning,
      'أخرى' => l10n.otherCategory,
      _ => stored,
    };

String weekDayLabel(AppLocalizations l10n, String stored) => switch (stored) {
      'السبت' => l10n.daySat,
      'الأحد' => l10n.daySun,
      'الاثنين' => l10n.dayMon,
      'الثلاثاء' => l10n.dayTue,
      'الأربعاء' => l10n.dayWed,
      'الخميس' => l10n.dayThu,
      'الجمعة' => l10n.dayFri,
      _ => stored,
    };

/// مصدر بند المشتريات: «نفد من المؤونة» أو اسم الوصفة كما كُتب.
String shoppingSourceLabel(AppLocalizations l10n, String stored) =>
    stored == 'نفد من المؤونة' ? l10n.sourceOutOfStock : stored;

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
