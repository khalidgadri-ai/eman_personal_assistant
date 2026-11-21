import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../settings/settings_button.dart';
import 'kitchen_store.dart';
import 'laundry_tab.dart';
import 'pantry_tab.dart';
import 'recipes_tab.dart';
import 'shopping_tab.dart';
import '../../l10n/l10n.dart';

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
      0 => (context.l10n.addRecipe, () => startAddRecipe(context, store)),
      1 => (context.l10n.addPantryItem, () => startAddPantryItem(context, store)),
      2 => (context.l10n.addShoppingItem, () => startAddShoppingItem(context, store)),
      _ => (context.l10n.addLaundry, () => startAddLaundry(context, store)),
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
        title: Text(context.l10n.kitchenTitle),
        actions: const [SettingsButton()],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          indicatorColor: AppTheme.accentColor,
          labelColor: AppTheme.accentColor,
          unselectedLabelColor: AppTheme.subTextColor,
          tabs: [
            Tab(text: context.l10n.tabRecipes),
            Tab(text: context.l10n.tabPantry),
            Tab(text: context.l10n.tabShopping),
            Tab(text: context.l10n.tabLaundry),
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
