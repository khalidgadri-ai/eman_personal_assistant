import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../ai/ai_errors.dart';
import '../ai/ai_models.dart';
import '../ai/ai_provider.dart';
import '../ai/ai_service.dart';
import '../ai/ai_settings_service.dart';
import '../ai/provider_presets.dart';
import '../theme/app_theme.dart';

/// يرجّع [AiService] بمزوّد ومفتاح المستخدم، وإن لم يكن مُعدًّا يعرض شاشة الإعداد أولًا.
/// يرجّع null إذا رجع المستخدم دون إعداد.
Future<AiService?> requireAiService(
  BuildContext context, {
  String? systemPrompt,
  AiProviderBuilder? builder,
}) async {
  final service = await AiService.create(systemPrompt: systemPrompt, builder: builder);
  if (service.isConfigured) return service;
  if (!context.mounted) return null;

  await Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (_) => const AiProviderScreen()),
  );

  final refreshed = await AiService.create(systemPrompt: systemPrompt, builder: builder);
  return refreshed.isConfigured ? refreshed : null;
}

/// صورة PNG بحجم 1×1 بكسل لاختبار دعم الصور بأقل كلفة.
final Uint8List _probeImage = Uint8List.fromList(const [
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52, //
  0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4,
  0x89, 0x00, 0x00, 0x00, 0x0D, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0xF8, 0xFF, 0xFF, 0x3F,
  0x00, 0x05, 0xFE, 0x02, 0xFE, 0xA7, 0x35, 0x81, 0x84, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E,
  0x44, 0xAE, 0x42, 0x60, 0x82,
]);

class AiProviderScreen extends StatefulWidget {
  /// [providerBuilder] يُستبدل في الاختبارات فقط؛ الأصل هو المحوّل الحقيقي.
  const AiProviderScreen({super.key, this.providerBuilder = buildAiProvider});

  final AiProviderBuilder providerBuilder;

  @override
  State<AiProviderScreen> createState() => _AiProviderScreenState();
}

class _AiProviderScreenState extends State<AiProviderScreen> {
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _keyController = TextEditingController();

  AiSettingsService? _settings;
  String _presetId = AiPresets.geminiId;
  AiSupport _images = AiSupport.unknown;
  String _savedKeyPreview = '';
  bool _obscured = true;
  bool _loading = true;
  bool _busy = false;
  _Outcome? _outcome;

