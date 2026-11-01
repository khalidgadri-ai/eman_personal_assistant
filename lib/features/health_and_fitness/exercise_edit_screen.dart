import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'health_service.dart';
import 'image_source_sheet.dart';
import 'models/exercise.dart';

typedef ExerciseImagePicker = Future<Uint8List?> Function(BuildContext context);

/// إضافة تمرين أو تعديله: الاسم والعضلات والمجموعات والتكرار والخطوات والملاحظات والصورة.
/// [draft] و[image] يملآن النموذج مسبقًا من تحليل صورة بالذكاء الاصطناعي؛ المستخدم يراجع
/// ويعدّل ثم يضغط حفظ، ولا يُحفظ شيء قبل ذلك. ترجّع true عند الحفظ.
class ExerciseEditScreen extends StatefulWidget {
  const ExerciseEditScreen({
    super.key,
    required this.health,
    this.exercise,
    this.draft,
    this.image,
    this.pickImage = pickExerciseImage,
  });

  final HealthService health;
  final Exercise? exercise;
  final ExerciseDraft? draft;
  final Uint8List? image;
  final ExerciseImagePicker pickImage;

  @override
  State<ExerciseEditScreen> createState() => _ExerciseEditScreenState();
}

class _ExerciseEditScreenState extends State<ExerciseEditScreen> {
  late final TextEditingController _name;
  late final TextEditingController _muscles;
  late final TextEditingController _reps;
  late final TextEditingController _notes;
  final List<TextEditingController> _steps = [];
  late int _sets;
  Uint8List? _image;
  bool _imageChanged = false;
  bool _imageRemoved = false;
  String? _nameError;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final e = widget.exercise;
    final d = widget.draft;
    _name = TextEditingController(text: e?.name ?? d?.name ?? '');
    _muscles = TextEditingController(text: e?.muscles ?? d?.muscles ?? '');
    _reps = TextEditingController(text: e?.reps ?? d?.reps ?? Exercise.defaultReps);
    _notes = TextEditingController(text: e?.notes ?? d?.notes ?? '');
    _sets = e?.sets ?? d?.sets ?? Exercise.defaultSets;
    for (final s in e?.steps ?? d?.steps ?? const <String>[]) {
      _steps.add(TextEditingController(text: s));
    }
    if (e != null && e.hasImage) {
      _image = widget.health.exerciseImage(e.id);
    } else {
      _image = widget.image;
      // صورة جاءت من تحليل جديد تُحفظ مع التمرين الجديد.
      _imageChanged = widget.image != null;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _muscles.dispose();
    _reps.dispose();
    _notes.dispose();
    for (final c in _steps) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _changeImage() async {
    final picked = await widget.pickImage(context);
    if (picked == null || !mounted) return;
    setState(() {
      _image = picked;
      _imageChanged = true;
      _imageRemoved = false;
    });
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    if (name.isEmpty) {
      setState(() => _nameError = 'هذا الحقل مطلوب');
      return;
    }
    setState(() => _saving = true);
    final existing = widget.exercise;
    final steps = _steps.map((c) => c.text.trim()).where((s) => s.isNotEmpty).toList();
    final fields = Exercise(
      id: existing?.id ?? '',
      name: name,
      muscles: _muscles.text,
      steps: steps,
      sets: _sets,
      reps: _reps.text,
      notes: _notes.text,
      pinned: existing?.pinned ?? false,
      createdAt: existing?.createdAt ?? '',
    );
    if (existing == null) {
      await widget.health.addExercise(fields, image: _imageChanged ? _image : null);
    } else {
      await widget.health.updateExercise(
        fields,
        image: _imageChanged && !_imageRemoved ? _image : null,
        removeImage: _imageRemoved,
      );
    }
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.exercise == null ? 'إضافة تمرين' : 'تعديل التمرين'),
          actions: [
            TextButton(
              onPressed: _saving ? null : _save,
              child: const Text('حفظ', style: TextStyle(color: AppTheme.accentColor, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _imageBlock(),
            const SizedBox(height: 16),
            TextField(
              controller: _name,
              maxLength: Exercise.maxNameLength,
              style: const TextStyle(color: AppTheme.textColor),
              decoration: InputDecoration(labelText: 'اسم التمرين', errorText: _nameError, counterText: ''),
              onChanged: (_) {
                if (_nameError != null) setState(() => _nameError = null);
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _muscles,
              maxLength: Exercise.maxMusclesLength,
              style: const TextStyle(color: AppTheme.textColor),
              decoration: const InputDecoration(labelText: 'العضلات المستهدفة', counterText: ''),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('المجموعات', style: TextStyle(color: AppTheme.textColor)),
                IconButton(
                  tooltip: 'تقليل المجموعات',
                  icon: const Icon(Icons.remove_circle_outline_rounded),
                  onPressed: _sets > 1 ? () => setState(() => _sets--) : null,
                ),
                Text('$_sets', style: const TextStyle(color: AppTheme.textColor, fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(
                  tooltip: 'زيادة المجموعات',
                  icon: const Icon(Icons.add_circle_outline_rounded),
                  onPressed: _sets < Exercise.maxSets ? () => setState(() => _sets++) : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _reps,
                    maxLength: Exercise.maxRepsLength,
                    style: const TextStyle(color: AppTheme.textColor),
                    decoration: const InputDecoration(labelText: 'التكرار', hintText: '10 أو 8-12', counterText: ''),
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            const Text('خطوات الأداء', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textColor)),
            const SizedBox(height: 8),
            for (var i = 0; i < _steps.length; i++) _stepRow(i),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton.icon(
                onPressed: _steps.length >= Exercise.maxSteps
                    ? null
                    : () => setState(() => _steps.add(TextEditingController())),
                icon: const Icon(Icons.add_rounded),
                label: const Text('إضافة خطوة'),
              ),
            ),
            const Divider(height: 32),
            TextField(
              controller: _notes,
              maxLength: Exercise.maxNotesLength,
              maxLines: 4,
              style: const TextStyle(color: AppTheme.textColor),
              decoration: const InputDecoration(labelText: 'ملاحظات (اختياري)', counterText: ''),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imageBlock() {
    final image = _imageRemoved ? null : _image;
    return Column(
      children: [
        if (image != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.memory(image, height: 200, width: double.infinity, fit: BoxFit.cover, gaplessPlayback: true),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton.icon(
              onPressed: _changeImage,
              icon: const Icon(Icons.add_a_photo_rounded),
              label: Text(image == null ? 'إضافة صورة' : 'تغيير الصورة'),
            ),
            if (image != null)
              TextButton.icon(
                onPressed: () => setState(() {
                  _imageRemoved = true;
                  _imageChanged = widget.exercise == null ? false : _imageChanged;
                }),
                icon: const Icon(Icons.hide_image_rounded),
                label: const Text('إزالة الصورة'),
              ),
          ],
        ),
      ],
    );
  }

  Widget _stepRow(int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 14, left: 8),
            child: Text('${index + 1}.', style: const TextStyle(color: AppTheme.accentColor, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: TextField(
              controller: _steps[index],
              maxLength: Exercise.maxStepLength,
              maxLines: null,
              style: const TextStyle(color: AppTheme.textColor),
              decoration: InputDecoration(labelText: 'الخطوة ${index + 1}', counterText: ''),
            ),
          ),
          IconButton(
            tooltip: 'حذف الخطوة',
            icon: const Icon(Icons.close_rounded, color: AppTheme.subTextColor),
            onPressed: () => setState(() {
              _steps.removeAt(index).dispose();
            }),
          ),
        ],
      ),
    );
  }
}
