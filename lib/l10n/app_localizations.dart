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

  /// No description provided for @back.
  ///
  /// In ar, this message translates to:
  /// **'رجوع'**
  String get back;

  /// No description provided for @next.
  ///
  /// In ar, this message translates to:
  /// **'التالي'**
  String get next;

  /// No description provided for @skip.
  ///
  /// In ar, this message translates to:
  /// **'تخطي'**
  String get skip;

  /// No description provided for @save.
  ///
  /// In ar, this message translates to:
  /// **'حفظ'**
  String get save;

  /// No description provided for @start.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ'**
  String get start;

  /// No description provided for @interestHealth.
  ///
  /// In ar, this message translates to:
  /// **'الصحة واللياقة'**
  String get interestHealth;

  /// No description provided for @interestGrowth.
  ///
  /// In ar, this message translates to:
  /// **'التنمية الذاتية'**
  String get interestGrowth;

  /// No description provided for @interestReading.
  ///
  /// In ar, this message translates to:
  /// **'القراءة'**
  String get interestReading;

  /// No description provided for @interestFaith.
  ///
  /// In ar, this message translates to:
  /// **'العبادة والروحانيات'**
  String get interestFaith;

  /// No description provided for @interestBudget.
  ///
  /// In ar, this message translates to:
  /// **'الميزانية والادخار'**
  String get interestBudget;

  /// No description provided for @interestKitchen.
  ///
  /// In ar, this message translates to:
  /// **'المطبخ والوصفات'**
  String get interestKitchen;

  /// No description provided for @interestHome.
  ///
  /// In ar, this message translates to:
  /// **'تنظيم المنزل'**
  String get interestHome;

  /// No description provided for @interestSkills.
  ///
  /// In ar, this message translates to:
  /// **'تعلّم مهارات جديدة'**
  String get interestSkills;

  /// No description provided for @interestWork.
  ///
  /// In ar, this message translates to:
  /// **'العمل والإنتاجية'**
  String get interestWork;

  /// No description provided for @interestFamily.
  ///
  /// In ar, this message translates to:
  /// **'الأسرة'**
  String get interestFamily;

  /// No description provided for @onboardingWelcome.
  ///
  /// In ar, this message translates to:
  /// **'أهلًا بك في إيمان'**
  String get onboardingWelcome;

  /// No description provided for @onboardingIntro.
  ///
  /// In ar, this message translates to:
  /// **'مساعدك الشخصي للمهام والصحة والمطبخ والميزانية. كل ما تدخله يبقى على جهازك.'**
  String get onboardingIntro;

  /// No description provided for @onboardingNameQuestion.
  ///
  /// In ar, this message translates to:
  /// **'ما اسمك؟'**
  String get onboardingNameQuestion;

  /// No description provided for @onboardingNameLabel.
  ///
  /// In ar, this message translates to:
  /// **'ما اسمك؟ (اختياري)'**
  String get onboardingNameLabel;

  /// No description provided for @onboardingInterestsTitle.
  ///
  /// In ar, this message translates to:
  /// **'ما الذي يهمّك؟'**
  String get onboardingInterestsTitle;

  /// No description provided for @onboardingInterestsHint.
  ///
  /// In ar, this message translates to:
  /// **'اختر ما يناسبك، ويمكنك تغييره لاحقًا من الإعدادات.'**
  String get onboardingInterestsHint;

  /// No description provided for @onboardingGoalsTitle.
  ///
  /// In ar, this message translates to:
  /// **'أهدافك (اختياري)'**
  String get onboardingGoalsTitle;

  /// No description provided for @onboardingGoalLabel.
  ///
  /// In ar, this message translates to:
  /// **'اكتب هدفًا ثم اضغط +'**
  String get onboardingGoalLabel;

  /// No description provided for @onboardingGoalHint.
  ///
  /// In ar, this message translates to:
  /// **'مثال: قراءة 20 صفحة يوميًا'**
  String get onboardingGoalHint;

  /// No description provided for @onboardingAddGoal.
  ///
  /// In ar, this message translates to:
  /// **'إضافة هدف'**
  String get onboardingAddGoal;

  /// No description provided for @onboardingRemoveGoal.
  ///
  /// In ar, this message translates to:
  /// **'حذف الهدف'**
  String get onboardingRemoveGoal;

  /// No description provided for @onboardingPrivacy.
  ///
  /// In ar, this message translates to:
  /// **'تُحفظ هذه المعلومات مشفّرة على جهازك. وإن فعّلت المساعد الذكي بمفتاحك، تُرسل مع طلباته إلى مزوّد الذكاء الاصطناعي الذي تختاره لتخصيص الردود.'**
  String get onboardingPrivacy;

  /// No description provided for @onboardingSaveFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر الحفظ على جهازك. حاول مرة أخرى.'**
  String get onboardingSaveFailed;

  /// No description provided for @tourPageOf.
  ///
  /// In ar, this message translates to:
  /// **'صفحة {page} من {total}'**
  String tourPageOf(int page, int total);

  /// No description provided for @tourIntroTitle.
  ///
  /// In ar, this message translates to:
  /// **'جولة قصيرة'**
  String get tourIntroTitle;

  /// No description provided for @tourIntro1.
  ///
  /// In ar, this message translates to:
  /// **'سنعرّفك على التطبيق في 10 صفحات قصيرة.'**
  String get tourIntro1;

  /// No description provided for @tourIntro2.
  ///
  /// In ar, this message translates to:
  /// **'في كل صفحة فكرة واحدة فقط.'**
  String get tourIntro2;

  /// No description provided for @tourIntro3.
  ///
  /// In ar, this message translates to:
  /// **'يمكنك الرجوع لأي صفحة بزر «رجوع».'**
  String get tourIntro3;

  /// No description provided for @tourTasksTitle.
  ///
  /// In ar, this message translates to:
  /// **'الأهداف والمهام'**
  String get tourTasksTitle;

  /// No description provided for @tourTasks1.
  ///
  /// In ar, this message translates to:
  /// **'اكتب مهمة صغيرة واحدة بزر «+».'**
  String get tourTasks1;

  /// No description provided for @tourTasks2.
  ///
  /// In ar, this message translates to:
  /// **'حين تنتهي منها، ضع علامة ✓ بجانبها.'**
  String get tourTasks2;

  /// No description provided for @tourTasksExample.
  ///
  /// In ar, this message translates to:
  /// **'مثال: «اشترِ الخبز».'**
  String get tourTasksExample;

  /// No description provided for @tourGoalsTitle.
  ///
  /// In ar, this message translates to:
  /// **'قسّم الكبير إلى صغير'**
  String get tourGoalsTitle;

  /// No description provided for @tourGoals1.
  ///
  /// In ar, this message translates to:
  /// **'الهدف الكبير يصبح سهلًا إذا قسّمته.'**
  String get tourGoals1;

  /// No description provided for @tourGoals2.
  ///
  /// In ar, this message translates to:
  /// **'حرّك شريط التقدّم كلما أنجزت جزءًا.'**
  String get tourGoals2;

  /// No description provided for @tourGoalsExample.
  ///
  /// In ar, this message translates to:
  /// **'مثال: «ترتيب البيت» هدف شهري، و«ترتيب غرفة النوم» هدف أسبوعي، و«ترتيب درج واحد» مهمة اليوم.'**
  String get tourGoalsExample;

  /// No description provided for @tourRemindersTitle.
  ///
  /// In ar, this message translates to:
  /// **'التذكير'**
  String get tourRemindersTitle;

  /// No description provided for @tourReminders1.
  ///
  /// In ar, this message translates to:
  /// **'يمكنك أن تضع وقتًا للمهمة أو للدواء فيصلك تنبيه.'**
  String get tourReminders1;

  /// No description provided for @tourReminders2.
  ///
  /// In ar, this message translates to:
  /// **'حين يسألك الجوال عن الإشعارات اضغط «السماح».'**
  String get tourReminders2;

  /// No description provided for @tourReminders3.
  ///
  /// In ar, this message translates to:
  /// **'قد يتأخر التنبيه دقائق قليلة.'**
  String get tourReminders3;

  /// No description provided for @tourHealthTitle.
  ///
  /// In ar, this message translates to:
  /// **'الصحة واللياقة'**
  String get tourHealthTitle;

  /// No description provided for @tourHealth1.
  ///
  /// In ar, this message translates to:
  /// **'سجّل تمارينك، ومواعيد أدويتك، وروتين العناية.'**
  String get tourHealth1;

  /// No description provided for @tourHealthExample.
  ///
  /// In ar, this message translates to:
  /// **'مثال: دواء الصباح الساعة 8.'**
  String get tourHealthExample;

  /// No description provided for @tourKitchenTitle.
  ///
  /// In ar, this message translates to:
  /// **'المطبخ والمنزل'**
  String get tourKitchenTitle;

  /// No description provided for @tourKitchen1.
  ///
  /// In ar, this message translates to:
  /// **'وصفاتك، وما عندك في البيت، وقائمة المشتريات، وجدول الغسيل.'**
  String get tourKitchen1;

  /// No description provided for @tourKitchen2.
  ///
  /// In ar, this message translates to:
  /// **'ما ينقص من البيت يمكنك نقله إلى المشتريات.'**
  String get tourKitchen2;

  /// No description provided for @tourBudgetTitle.
  ///
  /// In ar, this message translates to:
  /// **'الميزانية'**
  String get tourBudgetTitle;

  /// No description provided for @tourBudget1.
  ///
  /// In ar, this message translates to:
  /// **'اكتب دخلك ومصاريفك الثابتة مرة واحدة، فيحسب لك التطبيق كم يمكنك أن تصرف اليوم.'**
  String get tourBudget1;

  /// No description provided for @tourBudget2.
  ///
  /// In ar, this message translates to:
  /// **'كل الأرقام تبقى على جوالك.'**
  String get tourBudget2;

  /// No description provided for @tourCoachTitle.
  ///
  /// In ar, this message translates to:
  /// **'المدرب والمساعد الذكي'**
  String get tourCoachTitle;

  /// No description provided for @tourCoach1.
  ///
  /// In ar, this message translates to:
  /// **'زر المدرب (أيقونة الرأس في أسفل وسط الشاشة) يسألك أسئلة تساعدك تفكّر وترتّب أمورك.'**
  String get tourCoach1;

  /// No description provided for @tourCoach2.
  ///
  /// In ar, this message translates to:
  /// **'أما المساعد الذكي فيجيب أسئلتك، لكنه يحتاج مفتاحًا: الصفحة التالية تشرح كيف تحصل عليه.'**
  String get tourCoach2;

  /// No description provided for @tourKeyTitle.
  ///
  /// In ar, this message translates to:
  /// **'مفتاح الذكاء الاصطناعي'**
  String get tourKeyTitle;

  /// No description provided for @tourStartTitle.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ بخطوة واحدة'**
  String get tourStartTitle;

  /// No description provided for @tourStart1.
  ///
  /// In ar, this message translates to:
  /// **'لا تحاول ترتيب كل شيء اليوم.'**
  String get tourStart1;

  /// No description provided for @tourStart2.
  ///
  /// In ar, this message translates to:
  /// **'اختر شيئًا صغيرًا واحدًا وابدأ به.'**
  String get tourStart2;

  /// No description provided for @tourStart3.
  ///
  /// In ar, this message translates to:
  /// **'يمكنك إعادة هذه الجولة من الإعدادات.'**
  String get tourStart3;

  /// No description provided for @tourSaveFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر حفظ إنهاء الجولة على جهازك.'**
  String get tourSaveFailed;

  /// No description provided for @tourKeySaved.
  ///
  /// In ar, this message translates to:
  /// **'✓ تم حفظ المفتاح'**
  String get tourKeySaved;

  /// No description provided for @tourAddKeyNow.
  ///
  /// In ar, this message translates to:
  /// **'أضف المفتاح الآن'**
  String get tourAddKeyNow;

  /// No description provided for @tourAddKeyLater.
  ///
  /// In ar, this message translates to:
  /// **'سأضيفه لاحقًا'**
  String get tourAddKeyLater;

  /// No description provided for @tourFinishFirstRun.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ استعمال التطبيق'**
  String get tourFinishFirstRun;

  /// No description provided for @tourFinish.
  ///
  /// In ar, this message translates to:
  /// **'إنهاء'**
  String get tourFinish;

  /// No description provided for @keyGuideTitle.
  ///
  /// In ar, this message translates to:
  /// **'كيف أحصل على مفتاح؟'**
  String get keyGuideTitle;

  /// No description provided for @keyGuideIntro.
  ///
  /// In ar, this message translates to:
  /// **'المفتاح مثل كلمة سرّ خاصة بك من المزوّد، يسمح للتطبيق أن يسأل الذكاء الاصطناعي باسمك.'**
  String get keyGuideIntro;

  /// No description provided for @keyGuideStepsWith.
  ///
  /// In ar, this message translates to:
  /// **'الخطوات مع {provider}:'**
  String keyGuideStepsWith(String provider);

  /// No description provided for @keyGuideGemini1.
  ///
  /// In ar, this message translates to:
  /// **'اضغط «افتح صفحة المفاتيح».'**
  String get keyGuideGemini1;

  /// No description provided for @keyGuideGemini2.
  ///
  /// In ar, this message translates to:
  /// **'سجّل الدخول بحساب Google.'**
  String get keyGuideGemini2;

  /// No description provided for @keyGuideGemini3.
  ///
  /// In ar, this message translates to:
  /// **'وافق على الشروط إن ظهرت.'**
  String get keyGuideGemini3;

  /// No description provided for @keyGuideGemini4.
  ///
  /// In ar, this message translates to:
  /// **'اضغط الزر المكتوب عليه Create API key (قد يظهر بلغة جوالك).'**
  String get keyGuideGemini4;

  /// No description provided for @keyGuideGemini5.
  ///
  /// In ar, this message translates to:
  /// **'انسخ المفتاح.'**
  String get keyGuideGemini5;

  /// No description provided for @keyGuideGemini6.
  ///
  /// In ar, this message translates to:
  /// **'ارجع إلى التطبيق والصقه في خانة «المفتاح»، ثم اضغط «حفظ وتفعيل».'**
  String get keyGuideGemini6;

  /// No description provided for @keyGuideOther1.
  ///
  /// In ar, this message translates to:
  /// **'اضغط «افتح صفحة المفاتيح».'**
  String get keyGuideOther1;

  /// No description provided for @keyGuideOther2.
  ///
  /// In ar, this message translates to:
  /// **'سجّل الدخول.'**
  String get keyGuideOther2;

  /// No description provided for @keyGuideOther3.
  ///
  /// In ar, this message translates to:
  /// **'أنشئ مفتاحًا جديدًا.'**
  String get keyGuideOther3;

  /// No description provided for @keyGuideOther4.
  ///
  /// In ar, this message translates to:
  /// **'انسخ المفتاح، ثم ارجع إلى التطبيق والصقه في خانة «المفتاح»، ثم اضغط «حفظ وتفعيل».'**
  String get keyGuideOther4;

  /// No description provided for @keyGuideGeminiFree.
  ///
  /// In ar, this message translates to:
  /// **'لـ Gemini استعمال مجاني ضمن حدود تضعها Google. وإن فعّلت الدفع في حسابك عند Google فقد تُحتسب عليك رسوم.'**
  String get keyGuideGeminiFree;

  /// No description provided for @keyGuidePaymentNote.
  ///
  /// In ar, this message translates to:
  /// **'قد يطلب بعض المزوّدين إضافة وسيلة دفع قبل أن يعمل المفتاح.'**
  String get keyGuidePaymentNote;

  /// No description provided for @keyGuideDontShare.
  ///
  /// In ar, this message translates to:
  /// **'لا تشارك مفتاحك مع أحد ولا تنشره. يُحفظ على جوالك فقط.'**
  String get keyGuideDontShare;

  /// No description provided for @keyGuideOpenPage.
  ///
  /// In ar, this message translates to:
  /// **'افتح صفحة المفاتيح'**
  String get keyGuideOpenPage;

  /// No description provided for @keyGuideLinkCopied.
  ///
  /// In ar, this message translates to:
  /// **'تم نسخ الرابط. الصقه في المتصفح.'**
  String get keyGuideLinkCopied;

  /// No description provided for @add.
  ///
  /// In ar, this message translates to:
  /// **'إضافة'**
  String get add;

  /// No description provided for @undo.
  ///
  /// In ar, this message translates to:
  /// **'تراجع'**
  String get undo;

  /// No description provided for @fieldRequired.
  ///
  /// In ar, this message translates to:
  /// **'هذا الحقل مطلوب'**
  String get fieldRequired;

  /// No description provided for @reminderNone.
  ///
  /// In ar, this message translates to:
  /// **'بدون تذكير'**
  String get reminderNone;

  /// No description provided for @reminderAt.
  ///
  /// In ar, this message translates to:
  /// **'يوميًا عند {time}'**
  String reminderAt(String time);

  /// No description provided for @reminderSet.
  ///
  /// In ar, this message translates to:
  /// **'ضبط تذكير'**
  String get reminderSet;

  /// No description provided for @reminderChange.
  ///
  /// In ar, this message translates to:
  /// **'تغيير الوقت'**
  String get reminderChange;

  /// No description provided for @reminderRemove.
  ///
  /// In ar, this message translates to:
  /// **'إزالة التذكير'**
  String get reminderRemove;

  /// No description provided for @reminderMedicationTitle.
  ///
  /// In ar, this message translates to:
  /// **'تذكير بالدواء'**
  String get reminderMedicationTitle;

  /// No description provided for @reminderRoutineTitle.
  ///
  /// In ar, this message translates to:
  /// **'تذكير بالعناية'**
  String get reminderRoutineTitle;

  /// No description provided for @reminderTaskTitle.
  ///
  /// In ar, this message translates to:
  /// **'تذكير بمهمة'**
  String get reminderTaskTitle;

  /// No description provided for @reminderNotScheduled.
  ///
  /// In ar, this message translates to:
  /// **'لم يُضبط التذكير. يلزم تفعيل إشعارات هذا التطبيق من إعدادات الجوال ثم إعادة المحاولة.'**
  String get reminderNotScheduled;

  /// No description provided for @notificationChannelName.
  ///
  /// In ar, this message translates to:
  /// **'تذكيرات الحياة والمنزل'**
  String get notificationChannelName;

  /// No description provided for @notificationChannelDescription.
  ///
  /// In ar, this message translates to:
  /// **'تذكيرات الأدوية وروتين العناية والمهام التي تضبطها بنفسك'**
  String get notificationChannelDescription;

  /// No description provided for @tasksTitle.
  ///
  /// In ar, this message translates to:
  /// **'🎯 الأهداف والمهام اليومية'**
  String get tasksTitle;

  /// No description provided for @voiceImportTooltip.
  ///
  /// In ar, this message translates to:
  /// **'استيراد مهام من المذكرة الصوتية'**
  String get voiceImportTooltip;

  /// No description provided for @tabDailyTasks.
  ///
  /// In ar, this message translates to:
  /// **'المهام اليومية'**
  String get tabDailyTasks;

  /// No description provided for @tabGoals.
  ///
  /// In ar, this message translates to:
  /// **'الأهداف الهرمية'**
  String get tabGoals;

  /// No description provided for @tabWird.
  ///
  /// In ar, this message translates to:
  /// **'الورد والتتبع'**
  String get tabWird;

  /// No description provided for @taskAddTitle.
  ///
  /// In ar, this message translates to:
  /// **'إضافة مهمة جديدة'**
  String get taskAddTitle;

  /// No description provided for @taskField.
  ///
  /// In ar, this message translates to:
  /// **'المهمة'**
  String get taskField;

  /// No description provided for @taskHint.
  ///
  /// In ar, this message translates to:
  /// **'اكتب نص المهمة...'**
  String get taskHint;

  /// No description provided for @categoryField.
  ///
  /// In ar, this message translates to:
  /// **'التصنيف'**
  String get categoryField;

  /// No description provided for @reminderField.
  ///
  /// In ar, this message translates to:
  /// **'تذكير'**
  String get reminderField;

  /// No description provided for @taskEditTitle.
  ///
  /// In ar, this message translates to:
  /// **'تعديل المهمة'**
  String get taskEditTitle;

  /// No description provided for @taskDeleted.
  ///
  /// In ar, this message translates to:
  /// **'حُذفت «{title}»'**
  String taskDeleted(String title);

  /// No description provided for @addTask.
  ///
  /// In ar, this message translates to:
  /// **'إضافة مهمة'**
  String get addTask;

  /// No description provided for @taskPin.
  ///
  /// In ar, this message translates to:
  /// **'تثبيت المهمة'**
  String get taskPin;

  /// No description provided for @taskUnpin.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء تثبيت المهمة'**
  String get taskUnpin;

  /// No description provided for @taskDelete.
  ///
  /// In ar, this message translates to:
  /// **'حذف المهمة'**
  String get taskDelete;

  /// No description provided for @tasksHeader.
  ///
  /// In ar, this message translates to:
  /// **'مركز إدارة المهام المقسمة'**
  String get tasksHeader;

  /// No description provided for @tasksVoiceTip.
  ///
  /// In ar, this message translates to:
  /// **'اضغط على أيقونة الميكروفون 🎙️ في الأعلى لاستيراد مهام من مذكرتك الصوتية'**
  String get tasksVoiceTip;

  /// No description provided for @tasksEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد مهام بعد. اضغط + لإضافة مهمة أو استخدم المذكرة الصوتية.'**
  String get tasksEmpty;

  /// No description provided for @catPersonal.
  ///
  /// In ar, this message translates to:
  /// **'شخصي'**
  String get catPersonal;

  /// No description provided for @catHome.
  ///
  /// In ar, this message translates to:
  /// **'المنزل'**
  String get catHome;

  /// No description provided for @catWork.
  ///
  /// In ar, this message translates to:
  /// **'العمل'**
  String get catWork;

  /// No description provided for @catFamily.
  ///
  /// In ar, this message translates to:
  /// **'العائلة'**
  String get catFamily;

  /// No description provided for @goalAdd.
  ///
  /// In ar, this message translates to:
  /// **'إضافة هدف'**
  String get goalAdd;

  /// No description provided for @goalField.
  ///
  /// In ar, this message translates to:
  /// **'الهدف'**
  String get goalField;

  /// No description provided for @goalTypeField.
  ///
  /// In ar, this message translates to:
  /// **'النوع'**
  String get goalTypeField;

  /// No description provided for @goalEditTitle.
  ///
  /// In ar, this message translates to:
  /// **'تعديل الهدف'**
  String get goalEditTitle;

  /// No description provided for @goalDeleted.
  ///
  /// In ar, this message translates to:
  /// **'حُذف الهدف «{title}»'**
  String goalDeleted(String title);

  /// No description provided for @goalPin.
  ///
  /// In ar, this message translates to:
  /// **'تثبيت الهدف'**
  String get goalPin;

  /// No description provided for @goalUnpin.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء تثبيت الهدف'**
  String get goalUnpin;

  /// No description provided for @goalDelete.
  ///
  /// In ar, this message translates to:
  /// **'حذف الهدف'**
  String get goalDelete;

  /// No description provided for @goalsHeader.
  ///
  /// In ar, this message translates to:
  /// **'محرك الأهداف الهرمية (السنوية ⬅️ الشهرية ⬅️ الأسبوعية)'**
  String get goalsHeader;

  /// No description provided for @goalsEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد أهداف بعد. اضغط + لإضافة هدفك الأول.'**
  String get goalsEmpty;

  /// No description provided for @goalTypeGeneral.
  ///
  /// In ar, this message translates to:
  /// **'هدف عام'**
  String get goalTypeGeneral;

  /// No description provided for @goalTypeYearly.
  ///
  /// In ar, this message translates to:
  /// **'هدف سنوي'**
  String get goalTypeYearly;

  /// No description provided for @goalTypeMonthly.
  ///
  /// In ar, this message translates to:
  /// **'هدف شهري'**
  String get goalTypeMonthly;

  /// No description provided for @goalTypeWeekly.
  ///
  /// In ar, this message translates to:
  /// **'هدف أسبوعي'**
  String get goalTypeWeekly;

  /// No description provided for @wirdTitle.
  ///
  /// In ar, this message translates to:
  /// **'متتبع الورد اليومي والقرآن الكريم'**
  String get wirdTitle;

  /// No description provided for @wirdCurrentPage.
  ///
  /// In ar, this message translates to:
  /// **'الصفحة الحالية: {page}'**
  String wirdCurrentPage(int page);

  /// No description provided for @wirdFinished.
  ///
  /// In ar, this message translates to:
  /// **'أتممت الختمة 🎉 بارك الله فيك'**
  String get wirdFinished;

  /// No description provided for @wirdRemaining.
  ///
  /// In ar, this message translates to:
  /// **'المتبقي لإتمام الختمة: {count, plural, =1{صفحة واحدة} =2{صفحتان} few{{count} صفحات} many{{count} صفحة} other{{count} صفحة}}'**
  String wirdRemaining(int count);

  /// No description provided for @wirdReadOne.
  ///
  /// In ar, this message translates to:
  /// **'تم قراءة صفحة (+1)'**
  String get wirdReadOne;

  /// No description provided for @wirdSetPage.
  ///
  /// In ar, this message translates to:
  /// **'تحديد الصفحة'**
  String get wirdSetPage;

  /// No description provided for @wirdSetTitle.
  ///
  /// In ar, this message translates to:
  /// **'تحديد الصفحة الحالية'**
  String get wirdSetTitle;

  /// No description provided for @wirdPageField.
  ///
  /// In ar, this message translates to:
  /// **'رقم الصفحة (0 - {max})'**
  String wirdPageField(int max);

  /// No description provided for @wirdPageError.
  ///
  /// In ar, this message translates to:
  /// **'أدخل رقمًا من 0 إلى {max}'**
  String wirdPageError(int max);

  /// No description provided for @voiceTitle.
  ///
  /// In ar, this message translates to:
  /// **'🎙️ استيراد من المذكرة الصوتية'**
  String get voiceTitle;

  /// No description provided for @voicePrompt.
  ///
  /// In ar, this message translates to:
  /// **'اكتب نص المذكرة الصوتية أو ما تريد تحويله لمهام:'**
  String get voicePrompt;

  /// No description provided for @voiceHint.
  ///
  /// In ar, this message translates to:
  /// **'مثال: أريد اليوم إنهاء التقرير، والذهاب للسوق، وترتيب الخزانة...'**
  String get voiceHint;

  /// No description provided for @voiceExtracted.
  ///
  /// In ar, this message translates to:
  /// **'المهام المستخرجة:'**
  String get voiceExtracted;

  /// No description provided for @voiceExtracting.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ الاستخراج...'**
  String get voiceExtracting;

  /// No description provided for @voiceExtract.
  ///
  /// In ar, this message translates to:
  /// **'استخرج المهام 🧠'**
  String get voiceExtract;

  /// No description provided for @voiceImport.
  ///
  /// In ar, this message translates to:
  /// **'استورد المهام للقائمة ✅'**
  String get voiceImport;

  /// No description provided for @voiceImported.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, =0{لم تُستورد أي مهمة} =1{✅ تم استيراد مهمة واحدة بنجاح} =2{✅ تم استيراد مهمتين بنجاح} few{✅ تم استيراد {count} مهام بنجاح} many{✅ تم استيراد {count} مهمة بنجاح} other{✅ تم استيراد {count} مهمة بنجاح}}'**
  String voiceImported(int count);

  /// No description provided for @healthTitle.
  ///
  /// In ar, this message translates to:
  /// **'🏋️ الصحة واللياقة والعناية'**
  String get healthTitle;

  /// No description provided for @awarenessTooltip.
  ///
  /// In ar, this message translates to:
  /// **'وعي الاستخدام'**
  String get awarenessTooltip;

  /// No description provided for @tabExercises.
  ///
  /// In ar, this message translates to:
  /// **'التمارين والعضلات'**
  String get tabExercises;

  /// No description provided for @tabMeds.
  ///
  /// In ar, this message translates to:
  /// **'جدول الأدوية'**
  String get tabMeds;

  /// No description provided for @tabCare.
  ///
  /// In ar, this message translates to:
  /// **'العناية بالبشرة'**
  String get tabCare;

  /// No description provided for @tabMeditation.
  ///
  /// In ar, this message translates to:
  /// **'التأمل'**
  String get tabMeditation;

  /// No description provided for @exerciseDeleted.
  ///
  /// In ar, this message translates to:
  /// **'حُذف «{name}»'**
  String exerciseDeleted(String name);

  /// No description provided for @medAddTitle.
  ///
  /// In ar, this message translates to:
  /// **'إضافة دواء أو مكمل'**
  String get medAddTitle;

  /// No description provided for @nameField.
  ///
  /// In ar, this message translates to:
  /// **'الاسم'**
  String get nameField;

  /// No description provided for @medNameHint.
  ///
  /// In ar, this message translates to:
  /// **'مثال: فيتامين د'**
  String get medNameHint;

  /// No description provided for @timeOptionalField.
  ///
  /// In ar, this message translates to:
  /// **'الوقت (اختياري)'**
  String get timeOptionalField;

  /// No description provided for @medTimeHint.
  ///
  /// In ar, this message translates to:
  /// **'مثال: 09:00 صباحاً'**
  String get medTimeHint;

  /// No description provided for @medEditTitle.
  ///
  /// In ar, this message translates to:
  /// **'تعديل الدواء'**
  String get medEditTitle;

  /// No description provided for @careAddTitle.
  ///
  /// In ar, this message translates to:
  /// **'إضافة منتج للروتين'**
  String get careAddTitle;

  /// No description provided for @productField.
  ///
  /// In ar, this message translates to:
  /// **'المنتج'**
  String get productField;

  /// No description provided for @careProductHint.
  ///
  /// In ar, this message translates to:
  /// **'مثال: مرطب البشرة'**
  String get careProductHint;

  /// No description provided for @timeField.
  ///
  /// In ar, this message translates to:
  /// **'الوقت'**
  String get timeField;

  /// No description provided for @careStepField.
  ///
  /// In ar, this message translates to:
  /// **'طريقة الاستخدام (اختياري)'**
  String get careStepField;

  /// No description provided for @careEditTitle.
  ///
  /// In ar, this message translates to:
  /// **'تعديل المنتج'**
  String get careEditTitle;

  /// No description provided for @careMorning.
  ///
  /// In ar, this message translates to:
  /// **'صباحاً'**
  String get careMorning;

  /// No description provided for @careEvening.
  ///
  /// In ar, this message translates to:
  /// **'مساءً'**
  String get careEvening;

  /// No description provided for @careBoth.
  ///
  /// In ar, this message translates to:
  /// **'صباحاً ومساءً'**
  String get careBoth;

  /// No description provided for @exerciseAnalysisTitle.
  ///
  /// In ar, this message translates to:
  /// **'🏋️ تحليل التمرين والعضلات'**
  String get exerciseAnalysisTitle;

  /// No description provided for @saveAsExercise.
  ///
  /// In ar, this message translates to:
  /// **'حفظ كتمرين'**
  String get saveAsExercise;

  /// No description provided for @medReadTitle.
  ///
  /// In ar, this message translates to:
  /// **'💊 قراءة علبة الدواء'**
  String get medReadTitle;

  /// No description provided for @medLabelNotice.
  ///
  /// In ar, this message translates to:
  /// **'هذه قراءة آلية لما على العلبة وقد تخطئ. يُرجى الرجوع إلى نشرة الدواء أو الصيدلي أو الطبيب قبل تناول أي جرعة.'**
  String get medLabelNotice;

  /// No description provided for @okAction.
  ///
  /// In ar, this message translates to:
  /// **'حسناً'**
  String get okAction;

  /// No description provided for @addExercise.
  ///
  /// In ar, this message translates to:
  /// **'إضافة تمرين'**
  String get addExercise;

  /// No description provided for @addMedication.
  ///
  /// In ar, this message translates to:
  /// **'إضافة دواء'**
  String get addMedication;

  /// No description provided for @addProduct.
  ///
  /// In ar, this message translates to:
  /// **'إضافة منتج'**
  String get addProduct;

  /// No description provided for @healthLoadFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر فتح بياناتك الصحية المحفوظة.'**
  String get healthLoadFailed;

  /// No description provided for @retry.
  ///
  /// In ar, this message translates to:
  /// **'إعادة المحاولة'**
  String get retry;

  /// No description provided for @yourExercises.
  ///
  /// In ar, this message translates to:
  /// **'تمارينك'**
  String get yourExercises;

  /// No description provided for @analyzingImage.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ تحليل الصورة بالذكاء الاصطناعي...'**
  String get analyzingImage;

  /// No description provided for @analyzeExerciseImage.
  ///
  /// In ar, this message translates to:
  /// **'تحليل صورة التمرين بالذكاء الاصطناعي'**
  String get analyzeExerciseImage;

  /// No description provided for @exerciseCardsHeader.
  ///
  /// In ar, this message translates to:
  /// **'بطاقات التمارين بالجولات والتكرارات'**
  String get exerciseCardsHeader;

  /// No description provided for @logLabel.
  ///
  /// In ar, this message translates to:
  /// **'السجل'**
  String get logLabel;

  /// No description provided for @noExercises.
  ///
  /// In ar, this message translates to:
  /// **'لم تُضف تمارين بعد.'**
  String get noExercises;

  /// No description provided for @exercisePin.
  ///
  /// In ar, this message translates to:
  /// **'تثبيت التمرين'**
  String get exercisePin;

  /// No description provided for @exerciseUnpin.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء تثبيت التمرين'**
  String get exerciseUnpin;

  /// No description provided for @exerciseDelete.
  ///
  /// In ar, this message translates to:
  /// **'حذف التمرين'**
  String get exerciseDelete;

  /// No description provided for @medReadHeader.
  ///
  /// In ar, this message translates to:
  /// **'قراءة علبة الدواء بالذكاء الاصطناعي'**
  String get medReadHeader;

  /// No description provided for @medReadBody.
  ///
  /// In ar, this message translates to:
  /// **'صورة لعلبة الدواء أو المكمل، فيُقرأ ما هو مكتوب عليها: الاسم والجرعة المكتوبة والتحذيرات. القراءة الآلية قد تخطئ، والمرجع نشرة الدواء أو الصيدلي.'**
  String get medReadBody;

  /// No description provided for @analyzingMed.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ تحليل علبة الدواء...'**
  String get analyzingMed;

  /// No description provided for @analyzeMed.
  ///
  /// In ar, this message translates to:
  /// **'تحليل علبة الدواء 💊'**
  String get analyzeMed;

  /// No description provided for @medsHeader.
  ///
  /// In ar, this message translates to:
  /// **'توقيتات الأدوية والمكملات اليومية'**
  String get medsHeader;

  /// No description provided for @noMeds.
  ///
  /// In ar, this message translates to:
  /// **'لم تُضف أدوية أو مكملات بعد. اضغط + للإضافة.'**
  String get noMeds;

  /// No description provided for @medDelete.
  ///
  /// In ar, this message translates to:
  /// **'حذف الدواء'**
  String get medDelete;

  /// No description provided for @careHeader.
  ///
  /// In ar, this message translates to:
  /// **'سجل منتجات الروتين اليومي للبشرة والشعر'**
  String get careHeader;

  /// No description provided for @noCare.
  ///
  /// In ar, this message translates to:
  /// **'لم تُضف منتجات بعد. اضغط + للإضافة.'**
  String get noCare;

  /// No description provided for @careDelete.
  ///
  /// In ar, this message translates to:
  /// **'حذف المنتج'**
  String get careDelete;

  /// No description provided for @workoutLogTitle.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل تمرين اليوم'**
  String get workoutLogTitle;

  /// No description provided for @logAction.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل'**
  String get logAction;

  /// No description provided for @setsField.
  ///
  /// In ar, this message translates to:
  /// **'المجموعات'**
  String get setsField;

  /// No description provided for @setsError.
  ///
  /// In ar, this message translates to:
  /// **'أدخل رقمًا من 1 إلى {max}'**
  String setsError(int max);

  /// No description provided for @repsField.
  ///
  /// In ar, this message translates to:
  /// **'التكرار'**
  String get repsField;

  /// No description provided for @weightField.
  ///
  /// In ar, this message translates to:
  /// **'الوزن (اختياري)'**
  String get weightField;

  /// No description provided for @weightHint.
  ///
  /// In ar, this message translates to:
  /// **'مثال: 40 كجم'**
  String get weightHint;

  /// No description provided for @noteOptionalField.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظة (اختياري)'**
  String get noteOptionalField;

  /// No description provided for @workoutLogged.
  ///
  /// In ar, this message translates to:
  /// **'سُجّل تمرين اليوم'**
  String get workoutLogged;

  /// No description provided for @exerciseDeleteAsk.
  ///
  /// In ar, this message translates to:
  /// **'حذف التمرين؟'**
  String get exerciseDeleteAsk;

  /// No description provided for @exerciseDeleteBody.
  ///
  /// In ar, this message translates to:
  /// **'سيُحذف «{name}» وصورته. سجل تمارينك السابق يبقى.'**
  String exerciseDeleteBody(String name);

  /// No description provided for @deleteAction.
  ///
  /// In ar, this message translates to:
  /// **'حذف'**
  String get deleteAction;

  /// No description provided for @exerciseEdit.
  ///
  /// In ar, this message translates to:
  /// **'تعديل التمرين'**
  String get exerciseEdit;

  /// No description provided for @setsRepsLine.
  ///
  /// In ar, this message translates to:
  /// **'المجموعات والتكرار: {value}'**
  String setsRepsLine(String value);

  /// No description provided for @logToday.
  ///
  /// In ar, this message translates to:
  /// **'سجّل اليوم'**
  String get logToday;

  /// No description provided for @exerciseLogOf.
  ///
  /// In ar, this message translates to:
  /// **'سجل «{name}»'**
  String exerciseLogOf(String name);

  /// No description provided for @latestLogs.
  ///
  /// In ar, this message translates to:
  /// **'آخر التسجيلات'**
  String get latestLogs;

  /// No description provided for @stepsHeader.
  ///
  /// In ar, this message translates to:
  /// **'خطوات الأداء'**
  String get stepsHeader;

  /// No description provided for @notesHeader.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظات'**
  String get notesHeader;

  /// No description provided for @exerciseNameField.
  ///
  /// In ar, this message translates to:
  /// **'اسم التمرين'**
  String get exerciseNameField;

  /// No description provided for @musclesField.
  ///
  /// In ar, this message translates to:
  /// **'العضلات المستهدفة'**
  String get musclesField;

  /// No description provided for @setsLess.
  ///
  /// In ar, this message translates to:
  /// **'تقليل المجموعات'**
  String get setsLess;

  /// No description provided for @setsMore.
  ///
  /// In ar, this message translates to:
  /// **'زيادة المجموعات'**
  String get setsMore;

  /// No description provided for @repsHint.
  ///
  /// In ar, this message translates to:
  /// **'10 أو 8-12'**
  String get repsHint;

  /// No description provided for @addStep.
  ///
  /// In ar, this message translates to:
  /// **'إضافة خطوة'**
  String get addStep;

  /// No description provided for @notesOptional.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظات (اختياري)'**
  String get notesOptional;

  /// No description provided for @addImage.
  ///
  /// In ar, this message translates to:
  /// **'إضافة صورة'**
  String get addImage;

  /// No description provided for @changeImage.
  ///
  /// In ar, this message translates to:
  /// **'تغيير الصورة'**
  String get changeImage;

  /// No description provided for @removeImage.
  ///
  /// In ar, this message translates to:
  /// **'إزالة الصورة'**
  String get removeImage;

  /// No description provided for @deleteStep.
  ///
  /// In ar, this message translates to:
  /// **'حذف الخطوة'**
  String get deleteStep;

  /// No description provided for @workoutLogDefaultTitle.
  ///
  /// In ar, this message translates to:
  /// **'سجل التمارين'**
  String get workoutLogDefaultTitle;

  /// No description provided for @workoutEntryDeleted.
  ///
  /// In ar, this message translates to:
  /// **'حُذف التسجيل'**
  String get workoutEntryDeleted;

  /// No description provided for @noWorkouts.
  ///
  /// In ar, this message translates to:
  /// **'لم تُسجَّل تمارين بعد. افتح تمرينًا واضغط «سجّل اليوم».'**
  String get noWorkouts;

  /// No description provided for @exerciseFallbackName.
  ///
  /// In ar, this message translates to:
  /// **'تمرين'**
  String get exerciseFallbackName;

  /// No description provided for @workoutEntryDelete.
  ///
  /// In ar, this message translates to:
  /// **'حذف التسجيل'**
  String get workoutEntryDelete;

  /// No description provided for @imageSourceTitle.
  ///
  /// In ar, this message translates to:
  /// **'اختيار مصدر الصورة'**
  String get imageSourceTitle;

  /// No description provided for @camera.
  ///
  /// In ar, this message translates to:
  /// **'الكاميرا'**
  String get camera;

  /// No description provided for @gallery.
  ///
  /// In ar, this message translates to:
  /// **'المعرض'**
  String get gallery;

  /// No description provided for @draftExercise.
  ///
  /// In ar, this message translates to:
  /// **'التمرين: {name}'**
  String draftExercise(String name);

  /// No description provided for @draftMuscles.
  ///
  /// In ar, this message translates to:
  /// **'العضلات: {muscles}'**
  String draftMuscles(String muscles);

  /// No description provided for @draftSteps.
  ///
  /// In ar, this message translates to:
  /// **'الخطوات:'**
  String get draftSteps;

  /// No description provided for @draftNotes.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظات: {notes}'**
  String draftNotes(String notes);

  /// No description provided for @meditationGammaNotice.
  ///
  /// In ar, this message translates to:
  /// **'نغمة جاما للاستماع أثناء التأمل، بمستوى صوت منخفض. لا تُستعمل أثناء القيادة أو تشغيل الآلات. من لديه صرع أو جهاز طبي مزروع يستشير الطبيب قبل الاستعمال. النوع المزدوج يحتاج سماعات.'**
  String get meditationGammaNotice;

  /// No description provided for @meditationActiveNotice.
  ///
  /// In ar, this message translates to:
  /// **'الحركة بلطف، في مكان واسع وآمن، والتوقف عند الدوخة أو الألم. من لديه حالة قلبية أو حمل أو إصابة يستشير الطبيب قبل هذه الجلسة.'**
  String get meditationActiveNotice;

  /// No description provided for @meditationAiVoiceNotice.
  ///
  /// In ar, this message translates to:
  /// **'صوت المرشد مولَّد بالذكاء الاصطناعي.'**
  String get meditationAiVoiceNotice;

  /// No description provided for @noticeBeforeStart.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظة قبل البدء'**
  String get noticeBeforeStart;

  /// No description provided for @understoodStart.
  ///
  /// In ar, this message translates to:
  /// **'فهمت، ابدأ'**
  String get understoodStart;

  /// No description provided for @meditationLoadFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر فتح جلسات التأمل. إعادة المحاولة'**
  String get meditationLoadFailed;

  /// No description provided for @meditationWeekMinutes.
  ///
  /// In ar, this message translates to:
  /// **'دقائق التأمل في آخر 7 أيام: {count}'**
  String meditationWeekMinutes(int count);

  /// No description provided for @meditationScreenOffTip.
  ///
  /// In ar, this message translates to:
  /// **'الصوت يستمر والشاشة مطفأة، ويمكن الإيقاف من الإشعار.'**
  String get meditationScreenOffTip;

  /// No description provided for @withSubscription.
  ///
  /// In ar, this message translates to:
  /// **'مع الاشتراك'**
  String get withSubscription;

  /// No description provided for @toneNone.
  ///
  /// In ar, this message translates to:
  /// **'بلا نغمة'**
  String get toneNone;

  /// No description provided for @toneBinauralShort.
  ///
  /// In ar, this message translates to:
  /// **'جاما مزدوجة (سماعات)'**
  String get toneBinauralShort;

  /// No description provided for @toneIsochronicShort.
  ///
  /// In ar, this message translates to:
  /// **'جاما نبضية'**
  String get toneIsochronicShort;

  /// No description provided for @toneBinaural.
  ///
  /// In ar, this message translates to:
  /// **'مزدوجة (سماعات)'**
  String get toneBinaural;

  /// No description provided for @toneIsochronic.
  ///
  /// In ar, this message translates to:
  /// **'نبضية (بلا سماعات)'**
  String get toneIsochronic;

  /// No description provided for @durationLabel.
  ///
  /// In ar, this message translates to:
  /// **'المدة'**
  String get durationLabel;

  /// No description provided for @backgroundSound.
  ///
  /// In ar, this message translates to:
  /// **'الصوت في الخلفية'**
  String get backgroundSound;

  /// No description provided for @startSession.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ الجلسة'**
  String get startSession;

  /// No description provided for @minutesShort.
  ///
  /// In ar, this message translates to:
  /// **'{count} د'**
  String minutesShort(int count);

  /// No description provided for @minutesCount.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, =1{دقيقة واحدة} =2{دقيقتان} few{{count} دقائق} other{{count} دقيقة}}'**
  String minutesCount(int count);

  /// No description provided for @minutesRange.
  ///
  /// In ar, this message translates to:
  /// **'من {from} إلى {to} {to, plural, few{دقائق} other{دقيقة}}'**
  String minutesRange(int from, int to);

  /// No description provided for @soundFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر تشغيل الصوت. حاول مرة أخرى.'**
  String get soundFailed;

  /// No description provided for @endSessionAsk.
  ///
  /// In ar, this message translates to:
  /// **'إنهاء الجلسة؟'**
  String get endSessionAsk;

  /// No description provided for @endSessionBody.
  ///
  /// In ar, this message translates to:
  /// **'تُحفظ الدقائق التي مضت إن كانت دقيقة أو أكثر.'**
  String get endSessionBody;

  /// No description provided for @continueSession.
  ///
  /// In ar, this message translates to:
  /// **'متابعة الجلسة'**
  String get continueSession;

  /// No description provided for @endAction.
  ///
  /// In ar, this message translates to:
  /// **'إنهاء'**
  String get endAction;

  /// No description provided for @phaseOf.
  ///
  /// In ar, this message translates to:
  /// **'المرحلة {current} من {total}'**
  String phaseOf(int current, int total);

  /// No description provided for @timeLeft.
  ///
  /// In ar, this message translates to:
  /// **'الوقت المتبقي'**
  String get timeLeft;

  /// No description provided for @gammaLevel.
  ///
  /// In ar, this message translates to:
  /// **'مستوى نغمة جاما'**
  String get gammaLevel;

  /// No description provided for @pauseAction.
  ///
  /// In ar, this message translates to:
  /// **'إيقاف مؤقت'**
  String get pauseAction;

  /// No description provided for @resumeAction.
  ///
  /// In ar, this message translates to:
  /// **'متابعة'**
  String get resumeAction;

  /// No description provided for @sessionFinished.
  ///
  /// In ar, this message translates to:
  /// **'انتهت الجلسة'**
  String get sessionFinished;

  /// No description provided for @sessionMinutes.
  ///
  /// In ar, this message translates to:
  /// **'دقائق هذه الجلسة: {count}'**
  String sessionMinutes(int count);

  /// No description provided for @sessionUnderMinute.
  ///
  /// In ar, this message translates to:
  /// **'الجلسات الأقصر من دقيقة لا تُحفظ في السجل.'**
  String get sessionUnderMinute;

  /// No description provided for @meditationChannelName.
  ///
  /// In ar, this message translates to:
  /// **'جلسات التأمل'**
  String get meditationChannelName;

  /// No description provided for @kitchenTitle.
  ///
  /// In ar, this message translates to:
  /// **'🥗 المطبخ والمؤونة والغسيل'**
  String get kitchenTitle;

  /// No description provided for @tabRecipes.
  ///
  /// In ar, this message translates to:
  /// **'الوصفات والوجبات'**
  String get tabRecipes;

  /// No description provided for @tabPantry.
  ///
  /// In ar, this message translates to:
  /// **'المؤونة والمستلزمات'**
  String get tabPantry;

  /// No description provided for @tabShopping.
  ///
  /// In ar, this message translates to:
  /// **'المشتريات'**
  String get tabShopping;

  /// No description provided for @tabLaundry.
  ///
  /// In ar, this message translates to:
  /// **'جدول الغسيل'**
  String get tabLaundry;

  /// No description provided for @addRecipe.
  ///
  /// In ar, this message translates to:
  /// **'إضافة وصفة'**
  String get addRecipe;

  /// No description provided for @addPantryItem.
  ///
  /// In ar, this message translates to:
  /// **'إضافة صنف'**
  String get addPantryItem;

  /// No description provided for @addShoppingItem.
  ///
  /// In ar, this message translates to:
  /// **'إضافة بند للمشتريات'**
  String get addShoppingItem;

  /// No description provided for @addLaundry.
  ///
  /// In ar, this message translates to:
  /// **'إضافة موعد غسيل'**
  String get addLaundry;

  /// No description provided for @recipeBreakfast.
  ///
  /// In ar, this message translates to:
  /// **'فطور'**
  String get recipeBreakfast;

  /// No description provided for @recipeLunch.
  ///
  /// In ar, this message translates to:
  /// **'غداء'**
  String get recipeLunch;

  /// No description provided for @recipeDinner.
  ///
  /// In ar, this message translates to:
  /// **'عشاء'**
  String get recipeDinner;

  /// No description provided for @recipeSnack.
  ///
  /// In ar, this message translates to:
  /// **'وجبة خفيفة'**
  String get recipeSnack;

  /// No description provided for @recipeDessert.
  ///
  /// In ar, this message translates to:
  /// **'حلويات'**
  String get recipeDessert;

  /// No description provided for @recipeAi.
  ///
  /// In ar, this message translates to:
  /// **'ذكاء اصطناعي'**
  String get recipeAi;

  /// No description provided for @otherCategory.
  ///
  /// In ar, this message translates to:
  /// **'أخرى'**
  String get otherCategory;

  /// No description provided for @pantryOils.
  ///
  /// In ar, this message translates to:
  /// **'الزيوت والبهارات'**
  String get pantryOils;

  /// No description provided for @pantryGrains.
  ///
  /// In ar, this message translates to:
  /// **'الحبوب والبقوليات'**
  String get pantryGrains;

  /// No description provided for @pantryProduce.
  ///
  /// In ar, this message translates to:
  /// **'الخضار والفواكه'**
  String get pantryProduce;

  /// No description provided for @pantryDairyMeat.
  ///
  /// In ar, this message translates to:
  /// **'الألبان واللحوم'**
  String get pantryDairyMeat;

  /// No description provided for @pantryNuts.
  ///
  /// In ar, this message translates to:
  /// **'المكسرات'**
  String get pantryNuts;

  /// No description provided for @pantryCleaning.
  ///
  /// In ar, this message translates to:
  /// **'مستلزمات التنظيف'**
  String get pantryCleaning;

  /// No description provided for @daySat.
  ///
  /// In ar, this message translates to:
  /// **'السبت'**
  String get daySat;

  /// No description provided for @daySun.
  ///
  /// In ar, this message translates to:
  /// **'الأحد'**
  String get daySun;

  /// No description provided for @dayMon.
  ///
  /// In ar, this message translates to:
  /// **'الاثنين'**
  String get dayMon;

  /// No description provided for @dayTue.
  ///
  /// In ar, this message translates to:
  /// **'الثلاثاء'**
  String get dayTue;

  /// No description provided for @dayWed.
  ///
  /// In ar, this message translates to:
  /// **'الأربعاء'**
  String get dayWed;

  /// No description provided for @dayThu.
  ///
  /// In ar, this message translates to:
  /// **'الخميس'**
  String get dayThu;

  /// No description provided for @dayFri.
  ///
  /// In ar, this message translates to:
  /// **'الجمعة'**
  String get dayFri;

  /// No description provided for @sourceOutOfStock.
  ///
  /// In ar, this message translates to:
  /// **'نفد من المؤونة'**
  String get sourceOutOfStock;

  /// No description provided for @recipeNeedIngredients.
  ///
  /// In ar, this message translates to:
  /// **'⚠️ يرجى كتابة المكونات أولاً'**
  String get recipeNeedIngredients;

  /// No description provided for @recipeSuggested.
  ///
  /// In ar, this message translates to:
  /// **'وصفة مقترحة 🍽️'**
  String get recipeSuggested;

  /// No description provided for @saveToRecipes.
  ///
  /// In ar, this message translates to:
  /// **'حفظ في الوصفات'**
  String get saveToRecipes;

  /// No description provided for @aiRecipeFallbackTitle.
  ///
  /// In ar, this message translates to:
  /// **'وصفة ذكية: {first}'**
  String aiRecipeFallbackTitle(String first);

  /// No description provided for @recipeAdded.
  ///
  /// In ar, this message translates to:
  /// **'✅ تمت إضافة الوصفة'**
  String get recipeAdded;

  /// No description provided for @recipeDeleted.
  ///
  /// In ar, this message translates to:
  /// **'حُذفت «{title}»'**
  String recipeDeleted(String title);

  /// No description provided for @recipesHeader.
  ///
  /// In ar, this message translates to:
  /// **'موسوعة الوصفات وتفاصيل المقادير'**
  String get recipesHeader;

  /// No description provided for @recipesEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد وصفات بعد. اضغط + لإضافة وصفة، أو دع الذكاء الاصطناعي يقترح لك.'**
  String get recipesEmpty;

  /// No description provided for @servingsCount.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, =1{حصة واحدة} =2{حصتان} few{{count} حصص} other{{count} حصة}}'**
  String servingsCount(int count);

  /// No description provided for @ingredientsCount.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, =1{مكوّن واحد} =2{مكوّنان} few{{count} مكوّنات} other{{count} مكوّن}}'**
  String ingredientsCount(int count);

  /// No description provided for @stepsCount.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, =1{خطوة واحدة} =2{خطوتان} few{{count} خطوات} other{{count} خطوة}}'**
  String stepsCount(int count);

  /// No description provided for @recipePin.
  ///
  /// In ar, this message translates to:
  /// **'تثبيت الوصفة'**
  String get recipePin;

  /// No description provided for @recipeUnpin.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء تثبيت الوصفة'**
  String get recipeUnpin;

  /// No description provided for @recipeDelete.
  ///
  /// In ar, this message translates to:
  /// **'حذف الوصفة'**
  String get recipeDelete;

  /// No description provided for @ingredientsLine.
  ///
  /// In ar, this message translates to:
  /// **'المقادير: {text}'**
  String ingredientsLine(String text);

  /// No description provided for @aiRecipeTitle.
  ///
  /// In ar, this message translates to:
  /// **'🧑‍🍳 توليد وصفة بالذكاء الاصطناعي'**
  String get aiRecipeTitle;

  /// No description provided for @aiRecipePrompt.
  ///
  /// In ar, this message translates to:
  /// **'اكتب المكونات المتاحة في مطبخك (مفصولة بفواصل):'**
  String get aiRecipePrompt;

  /// No description provided for @aiRecipeHint.
  ///
  /// In ar, this message translates to:
  /// **'مثال: دجاج، أرز، طماطم، بصل، بهارات...'**
  String get aiRecipeHint;

  /// No description provided for @aiRecipeWorking.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ توليد الوصفة...'**
  String get aiRecipeWorking;

  /// No description provided for @aiRecipeSuggest.
  ///
  /// In ar, this message translates to:
  /// **'اقترح وصفة الآن ✨'**
  String get aiRecipeSuggest;

  /// No description provided for @pantryAddTitle.
  ///
  /// In ar, this message translates to:
  /// **'إضافة صنف للمؤونة'**
  String get pantryAddTitle;

  /// No description provided for @itemField.
  ///
  /// In ar, this message translates to:
  /// **'الصنف'**
  String get itemField;

  /// No description provided for @qtyOptionalField.
  ///
  /// In ar, this message translates to:
  /// **'الكمية (اختياري)'**
  String get qtyOptionalField;

  /// No description provided for @pantryQtyHint.
  ///
  /// In ar, this message translates to:
  /// **'مثال: 2 لتر'**
  String get pantryQtyHint;

  /// No description provided for @pantryEditTitle.
  ///
  /// In ar, this message translates to:
  /// **'تعديل الصنف'**
  String get pantryEditTitle;

  /// No description provided for @itemDeleted.
  ///
  /// In ar, this message translates to:
  /// **'حُذف «{name}»'**
  String itemDeleted(String name);

  /// No description provided for @movedToShopping.
  ///
  /// In ar, this message translates to:
  /// **'نُقل «{name}» إلى المشتريات'**
  String movedToShopping(String name);

  /// No description provided for @pantryHeader.
  ///
  /// In ar, this message translates to:
  /// **'مخزون المطبخ واحتياجات المنزل'**
  String get pantryHeader;

  /// No description provided for @pantryEmpty.
  ///
  /// In ar, this message translates to:
  /// **'المؤونة فارغة. اضغط + لإضافة أول صنف.'**
  String get pantryEmpty;

  /// No description provided for @pantrySearchHint.
  ///
  /// In ar, this message translates to:
  /// **'بحث في المؤونة والمستلزمات'**
  String get pantrySearchHint;

  /// No description provided for @clearSearch.
  ///
  /// In ar, this message translates to:
  /// **'مسح البحث'**
  String get clearSearch;

  /// No description provided for @filterAll.
  ///
  /// In ar, this message translates to:
  /// **'الكل'**
  String get filterAll;

  /// No description provided for @noSearchResults.
  ///
  /// In ar, this message translates to:
  /// **'لا نتائج مطابقة للبحث.'**
  String get noSearchResults;

  /// No description provided for @pinnedSection.
  ///
  /// In ar, this message translates to:
  /// **'📌 المثبّتة'**
  String get pinnedSection;

  /// No description provided for @qtyLess.
  ///
  /// In ar, this message translates to:
  /// **'نقصان الكمية'**
  String get qtyLess;

  /// No description provided for @qtyMore.
  ///
  /// In ar, this message translates to:
  /// **'زيادة الكمية'**
  String get qtyMore;

  /// No description provided for @moreActions.
  ///
  /// In ar, this message translates to:
  /// **'المزيد'**
  String get moreActions;

  /// No description provided for @editAction.
  ///
  /// In ar, this message translates to:
  /// **'تعديل'**
  String get editAction;

  /// No description provided for @pinAction.
  ///
  /// In ar, this message translates to:
  /// **'تثبيت'**
  String get pinAction;

  /// No description provided for @unpinAction.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء التثبيت'**
  String get unpinAction;

  /// No description provided for @outToShopping.
  ///
  /// In ar, this message translates to:
  /// **'نفد: إلى المشتريات'**
  String get outToShopping;

  /// No description provided for @shoppingAddTitle.
  ///
  /// In ar, this message translates to:
  /// **'إضافة بند للمشتريات'**
  String get shoppingAddTitle;

  /// No description provided for @shoppingItemField.
  ///
  /// In ar, this message translates to:
  /// **'البند'**
  String get shoppingItemField;

  /// No description provided for @shoppingQtyHint.
  ///
  /// In ar, this message translates to:
  /// **'مثال: 2 كجم'**
  String get shoppingQtyHint;

  /// No description provided for @shoppingEditTitle.
  ///
  /// In ar, this message translates to:
  /// **'تعديل البند'**
  String get shoppingEditTitle;

  /// No description provided for @shoppingHeader.
  ///
  /// In ar, this message translates to:
  /// **'قائمة المشتريات'**
  String get shoppingHeader;

  /// No description provided for @shoppingEmpty.
  ///
  /// In ar, this message translates to:
  /// **'قائمة المشتريات فارغة. اضغط + لإضافة بند، أو أضف مقادير وصفة من صفحتها.'**
  String get shoppingEmpty;

  /// No description provided for @movedToPantry.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, =1{نُقل بند واحد إلى المؤونة} =2{نُقل بندان إلى المؤونة} few{نُقلت {count} بنود إلى المؤونة} many{نُقل {count} بندًا إلى المؤونة} other{نُقل {count} بند إلى المؤونة}}'**
  String movedToPantry(int count);

  /// No description provided for @moveBoughtToPantry.
  ///
  /// In ar, this message translates to:
  /// **'نقل المشتراة إلى المؤونة'**
  String get moveBoughtToPantry;

  /// No description provided for @clearBought.
  ///
  /// In ar, this message translates to:
  /// **'مسح المشتراة'**
  String get clearBought;

  /// No description provided for @shoppingFrom.
  ///
  /// In ar, this message translates to:
  /// **'من: {source}'**
  String shoppingFrom(String source);

  /// No description provided for @shoppingDelete.
  ///
  /// In ar, this message translates to:
  /// **'حذف البند'**
  String get shoppingDelete;

  /// No description provided for @laundryAddTitle.
  ///
  /// In ar, this message translates to:
  /// **'إضافة موعد غسيل'**
  String get laundryAddTitle;

  /// No description provided for @dayField.
  ///
  /// In ar, this message translates to:
  /// **'اليوم'**
  String get dayField;

  /// No description provided for @laundryTypeField.
  ///
  /// In ar, this message translates to:
  /// **'نوع الغسيل'**
  String get laundryTypeField;

  /// No description provided for @laundryTypeHint.
  ///
  /// In ar, this message translates to:
  /// **'مثال: الملابس الملونة'**
  String get laundryTypeHint;

  /// No description provided for @instructionsOptional.
  ///
  /// In ar, this message translates to:
  /// **'التعليمات (اختياري)'**
  String get instructionsOptional;

  /// No description provided for @laundryEditTitle.
  ///
  /// In ar, this message translates to:
  /// **'تعديل موعد الغسيل'**
  String get laundryEditTitle;

  /// No description provided for @laundryDeleted.
  ///
  /// In ar, this message translates to:
  /// **'حُذف موعد «{type}»'**
  String laundryDeleted(String type);

  /// No description provided for @laundryHeader.
  ///
  /// In ar, this message translates to:
  /// **'جدول العناية بالأقمشة والغسيل الأسبوعي'**
  String get laundryHeader;

  /// No description provided for @laundryEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد مواعيد غسيل بعد. اضغط + لإضافة موعد.'**
  String get laundryEmpty;

  /// No description provided for @instructionsLine.
  ///
  /// In ar, this message translates to:
  /// **'التعليمات: {text}'**
  String instructionsLine(String text);

  /// No description provided for @laundryDelete.
  ///
  /// In ar, this message translates to:
  /// **'حذف الموعد'**
  String get laundryDelete;

  /// No description provided for @recipeDeleteAsk.
  ///
  /// In ar, this message translates to:
  /// **'حذف الوصفة؟'**
  String get recipeDeleteAsk;

  /// No description provided for @recipeDeleteBody.
  ///
  /// In ar, this message translates to:
  /// **'ستُحذف «{title}» من وصفاتك.'**
  String recipeDeleteBody(String title);

  /// No description provided for @addedToShopping.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, =1{أُضيف بند واحد إلى المشتريات} =2{أُضيف بندان إلى المشتريات} few{أُضيفت {count} بنود إلى المشتريات} many{أُضيف {count} بندًا إلى المشتريات} other{أُضيف {count} بند إلى المشتريات}}'**
  String addedToShopping(int count);

  /// No description provided for @alreadyInList.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, =1{بند واحد موجود في القائمة أصلًا} =2{بندان موجودان في القائمة أصلًا} few{{count} بنود موجودة في القائمة أصلًا} many{{count} بندًا موجودًا في القائمة أصلًا} other{{count} بند موجود في القائمة أصلًا}}'**
  String alreadyInList(int count);

  /// No description provided for @recipeEdit.
  ///
  /// In ar, this message translates to:
  /// **'تعديل الوصفة'**
  String get recipeEdit;

  /// No description provided for @ingredientsHeader.
  ///
  /// In ar, this message translates to:
  /// **'المقادير'**
  String get ingredientsHeader;

  /// No description provided for @noIngredients.
  ///
  /// In ar, this message translates to:
  /// **'لم تُضف مقادير بعد.'**
  String get noIngredients;

  /// No description provided for @addIngredientsToShopping.
  ///
  /// In ar, this message translates to:
  /// **'أضف المقادير إلى المشتريات'**
  String get addIngredientsToShopping;

  /// No description provided for @prepSteps.
  ///
  /// In ar, this message translates to:
  /// **'خطوات التحضير'**
  String get prepSteps;

  /// No description provided for @servingsScaled.
  ///
  /// In ar, this message translates to:
  /// **'{servings, plural, =1{حصة واحدة} =2{حصتان} few{{servings} حصص} other{{servings} حصة}} (الأصل {original})'**
  String servingsScaled(int servings, int original);

  /// No description provided for @servingsLess.
  ///
  /// In ar, this message translates to:
  /// **'تقليل الحصص'**
  String get servingsLess;

  /// No description provided for @servingsMore.
  ///
  /// In ar, this message translates to:
  /// **'زيادة الحصص'**
  String get servingsMore;

  /// No description provided for @whatToShopping.
  ///
  /// In ar, this message translates to:
  /// **'ما الذي تريد إضافته للمشتريات؟'**
  String get whatToShopping;

  /// No description provided for @inPantry.
  ///
  /// In ar, this message translates to:
  /// **'موجود في المؤونة'**
  String get inPantry;

  /// No description provided for @addCount.
  ///
  /// In ar, this message translates to:
  /// **'إضافة ({count})'**
  String addCount(int count);

  /// No description provided for @ingredientNameRequired.
  ///
  /// In ar, this message translates to:
  /// **'اسم المكوّن مطلوب'**
  String get ingredientNameRequired;

  /// No description provided for @invalidAmount.
  ///
  /// In ar, this message translates to:
  /// **'كمية غير صالحة'**
  String get invalidAmount;

  /// No description provided for @mealNameField.
  ///
  /// In ar, this message translates to:
  /// **'اسم الوجبة'**
  String get mealNameField;

  /// No description provided for @servingsField.
  ///
  /// In ar, this message translates to:
  /// **'عدد الحصص'**
  String get servingsField;

  /// No description provided for @freeTextIngredients.
  ///
  /// In ar, this message translates to:
  /// **'مقادير مكتوبة كنص حر:'**
  String get freeTextIngredients;

  /// No description provided for @convertIngredients.
  ///
  /// In ar, this message translates to:
  /// **'تحويل إلى مقادير منظّمة'**
  String get convertIngredients;

  /// No description provided for @addIngredient.
  ///
  /// In ar, this message translates to:
  /// **'إضافة مكوّن'**
  String get addIngredient;

  /// No description provided for @ingredientField.
  ///
  /// In ar, this message translates to:
  /// **'المكوّن'**
  String get ingredientField;

  /// No description provided for @amountField.
  ///
  /// In ar, this message translates to:
  /// **'الكمية'**
  String get amountField;

  /// No description provided for @unitField.
  ///
  /// In ar, this message translates to:
  /// **'الوحدة'**
  String get unitField;

  /// No description provided for @unitHint.
  ///
  /// In ar, this message translates to:
  /// **'كوب'**
  String get unitHint;

  /// No description provided for @deleteIngredient.
  ///
  /// In ar, this message translates to:
  /// **'حذف المكوّن'**
  String get deleteIngredient;

  /// No description provided for @stepNumber.
  ///
  /// In ar, this message translates to:
  /// **'الخطوة {number}'**
  String stepNumber(int number);

  /// No description provided for @recipeTypeField.
  ///
  /// In ar, this message translates to:
  /// **'النوع'**
  String get recipeTypeField;

  /// No description provided for @expenseFood.
  ///
  /// In ar, this message translates to:
  /// **'طعام'**
  String get expenseFood;

  /// No description provided for @expenseTransport.
  ///
  /// In ar, this message translates to:
  /// **'مواصلات'**
  String get expenseTransport;

  /// No description provided for @expenseEntertainment.
  ///
  /// In ar, this message translates to:
  /// **'ترفيه'**
  String get expenseEntertainment;

  /// No description provided for @expenseBills.
  ///
  /// In ar, this message translates to:
  /// **'فواتير'**
  String get expenseBills;

  /// No description provided for @expenseShopping.
  ///
  /// In ar, this message translates to:
  /// **'تسوق'**
  String get expenseShopping;

  /// No description provided for @percentSign.
  ///
  /// In ar, this message translates to:
  /// **'٪'**
  String get percentSign;

  /// No description provided for @listSeparator.
  ///
  /// In ar, this message translates to:
  /// **'، '**
  String get listSeparator;

  /// No description provided for @planSaved.
  ///
  /// In ar, this message translates to:
  /// **'حُفظت خطة الميزانية'**
  String get planSaved;

  /// No description provided for @limitsSaved.
  ///
  /// In ar, this message translates to:
  /// **'حُفظت الحدود. عدّلها من «تعديل الخطة»'**
  String get limitsSaved;

  /// No description provided for @budgetTitle.
  ///
  /// In ar, this message translates to:
  /// **'💰 المحفظة المالية والميزانية'**
  String get budgetTitle;

  /// No description provided for @monthlyExpenses.
  ///
  /// In ar, this message translates to:
  /// **'مصاريفي الشهرية'**
  String get monthlyExpenses;

  /// No description provided for @budgetOpenFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر فتح بيانات الميزانية'**
  String get budgetOpenFailed;

  /// No description provided for @setupBudgetTitle.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ بإعداد ميزانيتك'**
  String get setupBudgetTitle;

  /// No description provided for @setupBudgetBody.
  ///
  /// In ar, this message translates to:
  /// **'أدخل دخلك الشهري ويوم نزول الراتب ومصروفاتك الثابتة، وسنحسب لك كم يبقى لك وكم تصرف يوميًا. تُحفظ كل بياناتك على جهازك مشفّرة.'**
  String get setupBudgetBody;

  /// No description provided for @setupBudgetButton.
  ///
  /// In ar, this message translates to:
  /// **'إعداد الميزانية'**
  String get setupBudgetButton;

  /// No description provided for @currentCycleBudget.
  ///
  /// In ar, this message translates to:
  /// **'ميزانية الدورة الحالية'**
  String get currentCycleBudget;

  /// No description provided for @daysLeft.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, =1{باقي يوم واحد} =2{باقي يومان} few{باقي {count} أيام} many{باقي {count} يومًا} other{باقي {count} يوم}}'**
  String daysLeft(int count);

  /// No description provided for @cycleRange.
  ///
  /// In ar, this message translates to:
  /// **'من {start} إلى {end}'**
  String cycleRange(String start, String end);

  /// No description provided for @remainingLabel.
  ///
  /// In ar, this message translates to:
  /// **'المتبقي'**
  String get remainingLabel;

  /// No description provided for @spentPercent.
  ///
  /// In ar, this message translates to:
  /// **'صرفت {percent}٪ من المتاح'**
  String spentPercent(int percent);

  /// No description provided for @incomeLabel.
  ///
  /// In ar, this message translates to:
  /// **'الدخل'**
  String get incomeLabel;

  /// No description provided for @fixedExpenses.
  ///
  /// In ar, this message translates to:
  /// **'المصروفات الثابتة'**
  String get fixedExpenses;

  /// No description provided for @savingsLabel.
  ///
  /// In ar, this message translates to:
  /// **'الادخار'**
  String get savingsLabel;

  /// No description provided for @availableToSpend.
  ///
  /// In ar, this message translates to:
  /// **'المتاح للصرف'**
  String get availableToSpend;

  /// No description provided for @spentSoFar.
  ///
  /// In ar, this message translates to:
  /// **'المصروف حتى الآن'**
  String get spentSoFar;

  /// No description provided for @dailyAvailable.
  ///
  /// In ar, this message translates to:
  /// **'المتاح يوميًا'**
  String get dailyAvailable;

  /// No description provided for @overcommittedWarning.
  ///
  /// In ar, this message translates to:
  /// **'المصروفات الثابتة والادخار ({amount}) أكبر من دخلك. عدّل الخطة.'**
  String overcommittedWarning(String amount);

  /// No description provided for @overspentWarning.
  ///
  /// In ar, this message translates to:
  /// **'تجاوزت المتاح في هذه الدورة بمقدار {amount}.'**
  String overspentWarning(String amount);

  /// No description provided for @nearEndWarning.
  ///
  /// In ar, this message translates to:
  /// **'اقتربت من نهاية المتاح: صرفت {percent}٪ ويبقى {amount}.'**
  String nearEndWarning(int percent, String amount);

  /// No description provided for @editPlan.
  ///
  /// In ar, this message translates to:
  /// **'تعديل الخطة'**
  String get editPlan;

  /// No description provided for @suggestBudget.
  ///
  /// In ar, this message translates to:
  /// **'اقتراح ميزانية'**
  String get suggestBudget;

  /// No description provided for @paidCount.
  ///
  /// In ar, this message translates to:
  /// **'دُفع {paid} من {total}'**
  String paidCount(int paid, int total);

  /// No description provided for @dueDayLine.
  ///
  /// In ar, this message translates to:
  /// **'يوم {day} من الشهر'**
  String dueDayLine(int day);

  /// No description provided for @dueDayAmount.
  ///
  /// In ar, this message translates to:
  /// **'يوم {day} من الشهر · {amount}'**
  String dueDayAmount(int day, String amount);

  /// No description provided for @byCategory.
  ///
  /// In ar, this message translates to:
  /// **'الصرف حسب الفئة'**
  String get byCategory;

  /// No description provided for @noCategorySpending.
  ///
  /// In ar, this message translates to:
  /// **'لا صرف مسجَّل في هذه الدورة ولا حدود للفئات. يمكنك اقتراح حدود من «اقتراح ميزانية».'**
  String get noCategorySpending;

  /// No description provided for @overLimit.
  ///
  /// In ar, this message translates to:
  /// **'تجاوزت حد «{category}» بمقدار {amount}.'**
  String overLimit(String category, String amount);

  /// No description provided for @nearLimit.
  ///
  /// In ar, this message translates to:
  /// **'اقتربت من حد «{category}»: صرفت {percent}٪ منه.'**
  String nearLimit(String category, int percent);

  /// No description provided for @recentExpenses.
  ///
  /// In ar, this message translates to:
  /// **'آخر المصاريف'**
  String get recentExpenses;

  /// No description provided for @noRecentExpenses.
  ///
  /// In ar, this message translates to:
  /// **'لا مصاريف مسجَّلة في هذه الدورة بعد.'**
  String get noRecentExpenses;

  /// No description provided for @recordExpense.
  ///
  /// In ar, this message translates to:
  /// **'سجّل مصروف'**
  String get recordExpense;

  /// No description provided for @allExpenses.
  ///
  /// In ar, this message translates to:
  /// **'كل المصاريف'**
  String get allExpenses;

  /// No description provided for @invalidAmountPositive.
  ///
  /// In ar, this message translates to:
  /// **'أدخل مبلغًا صحيحًا أكبر من صفر'**
  String get invalidAmountPositive;

  /// No description provided for @percentRange.
  ///
  /// In ar, this message translates to:
  /// **'أدخل نسبة بين 0 و100'**
  String get percentRange;

  /// No description provided for @savingsAmountInvalid.
  ///
  /// In ar, this message translates to:
  /// **'أدخل مبلغًا صحيحًا (أو اتركه فارغًا)'**
  String get savingsAmountInvalid;

  /// No description provided for @checkRedFields.
  ///
  /// In ar, this message translates to:
  /// **'راجع الحقول المعلَّمة بالأحمر ثم احفظ مرة أخرى'**
  String get checkRedFields;

  /// No description provided for @planSaveFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر حفظ الخطة. حاول مرة أخرى'**
  String get planSaveFailed;

  /// No description provided for @unsavedChanges.
  ///
  /// In ar, this message translates to:
  /// **'تعديلات غير محفوظة'**
  String get unsavedChanges;

  /// No description provided for @unsavedPlanBody.
  ///
  /// In ar, this message translates to:
  /// **'لم تحفظ التغييرات على خطة الميزانية. هل تحفظها قبل الخروج؟'**
  String get unsavedPlanBody;

  /// No description provided for @keepEditing.
  ///
  /// In ar, this message translates to:
  /// **'متابعة التعديل'**
  String get keepEditing;

  /// No description provided for @leaveWithoutSaving.
  ///
  /// In ar, this message translates to:
  /// **'خروج بلا حفظ'**
  String get leaveWithoutSaving;

  /// No description provided for @savePlan.
  ///
  /// In ar, this message translates to:
  /// **'حفظ الخطة'**
  String get savePlan;

  /// No description provided for @newFixedExpense.
  ///
  /// In ar, this message translates to:
  /// **'مصروف ثابت جديد'**
  String get newFixedExpense;

  /// No description provided for @editFixedExpense.
  ///
  /// In ar, this message translates to:
  /// **'تعديل المصروف الثابت'**
  String get editFixedExpense;

  /// No description provided for @expenseName.
  ///
  /// In ar, this message translates to:
  /// **'اسم المصروف'**
  String get expenseName;

  /// No description provided for @expenseNameHint.
  ///
  /// In ar, this message translates to:
  /// **'مثال: إيجار'**
  String get expenseNameHint;

  /// No description provided for @amountLabel.
  ///
  /// In ar, this message translates to:
  /// **'المبلغ'**
  String get amountLabel;

  /// No description provided for @dueDayField.
  ///
  /// In ar, this message translates to:
  /// **'يوم الاستحقاق (من 1 إلى 31)'**
  String get dueDayField;

  /// No description provided for @dueDayInvalid.
  ///
  /// In ar, this message translates to:
  /// **'أدخل يومًا من 1 إلى 31'**
  String get dueDayInvalid;

  /// No description provided for @budgetPlanTitle.
  ///
  /// In ar, this message translates to:
  /// **'خطة الميزانية'**
  String get budgetPlanTitle;

  /// No description provided for @incomeAndCycle.
  ///
  /// In ar, this message translates to:
  /// **'الدخل والدورة'**
  String get incomeAndCycle;

  /// No description provided for @monthlyIncome.
  ///
  /// In ar, this message translates to:
  /// **'الدخل الشهري'**
  String get monthlyIncome;

  /// No description provided for @paydayField.
  ///
  /// In ar, this message translates to:
  /// **'يوم نزول الراتب'**
  String get paydayField;

  /// No description provided for @paydayHelper.
  ///
  /// In ar, this message translates to:
  /// **'تبدأ دورة الميزانية من هذا اليوم كل شهر'**
  String get paydayHelper;

  /// No description provided for @currencyField.
  ///
  /// In ar, this message translates to:
  /// **'العملة'**
  String get currencyField;

  /// No description provided for @fixedEmptyHint.
  ///
  /// In ar, this message translates to:
  /// **'أضف ما يتكرر كل شهر: إيجار، أقساط، اشتراكات، فواتير.'**
  String get fixedEmptyHint;

  /// No description provided for @deleteNamed.
  ///
  /// In ar, this message translates to:
  /// **'حذف {name}'**
  String deleteNamed(String name);

  /// No description provided for @totalLine.
  ///
  /// In ar, this message translates to:
  /// **'المجموع: {amount}'**
  String totalLine(String amount);

  /// No description provided for @addFixedExpense.
  ///
  /// In ar, this message translates to:
  /// **'إضافة مصروف ثابت'**
  String get addFixedExpense;

  /// No description provided for @monthlySavingsGoal.
  ///
  /// In ar, this message translates to:
  /// **'هدف الادخار الشهري'**
  String get monthlySavingsGoal;

  /// No description provided for @savingsModeAmount.
  ///
  /// In ar, this message translates to:
  /// **'مبلغ'**
  String get savingsModeAmount;

  /// No description provided for @savingsModePercent.
  ///
  /// In ar, this message translates to:
  /// **'نسبة من الدخل'**
  String get savingsModePercent;

  /// No description provided for @savingsPercentField.
  ///
  /// In ar, this message translates to:
  /// **'نسبة الادخار'**
  String get savingsPercentField;

  /// No description provided for @savingsAmountField.
  ///
  /// In ar, this message translates to:
  /// **'مبلغ الادخار'**
  String get savingsAmountField;

  /// No description provided for @equalsMonthly.
  ///
  /// In ar, this message translates to:
  /// **'يساوي {amount} شهريًا'**
  String equalsMonthly(String amount);

  /// No description provided for @categoryLimitsOptional.
  ///
  /// In ar, this message translates to:
  /// **'حدود الفئات (اختياري)'**
  String get categoryLimitsOptional;

  /// No description provided for @categoryLimitsHint.
  ///
  /// In ar, this message translates to:
  /// **'حدّ أقصى للصرف في كل فئة خلال الدورة. اتركه فارغًا لعدم وضع حد.'**
  String get categoryLimitsHint;

  /// No description provided for @categoryLimitField.
  ///
  /// In ar, this message translates to:
  /// **'حد {category}'**
  String categoryLimitField(String category);

  /// No description provided for @planOvercommitted.
  ///
  /// In ar, this message translates to:
  /// **'المصروفات الثابتة والادخار ({committed}) أكبر من الدخل ({income}). لن يبقى شيء للصرف.'**
  String planOvercommitted(String committed, String income);

  /// No description provided for @limitsOverAvailable.
  ///
  /// In ar, this message translates to:
  /// **'مجموع حدود الفئات ({limits}) أكبر من المتاح للصرف ({available}).'**
  String limitsOverAvailable(String limits, String available);

  /// No description provided for @planSummary.
  ///
  /// In ar, this message translates to:
  /// **'ملخص الخطة'**
  String get planSummary;

  /// No description provided for @limitsSaveFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر حفظ الحدود. حاول مرة أخرى'**
  String get limitsSaveFailed;

  /// No description provided for @yourAiProvider.
  ///
  /// In ar, this message translates to:
  /// **'مزوّد الذكاء الاصطناعي الذي اخترته'**
  String get yourAiProvider;

  /// No description provided for @sendFinancialData.
  ///
  /// In ar, this message translates to:
  /// **'إرسال بياناتك المالية؟'**
  String get sendFinancialData;

  /// No description provided for @financialConsentBody.
  ///
  /// In ar, this message translates to:
  /// **'سيُرسل إلى «{provider}» الأرقام التالية فقط:\n• الدخل الشهري: {income}\n• مجموع المصروفات الثابتة: {fixed}\n• هدف الادخار: {savings}\n• المتاح للصرف: {available}\n\nلن تُرسل أسماء مصروفاتك الثابتة ولا مصاريفك المسجَّلة. ما يُرسل يخضع لسياسة هذا المزوّد. نسألك في كل مرة، ولا شيء يُرسل قبل موافقتك.'**
  String financialConsentBody(
    String provider,
    String income,
    String fixed,
    String savings,
    String available,
  );

  /// No description provided for @agreeAndSend.
  ///
  /// In ar, this message translates to:
  /// **'أوافق وأرسل هذه المرة'**
  String get agreeAndSend;

  /// No description provided for @aiSuggestionUnreadable.
  ///
  /// In ar, this message translates to:
  /// **'لم أتمكن من قراءة الاقتراح كحدود للفئات. {reply}'**
  String aiSuggestionUnreadable(String reply);

  /// No description provided for @saveAsLimits.
  ///
  /// In ar, this message translates to:
  /// **'حفظ كحدود للفئات'**
  String get saveAsLimits;

  /// No description provided for @availableMonthly.
  ///
  /// In ar, this message translates to:
  /// **'المتاح للصرف شهريًا'**
  String get availableMonthly;

  /// No description provided for @noAvailableForLimits.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد متاح للصرف في خطتك الآن، فلا يمكن اقتراح حدود. عدّل الدخل أو المصروفات الثابتة أو الادخار أولًا.'**
  String get noAvailableForLimits;

  /// No description provided for @localSuggestion.
  ///
  /// In ar, this message translates to:
  /// **'اقتراح محلي (بلا إنترنت)'**
  String get localSuggestion;

  /// No description provided for @localRuleText.
  ///
  /// In ar, this message translates to:
  /// **'قاعدة بسيطة توزّع المتاح هكذا: {rule}. بعد الحفظ تعدّل أي حد من «تعديل الخطة».'**
  String localRuleText(String rule);

  /// No description provided for @aiSuggestionOptional.
  ///
  /// In ar, this message translates to:
  /// **'اقتراح بالذكاء الاصطناعي (اختياري)'**
  String get aiSuggestionOptional;

  /// No description provided for @aiSuggestionNote.
  ///
  /// In ar, this message translates to:
  /// **'يرسل أرقام خطتك المالية إلى المزوّد الذي اخترته، ولا يُرسل شيء إلا بموافقتك في كل مرة.'**
  String get aiSuggestionNote;

  /// No description provided for @askAiSuggestion.
  ///
  /// In ar, this message translates to:
  /// **'اطلب اقتراحًا بالذكاء الاصطناعي'**
  String get askAiSuggestion;

  /// No description provided for @aiSuggestionOver.
  ///
  /// In ar, this message translates to:
  /// **'مجموع هذا الاقتراح ({amount}) أكبر من المتاح للصرف. عدّله بعد الحفظ.'**
  String aiSuggestionOver(String amount);

  /// No description provided for @expenseDeleted.
  ///
  /// In ar, this message translates to:
  /// **'حُذف مصروف {amount}'**
  String expenseDeleted(String amount);

  /// No description provided for @noMonthExpenses.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد مصاريف مسجلة في هذا الشهر'**
  String get noMonthExpenses;

  /// No description provided for @previousMonth.
  ///
  /// In ar, this message translates to:
  /// **'الشهر السابق'**
  String get previousMonth;

  /// No description provided for @nextMonth.
  ///
  /// In ar, this message translates to:
  /// **'الشهر التالي'**
  String get nextMonth;

  /// No description provided for @totalSpending.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي الصرف'**
  String get totalSpending;

  /// No description provided for @breakdownByCategory.
  ///
  /// In ar, this message translates to:
  /// **'التوزيع حسب الفئة'**
  String get breakdownByCategory;

  /// No description provided for @percentOfTotal.
  ///
  /// In ar, this message translates to:
  /// **'{percent}٪ من الإجمالي'**
  String percentOfTotal(int percent);

  /// No description provided for @monthExpenses.
  ///
  /// In ar, this message translates to:
  /// **'مصروفات الشهر'**
  String get monthExpenses;

  /// No description provided for @deleteExpense.
  ///
  /// In ar, this message translates to:
  /// **'حذف المصروف'**
  String get deleteExpense;

  /// No description provided for @recordExpenseTitle.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل مصروف'**
  String get recordExpenseTitle;

  /// No description provided for @editExpenseTitle.
  ///
  /// In ar, this message translates to:
  /// **'تعديل مصروف'**
  String get editExpenseTitle;

  /// No description provided for @expenseCategoryField.
  ///
  /// In ar, this message translates to:
  /// **'الفئة'**
  String get expenseCategoryField;

  /// No description provided for @dateLine.
  ///
  /// In ar, this message translates to:
  /// **'التاريخ: {date}'**
  String dateLine(String date);

  /// No description provided for @changeDate.
  ///
  /// In ar, this message translates to:
  /// **'تغيير التاريخ'**
  String get changeDate;

  /// No description provided for @aiMissingKey.
  ///
  /// In ar, this message translates to:
  /// **'يلزم إعداد مزوّد الذكاء الاصطناعي ومفتاحه من الإعدادات أولًا.'**
  String get aiMissingKey;

  /// No description provided for @aiInvalidKey.
  ///
  /// In ar, this message translates to:
  /// **'المفتاح غير صالح أو منتهي. يرجى تحديثه من إعدادات مزوّد الذكاء الاصطناعي ثم إعادة المحاولة.'**
  String get aiInvalidKey;

  /// No description provided for @aiModelNotFound.
  ///
  /// In ar, this message translates to:
  /// **'الموديل المختار غير موجود أو أُوقف. يرجى تحديث قائمة الموديلات من الإعدادات واختيار موديل آخر.'**
  String get aiModelNotFound;

  /// No description provided for @aiRateLimited.
  ///
  /// In ar, this message translates to:
  /// **'تم بلوغ حد الاستخدام أو الرصيد لدى المزوّد. يرجى الانتظار قليلًا أو مراجعة الحساب لديه ثم إعادة المحاولة.'**
  String get aiRateLimited;

  /// No description provided for @aiBusy.
  ///
  /// In ar, this message translates to:
  /// **'خوادم المزوّد مزدحمة الآن، والمشكلة عنده لا في التطبيق. يرجى المحاولة بعد قليل، أو اختيار موديل أخفّ من إعدادات الذكاء الاصطناعي (مثل الموديلات التي في اسمها lite أو mini أو haiku).'**
  String get aiBusy;

  /// No description provided for @aiNetwork.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر الاتصال بالإنترنت. يرجى التحقق من الشبكة ثم إعادة المحاولة.'**
  String get aiNetwork;

  /// No description provided for @aiTimeout.
  ///
  /// In ar, this message translates to:
  /// **'لم يصل رد من المزوّد في الوقت المحدد، وغالبًا خوادمه مزدحمة. يرجى المحاولة مرة أخرى، أو اختيار موديل أخفّ وأسرع من إعدادات الذكاء الاصطناعي (مثل الموديلات التي في اسمها lite أو mini أو haiku).'**
  String get aiTimeout;

  /// No description provided for @aiBadRequest.
  ///
  /// In ar, this message translates to:
  /// **'رفض المزوّد الطلب. قد لا يدعم الموديل هذا النوع من الطلبات، فجرّب موديلًا آخر.'**
  String get aiBadRequest;

  /// No description provided for @aiImageUnsupported.
  ///
  /// In ar, this message translates to:
  /// **'الموديل المختار لا يدعم الصور. يرجى اختيار موديل يدعمها من إعدادات مزوّد الذكاء الاصطناعي.'**
  String get aiImageUnsupported;

  /// No description provided for @aiBlocked.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر تكوين رد لهذا الطلب. جرّب صياغة مختلفة.'**
  String get aiBlocked;

  /// No description provided for @aiUnsupportedLocation.
  ///
  /// In ar, this message translates to:
  /// **'خدمة المزوّد غير متاحة في بلدك حاليًا.'**
  String get aiUnsupportedLocation;

  /// No description provided for @aiInsecureUrl.
  ///
  /// In ar, this message translates to:
  /// **'عنوان المزوّد يجب أن يبدأ بـ https:// ويكون عنوانًا صحيحًا.'**
  String get aiInsecureUrl;

  /// No description provided for @aiInvalidModelName.
  ///
  /// In ar, this message translates to:
  /// **'اسم الموديل غير صالح. يُسمح بالحروف والأرقام والرموز - _ . : / @ فقط.'**
  String get aiInvalidModelName;

  /// No description provided for @aiEmptyReply.
  ///
  /// In ar, this message translates to:
  /// **'لم يتم استلام رد من المساعد الذكي.'**
  String get aiEmptyReply;

  /// No description provided for @aiUnknown.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ غير متوقع مع المساعد الذكي. يرجى المحاولة مرة أخرى بعد قليل.'**
  String get aiUnknown;

  /// No description provided for @aiEmptyImageReply.
  ///
  /// In ar, this message translates to:
  /// **'لم أتمكن من تحليل الصورة.'**
  String get aiEmptyImageReply;

  /// No description provided for @aiNoKeySet.
  ///
  /// In ar, this message translates to:
  /// **'لم يُضبط مفتاح'**
  String get aiNoKeySet;

  /// No description provided for @customProviderLabel.
  ///
  /// In ar, this message translates to:
  /// **'مخصص (متوافق مع OpenAI)'**
  String get customProviderLabel;

  /// No description provided for @providerConnectionOk.
  ///
  /// In ar, this message translates to:
  /// **'الاتصال سليم والموديل يرد.'**
  String get providerConnectionOk;

  /// No description provided for @providerImageRejected.
  ///
  /// In ar, this message translates to:
  /// **'الموديل لم يقبل الصورة، فعُلّم بأنه لا يدعم الصور.'**
  String get providerImageRejected;

  /// No description provided for @providerImagesOk.
  ///
  /// In ar, this message translates to:
  /// **'الموديل يدعم الصور.'**
  String get providerImagesOk;

  /// No description provided for @providerNoModels.
  ///
  /// In ar, this message translates to:
  /// **'لم يُرجع المزوّد أي موديل.'**
  String get providerNoModels;

  /// No description provided for @providerSaved.
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ إعداد الذكاء الاصطناعي.'**
  String get providerSaved;

  /// No description provided for @providerKeyDeleted.
  ///
  /// In ar, this message translates to:
  /// **'حُذف المفتاح من هذا الجهاز.'**
  String get providerKeyDeleted;

  /// No description provided for @linkCopied.
  ///
  /// In ar, this message translates to:
  /// **'تم نسخ الرابط'**
  String get linkCopied;

  /// No description provided for @providerIntro.
  ///
  /// In ar, this message translates to:
  /// **'اختر المزوّد الذي تريد استعماله وأدخل مفتاحك الخاص منه.\nالمفتاح يُحفظ على جهازك فقط في تخزين آمن، ويُرسل إلى المزوّد الذي تختاره وحده مع طلباتك، بلا خادم وسيط. ما تُرسله يخضع لسياسة الخصوصية لدى ذلك المزوّد.'**
  String get providerIntro;

  /// No description provided for @providerField.
  ///
  /// In ar, this message translates to:
  /// **'المزوّد'**
  String get providerField;

  /// No description provided for @providerUrlField.
  ///
  /// In ar, this message translates to:
  /// **'عنوان المزوّد'**
  String get providerUrlField;

  /// No description provided for @modelNameField.
  ///
  /// In ar, this message translates to:
  /// **'اسم الموديل'**
  String get modelNameField;

  /// No description provided for @modelNameHint.
  ///
  /// In ar, this message translates to:
  /// **'اكتب الاسم أو اجلبه من المزوّد'**
  String get modelNameHint;

  /// No description provided for @fetchModels.
  ///
  /// In ar, this message translates to:
  /// **'جلب الموديلات المتاحة'**
  String get fetchModels;

  /// No description provided for @keyField.
  ///
  /// In ar, this message translates to:
  /// **'المفتاح'**
  String get keyField;

  /// No description provided for @copyLink.
  ///
  /// In ar, this message translates to:
  /// **'نسخ الرابط'**
  String get copyLink;

  /// No description provided for @pasteKeyHint.
  ///
  /// In ar, this message translates to:
  /// **'الصق مفتاحك هنا'**
  String get pasteKeyHint;

  /// No description provided for @savedKeyHint.
  ///
  /// In ar, this message translates to:
  /// **'محفوظ: {preview} (اتركه فارغًا للإبقاء عليه)'**
  String savedKeyHint(String preview);

  /// No description provided for @showKey.
  ///
  /// In ar, this message translates to:
  /// **'إظهار المفتاح'**
  String get showKey;

  /// No description provided for @hideKey.
  ///
  /// In ar, this message translates to:
  /// **'إخفاء المفتاح'**
  String get hideKey;

  /// No description provided for @deleteSavedKey.
  ///
  /// In ar, this message translates to:
  /// **'حذف المفتاح المحفوظ'**
  String get deleteSavedKey;

  /// No description provided for @modelImagesQuestion.
  ///
  /// In ar, this message translates to:
  /// **'هل يدعم الموديل الصور؟'**
  String get modelImagesQuestion;

  /// No description provided for @yes.
  ///
  /// In ar, this message translates to:
  /// **'نعم'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In ar, this message translates to:
  /// **'لا'**
  String get no;

  /// No description provided for @unknownSupport.
  ///
  /// In ar, this message translates to:
  /// **'غير معروف'**
  String get unknownSupport;

  /// No description provided for @testImagesAuto.
  ///
  /// In ar, this message translates to:
  /// **'اختبار دعم الصور تلقائيًا'**
  String get testImagesAuto;

  /// No description provided for @testConnection.
  ///
  /// In ar, this message translates to:
  /// **'اختبار الاتصال'**
  String get testConnection;

  /// No description provided for @saveAndActivate.
  ///
  /// In ar, this message translates to:
  /// **'حفظ وتفعيل'**
  String get saveAndActivate;

  /// No description provided for @searchModels.
  ///
  /// In ar, this message translates to:
  /// **'بحث في {count} موديل'**
  String searchModels(int count);

  /// No description provided for @assistantActivated.
  ///
  /// In ar, this message translates to:
  /// **'✅ تم تفعيل المزوّد بنجاح! يمكنك الآن استخدام جميع ميزات الذكاء الاصطناعي.'**
  String get assistantActivated;

  /// No description provided for @assistantTitle.
  ///
  /// In ar, this message translates to:
  /// **'🤖 المساعد الذكي'**
  String get assistantTitle;

  /// No description provided for @assistantProviderSetup.
  ///
  /// In ar, this message translates to:
  /// **'إعداد مزوّد الذكاء الاصطناعي'**
  String get assistantProviderSetup;

  /// No description provided for @assistantStarting.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ تهيئة المساعد الذكي...'**
  String get assistantStarting;

  /// No description provided for @assistantThinking.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ التفكير...'**
  String get assistantThinking;

  /// No description provided for @assistantHint.
  ///
  /// In ar, this message translates to:
  /// **'اسأل المساعد الذكي أو اطلب اقتراحاً...'**
  String get assistantHint;

  /// No description provided for @send.
  ///
  /// In ar, this message translates to:
  /// **'إرسال'**
  String get send;

  /// No description provided for @coachDomainBeliefs.
  ///
  /// In ar, this message translates to:
  /// **'المعتقدات'**
  String get coachDomainBeliefs;

  /// No description provided for @coachDomainEmotions.
  ///
  /// In ar, this message translates to:
  /// **'المشاعر'**
  String get coachDomainEmotions;

  /// No description provided for @coachDomainGoals.
  ///
  /// In ar, this message translates to:
  /// **'الأهداف والتخطيط'**
  String get coachDomainGoals;

  /// No description provided for @coachDomainOrganization.
  ///
  /// In ar, this message translates to:
  /// **'التنظيم والتوازن'**
  String get coachDomainOrganization;

  /// No description provided for @coachDomainSkills.
  ///
  /// In ar, this message translates to:
  /// **'المهارات والتقنيات'**
  String get coachDomainSkills;

  /// No description provided for @coachHintBudget.
  ///
  /// In ar, this message translates to:
  /// **'لاحظنا نمطًا في مصاريفك هذا الأسبوع'**
  String get coachHintBudget;

  /// No description provided for @coachHintUsage.
  ///
  /// In ar, this message translates to:
  /// **'هذا السؤال مرتبط بتوزيع وقتك اليوم'**
  String get coachHintUsage;

  /// No description provided for @coachHintReflection.
  ///
  /// In ar, this message translates to:
  /// **'لاحظنا فكرة تتكرر في إجاباتك الأخيرة'**
  String get coachHintReflection;

  /// No description provided for @coachQuotaRemaining.
  ///
  /// In ar, this message translates to:
  /// **'متبقٍ {remaining} من {limit} مجانًا هذا الشهر'**
  String coachQuotaRemaining(int remaining, int limit);

  /// No description provided for @coachQuotaUsedUp.
  ///
  /// In ar, this message translates to:
  /// **'انتهت المحاولات المجانية لهذا الشهر، وتتجدد في {date}'**
  String coachQuotaUsedUp(String date);

  /// No description provided for @coachQuotaRenews.
  ///
  /// In ar, this message translates to:
  /// **'تتجدد محاولاتك المجانية في {date}'**
  String coachQuotaRenews(String date);

  /// No description provided for @coachQuotaOffer.
  ///
  /// In ar, this message translates to:
  /// **'{limit, plural, =1{تحصل مجانًا على سؤال متابعة واحد كل شهر.} =2{تحصل مجانًا على سؤالَي متابعة كل شهر.} few{تحصل مجانًا على {limit} أسئلة متابعة كل شهر.} other{تحصل مجانًا على {limit} سؤال متابعة كل شهر.}} الاشتراك يجعلها بلا حد.'**
  String coachQuotaOffer(int limit);

  /// No description provided for @crisisResponse.
  ///
  /// In ar, this message translates to:
  /// **'إذا كنت تمر بأزمة فعلية أو تفكر في إيذاء نفسك، الرجاء التواصل فورًا مع خط مساعدة مختص أو أقرب جهة طوارئ. هذا التطبيق أداة تأمل ذاتي فقط، وليس بديلاً عن معالج نفسي مرخّص.'**
  String get crisisResponse;

  /// No description provided for @crisisSaudiNote.
  ///
  /// In ar, this message translates to:
  /// **'في المملكة العربية السعودية (خطوط حكومية رسمية):'**
  String get crisisSaudiNote;

  /// No description provided for @crisisLocalEmergency.
  ///
  /// In ar, this message translates to:
  /// **'إن كان هناك خطر مباشر، اتصل الآن برقم الطوارئ في بلدك، أو اذهب إلى أقرب قسم طوارئ.'**
  String get crisisLocalEmergency;

  /// No description provided for @crisisFinderLabel.
  ///
  /// In ar, this message translates to:
  /// **'ابحث عن خط مساعدة مجاني في بلدك'**
  String get crisisFinderLabel;

  /// No description provided for @crisisImportant.
  ///
  /// In ar, this message translates to:
  /// **'مهم'**
  String get crisisImportant;

  /// No description provided for @gotIt.
  ///
  /// In ar, this message translates to:
  /// **'فهمت'**
  String get gotIt;

  /// No description provided for @coachHistory.
  ///
  /// In ar, this message translates to:
  /// **'سجل جلسات المدرب'**
  String get coachHistory;

  /// No description provided for @coachDisclaimer.
  ///
  /// In ar, this message translates to:
  /// **'هذه أداة تأمل ذاتي، وليست بديلًا عن معالج نفسي مرخّص.'**
  String get coachDisclaimer;

  /// No description provided for @coachAnswerHint.
  ///
  /// In ar, this message translates to:
  /// **'إجابتك (اختياري)...'**
  String get coachAnswerHint;

  /// No description provided for @coachDeepen.
  ///
  /// In ar, this message translates to:
  /// **'عمّق أكثر'**
  String get coachDeepen;

  /// No description provided for @coachSessionDeleted.
  ///
  /// In ar, this message translates to:
  /// **'حُذفت الجلسة'**
  String get coachSessionDeleted;

  /// No description provided for @coachNoSessions.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد جلسات محفوظة بعد'**
  String get coachNoSessions;

  /// No description provided for @coachDeleteSession.
  ///
  /// In ar, this message translates to:
  /// **'حذف الجلسة'**
  String get coachDeleteSession;

  /// No description provided for @payPending.
  ///
  /// In ar, this message translates to:
  /// **'الدفع قيد المعالجة لدى Google Play، وسيُفعَّل الاشتراك تلقائيًا عند اكتماله.'**
  String get payPending;

  /// No description provided for @payError.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر إتمام الشراء، حاول مرة أخرى.'**
  String get payError;

  /// No description provided for @payOpenFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر فتح نافذة الشراء، حاول مرة أخرى.'**
  String get payOpenFailed;

  /// No description provided for @payNoSubscription.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد اشتراك فعّال على حساب Google Play هذا.'**
  String get payNoSubscription;

  /// No description provided for @payTitle.
  ///
  /// In ar, this message translates to:
  /// **'الاشتراك الشهري'**
  String get payTitle;

  /// No description provided for @payHeadingMeditation.
  ///
  /// In ar, this message translates to:
  /// **'كل جلسات التأمل'**
  String get payHeadingMeditation;

  /// No description provided for @payHeadingCoach.
  ///
  /// In ar, this message translates to:
  /// **'تعمّق أكثر في تأملك'**
  String get payHeadingCoach;

  /// No description provided for @payBenefitDeepen.
  ///
  /// In ar, this message translates to:
  /// **'«عمّق أكثر» بلا حد: سؤال متابعة مبني على إجابتك أنت، بلا نصائح ولا أحكام.'**
  String get payBenefitDeepen;

  /// No description provided for @payBenefitMeditation.
  ///
  /// In ar, this message translates to:
  /// **'كل جلسات التأمل المرشدة والحركية: مسح الجسد، والحضور في اللحظة، وحركة ثم سكون.'**
  String get payBenefitMeditation;

  /// No description provided for @payBenefitControl.
  ///
  /// In ar, this message translates to:
  /// **'أنت تقرر متى تستعملها، لا شيء يحدث تلقائيًا.'**
  String get payBenefitControl;

  /// No description provided for @payFreeNote.
  ///
  /// In ar, this message translates to:
  /// **'الأسئلة المحلية وسجل جلساتك وتتبع الميزانية تبقى مجانية بالكامل، وكذلك المؤقت الصامت وموجات جاما وجلسة التنفّس الهادئ.\nسؤال المتابعة يعمل بمفتاح مزوّد الذكاء الاصطناعي الذي تحدده من الإعدادات.'**
  String get payFreeNote;

  /// No description provided for @payUnavailable.
  ///
  /// In ar, this message translates to:
  /// **'الاشتراك غير متاح حاليًا'**
  String get payUnavailable;

  /// No description provided for @paySubscribe.
  ///
  /// In ar, this message translates to:
  /// **'اشترك الآن — {price} شهريًا'**
  String paySubscribe(String price);

  /// No description provided for @payAndroidOnly.
  ///
  /// In ar, this message translates to:
  /// **'الاشتراك متاح في نسخة Android المثبتة من Google Play.'**
  String get payAndroidOnly;

  /// No description provided for @payRestore.
  ///
  /// In ar, this message translates to:
  /// **'استعادة المشتريات'**
  String get payRestore;

  /// No description provided for @payRenewal.
  ///
  /// In ar, this message translates to:
  /// **'يتجدد الاشتراك تلقائيًا كل شهر بنفس السعر حتى تلغيه. يمكنك الإلغاء في أي وقت من Google Play ← الدفعات والاشتراكات ← الاشتراكات.'**
  String get payRenewal;

  /// No description provided for @hoursShort.
  ///
  /// In ar, this message translates to:
  /// **'{h} س'**
  String hoursShort(int h);

  /// No description provided for @hoursMinutesShort.
  ///
  /// In ar, this message translates to:
  /// **'{h} س {m} د'**
  String hoursMinutesShort(int h, int m);

  /// No description provided for @refresh.
  ///
  /// In ar, this message translates to:
  /// **'تحديث'**
  String get refresh;

  /// No description provided for @usageAndroidOnly.
  ///
  /// In ar, this message translates to:
  /// **'هذه الميزة تعمل على أجهزة Android فقط، لأنها تعتمد على صلاحية \"الوصول إلى بيانات الاستخدام\" في النظام.'**
  String get usageAndroidOnly;

  /// No description provided for @usageReadFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذّرت قراءة بيانات الاستخدام من النظام، حاول مرة أخرى لاحقًا.'**
  String get usageReadFailed;

  /// No description provided for @usageToday.
  ///
  /// In ar, this message translates to:
  /// **'وقتك اليوم في تطبيقات التواصل'**
  String get usageToday;

  /// No description provided for @usageNone.
  ///
  /// In ar, this message translates to:
  /// **'لم يُسجَّل استخدام لهذه التطبيقات اليوم.'**
  String get usageNone;

  /// No description provided for @usageBreakdown.
  ///
  /// In ar, this message translates to:
  /// **'التوزيع بين التطبيقات (بالدقائق)'**
  String get usageBreakdown;

  /// No description provided for @usageShare.
  ///
  /// In ar, this message translates to:
  /// **'{percent}٪ من وقت التواصل اليوم'**
  String usageShare(int percent);

  /// No description provided for @usageSource.
  ///
  /// In ar, this message translates to:
  /// **'من منتصف الليل حتى الآن، كما يسجّلها نظام Android. الأرقام تبقى على جهازك فقط.'**
  String get usageSource;

  /// No description provided for @usageHowTitle.
  ///
  /// In ar, this message translates to:
  /// **'كيف تعمل هذه الميزة؟'**
  String get usageHowTitle;

  /// No description provided for @usageHowBody.
  ///
  /// In ar, this message translates to:
  /// **'نقرأ من نظام Android عدد الدقائق التي قضيتها اليوم في: {apps}. رقم واحد لكل تطبيق، لا أكثر.\nلا نقرأ رسائلك ولا إشعاراتك ولا أي محتوى داخل هذه التطبيقات، ولا نطلب تسجيل الدخول لأي حساب.\nالأرقام تبقى على جهازك فقط ولا تُرسل لأي مكان، ويمكنك إلغاء الصلاحية في أي وقت من نفس الإعدادات.'**
  String usageHowBody(String apps);

  /// No description provided for @usageEnableTitle.
  ///
  /// In ar, this message translates to:
  /// **'لتفعيلها:'**
  String get usageEnableTitle;

  /// No description provided for @usageStep1.
  ///
  /// In ar, this message translates to:
  /// **'اضغط \"فتح الإعدادات\" بالأسفل.'**
  String get usageStep1;

  /// No description provided for @usageStep2.
  ///
  /// In ar, this message translates to:
  /// **'ابحث في القائمة عن تطبيق \"{app}\".'**
  String usageStep2(String app);

  /// No description provided for @usageStep3.
  ///
  /// In ar, this message translates to:
  /// **'فعّل خيار السماح بالوصول إلى بيانات الاستخدام (قد يختلف الاسم قليلًا حسب نوع الجهاز).'**
  String get usageStep3;

  /// No description provided for @usageStep4.
  ///
  /// In ar, this message translates to:
  /// **'ارجع إلى التطبيق، وستظهر أرقام اليوم تلقائيًا.'**
  String get usageStep4;

  /// No description provided for @openSettings.
  ///
  /// In ar, this message translates to:
  /// **'فتح الإعدادات'**
  String get openSettings;

  /// No description provided for @notNow.
  ///
  /// In ar, this message translates to:
  /// **'ليس الآن'**
  String get notNow;

  /// No description provided for @backupWeakPassword.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور قصيرة: يلزم {min} أحرف على الأقل.'**
  String backupWeakPassword(int min);

  /// No description provided for @backupNotABackup.
  ///
  /// In ar, this message translates to:
  /// **'هذا الملف ليس نسخة احتياطية من هذا التطبيق.'**
  String get backupNotABackup;

  /// No description provided for @backupUnsupportedVersion.
  ///
  /// In ar, this message translates to:
  /// **'هذه النسخة أحدث من إصدار التطبيق الحالي. يرجى تحديث التطبيق ثم إعادة المحاولة.'**
  String get backupUnsupportedVersion;

  /// No description provided for @backupWrongPassword.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور غير صحيحة، أو أن الملف تالف.'**
  String get backupWrongPassword;

  /// No description provided for @backupRestoreFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذّرت الاستعادة، وأُعيدت البيانات كما كانت.'**
  String get backupRestoreFailed;

  /// No description provided for @backupRestoreFailedUnsafe.
  ///
  /// In ar, this message translates to:
  /// **'تعذّرت الاستعادة وقد تكون البيانات ناقصة. يرجى إعادة المحاولة بنفس الملف.'**
  String get backupRestoreFailedUnsafe;

  /// No description provided for @backupSaveDialog.
  ///
  /// In ar, this message translates to:
  /// **'حفظ النسخة الاحتياطية'**
  String get backupSaveDialog;

  /// No description provided for @backupPickDialog.
  ///
  /// In ar, this message translates to:
  /// **'اختيار ملف النسخة الاحتياطية'**
  String get backupPickDialog;

  /// No description provided for @contactSubject.
  ///
  /// In ar, this message translates to:
  /// **'تواصل بخصوص التطبيق'**
  String get contactSubject;

  /// No description provided for @assistantHello.
  ///
  /// In ar, this message translates to:
  /// **'أهلًا بك!'**
  String get assistantHello;

  /// No description provided for @assistantHelloName.
  ///
  /// In ar, this message translates to:
  /// **'أهلًا بك يا {name}!'**
  String assistantHelloName(String name);

  /// No description provided for @assistantGreetingBody.
  ///
  /// In ar, this message translates to:
  /// **'أنا مساعدك الذكي. كيف أساعدك في تنظيم يومك، أو اقتراح وجبات، أو مراجعة تمارينك؟\n\n🔑 للبدء يلزم إعداد مزوّد الذكاء الاصطناعي ومفتاحك الخاص من أيقونة المفتاح في الأعلى.'**
  String get assistantGreetingBody;

  /// No description provided for @coachToolsTitle.
  ///
  /// In ar, this message translates to:
  /// **'أدوات المدرب'**
  String get coachToolsTitle;

  /// No description provided for @coachToolsIntro.
  ///
  /// In ar, this message translates to:
  /// **'تمارين قصيرة بخطوات، تُحفظ نتائجها على هذا الجهاز للمقارنة بالمرات السابقة.'**
  String get coachToolsIntro;

  /// No description provided for @coachToolsEntry.
  ///
  /// In ar, this message translates to:
  /// **'أدوات المدرب: عجلة الحياة وتسمية المشاعر'**
  String get coachToolsEntry;

  /// No description provided for @wheelTitle.
  ///
  /// In ar, this message translates to:
  /// **'عجلة الحياة'**
  String get wheelTitle;

  /// No description provided for @wheelSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'تقييم مجالات الحياة الثمانية واختيار خطوة صغيرة.'**
  String get wheelSubtitle;

  /// No description provided for @emotionTitle.
  ///
  /// In ar, this message translates to:
  /// **'تسمية المشاعر'**
  String get emotionTitle;

  /// No description provided for @emotionSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'تسمية الشعور ومتابعته عبر الأيام.'**
  String get emotionSubtitle;

  /// No description provided for @wheelHealth.
  ///
  /// In ar, this message translates to:
  /// **'الصحة'**
  String get wheelHealth;

  /// No description provided for @wheelWork.
  ///
  /// In ar, this message translates to:
  /// **'العمل أو الدراسة'**
  String get wheelWork;

  /// No description provided for @wheelMoney.
  ///
  /// In ar, this message translates to:
  /// **'المال'**
  String get wheelMoney;

  /// No description provided for @wheelFamily.
  ///
  /// In ar, this message translates to:
  /// **'الأسرة'**
  String get wheelFamily;

  /// No description provided for @wheelRelationships.
  ///
  /// In ar, this message translates to:
  /// **'الأصدقاء والعلاقات'**
  String get wheelRelationships;

  /// No description provided for @wheelGrowth.
  ///
  /// In ar, this message translates to:
  /// **'التطور الشخصي'**
  String get wheelGrowth;

  /// No description provided for @wheelSpirit.
  ///
  /// In ar, this message translates to:
  /// **'الجانب الروحي'**
  String get wheelSpirit;

  /// No description provided for @wheelFun.
  ///
  /// In ar, this message translates to:
  /// **'المتعة والراحة'**
  String get wheelFun;

  /// No description provided for @wheelIntro.
  ///
  /// In ar, this message translates to:
  /// **'تقييم الرضا عن كل مجال من 0 إلى 10، ثم اختيار مجال واحد للعمل عليه.'**
  String get wheelIntro;

  /// No description provided for @wheelNow.
  ///
  /// In ar, this message translates to:
  /// **'الآن'**
  String get wheelNow;

  /// No description provided for @wheelLastTime.
  ///
  /// In ar, this message translates to:
  /// **'المرة السابقة ({date})'**
  String wheelLastTime(String date);

  /// No description provided for @wheelWas.
  ///
  /// In ar, this message translates to:
  /// **'كان {score}'**
  String wheelWas(int score);

  /// No description provided for @wheelFocus.
  ///
  /// In ar, this message translates to:
  /// **'مجال التركيز'**
  String get wheelFocus;

  /// No description provided for @wheelQ1.
  ///
  /// In ar, this message translates to:
  /// **'ما الذي يجعل «{area}» عند {score} وليس أقل؟'**
  String wheelQ1(String area, int score);

  /// No description provided for @wheelQ2.
  ///
  /// In ar, this message translates to:
  /// **'لو صار «{area}» عند {target}، ما أول ما سيتغيّر في اليوم؟'**
  String wheelQ2(String area, int target);

  /// No description provided for @wheelQ2Keep.
  ///
  /// In ar, this message translates to:
  /// **'ما الذي يساعد على إبقاء «{area}» في هذا المستوى؟'**
  String wheelQ2Keep(String area);

  /// No description provided for @wheelQ3.
  ///
  /// In ar, this message translates to:
  /// **'ما الذي يقف في الطريق الآن؟'**
  String get wheelQ3;

  /// No description provided for @wheelQ4.
  ///
  /// In ar, this message translates to:
  /// **'ما خطوة صغيرة واحدة تقرّب هذا المجال نقطة واحدة هذا الأسبوع؟'**
  String get wheelQ4;

  /// No description provided for @answerOptional.
  ///
  /// In ar, this message translates to:
  /// **'الإجابة (اختياري)'**
  String get answerOptional;

  /// No description provided for @stepToTask.
  ///
  /// In ar, this message translates to:
  /// **'إضافة الخطوة إلى المهام'**
  String get stepToTask;

  /// No description provided for @stepReminder.
  ///
  /// In ar, this message translates to:
  /// **'تذكير: {time}'**
  String stepReminder(String time);

  /// No description provided for @stepNoReminder.
  ///
  /// In ar, this message translates to:
  /// **'بلا تذكير'**
  String get stepNoReminder;

  /// No description provided for @stepSetReminder.
  ///
  /// In ar, this message translates to:
  /// **'ضبط تذكير'**
  String get stepSetReminder;

  /// No description provided for @wheelSave.
  ///
  /// In ar, this message translates to:
  /// **'حفظ العجلة'**
  String get wheelSave;

  /// No description provided for @wheelSaved.
  ///
  /// In ar, this message translates to:
  /// **'حُفظت عجلة الحياة.'**
  String get wheelSaved;

  /// No description provided for @wheelSavedWithTask.
  ///
  /// In ar, this message translates to:
  /// **'حُفظت عجلة الحياة، وأُضيفت الخطوة إلى المهام.'**
  String get wheelSavedWithTask;

  /// No description provided for @emotionIntro.
  ///
  /// In ar, this message translates to:
  /// **'تسمية الشعور بدقة خطوة أولى لفهمه. لا توجد إجابة صحيحة أو خاطئة.'**
  String get emotionIntro;

  /// No description provided for @emotionWhich.
  ///
  /// In ar, this message translates to:
  /// **'ما الشعور الأقرب الآن؟'**
  String get emotionWhich;

  /// No description provided for @emotionWord.
  ///
  /// In ar, this message translates to:
  /// **'كلمة أدق (اختياري)'**
  String get emotionWord;

  /// No description provided for @emotionIntensity.
  ///
  /// In ar, this message translates to:
  /// **'الشدة الآن: {value} من 10'**
  String emotionIntensity(int value);

  /// No description provided for @emotionWhere.
  ///
  /// In ar, this message translates to:
  /// **'أين يظهر هذا الشعور في الجسد؟'**
  String get emotionWhere;

  /// No description provided for @emotionTrigger.
  ///
  /// In ar, this message translates to:
  /// **'ما الذي أثاره؟ (اختياري)'**
  String get emotionTrigger;

  /// No description provided for @emotionNeed.
  ///
  /// In ar, this message translates to:
  /// **'ما الذي يحتاجه هذا الشعور الآن؟'**
  String get emotionNeed;

  /// No description provided for @emotionPickFirst.
  ///
  /// In ar, this message translates to:
  /// **'اختيار الشعور أولًا'**
  String get emotionPickFirst;

  /// No description provided for @emotionSaved.
  ///
  /// In ar, this message translates to:
  /// **'حُفظ الشعور في السجل.'**
  String get emotionSaved;

  /// No description provided for @emotionStrong.
  ///
  /// In ar, this message translates to:
  /// **'الشعور قوي الآن. إن رغبت، جلسة «تنفّس هادئ» في تبويب التأمل تتيح بضع دقائق من التنفّس البطيء.'**
  String get emotionStrong;

  /// No description provided for @openMeditation.
  ///
  /// In ar, this message translates to:
  /// **'فتح التأمل'**
  String get openMeditation;

  /// No description provided for @emotionLog.
  ///
  /// In ar, this message translates to:
  /// **'سجل المشاعر'**
  String get emotionLog;

  /// No description provided for @emotionLogEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا مشاعر مسجّلة بعد.'**
  String get emotionLogEmpty;

  /// No description provided for @emotionMostFrequent.
  ///
  /// In ar, this message translates to:
  /// **'الأكثر تكرارًا في آخر 30 يومًا: {feeling}'**
  String emotionMostFrequent(String feeling);

  /// No description provided for @emotionLine.
  ///
  /// In ar, this message translates to:
  /// **'{feeling} · {value} من 10'**
  String emotionLine(String feeling, int value);

  /// No description provided for @toolRecordDeleted.
  ///
  /// In ar, this message translates to:
  /// **'حُذف السجل'**
  String get toolRecordDeleted;

  /// No description provided for @deleteEntry.
  ///
  /// In ar, this message translates to:
  /// **'حذف السجل'**
  String get deleteEntry;

  /// No description provided for @feelingHappy.
  ///
  /// In ar, this message translates to:
  /// **'سعادة'**
  String get feelingHappy;

  /// No description provided for @feelingCalm.
  ///
  /// In ar, this message translates to:
  /// **'هدوء'**
  String get feelingCalm;

  /// No description provided for @feelingGrateful.
  ///
  /// In ar, this message translates to:
  /// **'امتنان'**
  String get feelingGrateful;

  /// No description provided for @feelingHopeful.
  ///
  /// In ar, this message translates to:
  /// **'أمل'**
  String get feelingHopeful;

  /// No description provided for @feelingProud.
  ///
  /// In ar, this message translates to:
  /// **'فخر'**
  String get feelingProud;

  /// No description provided for @feelingTired.
  ///
  /// In ar, this message translates to:
  /// **'تعب'**
  String get feelingTired;

  /// No description provided for @feelingAnxious.
  ///
  /// In ar, this message translates to:
  /// **'قلق'**
  String get feelingAnxious;

  /// No description provided for @feelingStressed.
  ///
  /// In ar, this message translates to:
  /// **'توتر'**
  String get feelingStressed;

  /// No description provided for @feelingSad.
  ///
  /// In ar, this message translates to:
  /// **'حزن'**
  String get feelingSad;

  /// No description provided for @feelingLonely.
  ///
  /// In ar, this message translates to:
  /// **'وحدة'**
  String get feelingLonely;

  /// No description provided for @feelingAngry.
  ///
  /// In ar, this message translates to:
  /// **'غضب'**
  String get feelingAngry;

  /// No description provided for @feelingFrustrated.
  ///
  /// In ar, this message translates to:
  /// **'إحباط'**
  String get feelingFrustrated;

  /// No description provided for @feelingAfraid.
  ///
  /// In ar, this message translates to:
  /// **'خوف'**
  String get feelingAfraid;

  /// No description provided for @feelingGuilty.
  ///
  /// In ar, this message translates to:
  /// **'شعور بالذنب'**
  String get feelingGuilty;

  /// No description provided for @feelingBored.
  ///
  /// In ar, this message translates to:
  /// **'ملل'**
  String get feelingBored;

  /// No description provided for @feelingOverwhelmed.
  ///
  /// In ar, this message translates to:
  /// **'إرهاق'**
  String get feelingOverwhelmed;

  /// No description provided for @bodyHead.
  ///
  /// In ar, this message translates to:
  /// **'الرأس'**
  String get bodyHead;

  /// No description provided for @bodyThroat.
  ///
  /// In ar, this message translates to:
  /// **'الحلق'**
  String get bodyThroat;

  /// No description provided for @bodyChest.
  ///
  /// In ar, this message translates to:
  /// **'الصدر'**
  String get bodyChest;

  /// No description provided for @bodyStomach.
  ///
  /// In ar, this message translates to:
  /// **'البطن'**
  String get bodyStomach;

  /// No description provided for @bodyShoulders.
  ///
  /// In ar, this message translates to:
  /// **'الكتفان'**
  String get bodyShoulders;

  /// No description provided for @bodyHands.
  ///
  /// In ar, this message translates to:
  /// **'اليدان'**
  String get bodyHands;

  /// No description provided for @bodyWhole.
  ///
  /// In ar, this message translates to:
  /// **'كل الجسد'**
  String get bodyWhole;

  /// No description provided for @bodyUnsure.
  ///
  /// In ar, this message translates to:
  /// **'غير واضح'**
  String get bodyUnsure;

  /// No description provided for @needRest.
  ///
  /// In ar, this message translates to:
  /// **'راحة'**
  String get needRest;

  /// No description provided for @needTalk.
  ///
  /// In ar, this message translates to:
  /// **'حديث مع شخص'**
  String get needTalk;

  /// No description provided for @needMovement.
  ///
  /// In ar, this message translates to:
  /// **'حركة'**
  String get needMovement;

  /// No description provided for @needQuiet.
  ///
  /// In ar, this message translates to:
  /// **'وقت هادئ'**
  String get needQuiet;

  /// No description provided for @needSolve.
  ///
  /// In ar, this message translates to:
  /// **'حل أمر عالق'**
  String get needSolve;

  /// No description provided for @needWrite.
  ///
  /// In ar, this message translates to:
  /// **'الكتابة عنه'**
  String get needWrite;

  /// No description provided for @needNothing.
  ///
  /// In ar, this message translates to:
  /// **'لا شيء الآن'**
  String get needNothing;

  /// No description provided for @followUpTitle.
  ///
  /// In ar, this message translates to:
  /// **'آخر خطوة'**
  String get followUpTitle;

  /// No description provided for @followUpQuestion.
  ///
  /// In ar, this message translates to:
  /// **'«{step}». كيف سارت؟'**
  String followUpQuestion(String step);

  /// No description provided for @followUpDone.
  ///
  /// In ar, this message translates to:
  /// **'تمّت'**
  String get followUpDone;

  /// No description provided for @followUpNotYet.
  ///
  /// In ar, this message translates to:
  /// **'لم تتم بعد'**
  String get followUpNotYet;

  /// No description provided for @followUpNoted.
  ///
  /// In ar, this message translates to:
  /// **'سُجّل ذلك.'**
  String get followUpNoted;

  /// No description provided for @historyToolsSection.
  ///
  /// In ar, this message translates to:
  /// **'أدوات المدرب'**
  String get historyToolsSection;

  /// No description provided for @historyWheelFocus.
  ///
  /// In ar, this message translates to:
  /// **'التركيز: {area} ({score})'**
  String historyWheelFocus(String area, int score);

  /// No description provided for @historyStep.
  ///
  /// In ar, this message translates to:
  /// **'الخطوة: {step}'**
  String historyStep(String step);
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
