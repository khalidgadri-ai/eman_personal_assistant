import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../core/ai/ai_errors.dart';
import '../../core/ai/ai_service.dart';
import '../../core/ai/provider_presets.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/ai_provider_screen.dart';
import '../../core/widgets/entry_dialog.dart';
import '../../core/widgets/undo_snackbar.dart';
import '../awareness/usage_awareness_screen.dart';
import '../reminders/reminder_notice.dart';
import '../settings/settings_button.dart';
import 'exercise_details_screen.dart';
import 'exercise_edit_screen.dart';
import 'health_service.dart';
import 'image_source_sheet.dart';
import 'models/exercise.dart';
import 'models/health_entry.dart';
import 'workout_log_screen.dart';

class HealthFitnessScreen extends StatefulWidget {
  /// [pickImage] و[aiProviderBuilder] يُستبدلان في الاختبارات فقط؛ الأصل هو كاميرا النظام أو
  /// المعرض والمحوّل الحقيقي للمزوّد.
  const HealthFitnessScreen({super.key, this.pickImage = pickExerciseImage, this.aiProviderBuilder});

  final ExerciseImagePicker pickImage;
  final AiProviderBuilder? aiProviderBuilder;

  @override
  State<HealthFitnessScreen> createState() => _HealthFitnessScreenState();
}

