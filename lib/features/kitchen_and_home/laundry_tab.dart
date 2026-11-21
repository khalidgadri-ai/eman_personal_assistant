import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/entry_dialog.dart';
import '../../core/widgets/undo_snackbar.dart';
import 'kitchen_constants.dart';
import 'kitchen_store.dart';
import 'models/laundry_entry.dart';
import '../../l10n/l10n.dart';

Future<void> startAddLaundry(BuildContext context, KitchenStore store) async {
  final values = await showEntryDialog(
    context,
    title: context.l10n.laundryAddTitle,
    fields: [
      EntryField(key: 'day', label: context.l10n.dayField, options: weekDays, optionLabel: (d) => weekDayLabel(context.l10n, d)),
      EntryField(key: 'type', label: context.l10n.laundryTypeField, hint: context.l10n.laundryTypeHint, required: true),
      EntryField(key: 'care', label: context.l10n.instructionsOptional, maxLength: 200),
    ],
  );
  if (values == null) return;
  await store.addLaundry(day: values['day']!, type: values['type']!, care: values['care']!);
}

/// جدول الغسيل الأسبوعي: إضافة وعرض وتعديل (بالضغط على الموعد) وحذف مع تراجع.
class LaundryTab extends StatelessWidget {
  const LaundryTab({super.key, required this.store});

  final KitchenStore store;

  Future<void> _edit(BuildContext context, LaundryEntry entry) async {
    final days = weekDays.contains(entry.day) ? weekDays : [...weekDays, entry.day];
    final values = await showEntryDialog(
      context,
      title: context.l10n.laundryEditTitle,
      confirmLabel: context.l10n.save,
      fields: [
        EntryField(key: 'day', label: context.l10n.dayField, options: days, initial: entry.day, optionLabel: (d) => weekDayLabel(context.l10n, d)),
        EntryField(key: 'type', label: context.l10n.laundryTypeField, required: true, initial: entry.type),
        EntryField(key: 'care', label: context.l10n.instructionsOptional, maxLength: 200, initial: entry.care),
      ],
    );
    if (values == null) return;
    await store.updateLaundry(entry.copyWith(day: values['day'], type: values['type'], care: values['care']));
  }

  Future<void> _delete(BuildContext context, LaundryEntry entry) async {
    final removed = await store.removeLaundry(entry.id);
    if (removed == null || !context.mounted) return;
    showUndoSnackBar(context, context.l10n.laundryDeleted(entry.type), () => store.restoreLaundry(removed));
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final entries = store.laundry;
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          children: [
            KitchenSectionTitle(context.l10n.laundryHeader),
            const SizedBox(height: 12),
            if (entries.isEmpty) KitchenEmptyNote(context.l10n.laundryEmpty),
            for (final entry in entries)
              Card(
                key: ValueKey('laundry_${entry.id}'),
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: const Icon(Icons.local_laundry_service_rounded, color: AppTheme.accentColor),
                  title: Text(
                    '${weekDayLabel(context.l10n, entry.day)}: ${entry.type}',
                    style: const TextStyle(color: AppTheme.textColor, fontWeight: FontWeight.bold),
                  ),
                  subtitle: entry.care.isEmpty
                      ? null
                      : Text(context.l10n.instructionsLine(entry.care), style: const TextStyle(color: AppTheme.subTextColor)),
                  onTap: () => _edit(context, entry),
                  trailing: IconButton(
                    tooltip: context.l10n.laundryDelete,
                    icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.subTextColor),
                    onPressed: () => _delete(context, entry),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
