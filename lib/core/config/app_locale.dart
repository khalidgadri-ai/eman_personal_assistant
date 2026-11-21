import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../../l10n/app_localizations.dart';

/// اختيار المستخدم للغة من الإعدادات. يُحفظ في `app_language` (إعداد جهاز، خارج النسخة الاحتياطية).
enum AppLanguage { system, ar, en }

/// لغات التطبيق. النصوص في lib/l10n/app_*.arb (العربية هي الأصل)، ونوافذ التاريخ والوقت وأسماء
/// الأزرار الجاهزة من flutter_localizations. الاتجاه يتبع اللغة: العربية من اليمين، والإنجليزية من اليسار.
abstract final class AppLocale {
  static const Locale arabic = Locale('ar');
  static const Locale english = Locale('en');

  /// اللغة الافتراضية.
  static const Locale locale = arabic;

  static const List<Locale> supported = [arabic, english];

  static const List<LocalizationsDelegate<dynamic>> delegates = [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  /// الإنجليزية لا تظهر للمستخدمين قبل ترجمة كل الشاشات: بدونها يرى نصف التطبيق بالعربية.
  /// قبل ذلك تبقى «لغة الجوال» عربية، وخيار اللغة يظهر في نسخ التطوير فقط.
  static const bool englishReady = false;

  static bool get languagePickerVisible => englishReady || kDebugMode;

  /// ما اختاره المستخدم، وتتبعه MaterialApp فورًا.
  static final ValueNotifier<AppLanguage> choice = ValueNotifier(
    AppLanguage.system,
  );

  /// اللغة الفعلية: اختيار المستخدم، أو لغة الجوال إن كانت عربية، وإلا الإنجليزية (حين تجهز).
  static Locale resolve(AppLanguage choice, Locale? device) => switch (choice) {
    AppLanguage.ar => arabic,
    AppLanguage.en => english,
    AppLanguage.system =>
      englishReady && device?.languageCode != 'ar' ? english : arabic,
  };

  /// اللغة الحالية خارج الشاشات (نصوص التذكيرات مثلًا)، حيث لا يوجد BuildContext.
  static Locale get current => resolve(choice.value, PlatformDispatcher.instance.locale);

  /// نصوص اللغة الحالية خارج الشاشات.
  static AppLocalizations get texts => lookupAppLocalizations(current);

  static AppLanguage parse(String? raw) =>
      AppLanguage.values.where((l) => l.name == raw).firstOrNull ??
      AppLanguage.system;
}
