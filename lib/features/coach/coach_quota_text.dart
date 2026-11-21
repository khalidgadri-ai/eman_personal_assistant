import '../../core/services/free_quota_service.dart';
import '../budget/budget_format.dart';
import '../../core/config/app_locale.dart';

/// السطر الصغير تحت زر «عمّق أكثر» لغير المشترك.
String coachQuotaLine({required int remaining, required DateTime now}) {
  if (remaining > 0) {
    return AppLocale.texts.coachQuotaRemaining(remaining, FreeQuotaService.coachFollowUpMonthlyLimit);
  }
  return AppLocale.texts.coachQuotaUsedUp(_renewalDay(now));
}

/// تُعرض في شاشة الاشتراك حين فُتحت لأن المحاولات المجانية انتهت.
String coachQuotaRenewalLine(DateTime now) => AppLocale.texts.coachQuotaRenews(_renewalDay(now));

/// الجملة التعريفية في شاشة الاشتراك.
String get coachQuotaOfferLine => AppLocale.texts.coachQuotaOffer(FreeQuotaService.coachFollowUpMonthlyLimit);

String _renewalDay(DateTime now) => formatDayMonth(FreeQuotaService.renewsOn(now), AppLocale.current.languageCode);
