import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/arabic_text.dart';
import '../../core/widgets/entry_dialog.dart';
import '../../core/widgets/undo_snackbar.dart';
import 'kitchen_constants.dart';
import 'kitchen_store.dart';
import 'models/pantry_item.dart';
import '../../l10n/l10n.dart';

/// إضافة صنف جديد للمؤونة أو المستلزمات (زر + في الشاشة).
Future<void> startAddPantryItem(BuildContext context, KitchenStore store) async {
  final values = await showEntryDialog(
    context,
    title: context.l10n.pantryAddTitle,
    fields: [
      EntryField(key: 'name', label: context.l10n.itemField, required: true),
      EntryField(key: 'qty', label: context.l10n.qtyOptionalField, hint: context.l10n.pantryQtyHint),
      EntryField(
        key: 'category',
        label: context.l10n.categoryField,
        options: pantryCategories,
        // صنف جديد يبدأ بـ«أخرى» لا بأول قسم (كان يقترح «الزيوت والبهارات» لكل شيء).
        initial: KitchenStore.defaultPantryCategory,
        optionLabel: (c) => pantryCategoryLabel(context.l10n, c),
      ),
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
      title: context.l10n.pantryEditTitle,
      confirmLabel: context.l10n.save,
      fields: [
        EntryField(key: 'name', label: context.l10n.itemField, required: true, initial: item.name),
        EntryField(key: 'qty', label: context.l10n.qtyOptionalField, hint: context.l10n.pantryQtyHint, initial: item.qty),
        EntryField(
          key: 'category',
          label: context.l10n.categoryField,
          options: categories,
          initial: item.category,
          optionLabel: (c) => pantryCategoryLabel(context.l10n, c),
        ),
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
    showUndoSnackBar(context, context.l10n.itemDeleted(item.name), () => _store.restorePantryItem(removed));
  }

  Future<void> _outOfStock(PantryItem item) async {
    final moved = await _store.markOutOfStock(item.id);
    if (moved == null || !mounted) return;
    showUndoSnackBar(context, context.l10n.movedToShopping(item.name), () => _store.undoOutOfStock(moved));
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
        // قسم تُصفّى عليه ثم حُذفت كل أصنافه: نعود إلى «الكل».
        final filter = _filter != null && categories.contains(_filter) ? _filter : null;
        final visible = all.where(_matches).toList();
        final pinned = visible.where((p) => p.pinned).toList();

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          children: [
            KitchenSectionTitle(context.l10n.pantryHeader),
            const SizedBox(height: 12),
            if (all.isEmpty)
              KitchenEmptyNote(context.l10n.pantryEmpty)
            else ...[
              TextField(
                controller: _search,
                style: const TextStyle(color: AppTheme.textColor),
                decoration: InputDecoration(
                  hintText: context.l10n.pantrySearchHint,
                  hintStyle: const TextStyle(color: AppTheme.subTextColor),
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          tooltip: context.l10n.clearSearch,
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
                    label: Text(context.l10n.filterAll),
                    selected: filter == null,
                    onSelected: (_) => setState(() => _filter = null),
                  ),
                  for (final c in categories)
                    ChoiceChip(
                      label: Text(pantryCategoryLabel(context.l10n, c)),
                      selected: filter == c,
                      onSelected: (_) => setState(() => _filter = c),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              if (visible.isEmpty)
                KitchenEmptyNote(context.l10n.noSearchResults)
              else ...[
                if (pinned.isNotEmpty && (filter == null || pinned.any((p) => p.category == filter)))
                  _section(
                    key: _pinnedKey,
                    title: context.l10n.pinnedSection,
                    items: pinned.where((p) => filter == null || p.category == filter).toList(),
                    showCategory: true,
                  ),
                for (final c in categories)
                  if (filter == null || filter == c)
                    if (visible.any((p) => p.category == c && !p.pinned))
                      _section(
                        key: c,
                        title: pantryCategoryLabel(context.l10n, c),
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
                  Text(pantryCategoryLabel(context.l10n, item.category), style: const TextStyle(color: AppTheme.subTextColor, fontSize: 12)),
              ],
            ),
          ),
          if (item.canAdjust) ...[
            IconButton(
              tooltip: context.l10n.qtyLess,
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
              tooltip: context.l10n.qtyMore,
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
            tooltip: context.l10n.moreActions,
            color: AppTheme.cardColor,
            icon: const Icon(Icons.more_vert_rounded, color: AppTheme.subTextColor),
            onSelected: (action) => _onMenu(action, item),
            itemBuilder: (_) => [
              PopupMenuItem(value: 'edit', child: Text(context.l10n.editAction)),
              PopupMenuItem(value: 'pin', child: Text(item.pinned ? context.l10n.unpinAction : context.l10n.pinAction)),
              PopupMenuItem(value: 'out', child: Text(context.l10n.outToShopping)),
              PopupMenuItem(value: 'delete', child: Text(context.l10n.deleteAction)),
            ],
          ),
        ],
      ),
    );
  }
}
