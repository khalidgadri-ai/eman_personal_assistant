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

  @override
  String get expenseFood => 'طعام';

  @override
  String get expenseTransport => 'مواصلات';

  @override
  String get expenseEntertainment => 'ترفيه';

  @override
  String get expenseBills => 'فواتير';

  @override
  String get expenseShopping => 'تسوق';

  @override
  String get percentSign => '٪';

  @override
  String get listSeparator => '، ';

  @override
  String get planSaved => 'حُفظت خطة الميزانية';

  @override
  String get limitsSaved => 'حُفظت الحدود. عدّلها من «تعديل الخطة»';

  @override
  String get budgetTitle => '💰 المحفظة المالية والميزانية';

  @override
  String get monthlyExpenses => 'مصاريفي الشهرية';

  @override
  String get budgetOpenFailed => 'تعذّر فتح بيانات الميزانية';

  @override
  String get setupBudgetTitle => 'ابدأ بإعداد ميزانيتك';

  @override
  String get setupBudgetBody =>
      'أدخل دخلك الشهري ويوم نزول الراتب ومصروفاتك الثابتة، وسنحسب لك كم يبقى لك وكم تصرف يوميًا. تُحفظ كل بياناتك على جهازك مشفّرة.';

  @override
  String get setupBudgetButton => 'إعداد الميزانية';

  @override
  String get currentCycleBudget => 'ميزانية الدورة الحالية';

  @override
  String daysLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'باقي $count يوم',
      many: 'باقي $count يومًا',
      few: 'باقي $count أيام',
      two: 'باقي يومان',
      one: 'باقي يوم واحد',
    );
    return '$_temp0';
  }

  @override
  String cycleRange(String start, String end) {
    return 'من $start إلى $end';
  }

  @override
  String get remainingLabel => 'المتبقي';

  @override
  String spentPercent(int percent) {
    return 'صرفت $percent٪ من المتاح';
  }

  @override
  String get incomeLabel => 'الدخل';

  @override
  String get fixedExpenses => 'المصروفات الثابتة';

  @override
  String get savingsLabel => 'الادخار';

  @override
  String get availableToSpend => 'المتاح للصرف';

  @override
  String get spentSoFar => 'المصروف حتى الآن';

  @override
  String get dailyAvailable => 'المتاح يوميًا';

  @override
  String overcommittedWarning(String amount) {
    return 'المصروفات الثابتة والادخار ($amount) أكبر من دخلك. عدّل الخطة.';
  }

  @override
  String overspentWarning(String amount) {
    return 'تجاوزت المتاح في هذه الدورة بمقدار $amount.';
  }

  @override
  String nearEndWarning(int percent, String amount) {
    return 'اقتربت من نهاية المتاح: صرفت $percent٪ ويبقى $amount.';
  }

  @override
  String get editPlan => 'تعديل الخطة';

  @override
  String get suggestBudget => 'اقتراح ميزانية';

  @override
  String paidCount(int paid, int total) {
    return 'دُفع $paid من $total';
  }

  @override
  String dueDayLine(int day) {
    return 'يوم $day من الشهر';
  }

  @override
  String dueDayAmount(int day, String amount) {
    return 'يوم $day من الشهر · $amount';
  }

  @override
  String get byCategory => 'الصرف حسب الفئة';

  @override
  String get noCategorySpending =>
      'لا صرف مسجَّل في هذه الدورة ولا حدود للفئات. يمكنك اقتراح حدود من «اقتراح ميزانية».';

  @override
  String overLimit(String category, String amount) {
    return 'تجاوزت حد «$category» بمقدار $amount.';
  }

  @override
  String nearLimit(String category, int percent) {
    return 'اقتربت من حد «$category»: صرفت $percent٪ منه.';
  }

  @override
  String get recentExpenses => 'آخر المصاريف';

  @override
  String get noRecentExpenses => 'لا مصاريف مسجَّلة في هذه الدورة بعد.';

  @override
  String get recordExpense => 'سجّل مصروف';

  @override
  String get allExpenses => 'كل المصاريف';

  @override
  String get invalidAmountPositive => 'أدخل مبلغًا صحيحًا أكبر من صفر';

  @override
  String get percentRange => 'أدخل نسبة بين 0 و100';

  @override
  String get savingsAmountInvalid => 'أدخل مبلغًا صحيحًا (أو اتركه فارغًا)';

  @override
  String get checkRedFields => 'راجع الحقول المعلَّمة بالأحمر ثم احفظ مرة أخرى';

  @override
  String get planSaveFailed => 'تعذّر حفظ الخطة. حاول مرة أخرى';

  @override
  String get unsavedChanges => 'تعديلات غير محفوظة';

  @override
  String get unsavedPlanBody =>
      'لم تحفظ التغييرات على خطة الميزانية. هل تحفظها قبل الخروج؟';

  @override
  String get keepEditing => 'متابعة التعديل';

  @override
  String get leaveWithoutSaving => 'خروج بلا حفظ';

  @override
  String get savePlan => 'حفظ الخطة';

  @override
  String get newFixedExpense => 'مصروف ثابت جديد';

  @override
  String get editFixedExpense => 'تعديل المصروف الثابت';

  @override
  String get expenseName => 'اسم المصروف';

  @override
  String get expenseNameHint => 'مثال: إيجار';

  @override
  String get amountLabel => 'المبلغ';

  @override
  String get dueDayField => 'يوم الاستحقاق (من 1 إلى 31)';

  @override
  String get dueDayInvalid => 'أدخل يومًا من 1 إلى 31';

  @override
  String get budgetPlanTitle => 'خطة الميزانية';

  @override
  String get incomeAndCycle => 'الدخل والدورة';

  @override
  String get monthlyIncome => 'الدخل الشهري';

  @override
  String get paydayField => 'يوم نزول الراتب';

  @override
  String get paydayHelper => 'تبدأ دورة الميزانية من هذا اليوم كل شهر';

  @override
  String get currencyField => 'العملة';

  @override
  String get fixedEmptyHint =>
      'أضف ما يتكرر كل شهر: إيجار، أقساط، اشتراكات، فواتير.';

  @override
  String deleteNamed(String name) {
    return 'حذف $name';
  }

  @override
  String totalLine(String amount) {
    return 'المجموع: $amount';
  }

  @override
  String get addFixedExpense => 'إضافة مصروف ثابت';

  @override
  String get monthlySavingsGoal => 'هدف الادخار الشهري';

  @override
  String get savingsModeAmount => 'مبلغ';

  @override
  String get savingsModePercent => 'نسبة من الدخل';

  @override
  String get savingsPercentField => 'نسبة الادخار';

  @override
  String get savingsAmountField => 'مبلغ الادخار';

  @override
  String equalsMonthly(String amount) {
    return 'يساوي $amount شهريًا';
  }

  @override
  String get categoryLimitsOptional => 'حدود الفئات (اختياري)';

  @override
  String get categoryLimitsHint =>
      'حدّ أقصى للصرف في كل فئة خلال الدورة. اتركه فارغًا لعدم وضع حد.';

  @override
  String categoryLimitField(String category) {
    return 'حد $category';
  }

  @override
  String planOvercommitted(String committed, String income) {
    return 'المصروفات الثابتة والادخار ($committed) أكبر من الدخل ($income). لن يبقى شيء للصرف.';
  }

  @override
  String limitsOverAvailable(String limits, String available) {
    return 'مجموع حدود الفئات ($limits) أكبر من المتاح للصرف ($available).';
  }

  @override
  String get planSummary => 'ملخص الخطة';

  @override
  String get limitsSaveFailed => 'تعذّر حفظ الحدود. حاول مرة أخرى';

  @override
  String get yourAiProvider => 'مزوّد الذكاء الاصطناعي الذي اخترته';

  @override
  String get sendFinancialData => 'إرسال بياناتك المالية؟';

  @override
  String financialConsentBody(
    String provider,
    String income,
    String fixed,
    String savings,
    String available,
  ) {
    return 'سيُرسل إلى «$provider» الأرقام التالية فقط:\n• الدخل الشهري: $income\n• مجموع المصروفات الثابتة: $fixed\n• هدف الادخار: $savings\n• المتاح للصرف: $available\n\nلن تُرسل أسماء مصروفاتك الثابتة ولا مصاريفك المسجَّلة. ما يُرسل يخضع لسياسة هذا المزوّد. نسألك في كل مرة، ولا شيء يُرسل قبل موافقتك.';
  }

  @override
  String get agreeAndSend => 'أوافق وأرسل هذه المرة';

  @override
  String aiSuggestionUnreadable(String reply) {
    return 'لم أتمكن من قراءة الاقتراح كحدود للفئات. $reply';
  }

  @override
  String get saveAsLimits => 'حفظ كحدود للفئات';

  @override
  String get availableMonthly => 'المتاح للصرف شهريًا';

  @override
  String get noAvailableForLimits =>
      'لا يوجد متاح للصرف في خطتك الآن، فلا يمكن اقتراح حدود. عدّل الدخل أو المصروفات الثابتة أو الادخار أولًا.';

  @override
  String get localSuggestion => 'اقتراح محلي (بلا إنترنت)';

  @override
  String localRuleText(String rule) {
    return 'قاعدة بسيطة توزّع المتاح هكذا: $rule. بعد الحفظ تعدّل أي حد من «تعديل الخطة».';
  }

  @override
  String get aiSuggestionOptional => 'اقتراح بالذكاء الاصطناعي (اختياري)';

  @override
  String get aiSuggestionNote =>
      'يرسل أرقام خطتك المالية إلى المزوّد الذي اخترته، ولا يُرسل شيء إلا بموافقتك في كل مرة.';

  @override
  String get askAiSuggestion => 'اطلب اقتراحًا بالذكاء الاصطناعي';

  @override
  String aiSuggestionOver(String amount) {
    return 'مجموع هذا الاقتراح ($amount) أكبر من المتاح للصرف. عدّله بعد الحفظ.';
  }

  @override
  String expenseDeleted(String amount) {
    return 'حُذف مصروف $amount';
  }

  @override
  String get noMonthExpenses => 'لا توجد مصاريف مسجلة في هذا الشهر';

  @override
  String get previousMonth => 'الشهر السابق';

  @override
  String get nextMonth => 'الشهر التالي';

  @override
  String get totalSpending => 'إجمالي الصرف';

  @override
  String get breakdownByCategory => 'التوزيع حسب الفئة';

  @override
  String percentOfTotal(int percent) {
    return '$percent٪ من الإجمالي';
  }

  @override
  String get monthExpenses => 'مصروفات الشهر';

  @override
  String get deleteExpense => 'حذف المصروف';

  @override
  String get recordExpenseTitle => 'تسجيل مصروف';

  @override
  String get editExpenseTitle => 'تعديل مصروف';

  @override
  String get expenseCategoryField => 'الفئة';

  @override
  String dateLine(String date) {
    return 'التاريخ: $date';
  }

  @override
  String get changeDate => 'تغيير التاريخ';

  @override
  String get aiMissingKey =>
      'يلزم إعداد مزوّد الذكاء الاصطناعي ومفتاحه من الإعدادات أولًا.';

  @override
  String get aiInvalidKey =>
      'المفتاح غير صالح أو منتهي. يرجى تحديثه من إعدادات مزوّد الذكاء الاصطناعي ثم إعادة المحاولة.';

  @override
  String get aiModelNotFound =>
      'الموديل المختار غير موجود أو أُوقف. يرجى تحديث قائمة الموديلات من الإعدادات واختيار موديل آخر.';

  @override
  String get aiRateLimited =>
      'تم بلوغ حد الاستخدام أو الرصيد لدى المزوّد. يرجى الانتظار قليلًا أو مراجعة الحساب لديه ثم إعادة المحاولة.';

  @override
  String get aiBusy =>
      'خوادم المزوّد مزدحمة الآن، والمشكلة عنده لا في التطبيق. يرجى المحاولة بعد قليل، أو اختيار موديل أخفّ من إعدادات الذكاء الاصطناعي (مثل الموديلات التي في اسمها lite أو mini أو haiku).';

  @override
  String get aiNetwork =>
      'تعذّر الاتصال بالإنترنت. يرجى التحقق من الشبكة ثم إعادة المحاولة.';

  @override
  String get aiTimeout =>
      'لم يصل رد من المزوّد في الوقت المحدد، وغالبًا خوادمه مزدحمة. يرجى المحاولة مرة أخرى، أو اختيار موديل أخفّ وأسرع من إعدادات الذكاء الاصطناعي (مثل الموديلات التي في اسمها lite أو mini أو haiku).';

  @override
  String get aiBadRequest =>
      'رفض المزوّد الطلب. قد لا يدعم الموديل هذا النوع من الطلبات، فجرّب موديلًا آخر.';

  @override
  String get aiImageUnsupported =>
      'الموديل المختار لا يدعم الصور. يرجى اختيار موديل يدعمها من إعدادات مزوّد الذكاء الاصطناعي.';

  @override
  String get aiBlocked => 'تعذّر تكوين رد لهذا الطلب. جرّب صياغة مختلفة.';

  @override
  String get aiUnsupportedLocation => 'خدمة المزوّد غير متاحة في بلدك حاليًا.';

  @override
  String get aiInsecureUrl =>
      'عنوان المزوّد يجب أن يبدأ بـ https:// ويكون عنوانًا صحيحًا.';

  @override
  String get aiInvalidModelName =>
      'اسم الموديل غير صالح. يُسمح بالحروف والأرقام والرموز - _ . : / @ فقط.';

  @override
  String get aiEmptyReply => 'لم يتم استلام رد من المساعد الذكي.';

  @override
  String get aiUnknown =>
      'حدث خطأ غير متوقع مع المساعد الذكي. يرجى المحاولة مرة أخرى بعد قليل.';

  @override
  String get aiEmptyImageReply => 'لم أتمكن من تحليل الصورة.';

  @override
  String get aiNoKeySet => 'لم يُضبط مفتاح';

  @override
  String get customProviderLabel => 'مخصص (متوافق مع OpenAI)';

  @override
  String get providerConnectionOk => 'الاتصال سليم والموديل يرد.';

  @override
  String get providerImageRejected =>
      'الموديل لم يقبل الصورة، فعُلّم بأنه لا يدعم الصور.';

  @override
  String get providerImagesOk => 'الموديل يدعم الصور.';

  @override
  String get providerNoModels => 'لم يُرجع المزوّد أي موديل.';

  @override
  String get providerSaved => 'تم حفظ إعداد الذكاء الاصطناعي.';

  @override
  String get providerKeyDeleted => 'حُذف المفتاح من هذا الجهاز.';

  @override
  String get linkCopied => 'تم نسخ الرابط';

  @override
  String get providerIntro =>
      'اختر المزوّد الذي تريد استعماله وأدخل مفتاحك الخاص منه.\nالمفتاح يُحفظ على جهازك فقط في تخزين آمن، ويُرسل إلى المزوّد الذي تختاره وحده مع طلباتك، بلا خادم وسيط. ما تُرسله يخضع لسياسة الخصوصية لدى ذلك المزوّد.';

  @override
  String get providerField => 'المزوّد';

  @override
  String get providerUrlField => 'عنوان المزوّد';

  @override
  String get modelNameField => 'اسم الموديل';

  @override
  String get modelNameHint => 'اكتب الاسم أو اجلبه من المزوّد';

  @override
  String get fetchModels => 'جلب الموديلات المتاحة';

  @override
  String get keyField => 'المفتاح';

  @override
  String get copyLink => 'نسخ الرابط';

  @override
  String get pasteKeyHint => 'الصق مفتاحك هنا';

  @override
  String savedKeyHint(String preview) {
    return 'محفوظ: $preview (اتركه فارغًا للإبقاء عليه)';
  }

  @override
  String get showKey => 'إظهار المفتاح';

  @override
  String get hideKey => 'إخفاء المفتاح';

  @override
  String get deleteSavedKey => 'حذف المفتاح المحفوظ';

  @override
  String get modelImagesQuestion => 'هل يدعم الموديل الصور؟';

  @override
  String get yes => 'نعم';

  @override
  String get no => 'لا';

  @override
  String get unknownSupport => 'غير معروف';

  @override
  String get testImagesAuto => 'اختبار دعم الصور تلقائيًا';

  @override
  String get testConnection => 'اختبار الاتصال';

  @override
  String get saveAndActivate => 'حفظ وتفعيل';

  @override
  String searchModels(int count) {
    return 'بحث في $count موديل';
  }

  @override
  String get assistantActivated =>
      '✅ تم تفعيل المزوّد بنجاح! يمكنك الآن استخدام جميع ميزات الذكاء الاصطناعي.';

  @override
  String get assistantTitle => '🤖 المساعد الذكي';

  @override
  String get assistantProviderSetup => 'إعداد مزوّد الذكاء الاصطناعي';

  @override
  String get assistantStarting => 'جارٍ تهيئة المساعد الذكي...';

  @override
  String get assistantThinking => 'جارٍ التفكير...';

  @override
  String get assistantHint => 'اسأل المساعد الذكي أو اطلب اقتراحاً...';

  @override
  String get send => 'إرسال';

  @override
  String get coachDomainBeliefs => 'المعتقدات';

  @override
  String get coachDomainEmotions => 'المشاعر';

  @override
  String get coachDomainGoals => 'الأهداف والتخطيط';

  @override
  String get coachDomainOrganization => 'التنظيم والتوازن';

  @override
  String get coachDomainSkills => 'المهارات والتقنيات';

  @override
  String get coachHintBudget => 'لاحظنا نمطًا في مصاريفك هذا الأسبوع';

  @override
  String get coachHintUsage => 'هذا السؤال مرتبط بتوزيع وقتك اليوم';

  @override
  String get coachHintReflection => 'لاحظنا فكرة تتكرر في إجاباتك الأخيرة';

  @override
  String coachQuotaRemaining(int remaining, int limit) {
    return 'متبقٍ $remaining من $limit مجانًا هذا الشهر';
  }

  @override
  String coachQuotaUsedUp(String date) {
    return 'انتهت المحاولات المجانية لهذا الشهر، وتتجدد في $date';
  }

  @override
  String coachQuotaRenews(String date) {
    return 'تتجدد محاولاتك المجانية في $date';
  }

  @override
  String coachQuotaOffer(int limit) {
    String _temp0 = intl.Intl.pluralLogic(
      limit,
      locale: localeName,
      other: 'تحصل مجانًا على $limit سؤال متابعة كل شهر.',
      few: 'تحصل مجانًا على $limit أسئلة متابعة كل شهر.',
      two: 'تحصل مجانًا على سؤالَي متابعة كل شهر.',
      one: 'تحصل مجانًا على سؤال متابعة واحد كل شهر.',
    );
    return '$_temp0 الاشتراك يجعلها بلا حد.';
  }

  @override
  String get crisisResponse =>
      'إذا كنت تمر بأزمة فعلية أو تفكر في إيذاء نفسك، الرجاء التواصل فورًا مع خط مساعدة مختص أو أقرب جهة طوارئ. هذا التطبيق أداة تأمل ذاتي فقط، وليس بديلاً عن معالج نفسي مرخّص.';

  @override
  String get crisisSaudiNote =>
      'في المملكة العربية السعودية (خطوط حكومية رسمية):';

  @override
  String get crisisLocalEmergency =>
      'إن كان هناك خطر مباشر، اتصل الآن برقم الطوارئ في بلدك، أو اذهب إلى أقرب قسم طوارئ.';

  @override
  String get crisisFinderLabel => 'ابحث عن خط مساعدة مجاني في بلدك';

  @override
  String get crisisImportant => 'مهم';

  @override
  String get gotIt => 'فهمت';

  @override
  String get coachHistory => 'سجل جلسات المدرب';

  @override
  String get coachDisclaimer =>
      'هذه أداة تأمل ذاتي، وليست بديلًا عن معالج نفسي مرخّص.';

  @override
  String get coachAnswerHint => 'إجابتك (اختياري)...';

  @override
  String get coachDeepen => 'عمّق أكثر';

  @override
  String get coachSessionDeleted => 'حُذفت الجلسة';

  @override
  String get coachNoSessions => 'لا توجد جلسات محفوظة بعد';

  @override
  String get coachDeleteSession => 'حذف الجلسة';

  @override
  String get payPending =>
      'الدفع قيد المعالجة لدى Google Play، وسيُفعَّل الاشتراك تلقائيًا عند اكتماله.';

  @override
  String get payError => 'تعذّر إتمام الشراء، حاول مرة أخرى.';

  @override
  String get payOpenFailed => 'تعذّر فتح نافذة الشراء، حاول مرة أخرى.';

  @override
  String get payNoSubscription =>
      'لا يوجد اشتراك فعّال على حساب Google Play هذا.';

  @override
  String get payTitle => 'الاشتراك الشهري';

  @override
  String get payHeadingMeditation => 'كل جلسات التأمل';

  @override
  String get payHeadingCoach => 'تعمّق أكثر في تأملك';

  @override
  String get payBenefitDeepen =>
      '«عمّق أكثر» بلا حد: سؤال متابعة مبني على إجابتك أنت، بلا نصائح ولا أحكام.';

  @override
  String get payBenefitMeditation =>
      'كل جلسات التأمل المرشدة والحركية: مسح الجسد، والحضور في اللحظة، وحركة ثم سكون.';

  @override
  String get payBenefitControl =>
      'أنت تقرر متى تستعملها، لا شيء يحدث تلقائيًا.';

  @override
  String get payFreeNote =>
      'الأسئلة المحلية وسجل جلساتك وتتبع الميزانية تبقى مجانية بالكامل، وكذلك عجلة الحياة وتسمية المشاعر، والمؤقت الصامت وموجات جاما وجلسة التنفّس الهادئ.\nسؤال المتابعة يعمل بمفتاح مزوّد الذكاء الاصطناعي الذي تحدده من الإعدادات.';

  @override
  String get payUnavailable => 'الاشتراك غير متاح حاليًا';

  @override
  String paySubscribe(String price) {
    return 'اشترك الآن — $price شهريًا';
  }

  @override
  String get payAndroidOnly =>
      'الاشتراك متاح في نسخة Android المثبتة من Google Play.';

  @override
  String get payRestore => 'استعادة المشتريات';

  @override
  String get payRenewal =>
      'يتجدد الاشتراك تلقائيًا كل شهر بنفس السعر حتى تلغيه. يمكنك الإلغاء في أي وقت من Google Play ← الدفعات والاشتراكات ← الاشتراكات.';

  @override
  String hoursShort(int h) {
    return '$h س';
  }

  @override
  String hoursMinutesShort(int h, int m) {
    return '$h س $m د';
  }

  @override
  String get refresh => 'تحديث';

  @override
  String get usageAndroidOnly =>
      'هذه الميزة تعمل على أجهزة Android فقط، لأنها تعتمد على صلاحية \"الوصول إلى بيانات الاستخدام\" في النظام.';

  @override
  String get usageReadFailed =>
      'تعذّرت قراءة بيانات الاستخدام من النظام، حاول مرة أخرى لاحقًا.';

  @override
  String get usageToday => 'وقتك اليوم في تطبيقات التواصل';

  @override
  String get usageNone => 'لم يُسجَّل استخدام لهذه التطبيقات اليوم.';

  @override
  String get usageBreakdown => 'التوزيع بين التطبيقات (بالدقائق)';

  @override
  String usageShare(int percent) {
    return '$percent٪ من وقت التواصل اليوم';
  }

  @override
  String get usageSource =>
      'من منتصف الليل حتى الآن، كما يسجّلها نظام Android. الأرقام تبقى على جهازك فقط.';

  @override
  String get usageHowTitle => 'كيف تعمل هذه الميزة؟';

  @override
  String usageHowBody(String apps) {
    return 'نقرأ من نظام Android عدد الدقائق التي قضيتها اليوم في: $apps. رقم واحد لكل تطبيق، لا أكثر.\nلا نقرأ رسائلك ولا إشعاراتك ولا أي محتوى داخل هذه التطبيقات، ولا نطلب تسجيل الدخول لأي حساب.\nالأرقام تبقى على جهازك فقط ولا تُرسل لأي مكان، ويمكنك إلغاء الصلاحية في أي وقت من نفس الإعدادات.';
  }

  @override
  String get usageEnableTitle => 'لتفعيلها:';

  @override
  String get usageStep1 => 'اضغط \"فتح الإعدادات\" بالأسفل.';

  @override
  String usageStep2(String app) {
    return 'ابحث في القائمة عن تطبيق \"$app\".';
  }

  @override
  String get usageStep3 =>
      'فعّل خيار السماح بالوصول إلى بيانات الاستخدام (قد يختلف الاسم قليلًا حسب نوع الجهاز).';

  @override
  String get usageStep4 => 'ارجع إلى التطبيق، وستظهر أرقام اليوم تلقائيًا.';

  @override
  String get openSettings => 'فتح الإعدادات';

  @override
  String get notNow => 'ليس الآن';

  @override
  String backupWeakPassword(int min) {
    return 'كلمة المرور قصيرة: يلزم $min أحرف على الأقل.';
  }

  @override
  String get backupNotABackup => 'هذا الملف ليس نسخة احتياطية من هذا التطبيق.';

  @override
  String get backupUnsupportedVersion =>
      'هذه النسخة أحدث من إصدار التطبيق الحالي. يرجى تحديث التطبيق ثم إعادة المحاولة.';

  @override
  String get backupWrongPassword => 'كلمة المرور غير صحيحة، أو أن الملف تالف.';

  @override
  String get backupRestoreFailed =>
      'تعذّرت الاستعادة، وأُعيدت البيانات كما كانت.';

  @override
  String get backupRestoreFailedUnsafe =>
      'تعذّرت الاستعادة وقد تكون البيانات ناقصة. يرجى إعادة المحاولة بنفس الملف.';

  @override
  String get backupSaveDialog => 'حفظ النسخة الاحتياطية';

  @override
  String get backupPickDialog => 'اختيار ملف النسخة الاحتياطية';

  @override
  String get contactSubject => 'تواصل بخصوص التطبيق';

  @override
  String get assistantHello => 'أهلًا بك!';

  @override
  String assistantHelloName(String name) {
    return 'أهلًا بك يا $name!';
  }

  @override
  String get assistantGreetingBody =>
      'أنا مساعدك الذكي. كيف أساعدك في تنظيم يومك، أو اقتراح وجبات، أو مراجعة تمارينك؟\n\n🔑 للبدء يلزم إعداد مزوّد الذكاء الاصطناعي ومفتاحك الخاص من أيقونة المفتاح في الأعلى.';

  @override
  String get coachToolsTitle => 'أدوات المدرب';

  @override
  String get coachToolsIntro =>
      'تمارين قصيرة بخطوات، تُحفظ نتائجها على هذا الجهاز للمقارنة بالمرات السابقة.';

  @override
  String get coachToolsEntry => 'أدوات المدرب: عجلة الحياة والمشاعر والمزيد';

  @override
  String get wheelTitle => 'عجلة الحياة';

  @override
  String get wheelSubtitle =>
      'تقييم مجالات الحياة الثمانية واختيار خطوة صغيرة.';

  @override
  String get emotionTitle => 'تسمية المشاعر';

  @override
  String get emotionSubtitle => 'تسمية الشعور ومتابعته عبر الأيام.';

  @override
  String get wheelHealth => 'الصحة';

  @override
  String get wheelWork => 'العمل أو الدراسة';

  @override
  String get wheelMoney => 'المال';

  @override
  String get wheelFamily => 'الأسرة';

  @override
  String get wheelRelationships => 'الأصدقاء والعلاقات';

  @override
  String get wheelGrowth => 'التطور الشخصي';

  @override
  String get wheelSpirit => 'الجانب الروحي';

  @override
  String get wheelFun => 'المتعة والراحة';

  @override
  String get wheelIntro =>
      'تقييم الرضا عن كل مجال من 0 إلى 10، ثم اختيار مجال واحد للعمل عليه.';

  @override
  String get wheelNow => 'الآن';

  @override
  String wheelLastTime(String date) {
    return 'المرة السابقة ($date)';
  }

  @override
  String wheelWas(int score) {
    return 'كان $score';
  }

  @override
  String get wheelFocus => 'مجال التركيز';

  @override
  String wheelQ1(String area, int score) {
    return 'ما الذي يجعل «$area» عند $score وليس أقل؟';
  }

  @override
  String wheelQ2(String area, int target) {
    return 'لو صار «$area» عند $target، ما أول ما سيتغيّر في اليوم؟';
  }

  @override
  String wheelQ2Keep(String area) {
    return 'ما الذي يساعد على إبقاء «$area» في هذا المستوى؟';
  }

  @override
  String get wheelQ3 => 'ما الذي يقف في الطريق الآن؟';

  @override
  String get wheelQ4 =>
      'ما خطوة صغيرة واحدة تقرّب هذا المجال نقطة واحدة هذا الأسبوع؟';

  @override
  String get answerOptional => 'الإجابة (اختياري)';

  @override
  String get stepToTask => 'إضافة الخطوة إلى المهام';

  @override
  String stepReminder(String time) {
    return 'تذكير: $time';
  }

  @override
  String get stepNoReminder => 'بلا تذكير';

  @override
  String get stepSetReminder => 'ضبط تذكير';

  @override
  String get wheelSave => 'حفظ العجلة';

  @override
  String get wheelSaved => 'حُفظت عجلة الحياة.';

  @override
  String get wheelSavedWithTask =>
      'حُفظت عجلة الحياة، وأُضيفت الخطوة إلى المهام.';

  @override
  String get emotionIntro =>
      'تسمية الشعور بدقة خطوة أولى لفهمه. لا توجد إجابة صحيحة أو خاطئة.';

  @override
  String get emotionWhich => 'ما الشعور الأقرب الآن؟';

  @override
  String get emotionWord => 'كلمة أدق (اختياري)';

  @override
  String emotionIntensity(int value) {
    return 'الشدة الآن: $value من 10';
  }

  @override
  String get emotionWhere => 'أين يظهر هذا الشعور في الجسد؟';

  @override
  String get emotionTrigger => 'ما الذي أثاره؟ (اختياري)';

  @override
  String get emotionNeed => 'ما الذي يحتاجه هذا الشعور الآن؟';

  @override
  String get emotionPickFirst => 'اختيار الشعور أولًا';

  @override
  String get emotionSaved => 'حُفظ الشعور في السجل.';

  @override
  String get emotionStrong =>
      'الشعور قوي الآن. إن رغبت، جلسة «تنفّس هادئ» في تبويب التأمل تتيح بضع دقائق من التنفّس البطيء.';

  @override
  String get openMeditation => 'فتح التأمل';

  @override
  String get emotionLog => 'سجل المشاعر';

  @override
  String get emotionLogEmpty => 'لا مشاعر مسجّلة بعد.';

  @override
  String emotionMostFrequent(String feeling) {
    return 'الأكثر تكرارًا في آخر 30 يومًا: $feeling';
  }

  @override
  String emotionLine(String feeling, int value) {
    return '$feeling · $value من 10';
  }

  @override
  String get toolRecordDeleted => 'حُذف السجل';

  @override
  String get deleteEntry => 'حذف السجل';

  @override
  String get feelingHappy => 'سعادة';

  @override
  String get feelingCalm => 'هدوء';

  @override
  String get feelingGrateful => 'امتنان';

  @override
  String get feelingHopeful => 'أمل';

  @override
  String get feelingProud => 'فخر';

  @override
  String get feelingTired => 'تعب';

  @override
  String get feelingAnxious => 'قلق';

  @override
  String get feelingStressed => 'توتر';

  @override
  String get feelingSad => 'حزن';

  @override
  String get feelingLonely => 'وحدة';

  @override
  String get feelingAngry => 'غضب';

  @override
  String get feelingFrustrated => 'إحباط';

  @override
  String get feelingAfraid => 'خوف';

  @override
  String get feelingGuilty => 'شعور بالذنب';

  @override
  String get feelingBored => 'ملل';

  @override
  String get feelingOverwhelmed => 'إرهاق';

  @override
  String get bodyHead => 'الرأس';

  @override
  String get bodyThroat => 'الحلق';

  @override
  String get bodyChest => 'الصدر';

  @override
  String get bodyStomach => 'البطن';

  @override
  String get bodyShoulders => 'الكتفان';

  @override
  String get bodyHands => 'اليدان';

  @override
  String get bodyWhole => 'كل الجسد';

  @override
  String get bodyUnsure => 'غير واضح';

  @override
  String get needRest => 'راحة';

  @override
  String get needTalk => 'حديث مع شخص';

  @override
  String get needMovement => 'حركة';

  @override
  String get needQuiet => 'وقت هادئ';

  @override
  String get needSolve => 'حل أمر عالق';

  @override
  String get needWrite => 'الكتابة عنه';

  @override
  String get needNothing => 'لا شيء الآن';

  @override
  String get followUpTitle => 'آخر خطوة';

  @override
  String followUpQuestion(String step) {
    return '«$step». كيف سارت؟';
  }

  @override
  String get followUpDone => 'تمّت';

  @override
  String get followUpNotYet => 'لم تتم بعد';

  @override
  String get followUpNoted => 'سُجّل ذلك.';

  @override
  String get historyToolsSection => 'أدوات المدرب';

  @override
  String historyWheelFocus(String area, int score) {
    return 'التركيز: $area ($score)';
  }

  @override
  String historyStep(String step) {
    return 'الخطوة: $step';
  }

  @override
  String get toolSaved => 'حُفظ.';

  @override
  String get toolSavedWithTask => 'حُفظ، وأُضيفت الخطوة إلى المهام.';

  @override
  String get writeSentenceFirst => 'كتابة الجملة أولًا';

  @override
  String get beliefTitle => 'فحص معتقد';

  @override
  String get beliefSubtitle => 'فحص جملة تتكرر في الرأس، وصياغة أدق لها.';

  @override
  String get beliefIntro =>
      'جملة تتكرر في الرأس عن النفس أو عن الحياة، تُفحص هنا كفكرة لا كحقيقة.';

  @override
  String get beliefSentence => 'ما الجملة؟ (مثل: «لا أنجح في أي شيء»)';

  @override
  String get beliefOrigin => 'متى بدأت هذه الفكرة، ومن أين جاءت؟';

  @override
  String get beliefFor => 'ما الذي يؤيدها؟';

  @override
  String get beliefAgainst => 'ما الذي ينقضها، ولو كان صغيرًا؟';

  @override
  String beliefStrengthBefore(int value) {
    return 'كم تبدو صحيحة الآن؟ $value من 10';
  }

  @override
  String get beliefNew => 'صياغة أدق وأكثر إنصافًا للجملة نفسها:';

  @override
  String get beliefNewFor => 'ما الذي يؤيد الصياغة الجديدة؟';

  @override
  String beliefStrengthAfter(int value) {
    return 'وكم تبدو الجملة القديمة صحيحة بعد هذا؟ $value من 10';
  }

  @override
  String get beliefStep => 'خطوة صغيرة تختبر الصياغة الجديدة هذا الأسبوع:';

  @override
  String get innerVoiceTitle => 'الصوت الداخلي';

  @override
  String get innerVoiceSubtitle =>
      'التعرّف على الصوت الناقد وإعادة صياغة ما يقوله.';

  @override
  String get innerVoiceIntro =>
      'للصوت الناقد في الداخل أنماط متكررة. تسميته تجعل ملاحظته أسهل حين يتكلم.';

  @override
  String get innerVoiceType => 'أي نمط هو الأقرب؟';

  @override
  String get voiceWorrier => 'القلِق: يتوقع الأسوأ';

  @override
  String get voiceCritic => 'الناقد: يحاسب على كل خطأ';

  @override
  String get voiceHopeless => 'اليائس: يقول لا فائدة';

  @override
  String get voicePerfectionist => 'الكمالي: لا يرضى إلا بالكمال';

  @override
  String get innerVoiceName => 'اسم له (اختياري)';

  @override
  String get innerVoiceSentence => 'ما الجملة التي يكررها كثيرًا؟';

  @override
  String get innerVoiceWhen => 'متى يعلو صوته عادة؟';

  @override
  String get innerVoiceFriend => 'لو قالها صديق عن نفسه، ماذا سيكون الرد عليه؟';

  @override
  String get innerVoiceReframe => 'صياغة جديدة للجملة نفسها، بصوت أهدأ وأعدل:';

  @override
  String get innerVoiceStep => 'خطوة عملية صغيرة لهذا الأسبوع:';

  @override
  String get decisionTitle => 'قرار بين خيارين';

  @override
  String get decisionSubtitle => 'مقارنة خيارين بما يُكسب ويُخسر، ثم أول خطوة.';

  @override
  String get decisionIntro =>
      'لا يقدّم التطبيق رأيًا: الأسئلة هنا لرؤية الخيارين بوضوح.';

  @override
  String get decisionOptionA => 'الخيار الأول';

  @override
  String get decisionOptionB => 'الخيار الثاني';

  @override
  String decisionGain(String option) {
    return 'ما الذي يُكسب مع «$option»؟';
  }

  @override
  String decisionLoss(String option) {
    return 'ما الذي يُخسر مع «$option»؟';
  }

  @override
  String get decisionRegret =>
      'بعد خمس سنوات، ترك أيّ الخيارين قد يُندم عليه أكثر؟';

  @override
  String get decisionUnsure => 'غير واضح بعد';

  @override
  String get decisionExperiment => 'تجربة صغيرة تختبر أحد الخيارين قبل الحسم:';

  @override
  String get decisionChosen => 'الخيار المختار الآن';

  @override
  String get decisionUndecided => 'لم يُحسم بعد';

  @override
  String get decisionStep => 'أول خطوة:';

  @override
  String get decisionNeedOptions => 'كتابة الخيارين أولًا';

  @override
  String get habitTitle => 'تغيير عادة';

  @override
  String get habitSubtitle =>
      'فهم ما يثير العادة، وخطوة يومية مع متابعة 21 يومًا.';

  @override
  String get habitIntro =>
      'العادة تبدأ غالبًا من مكان أو وقت أو أشخاص أو شعور. ملاحظة ذلك أول الطريق لتغييرها.';

  @override
  String get habitName => 'العادة المراد تغييرها:';

  @override
  String get habitWhere => 'أين تحدث غالبًا؟';

  @override
  String get habitWhen => 'متى؟';

  @override
  String get habitWho => 'مع من؟';

  @override
  String get habitFeeling => 'بعد أي شعور؟';

  @override
  String get habitEnvironment =>
      'تعديل صغير في المكان أو الأدوات يجعل التغيير أسهل:';

  @override
  String get habitDailyStep => 'خطوة يومية صغيرة:';

  @override
  String get habitDailyReminder => 'تذكير يومي (اختياري)';

  @override
  String get habitStart => 'بدء 21 يومًا';

  @override
  String get habitNeedFields => 'كتابة العادة والخطوة اليومية أولًا';

  @override
  String get habitStarted => 'بدأت متابعة 21 يومًا.';

  @override
  String habitDay(int day) {
    return 'اليوم $day من 21';
  }

  @override
  String habitDoneCount(int done) {
    return 'الأيام المنجزة: $done من 21';
  }

  @override
  String get habitCheckToday => 'تمّت خطوة اليوم';

  @override
  String get habitUncheckToday => 'إلغاء علامة اليوم';

  @override
  String get habitStop => 'إيقاف المتابعة';

  @override
  String get habitStopAsk =>
      'إيقاف متابعة هذه العادة؟ يبقى ما سُجّل، ويتوقف التذكير اليومي.';

  @override
  String habitFinished(int done) {
    return 'اكتملت الأيام الـ21. الأيام المنجزة: $done.';
  }

  @override
  String get habitPast => 'عادات سابقة';

  @override
  String get reminderHabitTitle => 'خطوة اليوم';

  @override
  String get payHeadingTools => 'أدوات المدرب المتقدمة';

  @override
  String get payBenefitTools =>
      'أدوات المدرب الأربع: فحص المعتقد، والصوت الداخلي، والقرار بين خيارين، وتغيير العادة.';

  @override
  String get coachDomainRelationships => 'العلاقات';

  @override
  String get coachDomainWork => 'العمل والمسار المهني';

  @override
  String get coachDomainDigital => 'الحياة الرقمية';
}
