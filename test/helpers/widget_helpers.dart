import 'package:eman_life_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// يعرض [screen] داخل MaterialApp بنفس ثيم التطبيق، ويترك الخدمات غير المتزامنة تنتهي.
Future<void> pumpScreen(WidgetTester tester, Widget screen) async {
  await tester.pumpWidget(MaterialApp(theme: AppTheme.darkTheme, home: screen));
  await settle(tester);
}

/// بدل pumpAndSettle: بعض الشاشات تعرض مؤشر تحميل لا ينتهي لحظة التهيئة.
Future<void> settle(WidgetTester tester, {int frames = 6}) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// يكتب في حقول نافذة الإدخال بحسب نص عنوان الحقل، ثم يضغط زر التأكيد.
Future<void> fillDialog(
  WidgetTester tester,
  Map<String, String> byLabel, {
  String confirm = 'إضافة',
}) async {
  for (final entry in byLabel.entries) {
    await tester.enterText(find.widgetWithText(TextField, entry.key), entry.value);
  }
  await tester.tap(find.text(confirm));
  await tester.pumpAndSettle();
}

/// ينتقل لتبويب داخلي بنصه ويترك الحركة تنتهي.
Future<void> openTab(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}
