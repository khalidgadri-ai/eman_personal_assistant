import 'app_locale.dart';

/// جهة التواصل مع مطوّر التطبيق.
abstract final class AppContact {
  /// البريد العام الذي يفتحه زر "تواصل معنا". **اتركه فارغًا حتى تضع بريد الدعم الذي ستنشره في
  /// متجر Google Play**: وهو فارغ يختفي الزر، بدل أن يظهر زر بلا وجهة. لا تضع بريدًا شخصيًا
  /// لم تقرر نشره، فهو يظهر لكل مستخدم.
  static const String supportEmail = '';

  /// عنوان الرسالة بلغة التطبيق.
  static String get subject => AppLocale.texts.contactSubject;
}
