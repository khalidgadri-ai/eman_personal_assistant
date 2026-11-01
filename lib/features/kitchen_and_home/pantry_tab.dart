import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/arabic_text.dart';
import '../../core/widgets/entry_dialog.dart';
import '../../core/widgets/undo_snackbar.dart';
import 'kitchen_constants.dart';
import 'kitchen_store.dart';
import 'models/pantry_item.dart';

/// إضافة صنف جديد للمؤونة أو المستلزمات (زر + في الشاشة).
Future<void> startAddPantryItem(BuildContext context, KitchenStore store) async {
  final values = await showEntryDialog(
    context,
    title: 'إضافة صنف للمؤونة',
    fields: const [
      EntryField(key: 'name', label: 'الصنف', required: true),
      EntryField(key: 'qty', label: 'الكمية (اختياري)', hint: 'مثال: 2 لتر'),
      EntryField(key: 'category', label: 'التصنيف', options: pantryCategories),
    ],
  );
  if (values == null) return;
  await store.addPantryItem(name: values['name']!, qty: values['qty']!, category: values['category']!);
}

/// "المؤونة والمستلزمات": أقسام قابلة للطي، بحث، تصفية بالقسم، تعديل، تثبيت، زيادة ونقصان
/// الكمية، "نفد" (ينقل الصنف إلى المشتريات)، وحذف مع تراجع.
class PantryTab extends StatefulWidget {
  const PantryTab({super.key, required this.store});

  final KitchenStore store;

  @override
  State<PantryTab> createState() => _PantryTabState();
}

class _PantryTabState extends State<PantryTab> {
  static const String _pinnedKey = '__pinned__';

  final TextEditingController _search = TextEditingController();
  String _query = '';
  String? _filter;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  KitchenStore get _store => widget.store;

  Future<void> _edit(PantryItem item) async {
    final categories = pantryCategories.contains(item.category)
        ? pantryCategories
        : [...pantryCategories, item.category];
    final values = await showEntryDialog(
      context,
      title: 'تعديل الصنف',
      confirmLabel: 'حفظ',
      fields: [
        EntryField(key: 'name', label: 'الصنف', required: true, initial: item.name),
        EntryField(key: 'qty', label: 'الكمية (اختياري)', hint: 'مثال: 2 لتر', initial: item.qty),
        EntryField(key: 'category', label: 'التصنيف', options: categories, initial: item.category),
      ],
    );
    if (values == null) return;
    await _store.updatePantryItem(
      item.copyWith(name: values['name'], qty: values['qty'], category: values['category']),
    );
  }

  Future<void> _delete(PantryItem item) async {
    final removed = await _store.removePantryItem(item.id);
    if (removed == null || !mounted) return;
    showUndoSnackBar(context, 'حُذف «${item.name}»', () => _store.restorePantryItem(removed));
  }

  Future<void> _outOfStock(PantryItem item) async {
    final moved = await _store.markOutOfStock(item.id);
    if (moved == null || !mounted) return;
    showUndoSnackBar(context, 'نُقل «${item.name}» إلى المشتريات', () => _store.undoOutOfStock(moved));
  }

  Future<void> _onMenu(String action, PantryItem item) async {
    switch (action) {
      case 'edit':
        await _edit(item);
      case 'pin':
        await _store.togglePantryPin(item.id);
      case 'out':
        await _outOfStock(item);
      case 'delete':
        await _delete(item);
    }
  }

  bool _matches(PantryItem item) {
    final q = normalizeArabicName(_query);
    if (q.isNotEmpty && !normalizeArabicName('${item.name} ${item.category}').contains(q)) return false;
    return true;
  }

