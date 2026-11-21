import 'package:flutter/widgets.dart';
import '../core/config/app_locale.dart';
import 'app_localizations.dart';

export 'app_localizations.dart';

/// نصوص الواجهة باللغة الحالية: `context.l10n.settingsTitle`. إن لم تُضف الترجمات للشجرة
/// (بعض الاختبارات) تُستعمل العربية بدل أن يتعطل البناء.
extension L10nContext on BuildContext {
  AppLocalizations get l10n =>
      Localizations.of<AppLocalizations>(this, AppLocalizations) ??
      lookupAppLocalizations(AppLocale.arabic);

  /// رمز لغة النصوص الحالية ('ar' أو 'en')، لاختيار محتوى مثل نصوص الجلسات وصوت المرشد.
  /// من ترجمات التطبيق لا من MaterialApp، فيبقى عربيًا في الاختبارات بلا ترجمات.
  String get appLang => l10n.localeName.split('_').first;
}
