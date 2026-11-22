import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// يعمل قبل كل ملف اختبار: الجوال الافتراضي عربي في السعودية، كجمهور التطبيق الأول، فتبقى
/// «لغة الجوال» عربية والعملة ريالًا. اختبارات الإنجليزية تختار اللغة صراحة (AppLocale.choice)،
/// والاختبار الذي يغيّر بلد الجوال يعيده إلى هذا في نهايته.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  binding.platformDispatcher.localeTestValue = testDeviceLocale;
  binding.platformDispatcher.localesTestValue = const [testDeviceLocale];
  await testMain();
}

const Locale testDeviceLocale = Locale('ar', 'SA');