  /// الأقسام الموجودة فعلًا، بترتيب العرض المعروف ثم أي قسم قديم غير معروف.
  List<String> _presentCategories(List<PantryItem> all) {
    final present = all.map((p) => p.category).toSet();
    return [
      ...pantryCategories.where(present.contains),
      ...present.where((c) => !pantryCategories.contains(c)),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _store,
      builder: (context, _) {
        final all = _store.pantry;
        final categories = _presentCategories(all);
        // قسم تُصفّى عليه ثم حُذفت كل أصنافه: نعود إلى "الكل".
        final filter = _filter != null && categories.contains(_filter) ? _filter : null;
        final visible = all.where(_matches).toList();
        final pinned = visible.where((p) => p.pinned).toList();

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          children: [
            const KitchenSectionTitle('مخزون المطبخ واحتياجات المنزل'),
            const SizedBox(height: 12),
            if (all.isEmpty)
              const KitchenEmptyNote('المؤونة فارغة. اضغط + لإضافة أول صنف.')
            else ...[
              TextField(
                controller: _search,
                style: const TextStyle(color: AppTheme.textColor),
                decoration: InputDecoration(
                  hintText: 'بحث في المؤونة والمستلزمات',
                  hintStyle: const TextStyle(color: AppTheme.subTextColor),
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'مسح البحث',
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () {
                            _search.clear();
                            setState(() => _query = '');
                          },
                        ),
                ),
                onChanged: (v) => setState(() => _query = v),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  ChoiceChip(
                    label: const Text('الكل'),
                    selected: filter == null,
                    onSelected: (_) => setState(() => _filter = null),
                  ),
                  for (final c in categories)
                    ChoiceChip(
                      label: Text(c),
                      selected: filter == c,
                      onSelected: (_) => setState(() => _filter = c),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              if (visible.isEmpty)
                const KitchenEmptyNote('لا نتائج مطابقة للبحث.')
              else ...[
                if (pinned.isNotEmpty && (filter == null || pinned.any((p) => p.category == filter)))
                  _section(
                    key: _pinnedKey,
                    title: '📌 المثبّتة',
                    items: pinned.where((p) => filter == null || p.category == filter).toList(),
                    showCategory: true,
                  ),
                for (final c in categories)
                  if (filter == null || filter == c)
                    if (visible.any((p) => p.category == c && !p.pinned))
                      _section(
                        key: c,
                        title: c,
                        items: visible.where((p) => p.category == c && !p.pinned).toList(),
                      ),
              ],
            ],
          ],
        );
      },
    );
  }

  Widget _section({
    required String key,
    required String title,
    required List<PantryItem> items,
    bool showCategory = false,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ExpansionTile(
        key: PageStorageKey<String>('pantry_$key'),
        initiallyExpanded: true,
        shape: const Border(),
        collapsedShape: const Border(),
        leading: Icon(
          key == _pinnedKey ? Icons.push_pin_rounded : pantryCategoryIcon(key),
          color: AppTheme.accentColor,
        ),
        title: Text(
          '$title (${items.length})',
          style: const TextStyle(color: AppTheme.textColor, fontWeight: FontWeight.bold),
        ),
        children: [for (final item in items) _row(item, showCategory: showCategory)],
      ),
    );
  }

  Widget _row(PantryItem item, {required bool showCategory}) {
    return Padding(
      key: ValueKey('pantry_row_${item.id}'),
      padding: const EdgeInsetsDirectional.only(start: 16, end: 4, top: 2, bottom: 2),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(color: AppTheme.textColor, fontWeight: FontWeight.bold),
                ),
                if (showCategory)
                  Text(item.category, style: const TextStyle(color: AppTheme.subTextColor, fontSize: 12)),
              ],
            ),
          ),
          if (item.canAdjust) ...[
            IconButton(
              tooltip: 'نقصان الكمية',
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.remove_circle_outline_rounded, color: AppTheme.subTextColor),
              onPressed: () => _store.adjustPantryQty(item.id, -1),
            ),
            SizedBox(
              width: 56,
              child: Text(
                item.qty.isEmpty ? '—' : item.qty,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppTheme.accentColor, fontWeight: FontWeight.bold),
              ),
            ),
            IconButton(
              tooltip: 'زيادة الكمية',
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.add_circle_outline_rounded, color: AppTheme.subTextColor),
              onPressed: () => _store.adjustPantryQty(item.id, 1),
            ),
          ] else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(item.qty, style: const TextStyle(color: AppTheme.accentColor, fontWeight: FontWeight.bold)),
            ),
          PopupMenuButton<String>(
            tooltip: 'المزيد',
            color: AppTheme.cardColor,
            icon: const Icon(Icons.more_vert_rounded, color: AppTheme.subTextColor),
            onSelected: (action) => _onMenu(action, item),
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'edit', child: Text('تعديل')),
              PopupMenuItem(value: 'pin', child: Text(item.pinned ? 'إلغاء التثبيت' : 'تثبيت')),
              const PopupMenuItem(value: 'out', child: Text('نفد: إلى المشتريات')),
              const PopupMenuItem(value: 'delete', child: Text('حذف')),
            ],
          ),
        ],
      ),
    );
  }
}
