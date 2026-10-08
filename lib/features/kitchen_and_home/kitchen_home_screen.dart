import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/ai_key_setup_screen.dart';

class KitchenHomeScreen extends StatefulWidget {
  const KitchenHomeScreen({super.key});

  @override
  State<KitchenHomeScreen> createState() => _KitchenHomeScreenState();
}

class _KitchenHomeScreenState extends State<KitchenHomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _ingredientsController = TextEditingController();
  bool _isGeneratingRecipe = false;

  final List<Map<String, dynamic>> _recipes = [
    {
      'title': 'سالمون مشوي بالأعشاب والليمون',
      'category': 'غداء',
      'ingredients': 'سالمون 300غ، زيت زيتون 15مل، ثوم، ليمون، زبدة 20غ',
    },
    {
      'title': 'شوفان بالمكسرات والعسل والفاكهة',
      'category': 'فطور',
      'ingredients': 'شوفان 50غ، حليب 200مل، عسل 10غ، جوز ولوز 20غ',
    },
  ];

  final List<Map<String, dynamic>> _pantryItems = [
    {'name': 'زيت زيتون بكر ممتاز', 'qty': '2 لتر', 'category': 'الزيوت والبهارات'},
    {'name': 'مكسرات مشكلة (جوز ولوز)', 'qty': '500 جرام', 'category': 'المكسرات'},
    {'name': 'منظف ومطهر الصحون', 'qty': '1 عبوة', 'category': 'مستلزمات التنظيف'},
  ];

  final List<Map<String, String>> _laundrySchedule = [
    {'day': 'الأحد', 'type': 'الملابس البيضاء والقطنيات', 'care': 'غسيل دافئ + مطهر + مسحوق عناية'},
    {'day': 'الثلاثاء', 'type': 'الأقمشة الملونة والحساسة', 'care': 'غسيل بارد + ملين أقمشة'},
    {'day': 'الخميس', 'type': 'البياضات والمناشف', 'care': 'درجة حرارة عالية + تجفيف حراري'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _ingredientsController.dispose();
    super.dispose();
  }

  /// ✅ يولّد وصفة طعام بالذكاء الاصطناعي بناءً على المكونات المتاحة
  Future<void> _generateRecipeWithAI() async {
    final ingredientsText = _ingredientsController.text.trim();
    if (ingredientsText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ يرجى كتابة المكونات أولاً'), backgroundColor: Colors.orange),
      );
      return;
    }

    final gemini = await requireGeminiService(context);
    if (gemini == null || !mounted) return;

    setState(() => _isGeneratingRecipe = true);

    final ingredients = ingredientsText
        .split(RegExp(r'[,،\n]+'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final result = await gemini.suggestRecipes(ingredients);

    setState(() => _isGeneratingRecipe = false);

    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
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
              onPressed: () => Navigator.pop(context),
              child: const Text('إغلاق', style: TextStyle(color: AppTheme.subTextColor)),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
              icon: const Icon(Icons.add_circle_outline, color: Colors.white, size: 18),
              label: const Text('حفظ في الوصفات', style: TextStyle(color: Colors.white)),
              onPressed: () {
                // إضافة الوصفة المولدة لقائمة الوصفات
                setState(() {
                  _recipes.insert(0, {
                    'title': 'وصفة ذكية: ${ingredients.first}',
                    'category': 'ذكاء اصطناعي',
                    'ingredients': ingredientsText,
                  });
                  _ingredientsController.clear();
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('✅ تمت إضافة الوصفة'), backgroundColor: Colors.green),
                );
              },
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🥗 المطبخ والمؤونة والغسيل'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.accentColor,
          labelColor: AppTheme.accentColor,
          unselectedLabelColor: AppTheme.subTextColor,
          tabs: const [
            Tab(text: 'الوصفات والوجبات'),
            Tab(text: 'المؤونة والمستلزمات'),
            Tab(text: 'جدول الغسيل'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRecipesTab(),
          _buildPantryTab(),
          _buildLaundryTab(),
        ],
      ),
    );
  }

  Widget _buildRecipesTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ✅ بطاقة توليد الوصفة بالذكاء الاصطناعي
        Card(
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
                    Text('🧑‍🍳 توليد وصفة بالذكاء الاصطناعي', style: TextStyle(color: AppTheme.textColor, fontWeight: FontWeight.bold, fontSize: 15)),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  'اكتبي المكونات المتاحة لديكِ في المطبخ (مفصولة بفواصل):',
                  style: TextStyle(color: AppTheme.subTextColor, fontSize: 13),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _ingredientsController,
                  maxLines: 2,
                  style: const TextStyle(color: AppTheme.textColor),
                  decoration: InputDecoration(
                    hintText: 'مثال: دجاج، أرز، طماطم، بصل، بهارات...',
                    hintStyle: const TextStyle(color: AppTheme.subTextColor, fontSize: 13),
                    filled: true,
                    fillColor: AppTheme.cardColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: _isGeneratingRecipe
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
                          onPressed: _generateRecipeWithAI,
                          icon: const Icon(Icons.auto_awesome, color: Colors.white),
                          label: const Text('اقترح وصفة الآن ✨', style: TextStyle(color: Colors.white)),
                        ),
                ),
              ],
            ),
          ),
        ),
        const Text('موسوعة الوصفات وتفاصيل المقادير', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textColor)),
        const SizedBox(height: 12),
        ..._recipes.map((item) => Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item['title'],
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textColor),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Chip(
                      label: Text(item['category'], style: const TextStyle(color: Colors.white, fontSize: 11)),
                      backgroundColor: item['category'] == 'ذكاء اصطناعي' ? Colors.purple : AppTheme.primaryColor,
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text('المقادير: ${item['ingredients']}', style: const TextStyle(color: AppTheme.subTextColor, fontSize: 13)),
              ],
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildPantryTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('مخزون المطبخ واحتياجات المنزل', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textColor)),
        const SizedBox(height: 12),
        ..._pantryItems.map((item) => Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            leading: const Icon(Icons.shopping_basket_rounded, color: AppTheme.accentColor),
            title: Text(item['name'], style: const TextStyle(color: AppTheme.textColor, fontWeight: FontWeight.bold)),
            subtitle: Text('التصنيف: ${item['category']}', style: const TextStyle(color: AppTheme.subTextColor)),
            trailing: Text(item['qty'], style: const TextStyle(color: AppTheme.accentColor, fontWeight: FontWeight.bold)),
          ),
        )),
      ],
    );
  }

  Widget _buildLaundryTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('جدول العناية بالأقمشة والغسيل الأسبوعي', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textColor)),
        const SizedBox(height: 12),
        ..._laundrySchedule.map((item) => Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            leading: const Icon(Icons.local_laundry_service_rounded, color: AppTheme.accentColor),
            title: Text('${item['day']}: ${item['type']}', style: const TextStyle(color: AppTheme.textColor, fontWeight: FontWeight.bold)),
            subtitle: Text('التعليمات: ${item['care']}', style: const TextStyle(color: AppTheme.subTextColor)),
          ),
        )),
      ],
    );
  }
}
