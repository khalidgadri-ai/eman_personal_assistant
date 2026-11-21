import 'package:intl/intl.dart' as intl;

const List<String> arabicMonthNames = [
  'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
  'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
];

const List<String> englishMonthNames = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
];

/// اسم الشهر (1-12) بلغة التطبيق [lang] ('ar' أو 'en').
String monthName(int month, String lang) => (lang == 'ar' ? arabicMonthNames : englishMonthNames)[month - 1];

final intl.NumberFormat _money = intl.NumberFormat('#,##0.##');

/// مبلغ بفواصل الآلاف وبأقل كسور ممكنة: `12,500` و`25.5`.
String formatMoney(double value) => _money.format(value);

/// مبلغ مع رمز العملة: `12,500 ر.س`.
String formatWithCurrency(double value, String symbol) => '${formatMoney(value)} $symbol';

/// يوم وشهر: `27 أكتوبر` أو `27 October`.
String formatDayMonth(DateTime d, [String lang = 'ar']) => '${d.day} ${monthName(d.month, lang)}';

/// شهر وسنة: `أكتوبر 2026` أو `October 2026`.
String formatMonthYear(DateTime d, String lang) => '${monthName(d.month, lang)} ${d.year}';
