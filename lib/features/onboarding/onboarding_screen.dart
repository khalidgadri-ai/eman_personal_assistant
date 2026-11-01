import 'package:flutter/material.dart';
import '../../core/services/database_service.dart';
import '../../core/services/profile_service.dart';
import '../../core/theme/app_theme.dart';

/// اهتمامات جاهزة للاختيار؛ لا تتضمن أي معلومة عن شخص بعينه.
const List<String> kInterestOptions = [
  'الصحة واللياقة',
  'التنمية الذاتية',
  'القراءة',
  'العبادة والروحانيات',
  'الميزانية والادخار',
  'المطبخ والوصفات',
  'تنظيم المنزل',
  'تعلّم مهارات جديدة',
  'العمل والإنتاجية',
  'الأسرة',
];

/// شاشة الترحيب عند أول تشغيل: الاسم، ثم الاهتمامات والأهداف، ثم تُحفظ مشفّرة على الجهاز.
/// مع [initial] تصبح شاشة تعديل من الإعدادات (بدون "تخطي").
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.onFinished, this.initial});

  final VoidCallback onFinished;
  final UserProfile? initial;

  bool get isEditing => initial != null;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _goalController = TextEditingController();
  final Set<String> _interests = {};
  final List<String> _goals = [];
  int _page = 0;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    if (initial != null) {
      _nameController.text = initial.name;
      _interests.addAll(initial.interests);
      _goals.addAll(initial.goals);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _goalController.dispose();
    super.dispose();
  }

  void _addGoal() {
    final goal = _goalController.text.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (goal.isEmpty || _goals.contains(goal) || _goals.length >= UserProfile.maxGoals) return;
    setState(() {
      _goals.add(goal);
      _goalController.clear();
    });
  }

  Future<void> _finish({bool skip = false}) async {
    if (_saving) return;
    // هدف كُتب ولم يُضغط +: لا نضيّعه.
    if (!skip) _addGoal();
    setState(() {
      _saving = true;
      _error = null;
    });
    final profile = skip
        ? const UserProfile()
        : UserProfile.sanitized(name: _nameController.text, interests: _interests, goals: _goals);
    try {
      final service = await ProfileService.getInstance();
      await service.save(profile);
      if (!widget.isEditing && profile.goals.isNotEmpty) {
        final db = await DatabaseService.getInstance();
        if (db.getGoals().isEmpty) {
          await db.saveGoals([
            for (final goal in profile.goals) {'title': goal, 'type': 'هدف عام', 'progress': 0.0},
          ]);
        }
      }
    } catch (e) {
      debugPrint('Onboarding save failed: ${e.runtimeType}');
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = 'تعذّر الحفظ على جهازك. حاول مرة أخرى.';
      });
      return;
    }
    if (!mounted) return;
    widget.onFinished();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: widget.isEditing ? AppBar(title: const Text('تعديل ملفي')) : null,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
            child: Column(
              children: [
                _PageDots(page: _page, count: 2),
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    child: _page == 0 ? _buildNamePage() : _buildInterestsPage(),
                  ),
                ),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(_error!, style: const TextStyle(color: Colors.redAccent)),
                  ),
                _buildButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNamePage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        const Icon(Icons.auto_awesome_rounded, size: 56, color: AppTheme.accentColor),
        const SizedBox(height: 16),
        Text(
          widget.isEditing ? 'ما اسمك؟' : 'أهلًا بك في إيمان',
          style: const TextStyle(color: AppTheme.textColor, fontSize: 26, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'مساعدك الشخصي للمهام والصحة والمطبخ والميزانية. كل ما تدخله يبقى على جهازك.',
          style: TextStyle(color: AppTheme.subTextColor, fontSize: 14, height: 1.7),
        ),
        const SizedBox(height: 28),
        TextField(
          key: const ValueKey('onboarding_name'),
          controller: _nameController,
          maxLength: UserProfile.maxNameLength,
          textInputAction: TextInputAction.done,
          style: const TextStyle(color: AppTheme.textColor, fontSize: 18),
          decoration: const InputDecoration(labelText: 'ما اسمك؟ (اختياري)', counterText: ''),
        ),
      ],
    );
  }

  Widget _buildInterestsPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ما الذي يهمّك؟',
          style: TextStyle(color: AppTheme.textColor, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        const Text(
          'اختر ما يناسبك، ويمكنك تغييره لاحقًا من الإعدادات.',
          style: TextStyle(color: AppTheme.subTextColor, fontSize: 13),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final option in kInterestOptions)
              FilterChip(
                label: Text(option),
                selected: _interests.contains(option),
                selectedColor: AppTheme.primaryColor,
                backgroundColor: AppTheme.cardColor,
                labelStyle: TextStyle(
                  color: _interests.contains(option) ? Colors.white : AppTheme.textColor,
                ),
                checkmarkColor: Colors.white,
                onSelected: (selected) => setState(() {
                  selected ? _interests.add(option) : _interests.remove(option);
                }),
              ),
          ],
        ),
        const SizedBox(height: 24),
        const Text(
          'أهدافك (اختياري)',
          style: TextStyle(color: AppTheme.textColor, fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                key: const ValueKey('onboarding_goal'),
                controller: _goalController,
                maxLength: UserProfile.maxItemLength,
                textInputAction: TextInputAction.done,
                style: const TextStyle(color: AppTheme.textColor),
                decoration: const InputDecoration(
                  labelText: 'اكتب هدفًا ثم اضغط +',
                  hintText: 'مثال: قراءة 20 صفحة يوميًا',
                  counterText: '',
                ),
                onSubmitted: (_) => _addGoal(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              tooltip: 'إضافة هدف',
              style: IconButton.styleFrom(backgroundColor: AppTheme.primaryColor),
              onPressed: _addGoal,
              icon: const Icon(Icons.add_rounded, color: Colors.white),
            ),
          ],
        ),
        if (_goals.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              for (final goal in _goals)
                InputChip(
                  label: Text(goal),
                  backgroundColor: AppTheme.cardColor,
                  labelStyle: const TextStyle(color: AppTheme.textColor),
                  deleteButtonTooltipMessage: 'حذف الهدف',
                  onDeleted: () => setState(() => _goals.remove(goal)),
                ),
            ],
          ),
        ],
        const SizedBox(height: 16),
        const Text(
          'تُحفظ هذه المعلومات مشفّرة على جهازك. وإن فعّلت المساعد الذكي بمفتاحك، '
          'تُرسل مع طلباته إلى مزوّد الذكاء الاصطناعي الذي تختاره لتخصيص الردود.',
          style: TextStyle(color: AppTheme.subTextColor, fontSize: 12, height: 1.7),
        ),
      ],
    );
  }

  Widget _buildButtons() {
    final Widget leading;
    if (_page == 1) {
      leading = TextButton(
        onPressed: _saving ? null : () => setState(() => _page = 0),
        child: const Text('رجوع', style: TextStyle(color: AppTheme.subTextColor)),
      );
    } else if (widget.isEditing) {
      leading = TextButton(
        onPressed: _saving ? null : () => Navigator.of(context).pop(),
        child: const Text('إلغاء', style: TextStyle(color: AppTheme.subTextColor)),
      );
    } else {
      leading = TextButton(
        onPressed: _saving ? null : () => _finish(skip: true),
        child: const Text('تخطي', style: TextStyle(color: AppTheme.subTextColor)),
      );
    }

    final lastLabel = widget.isEditing ? 'حفظ' : 'ابدأ';
    return Row(
      children: [
        leading,
        const Spacer(),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            minimumSize: const Size(120, 48),
          ),
          onPressed: _saving ? null : (_page == 0 ? () => setState(() => _page = 1) : _finish),
          child: Text(
            _page == 0 ? 'التالي' : lastLabel,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ],
    );
  }
}

class _PageDots extends StatelessWidget {
  const _PageDots({required this.page, required this.count});

  final int page;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < count; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: i == page ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: i == page ? AppTheme.accentColor : AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
      ],
    );
  }
}
