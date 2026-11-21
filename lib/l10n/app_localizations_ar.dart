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

  @override
  String get healthTitle => '🏋️ الصحة واللياقة والعناية';

  @override
  String get awarenessTooltip => 'وعي الاستخدام';

  @override
  String get tabExercises => 'التمارين والعضلات';

  @override
  String get tabMeds => 'جدول الأدوية';

  @override
  String get tabCare => 'العناية بالبشرة';

  @override
  String get tabMeditation => 'التأمل';

  @override
  String exerciseDeleted(String name) {
    return 'حُذف «$name»';
  }

  @override
  String get medAddTitle => 'إضافة دواء أو مكمل';

  @override
  String get nameField => 'الاسم';

  @override
  String get medNameHint => 'مثال: فيتامين د';

  @override
  String get timeOptionalField => 'الوقت (اختياري)';

  @override
  String get medTimeHint => 'مثال: 09:00 صباحاً';

  @override
  String get medEditTitle => 'تعديل الدواء';

  @override
  String get careAddTitle => 'إضافة منتج للروتين';

  @override
  String get productField => 'المنتج';

  @override
  String get careProductHint => 'مثال: مرطب البشرة';

  @override
  String get timeField => 'الوقت';

  @override
  String get careStepField => 'طريقة الاستخدام (اختياري)';

  @override
  String get careEditTitle => 'تعديل المنتج';

  @override
  String get careMorning => 'صباحاً';

  @override
  String get careEvening => 'مساءً';

  @override
  String get careBoth => 'صباحاً ومساءً';

  @override
  String get exerciseAnalysisTitle => '🏋️ تحليل التمرين والعضلات';

  @override
  String get saveAsExercise => 'حفظ كتمرين';

  @override
  String get medReadTitle => '💊 قراءة علبة الدواء';

  @override
  String get medLabelNotice =>
      'هذه قراءة آلية لما على العلبة وقد تخطئ. يُرجى الرجوع إلى نشرة الدواء أو الصيدلي أو الطبيب قبل تناول أي جرعة.';

  @override
  String get okAction => 'حسناً';

  @override
  String get addExercise => 'إضافة تمرين';

  @override
  String get addMedication => 'إضافة دواء';

  @override
  String get addProduct => 'إضافة منتج';

  @override
  String get healthLoadFailed => 'تعذّر فتح بياناتك الصحية المحفوظة.';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get yourExercises => 'تمارينك';

  @override
  String get analyzingImage => 'جارٍ تحليل الصورة بالذكاء الاصطناعي...';

  @override
  String get analyzeExerciseImage => 'تحليل صورة التمرين بالذكاء الاصطناعي';

  @override
  String get exerciseCardsHeader => 'بطاقات التمارين بالجولات والتكرارات';

  @override
  String get logLabel => 'السجل';

  @override
  String get noExercises => 'لم تُضف تمارين بعد.';

  @override
  String get exercisePin => 'تثبيت التمرين';

  @override
  String get exerciseUnpin => 'إلغاء تثبيت التمرين';

  @override
  String get exerciseDelete => 'حذف التمرين';

  @override
  String get medReadHeader => 'قراءة علبة الدواء بالذكاء الاصطناعي';

  @override
  String get medReadBody =>
      'صورة لعلبة الدواء أو المكمل، فيُقرأ ما هو مكتوب عليها: الاسم والجرعة المكتوبة والتحذيرات. القراءة الآلية قد تخطئ، والمرجع نشرة الدواء أو الصيدلي.';

  @override
  String get analyzingMed => 'جارٍ تحليل علبة الدواء...';

  @override
  String get analyzeMed => 'تحليل علبة الدواء 💊';

  @override
  String get medsHeader => 'توقيتات الأدوية والمكملات اليومية';

  @override
  String get noMeds => 'لم تُضف أدوية أو مكملات بعد. اضغط + للإضافة.';

  @override
  String get medDelete => 'حذف الدواء';

  @override
  String get careHeader => 'سجل منتجات الروتين اليومي للبشرة والشعر';

  @override
  String get noCare => 'لم تُضف منتجات بعد. اضغط + للإضافة.';

  @override
  String get careDelete => 'حذف المنتج';

  @override
  String get workoutLogTitle => 'تسجيل تمرين اليوم';

  @override
  String get logAction => 'تسجيل';

  @override
  String get setsField => 'المجموعات';

  @override
  String setsError(int max) {
    return 'أدخل رقمًا من 1 إلى $max';
  }

  @override
  String get repsField => 'التكرار';

  @override
  String get weightField => 'الوزن (اختياري)';

  @override
  String get weightHint => 'مثال: 40 كجم';

  @override
  String get noteOptionalField => 'ملاحظة (اختياري)';

  @override
  String get workoutLogged => 'سُجّل تمرين اليوم';

  @override
  String get exerciseDeleteAsk => 'حذف التمرين؟';

  @override
  String exerciseDeleteBody(String name) {
    return 'سيُحذف «$name» وصورته. سجل تمارينك السابق يبقى.';
  }

  @override
  String get deleteAction => 'حذف';

  @override
  String get exerciseEdit => 'تعديل التمرين';

  @override
  String setsRepsLine(String value) {
    return 'المجموعات والتكرار: $value';
  }

  @override
  String get logToday => 'سجّل اليوم';

  @override
  String exerciseLogOf(String name) {
    return 'سجل «$name»';
  }

  @override
  String get latestLogs => 'آخر التسجيلات';

  @override
  String get stepsHeader => 'خطوات الأداء';

  @override
  String get notesHeader => 'ملاحظات';

  @override
  String get exerciseNameField => 'اسم التمرين';

  @override
  String get musclesField => 'العضلات المستهدفة';

  @override
  String get setsLess => 'تقليل المجموعات';

  @override
  String get setsMore => 'زيادة المجموعات';

  @override
  String get repsHint => '10 أو 8-12';

  @override
  String get addStep => 'إضافة خطوة';

  @override
  String get notesOptional => 'ملاحظات (اختياري)';

  @override
  String get addImage => 'إضافة صورة';

  @override
  String get changeImage => 'تغيير الصورة';

  @override
  String get removeImage => 'إزالة الصورة';

  @override
  String get deleteStep => 'حذف الخطوة';

  @override
  String get workoutLogDefaultTitle => 'سجل التمارين';

  @override
  String get workoutEntryDeleted => 'حُذف التسجيل';

  @override
  String get noWorkouts =>
      'لم تُسجَّل تمارين بعد. افتح تمرينًا واضغط «سجّل اليوم».';

  @override
  String get exerciseFallbackName => 'تمرين';

  @override
  String get workoutEntryDelete => 'حذف التسجيل';

  @override
  String get imageSourceTitle => 'اختيار مصدر الصورة';

  @override
  String get camera => 'الكاميرا';

  @override
  String get gallery => 'المعرض';

  @override
  String draftExercise(String name) {
    return 'التمرين: $name';
  }

  @override
  String draftMuscles(String muscles) {
    return 'العضلات: $muscles';
  }

  @override
  String get draftSteps => 'الخطوات:';

  @override
  String draftNotes(String notes) {
    return 'ملاحظات: $notes';
  }

  @override
  String get meditationGammaNotice =>
      'نغمة جاما للاستماع أثناء التأمل، بمستوى صوت منخفض. لا تُستعمل أثناء القيادة أو تشغيل الآلات. من لديه صرع أو جهاز طبي مزروع يستشير الطبيب قبل الاستعمال. النوع المزدوج يحتاج سماعات.';

  @override
  String get meditationActiveNotice =>
      'الحركة بلطف، في مكان واسع وآمن، والتوقف عند الدوخة أو الألم. من لديه حالة قلبية أو حمل أو إصابة يستشير الطبيب قبل هذه الجلسة.';

  @override
  String get meditationAiVoiceNotice => 'صوت المرشد مولَّد بالذكاء الاصطناعي.';

  @override
  String get noticeBeforeStart => 'ملاحظة قبل البدء';

  @override
  String get understoodStart => 'فهمت، ابدأ';

  @override
  String get meditationLoadFailed => 'تعذّر فتح جلسات التأمل. إعادة المحاولة';

  @override
  String meditationWeekMinutes(int count) {
    return 'دقائق التأمل في آخر 7 أيام: $count';
  }

  @override
  String get meditationScreenOffTip =>
      'الصوت يستمر والشاشة مطفأة، ويمكن الإيقاف من الإشعار.';

  @override
  String get withSubscription => 'مع الاشتراك';

  @override
  String get toneNone => 'بلا نغمة';

  @override
  String get toneBinauralShort => 'جاما مزدوجة (سماعات)';

  @override
  String get toneIsochronicShort => 'جاما نبضية';

  @override
  String get toneBinaural => 'مزدوجة (سماعات)';

  @override
  String get toneIsochronic => 'نبضية (بلا سماعات)';

  @override
  String get durationLabel => 'المدة';

  @override
  String get backgroundSound => 'الصوت في الخلفية';

  @override
  String get startSession => 'ابدأ الجلسة';

  @override
  String minutesShort(int count) {
    return '$count د';
  }

  @override
  String minutesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count دقيقة',
      few: '$count دقائق',
      two: 'دقيقتان',
      one: 'دقيقة واحدة',
    );
    return '$_temp0';
  }

  @override
  String minutesRange(int from, int to) {
    String _temp0 = intl.Intl.pluralLogic(
      to,
      locale: localeName,
      other: 'دقيقة',
      few: 'دقائق',
    );
    return 'من $from إلى $to $_temp0';
  }

  @override
  String get soundFailed => 'تعذّر تشغيل الصوت. حاول مرة أخرى.';

  @override
  String get endSessionAsk => 'إنهاء الجلسة؟';

  @override
  String get endSessionBody => 'تُحفظ الدقائق التي مضت إن كانت دقيقة أو أكثر.';

  @override
  String get continueSession => 'متابعة الجلسة';

  @override
  String get endAction => 'إنهاء';

  @override
  String phaseOf(int current, int total) {
    return 'المرحلة $current من $total';
  }

  @override
  String get timeLeft => 'الوقت المتبقي';

  @override
  String get gammaLevel => 'مستوى نغمة جاما';

  @override
  String get pauseAction => 'إيقاف مؤقت';

  @override
  String get resumeAction => 'متابعة';

  @override
  String get sessionFinished => 'انتهت الجلسة';

  @override
  String sessionMinutes(int count) {
    return 'دقائق هذه الجلسة: $count';
  }

  @override
  String get sessionUnderMinute => 'الجلسات الأقصر من دقيقة لا تُحفظ في السجل.';

  @override
  String get meditationChannelName => 'جلسات التأمل';

  @override
  String get kitchenTitle => '🥗 المطبخ والمؤونة والغسيل';

  @override
  String get tabRecipes => 'الوصفات والوجبات';

  @override
  String get tabPantry => 'المؤونة والمستلزمات';

  @override
  String get tabShopping => 'المشتريات';

  @override
  String get tabLaundry => 'جدول الغسيل';

  @override
  String get addRecipe => 'إضافة وصفة';

  @override
  String get addPantryItem => 'إضافة صنف';

  @override
  String get addShoppingItem => 'إضافة بند للمشتريات';

  @override
  String get addLaundry => 'إضافة موعد غسيل';

  @override
  String get recipeBreakfast => 'فطور';

  @override
  String get recipeLunch => 'غداء';

  @override
  String get recipeDinner => 'عشاء';

  @override
  String get recipeSnack => 'وجبة خفيفة';

  @override
  String get recipeDessert => 'حلويات';

  @override
  String get recipeAi => 'ذكاء اصطناعي';

  @override
  String get otherCategory => 'أخرى';

  @override
  String get pantryOils => 'الزيوت والبهارات';

  @override
  String get pantryGrains => 'الحبوب والبقوليات';

  @override
  String get pantryProduce => 'الخضار والفواكه';

  @override
  String get pantryDairyMeat => 'الألبان واللحوم';

  @override
  String get pantryNuts => 'المكسرات';

  @override
  String get pantryCleaning => 'مستلزمات التنظيف';

  @override
  String get daySat => 'السبت';

  @override
  String get daySun => 'الأحد';

  @override
  String get dayMon => 'الاثنين';

  @override
  String get dayTue => 'الثلاثاء';

  @override
  String get dayWed => 'الأربعاء';

  @override
  String get dayThu => 'الخميس';

  @override
  String get dayFri => 'الجمعة';

  @override
  String get sourceOutOfStock => 'نفد من المؤونة';

  @override
  String get recipeNeedIngredients => '⚠️ يرجى كتابة المكونات أولاً';

  @override
  String get recipeSuggested => 'وصفة مقترحة 🍽️';

  @override
  String get saveToRecipes => 'حفظ في الوصفات';

  @override
  String aiRecipeFallbackTitle(String first) {
    return 'وصفة ذكية: $first';
  }

  @override
  String get recipeAdded => '✅ تمت إضافة الوصفة';

  @override
  String recipeDeleted(String title) {
    return 'حُذفت «$title»';
  }

  @override
  String get recipesHeader => 'موسوعة الوصفات وتفاصيل المقادير';

  @override
  String get recipesEmpty =>
      'لا توجد وصفات بعد. اضغط + لإضافة وصفة، أو دع الذكاء الاصطناعي يقترح لك.';

  @override
  String servingsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count حصة',
      few: '$count حصص',
      two: 'حصتان',
      one: 'حصة واحدة',
    );
    return '$_temp0';
  }

  @override
  String ingredientsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مكوّن',
      few: '$count مكوّنات',
      two: 'مكوّنان',
      one: 'مكوّن واحد',
    );
    return '$_temp0';
  }

  @override
  String stepsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count خطوة',
      few: '$count خطوات',
      two: 'خطوتان',
      one: 'خطوة واحدة',
    );
    return '$_temp0';
  }

  @override
  String get recipePin => 'تثبيت الوصفة';

  @override
  String get recipeUnpin => 'إلغاء تثبيت الوصفة';

  @override
  String get recipeDelete => 'حذف الوصفة';

  @override
  String ingredientsLine(String text) {
    return 'المقادير: $text';
  }

  @override
  String get aiRecipeTitle => '🧑‍🍳 توليد وصفة بالذكاء الاصطناعي';

  @override
  String get aiRecipePrompt =>
      'اكتب المكونات المتاحة في مطبخك (مفصولة بفواصل):';

  @override
  String get aiRecipeHint => 'مثال: دجاج، أرز، طماطم، بصل، بهارات...';

  @override
  String get aiRecipeWorking => 'جارٍ توليد الوصفة...';

  @override
  String get aiRecipeSuggest => 'اقترح وصفة الآن ✨';

  @override
  String get pantryAddTitle => 'إضافة صنف للمؤونة';

  @override
  String get itemField => 'الصنف';

  @override
  String get qtyOptionalField => 'الكمية (اختياري)';

  @override
  String get pantryQtyHint => 'مثال: 2 لتر';

  @override
  String get pantryEditTitle => 'تعديل الصنف';

  @override
  String itemDeleted(String name) {
    return 'حُذف «$name»';
  }

  @override
  String movedToShopping(String name) {
    return 'نُقل «$name» إلى المشتريات';
  }

  @override
  String get pantryHeader => 'مخزون المطبخ واحتياجات المنزل';

  @override
  String get pantryEmpty => 'المؤونة فارغة. اضغط + لإضافة أول صنف.';

  @override
  String get pantrySearchHint => 'بحث في المؤونة والمستلزمات';

  @override
  String get clearSearch => 'مسح البحث';

  @override
  String get filterAll => 'الكل';

  @override
  String get noSearchResults => 'لا نتائج مطابقة للبحث.';

  @override
  String get pinnedSection => '📌 المثبّتة';

  @override
  String get qtyLess => 'نقصان الكمية';

  @override
  String get qtyMore => 'زيادة الكمية';

  @override
  String get moreActions => 'المزيد';

  @override
  String get editAction => 'تعديل';

  @override
  String get pinAction => 'تثبيت';

  @override
  String get unpinAction => 'إلغاء التثبيت';

  @override
  String get outToShopping => 'نفد: إلى المشتريات';

  @override
  String get shoppingAddTitle => 'إضافة بند للمشتريات';

  @override
  String get shoppingItemField => 'البند';

  @override
  String get shoppingQtyHint => 'مثال: 2 كجم';

  @override
  String get shoppingEditTitle => 'تعديل البند';

  @override
  String get shoppingHeader => 'قائمة المشتريات';

  @override
  String get shoppingEmpty =>
      'قائمة المشتريات فارغة. اضغط + لإضافة بند، أو أضف مقادير وصفة من صفحتها.';

  @override
  String movedToPantry(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'نُقل $count بند إلى المؤونة',
      many: 'نُقل $count بندًا إلى المؤونة',
      few: 'نُقلت $count بنود إلى المؤونة',
      two: 'نُقل بندان إلى المؤونة',
      one: 'نُقل بند واحد إلى المؤونة',
    );
    return '$_temp0';
  }

  @override
  String get moveBoughtToPantry => 'نقل المشتراة إلى المؤونة';

  @override
  String get clearBought => 'مسح المشتراة';

  @override
  String shoppingFrom(String source) {
    return 'من: $source';
  }

  @override
  String get shoppingDelete => 'حذف البند';

  @override
  String get laundryAddTitle => 'إضافة موعد غسيل';

  @override
  String get dayField => 'اليوم';

  @override
  String get laundryTypeField => 'نوع الغسيل';

  @override
  String get laundryTypeHint => 'مثال: الملابس الملونة';

  @override
  String get instructionsOptional => 'التعليمات (اختياري)';

  @override
  String get laundryEditTitle => 'تعديل موعد الغسيل';

  @override
  String laundryDeleted(String type) {
    return 'حُذف موعد «$type»';
  }

  @override
  String get laundryHeader => 'جدول العناية بالأقمشة والغسيل الأسبوعي';

  @override
  String get laundryEmpty => 'لا توجد مواعيد غسيل بعد. اضغط + لإضافة موعد.';

  @override
  String instructionsLine(String text) {
    return 'التعليمات: $text';
  }

  @override
  String get laundryDelete => 'حذف الموعد';

  @override
  String get recipeDeleteAsk => 'حذف الوصفة؟';

  @override
  String recipeDeleteBody(String title) {
    return 'ستُحذف «$title» من وصفاتك.';
  }

  @override
  String addedToShopping(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'أُضيف $count بند إلى المشتريات',
      many: 'أُضيف $count بندًا إلى المشتريات',
      few: 'أُضيفت $count بنود إلى المشتريات',
      two: 'أُضيف بندان إلى المشتريات',
      one: 'أُضيف بند واحد إلى المشتريات',
    );
    return '$_temp0';
  }

  @override
  String alreadyInList(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count بند موجود في القائمة أصلًا',
      many: '$count بندًا موجودًا في القائمة أصلًا',
      few: '$count بنود موجودة في القائمة أصلًا',
      two: 'بندان موجودان في القائمة أصلًا',
      one: 'بند واحد موجود في القائمة أصلًا',
    );
    return '$_temp0';
  }

  @override
  String get recipeEdit => 'تعديل الوصفة';

  @override
  String get ingredientsHeader => 'المقادير';

  @override
  String get noIngredients => 'لم تُضف مقادير بعد.';

  @override
  String get addIngredientsToShopping => 'أضف المقادير إلى المشتريات';

  @override
  String get prepSteps => 'خطوات التحضير';

  @override
  String servingsScaled(int servings, int original) {
    String _temp0 = intl.Intl.pluralLogic(
      servings,
      locale: localeName,
      other: '$servings حصة',
      few: '$servings حصص',
      two: 'حصتان',
      one: 'حصة واحدة',
    );
    return '$_temp0 (الأصل $original)';
  }

  @override
  String get servingsLess => 'تقليل الحصص';

  @override
  String get servingsMore => 'زيادة الحصص';

  @override
  String get whatToShopping => 'ما الذي تريد إضافته للمشتريات؟';

  @override
  String get inPantry => 'موجود في المؤونة';

  @override
  String addCount(int count) {
    return 'إضافة ($count)';
  }

  @override
  String get ingredientNameRequired => 'اسم المكوّن مطلوب';

  @override
  String get invalidAmount => 'كمية غير صالحة';

  @override
  String get mealNameField => 'اسم الوجبة';

  @override
  String get servingsField => 'عدد الحصص';

  @override
  String get freeTextIngredients => 'مقادير مكتوبة كنص حر:';

  @override
  String get convertIngredients => 'تحويل إلى مقادير منظّمة';

  @override
  String get addIngredient => 'إضافة مكوّن';

  @override
  String get ingredientField => 'المكوّن';

  @override
  String get amountField => 'الكمية';

  @override
  String get unitField => 'الوحدة';

  @override
  String get unitHint => 'كوب';

  @override
  String get deleteIngredient => 'حذف المكوّن';

  @override
  String stepNumber(int number) {
    return 'الخطوة $number';
  }

  @override
  String get recipeTypeField => 'النوع';
}
