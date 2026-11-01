import 'arabic_numbers.dart';

const Map<String, double> _fractionGlyphs = {
  '½': 0.5,
  '¼': 0.25,
  '¾': 0.75,
  '⅓': 1 / 3,
  '⅔': 2 / 3,
  '⅛': 0.125,
  '⅜': 0.375,
  '⅝': 0.625,
  '⅞': 0.875,
};

final String _glyphs = _fractionGlyphs.keys.join();

/// كمية من نص: `2` و`2.5` و`٢٫٥` و`1/2` و`1 1/2` و`½` و`1½`. null إن لم يكن النص كمية صالحة
/// أو كان سالبًا أو غير منتهٍ.
double? parseQuantity(String input) {
  var text = normalizeDigits(input.trim()).replaceAll('٫', '.').replaceAll(RegExp('[,٬]'), '');
  if (text.isEmpty) return null;
  final match = RegExp(
    r'^(?:(\d+(?:\.\d+)?))?\s*(?:(\d+)\s*/\s*(\d+)|([' + _glyphs + r']))?$',
  ).firstMatch(text);
  if (match == null) return null;
  final whole = match.group(1);
  final numerator = match.group(2);
  final denominator = match.group(3);
  final glyph = match.group(4);
  if (whole == null && numerator == null && glyph == null) return null;

  var value = whole == null ? 0.0 : double.parse(whole);
  if (numerator != null) {
    final d = int.parse(denominator!);
    if (d == 0) return null;
    value += int.parse(numerator) / d;
  } else if (glyph != null) {
    value += _fractionGlyphs[glyph]!;
  }
  return value.isFinite ? value : null;
}

/// يعرض الكمية بأبسط شكل: `2` و`2.5` و`1½` و`¼` (كسور شائعة بحروفها، وإلا حتى رقمين عشريين).
String formatQuantity(double value) {
  if (!value.isFinite || value < 0) return '';
  final rounded = (value * 100).round() / 100;
  final whole = rounded.floor();
  final fraction = rounded - whole;
  if (fraction < 0.005) return '$whole';
  for (final entry in _fractionGlyphs.entries) {
    if ((fraction - entry.value).abs() < 0.01) {
      return whole == 0 ? entry.key : '$whole${entry.key}';
    }
  }
  var text = rounded.toStringAsFixed(2);
  text = text.replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
  return text;
}

/// يفصل نصًا مثل "2 كجم" إلى كمية (2) ووحدة ("كجم"). نص بلا رقم في بدايته مثل "كثير" يرجع
/// كمية null والنص كله وحدة.
({double? amount, String unit}) splitQuantityText(String text) {
  final normalized = normalizeDigits(text.trim());
  final match = RegExp(
    r'^((?:\d+(?:[.,٫]\d+)?(?:\s+\d+/\d+|/\d+)?[' + _glyphs + r']?)|[' + _glyphs + r'])\s*(.*)$',
  ).firstMatch(normalized);
  if (match == null) return (amount: null, unit: normalized);
  final amount = parseQuantity(match.group(1)!);
  if (amount == null) return (amount: null, unit: normalized);
  return (amount: amount, unit: match.group(2)!.trim());
}

/// عكس [splitQuantityText]: "2" و"كجم" → "2 كجم".
String joinQuantity(double amount, String unit) {
  final number = formatQuantity(amount);
  return unit.isEmpty ? number : '$number $unit';
}
