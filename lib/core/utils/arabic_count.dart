/// صيغ اسم معدود واحد بالعربية، لكتابة العدد معه صحيحًا بدل «10 يوم».
class ArabicNoun {
  const ArabicNoun({
    required this.singular,
    required this.one,
    required this.two,
    required this.plural,
    required this.accusative,
  });

  /// المفرد بلا عدد قبله: يوم. يُستعمل بعد المئات والآلاف الكاملة (100 يوم، 1002 يوم).
  final String singular;

  /// الواحد بلا رقم: يوم واحد.
  final String one;

  /// المثنى بلا رقم: يومان.
  final String two;

  /// الجمع بعد 3 إلى 10: أيام.
  final String plural;

  /// المفرد المنصوب بعد 11 إلى 99: يومًا.
  final String accusative;

  static const ArabicNoun day = ArabicNoun(
    singular: 'يوم',
    one: 'يوم واحد',
    two: 'يومان',
    plural: 'أيام',
    accusative: 'يومًا',
  );

  static const ArabicNoun minute = ArabicNoun(
    singular: 'دقيقة',
    one: 'دقيقة واحدة',
    two: 'دقيقتان',
    plural: 'دقائق',
    accusative: 'دقيقة',
  );

  static const ArabicNoun page = ArabicNoun(
    singular: 'صفحة',
    one: 'صفحة واحدة',
    two: 'صفحتان',
    plural: 'صفحات',
    accusative: 'صفحة',
  );
}

/// العدد مع معدوده: «يوم واحد»، «يومان»، «5 أيام»، «11 يومًا»، «100 يوم»، «105 أيام».
/// القاعدة على آخر رقمين: 3–10 جمع، و11–99 مفرد منصوب، و0–2 بعد المئات مفرد.
String arabicCount(int n, ArabicNoun noun) {
  if (n == 1) return noun.one;
  if (n == 2) return noun.two;
  final lastTwo = n.abs() % 100;
  if (lastTwo >= 3 && lastTwo <= 10) return '$n ${noun.plural}';
  if (lastTwo >= 11) return '$n ${noun.accusative}';
  return '$n ${noun.singular}';
}
