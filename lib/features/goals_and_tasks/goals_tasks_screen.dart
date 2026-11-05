import 'dart:async';

import 'package:flutter/material.dart';
import '../../core/services/database_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/arabic_numbers.dart';
import '../../core/utils/ids.dart';
import '../../core/widgets/ai_provider_screen.dart';
import '../../core/widgets/entry_dialog.dart';
import '../../core/widgets/undo_snackbar.dart';
import '../reminders/reminder_notice.dart';
import '../settings/settings_button.dart';

const List<String> _taskCategories = ['شخصي', 'المنزل', 'العمل', 'العائلة'];
const List<String> _goalTypes = ['هدف عام', 'هدف سنوي', 'هدف شهري', 'هدف أسبوعي'];

class GoalsTasksScreen extends StatefulWidget {
  const GoalsTasksScreen({super.key});

  @override
  State<GoalsTasksScreen> createState() => _GoalsTasksScreenState();
}

class _GoalsTasksScreenState extends State<GoalsTasksScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DatabaseService? _db;

  List<Map<String, dynamic>> _dailyTasks = [];
  List<Map<String, dynamic>> _goals = [];
  int _quranPage = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this)..addListener(_onTabChanged);
    _loadData();
  }

  void _onTabChanged() {
    // الزر العائم يتغير بحسب التبويب.
    if (!_tabController.indexIsChanging && mounted) setState(() {});
  }

  Future<void> _loadData() async {
    final db = await DatabaseService.getInstance();
    final tasks = db.getDailyTasks();
    final goals = db.getGoals();
    // مهام وأهداف قديمة بلا معرّف: يُمنح كل منها معرّفًا ثابتًا ويُحفظ فورًا (التذكيرات تحتاجه).
    if (_ensureIds(tasks)) await db.saveDailyTasks(tasks);
    if (_ensureIds(goals)) await db.saveGoals(goals);
    if (!mounted) return;
    setState(() {
      _db = db;
      _dailyTasks = tasks;
      _goals = goals;
      _quranPage = db.getQuranPage();
    });
  }

  static bool _ensureIds(List<Map<String, dynamic>> items) {
    var changed = false;
    for (final item in items) {
      final id = item['id'];
      if (id is! String || id.isEmpty) {
        item['id'] = newId();
        changed = true;
      }
    }
    return changed;
  }

  /// المثبّتة أولًا مع بقاء الترتيب الأصلي داخل كل مجموعة.
  static List<Map<String, dynamic>> _pinnedFirst(List<Map<String, dynamic>> items) => [
        ...items.where((i) => i['pinned'] == true),
        ...items.where((i) => i['pinned'] != true),
      ];

  void _syncReminders({bool ask = false}) => unawaited(syncRemindersWithNotice(context, ask: ask));

  // --- المهام ---

  void _addNewTask(String title, String category, {String reminder = ''}) {
    if (title.trim().isEmpty) return;
    setState(() {
      _dailyTasks.add({
        'id': newId(),
        'title': title.trim(),
        'category': category,
        'done': false,
        'pinned': false,
        'reminder': reminder,
      });
    });
    _db?.saveDailyTasks(_dailyTasks);
    _syncReminders(ask: reminder.isNotEmpty);
  }

  Future<void> _showAddTaskDialog() async {
    final values = await showEntryDialog(
      context,
      title: 'إضافة مهمة جديدة',
      fields: const [
        EntryField(key: 'title', label: 'المهمة', hint: 'اكتب نص المهمة...', required: true),
        EntryField(key: 'category', label: 'التصنيف', options: _taskCategories),
        EntryField(key: 'reminder', label: 'تذكير', isTime: true),
      ],
    );
    if (values == null) return;
    _addNewTask(values['title']!, values['category']!, reminder: values['reminder']!);
  }

  Future<void> _editTask(Map<String, dynamic> task) async {
    final category = '${task['category'] ?? _taskCategories.first}';
    final values = await showEntryDialog(
      context,
      title: 'تعديل المهمة',
      confirmLabel: 'حفظ',
      fields: [
        EntryField(key: 'title', label: 'المهمة', required: true, initial: '${task['title'] ?? ''}'),
        EntryField(
          key: 'category',
          label: 'التصنيف',
          options: _taskCategories.contains(category) ? _taskCategories : [..._taskCategories, category],
          initial: category,
        ),
        EntryField(key: 'reminder', label: 'تذكير', isTime: true, initial: '${task['reminder'] ?? ''}'),
      ],
    );
    if (values == null) return;
    setState(() {
      task['title'] = values['title'];
      task['category'] = values['category'];
      task['reminder'] = values['reminder'];
    });
    await _db?.saveDailyTasks(_dailyTasks);
    _syncReminders(ask: values['reminder']!.isNotEmpty);
  }

  Future<void> _toggleTaskPin(Map<String, dynamic> task) async {
    setState(() => task['pinned'] = task['pinned'] != true);
    await _db?.saveDailyTasks(_dailyTasks);
  }

  void _deleteTask(Map<String, dynamic> task) {
    final index = _dailyTasks.indexOf(task);
    setState(() => _dailyTasks.remove(task));
    _db?.saveDailyTasks(_dailyTasks);
    _syncReminders();
    showUndoSnackBar(context, 'حُذفت «${task['title']}»', () async {
      if (!mounted) return;
      setState(() => _dailyTasks.insert(index.clamp(0, _dailyTasks.length), task));
      await _db?.saveDailyTasks(_dailyTasks);
      _syncReminders();
    });
  }

  // --- الأهداف ---

  Future<void> _showAddGoalDialog() async {
    final values = await showEntryDialog(
      context,
      title: 'إضافة هدف',
      fields: const [
        EntryField(key: 'title', label: 'الهدف', hint: 'مثال: قراءة 20 صفحة يوميًا', required: true),
        EntryField(key: 'type', label: 'النوع', options: _goalTypes),
      ],
    );
    if (values == null) return;
    setState(() {
      _goals.add({
        'id': newId(),
        'title': values['title']!,
        'type': values['type']!,
        'progress': 0.0,
        'pinned': false,
      });
    });
    await _db?.saveGoals(_goals);
  }

  Future<void> _editGoal(Map<String, dynamic> goal) async {
    final type = '${goal['type'] ?? _goalTypes.first}';
    final values = await showEntryDialog(
      context,
      title: 'تعديل الهدف',
      confirmLabel: 'حفظ',
      fields: [
        EntryField(key: 'title', label: 'الهدف', required: true, initial: '${goal['title'] ?? ''}'),
        EntryField(
          key: 'type',
          label: 'النوع',
          options: _goalTypes.contains(type) ? _goalTypes : [..._goalTypes, type],
          initial: type,
        ),
      ],
    );
    if (values == null) return;
    setState(() {
      goal['title'] = values['title'];
      goal['type'] = values['type'];
    });
    await _db?.saveGoals(_goals);
  }

  Future<void> _toggleGoalPin(Map<String, dynamic> goal) async {
    setState(() => goal['pinned'] = goal['pinned'] != true);
    await _db?.saveGoals(_goals);
  }

  void _deleteGoal(Map<String, dynamic> goal) {
    final index = _goals.indexOf(goal);
    setState(() => _goals.remove(goal));
    _db?.saveGoals(_goals);
    showUndoSnackBar(context, 'حُذف الهدف «${goal['title']}»', () async {
      if (!mounted) return;
      setState(() => _goals.insert(index.clamp(0, _goals.length), goal));
      await _db?.saveGoals(_goals);
    });
  }

  // --- الورد ---

  void _changeQuranPage(int page) {
    final clamped = page.clamp(0, DatabaseService.quranPages);
    setState(() => _quranPage = clamped);
    _db?.saveQuranPage(clamped);
  }

  Future<void> _showSetQuranPageDialog() async {
    final values = await showEntryDialog(
      context,
      title: 'تحديد الصفحة الحالية',
      confirmLabel: 'حفظ',
      fields: [
        EntryField(
          key: 'page',
          label: 'رقم الصفحة (0 - ${DatabaseService.quranPages})',
          keyboardType: TextInputType.number,
          maxLength: 3,
          required: true,
          initial: '$_quranPage',
          validator: (value) {
            final page = parseInteger(value);
            if (page == null || page < 0 || page > DatabaseService.quranPages) {
              return 'أدخل رقمًا من 0 إلى ${DatabaseService.quranPages}';
            }
            return null;
          },
        ),
      ],
    );
    if (values == null) return;
    _changeQuranPage(parseInteger(values['page']!) ?? _quranPage);
  }

  /// ✅ يفتح نافذة كتابة المذكرة الصوتية ويستخرج المهام بالذكاء الاصطناعي
  void _showVoiceNoteDialog() {
    final noteController = TextEditingController();
    bool isAnalyzing = false;
    String aiResult = '';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: AlertDialog(
                backgroundColor: AppTheme.cardColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                title: const Row(
                  children: [
                    Icon(Icons.mic_rounded, color: AppTheme.accentColor),
                    SizedBox(width: 8),
                    Text('🎙️ استيراد من المذكرة الصوتية', style: TextStyle(color: AppTheme.textColor, fontSize: 16)),
                  ],
                ),
                content: SizedBox(
                  width: double.maxFinite,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'اكتب نص المذكرة الصوتية أو ما تريد تحويله لمهام:',
                          style: TextStyle(color: AppTheme.subTextColor, fontSize: 13),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: noteController,
                          maxLines: 4,
                          maxLength: 2000,
                          style: const TextStyle(color: AppTheme.textColor, fontSize: 14),
                          decoration: InputDecoration(
                            hintText: 'مثال: أريد اليوم إنهاء التقرير، والذهاب للسوق، وترتيب الخزانة...',
                            hintStyle: const TextStyle(color: AppTheme.subTextColor, fontSize: 12),
                            filled: true,
                            fillColor: AppTheme.surfaceColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        if (aiResult.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceColor,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppTheme.accentColor.withValues(alpha: 0.3)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.auto_awesome, color: AppTheme.accentColor, size: 16),
                                    SizedBox(width: 6),
                                    Text('المهام المستخرجة:', style: TextStyle(color: AppTheme.accentColor, fontWeight: FontWeight.bold, fontSize: 13)),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(aiResult, style: const TextStyle(color: AppTheme.subTextColor, fontSize: 13, height: 1.5)),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('إغلاق', style: TextStyle(color: AppTheme.subTextColor)),
                  ),
                  if (aiResult.isEmpty)
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
                      onPressed: isAnalyzing
                          ? null
                          : () async {
                              final text = noteController.text.trim();
                              if (text.isEmpty) return;
                              final ai = await requireAiService(context);
                              if (ai == null || !context.mounted) return;
                              setModalState(() => isAnalyzing = true);
                              final result = await ai.parseVoiceNoteToTasks(text);
                              if (!context.mounted) return;
                              setModalState(() {
                                isAnalyzing = false;
                                aiResult = result;
                              });
                            },
                      icon: isAnalyzing
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
                      label: Text(isAnalyzing ? 'جارٍ الاستخراج...' : 'استخرج المهام 🧠', style: const TextStyle(color: Colors.white)),
                    ),
                  if (aiResult.isNotEmpty)
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      onPressed: () {
                        // استيراد المهام من النتيجة وإضافتها للقائمة
                        final lines = aiResult
                            .split('\n')
                            .map((l) => l.replaceAll(RegExp(r'^[-•*\d.]+\s*'), '').trim())
                            .where((l) => l.length > 3)
                            .toList();

                        int addedCount = 0;
                        for (final line in lines) {
                          if (line.isNotEmpty) {
                            _addNewTask(line, 'شخصي');
                            addedCount++;
                          }
                        }

                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('✅ تم استيراد $addedCount مهمة بنجاح'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                      icon: const Icon(Icons.playlist_add_check_rounded, color: Colors.white, size: 18),
                      label: const Text('استورد المهام للقائمة ✅', style: TextStyle(color: Colors.white)),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _tabController
      ..removeListener(_onTabChanged)
      ..dispose();
    super.dispose();
  }

  Widget? _buildFab() {
    if (_db == null) return null;
    return switch (_tabController.index) {
      0 => FloatingActionButton(
          heroTag: 'add_task_fab',
          tooltip: 'إضافة مهمة',
          backgroundColor: AppTheme.primaryColor,
          onPressed: _showAddTaskDialog,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      1 => FloatingActionButton(
          heroTag: 'add_goal_fab',
          tooltip: 'إضافة هدف',
          backgroundColor: AppTheme.primaryColor,
          onPressed: _showAddGoalDialog,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      _ => null,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🎯 الأهداف والمهام اليومية'),
        actions: [
          // ✅ زر المذكرة الصوتية في الـ AppBar
          IconButton(
            tooltip: 'استيراد مهام من المذكرة الصوتية',
            icon: const Icon(Icons.mic_rounded, color: AppTheme.accentColor),
            onPressed: _showVoiceNoteDialog,
          ),
          const SettingsButton(),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.accentColor,
          labelColor: AppTheme.accentColor,
          unselectedLabelColor: AppTheme.subTextColor,
          tabs: const [
            Tab(text: 'المهام اليومية'),
            Tab(text: 'الأهداف الهرمية'),
            Tab(text: 'الورد والتتبع'),
          ],
        ),
      ),
      floatingActionButton: _buildFab(),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDailyTasksTab(),
          _buildGoalsCascadeTab(),
          _buildQuranTrackerTab(),
        ],
      ),
    );
  }

  Widget _buildDailyTasksTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      children: [
        const Text(
          'مركز إدارة المهام المقسمة',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textColor),
        ),
        const SizedBox(height: 4),
        const Text(
          'اضغط على أيقونة الميكروفون 🎙️ في الأعلى لاستيراد مهام من مذكرتك الصوتية',
          style: TextStyle(fontSize: 12, color: AppTheme.subTextColor),
        ),
        const SizedBox(height: 12),
        if (_dailyTasks.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text('لا توجد مهام بعد. اضغط + لإضافة مهمة أو استخدم المذكرة الصوتية.', style: TextStyle(color: AppTheme.subTextColor), textAlign: TextAlign.center),
            ),
          ),
        ..._pinnedFirst(_dailyTasks).map((task) => Card(
          key: ValueKey('task_${task['id']}'),
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            leading: Checkbox(
              value: task['done'] == true,
              activeColor: AppTheme.primaryColor,
              onChanged: (val) {
                setState(() {
                  task['done'] = val ?? false;
                });
                _db?.saveDailyTasks(_dailyTasks);
                // مهمة أُنجزت لا تُذكَّر بها، وإعادتها تعيد تذكيرها.
                _syncReminders();
              },
            ),
            title: Text(
              '${task['title']}',
              style: TextStyle(
                color: AppTheme.textColor,
                decoration: task['done'] == true ? TextDecoration.lineThrough : null,
              ),
            ),
            subtitle: '${task['reminder'] ?? ''}'.isEmpty
                ? null
                : Text('⏰ ${task['reminder']}', style: const TextStyle(color: AppTheme.subTextColor, fontSize: 12)),
            onTap: () => _editTask(task),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${task['category']}',
                    style: const TextStyle(color: AppTheme.accentColor, fontSize: 12),
                  ),
                ),
                IconButton(
                  tooltip: task['pinned'] == true ? 'إلغاء تثبيت المهمة' : 'تثبيت المهمة',
                  icon: Icon(
                    task['pinned'] == true ? Icons.push_pin_rounded : Icons.push_pin_outlined,
                    color: AppTheme.subTextColor,
                  ),
                  onPressed: () => _toggleTaskPin(task),
                ),
                IconButton(
                  tooltip: 'حذف المهمة',
                  icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.subTextColor),
                  onPressed: () => _deleteTask(task),
                ),
              ],
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildGoalsCascadeTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      children: [
        const Text(
          'محرك الأهداف الهرمية (السنوية ⬅️ الشهرية ⬅️ الأسبوعية)',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textColor),
        ),
        const SizedBox(height: 12),
        if (_goals.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text('لا توجد أهداف بعد. اضغط + لإضافة هدفك الأول.', style: TextStyle(color: AppTheme.subTextColor), textAlign: TextAlign.center),
            ),
          ),
        ..._pinnedFirst(_goals).map((goal) {
          final progress = ((goal['progress'] as num?)?.toDouble() ?? 0).clamp(0.0, 1.0);
          return Card(
            key: ValueKey('goal_${goal['id']}'),
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${goal['type']}', style: const TextStyle(color: AppTheme.accentColor, fontWeight: FontWeight.bold)),
                      Row(
                        children: [
                          Text('${(progress * 100).round()}%', style: const TextStyle(color: AppTheme.textColor)),
                          IconButton(
                            tooltip: 'تعديل الهدف',
                            icon: const Icon(Icons.edit_rounded, color: AppTheme.subTextColor),
                            onPressed: () => _editGoal(goal),
                          ),
                          IconButton(
                            tooltip: goal['pinned'] == true ? 'إلغاء تثبيت الهدف' : 'تثبيت الهدف',
                            icon: Icon(
                              goal['pinned'] == true ? Icons.push_pin_rounded : Icons.push_pin_outlined,
                              color: AppTheme.subTextColor,
                            ),
                            onPressed: () => _toggleGoalPin(goal),
                          ),
                          IconButton(
                            tooltip: 'حذف الهدف',
                            icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.subTextColor),
                            onPressed: () => _deleteGoal(goal),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Text('${goal['title']}', style: const TextStyle(fontSize: 15, color: AppTheme.textColor)),
                  Slider(
                    value: progress,
                    divisions: 20,
                    label: '${(progress * 100).round()}%',
                    activeColor: AppTheme.primaryColor,
                    onChanged: (value) => setState(() => goal['progress'] = value),
                    onChangeEnd: (_) => _db?.saveGoals(_goals),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildQuranTrackerTab() {
    final finished = _quranPage >= DatabaseService.quranPages;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        color: AppTheme.surfaceColor,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const Icon(Icons.menu_book_rounded, size: 50, color: AppTheme.accentColor),
              const SizedBox(height: 10),
              const Text('متتبع الورد اليومي والقرآن الكريم', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textColor), textAlign: TextAlign.center),
              const SizedBox(height: 15),
              Text('الصفحة الحالية: $_quranPage', style: const TextStyle(fontSize: 22, color: AppTheme.accentColor, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(
                finished
                    ? 'أتممت الختمة 🎉 بارك الله فيك'
                    : 'المتبقي لإتمام الختمة: ${DatabaseService.quranPages - _quranPage} صفحة',
                style: const TextStyle(color: AppTheme.subTextColor, fontSize: 13),
              ),
              const SizedBox(height: 15),
              LinearProgressIndicator(
                value: _quranPage / DatabaseService.quranPages,
                backgroundColor: AppTheme.surfaceColor,
                color: AppTheme.accentColor,
                minHeight: 10,
                borderRadius: BorderRadius.circular(5),
              ),
              const SizedBox(height: 15),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 12,
                runSpacing: 8,
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
                    onPressed: finished || _db == null ? null : () => _changeQuranPage(_quranPage + 1),
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text('تم قراءة صفحة (+1)', style: TextStyle(color: Colors.white)),
                  ),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: AppTheme.accentColor)),
                    onPressed: _db == null ? null : _showSetQuranPageDialog,
                    icon: const Icon(Icons.edit_rounded, color: AppTheme.accentColor, size: 18),
                    label: const Text('تحديد الصفحة', style: TextStyle(color: AppTheme.accentColor)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
