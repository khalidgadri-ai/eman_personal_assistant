import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/entry_dialog.dart';
import '../../core/widgets/undo_snackbar.dart';
import 'kitchen_constants.dart';
import 'kitchen_store.dart';
import 'models/shopping_item.dart';
import '../../l10n/l10n.dart';

Future<void> startAddShoppingItem(BuildContext context, KitchenStore store) async {
  final values = await showEntryDialog(
    context,
    title: context.l10n.shoppingAddTitle,
    fields: [
      EntryField(key: 'name', label: context.l10n.shoppingItemField, required: true),
      EntryField(key: 'qty', label: context.l10n.qtyOptionalField, hint: context.l10n.shoppingQtyHint),
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
      title: context.l10n.shoppingEditTitle,
      confirmLabel: context.l10n.save,
      fields: [
        EntryField(key: 'name', label: context.l10n.shoppingItemField, required: true, initial: item.name),
        EntryField(key: 'qty', label: context.l10n.qtyOptionalField, initial: item.qty),
      ],
    );
    if (values == null) return;
    await store.updateShoppingItem(item.copyWith(name: values['name'], qty: values['qty']));
  }

  Future<void> _delete(BuildContext context, ShoppingItem item) async {
    final removed = await store.removeShoppingItem(item.id);
    if (removed == null || !context.mounted) return;
    showUndoSnackBar(context, context.l10n.itemDeleted(item.name), () => store.restoreShoppingItem(removed));
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
            KitchenSectionTitle(context.l10n.shoppingHeader),
            const SizedBox(height: 12),
            if (items.isEmpty)
              KitchenEmptyNote(context.l10n.shoppingEmpty)
            else ...[
              if (doneCount > 0)
                Wrap(
                  spacing: 8,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () async {
                        final moved = await store.moveBoughtToPantry();
                        if (context.mounted) showInfoSnackBar(context, context.l10n.movedToPantry(moved));
                      },
                      icon: const Icon(Icons.kitchen_rounded, size: 18),
                      label: Text(context.l10n.moveBoughtToPantry),
                    ),
                    TextButton(
                      onPressed: store.clearDoneShopping,
                      child: Text(context.l10n.clearBought),
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
                        : Text(context.l10n.shoppingFrom(shoppingSourceLabel(context.l10n, item.source)), style: const TextStyle(color: AppTheme.subTextColor, fontSize: 12)),
                    onTap: () => _edit(context, item),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (item.qty.isNotEmpty)
                          Text(item.qty, style: const TextStyle(color: AppTheme.accentColor, fontWeight: FontWeight.bold)),
                        IconButton(
                          tooltip: context.l10n.shoppingDelete,
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
