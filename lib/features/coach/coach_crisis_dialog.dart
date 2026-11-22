import 'package:flutter/material.dart';
import '../../core/services/contact_service.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/l10n.dart';
import 'coach_safety.dart';

/// منطقة الجوال (مثل SA) لترتيب خطوط المساعدة.
String? deviceCountryCode() => WidgetsBinding.instance.platformDispatcher.locale.countryCode;

/// نافذة المساعدة عند إشارة أزمة: رقم الطوارئ المحلي ودليل خطوط المساعدة لكل بلد، والخطوط
/// السعودية الرسمية تحت عنوان يقول إنها سعودية (أولًا على جوال سعودي). يستعملها المدرب وأدواته.
Future<void> showCrisisHelpDialog(
  BuildContext context, {
  String? countryCode,
  LinkOpener openLink = openExternalLink,
}) async {
  final l10n = context.l10n;
  final general = <Widget>[
    Text(
      l10n.crisisLocalEmergency,
      style: const TextStyle(color: AppTheme.textColor, fontWeight: FontWeight.w600, height: 1.6),
    ),
    const SizedBox(height: 8),
    OutlinedButton.icon(
      style: OutlinedButton.styleFrom(side: const BorderSide(color: AppTheme.accentColor)),
      onPressed: () => openLink(crisisHelplineFinderUrl),
      icon: const Icon(Icons.open_in_new_rounded, size: 18, color: AppTheme.accentColor),
      label: Text(l10n.crisisFinderLabel, style: const TextStyle(color: AppTheme.accentColor)),
    ),
    const SizedBox(height: 16),
  ];
  final saudi = <Widget>[
    Text(
      l10n.crisisSaudiNote,
      style: const TextStyle(color: AppTheme.subTextColor, fontSize: 12, fontWeight: FontWeight.w600),
    ),
    const SizedBox(height: 8),
    for (final line in crisisHelplines)
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SelectableText(
              line.number,
              textDirection: TextDirection.ltr,
              style: const TextStyle(color: AppTheme.accentColor, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              line.descriptionFor(context.appLang),
              style: const TextStyle(color: AppTheme.subTextColor, fontSize: 12),
            ),
          ],
        ),
      ),
  ];
  final saudiFirst = showSaudiHelplinesFirst(countryCode);

  await showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: AppTheme.cardColor,
      title: Text(l10n.crisisImportant, style: const TextStyle(color: AppTheme.textColor)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.crisisResponse, style: const TextStyle(color: AppTheme.textColor, height: 1.6)),
            const SizedBox(height: 16),
            ...saudiFirst ? [...saudi, ...general] : [...general, ...saudi],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: Text(l10n.gotIt, style: const TextStyle(color: AppTheme.primaryColor)),
        ),
      ],
    ),
  );
}
