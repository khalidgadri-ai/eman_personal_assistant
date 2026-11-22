import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../ai/provider_presets.dart';
import '../theme/app_theme.dart';
import '../../l10n/l10n.dart';

/// يفتح رابطًا في المتصفح خارج التطبيق. يرجّع false إن تعذّر الفتح.
typedef LinkOpener = Future<bool> Function(Uri uri);

/// الفتح الحقيقي: متصفح الجوال، بلا WebView داخل التطبيق ولا canLaunchUrl.
Future<bool> openExternalLink(Uri uri) async {
  try {
    return await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (e) {
    debugPrint('openExternalLink: ${e.runtimeType}');
    return false;
  }
}

/// شرح الحصول على مفتاح من [preset] خطوة بخطوة. يُستعمل في صفحة الجولة وفي شاشة مستقلة.
/// لا يعرض أي مفتاح ولا مثالًا لشكله.
class ApiKeyGuide extends StatelessWidget {
  const ApiKeyGuide({super.key, required this.preset, this.linkOpener = openExternalLink});

  final AiProviderPreset preset;
  final LinkOpener linkOpener;

  bool get _isGemini => preset.id == AiPresets.geminiId;

  List<String> _steps(AppLocalizations l10n) => _isGemini
      ? [
          l10n.keyGuideGemini1,
          l10n.keyGuideGemini2,
          l10n.keyGuideGemini3,
          l10n.keyGuideGemini4,
          l10n.keyGuideGemini5,
          l10n.keyGuideGemini6,
        ]
      : [
          l10n.keyGuideOther1,
          l10n.keyGuideOther2,
          l10n.keyGuideOther3,
          l10n.keyGuideOther4,
        ];

  Future<void> _openKeyPage(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final copied = context.l10n.keyGuideLinkCopied;
    var opened = false;
    try {
      opened = await linkOpener(Uri.parse(preset.keyUrl));
    } catch (e) {
      debugPrint('ApiKeyGuide: could not open the key page (${e.runtimeType})');
    }
    if (opened) return;
    await Clipboard.setData(ClipboardData(text: preset.keyUrl));
    messenger.showSnackBar(SnackBar(content: Text(copied)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final steps = _steps(l10n);
    const body = TextStyle(color: AppTheme.textColor, fontSize: 15, height: 1.7);
    const note = TextStyle(color: AppTheme.subTextColor, fontSize: 13, height: 1.7);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.keyGuideIntro, style: body),
        const SizedBox(height: 12),
        Text(l10n.keyGuideStepsWith(preset.displayLabel), style: note),
        const SizedBox(height: 4),
        for (var i = 0; i < steps.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 24,
                  child: Text('${i + 1}.', style: const TextStyle(color: AppTheme.accentColor, fontSize: 15)),
                ),
                Expanded(child: Text(steps[i], style: body)),
              ],
            ),
          ),
        const SizedBox(height: 8),
        Text(
          _isGemini ? l10n.keyGuideGeminiFree : l10n.keyGuidePaymentNote,
          style: note,
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.orange.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.orange),
          ),
          child: Row(
            children: [
              const Icon(Icons.lock_rounded, color: Colors.orange),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l10n.keyGuideDontShare,
                  style: const TextStyle(color: AppTheme.textColor, height: 1.6),
                ),
              ),
            ],
          ),
        ),
        if (preset.keyUrl.isNotEmpty) ...[
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(minimumSize: const Size(0, 48)),
              onPressed: () => _openKeyPage(context),
              icon: const Icon(Icons.open_in_new_rounded),
              label: Text(l10n.keyGuideOpenPage),
            ),
          ),
        ],
      ],
    );
  }
}

/// الدليل في شاشة مستقلة، تُفتح من «كيف أحصل على مفتاح؟» في شاشة المزوّد.
class ApiKeyGuideScreen extends StatelessWidget {
  const ApiKeyGuideScreen({super.key, required this.preset, this.linkOpener = openExternalLink});

  final AiProviderPreset preset;
  final LinkOpener linkOpener;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.keyGuideTitle)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ApiKeyGuide(preset: preset, linkOpener: linkOpener),
        ),
      ),
    );
  }
}
