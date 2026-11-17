import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../ai/provider_presets.dart';
import '../theme/app_theme.dart';

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

  List<String> get _steps => _isGemini
      ? const [
          'اضغط «افتح صفحة المفاتيح».',
          'سجّل الدخول بحساب Google.',
          'وافق على الشروط إن ظهرت.',
          'اضغط الزر المكتوب عليه Create API key (قد يظهر بلغة جوالك).',
          'انسخ المفتاح.',
          'ارجع إلى التطبيق والصقه في خانة «المفتاح»، ثم اضغط «حفظ وتفعيل».',
        ]
      : const [
          'اضغط «افتح صفحة المفاتيح».',
          'سجّل الدخول.',
          'أنشئ مفتاحًا جديدًا.',
          'انسخ المفتاح، ثم ارجع إلى التطبيق والصقه في خانة «المفتاح»، ثم اضغط «حفظ وتفعيل».',
        ];

  Future<void> _openKeyPage(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    var opened = false;
    try {
      opened = await linkOpener(Uri.parse(preset.keyUrl));
    } catch (e) {
      debugPrint('ApiKeyGuide: could not open the key page (${e.runtimeType})');
    }
    if (opened) return;
    await Clipboard.setData(ClipboardData(text: preset.keyUrl));
    messenger.showSnackBar(const SnackBar(content: Text('تم نسخ الرابط. الصقه في المتصفح.')));
  }

  @override
  Widget build(BuildContext context) {
    const body = TextStyle(color: AppTheme.textColor, fontSize: 15, height: 1.7);
    const note = TextStyle(color: AppTheme.subTextColor, fontSize: 13, height: 1.7);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'المفتاح مثل كلمة سرّ خاصة بك من المزوّد، يسمح للتطبيق أن يسأل الذكاء الاصطناعي باسمك.',
          style: body,
        ),
        const SizedBox(height: 12),
        Text('الخطوات مع ${preset.label}:', style: note),
        const SizedBox(height: 4),
        for (var i = 0; i < _steps.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 24,
                  child: Text('${i + 1}.', style: const TextStyle(color: AppTheme.accentColor, fontSize: 15)),
                ),
                Expanded(child: Text(_steps[i], style: body)),
              ],
            ),
          ),
        const SizedBox(height: 8),
        Text(
          _isGemini
              ? 'لـ Gemini استعمال مجاني ضمن حدود تضعها Google. وإن فعّلت الدفع في حسابك عند Google فقد تُحتسب عليك رسوم.'
              : 'قد يطلب بعض المزوّدين إضافة وسيلة دفع قبل أن يعمل المفتاح.',
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
          child: const Row(
            children: [
              Icon(Icons.lock_rounded, color: Colors.orange),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'لا تشارك مفتاحك مع أحد ولا تنشره. يُحفظ على جوالك فقط.',
                  style: TextStyle(color: AppTheme.textColor, height: 1.6),
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
              label: const Text('افتح صفحة المفاتيح'),
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
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('كيف أحصل على مفتاح؟')),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ApiKeyGuide(preset: preset, linkOpener: linkOpener),
          ),
        ),
      ),
    );
  }
}