class _HealthFitnessScreenState extends State<HealthFitnessScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  HealthService? _health;
  List<Exercise> _exercises = [];
  List<Medication> _medications = [];
  List<BeautyItem> _beautyItems = [];
  bool _loadFailed = false;
  bool _isAnalyzingExercise = false;
  bool _isAnalyzingMed = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this)..addListener(_onTabChanged);
    _loadData();
  }

  @override
  void dispose() {
    _tabController
      ..removeListener(_onTabChanged)
      ..dispose();
    super.dispose();
  }

  void _onTabChanged() {
    // الزر العائم يتغير بحسب التبويب.
    if (!_tabController.indexIsChanging && mounted) setState(() {});
  }

  Future<void> _loadData() async {
    try {
      final health = await HealthService.getInstance();
      if (!mounted) return;
      setState(() {
        _health = health;
        _exercises = health.exercises();
        _medications = health.medications();
        _beautyItems = health.beautyItems();
        _loadFailed = false;
      });
    } catch (e) {
      debugPrint('HealthFitnessScreen: could not open health data (${e.runtimeType})');
      if (!mounted) return;
      setState(() => _loadFailed = true);
    }
  }

  void _refresh() {
    final health = _health;
    if (health == null || !mounted) return;
    setState(() {
      _exercises = health.exercises();
      _medications = health.medications();
      _beautyItems = health.beautyItems();
    });
  }

  /// يعيد جدولة التذكيرات بعد أي تغيير في الأدوية أو العناية. [ask] لا يكون true إلا حين ضبط
  /// المستخدم تذكيرًا بنفسه، فيُسأل عن إذن الإشعارات عندئذ وحده، ويُخبَر إن لم يُضمن أن يرن.
  void _syncReminders({bool ask = false}) {
    unawaited(syncRemindersWithNotice(context, ask: ask));
  }

  // --- التمارين ---

  Future<void> _addExercise({ExerciseDraft? draft, Uint8List? image}) async {
    final health = _health;
    if (health == null) return;
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ExerciseEditScreen(health: health, draft: draft, image: image, pickImage: widget.pickImage),
      ),
    );
    _refresh();
  }

  Future<void> _openExercise(Exercise exercise) async {
    final health = _health;
    if (health == null) return;
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => ExerciseDetailsScreen(health: health, exerciseId: exercise.id, pickImage: widget.pickImage),
      ),
    );
    _refresh();
  }

  Future<void> _deleteExercise(Exercise exercise) async {
    final removed = await _health?.deleteExercise(exercise.id);
    _refresh();
    if (removed == null || !mounted) return;
    showUndoSnackBar(context, 'حُذف «${exercise.name}»', () async {
      await _health?.restoreExercise(removed);
      _refresh();
    });
  }

  Future<void> _toggleExercisePin(Exercise exercise) async {
    await _health?.toggleExercisePin(exercise.id);
    _refresh();
  }

  void _openWorkoutLog() {
    final health = _health;
    if (health == null) return;
    Navigator.of(context).push<void>(MaterialPageRoute(builder: (_) => WorkoutLogScreen(health: health)));
  }

  // --- الأدوية ---

  Future<void> _addMedication() async {
    final health = _health;
    if (health == null) return;
    final values = await showEntryDialog(
      context,
      title: 'إضافة دواء أو مكمل',
      fields: const [
        EntryField(key: 'name', label: 'الاسم', hint: 'مثال: فيتامين د', required: true),
        EntryField(key: 'time', label: 'الوقت (اختياري)', hint: 'مثال: 09:00 صباحاً'),
        EntryField(key: 'reminder', label: 'تذكير', isTime: true),
      ],
    );
    if (values == null) return;
    await health.addMedication(name: values['name']!, time: values['time']!, reminder: values['reminder']!);
    _refresh();
    _syncReminders(ask: values['reminder']!.isNotEmpty);
  }

  Future<void> _editMedication(Medication med) async {
    final health = _health;
    if (health == null) return;
    final values = await showEntryDialog(
      context,
      title: 'تعديل الدواء',
      confirmLabel: 'حفظ',
      fields: [
        EntryField(key: 'name', label: 'الاسم', required: true, initial: med.name),
        EntryField(key: 'time', label: 'الوقت (اختياري)', initial: med.time),
        EntryField(key: 'reminder', label: 'تذكير', isTime: true, initial: med.reminder),
      ],
    );
    if (values == null) return;
    await health.updateMedication(med.id, name: values['name']!, time: values['time']!, reminder: values['reminder']!);
    _refresh();
    _syncReminders(ask: values['reminder']!.isNotEmpty);
  }

  Future<void> _setMedicationTaken(Medication med, bool taken) async {
    await _health?.setMedicationTaken(med.id, taken);
    _refresh();
  }

  Future<void> _deleteEntry(String id) async {
    await _health?.delete(id);
    _refresh();
    _syncReminders();
  }

  // --- روتين العناية ---

  Future<void> _addBeautyItem() async {
    final health = _health;
    if (health == null) return;
    final values = await showEntryDialog(
      context,
      title: 'إضافة منتج للروتين',
      fields: const [
        EntryField(key: 'item', label: 'المنتج', hint: 'مثال: مرطب البشرة', required: true),
        EntryField(key: 'time', label: 'الوقت', options: ['صباحاً', 'مساءً', 'صباحاً ومساءً']),
        EntryField(key: 'step', label: 'طريقة الاستخدام (اختياري)', maxLength: 200),
        EntryField(key: 'reminder', label: 'تذكير', isTime: true),
      ],
    );
    if (values == null) return;
    await health.addBeautyItem(
      item: values['item']!,
      time: values['time']!,
      step: values['step']!,
      reminder: values['reminder']!,
    );
    _refresh();
    _syncReminders(ask: values['reminder']!.isNotEmpty);
  }

  Future<void> _editBeautyItem(BeautyItem item) async {
    final health = _health;
    if (health == null) return;
    const times = ['صباحاً', 'مساءً', 'صباحاً ومساءً'];
    final values = await showEntryDialog(
      context,
      title: 'تعديل المنتج',
      confirmLabel: 'حفظ',
      fields: [
        EntryField(key: 'item', label: 'المنتج', required: true, initial: item.item),
        EntryField(
          key: 'time',
          label: 'الوقت',
          options: times.contains(item.time) || item.time.isEmpty ? times : [...times, item.time],
          initial: item.time.isEmpty ? times.first : item.time,
        ),
        EntryField(key: 'step', label: 'طريقة الاستخدام (اختياري)', maxLength: 200, initial: item.step),
        EntryField(key: 'reminder', label: 'تذكير', isTime: true, initial: item.reminder),
      ],
    );
    if (values == null) return;
    await health.updateBeautyItem(
      item.id,
      item: values['item']!,
      time: values['time']!,
      step: values['step']!,
      reminder: values['reminder']!,
    );
    _refresh();
    _syncReminders(ask: values['reminder']!.isNotEmpty);
  }

  // --- تحليل الصور بالذكاء الاصطناعي ---

  /// يلتقط صورة تمرين ويحلّلها بالمزوّد المختار، ثم يعرض النتيجة مع "حفظ كتمرين".
  Future<void> _analyzeExerciseImage() async {
    final ai = await requireAiService(context, builder: widget.aiProviderBuilder);
    if (ai == null || !mounted) return;
    final image = await widget.pickImage(context);
    if (image == null || !mounted) return;

    setState(() => _isAnalyzingExercise = true);
    String? text;
    String? error;
    try {
      text = await ai.analyzeImageStrict(
        imageBytes: image,
        mimeType: 'image/jpeg',
        prompt: AiService.exerciseAnalysisPrompt,
      );
    } catch (e) {
      error = aiFriendlyError(e);
    }
    if (!mounted) return;
    setState(() => _isAnalyzingExercise = false);

    if (error != null) {
      _showResultDialog('🏋️ تحليل التمرين والعضلات', error);
      return;
    }
    final reply = text!;
    final draft = ExerciseDraft.tryParse(reply);
    await _showExerciseResult(
      draft?.toDisplayText() ?? reply,
      // رد ليس بصيغة JSON: يُعرض كما هو ويمكن حفظه كملاحظة تمرين بعد مراجعته.
      draft ?? ExerciseDraft(notes: String.fromCharCodes(reply.runes.take(Exercise.maxNotesLength))),
      image,
    );
  }

  /// نتيجة تحليل التمرين: عرض ثم زر "حفظ كتمرين" يفتح نموذجًا معبّأ للمراجعة.
  Future<void> _showExerciseResult(String shown, ExerciseDraft draft, Uint8List image) async {
    final save = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: AppTheme.cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('🏋️ تحليل التمرين والعضلات', style: TextStyle(color: AppTheme.textColor, fontSize: 17)),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              // نص عادي فقط: ما يولّده الذكاء الاصطناعي لا يُفسَّر Markdown ولا روابط.
              child: SelectableText(shown, style: const TextStyle(color: AppTheme.subTextColor, fontSize: 14, height: 1.6)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('إغلاق', style: TextStyle(color: AppTheme.subTextColor)),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
              icon: const Icon(Icons.bookmark_add_rounded, color: Colors.white, size: 18),
              label: const Text('حفظ كتمرين', style: TextStyle(color: Colors.white)),
              onPressed: () => Navigator.pop(dialogContext, true),
            ),
          ],
        ),
      ),
    );
    if (save == true && mounted) await _addExercise(draft: draft, image: image);
  }

  /// يفتح الكاميرا أو المعرض ويرسل صورة الدواء للمزوّد المختار للتحليل.
  Future<void> _analyzeMedicationLabel() async {
    final ai = await requireAiService(context, builder: widget.aiProviderBuilder);
    if (ai == null || !mounted) return;
    final image = await widget.pickImage(context);
    if (image == null || !mounted) return;

    setState(() => _isAnalyzingMed = true);
    final result = await ai.analyzeMedicationLabel(image);

    if (!mounted) return;
    setState(() => _isAnalyzingMed = false);
    _showResultDialog('💊 تحليل علبة الدواء', result);
  }

  /// يعرض نتيجة التحليل في نافذة قابلة للتمرير
  void _showResultDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: AppTheme.cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(title, style: const TextStyle(color: AppTheme.textColor, fontSize: 17)),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: SelectableText(content, style: const TextStyle(color: AppTheme.subTextColor, fontSize: 14, height: 1.6)),
            ),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
              onPressed: () => Navigator.pop(context),
              child: const Text('حسناً', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget? _buildFab() {
    if (_health == null) return null;
    return switch (_tabController.index) {
      0 => FloatingActionButton(
          heroTag: 'add_exercise_fab',
          tooltip: 'إضافة تمرين',
          backgroundColor: AppTheme.primaryColor,
          onPressed: _addExercise,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      1 => FloatingActionButton(
          heroTag: 'add_medication_fab',
          tooltip: 'إضافة دواء',
          backgroundColor: AppTheme.primaryColor,
          onPressed: _addMedication,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      2 => FloatingActionButton(
          heroTag: 'add_beauty_fab',
          tooltip: 'إضافة منتج',
          backgroundColor: AppTheme.primaryColor,
          onPressed: _addBeautyItem,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      _ => null,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🏋️ الصحة واللياقة والعناية'),
        actions: [
          IconButton(
            tooltip: 'وعي الاستخدام',
            icon: const Icon(Icons.hourglass_bottom_rounded, color: AppTheme.accentColor),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const UsageAwarenessScreen()),
            ),
          ),
          const SettingsButton(),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.accentColor,
          labelColor: AppTheme.accentColor,
          unselectedLabelColor: AppTheme.subTextColor,
          tabs: const [
            Tab(text: 'التمارين والعضلات'),
            Tab(text: 'جدول الأدوية'),
            Tab(text: 'العناية بالبشرة'),
          ],
        ),
      ),
      floatingActionButton: _buildFab(),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFitnessTab(),
          _buildMedsTab(),
          _buildBeautyTab(),
        ],
      ),
    );
  }

  Widget _buildLoadFailedCard() {
    return Card(
      color: AppTheme.surfaceColor,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'تعذّر فتح بياناتك الصحية المحفوظة.',
              style: TextStyle(color: AppTheme.textColor),
            ),
            TextButton(
              onPressed: _loadData,
              child: const Text('إعادة المحاولة', style: TextStyle(color: AppTheme.accentColor)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFitnessTab() {
    final health = _health;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      children: [
        if (_loadFailed) _buildLoadFailedCard(),
        Card(
          color: AppTheme.surfaceColor,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Icon(Icons.fitness_center, size: 48, color: AppTheme.accentColor),
                const SizedBox(height: 10),
                const Text(
                  'تمارينك',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textColor),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                _isAnalyzingExercise
                    ? const Column(
                        children: [
                          CircularProgressIndicator(color: AppTheme.accentColor),
                          SizedBox(height: 8),
                          Text('جارٍ تحليل الصورة بالذكاء الاصطناعي...', style: TextStyle(color: AppTheme.subTextColor, fontSize: 12)),
                        ],
                      )
                    : ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                        onPressed: _analyzeExerciseImage,
                        icon: const Icon(Icons.camera_alt, color: Colors.white),
                        label: const Text('تحليل صورة التمرين بالذكاء الاصطناعي', style: TextStyle(color: Colors.white)),
                      ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            const Expanded(
              child: Text(
                'بطاقات التمارين بالجولات والتكرارات',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textColor),
              ),
            ),
            if (_exercises.isNotEmpty)
              TextButton.icon(
                onPressed: _openWorkoutLog,
                icon: const Icon(Icons.history_rounded, size: 18),
                label: const Text('السجل'),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (_exercises.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'لم تُضف تمارين بعد.',
                style: TextStyle(color: AppTheme.subTextColor),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        for (final exercise in _exercises) _exerciseCard(exercise, health),
      ],
    );
  }

  Widget _exerciseCard(Exercise exercise, HealthService? health) {
    final image = exercise.hasImage ? health?.exerciseImage(exercise.id) : null;
    return Card(
      key: ValueKey('exercise_${exercise.id}'),
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _openExercise(exercise),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 56,
                  height: 56,
                  child: image != null
                      ? Image.memory(image, fit: BoxFit.cover, cacheWidth: 160, gaplessPlayback: true)
                      : const ColoredBox(
                          color: AppTheme.surfaceColor,
                          child: Icon(Icons.fitness_center_rounded, color: AppTheme.accentColor),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (exercise.pinned)
                          const Padding(
                            padding: EdgeInsetsDirectional.only(end: 4),
                            child: Icon(Icons.push_pin_rounded, size: 14, color: AppTheme.accentColor),
                          ),
                        Expanded(
                          child: Text(
                            exercise.name,
                            style: const TextStyle(color: AppTheme.textColor, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      [if (exercise.muscles.isNotEmpty) exercise.muscles, exercise.setsAndReps].join(' · '),
                      style: const TextStyle(color: AppTheme.subTextColor, fontSize: 12),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: exercise.pinned ? 'إلغاء تثبيت التمرين' : 'تثبيت التمرين',
                icon: Icon(
                  exercise.pinned ? Icons.push_pin_rounded : Icons.push_pin_outlined,
                  color: AppTheme.subTextColor,
                ),
                onPressed: () => _toggleExercisePin(exercise),
              ),
              IconButton(
                tooltip: 'حذف التمرين',
                icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.subTextColor),
                onPressed: () => _deleteExercise(exercise),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMedsTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      children: [
        if (_loadFailed) _buildLoadFailedCard(),
        Card(
          color: AppTheme.surfaceColor,
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                const Row(
                  children: [
                    Icon(Icons.medication_liquid_rounded, color: AppTheme.accentColor),
                    SizedBox(width: 8),
                    Text('تحليل الدواء بالذكاء الاصطناعي', style: TextStyle(color: AppTheme.textColor, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'التقاط صورة لعلبة الدواء أو المكمل الغذائي لمعرفة الجرعة والتحذيرات',
                  style: TextStyle(color: AppTheme.subTextColor, fontSize: 13),
                ),
                const SizedBox(height: 12),
                _isAnalyzingMed
                    ? const Column(
                        children: [
                          CircularProgressIndicator(color: AppTheme.accentColor),
                          SizedBox(height: 8),
                          Text('جارٍ تحليل علبة الدواء...', style: TextStyle(color: AppTheme.subTextColor, fontSize: 12)),
                        ],
                      )
                    : ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
                        onPressed: _analyzeMedicationLabel,
                        icon: const Icon(Icons.camera_alt, color: Colors.white),
                        label: const Text('تحليل علبة الدواء 💊', style: TextStyle(color: Colors.white)),
                      ),
              ],
            ),
          ),
        ),
        const Text('توقيتات الأدوية والمكملات اليومية', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textColor)),
        const SizedBox(height: 12),
        if (_medications.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'لم تُضف أدوية أو مكملات بعد. اضغط + للإضافة.',
                style: TextStyle(color: AppTheme.subTextColor),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ..._medications.map((med) => Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            leading: Icon(
              Icons.medication_liquid_rounded,
              color: med.takenToday ? Colors.green : Colors.orangeAccent,
            ),
            title: Text(med.name, style: const TextStyle(color: AppTheme.textColor, fontWeight: FontWeight.bold)),
            subtitle: (med.time.isEmpty && med.reminder.isEmpty)
                ? null
                : Text(
                    [
                      if (med.time.isNotEmpty) med.time,
                      if (med.reminder.isNotEmpty) '⏰ ${med.reminder}',
                    ].join('  ·  '),
                    style: const TextStyle(color: AppTheme.subTextColor),
                  ),
            onTap: () => _editMedication(med),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Switch(
                  value: med.takenToday,
                  activeThumbColor: AppTheme.primaryColor,
                  onChanged: (val) => _setMedicationTaken(med, val),
                ),
                IconButton(
                  tooltip: 'حذف الدواء',
                  icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.subTextColor),
                  onPressed: () => _deleteEntry(med.id),
                ),
              ],
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildBeautyTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      children: [
        if (_loadFailed) _buildLoadFailedCard(),
        const Text('سجل منتجات الروتين اليومي للبشرة والشعر', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textColor)),
        const SizedBox(height: 12),
        if (_beautyItems.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'لم تُضف منتجات بعد. اضغط + للإضافة.',
                style: TextStyle(color: AppTheme.subTextColor),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ..._beautyItems.map((item) => Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            leading: const Icon(Icons.spa_rounded, color: AppTheme.accentColor),
            title: Text(item.item, style: const TextStyle(color: AppTheme.textColor, fontWeight: FontWeight.bold)),
            subtitle: Text(
              [item.time, item.step, if (item.reminder.isNotEmpty) '⏰ ${item.reminder}']
                  .where((s) => s.isNotEmpty)
                  .join(' - '),
              style: const TextStyle(color: AppTheme.subTextColor),
            ),
            onTap: () => _editBeautyItem(item),
            trailing: IconButton(
              tooltip: 'حذف المنتج',
              icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.subTextColor),
              onPressed: () => _deleteEntry(item.id),
            ),
          ),
        )),
      ],
    );
  }
}
