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
