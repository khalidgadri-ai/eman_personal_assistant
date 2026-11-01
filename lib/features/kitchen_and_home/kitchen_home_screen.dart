import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../settings/settings_button.dart';
import 'kitchen_store.dart';
import 'laundry_tab.dart';
import 'pantry_tab.dart';
import 'recipes_tab.dart';
import 'shopping_tab.dart';

/// المطبخ والمنزل: الوصفات، والمؤونة والمستلزمات المنزلية، وقائمة المشتريات، وجدول الغسيل.
/// كل بياناتها في [KitchenStore] الذي تقرؤه التبويبات الأربعة، فنقل صنف من المؤونة إلى
/// المشتريات يظهر فورًا في التبويبين.
class KitchenHomeScreen extends StatefulWidget {
  const KitchenHomeScreen({super.key});

  @override
  State<KitchenHomeScreen> createState() => _KitchenHomeScreenState();
}

class _KitchenHomeScreenState extends State<KitchenHomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  KitchenStore? _store;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this)..addListener(_onTabChanged);
    _open();
  }

  @override
  void dispose() {
    _tabController
      ..removeListener(_onTabChanged)
      ..dispose();
    _store?.dispose();
    super.dispose();
  }

  Future<void> _open() async {
    final store = await KitchenStore.open();
    if (!mounted) {
      store.dispose();
      return;
    }
    setState(() => _store = store);
  }

  void _onTabChanged() {
    // الزر العائم يتغير بحسب التبويب.
    if (!_tabController.indexIsChanging && mounted) setState(() {});
  }

  Widget? _buildFab() {
    final store = _store;
    if (store == null) return null;
    final (String tooltip, Future<void> Function() onPressed) = switch (_tabController.index) {
      0 => ('إضافة وصفة', () => startAddRecipe(context, store)),
      1 => ('إضافة صنف', () => startAddPantryItem(context, store)),
      2 => ('إضافة بند للمشتريات', () => startAddShoppingItem(context, store)),
      _ => ('إضافة موعد غسيل', () => startAddLaundry(context, store)),
    };
    return FloatingActionButton(
      heroTag: 'add_kitchen_fab',
      tooltip: tooltip,
      backgroundColor: AppTheme.primaryColor,
      onPressed: onPressed,
      child: const Icon(Icons.add, color: Colors.white),
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = _store;
    return Scaffold(
      appBar: AppBar(
        title: const Text('🥗 المطبخ والمؤونة والغسيل'),
        actions: const [SettingsButton()],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          indicatorColor: AppTheme.accentColor,
          labelColor: AppTheme.accentColor,
          unselectedLabelColor: AppTheme.subTextColor,
          tabs: const [
            Tab(text: 'الوصفات والوجبات'),
            Tab(text: 'المؤونة والمستلزمات'),
            Tab(text: 'المشتريات'),
            Tab(text: 'جدول الغسيل'),
          ],
        ),
      ),
      floatingActionButton: _buildFab(),
      body: store == null
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                RecipesTab(store: store),
                PantryTab(store: store),
                ShoppingTab(store: store),
                LaundryTab(store: store),
              ],
            ),
    );
  }
}
