import 'dart:async';

import 'package:flutter/material.dart';
import '../../core/app_events.dart';
import '../../core/services/database_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/arabic_numbers.dart';
import '../../core/utils/ids.dart';
import '../../core/widgets/ai_provider_screen.dart';
import '../../core/widgets/entry_dialog.dart';
import '../../core/widgets/undo_snackbar.dart';
import '../reminders/reminder_notice.dart';
import '../../l10n/l10n.dart';
import '../settings/settings_button.dart';

/// تصنيفات المهام وأنواع الأهداف تُحفظ بهذا النص العربي (معرّفات ثابتة في بيانات المستخدم)،
/// وتُعرض بلغة التطبيق عبر [taskCategoryLabel] و[goalTypeLabel].
const List<String> _taskCategories = ['شخصي', 'المنزل', 'العمل', 'العائلة'];
const List<String> _goalTypes = ['هدف عام', 'هدف سنوي', 'هدف شهري', 'هدف أسبوعي'];

String taskCategoryLabel(AppLocalizations l10n, String stored) => switch (stored) {
      'شخصي' => l10n.catPersonal,
      'المنزل' => l10n.catHome,
      'العمل' => l10n.catWork,
      'العائلة' => l10n.catFamily,
      _ => stored,
    };

String goalTypeLabel(AppLocalizations l10n, String stored) => switch (stored) {
      'هدف عام' => l10n.goalTypeGeneral,
      'هدف سنوي' => l10n.goalTypeYearly,
      'هدف شهري' => l10n.goalTypeMonthly,
      'هدف أسبوعي' => l10n.goalTypeWeekly,
      _ => stored,
    };

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
    AppEvents.tasksChanged.addListener(_loadData);
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
    final l10n = context.l10n;
    final values = await showEntryDialog(
      context,
      title: l10n.taskAddTitle,
      fields: [
        EntryField(key: 'title', label: l10n.taskField, hint: l10n.taskHint, required: true),
        EntryField(
          key: 'category',
          label: l10n.categoryField,
          options: _taskCategories,
          optionLabel: (c) => taskCategoryLabel(l10n, c),
        ),
        EntryField(key: 'reminder', label: l10n.reminderField, isTime: true),
      ],
    );
    if (values == null) return;
    _addNewTask(values['title']!, values['category']!, reminder: values['reminder']!);
  }

  Future<void> _editTask(Map<String, dynamic> task) async {
    final l10n = context.l10n;
    final category = '${task['category'] ?? _taskCategories.first}';
    final values = await showEntryDialog(
      context,
      title: l10n.taskEditTitle,
      confirmLabel: l10n.save,
      fields: [
        EntryField(key: 'title', label: l10n.taskField, required: true, initial: '${task['title'] ?? ''}'),
        EntryField(
          key: 'category',
          label: l10n.categoryField,
          options: _taskCategories.contains(category) ? _taskCategories : [..._taskCategories, category],
          initial: category,
          optionLabel: (c) => taskCategoryLabel(l10n, c),
        ),
        EntryField(key: 'reminder', label: l10n.reminderField, isTime: true, initial: '${task['reminder'] ?? ''}'),
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
    showUndoSnackBar(context, context.l10n.taskDeleted('${task['title']}'), () async {
      if (!mounted) return;
      setState(() => _dailyTasks.insert(index.clamp(0, _dailyTasks.length), task));
      await _db?.saveDailyTasks(_dailyTasks);
      _syncReminders();
    });
  }

  // --- الأهداف ---

  Future<void> _showAddGoalDialog() async {
    final l10n = context.l10n;
    final values = await showEntryDialog(
      context,
      title: l10n.goalAdd,
      fields: [
        EntryField(key: 'title', label: l10n.goalField, hint: l10n.onboardingGoalHint, required: true),
        EntryField(
          key: 'type',
          label: l10n.goalTypeField,
          options: _goalTypes,
          optionLabel: (t) => goalTypeLabel(l10n, t),
        ),
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
    final l10n = context.l10n;
    final type = '${goal['type'] ?? _goalTypes.first}';
    final values = await showEntryDialog(
      context,
      title: l10n.goalEditTitle,
      confirmLabel: l10n.save,
      fields: [
        EntryField(key: 'title', label: l10n.goalField, required: true, initial: '${goal['title'] ?? ''}'),
        EntryField(
          key: 'type',
          label: l10n.goalTypeField,
          options: _goalTypes.contains(type) ? _goalTypes : [..._goalTypes, type],
          initial: type,
          optionLabel: (t) => goalTypeLabel(l10n, t),
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
    showUndoSnackBar(context, context.l10n.goalDeleted('${goal['title']}'), () async {
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
    final l10n = context.l10n;
    final values = await showEntryDialog(
      context,
      title: l10n.wirdSetTitle,
      confirmLabel: l10n.save,
      fields: [
        EntryField(
          key: 'page',
          label: l10n.wirdPageField(DatabaseService.quranPages),
          keyboardType: TextInputType.number,
          maxLength: 3,
          required: true,
          initial: '$_quranPage',
          validator: (value) {
            final page = parseInteger(value);
            if (page == null || page < 0 || page > DatabaseService.quranPages) {
              return l10n.wirdPageError(DatabaseService.quranPages);
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
    final l10n = context.l10n;
    final noteController = TextEditingController();
    bool isAnalyzing = false;
    String aiResult = '';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              backgroundColor: AppTheme.cardColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: [
                  const Icon(Icons.mic_rounded, color: AppTheme.accentColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(l10n.voiceTitle, style: const TextStyle(color: AppTheme.textColor, fontSize: 16)),
                  ),
                ],
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.voicePrompt,
                        style: const TextStyle(color: AppTheme.subTextColor, fontSize: 13),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: noteController,
                        maxLines: 4,
                        maxLength: 2000,
                        style: const TextStyle(color: AppTheme.textColor, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: l10n.voiceHint,
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
                              Row(
                                children: [
                                  const Icon(Icons.auto_awesome, color: AppTheme.accentColor, size: 16),
                                  const SizedBox(width: 6),
                                  Text(l10n.voiceExtracted, style: const TextStyle(color: AppTheme.accentColor, fontWeight: FontWeight.bold, fontSize: 13)),
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
                  child: Text(l10n.close, style: const TextStyle(color: AppTheme.subTextColor)),
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
                    label: Text(isAnalyzing ? l10n.voiceExtracting : l10n.voiceExtract, style: const TextStyle(color: Colors.white)),
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
                          content: Text(l10n.voiceImported(addedCount)),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    icon: const Icon(Icons.playlist_add_check_rounded, color: Colors.white, size: 18),
                    label: Text(l10n.voiceImport, style: const TextStyle(color: Colors.white)),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    AppEvents.tasksChanged.removeListener(_loadData);
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
          tooltip: context.l10n.addTask,
          backgroundColor: AppTheme.primaryColor,
          onPressed: _showAddTaskDialog,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      1 => FloatingActionButton(
          heroTag: 'add_goal_fab',
          tooltip: context.l10n.goalAdd,
          backgroundColor: AppTheme.primaryColor,
          onPressed: _showAddGoalDialog,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      _ => null,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.tasksTitle),
        actions: [
          // ✅ زر المذكرة الصوتية في الـ AppBar
          IconButton(
            tooltip: l10n.voiceImportTooltip,
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
          tabs: [
            Tab(text: l10n.tabDailyTasks),
            Tab(text: l10n.tabGoals),
            Tab(text: l10n.tabWird),
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
    final l10n = context.l10n;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      children: [
        Text(
          l10n.tasksHeader,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textColor),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.tasksVoiceTip,
          style: const TextStyle(fontSize: 12, color: AppTheme.subTextColor),
        ),
        const SizedBox(height: 12),
        if (_dailyTasks.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Text(l10n.tasksEmpty, style: const TextStyle(color: AppTheme.subTextColor), textAlign: TextAlign.center),
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
                    taskCategoryLabel(l10n, '${task['category']}'),
                    style: const TextStyle(color: AppTheme.accentColor, fontSize: 12),
                  ),
                ),
                IconButton(
                  tooltip: task['pinned'] == true ? l10n.taskUnpin : l10n.taskPin,
                  icon: Icon(
                    task['pinned'] == true ? Icons.push_pin_rounded : Icons.push_pin_outlined,
                    color: AppTheme.subTextColor,
                  ),
                  onPressed: () => _toggleTaskPin(task),
                ),
                IconButton(
                  tooltip: l10n.taskDelete,
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
    final l10n = context.l10n;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      children: [
        Text(
          l10n.goalsHeader,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textColor),
        ),
        const SizedBox(height: 12),
        if (_goals.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Text(l10n.goalsEmpty, style: const TextStyle(color: AppTheme.subTextColor), textAlign: TextAlign.center),
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
                      Text(goalTypeLabel(l10n, '${goal['type']}'), style: const TextStyle(color: AppTheme.accentColor, fontWeight: FontWeight.bold)),
                      Row(
                        children: [
                          Text('${(progress * 100).round()}%', style: const TextStyle(color: AppTheme.textColor)),
                          IconButton(
                            tooltip: l10n.goalEditTitle,
                            icon: const Icon(Icons.edit_rounded, color: AppTheme.subTextColor),
                            onPressed: () => _editGoal(goal),
                          ),
                          IconButton(
                            tooltip: goal['pinned'] == true ? l10n.goalUnpin : l10n.goalPin,
                            icon: Icon(
                              goal['pinned'] == true ? Icons.push_pin_rounded : Icons.push_pin_outlined,
                              color: AppTheme.subTextColor,
                            ),
                            onPressed: () => _toggleGoalPin(goal),
                          ),
                          IconButton(
                            tooltip: l10n.goalDelete,
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
    final l10n = context.l10n;
    final finished = _quranPage >= DatabaseService.quranPages;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      child: Card(
        color: AppTheme.surfaceColor,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const Icon(Icons.menu_book_rounded, size: 50, color: AppTheme.accentColor),
              const SizedBox(height: 10),
              Text(l10n.wirdTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textColor), textAlign: TextAlign.center),
              const SizedBox(height: 15),
              Text(l10n.wirdCurrentPage(_quranPage), style: const TextStyle(fontSize: 22, color: AppTheme.accentColor, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(
                finished ? l10n.wirdFinished : l10n.wirdRemaining(DatabaseService.quranPages - _quranPage),
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
                    label: Text(l10n.wirdReadOne, style: const TextStyle(color: Colors.white)),
                  ),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: AppTheme.accentColor)),
                    onPressed: _db == null ? null : _showSetQuranPageDialog,
                    icon: const Icon(Icons.edit_rounded, color: AppTheme.accentColor, size: 18),
                    label: Text(l10n.wirdSetPage, style: const TextStyle(color: AppTheme.accentColor)),
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
