import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/services/gemini_service.dart';
import '../../core/theme/app_theme.dart';

class HealthFitnessScreen extends StatefulWidget {
  const HealthFitnessScreen({super.key});

  @override
  State<HealthFitnessScreen> createState() => _HealthFitnessScreenState();
}

class _HealthFitnessScreenState extends State<HealthFitnessScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final GeminiService _geminiService = GeminiService();
  final ImagePicker _imagePicker = ImagePicker();
  bool _isAnalyzingExercise = false;
  bool _isAnalyzingMed = false;

  final List<Map<String, dynamic>> _medications = [
    {'name': 'فيتامين د3 (5000 وحدة)', 'time': '09:00 صباحاً', 'taken': true},
    {'name': 'أوميغا 3 (زيت السمك)', 'time': '02:00 مساءً', 'taken': false},
    {'name': 'كولاجين للبشرة والشعر', 'time': '09:00 مساءً', 'taken': false},
  ];

  final List<Map<String, String>> _beautyRoutine = [
    {'item': 'سيروم فيتامين سي', 'time': 'صباحاً', 'step': 'تنظيف الوجه ثم تطبيق السيروم'},
    {'item': 'واقي الشمس Spf 50', 'time': 'صباحاً', 'step': 'تطبيق قبل الخروج بـ 15 دقيقة'},
    {'item': 'مرطب البشرة الليلي + ريتينول', 'time': 'مساءً', 'step': 'ترطيب عميق قبل النوم'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// ✅ يفتح الكاميرا أو المعرض ويرسل الصورة لـ Gemini لتحليل التمرين
  Future<void> _analyzeExerciseImage() async {
    final source = await _showImageSourceDialog();
    if (source == null) return;

    final XFile? pickedFile = await _imagePicker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1024,
    );
    if (pickedFile == null) return;

    setState(() => _isAnalyzingExercise = true);

    final Uint8List imageBytes = await pickedFile.readAsBytes();
    final result = await _geminiService.analyzeExerciseImage(imageBytes);

    setState(() => _isAnalyzingExercise = false);

    if (mounted) _showResultDialog('🏋️‍♀️ تحليل التمرين والعضلات', result);
  }

  /// ✅ يفتح الكاميرا أو المعرض ويرسل صورة الدواء لـ Gemini للتحليل
  Future<void> _analyzeMedicationLabel() async {
    final source = await _showImageSourceDialog();
    if (source == null) return;

    final XFile? pickedFile = await _imagePicker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1024,
    );
    if (pickedFile == null) return;

    setState(() => _isAnalyzingMed = true);

    final Uint8List imageBytes = await pickedFile.readAsBytes();
    final result = await _geminiService.analyzeMedicationLabel(imageBytes);

    setState(() => _isAnalyzingMed = false);

    if (mounted) _showResultDialog('💊 تحليل علبة الدواء', result);
  }

  /// يعرض نافذة اختيار مصدر الصورة (كاميرا أو معرض)
  Future<ImageSource?> _showImageSourceDialog() async {
    return showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: AppTheme.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('اختيار مصدر الصورة', style: TextStyle(color: AppTheme.textColor, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _sourceOption(Icons.camera_alt_rounded, 'الكاميرا', () => Navigator.pop(context, ImageSource.camera)),
                _sourceOption(Icons.photo_library_rounded, 'المعرض', () => Navigator.pop(context, ImageSource.gallery)),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _sourceOption(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.2),
            child: Icon(icon, color: AppTheme.accentColor, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: AppTheme.textColor)),
        ],
      ),
    );
  }

  /// يعرض نتيجة التحليل في نافذة قابلة للتمرير
  void _showResultDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title, style: const TextStyle(color: AppTheme.textColor, fontSize: 17)),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Text(content, style: const TextStyle(color: AppTheme.subTextColor, fontSize: 14, height: 1.6)),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🏋️‍♀️ الصحة واللياقة والعناية'),
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

  Widget _buildFitnessTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          color: AppTheme.surfaceColor,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Icon(Icons.fitness_center, size: 48, color: AppTheme.accentColor),
                const SizedBox(height: 10),
                const Text(
                  'تمارين اليوم: عضلات الجزء العلوي والظهر',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textColor),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                // ✅ زر تحليل التمرين مربوط الآن بالكاميرا وGemini
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
        const Text('بطاقات التمارين بالجولات والتكرارات', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textColor)),
        const SizedBox(height: 8),
        _buildExerciseCard('تمرين سحب البار للظهر (Lat Pulldown)', '4 جولات × 12 تكرار', 'التركيز على انقباض عضلات الظهر العلوي مع الثبات لمدة ثانية'),
        _buildExerciseCard('تمرين الأكتاف بالدنابل (Dumbbell Press)', '3 جولات × 10 تكرارات', 'التحكم في الهبوط والحفاظ على استقامة الظهر'),
      ],
    );
  }

  Widget _buildExerciseCard(String title, String sets, String note) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textColor)),
        subtitle: Text('$sets\n$note', style: const TextStyle(color: AppTheme.subTextColor)),
        isThreeLine: true,
        trailing: const Icon(Icons.check_circle_outline, color: AppTheme.accentColor),
      ),
    );
  }

  Widget _buildMedsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ✅ زر تحليل علبة الدواء بالكاميرا
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
                  'التقطي صورة لعلبة الدواء أو المكمل الغذائي لمعرفة الجرعة والتحذيرات',
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
        ..._medications.map((med) => Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            leading: Icon(
              Icons.medication_liquid_rounded,
              color: med['taken'] ? Colors.green : Colors.orangeAccent,
            ),
            title: Text(med['name'], style: const TextStyle(color: AppTheme.textColor, fontWeight: FontWeight.bold)),
            subtitle: Text(med['time'], style: const TextStyle(color: AppTheme.subTextColor)),
            trailing: Switch(
              value: med['taken'],
              activeThumbColor: AppTheme.primaryColor,
              onChanged: (val) {
                setState(() {
                  med['taken'] = val;
                });
              },
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildBeautyTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('سجل منتجات الروتين اليومي للبشرة والشعر', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textColor)),
        const SizedBox(height: 12),
        ..._beautyRoutine.map((item) => Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            leading: const Icon(Icons.spa_rounded, color: AppTheme.accentColor),
            title: Text(item['item']!, style: const TextStyle(color: AppTheme.textColor, fontWeight: FontWeight.bold)),
            subtitle: Text('${item['time']} - ${item['step']}', style: const TextStyle(color: AppTheme.subTextColor)),
          ),
        )),
      ],
    );
  }
}
