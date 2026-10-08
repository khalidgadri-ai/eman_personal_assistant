import 'dart:math' as math;

/// أقرب خطوة "مستديرة" (1، 2، 2.5، 5 × 10ⁿ) لتكون أرقام محاور الرسوم نظيفة.
double niceAxisStep(double rough) {
  if (rough <= 0) return 1;
  final magnitude = math.pow(10, (math.log(rough) / math.ln10).floor()).toDouble();
  for (final factor in const [1.0, 2.0, 2.5, 5.0, 10.0]) {
    if (factor * magnitude >= rough) return factor * magnitude;
  }
  return 10 * magnitude;
}
