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
}
