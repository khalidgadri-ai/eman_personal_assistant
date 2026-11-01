import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// حقل في نافذة الإدخال. إن وُجدت [options] يصبح الحقل قائمة منسدلة بدل حقل نص.
class EntryField {
  const EntryField({
    required this.key,
    required this.label,
    this.hint,
    this.required = false,
    this.keyboardType = TextInputType.text,
    this.maxLength = 120,
    this.maxLines = 1,
    this.options,
    this.initial,
    this.validator,
    this.isTime = false,
  });

  final String key;
  final String label;
  final String? hint;
  final bool required;
  final TextInputType keyboardType;
  final int maxLength;
  final int maxLines;
  final List<String>? options;
  final String? initial;

  /// يرجّع نص الخطأ أو null إذا كانت القيمة مقبولة. يُستدعى للقيم غير الفارغة بعد تنظيفها.
  final String? Function(String value)? validator;

  /// حقل وقت اختياري (تذكير): زر اختيار وقت وزر إزالة، وقيمته `HH:mm` أو فارغة. [initial] بنفس الصيغة.
  final bool isTime;
}

/// نافذة إدخال موحّدة لكل شاشات التطبيق. ترجّع القيم المنظّفة بحسب [EntryField.key]،
/// أو null عند الإلغاء.
Future<Map<String, String>?> showEntryDialog(
  BuildContext context, {
  required String title,
  required List<EntryField> fields,
  String confirmLabel = 'إضافة',
}) {
  return showDialog<Map<String, String>>(
    context: context,
    builder: (_) => _EntryDialog(title: title, fields: fields, confirmLabel: confirmLabel),
  );
}

class _EntryDialog extends StatefulWidget {
  const _EntryDialog({required this.title, required this.fields, required this.confirmLabel});

  final String title;
  final List<EntryField> fields;
  final String confirmLabel;

  @override
  State<_EntryDialog> createState() => _EntryDialogState();
}

class _EntryDialogState extends State<_EntryDialog> {
  static const String _requiredMessage = 'هذا الحقل مطلوب';

  late final Map<String, TextEditingController> _controllers;
  late final Map<String, String> _choices;
  late final Map<String, String> _times;
  final Map<String, String?> _errors = {};

  @override
  void initState() {
    super.initState();
    _controllers = {
      for (final f in widget.fields)
        if (f.options == null && !f.isTime) f.key: TextEditingController(text: f.initial ?? ''),
    };
    _times = {
      for (final f in widget.fields)
        if (f.isTime) f.key: _validTime(f.initial) ?? '',
    };
    _choices = {
      for (final f in widget.fields)
        if (f.options != null) f.key: f.initial ?? f.options!.first,
    };
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _submit() {
    final values = <String, String>{};
    final errors = <String, String?>{};
    for (final field in widget.fields) {
      if (field.isTime) {
        values[field.key] = _times[field.key] ?? '';
        continue;
      }
      final raw = field.options != null ? _choices[field.key]! : _controllers[field.key]!.text;
      final value = field.maxLines == 1 ? raw.replaceAll(RegExp(r'\s+'), ' ').trim() : raw.trim();
      values[field.key] = value;
      if (value.isEmpty) {
        if (field.required) errors[field.key] = _requiredMessage;
      } else if (field.validator != null) {
        errors[field.key] = field.validator!(value);
      }
    }
    if (errors.values.any((e) => e != null)) {
      setState(() => _errors
        ..clear()
        ..addAll(errors));
      return;
    }
    Navigator.of(context).pop(values);
  }

  /// `HH:mm` صالحة أو null.
  static String? _validTime(String? input) {
    final match = RegExp(r'^([01]?\d|2[0-3]):([0-5]\d)$').firstMatch((input ?? '').trim());
    return match == null ? null : '${match.group(1)!.padLeft(2, '0')}:${match.group(2)}';
  }

  Future<void> _pickTime(EntryField field) async {
    final current = _validTime(_times[field.key]);
    final initial = current == null
        ? const TimeOfDay(hour: 9, minute: 0)
        : TimeOfDay(hour: int.parse(current.substring(0, 2)), minute: int.parse(current.substring(3)));
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked == null || !mounted) return;
    setState(() {
      _times[field.key] =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    });
  }

  Widget _buildTimeField(EntryField field) {
    final value = _times[field.key] ?? '';
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(field.label, style: const TextStyle(color: AppTheme.subTextColor, fontSize: 12)),
                const SizedBox(height: 2),
                Text(
                  value.isEmpty ? 'بدون تذكير' : 'يوميًا عند $value',
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    color: value.isEmpty ? AppTheme.subTextColor : AppTheme.accentColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => _pickTime(field),
            child: Text(value.isEmpty ? 'ضبط تذكير' : 'تغيير الوقت'),
          ),
          if (value.isNotEmpty)
            IconButton(
              tooltip: 'إزالة التذكير',
              icon: const Icon(Icons.alarm_off_rounded, color: AppTheme.subTextColor),
              onPressed: () => setState(() => _times[field.key] = ''),
            ),
        ],
      ),
    );
  }

  Widget _buildField(EntryField field, {required bool first}) {
    if (field.isTime) return _buildTimeField(field);
    final options = field.options;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: options != null
          ? DropdownButtonFormField<String>(
              initialValue: _choices[field.key],
              isExpanded: true,
              dropdownColor: AppTheme.cardColor,
              decoration: InputDecoration(labelText: field.label),
              items: [
                for (final option in options)
                  DropdownMenuItem(
                    value: option,
                    child: Text(option, style: const TextStyle(color: AppTheme.textColor)),
                  ),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _choices[field.key] = value);
              },
            )
          : TextField(
              controller: _controllers[field.key],
              autofocus: first,
              keyboardType: field.keyboardType,
              maxLength: field.maxLength,
              maxLines: field.maxLines,
              style: const TextStyle(color: AppTheme.textColor),
              decoration: InputDecoration(
                labelText: field.label,
                hintText: field.hint,
                errorText: _errors[field.key],
                counterText: '',
              ),
              onChanged: (_) {
                if (_errors[field.key] != null) setState(() => _errors[field.key] = null);
              },
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final firstText = widget.fields.indexWhere((f) => f.options == null && !f.isTime);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        backgroundColor: AppTheme.cardColor,
        title: Text(widget.title, style: const TextStyle(color: AppTheme.textColor)),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < widget.fields.length; i++)
                  _buildField(widget.fields[i], first: i == firstText),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء', style: TextStyle(color: AppTheme.subTextColor)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
            onPressed: _submit,
            child: Text(widget.confirmLabel, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
