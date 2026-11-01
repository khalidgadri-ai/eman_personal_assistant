import 'dart:math';

final Random _random = Random();
int _counter = 0;

/// معرّف قصير فريد لعنصر محفوظ (وصفة، صنف، تمرين...). الوقت + عدّاد + رقم عشوائي، فلا
/// يتكرر حتى لو أُنشئ عنصران في اللحظة نفسها.
String newId() {
  final time = DateTime.now().microsecondsSinceEpoch.toRadixString(36);
  final count = (_counter++ % 1296).toRadixString(36).padLeft(2, '0');
  final noise = _random.nextInt(1296).toRadixString(36).padLeft(2, '0');
  return '$time$count$noise';
}
