import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'backup_service.dart';

/// حفظ ملف النسخة الاحتياطية واختياره. يُستبدل في الاختبارات؛ الأصل منتقي ملفات النظام.
abstract class BackupFileGateway {
  const BackupFileGateway();

  /// true إن حفظ المستخدم الملف، وfalse إن ألغى.
  Future<bool> save(String fileName, Uint8List bytes);

  /// بايتات الملف المختار، أو null إن ألغى المستخدم.
  Future<Uint8List?> pick();
}

/// منتقي ملفات النظام (Storage Access Framework على أندرويد): المستخدم يختار المكان بنفسه
/// فلا يحتاج التطبيق أي صلاحية تخزين أو وسائط.
class SystemBackupFileGateway extends BackupFileGateway {
  const SystemBackupFileGateway();

  @override
  Future<bool> save(String fileName, Uint8List bytes) async {
    final saved = await FilePicker.saveFile(
      fileName: fileName,
      bytes: bytes,
      dialogTitle: 'حفظ النسخة الاحتياطية',
    );
    return saved != null;
  }

  @override
  Future<Uint8List?> pick() async {
    final files = await FilePicker.pickFiles(dialogTitle: 'اختيار ملف النسخة الاحتياطية');
    if (files.isEmpty) return null;
    final file = files.first;
    final size = await file.length();
    if (size != null && size > BackupService.maxFileBytes) {
      throw const BackupException(BackupFailure.notABackup);
    }
    return file.readAsBytes();
  }
}
