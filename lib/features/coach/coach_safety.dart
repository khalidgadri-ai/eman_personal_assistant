/// فلاتر محلية تعمل قبل وبعد أي اتصال بنموذج AI.
/// فحص الكلمات المفتاحية لا يلتقط الصياغة غير المباشرة للأزمة، فهو طبقة أولى
/// سريعة وليس الفحص الوحيد المطلوب.
library;

const List<String> crisisKeywords = [
  // عربي
  'انتحار',
  'انتحر',
  'بنتحر',
  'اذية نفسي',
  'أذية نفسي',
  'اذي نفسي',
  'اضر نفسي',
  'اؤذي نفسي',
  'ابي اموت',
  'أبغى أموت',
  'نفسي اموت',
  'ما يسوى اعيش',
  'ماعاد يسوى اعيش',
  'ودي اختفي',
  'ابي اختفي',
  'مافي فايدة من حياتي',
  'لا اريد ان اعيش',
  'ماعاد اقدر اتحمل',
  'قتل نفسي',
  'اقتل نفسي',
  // English
  'suicide',
  'kill myself',
  'want to die',
  'end my life',
  'self harm',
  'self-harm',
  'hurt myself',
  'no reason to live',
  'better off dead',
  'suicidal',
  'take my own life',
  'kill my self',
  "don't want to live",
  'dont want to live',
  "don't want to be alive",
];

const List<String> advicePhrases = [
  'ينصح',
  'انصح',
  'نصيحتي',
  'يجب',
  'الحل',
  'جرب',
  'اقترح',
  'من الافضل',
  'عليك ان',
  'ما رايك ان',
  'الا تعتقد ان',
];

const String crisisResponseMessage =
    'إذا كنت تمر بأزمة فعلية أو تفكر في إيذاء نفسك، الرجاء التواصل فورًا مع '
    'خط مساعدة مختص أو أقرب جهة طوارئ. هذا التطبيق أداة تأمل ذاتي فقط، '
    'وليس بديلاً عن معالج نفسي مرخّص.';

class CrisisHelpline {
  final String number;
  final String description;
  const CrisisHelpline(this.number, this.description);
}

// لا يوجد في السعودية خط وطني مخصص للانتحار على مدار الساعة، لذلك نعرض
// الخطوط الحكومية الرسمية الأقرب للغرض، مرتبة حسب الأولوية.
// هذه الأرقام سعودية فقط، وتظهر دائمًا تحت عنوان يقول ذلك ([crisisHelplinesNote])، وأولًا
// إن كانت منطقة الجوال السعودية ([showSaudiHelplinesFirst]). لا نضع أرقام دول أخرى من عندنا:
// الرقم الخاطئ في أزمة خطر، فبقية الدول يوجّهها [crisisHelplineFinderUrl].
const List<CrisisHelpline> crisisHelplines = [
  CrisisHelpline('911 / 997', 'طوارئ فورية أو خطر مباشر على الحياة (997: الهلال الأحمر)'),
  CrisisHelpline(
    '1919',
    'دعم نفسي متخصص على مدار 24 ساعة — مركز بلاغات العنف الأسري، وزارة الموارد البشرية',
  ),
  CrisisHelpline('937', 'استشارة طبية على مدار 24 ساعة — مركز اتصال وزارة الصحة'),
];

const String crisisHelplinesNote = 'في المملكة العربية السعودية (خطوط حكومية رسمية):';

/// لكل البلاد، لأن التطبيق متاح خارج السعودية.
const String crisisLocalEmergencyMessage =
    'إن كان هناك خطر مباشر، اتصل الآن برقم الطوارئ في بلدك، أو اذهب إلى أقرب قسم طوارئ.';

const String crisisHelplineFinderLabel = 'ابحث عن خط مساعدة مجاني في بلدك';

/// Find A Helpline (ThroughLine): دليل مجاني لخطوط المساعدة الموثّقة في أكثر من 175 بلدًا،
/// ويقترح خطوط بلد الزائر (راجعناه في 21 نوفمبر 2026). يُفتح فقط حين يضغط المستخدم،
/// في المتصفح، ولا يُرسل التطبيق إليه أي شيء.
final Uri crisisHelplineFinderUrl = Uri.parse('https://findahelpline.com');

/// منطقة الجوال (من إعداد اللغة والمنطقة، مثل ar_SA). تقريب لا موقع فعلي، لذلك لا تُخفى
/// الأرقام السعودية عن أحد: تتغير فقط هل تأتي قبل الدليل العام أو بعده.
bool showSaudiHelplinesFirst(String? countryCode) => countryCode?.toUpperCase() == 'SA';

String normalizeArabic(String input) {
  return input
      .toLowerCase()
      .replaceAll(RegExp('[إأآا]'), 'ا')
      .replaceAll('ة', 'ه')
      .replaceAll(String.fromCharCode(0x0640), '')
      .replaceAll(RegExp('[${String.fromCharCode(0x064B)}-${String.fromCharCode(0x0652)}]'), '')
      .replaceAll(RegExp(r'\s+'), ' ');
}

bool containsCrisisSignals(String text) {
  if (text.trim().isEmpty) return false;
  final normalizedText = normalizeArabic(text);
  for (final keyword in crisisKeywords) {
    if (normalizedText.contains(normalizeArabic(keyword))) {
      return true;
    }
  }
  return false;
}

// كلمة كاملة مع حرف عطف اختياري قبلها وضمير اختياري بعدها، حتى تُلتقط
// "فالحل" و"أنصحكِ" و"جربي" بدون رفض "الحلم" أو "يجبرك" أو "جربته".
final List<RegExp> _advicePatterns = advicePhrases
    .map((phrase) => RegExp(
          '(?<!\\p{L})[وف]?${RegExp.escape(normalizeArabic(phrase))}'
          '(?:ي|ك|كي|كم|ه|ها)?(?!\\p{L})',
          unicode: true,
        ))
    .toList();

bool containsAdviceLanguage(String text) {
  final normalizedText = normalizeArabic(text);
  return _advicePatterns.any((pattern) => pattern.hasMatch(normalizedText));
}
