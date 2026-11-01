import 'dart:typed_data';

import 'package:eman_life_app/core/app_events.dart';
import 'package:eman_life_app/core/theme/app_theme.dart';
import 'package:eman_life_app/features/settings/backup_file_gateway.dart';
import 'package:eman_life_app/features/settings/backup_service.dart';
import 'package:eman_life_app/features/settings/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/test_storage.dart';

class _FakeGateway extends BackupFileGateway {
  _FakeGateway({this.pickResult, this.saveResult = true, this.pickError});

  Uint8List? pickResult;
  bool saveResult;
  Object? pickError;

  String? savedName;
  Uint8List? savedBytes;
  int picks = 0;

  @override
  Future<bool> save(String fileName, Uint8List bytes) async {
    savedName = fileName;
    savedBytes = bytes;
    return saveResult;
  }

  @override
  Future<Uint8List?> pick() async {
    picks++;
    if (pickError != null) throw pickError!;
    return pickResult;
  }
}

void main() {
  late TestStorage storage;

  setUp(() async {
    storage = await TestStorage.inMemory();
  });
  tearDown(() => storage.dispose());

  final fakeBackup = Uint8List.fromList([1, 2, 3, 4]);

  Future<void> pumpSettings(
    WidgetTester tester, {
    required _FakeGateway gateway,
    Future<Uint8List> Function(String)? createBackup,
    Future<DateTime?> Function(Uint8List, String)? restoreBackup,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: SettingsScreen(
          backupFiles: gateway,
          createBackup: createBackup ?? (_) async => fakeBackup,
          restoreBackup: restoreBackup ?? (_, _) async => null,
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
  }

  Future<void> enterPasswords(WidgetTester tester, String password, [String? repeat]) async {
    final fields = find.byType(TextField);
    await tester.enterText(fields.first, password);
    if (repeat != null) await tester.enterText(fields.at(1), repeat);
  }

  testWidgets('both backup buttons are on the settings screen', (tester) async {
    await pumpSettings(tester, gateway: _FakeGateway());

    expect(find.text('حفظ نسخة احتياطية مشفّرة'), findsOneWidget);
    expect(find.text('استعادة من نسخة احتياطية'), findsOneWidget);
  });

  testWidgets('saving asks for the password twice, warns it cannot be recovered, then saves the file', (tester) async {
    final gateway = _FakeGateway();
    String? usedPassword;
    await pumpSettings(
      tester,
      gateway: gateway,
      createBackup: (password) async {
        usedPassword = password;
        return fakeBackup;
      },
    );

    await tester.tap(find.text('حفظ نسخة احتياطية مشفّرة'));
    await tester.pumpAndSettle();
    expect(find.textContaining('لا توجد طريقة لاسترجاع كلمة المرور'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));

    await enterPasswords(tester, 'كلمة سر قوية', 'كلمة سر قوية');
    await tester.tap(find.text('متابعة'));
    await tester.pumpAndSettle();

    expect(usedPassword, 'كلمة سر قوية');
    expect(gateway.savedBytes, fakeBackup);
    expect(gateway.savedName, endsWith('.${BackupService.fileExtension}'));
    expect(find.textContaining('حُفظت النسخة الاحتياطية'), findsOneWidget);
  });

  testWidgets('a short or mismatched password is refused inside the dialog and nothing is created', (tester) async {
    var created = 0;
    await pumpSettings(
      tester,
      gateway: _FakeGateway(),
      createBackup: (_) async {
        created++;
        return fakeBackup;
      },
    );

    await tester.tap(find.text('حفظ نسخة احتياطية مشفّرة'));
    await tester.pumpAndSettle();

    await enterPasswords(tester, '1234567', '1234567');
    await tester.tap(find.text('متابعة'));
    await tester.pumpAndSettle();
    expect(find.text(BackupFailure.weakPassword.message), findsOneWidget);

    await enterPasswords(tester, 'كلمة سر قوية', 'كلمة سر مختلفة');
    await tester.tap(find.text('متابعة'));
    await tester.pumpAndSettle();
    expect(find.text('كلمتا المرور غير متطابقتين.'), findsOneWidget);

    expect(created, 0);
    expect(find.textContaining('لا توجد طريقة لاسترجاع كلمة المرور'), findsOneWidget, reason: 'dialog stays open');
  });

  testWidgets('cancelling the password dialog creates nothing', (tester) async {
    var created = 0;
    final gateway = _FakeGateway();
    await pumpSettings(
      tester,
      gateway: gateway,
      createBackup: (_) async {
        created++;
        return fakeBackup;
      },
    );

    await tester.tap(find.text('حفظ نسخة احتياطية مشفّرة'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('إلغاء'));
    await tester.pumpAndSettle();

    expect(created, 0);
    expect(gateway.savedBytes, isNull);
  });

  testWidgets('if the user dismisses the system save dialog the screen says it was not saved', (tester) async {
    await pumpSettings(tester, gateway: _FakeGateway(saveResult: false));

    await tester.tap(find.text('حفظ نسخة احتياطية مشفّرة'));
    await tester.pumpAndSettle();
    await enterPasswords(tester, 'كلمة سر قوية', 'كلمة سر قوية');
    await tester.tap(find.text('متابعة'));
    await tester.pumpAndSettle();

    expect(find.text('لم تُحفظ النسخة الاحتياطية.'), findsOneWidget);
  });

  testWidgets('a failure while saving shows a fixed Arabic message, never the raw error', (tester) async {
    await pumpSettings(
      tester,
      gateway: _FakeGateway(),
      createBackup: (_) async => throw StateError('disk is read-only: /secret/path'),
    );

    await tester.tap(find.text('حفظ نسخة احتياطية مشفّرة'));
    await tester.pumpAndSettle();
    await enterPasswords(tester, 'كلمة سر قوية', 'كلمة سر قوية');
    await tester.tap(find.text('متابعة'));
    await tester.pumpAndSettle();

    expect(find.text('تعذّر إتمام العملية. لم تتغير البيانات.'), findsOneWidget);
    expect(find.textContaining('secret'), findsNothing);
    // الزر ما زال يعمل بعد الفشل.
    await tester.tap(find.text('حفظ نسخة احتياطية مشفّرة'));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsNWidgets(2));
  });

  testWidgets('restoring warns that device data is replaced, then picks the file and asks for the password', (tester) async {
    final gateway = _FakeGateway(pickResult: fakeBackup);
    Uint8List? gotBytes;
    String? gotPassword;
    await pumpSettings(
      tester,
      gateway: gateway,
      restoreBackup: (bytes, password) async {
        gotBytes = bytes;
        gotPassword = password;
        return DateTime(2026, 10, 1);
      },
    );
    final before = AppEvents.dataRestored.value;

    await tester.tap(find.text('استعادة من نسخة احتياطية'));
    await tester.pumpAndSettle();
    expect(find.text('استعادة نسخة احتياطية؟'), findsOneWidget);
    expect(find.textContaining('ستُستبدل بيانات هذا الجهاز'), findsOneWidget);
    expect(gateway.picks, 0, reason: 'no file is read before the user agrees');

    await tester.tap(find.text('اختيار الملف'));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsOneWidget, reason: 'restore asks the password once');

    await enterPasswords(tester, 'كلمة سر قوية');
    await tester.tap(find.text('استعادة'));
    await tester.pumpAndSettle();

    expect(gotBytes, fakeBackup);
    expect(gotPassword, 'كلمة سر قوية');
    expect(AppEvents.dataRestored.value, before + 1, reason: 'the gate rebuilds the screens');
    expect(find.text('تمت استعادة النسخة الاحتياطية.'), findsOneWidget);
  });

  testWidgets('cancelling the warning picks no file and restores nothing', (tester) async {
    final gateway = _FakeGateway(pickResult: fakeBackup);
    var restored = 0;
    await pumpSettings(tester, gateway: gateway, restoreBackup: (_, _) async {
      restored++;
      return null;
    });

    await tester.tap(find.text('استعادة من نسخة احتياطية'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('إلغاء'));
    await tester.pumpAndSettle();

    expect(gateway.picks, 0);
    expect(restored, 0);
  });

  testWidgets('leaving the system file picker without choosing a file restores nothing', (tester) async {
    final gateway = _FakeGateway(pickResult: null);
    var restored = 0;
    await pumpSettings(tester, gateway: gateway, restoreBackup: (_, _) async {
      restored++;
      return null;
    });
    final before = AppEvents.dataRestored.value;

    await tester.tap(find.text('استعادة من نسخة احتياطية'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('اختيار الملف'));
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsNothing);
    expect(restored, 0);
    expect(AppEvents.dataRestored.value, before);
  });

  testWidgets('a wrong password says so and does not signal a restore', (tester) async {
    await pumpSettings(
      tester,
      gateway: _FakeGateway(pickResult: fakeBackup),
      restoreBackup: (_, _) async => throw const BackupException(BackupFailure.wrongPasswordOrCorrupt),
    );
    final before = AppEvents.dataRestored.value;

    await tester.tap(find.text('استعادة من نسخة احتياطية'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('اختيار الملف'));
    await tester.pumpAndSettle();
    await enterPasswords(tester, 'كلمة خاطئة تمامًا');
    await tester.tap(find.text('استعادة'));
    await tester.pumpAndSettle();

    expect(find.text(BackupFailure.wrongPasswordOrCorrupt.message), findsOneWidget);
    expect(AppEvents.dataRestored.value, before);
  });

  testWidgets('a file that is not a backup is reported before any password is asked', (tester) async {
    await pumpSettings(
      tester,
      gateway: _FakeGateway(pickError: const BackupException(BackupFailure.notABackup)),
    );

    await tester.tap(find.text('استعادة من نسخة احتياطية'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('اختيار الملف'));
    await tester.pumpAndSettle();

    expect(find.text(BackupFailure.notABackup.message), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
  });
}
