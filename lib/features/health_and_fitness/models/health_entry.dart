class Medication {
  final String id;
  final String name;
  final String time;

  /// وقت التذكير اليومي بصيغة `HH:mm`، أو فارغ إن لم يُضبط تذكير.
  final String reminder;

  /// تُحسب لليوم الحالي فقط: تعود "لم تؤخذ" تلقائيًا كل يوم جديد.
  final bool takenToday;

  const Medication({
    required this.id,
    required this.name,
    required this.time,
    this.reminder = '',
    required this.takenToday,
  });
}

class BeautyItem {
  final String id;
  final String item;
  final String time;
  final String step;

  /// وقت التذكير اليومي بصيغة `HH:mm`، أو فارغ إن لم يُضبط تذكير.
  final String reminder;

  const BeautyItem({
    required this.id,
    required this.item,
    required this.time,
    required this.step,
    this.reminder = '',
  });
}