  AiProviderPreset get _preset => AiPresets.byId(_presetId);

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _urlController.dispose();
    _modelController.dispose();
    _keyController.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    try {
      final settings = await AiSettingsService.getInstance();
      _settings = settings;
      await _selectPreset(settings.selectedId ?? AiPresets.geminiId);
    } catch (e) {
      debugPrint('AiProviderScreen: settings unavailable (${e.runtimeType})');
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _selectPreset(String id) async {
    final settings = _settings;
    if (settings == null) return;
    final config = settings.configFor(id);
    final preview = await settings.keyPreview(id);
    if (!mounted) return;
    setState(() {
      _presetId = id;
      _urlController.text = config.baseUrl;
      _modelController.text = config.model;
      _images = config.images;
      _keyController.clear();
      _savedKeyPreview = preview;
      _outcome = null;
    });
  }

  /// الإعداد الظاهر في الحقول، أو رسالة الخطأ العربية إن كان غير صالح.
  AiProviderConfig? _readConfig({bool allowEmptyModel = false}) {
    final config = AiProviderConfig(
      id: _presetId,
      kind: _preset.kind,
      baseUrl: _urlController.text.trim(),
      model: _modelController.text.trim(),
      images: _images,
    );
    try {
      if (allowEmptyModel) {
        validateBaseUrl(config.baseUrl);
      } else {
        config.validate();
      }
      return config;
    } on AiException catch (e) {
      setState(() => _outcome = _Outcome.failure(e.message));
      return null;
    }
  }

  /// المفتاح المكتوب في الحقل، وإلا المحفوظ. فارغ إن لم يوجد أيٌّ منهما.
  Future<String> _effectiveKey() async {
    final typed = _keyController.text.trim();
    if (typed.isNotEmpty) return typed;
    return await _settings?.readKey(_presetId) ?? '';
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() {
      _busy = true;
      _outcome = null;
    });
    try {
      await action();
    } catch (e) {
      if (mounted) setState(() => _outcome = _Outcome.failure(aiFriendlyError(e)));
    }
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _testConnection() async {
    final config = _readConfig();
    if (config == null) return;
    await _run(() async {
      final key = await _effectiveKey();
      if (key.isEmpty) throw const AiException(AiFailure.missingKey);
      await widget.providerBuilder(config, key).testConnection();
      if (mounted) setState(() => _outcome = const _Outcome.success('الاتصال سليم والموديل يرد.'));
    });
  }

  Future<void> _testImages() async {
    final config = _readConfig();
    if (config == null) return;
    await _run(() async {
      final key = await _effectiveKey();
      if (key.isEmpty) throw const AiException(AiFailure.missingKey);
      try {
        await widget.providerBuilder(config, key).send(AiRequest(
          messages: [
            AiMessage.user('ما لون هذه الصورة؟ أجب بكلمة.', images: [AiImage(_probeImage, 'image/png')]),
          ],
          maxOutputTokens: 64,
        ));
      } on AiException catch (e) {
        if (e.failure == AiFailure.emptyReply) {
          // وصلنا رد ناجح بلا نص: الموديل قبل الصورة.
        } else if (e.failure == AiFailure.imageUnsupported || e.failure == AiFailure.badRequest) {
          if (mounted) {
            setState(() {
              _images = AiSupport.no;
              _outcome = _Outcome.failure('الموديل لم يقبل الصورة، فعُلّم بأنه لا يدعم الصور.');
            });
          }
          return;
        } else {
          rethrow;
        }
      }
      if (mounted) {
        setState(() {
          _images = AiSupport.yes;
          _outcome = const _Outcome.success('الموديل يدعم الصور.');
        });
      }
    });
  }

  Future<void> _fetchModels() async {
    final config = _readConfig(allowEmptyModel: true);
    if (config == null) return;
    List<AiModelInfo>? models;
    await _run(() async {
      final key = await _effectiveKey();
      if (key.isEmpty) throw const AiException(AiFailure.missingKey);
      models = await widget.providerBuilder(config, key).listModels();
    });
    final list = models;
    if (list == null || !mounted) return;
    if (list.isEmpty) {
      setState(() => _outcome = _Outcome.failure('لم يُرجع المزوّد أي موديل.'));
      return;
    }
    final picked = await showModalBottomSheet<AiModelInfo>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.cardColor,
      builder: (_) => _ModelPicker(models: list),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _modelController.text = picked.id;
      if (picked.supportsImages != AiSupport.unknown) _images = picked.supportsImages;
    });
  }

  Future<void> _save() async {
    final config = _readConfig();
    final settings = _settings;
    if (config == null || settings == null) return;
    await _run(() async {
      final typed = _keyController.text.trim();
      if (typed.isEmpty && !await settings.hasKey(_presetId)) {
        throw const AiException(AiFailure.missingKey);
      }
      await settings.save(config);
      if (typed.isNotEmpty) await settings.saveKey(_presetId, typed);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حفظ إعداد الذكاء الاصطناعي.')),
      );
      Navigator.of(context).pop();
    });
  }

  Future<void> _deleteKey() async {
    final settings = _settings;
    if (settings == null) return;
    await _run(() async {
      await settings.deleteKey(_presetId);
      _keyController.clear();
      final preview = await settings.keyPreview(_presetId);
      if (mounted) {
        setState(() {
          _savedKeyPreview = preview;
          _outcome = const _Outcome.success('حُذف المفتاح من هذا الجهاز.');
        });
      }
    });
  }

  Future<void> _copyKeyLink() async {
    await Clipboard.setData(ClipboardData(text: _preset.keyUrl));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم نسخ الرابط')));
  }

  InputDecoration _decoration(String hint, {Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppTheme.subTextColor),
      filled: true,
      fillColor: AppTheme.surfaceColor,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
      suffixIcon: suffix,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('مزوّد الذكاء الاصطناعي')),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppTheme.cardColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'اختر المزوّد الذي تريد استعماله وأدخل مفتاحك الخاص منه.\n'
                        'المفتاح يُحفظ على جهازك فقط في تخزين آمن، ويُرسل إلى المزوّد الذي تختاره وحده مع طلباتك، '
                        'بلا خادم وسيط. ما تُرسله يخضع لسياسة الخصوصية لدى ذلك المزوّد.',
                        style: TextStyle(color: AppTheme.subTextColor, fontSize: 13, height: 1.8),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text('المزوّد', style: TextStyle(color: AppTheme.subTextColor, fontSize: 13)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      key: ValueKey(_presetId),
                      initialValue: _presetId,
                      isExpanded: true,
                      dropdownColor: AppTheme.cardColor,
                      decoration: _decoration(''),
                      style: const TextStyle(color: AppTheme.textColor),
                      items: [
                        for (final p in AiPresets.all)
                          DropdownMenuItem(value: p.id, child: Text(p.label)),
                      ],
                      onChanged: _busy ? null : (id) => id == null ? null : _selectPreset(id),
                    ),
                    const SizedBox(height: 16),
                    const Text('عنوان المزوّد', style: TextStyle(color: AppTheme.subTextColor, fontSize: 13)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _urlController,
                      readOnly: !_preset.editableUrl,
                      textDirection: TextDirection.ltr,
                      keyboardType: TextInputType.url,
                      style: TextStyle(
                        color: _preset.editableUrl ? AppTheme.textColor : AppTheme.subTextColor,
                        fontSize: 13,
                      ),
                      decoration: _decoration('https://example.com/v1'),
                    ),
                    const SizedBox(height: 16),
                    const Text('اسم الموديل', style: TextStyle(color: AppTheme.subTextColor, fontSize: 13)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _modelController,
                      textDirection: TextDirection.ltr,
                      autocorrect: false,
                      enableSuggestions: false,
                      style: const TextStyle(color: AppTheme.textColor, fontSize: 13),
                      decoration: _decoration('اكتب الاسم أو اجلبه من المزوّد'),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: _busy ? null : _fetchModels,
                      icon: const Icon(Icons.cloud_download_rounded, size: 18),
                      label: const Text('جلب الموديلات المتاحة'),
                    ),
                    const SizedBox(height: 16),
                    const Text('المفتاح', style: TextStyle(color: AppTheme.subTextColor, fontSize: 13)),
                    if (_preset.keyUrl.isNotEmpty)
                      Row(
                        children: [
                          Expanded(
                            child: SelectableText(
                              _preset.keyUrl,
                              textDirection: TextDirection.ltr,
                              style: const TextStyle(color: AppTheme.accentColor, fontSize: 12),
                            ),
                          ),
                          IconButton(
                            tooltip: 'نسخ الرابط',
                            icon: const Icon(Icons.copy_rounded, color: AppTheme.accentColor),
                            onPressed: _copyKeyLink,
                          ),
                        ],
                      ),
                    const SizedBox(height: 4),
                    TextField(
                      controller: _keyController,
                      obscureText: _obscured,
                      textDirection: TextDirection.ltr,
                      autocorrect: false,
                      enableSuggestions: false,
                      style: const TextStyle(color: AppTheme.textColor, fontSize: 13),
                      decoration: _decoration(
                        _savedKeyPreview.isEmpty ? 'الصق مفتاحك هنا' : 'محفوظ: $_savedKeyPreview (اتركه فارغًا للإبقاء عليه)',
                        suffix: IconButton(
                          tooltip: _obscured ? 'إظهار المفتاح' : 'إخفاء المفتاح',
                          icon: Icon(
                            _obscured ? Icons.visibility_off : Icons.visibility,
                            color: AppTheme.subTextColor,
                          ),
                          onPressed: () => setState(() => _obscured = !_obscured),
                        ),
                      ),
                    ),
                    if (_savedKeyPreview.isNotEmpty)
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: TextButton(
                          onPressed: _busy ? null : _deleteKey,
                          child: const Text('حذف المفتاح المحفوظ', style: TextStyle(color: Colors.redAccent)),
                        ),
                      ),
                    const SizedBox(height: 12),
                    const Text('هل يدعم الموديل الصور؟', style: TextStyle(color: AppTheme.subTextColor, fontSize: 13)),
                    const SizedBox(height: 6),
                    SegmentedButton<AiSupport>(
                      showSelectedIcon: false,
                      segments: const [
                        ButtonSegment(value: AiSupport.yes, label: Text('نعم')),
                        ButtonSegment(value: AiSupport.no, label: Text('لا')),
                        ButtonSegment(value: AiSupport.unknown, label: Text('غير معروف')),
                      ],
                      selected: {_images},
                      onSelectionChanged: _busy ? null : (s) => setState(() => _images = s.first),
                    ),
                    TextButton(
                      onPressed: _busy ? null : _testImages,
                      child: const Text('اختبار دعم الصور تلقائيًا'),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _busy ? null : _testConnection,
                            icon: const Icon(Icons.wifi_tethering_rounded, size: 18),
                            label: const Text('اختبار الاتصال'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
                            onPressed: _busy ? null : _save,
                            icon: const Icon(Icons.save_rounded, color: Colors.white, size: 18),
                            label: const Text('حفظ وتفعيل', style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                    if (_busy)
                      const Padding(
                        padding: EdgeInsets.only(top: 16),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    if (_outcome != null) _OutcomeCard(outcome: _outcome!),
                  ],
                ),
              ),
      ),
    );
  }
}

