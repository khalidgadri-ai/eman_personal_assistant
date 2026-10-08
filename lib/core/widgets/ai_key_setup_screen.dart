import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/gemini_service.dart';
import '../theme/app_theme.dart';

const String aiStudioKeyUrl = 'https://aistudio.google.com/app/apikey';

/// يرجّع GeminiService بمفتاح المستخدم، وإن لم يوجد مفتاح يعرض شاشة التفعيل أولًا.
/// يرجّع null إذا رجع المستخدم بدون حفظ مفتاح.
Future<GeminiService?> requireGeminiService(BuildContext context) async {
  final service = await GeminiService.create();
  if (service.hasKey) return service;
  if (!context.mounted) return null;

  await Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (_) => const AiKeySetupScreen()),
  );

  final refreshed = await GeminiService.create();
  return refreshed.hasKey ? refreshed : null;
}

class AiKeySetupScreen extends StatefulWidget {
  const AiKeySetupScreen({super.key});

  @override
  State<AiKeySetupScreen> createState() => _AiKeySetupScreenState();
}

class _AiKeySetupScreenState extends State<AiKeySetupScreen> {
  final TextEditingController _keyController = TextEditingController();
  bool _obscured = true;
  bool _saving = false;

  @override
  void dispose() {
    _keyController.dispose();
    super.dispose();
  }

  Future<void> _copyLink() async {
    await Clipboard.setData(const ClipboardData(text: aiStudioKeyUrl));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم نسخ الرابط')),
    );
  }

  Future<void> _save() async {
    final key = _keyController.text.trim();
    if (key.isEmpty) return;
    setState(() => _saving = true);
    final service = await GeminiService.create();
    await service.resetModel(key);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('تفعيل الذكاء الاصطناعي')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'فعّل ميزات الذكاء الاصطناعي بمفتاحك الخاص (مجاني من Google AI Studio)',
                style: TextStyle(
                  color: AppTheme.textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'لا نطلب منك بيانات دفع ولا حسابًا لدينا: كل مستخدم يفعّل الميزات بمفتاحه المجاني الخاص.\n'
                  'مفتاحك يُحفظ على جهازك فقط، وطلباتك تذهب مباشرة إلى Google بدون أي خادم وسيط.\n'
                  'لا يوجد مفتاح مشترك يمكن أن يُسرَّب أو يتوقف فتتعطل الخدمة على الجميع.',
                  style: TextStyle(color: AppTheme.subTextColor, fontSize: 13, height: 1.8),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'احصل على مفتاحك من:',
                style: TextStyle(color: AppTheme.subTextColor, fontSize: 13),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Expanded(
                    child: SelectableText(
                      aiStudioKeyUrl,
                      textDirection: TextDirection.ltr,
                      style: TextStyle(color: AppTheme.accentColor, fontSize: 13),
                    ),
                  ),
                  IconButton(
                    tooltip: 'نسخ الرابط',
                    icon: const Icon(Icons.copy_rounded, color: AppTheme.accentColor),
                    onPressed: _copyLink,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _keyController,
                obscureText: _obscured,
                textDirection: TextDirection.ltr,
                style: const TextStyle(color: AppTheme.textColor, fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'الصق مفتاحك هنا',
                  hintStyle: const TextStyle(color: AppTheme.subTextColor),
                  filled: true,
                  fillColor: AppTheme.surfaceColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscured ? Icons.visibility_off : Icons.visibility,
                      color: AppTheme.subTextColor,
                    ),
                    onPressed: () => setState(() => _obscured = !_obscured),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
                  onPressed: _saving ? null : _save,
                  icon: const Icon(Icons.vpn_key_rounded, color: Colors.white, size: 18),
                  label: const Text('حفظ وتفعيل', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
