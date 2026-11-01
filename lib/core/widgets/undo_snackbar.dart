import 'package:flutter/material.dart';

/// رسالة قصيرة بعد حذف عنصر مع زر "تراجع" يعيده إلى مكانه. تحل محل رسالة سابقة إن وُجدت.
void showUndoSnackBar(BuildContext context, String message, Future<void> Function() onUndo) {
  final messenger = ScaffoldMessenger.of(context);
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        action: SnackBarAction(label: 'تراجع', onPressed: () => onUndo()),
      ),
    );
}

/// رسالة عابرة بسيطة.
void showInfoSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}
