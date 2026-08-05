import 'package:flutter/material.dart';
import '../../core/services/gemini_service.dart';
import '../../core/services/database_service.dart';
import '../../core/theme/app_theme.dart';

class AIAssistantScreen extends StatefulWidget {
  const AIAssistantScreen({super.key});

  @override
  State<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends State<AIAssistantScreen> {
  GeminiService? _geminiService;
  DatabaseService? _db;
  final TextEditingController _promptController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String>> _messages = [
    {
      'sender': 'assistant',
      'text': 'أهلاً بك! أنا مساعدك الذكي المعتمد على Gemini Flash. كيف يمكنني مساعدتك في تنظيم جدولك اليومي، أو اقتراح وجبات، أو تحليل المذكرات والتمرين؟\n\n🔑 للبدء، تأكدي من إعداد مفتاح Gemini API الخاص بك من أيقونة المفتاح في الأعلى.'
    }
  ];
  bool _isLoading = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initServices();
  }

  Future<void> _initServices() async {
    final service = await GeminiService.create();
    final db = await DatabaseService.getInstance();
    if (mounted) {
      setState(() {
        _geminiService = service;
        _db = db;
        _isInitialized = true;
      });
    }
  }

  /// يفتح نافذة حوارية لإدخال مفتاح Gemini API وحفظه ديناميكياً
  void _showApiKeyDialog() async {
    if (_db == null) return;
    final currentKey = _db!.getGeminiApiKey();
    final keyController = TextEditingController(text: currentKey);
    bool isObscured = true;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              backgroundColor: AppTheme.cardColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Row(
                children: [
                  Icon(Icons.vpn_key_rounded, color: AppTheme.accentColor),
                  SizedBox(width: 8),
                  Text('مفتاح Gemini API', style: TextStyle(color: AppTheme.textColor, fontSize: 18)),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'احصلي على مفتاح مجاني من:',
                    style: TextStyle(color: AppTheme.subTextColor, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  const SelectableText(
                    'aistudio.google.com/app/apikey',
                    style: TextStyle(color: AppTheme.accentColor, fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: keyController,
                    obscureText: isObscured,
                    style: const TextStyle(color: AppTheme.textColor, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'AIzaSy...',
                      hintStyle: const TextStyle(color: AppTheme.subTextColor),
                      filled: true,
                      fillColor: AppTheme.surfaceColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          isObscured ? Icons.visibility_off : Icons.visibility,
                          color: AppTheme.subTextColor,
                        ),
                        onPressed: () => setModalState(() => isObscured = !isObscured),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '⚠️ المفتاح يُحفظ محلياً على جهازك فقط ولا يُرسل لأي خادم خارجي.',
                    style: TextStyle(color: Colors.amber, fontSize: 11),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('إلغاء', style: TextStyle(color: AppTheme.subTextColor)),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
                  icon: const Icon(Icons.save_rounded, color: Colors.white, size: 18),
                  label: const Text('حفظ وتفعيل', style: TextStyle(color: Colors.white)),
                  onPressed: () async {
                    final newKey = keyController.text.trim();
                    if (newKey.isEmpty) return;
                    // Capture context-dependent objects before async gap
                    final nav = Navigator.of(context);
                    final messenger = ScaffoldMessenger.of(context);
                    await _geminiService?.resetModel(newKey);
                    if (mounted) {
                      nav.pop();
                      setState(() {
                        _messages.add({
                          'sender': 'assistant',
                          'text': '✅ تم تفعيل مفتاح API بنجاح! يمكنك الآن استخدام جميع ميزات الذكاء الاصطناعي.',
                        });
                      });
                      _scrollToBottom();
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text('✅ تم حفظ مفتاح API بنجاح'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
    keyController.dispose();
  }

  void _sendMessage() async {
    if (_geminiService == null) return;
    final text = _promptController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({'sender': 'user', 'text': text});
      _isLoading = true;
      _promptController.clear();
    });
    _scrollToBottom();

    final response = await _geminiService!.askAssistant(text);

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
        title: const Text('🤖 مساعد Gemini الذكي'),
        actions: [
          // ✅ زر إعداد مفتاح API
          IconButton(
            tooltip: 'إعداد مفتاح Gemini API',
            icon: const Icon(Icons.vpn_key_rounded, color: AppTheme.accentColor),
            onPressed: _isInitialized ? _showApiKeyDialog : null,
          ),
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
                    child: Text(
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
                    decoration: const InputDecoration(
                      hintText: 'اسأل المساعد الذكي أو اطلب اقتراحاً...',
                      hintStyle: TextStyle(color: AppTheme.subTextColor),
                      border: InputBorder.none,
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send_rounded, color: AppTheme.accentColor),
                  onPressed: _isInitialized ? _sendMessage : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
