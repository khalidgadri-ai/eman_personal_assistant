import 'package:flutter/material.dart';
import '../../core/ai/ai_service.dart';
import '../../core/services/assistant_prompt.dart';
import '../../core/services/profile_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/ai_provider_screen.dart';
import '../settings/settings_button.dart';

class AIAssistantScreen extends StatefulWidget {
  const AIAssistantScreen({super.key});

  @override
  State<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends State<AIAssistantScreen> {
  AiService? _aiService;
  String _systemPrompt = buildAssistantSystemPrompt(null);
  final TextEditingController _promptController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initServices();
  }

  Future<void> _initServices() async {
    // التعليمات والترحيب يُبنيان من ملف المستخدم نفسه فقط؛ لو تعذّرت قراءته يبقيان عامّين.
    UserProfile? profile;
    try {
      profile = (await ProfileService.getInstance()).profile;
    } catch (_) {
      profile = null;
    }
    final systemPrompt = buildAssistantSystemPrompt(profile);
    final service = await AiService.create(systemPrompt: systemPrompt);
    if (mounted) {
      setState(() {
        _systemPrompt = systemPrompt;
        _aiService = service;
        _messages.add({'sender': 'assistant', 'text': assistantGreeting(profile?.name ?? '')});
        _isInitialized = true;
      });
    }
  }

  /// يفتح شاشة إعداد المزوّد (المزوّد والموديل والمفتاح) ثم يعيد تهيئة الخدمة بما حُفظ.
  Future<void> _openProviderSettings() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const AiProviderScreen()),
    );
    final service = await AiService.create(systemPrompt: _systemPrompt);
    if (!mounted) return;
    setState(() {
      final wasConfigured = _aiService?.isConfigured ?? false;
      _aiService = service;
      if (service.isConfigured && !wasConfigured) {
        _messages.add({
          'sender': 'assistant',
          'text': '✅ تم تفعيل المزوّد بنجاح! يمكنك الآن استخدام جميع ميزات الذكاء الاصطناعي.',
        });
      }
    });
    _scrollToBottom();
  }

  void _sendMessage() async {
    if (_aiService == null || _isLoading) return;
    final text = _promptController.text.trim();
    if (text.isEmpty) return;

    if (!_aiService!.isConfigured) {
      final service = await requireAiService(context, systemPrompt: _systemPrompt);
      if (service == null || !mounted) return;
      _aiService = service;
    }

    setState(() {
      _messages.add({'sender': 'user', 'text': text});
      _isLoading = true;
      _promptController.clear();
    });
    _scrollToBottom();

    final response = await _aiService!.askAssistant(text);

    if (!mounted) return;
    setState(() {
      _messages.add({'sender': 'assistant', 'text': response});
      _isLoading = false;
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _promptController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🤖 المساعد الذكي'),
        actions: [
          // زر إعداد مزوّد الذكاء الاصطناعي ومفتاحه
          IconButton(
            tooltip: 'إعداد مزوّد الذكاء الاصطناعي',
            icon: const Icon(Icons.vpn_key_rounded, color: AppTheme.accentColor),
            onPressed: _isInitialized ? _openProviderSettings : null,
          ),
          const SettingsButton(),
        ],
      ),
      body: Column(
        children: [
          // شريط حالة التهيئة
          if (!_isInitialized)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              color: AppTheme.surfaceColor,
              child: const Row(
                children: [
                  SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.accentColor)),
                  SizedBox(width: 10),
                  Text('جارٍ تهيئة المساعد الذكي...', style: TextStyle(color: AppTheme.subTextColor, fontSize: 13)),
                ],
              ),
            ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg['sender'] == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isUser ? AppTheme.primaryColor : AppTheme.cardColor,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.82,
                    ),
                    // ردود الذكاء الاصطناعي نص عادي فقط: لا Markdown ولا HTML ولا روابط تُفتح.
                    child: SelectableText(
                      msg['text']!,
                      style: const TextStyle(color: AppTheme.textColor, fontSize: 15, height: 1.5),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: AppTheme.accentColor, strokeWidth: 2)),
                  SizedBox(width: 10),
                  Text('جارٍ التفكير...', style: TextStyle(color: AppTheme.subTextColor, fontSize: 13)),
                ],
              ),
            ),
          Container(
            padding: const EdgeInsets.all(12),
            color: AppTheme.cardColor,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _promptController,
                    enabled: _isInitialized,
                    maxLines: null,
                    maxLength: 4000,
                    decoration: const InputDecoration(
                      hintText: 'اسأل المساعد الذكي أو اطلب اقتراحاً...',
                      hintStyle: TextStyle(color: AppTheme.subTextColor),
                      border: InputBorder.none,
                      counterText: '',
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  tooltip: 'إرسال',
                  icon: const Icon(Icons.send_rounded, color: AppTheme.accentColor),
                  onPressed: _isInitialized && !_isLoading ? _sendMessage : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
