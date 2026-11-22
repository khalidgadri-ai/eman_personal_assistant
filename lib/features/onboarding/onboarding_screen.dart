import 'package:flutter/material.dart';
import '../../core/services/database_service.dart';
import '../../core/services/profile_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/page_dots.dart';
import '../../l10n/l10n.dart';

/// اهتمامات جاهزة للاختيار؛ لا تتضمن أي معلومة عن شخص بعينه. تُحفظ في الملف الشخصي بهذا
/// النص العربي نفسه (معرّف ثابت، ويدخل تعليمات المساعد العربية)، وتُعرض بلغة التطبيق
/// عبر [interestLabel].
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

/// اسم الاهتمام بلغة التطبيق. اهتمام غير معروف (نسخة قديمة) يظهر كما حُفظ.
String interestLabel(AppLocalizations l10n, String stored) {
  return switch (stored) {
    'الصحة واللياقة' => l10n.interestHealth,
    'التنمية الذاتية' => l10n.interestGrowth,
    'القراءة' => l10n.interestReading,
    'العبادة والروحانيات' => l10n.interestFaith,
    'الميزانية والادخار' => l10n.interestBudget,
    'المطبخ والوصفات' => l10n.interestKitchen,
    'تنظيم المنزل' => l10n.interestHome,
    'تعلّم مهارات جديدة' => l10n.interestSkills,
    'العمل والإنتاجية' => l10n.interestWork,
    'الأسرة' => l10n.interestFamily,
    _ => stored,
  };
}

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
        _error = context.l10n.onboardingSaveFailed;
      });
      return;
    }
    if (!mounted) return;
    widget.onFinished();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.isEditing ? AppBar(title: Text(context.l10n.profileEdit)) : null,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
          child: Column(
            children: [
              PageDots(page: _page, count: 2),
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
    );
  }

  Widget _buildNamePage() {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        const Icon(Icons.auto_awesome_rounded, size: 56, color: AppTheme.accentColor),
        const SizedBox(height: 16),
        Text(
          widget.isEditing ? l10n.onboardingNameQuestion : l10n.onboardingWelcome,
          style: const TextStyle(color: AppTheme.textColor, fontSize: 26, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.onboardingIntro,
          style: const TextStyle(color: AppTheme.subTextColor, fontSize: 14, height: 1.7),
        ),
        const SizedBox(height: 28),
        TextField(
          key: const ValueKey('onboarding_name'),
          controller: _nameController,
          maxLength: UserProfile.maxNameLength,
          textInputAction: TextInputAction.done,
          style: const TextStyle(color: AppTheme.textColor, fontSize: 18),
          decoration: InputDecoration(labelText: l10n.onboardingNameLabel, counterText: ''),
        ),
      ],
    );
  }

  Widget _buildInterestsPage() {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.onboardingInterestsTitle,
          style: const TextStyle(color: AppTheme.textColor, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.onboardingInterestsHint,
          style: const TextStyle(color: AppTheme.subTextColor, fontSize: 13),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final option in kInterestOptions)
              FilterChip(
                label: Text(interestLabel(l10n, option)),
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
        Text(
          l10n.onboardingGoalsTitle,
          style: const TextStyle(color: AppTheme.textColor, fontSize: 16, fontWeight: FontWeight.w600),
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
                decoration: InputDecoration(
                  labelText: l10n.onboardingGoalLabel,
                  hintText: l10n.onboardingGoalHint,
                  counterText: '',
                ),
                onSubmitted: (_) => _addGoal(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              tooltip: l10n.onboardingAddGoal,
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
                  deleteButtonTooltipMessage: l10n.onboardingRemoveGoal,
                  onDeleted: () => setState(() => _goals.remove(goal)),
                ),
            ],
          ),
        ],
        const SizedBox(height: 16),
        Text(
          l10n.onboardingPrivacy,
          style: const TextStyle(color: AppTheme.subTextColor, fontSize: 12, height: 1.7),
        ),
      ],
    );
  }

  Widget _buildButtons() {
    final l10n = context.l10n;
    final Widget leading;
    if (_page == 1) {
      leading = TextButton(
        onPressed: _saving ? null : () => setState(() => _page = 0),
        child: Text(l10n.back, style: const TextStyle(color: AppTheme.subTextColor)),
      );
    } else if (widget.isEditing) {
      leading = TextButton(
        onPressed: _saving ? null : () => Navigator.of(context).pop(),
        child: Text(l10n.cancel, style: const TextStyle(color: AppTheme.subTextColor)),
      );
    } else {
      leading = TextButton(
        onPressed: _saving ? null : () => _finish(skip: true),
        child: Text(l10n.skip, style: const TextStyle(color: AppTheme.subTextColor)),
      );
    }

    final lastLabel = widget.isEditing ? l10n.save : l10n.start;
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
            _page == 0 ? l10n.next : lastLabel,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ],
    );
  }
}

