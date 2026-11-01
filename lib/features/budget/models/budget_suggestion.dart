import 'dart:convert';

import 'expense_entry.dart';

/// اقتراح حدود فئات يستخلصه التطبيق من رد الذكاء الاصطناعي. **الرد بيانات غير موثوقة**: لا يؤخذ
/// منه إلا الفئات المعروفة بمبالغ موجبة ضمن الحد، والملاحظة تُنظَّف وتُقصّ. لا يُحفظ شيء قبل أن
/// يضغط المستخدم "حفظ كحدود".
class BudgetSuggestion {
  const BudgetSuggestion({required this.limits, this.note = ''});

  static const int maxNoteLength = 300;

  final Map<ExpenseCategory, double> limits;
  final String note;

  double get total => limits.values.fold(0.0, (a, b) => a + b);

  static String _cleanNote(Object? value) {
    if (value is! String) return '';
    final text = value
        .replaceAll(RegExp(r'[\u0000-\u0008\u000B\u000C\u000E-\u001F\u007F]'), '')
        .replaceAll(RegExp(r'[ \t]+'), ' ')
        .trim();
    return String.fromCharCodes(text.runes.take(maxNoteLength));
  }

  /// يقبل JSON صافيًا أو داخل سور كود أو بنص قبله وبعده. null إن لم يوجد كائن JSON فيه فئة
  /// واحدة صالحة على الأقل.
  static BudgetSuggestion? tryParse(String raw) {
    final start = raw.indexOf('{');
    final end = raw.lastIndexOf('}');
    if (start < 0 || end <= start) return null;
    final Object? decoded;
    try {
      decoded = jsonDecode(raw.substring(start, end + 1));
    } catch (_) {
      return null;
    }
    if (decoded is! Map) return null;
    final rawLimits = decoded['limits'];
    if (rawLimits is! Map) return null;

    final limits = <ExpenseCategory, double>{};
    for (final category in ExpenseCategory.values) {
      final v = rawLimits[category.name];
      final amount = switch (v) {
        num n => n.toDouble(),
        String s => parseAmount(s),
        _ => null,
      };
      if (amount != null && amount.isFinite && amount > 0 && amount <= ExpenseEntry.maxAmount) {
        limits[category] = amount;
      }
    }
    if (limits.isEmpty) return null;
    return BudgetSuggestion(limits: limits, note: _cleanNote(decoded['note']));
  }
}
