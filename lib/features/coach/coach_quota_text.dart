import '../../core/services/free_quota_service.dart';
import '../budget/budget_format.dart';

/// السطر الصغير تحت زر «عمّق أكثر» لغير المشترك.
String coachQuotaLine({required int remaining, required DateTime now}) {
  if (remaining > 0) {
    return 'متبقٍ $remaining من ${FreeQuotaService.coachFollowUpMonthlyLimit} مجانًا هذا الشهر';
  }
  return 'انتهت المحاولات المجانية لهذا الشهر، وتتجدد في ${_renewalDay(now)}';
}

/// تُعرض في شاشة الاشتراك حين فُتحت لأن المحاولات المجانية انتهت.
String coachQuotaRenewalLine(DateTime now) => 'تتجدد محاولاتك المجانية في ${_renewalDay(now)}';

/// الجملة التعريفية في شاشة الاشتراك.
String get coachQuotaOfferLine =>
    'تحصل مجانًا على ${FreeQuotaService.coachFollowUpMonthlyLimit} أسئلة متابعة كل شهر. '
    'الاشتراك يجعلها بلا حد.';

String _renewalDay(DateTime now) => formatDayMonth(FreeQuotaService.renewsOn(now));
