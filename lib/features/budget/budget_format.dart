import 'package:intl/intl.dart' as intl;

const List<String> arabicMonthNames = [
  'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
  'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
];

final intl.NumberFormat _money = intl.NumberFormat('#,##0.##');

/// مبلغ بفواصل الآلاف وبأقل كسور ممكنة: `12,500` و`25.5`.
String formatMoney(double value) => _money.format(value);

/// مبلغ مع رمز العملة: `12,500 ر.س`.
String formatWithCurrency(double value, String symbol) => '${formatMoney(value)} $symbol';

/// يوم وشهر بالعربية: `27 أكتوبر`.
String formatDayMonth(DateTime d) => '${d.day} ${arabicMonthNames[d.month - 1]}';
