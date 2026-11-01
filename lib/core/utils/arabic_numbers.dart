/// يحوّل الأرقام العربية-الهندية (٠-٩) والفارسية (۰-۹) إلى 0-9 حتى يقبلها `int.tryParse`.
String normalizeDigits(String input) {
  final buffer = StringBuffer();
  for (final unit in input.runes) {
    if (unit >= 0x0660 && unit <= 0x0669) {
      buffer.writeCharCode(0x30 + unit - 0x0660);
    } else if (unit >= 0x06F0 && unit <= 0x06F9) {
      buffer.writeCharCode(0x30 + unit - 0x06F0);
    } else {
      buffer.writeCharCode(unit);
    }
  }
  return buffer.toString();
}

/// عدد صحيح من نص يحتوي أرقامًا عربية أو غربية؛ null إن لم يكن عددًا صحيحًا.
int? parseInteger(String input) => int.tryParse(normalizeDigits(input.trim()));
