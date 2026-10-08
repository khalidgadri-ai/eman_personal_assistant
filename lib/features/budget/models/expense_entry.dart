import 'package:flutter/material.dart' show IconData, Icons;

enum ExpenseCategory { food, transport, entertainment, bills, shopping, other }

extension ExpenseCategoryDisplay on ExpenseCategory {
  String get arabicLabel => switch (this) {
        ExpenseCategory.food => 'طعام',
        ExpenseCategory.transport => 'مواصلات',
        ExpenseCategory.entertainment => 'ترفيه',
        ExpenseCategory.bills => 'فواتير',
        ExpenseCategory.shopping => 'تسوق',
        ExpenseCategory.other => 'أخرى',
      };

  IconData get icon => switch (this) {
        ExpenseCategory.food => Icons.restaurant_rounded,
        ExpenseCategory.transport => Icons.directions_car_rounded,
        ExpenseCategory.entertainment => Icons.movie_rounded,
        ExpenseCategory.bills => Icons.receipt_long_rounded,
        ExpenseCategory.shopping => Icons.shopping_bag_rounded,
        ExpenseCategory.other => Icons.more_horiz_rounded,
      };
}

class ExpenseEntry {
  final String id;
  final double amount;
  final ExpenseCategory category;
  final String? note;
  final DateTime date;

  const ExpenseEntry({
    required this.id,
    required this.amount,
    required this.category,
    this.note,
    required this.date,
  });

  factory ExpenseEntry.fromMap(String id, Map map) {
    return ExpenseEntry(
      id: id,
      amount: (map['amount'] as num).toDouble(),
      category: ExpenseCategory.values.byName(map['category'] as String),
      note: map['note'] as String?,
      date: map['date'] as DateTime,
    );
  }

  Map<String, dynamic> toMap() => {
        'amount': amount,
        'category': category.name,
        'note': note,
        'date': date,
      };
}

/// يقبل الأرقام العربية-الهندية والفاصلة العشرية العربية، ويرجّع null لأي مبلغ غير موجب.
double? parseAmount(String input) {
  const arabicDigits = '٠١٢٣٤٥٦٧٨٩';
  final buffer = StringBuffer();
  for (final char in input.trim().split('')) {
    final digit = arabicDigits.indexOf(char);
    if (digit >= 0) {
      buffer.write(digit);
    } else if (char == '٫') {
      buffer.write('.');
    } else if (char != ',' && char != '،' && char != '٬') {
      buffer.write(char);
    }
  }
  final value = double.tryParse(buffer.toString());
  if (value == null || !value.isFinite || value <= 0) return null;
  return value;
}
