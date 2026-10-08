import 'package:flutter/material.dart';
import '../../core/services/database_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/ai_key_setup_screen.dart';

class GoalsTasksScreen extends StatefulWidget {
  const GoalsTasksScreen({super.key});

  @override
  State<GoalsTasksScreen> createState() => _GoalsTasksScreenState();
}

class _GoalsTasksScreenState extends State<GoalsTasksScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DatabaseService? _db;

  List<Map<String, dynamic>> _dailyTasks = [];
  int _quranPage = 142;

  final List<Map<String, dynamic>> _goals = [
    {'title': '🎯 هدف العام: ختمة القرآن وتعلّم لغة جديدة', 'progress': 0.65, 'type': 'هدف سنوي'},
    {'title': '📅 مرحلة هذا الشهر: إنجاز 4 أجزاء من القرآن والقراءة اليومية', 'progress': 0.80, 'type': 'هدف شهري'},
    {'title': '📌 خطة الأسبوع: قراءة 30 صفحة + 4 حصص لياقة', 'progress': 0.50, 'type': 'خطط الأسبوع'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    _db = await DatabaseService.getInstance();
    setState(() {
      _dailyTasks = _db!.getDailyTasks();
      _quranPage = _db!.getQuranPage();
    });
  }

  void _addNewTask(String title, String category) {
    if (title.trim().isEmpty) return;
    setState(() {
      _dailyTasks.add({'title': title.trim(), 'category': category, 'done': false});
    });
    _db?.saveDailyTasks(_dailyTasks);
  }

  void _showAddTaskDialog() {
    final titleController = TextEditingController();
    String category = 'شخصي';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              backgroundColor: AppTheme.cardColor,
              title: const Text('إضافة مهمة جديدة', style: TextStyle(color: AppTheme.textColor)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    style: const TextStyle(color: AppTheme.textColor),
                    decoration: const InputDecoration(
                      hintText: 'اكتب نص المهمة...',
                      hintStyle: TextStyle(color: AppTheme.subTextColor),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButton<String>(
                    value: category,
                    dropdownColor: AppTheme.cardColor,
                    isExpanded: true,
                    items: ['شخصي', 'المنزل', 'الأطفال'].map((cat) {
                      return DropdownMenuItem(
                        value: cat,
                        child: Text(cat, style: const TextStyle(color: AppTheme.textColor)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setModalState(() {
                          category = val;
                        });
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('إلغاء', style: TextStyle(color: AppTheme.subTextColor)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
                  onPressed: () {
                    _addNewTask(titleController.text, category);
                    Navigator.pop(context);
                  },
                  child: const Text('إضافة', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
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
            return AlertDialog(
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
                        'اكتبي نص المذكرة الصوتية أو ما تريدين تحويله لمهام:',
                        style: TextStyle(color: AppTheme.subTextColor, fontSize: 13),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: noteController,
                        maxLines: 4,
                        style: const TextStyle(color: AppTheme.textColor, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'مثال: أريد اليوم أن أراجع دروس الأطفال وأذهب للسوق لشراء الخضار والفواكه وأيضاً أنظم الخزانة...',
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
                            final gemini = await requireGeminiService(context);
                            if (gemini == null || !context.mounted) return;
                            setModalState(() => isAnalyzing = true);
                            final result = await gemini.parseVoiceNoteToTasks(text);
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
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primaryColor,
        onPressed: _showAddTaskDialog,
        child: const Icon(Icons.add, color: Colors.white),
      ),
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
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'مركز إدارة المهام المقسمة',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textColor),
        ),
        const SizedBox(height: 4),
        const Text(
          'اضغطي على أيقونة الميكروفون 🎙️ في الأعلى لاستيراد مهام من مذكرتك الصوتية',
          style: TextStyle(fontSize: 12, color: AppTheme.subTextColor),
        ),
        const SizedBox(height: 12),
        if (_dailyTasks.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text('لا توجد مهام بعد. اضغطي + لإضافة مهمة أو استخدمي المذكرة الصوتية.', style: TextStyle(color: AppTheme.subTextColor), textAlign: TextAlign.center),
            ),
          ),
        ..._dailyTasks.map((task) => Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            leading: Checkbox(
              value: task['done'],
              activeColor: AppTheme.primaryColor,
              onChanged: (val) {
                setState(() {
                  task['done'] = val;
                });
                _db?.saveDailyTasks(_dailyTasks);
              },
            ),
            title: Text(
              task['title'],
              style: TextStyle(
                color: AppTheme.textColor,
                decoration: task['done'] ? TextDecoration.lineThrough : null,
              ),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                task['category'],
                style: const TextStyle(color: AppTheme.accentColor, fontSize: 12),
              ),
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildGoalsCascadeTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'محرك الأهداف الهرمية (السنوية ⬅️ الشهرية ⬅️ الأسبوعية)',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textColor),
        ),
        const SizedBox(height: 12),
        ..._goals.map((goal) => Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(goal['type'], style: const TextStyle(color: AppTheme.accentColor, fontWeight: FontWeight.bold)),
                    Text('${(goal['progress'] * 100).toInt()}%', style: const TextStyle(color: AppTheme.textColor)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(goal['title'], style: const TextStyle(fontSize: 15, color: AppTheme.textColor)),
                const SizedBox(height: 10),
                LinearProgressIndicator(
                  value: goal['progress'],
                  backgroundColor: AppTheme.surfaceColor,
                  color: AppTheme.primaryColor,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildQuranTrackerTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            color: AppTheme.surfaceColor,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  const Icon(Icons.menu_book_rounded, size: 50, color: AppTheme.accentColor),
                  const SizedBox(height: 10),
                  const Text('متتبع الورد اليومي والقرآن الكريم', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textColor)),
                  const SizedBox(height: 15),
                  Text('الصفحة الحالية: $_quranPage', style: const TextStyle(fontSize: 22, color: AppTheme.accentColor, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(
                    'المتبقي لإتمام الختمة: ${604 - _quranPage} صفحة',
                    style: const TextStyle(color: AppTheme.subTextColor, fontSize: 13),
                  ),
                  const SizedBox(height: 15),
                  LinearProgressIndicator(
                    value: _quranPage / 604,
                    backgroundColor: AppTheme.surfaceColor,
                    color: AppTheme.accentColor,
                    minHeight: 10,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
                        onPressed: () {
                          setState(() {
                            _quranPage += 1;
                          });
                          _db?.saveQuranPage(_quranPage);
                        },
                        icon: const Icon(Icons.add, color: Colors.white),
                        label: const Text('تم قراءة صفحة (+1)', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
