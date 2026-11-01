/// يوحّد كتابة اسم عربي للمقارنة فقط (لا للعرض): بلا تشكيل ولا تطويل، وهمزات الألف ألف،
/// والتاء المربوطة هاء، والألف المقصورة ياء، ويحذف "ال" التعريف من أول كل كلمة.
/// "الطماطم" و"طماطم" و"طَمَاطِم" تتطابق.
String normalizeArabicName(String input) {
  var text = input.trim().toLowerCase();
  text = text.replaceAll(RegExp('[ً-ْـ]'), '');
  text = text
      .replaceAll(RegExp('[أإآ]'), 'ا')
      .replaceAll('ة', 'ه')
      .replaceAll('ى', 'ي');
  final words = text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).map((w) {
    return w.length > 3 && w.startsWith('ال') ? w.substring(2) : w;
  });
  return words.join(' ');
}

/// هل يدلّ الاسمان على الشيء نفسه؟ تطابق بعد التوحيد، أو كلمة كاملة من أحدهما هي الآخر
/// ("زيت زيتون" و"زيت").
bool sameArabicItem(String a, String b) {
  final x = normalizeArabicName(a);
  final y = normalizeArabicName(b);
  if (x.isEmpty || y.isEmpty) return false;
  if (x == y) return true;
  final xs = x.split(' ');
  final ys = y.split(' ');
  return (ys.length == 1 && xs.contains(y)) || (xs.length == 1 && ys.contains(x));
}
