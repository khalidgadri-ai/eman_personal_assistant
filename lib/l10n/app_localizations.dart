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
