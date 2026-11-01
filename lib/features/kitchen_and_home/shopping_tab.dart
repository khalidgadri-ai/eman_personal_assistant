import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/entry_dialog.dart';
import '../../core/widgets/undo_snackbar.dart';
import 'kitchen_constants.dart';
import 'kitchen_store.dart';
import 'models/shopping_item.dart';

Future<void> startAddShoppingItem(BuildContext context, KitchenStore store) async {
  final values = await showEntryDialog(
    context,
    title: 'إضافة بند للمشتريات',
    fields: const [
      EntryField(key: 'name', label: 'البند', required: true),
      EntryField(key: 'qty', label: 'الكمية (اختياري)', hint: 'مثال: 2 كجم'),
    ],
  );
  if (values == null) return;
  await store.addShoppingItem(name: values['name']!, qty: values['qty']!);
}

/// قائمة المشتريات: بنود يدوية أو من وصفة أو من "نفد". الشراء يشطب البند، ثم يُمسح أو يُنقل
/// إلى المؤونة.
class ShoppingTab extends StatelessWidget {
  const ShoppingTab({super.key, required this.store});

  final KitchenStore store;

  Future<void> _edit(BuildContext context, ShoppingItem item) async {
    final values = await showEntryDialog(
      context,
      title: 'تعديل البند',
      confirmLabel: 'حفظ',
      fields: [
        EntryField(key: 'name', label: 'البند', required: true, initial: item.name),
        EntryField(key: 'qty', label: 'الكمية (اختياري)', initial: item.qty),
      ],
    );
    if (values == null) return;
    await store.updateShoppingItem(item.copyWith(name: values['name'], qty: values['qty']));
  }

  Future<void> _delete(BuildContext context, ShoppingItem item) async {
    final removed = await store.removeShoppingItem(item.id);
    if (removed == null || !context.mounted) return;
    showUndoSnackBar(context, 'حُذف «${item.name}»', () => store.restoreShoppingItem(removed));
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final items = store.shopping;
        final doneCount = items.where((s) => s.done).length;
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          children: [
            const KitchenSectionTitle('قائمة المشتريات'),
            const SizedBox(height: 12),
            if (items.isEmpty)
              const KitchenEmptyNote('قائمة المشتريات فارغة. اضغط + لإضافة بند، أو أضف مقادير وصفة من صفحتها.')
            else ...[
              if (doneCount > 0)
                Wrap(
                  spacing: 8,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () async {
                        final moved = await store.moveBoughtToPantry();
                        if (context.mounted) showInfoSnackBar(context, 'نُقل $moved إلى المؤونة');
                      },
                      icon: const Icon(Icons.kitchen_rounded, size: 18),
                      label: const Text('نقل المشتراة إلى المؤونة'),
                    ),
                    TextButton(
                      onPressed: store.clearDoneShopping,
                      child: const Text('مسح المشتراة'),
                    ),
                  ],
                ),
              for (final item in items)
                Card(
                  key: ValueKey('shopping_${item.id}'),
                  margin: const EdgeInsets.only(top: 10),
                  child: ListTile(
                    leading: Checkbox(
                      value: item.done,
                      activeColor: AppTheme.primaryColor,
                      onChanged: (_) => store.toggleShoppingDone(item.id),
                    ),
                    title: Text(
                      item.name,
                      style: TextStyle(
                        color: item.done ? AppTheme.subTextColor : AppTheme.textColor,
                        fontWeight: FontWeight.bold,
                        decoration: item.done ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    subtitle: item.source.isEmpty
                        ? null
                        : Text('من: ${item.source}', style: const TextStyle(color: AppTheme.subTextColor, fontSize: 12)),
                    onTap: () => _edit(context, item),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (item.qty.isNotEmpty)
                          Text(item.qty, style: const TextStyle(color: AppTheme.accentColor, fontWeight: FontWeight.bold)),
                        IconButton(
                          tooltip: 'حذف البند',
                          icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.subTextColor),
                          onPressed: () => _delete(context, item),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ],
        );
      },
    );
  }
}
