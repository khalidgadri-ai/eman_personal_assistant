import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// لغة التطبيق: العربية دائمًا. بدونها تظهر نوافذ التاريخ والوقت بالإنجليزية («Select date»،
/// «Cancel»)، وتقرأ قارئات الشاشة أسماء الأزرار الجاهزة بالإنجليزية («Back»).
abstract final class AppLocale {
  static const Locale locale = Locale('ar');

  static const List<Locale> supported = [locale];

  static const List<LocalizationsDelegate<dynamic>> delegates = [
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];
}
