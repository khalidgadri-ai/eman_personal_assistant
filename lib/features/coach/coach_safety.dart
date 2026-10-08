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
const List<CrisisHelpline> crisisHelplines = [
  CrisisHelpline('911 / 997', 'طوارئ فورية أو خطر مباشر على الحياة (997: الهلال الأحمر)'),
  CrisisHelpline(
    '1919',
    'دعم نفسي متخصص على مدار 24 ساعة — مركز بلاغات العنف الأسري، وزارة الموارد البشرية',
  ),
  CrisisHelpline('937', 'استشارة طبية على مدار 24 ساعة — مركز اتصال وزارة الصحة'),
];

const String crisisHelplinesNote = 'هذه خطوط حكومية رسمية في المملكة العربية السعودية.';

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
