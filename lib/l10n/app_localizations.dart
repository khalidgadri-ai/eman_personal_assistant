import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @navGoals.
  ///
  /// In ar, this message translates to:
  /// **'الأهداف والمهام'**
  String get navGoals;

  /// No description provided for @navHealth.
  ///
  /// In ar, this message translates to:
  /// **'الصحة واللياقة'**
  String get navHealth;

  /// No description provided for @navKitchen.
  ///
  /// In ar, this message translates to:
  /// **'المطبخ والمنزل'**
  String get navKitchen;

  /// No description provided for @navBudget.
  ///
  /// In ar, this message translates to:
  /// **'الميزانية'**
  String get navBudget;

  /// No description provided for @navAssistant.
  ///
  /// In ar, this message translates to:
  /// **'المساعد الذكي'**
  String get navAssistant;

  /// No description provided for @coachTooltip.
  ///
  /// In ar, this message translates to:
  /// **'مدرب الحياة'**
  String get coachTooltip;

  /// No description provided for @contactUs.
  ///
  /// In ar, this message translates to:
  /// **'تواصل معنا'**
  String get contactUs;

  /// No description provided for @contactMailFailed.
  ///
  /// In ar, this message translates to:
  /// **'لم يُفتح تطبيق البريد. يمكنك مراسلتنا على هذا العنوان:'**
  String get contactMailFailed;

  /// No description provided for @close.
  ///
  /// In ar, this message translates to:
  /// **'إغلاق'**
  String get close;

  /// No description provided for @copyAddress.
  ///
  /// In ar, this message translates to:
  /// **'نسخ العنوان'**
  String get copyAddress;

  /// No description provided for @cancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get cancel;

  /// No description provided for @settingsTitle.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get settingsTitle;

  /// No description provided for @settingsAiProvider.
  ///
  /// In ar, this message translates to:
  /// **'مزوّد الذكاء الاصطناعي'**
  String get settingsAiProvider;

  /// No description provided for @settingsAiProviderHint.
  ///
  /// In ar, this message translates to:
  /// **'لتفعيل ميزات الذكاء الاصطناعي بمفتاحك الخاص'**
  String get settingsAiProviderHint;

  /// No description provided for @settingsTour.
  ///
  /// In ar, this message translates to:
  /// **'جولة التعريف بالتطبيق'**
  String get settingsTour;

  /// No description provided for @settingsTourHint.
  ///
  /// In ar, this message translates to:
  /// **'شرح قصير لكل أقسام التطبيق وطريقة الحصول على مفتاح'**
  String get settingsTourHint;

  /// No description provided for @settingsLanguage.
  ///
  /// In ar, this message translates to:
  /// **'اللغة'**
  String get settingsLanguage;

  /// No description provided for @languageSystem.
  ///
  /// In ar, this message translates to:
  /// **'لغة الجوال'**
  String get languageSystem;

  /// No description provided for @languageArabic.
  ///
  /// In ar, this message translates to:
  /// **'العربية'**
  String get languageArabic;

  /// No description provided for @languageEnglish.
  ///
  /// In ar, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @profileNoName.
  ///
  /// In ar, this message translates to:
  /// **'بدون اسم'**
  String get profileNoName;

  /// No description provided for @profileEdit.
  ///
  /// In ar, this message translates to:
  /// **'تعديل ملفي'**
  String get profileEdit;

  /// No description provided for @profileEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لم تُضف اسمًا أو اهتمامات بعد. تُحفظ مشفّرة على جهازك فقط.'**
  String get profileEmpty;

  /// No description provided for @backupSaveTitle.
  ///
  /// In ar, this message translates to:
  /// **'حفظ نسخة احتياطية مشفّرة'**
  String get backupSaveTitle;

  /// No description provided for @backupSaveHint.
  ///
  /// In ar, this message translates to:
  /// **'ملف محميّ بكلمة مرور يُحفظ خارج التطبيق'**
  String get backupSaveHint;

  /// No description provided for @backupSaving.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ التشفير، قد يستغرق ذلك عدة ثوانٍ...'**
  String get backupSaving;

  /// No description provided for @backupRestoreTitle.
  ///
  /// In ar, this message translates to:
  /// **'استعادة من نسخة احتياطية'**
  String get backupRestoreTitle;

  /// No description provided for @backupRestoreHint.
  ///
  /// In ar, this message translates to:
  /// **'استبدال بيانات هذا الجهاز بما في ملف النسخة'**
  String get backupRestoreHint;

  /// No description provided for @backupRestoring.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ فتح النسخة، قد يستغرق ذلك عدة ثوانٍ...'**
  String get backupRestoring;

  /// No description provided for @backupSaved.
  ///
  /// In ar, this message translates to:
  /// **'حُفظت النسخة الاحتياطية. كلمة المرور لا تُسترجع، فيجب الاحتفاظ بها.'**
  String get backupSaved;

  /// No description provided for @backupNotSaved.
  ///
  /// In ar, this message translates to:
  /// **'لم تُحفظ النسخة الاحتياطية.'**
  String get backupNotSaved;

  /// No description provided for @backupRestoreAsk.
  ///
  /// In ar, this message translates to:
  /// **'استعادة نسخة احتياطية؟'**
  String get backupRestoreAsk;

  /// No description provided for @backupRestoreBody.
  ///
  /// In ar, this message translates to:
  /// **'ستُستبدل بيانات هذا الجهاز كلها (الملف الشخصي والمهام والأهداف والصحة والمطبخ والمصاريف وجلسات المدرب) بما في النسخة. مفاتيح الذكاء الاصطناعي لا تتأثر.'**
  String get backupRestoreBody;

  /// No description provided for @backupChooseFile.
  ///
  /// In ar, this message translates to:
  /// **'اختيار الملف'**
  String get backupChooseFile;

  /// No description provided for @backupRestored.
  ///
  /// In ar, this message translates to:
  /// **'تمت استعادة النسخة الاحتياطية.'**
  String get backupRestored;

  /// No description provided for @backupGenericError.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر إتمام العملية. لم تتغير البيانات.'**
  String get backupGenericError;

  /// No description provided for @passwordTitle.
  ///
  /// In ar, this message translates to:
  /// **'كلمة مرور النسخة'**
  String get passwordTitle;

  /// No description provided for @passwordNoRecovery.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد طريقة لاسترجاع كلمة المرور. بدونها لا يمكن فتح النسخة أبدًا.'**
  String get passwordNoRecovery;

  /// No description provided for @passwordHintNew.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور ({count, plural, =1{حرف واحد على الأقل} =2{حرفان على الأقل} few{{count} أحرف على الأقل} many{{count} حرفًا على الأقل} other{{count} حرف على الأقل}})'**
  String passwordHintNew(int count);

  /// No description provided for @passwordHint.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور'**
  String get passwordHint;

  /// No description provided for @passwordConfirmHint.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد كلمة المرور'**
  String get passwordConfirmHint;

  /// No description provided for @passwordMismatch.
  ///
  /// In ar, this message translates to:
  /// **'كلمتا المرور غير متطابقتين.'**
  String get passwordMismatch;

  /// No description provided for @passwordRequired.
  ///
  /// In ar, this message translates to:
  /// **'يرجى كتابة كلمة المرور.'**
  String get passwordRequired;

  /// No description provided for @show.
  ///
  /// In ar, this message translates to:
  /// **'إظهار'**
  String get show;

  /// No description provided for @hide.
  ///
  /// In ar, this message translates to:
  /// **'إخفاء'**
  String get hide;

  /// No description provided for @continueAction.
  ///
  /// In ar, this message translates to:
  /// **'متابعة'**
  String get continueAction;

  /// No description provided for @restoreAction.
  ///
  /// In ar, this message translates to:
  /// **'استعادة'**
  String get restoreAction;

  /// No description provided for @eraseTitle.
  ///
  /// In ar, this message translates to:
  /// **'مسح كل بياناتي'**
  String get eraseTitle;

  /// No description provided for @eraseHint.
  ///
  /// In ar, this message translates to:
  /// **'يحذف كل ما أدخلته من هذا الجهاز ويعيد التطبيق كأول تشغيل'**
  String get eraseHint;

  /// No description provided for @eraseAsk.
  ///
  /// In ar, this message translates to:
  /// **'مسح كل بياناتي؟'**
  String get eraseAsk;

  /// No description provided for @eraseBody.
  ///
  /// In ar, this message translates to:
  /// **'سيُحذف نهائيًا من هذا الجهاز كل ما أدخلته: الملف الشخصي والمهام والأهداف والصحة والمطبخ والمصاريف وجلسات المدرب ومفاتيح الذكاء الاصطناعي. لا يمكن التراجع.'**
  String get eraseBody;

  /// No description provided for @eraseConfirm.
  ///
  /// In ar, this message translates to:
  /// **'مسح كل شيء'**
  String get eraseConfirm;

  /// No description provided for @eraseFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر مسح البيانات. لم يُحذف شيء، حاول مرة أخرى.'**
  String get eraseFailed;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
