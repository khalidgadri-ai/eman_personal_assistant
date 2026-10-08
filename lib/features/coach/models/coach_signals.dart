import 'coach_question.dart';

class ReflectionSignal {
  /// الكلمة بعد التطبيع وإزالة "ال" والضمير، وليست للعرض.
  final String topic;
  final CoachDomain domain;

  const ReflectionSignal({required this.topic, required this.domain});
}

class CoachSignals {
  final bool budget;
  final bool usage;
  final ReflectionSignal? reflection;

  const CoachSignals({this.budget = false, this.usage = false, this.reflection});

  static const CoachSignals none = CoachSignals();

  /// تلميح فقط إذا كان المجال المختار هو مجال المحفّز، بدون أي تفاصيل أو أحكام.
  String? hintFor(CoachDomain domain) {
    if (budget && domain == CoachDomain.budget) {
      return 'لاحظنا نمط في مصاريفك هذا الأسبوع';
    }
    if (usage && domain == CoachDomain.organization) {
      return 'هذا السؤال مرتبط بتوزيع وقتك اليوم';
    }
    if (reflection?.domain == domain) {
      return 'لاحظنا فكرة تتكرر في إجاباتك الأخيرة';
    }
    return null;
  }
}
