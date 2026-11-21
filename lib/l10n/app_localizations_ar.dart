// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get navGoals => 'الأهداف والمهام';

  @override
  String get navHealth => 'الصحة واللياقة';

  @override
  String get navKitchen => 'المطبخ والمنزل';

  @override
  String get navBudget => 'الميزانية';

  @override
  String get navAssistant => 'المساعد الذكي';

  @override
  String get coachTooltip => 'مدرب الحياة';

  @override
  String get contactUs => 'تواصل معنا';

  @override
  String get contactMailFailed =>
      'لم يُفتح تطبيق البريد. يمكنك مراسلتنا على هذا العنوان:';

  @override
  String get close => 'إغلاق';

  @override
  String get copyAddress => 'نسخ العنوان';

  @override
  String get cancel => 'إلغاء';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get settingsAiProvider => 'مزوّد الذكاء الاصطناعي';

  @override
  String get settingsAiProviderHint =>
      'لتفعيل ميزات الذكاء الاصطناعي بمفتاحك الخاص';

  @override
  String get settingsTour => 'جولة التعريف بالتطبيق';

  @override
  String get settingsTourHint =>
      'شرح قصير لكل أقسام التطبيق وطريقة الحصول على مفتاح';

  @override
  String get settingsLanguage => 'اللغة';

  @override
  String get languageSystem => 'لغة الجوال';

  @override
  String get languageArabic => 'العربية';

  @override
  String get languageEnglish => 'English';

  @override
  String get profileNoName => 'بدون اسم';

  @override
  String get profileEdit => 'تعديل ملفي';

  @override
  String get profileEmpty =>
      'لم تُضف اسمًا أو اهتمامات بعد. تُحفظ مشفّرة على جهازك فقط.';

  @override
  String get backupSaveTitle => 'حفظ نسخة احتياطية مشفّرة';

  @override
  String get backupSaveHint => 'ملف محميّ بكلمة مرور يُحفظ خارج التطبيق';

  @override
  String get backupSaving => 'جارٍ التشفير، قد يستغرق ذلك عدة ثوانٍ...';

  @override
  String get backupRestoreTitle => 'استعادة من نسخة احتياطية';

  @override
  String get backupRestoreHint => 'استبدال بيانات هذا الجهاز بما في ملف النسخة';

  @override
  String get backupRestoring => 'جارٍ فتح النسخة، قد يستغرق ذلك عدة ثوانٍ...';

  @override
  String get backupSaved =>
      'حُفظت النسخة الاحتياطية. كلمة المرور لا تُسترجع، فيجب الاحتفاظ بها.';

  @override
  String get backupNotSaved => 'لم تُحفظ النسخة الاحتياطية.';

  @override
  String get backupRestoreAsk => 'استعادة نسخة احتياطية؟';

  @override
  String get backupRestoreBody =>
      'ستُستبدل بيانات هذا الجهاز كلها (الملف الشخصي والمهام والأهداف والصحة والمطبخ والمصاريف وجلسات المدرب) بما في النسخة. مفاتيح الذكاء الاصطناعي لا تتأثر.';

  @override
  String get backupChooseFile => 'اختيار الملف';

  @override
  String get backupRestored => 'تمت استعادة النسخة الاحتياطية.';

  @override
  String get backupGenericError => 'تعذّر إتمام العملية. لم تتغير البيانات.';

  @override
  String get passwordTitle => 'كلمة مرور النسخة';

  @override
  String get passwordNoRecovery =>
      'لا توجد طريقة لاسترجاع كلمة المرور. بدونها لا يمكن فتح النسخة أبدًا.';

  @override
  String passwordHintNew(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count حرف على الأقل',
      many: '$count حرفًا على الأقل',
      few: '$count أحرف على الأقل',
      two: 'حرفان على الأقل',
      one: 'حرف واحد على الأقل',
    );
    return 'كلمة المرور ($_temp0)';
  }

  @override
  String get passwordHint => 'كلمة المرور';

  @override
  String get passwordConfirmHint => 'تأكيد كلمة المرور';

  @override
  String get passwordMismatch => 'كلمتا المرور غير متطابقتين.';

  @override
  String get passwordRequired => 'يرجى كتابة كلمة المرور.';

  @override
  String get show => 'إظهار';

  @override
  String get hide => 'إخفاء';

  @override
  String get continueAction => 'متابعة';

  @override
  String get restoreAction => 'استعادة';

  @override
  String get eraseTitle => 'مسح كل بياناتي';

  @override
  String get eraseHint =>
      'يحذف كل ما أدخلته من هذا الجهاز ويعيد التطبيق كأول تشغيل';

  @override
  String get eraseAsk => 'مسح كل بياناتي؟';

  @override
  String get eraseBody =>
      'سيُحذف نهائيًا من هذا الجهاز كل ما أدخلته: الملف الشخصي والمهام والأهداف والصحة والمطبخ والمصاريف وجلسات المدرب ومفاتيح الذكاء الاصطناعي. لا يمكن التراجع.';

  @override
  String get eraseConfirm => 'مسح كل شيء';

  @override
  String get eraseFailed => 'تعذّر مسح البيانات. لم يُحذف شيء، حاول مرة أخرى.';

  @override
  String get back => 'رجوع';

  @override
  String get next => 'التالي';

  @override
  String get skip => 'تخطي';

  @override
  String get save => 'حفظ';

  @override
  String get start => 'ابدأ';

  @override
  String get interestHealth => 'الصحة واللياقة';

  @override
  String get interestGrowth => 'التنمية الذاتية';

  @override
  String get interestReading => 'القراءة';

  @override
  String get interestFaith => 'العبادة والروحانيات';

  @override
  String get interestBudget => 'الميزانية والادخار';

  @override
  String get interestKitchen => 'المطبخ والوصفات';

  @override
  String get interestHome => 'تنظيم المنزل';

  @override
  String get interestSkills => 'تعلّم مهارات جديدة';

  @override
  String get interestWork => 'العمل والإنتاجية';

  @override
  String get interestFamily => 'الأسرة';

  @override
  String get onboardingWelcome => 'أهلًا بك في إيمان';

  @override
  String get onboardingIntro =>
      'مساعدك الشخصي للمهام والصحة والمطبخ والميزانية. كل ما تدخله يبقى على جهازك.';

  @override
  String get onboardingNameQuestion => 'ما اسمك؟';

  @override
  String get onboardingNameLabel => 'ما اسمك؟ (اختياري)';

  @override
  String get onboardingInterestsTitle => 'ما الذي يهمّك؟';

  @override
  String get onboardingInterestsHint =>
      'اختر ما يناسبك، ويمكنك تغييره لاحقًا من الإعدادات.';

  @override
  String get onboardingGoalsTitle => 'أهدافك (اختياري)';

  @override
  String get onboardingGoalLabel => 'اكتب هدفًا ثم اضغط +';

  @override
  String get onboardingGoalHint => 'مثال: قراءة 20 صفحة يوميًا';

  @override
  String get onboardingAddGoal => 'إضافة هدف';

  @override
  String get onboardingRemoveGoal => 'حذف الهدف';

  @override
  String get onboardingPrivacy =>
      'تُحفظ هذه المعلومات مشفّرة على جهازك. وإن فعّلت المساعد الذكي بمفتاحك، تُرسل مع طلباته إلى مزوّد الذكاء الاصطناعي الذي تختاره لتخصيص الردود.';

  @override
  String get onboardingSaveFailed => 'تعذّر الحفظ على جهازك. حاول مرة أخرى.';

  @override
  String tourPageOf(int page, int total) {
    return 'صفحة $page من $total';
  }

  @override
  String get tourIntroTitle => 'جولة قصيرة';

  @override
  String get tourIntro1 => 'سنعرّفك على التطبيق في 10 صفحات قصيرة.';

  @override
  String get tourIntro2 => 'في كل صفحة فكرة واحدة فقط.';

  @override
  String get tourIntro3 => 'يمكنك الرجوع لأي صفحة بزر «رجوع».';

  @override
  String get tourTasksTitle => 'الأهداف والمهام';

  @override
  String get tourTasks1 => 'اكتب مهمة صغيرة واحدة بزر «+».';

  @override
  String get tourTasks2 => 'حين تنتهي منها، ضع علامة ✓ بجانبها.';

  @override
  String get tourTasksExample => 'مثال: «اشترِ الخبز».';

  @override
  String get tourGoalsTitle => 'قسّم الكبير إلى صغير';

  @override
  String get tourGoals1 => 'الهدف الكبير يصبح سهلًا إذا قسّمته.';

  @override
  String get tourGoals2 => 'حرّك شريط التقدّم كلما أنجزت جزءًا.';

  @override
  String get tourGoalsExample =>
      'مثال: «ترتيب البيت» هدف شهري، و«ترتيب غرفة النوم» هدف أسبوعي، و«ترتيب درج واحد» مهمة اليوم.';

  @override
  String get tourRemindersTitle => 'التذكير';

  @override
  String get tourReminders1 =>
      'يمكنك أن تضع وقتًا للمهمة أو للدواء فيصلك تنبيه.';

  @override
  String get tourReminders2 => 'حين يسألك الجوال عن الإشعارات اضغط «السماح».';

  @override
  String get tourReminders3 => 'قد يتأخر التنبيه دقائق قليلة.';

  @override
  String get tourHealthTitle => 'الصحة واللياقة';

  @override
  String get tourHealth1 => 'سجّل تمارينك، ومواعيد أدويتك، وروتين العناية.';

  @override
  String get tourHealthExample => 'مثال: دواء الصباح الساعة 8.';

  @override
  String get tourKitchenTitle => 'المطبخ والمنزل';

  @override
  String get tourKitchen1 =>
      'وصفاتك، وما عندك في البيت، وقائمة المشتريات، وجدول الغسيل.';

  @override
  String get tourKitchen2 => 'ما ينقص من البيت يمكنك نقله إلى المشتريات.';

  @override
  String get tourBudgetTitle => 'الميزانية';

  @override
  String get tourBudget1 =>
      'اكتب دخلك ومصاريفك الثابتة مرة واحدة، فيحسب لك التطبيق كم يمكنك أن تصرف اليوم.';

  @override
  String get tourBudget2 => 'كل الأرقام تبقى على جوالك.';

  @override
  String get tourCoachTitle => 'المدرب والمساعد الذكي';

  @override
  String get tourCoach1 =>
      'زر المدرب (أيقونة الرأس في أسفل وسط الشاشة) يسألك أسئلة تساعدك تفكّر وترتّب أمورك.';

  @override
  String get tourCoach2 =>
      'أما المساعد الذكي فيجيب أسئلتك، لكنه يحتاج مفتاحًا: الصفحة التالية تشرح كيف تحصل عليه.';

  @override
  String get tourKeyTitle => 'مفتاح الذكاء الاصطناعي';

  @override
  String get tourStartTitle => 'ابدأ بخطوة واحدة';

  @override
  String get tourStart1 => 'لا تحاول ترتيب كل شيء اليوم.';

  @override
  String get tourStart2 => 'اختر شيئًا صغيرًا واحدًا وابدأ به.';

  @override
  String get tourStart3 => 'يمكنك إعادة هذه الجولة من الإعدادات.';

  @override
  String get tourSaveFailed => 'تعذّر حفظ إنهاء الجولة على جهازك.';

  @override
  String get tourKeySaved => '✓ تم حفظ المفتاح';

  @override
  String get tourAddKeyNow => 'أضف المفتاح الآن';

  @override
  String get tourAddKeyLater => 'سأضيفه لاحقًا';

  @override
  String get tourFinishFirstRun => 'ابدأ استعمال التطبيق';

  @override
  String get tourFinish => 'إنهاء';

  @override
  String get keyGuideTitle => 'كيف أحصل على مفتاح؟';

  @override
  String get keyGuideIntro =>
      'المفتاح مثل كلمة سرّ خاصة بك من المزوّد، يسمح للتطبيق أن يسأل الذكاء الاصطناعي باسمك.';

  @override
  String keyGuideStepsWith(String provider) {
    return 'الخطوات مع $provider:';
  }

  @override
  String get keyGuideGemini1 => 'اضغط «افتح صفحة المفاتيح».';

  @override
  String get keyGuideGemini2 => 'سجّل الدخول بحساب Google.';

  @override
  String get keyGuideGemini3 => 'وافق على الشروط إن ظهرت.';

  @override
  String get keyGuideGemini4 =>
      'اضغط الزر المكتوب عليه Create API key (قد يظهر بلغة جوالك).';

  @override
  String get keyGuideGemini5 => 'انسخ المفتاح.';

  @override
  String get keyGuideGemini6 =>
      'ارجع إلى التطبيق والصقه في خانة «المفتاح»، ثم اضغط «حفظ وتفعيل».';

  @override
  String get keyGuideOther1 => 'اضغط «افتح صفحة المفاتيح».';

  @override
  String get keyGuideOther2 => 'سجّل الدخول.';

  @override
  String get keyGuideOther3 => 'أنشئ مفتاحًا جديدًا.';

  @override
  String get keyGuideOther4 =>
      'انسخ المفتاح، ثم ارجع إلى التطبيق والصقه في خانة «المفتاح»، ثم اضغط «حفظ وتفعيل».';

  @override
  String get keyGuideGeminiFree =>
      'لـ Gemini استعمال مجاني ضمن حدود تضعها Google. وإن فعّلت الدفع في حسابك عند Google فقد تُحتسب عليك رسوم.';

  @override
  String get keyGuidePaymentNote =>
      'قد يطلب بعض المزوّدين إضافة وسيلة دفع قبل أن يعمل المفتاح.';

  @override
  String get keyGuideDontShare =>
      'لا تشارك مفتاحك مع أحد ولا تنشره. يُحفظ على جوالك فقط.';

  @override
  String get keyGuideOpenPage => 'افتح صفحة المفاتيح';

  @override
  String get keyGuideLinkCopied => 'تم نسخ الرابط. الصقه في المتصفح.';

  @override
  String get add => 'إضافة';

  @override
  String get undo => 'تراجع';

  @override
  String get fieldRequired => 'هذا الحقل مطلوب';

  @override
  String get reminderNone => 'بدون تذكير';

  @override
  String reminderAt(String time) {
    return 'يوميًا عند $time';
  }

  @override
  String get reminderSet => 'ضبط تذكير';

  @override
  String get reminderChange => 'تغيير الوقت';

  @override
  String get reminderRemove => 'إزالة التذكير';

  @override
  String get reminderMedicationTitle => 'تذكير بالدواء';

  @override
  String get reminderRoutineTitle => 'تذكير بالعناية';

  @override
  String get reminderTaskTitle => 'تذكير بمهمة';

  @override
  String get reminderNotScheduled =>
      'لم يُضبط التذكير. يلزم تفعيل إشعارات هذا التطبيق من إعدادات الجوال ثم إعادة المحاولة.';

  @override
  String get notificationChannelName => 'تذكيرات الحياة والمنزل';

  @override
  String get notificationChannelDescription =>
      'تذكيرات الأدوية وروتين العناية والمهام التي تضبطها بنفسك';

  @override
  String get tasksTitle => '🎯 الأهداف والمهام اليومية';

  @override
  String get voiceImportTooltip => 'استيراد مهام من المذكرة الصوتية';

  @override
  String get tabDailyTasks => 'المهام اليومية';

  @override
  String get tabGoals => 'الأهداف الهرمية';

  @override
  String get tabWird => 'الورد والتتبع';

  @override
  String get taskAddTitle => 'إضافة مهمة جديدة';

  @override
  String get taskField => 'المهمة';

  @override
  String get taskHint => 'اكتب نص المهمة...';

  @override
  String get categoryField => 'التصنيف';

  @override
  String get reminderField => 'تذكير';

  @override
  String get taskEditTitle => 'تعديل المهمة';

  @override
  String taskDeleted(String title) {
    return 'حُذفت «$title»';
  }

  @override
  String get addTask => 'إضافة مهمة';

  @override
  String get taskPin => 'تثبيت المهمة';

  @override
  String get taskUnpin => 'إلغاء تثبيت المهمة';

  @override
  String get taskDelete => 'حذف المهمة';

  @override
  String get tasksHeader => 'مركز إدارة المهام المقسمة';

  @override
  String get tasksVoiceTip =>
      'اضغط على أيقونة الميكروفون 🎙️ في الأعلى لاستيراد مهام من مذكرتك الصوتية';

  @override
  String get tasksEmpty =>
      'لا توجد مهام بعد. اضغط + لإضافة مهمة أو استخدم المذكرة الصوتية.';

  @override
  String get catPersonal => 'شخصي';

  @override
  String get catHome => 'المنزل';

  @override
  String get catWork => 'العمل';

  @override
  String get catFamily => 'العائلة';

  @override
  String get goalAdd => 'إضافة هدف';

  @override
  String get goalField => 'الهدف';

  @override
  String get goalTypeField => 'النوع';

  @override
  String get goalEditTitle => 'تعديل الهدف';

  @override
  String goalDeleted(String title) {
    return 'حُذف الهدف «$title»';
  }

  @override
  String get goalPin => 'تثبيت الهدف';

  @override
  String get goalUnpin => 'إلغاء تثبيت الهدف';

  @override
  String get goalDelete => 'حذف الهدف';

  @override
  String get goalsHeader =>
      'محرك الأهداف الهرمية (السنوية ⬅️ الشهرية ⬅️ الأسبوعية)';

  @override
  String get goalsEmpty => 'لا توجد أهداف بعد. اضغط + لإضافة هدفك الأول.';

  @override
  String get goalTypeGeneral => 'هدف عام';

  @override
  String get goalTypeYearly => 'هدف سنوي';

  @override
  String get goalTypeMonthly => 'هدف شهري';

  @override
  String get goalTypeWeekly => 'هدف أسبوعي';

  @override
  String get wirdTitle => 'متتبع الورد اليومي والقرآن الكريم';

  @override
  String wirdCurrentPage(int page) {
    return 'الصفحة الحالية: $page';
  }

  @override
  String get wirdFinished => 'أتممت الختمة 🎉 بارك الله فيك';

  @override
  String wirdRemaining(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count صفحة',
      many: '$count صفحة',
      few: '$count صفحات',
      two: 'صفحتان',
      one: 'صفحة واحدة',
    );
    return 'المتبقي لإتمام الختمة: $_temp0';
  }

  @override
  String get wirdReadOne => 'تم قراءة صفحة (+1)';

  @override
  String get wirdSetPage => 'تحديد الصفحة';

  @override
  String get wirdSetTitle => 'تحديد الصفحة الحالية';

  @override
  String wirdPageField(int max) {
    return 'رقم الصفحة (0 - $max)';
  }

  @override
  String wirdPageError(int max) {
    return 'أدخل رقمًا من 0 إلى $max';
  }

  @override
  String get voiceTitle => '🎙️ استيراد من المذكرة الصوتية';

  @override
  String get voicePrompt => 'اكتب نص المذكرة الصوتية أو ما تريد تحويله لمهام:';

  @override
  String get voiceHint =>
      'مثال: أريد اليوم إنهاء التقرير، والذهاب للسوق، وترتيب الخزانة...';

  @override
  String get voiceExtracted => 'المهام المستخرجة:';

  @override
  String get voiceExtracting => 'جارٍ الاستخراج...';

  @override
  String get voiceExtract => 'استخرج المهام 🧠';

  @override
  String get voiceImport => 'استورد المهام للقائمة ✅';

  @override
  String voiceImported(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '✅ تم استيراد $count مهمة بنجاح',
      many: '✅ تم استيراد $count مهمة بنجاح',
      few: '✅ تم استيراد $count مهام بنجاح',
      two: '✅ تم استيراد مهمتين بنجاح',
      one: '✅ تم استيراد مهمة واحدة بنجاح',
      zero: 'لم تُستورد أي مهمة',
    );
    return '$_temp0';
  }
}
