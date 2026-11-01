import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_theme.dart';

/// يعرض اختيار مصدر الصورة (كاميرا أو معرض). الكاميرا والمعرض عبر image_picker بلا صلاحيات.
Future<ImageSource?> showImageSourceSheet(BuildContext context) {
  return showModalBottomSheet<ImageSource>(
    context: context,
    backgroundColor: AppTheme.cardColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) => Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'اختيار مصدر الصورة',
              style: TextStyle(color: AppTheme.textColor, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _option(Icons.camera_alt_rounded, 'الكاميرا', () => Navigator.pop(context, ImageSource.camera)),
                _option(Icons.photo_library_rounded, 'المعرض', () => Navigator.pop(context, ImageSource.gallery)),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    ),
  );
}

Widget _option(IconData icon, String label, VoidCallback onTap) {
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

/// يسأل عن المصدر ثم يلتقط/يختار صورة بحجم معقول (1024 بكسل، جودة 85). null عند الإلغاء.
Future<Uint8List?> pickExerciseImage(BuildContext context) async {
  final source = await showImageSourceSheet(context);
  if (source == null) return null;
  final picked = await ImagePicker().pickImage(source: source, imageQuality: 85, maxWidth: 1024);
  return picked?.readAsBytes();
}