class _Outcome {
  const _Outcome.success(this.message) : ok = true;
  const _Outcome.failure(this.message) : ok = false;

  final bool ok;
  final String message;
}

class _OutcomeCard extends StatelessWidget {
  const _OutcomeCard({required this.outcome});

  final _Outcome outcome;

  @override
  Widget build(BuildContext context) {
    final color = outcome.ok ? Colors.green : Colors.redAccent;
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color),
      ),
      child: Row(
        children: [
          Icon(outcome.ok ? Icons.check_circle_rounded : Icons.error_rounded, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(outcome.message, style: const TextStyle(color: AppTheme.textColor, height: 1.6)),
          ),
        ],
      ),
    );
  }
}

/// قائمة الموديلات المجلوبة مع بحث (OpenRouter وحده يُرجع مئات الموديلات).
class _ModelPicker extends StatefulWidget {
  const _ModelPicker({required this.models});

  final List<AiModelInfo> models;

  @override
  State<_ModelPicker> createState() => _ModelPickerState();
}

class _ModelPickerState extends State<_ModelPicker> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final query = _query.trim().toLowerCase();
    final shown = widget.models
        .where((m) => query.isEmpty || m.id.toLowerCase().contains(query) || (m.label ?? '').toLowerCase().contains(query))
        .toList();
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  autofocus: false,
                  textDirection: TextDirection.ltr,
                  style: const TextStyle(color: AppTheme.textColor),
                  decoration: InputDecoration(
                    hintText: 'بحث في ${widget.models.length} موديل',
                    hintStyle: const TextStyle(color: AppTheme.subTextColor),
                    prefixIcon: const Icon(Icons.search_rounded),
                  ),
                  onChanged: (v) => setState(() => _query = v),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: shown.length,
                  itemBuilder: (context, index) {
                    final model = shown[index];
                    return ListTile(
                      title: Text(
                        model.id,
                        textDirection: TextDirection.ltr,
                        style: const TextStyle(color: AppTheme.textColor, fontSize: 14),
                      ),
                      subtitle: model.label == null || model.label == model.id
                          ? null
                          : Text(model.label!, style: const TextStyle(color: AppTheme.subTextColor, fontSize: 12)),
                      trailing: switch (model.supportsImages) {
                        AiSupport.yes => const Icon(Icons.image_rounded, size: 18, color: AppTheme.accentColor),
                        _ => null,
                      },
                      onTap: () => Navigator.of(context).pop(model),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
