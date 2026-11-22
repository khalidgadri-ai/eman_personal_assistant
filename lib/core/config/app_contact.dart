import 'app_locale.dart';

/// جهة التواصل مع مطوّر التطبيق.
abstract final class AppContact {
  /// البريد العام الذي يفتحه زر "تواصل معنا"، ويظهر لكل مستخدم. اختاره مالك التطبيق في
  /// 22 نوفمبر 2026. لو صار فارغًا يختفي الزر، بدل أن يظهر زر بلا وجهة.
  static const String supportEmail = 'khalidibrahimgadrieng@gmail.com';

  /// عنوان الرسالة بلغة التطبيق.
  static String get subject => AppLocale.texts.contactSubject;
}
