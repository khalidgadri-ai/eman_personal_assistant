import 'package:flutter/material.dart';
import '../../l10n/l10n.dart';

/// رسالة قصيرة بعد حذف عنصر مع زر "تراجع" يعيده إلى مكانه. تحل محل رسالة سابقة إن وُجدت.
void showUndoSnackBar(BuildContext context, String message, Future<void> Function() onUndo) {
  final messenger = ScaffoldMessenger.of(context);
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        action: SnackBarAction(label: context.l10n.undo, onPressed: () => onUndo()),
      ),
    );
}

/// رسالة عابرة بسيطة.
void showInfoSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}
