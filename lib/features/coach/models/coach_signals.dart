import 'coach_question.dart';
import '../../../core/config/app_locale.dart';

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
      return AppLocale.texts.coachHintBudget;
    }
    if (usage && domain == CoachDomain.organization) {
      return AppLocale.texts.coachHintUsage;
    }
    if (reflection?.domain == domain) {
      return AppLocale.texts.coachHintReflection;
    }
    return null;
  }
}
