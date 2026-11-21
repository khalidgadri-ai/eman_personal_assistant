import 'dart:typed_data';

import 'package:flutter/material.dart';
import '../../core/ai/ai_settings_service.dart';
import '../../core/ai/provider_presets.dart';
import '../../core/app_events.dart';
import '../../core/config/app_locale.dart';
import '../../core/services/database_service.dart';
import '../../core/services/profile_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/ai_provider_screen.dart';
import '../../l10n/l10n.dart';
import '../onboarding/app_tour_screen.dart';
import '../onboarding/onboarding_screen.dart';
import 'backup_file_gateway.dart';
import 'backup_service.dart';
import 'data_reset_service.dart';

class SettingsScreen extends StatefulWidget {
  /// [eraser] والنسخ الاحتياطي ([backupFiles] وcreateBackup وrestoreBackup) تُستبدل في
  /// الاختبارات فقط؛ الأصل هو المسح الحقيقي ومنتقي ملفات النظام وBackupService.
  const SettingsScreen({
    super.key,
    this.eraser = DataResetService.eraseEverything,
    this.backupFiles = const SystemBackupFileGateway(),
    this.createBackup = BackupService.createBackup,
    this.restoreBackup = BackupService.restoreBackup,
  });

  final Future<void> Function() eraser;
  final BackupFileGateway backupFiles;
  final Future<Uint8List> Function(String password) createBackup;
  final Future<DateTime?> Function(Uint8List bytes, String password) restoreBackup;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

enum _BackupTask { saving, restoring }

class _SettingsScreenState extends State<SettingsScreen> {
  UserProfile? _profile;
  String _aiSummary = '';
  bool _loading = true;
  bool _erasing = false;
  _BackupTask? _backupTask;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    UserProfile? profile;
    try {
      profile = (await ProfileService.getInstance()).profile;
    } catch (e) {
      debugPrint('SettingsScreen: could not read profile (${e.runtimeType})');
    }
    final aiSummary = await _readAiSummary();
    if (!mounted) return;
    setState(() {
      _profile = profile;
      _aiSummary = aiSummary;
      _loading = false;
    });
  }

  /// سطر يصف المزوّد الحالي في الإعدادات (اسمه والموديل)، أو فارغ إن لم يُعدّ بعد.
  Future<String> _readAiSummary() async {
    try {
      final settings = await AiSettingsService.getInstance();
      final config = settings.selected;
      if (config == null || !await settings.hasKey(config.id)) return '';
      final label = AiPresets.byId(config.id).label;
      return config.model.isEmpty ? label : '$label — ${config.model}';
    } catch (e) {
      debugPrint('SettingsScreen: could not read AI settings (${e.runtimeType})');
      return '';
    }
  }

  Future<void> _editProfile() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (routeContext) => OnboardingScreen(
          initial: _profile ?? const UserProfile(),
          onFinished: () => Navigator.of(routeContext).pop(),
        ),
      ),
    );
    await _load();
  }

  Future<void> _saveBackup() async {
    final password = await showDialog<String>(
      context: context,
      builder: (_) => const _PasswordDialog(confirm: true),
    );
    if (password == null || !mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    setState(() => _backupTask = _BackupTask.saving);
    String message;
    try {
      final bytes = await widget.createBackup(password);
      final saved = await widget.backupFiles.save(BackupService.suggestedFileName(), bytes);
      message = saved ? l10n.backupSaved : l10n.backupNotSaved;
    } catch (e) {
      message = _backupErrorMessage(e);
    }
    if (mounted) setState(() => _backupTask = null);
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _restoreBackup() async {
    final l10n = context.l10n;
    final proceed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        title: Text(l10n.backupRestoreAsk, style: const TextStyle(color: AppTheme.textColor)),
        content: Text(
          l10n.backupRestoreBody,
          style: const TextStyle(color: AppTheme.subTextColor, height: 1.7),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel, style: const TextStyle(color: AppTheme.subTextColor)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.backupChooseFile, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (proceed != true || !mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    try {
      final bytes = await widget.backupFiles.pick();
      if (bytes == null || !mounted) return;
      final password = await showDialog<String>(
        context: context,
        builder: (_) => const _PasswordDialog(confirm: false),
      );
      if (password == null || !mounted) return;
      setState(() => _backupTask = _BackupTask.restoring);
      await widget.restoreBackup(bytes, password);
    } catch (e) {
      if (mounted) setState(() => _backupTask = null);
      // فشل التراجع نفسه: البيانات قد تكون تغيّرت جزئيًا، فتُعاد قراءتها في الشاشات.
      if (e is BackupException && e.reason == BackupFailure.restoreFailedUnsafe) {
        AppEvents.dataRestored.value++;
      }
      messenger.showSnackBar(SnackBar(content: Text(_backupErrorMessage(e))));
      return;
    }
    if (mounted) setState(() => _backupTask = null);
    // البوابة تسمع الإشارة وتعيد بناء الشاشات ببيانات النسخة؛ نعود لجذر التطبيق فقط.
    AppEvents.dataRestored.value++;
    navigator.popUntil((route) => route.isFirst);
    messenger.showSnackBar(SnackBar(content: Text(l10n.backupRestored)));
  }

  /// رسالة ثابتة: لا نص خطأ خام ولا مسارات.
  String _backupErrorMessage(Object error) {
    if (error is BackupException) return error.message;
    debugPrint('Backup failed: ${error.runtimeType}');
    return context.l10n.backupGenericError;
  }

  Future<void> _confirmErase() async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        title: Text(l10n.eraseAsk, style: const TextStyle(color: AppTheme.textColor)),
        content: Text(
          l10n.eraseBody,
          style: const TextStyle(color: AppTheme.subTextColor, height: 1.7),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel, style: const TextStyle(color: AppTheme.subTextColor)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.eraseConfirm, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _erasing = true);
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await widget.eraser();
    } catch (e) {
      debugPrint('Erase failed: ${e.runtimeType}');
      if (!mounted) return;
      setState(() => _erasing = false);
      messenger.showSnackBar(SnackBar(content: Text(l10n.eraseFailed)));
      return;
    }
    // البوابة تسمع إشارة المسح وتعرض الترحيب؛ نعود لجذر التطبيق فقط.
    if (mounted) setState(() => _erasing = false);
    navigator.popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildProfileCard(),
                const SizedBox(height: 16),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.vpn_key_rounded, color: AppTheme.accentColor),
                    title: Text(l10n.settingsAiProvider, style: const TextStyle(color: AppTheme.textColor)),
                    subtitle: Text(
                      _aiSummary.isEmpty ? l10n.settingsAiProviderHint : _aiSummary,
                      textDirection: _aiSummary.isEmpty ? null : TextDirection.ltr,
                      style: const TextStyle(color: AppTheme.subTextColor, fontSize: 12),
                    ),
                    onTap: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute<void>(builder: (_) => const AiProviderScreen()),
                      );
                      final summary = await _readAiSummary();
                      if (mounted) setState(() => _aiSummary = summary);
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.tour_rounded, color: AppTheme.accentColor),
                    title: Text(l10n.settingsTour, style: const TextStyle(color: AppTheme.textColor)),
                    subtitle: Text(
                      l10n.settingsTourHint,
                      style: const TextStyle(color: AppTheme.subTextColor, fontSize: 12),
                    ),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(builder: (_) => const AppTourScreen(mandatory: false)),
                    ),
                  ),
                ),
                if (AppLocale.languagePickerVisible) ...[
                  const SizedBox(height: 16),
                  _buildLanguageCard(),
                ],
                const SizedBox(height: 16),
                _buildBackupCard(),
                const SizedBox(height: 16),
                Card(
                  child: ListTile(
                    leading: _erasing
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.delete_forever_rounded, color: Colors.redAccent),
                    title: Text(
                      l10n.eraseTitle,
                      style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      l10n.eraseHint,
                      style: const TextStyle(color: AppTheme.subTextColor, fontSize: 12),
                    ),
                    onTap: _erasing ? null : _confirmErase,
                  ),
                ),
              ],
            ),
    );
  }

  String _languageLabel(AppLanguage language) => switch (language) {
        AppLanguage.system => context.l10n.languageSystem,
        AppLanguage.ar => context.l10n.languageArabic,
        AppLanguage.en => context.l10n.languageEnglish,
      };

  Widget _buildLanguageCard() {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.language_rounded, color: AppTheme.accentColor),
        title: Text(context.l10n.settingsLanguage, style: const TextStyle(color: AppTheme.textColor)),
        subtitle: Text(
          _languageLabel(AppLocale.choice.value),
          style: const TextStyle(color: AppTheme.subTextColor, fontSize: 12),
        ),
        onTap: _chooseLanguage,
      ),
    );
  }

  Future<void> _chooseLanguage() async {
    final chosen = await showDialog<AppLanguage>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        backgroundColor: AppTheme.cardColor,
        title: Text(context.l10n.settingsLanguage, style: const TextStyle(color: AppTheme.textColor)),
        children: [
          for (final language in AppLanguage.values)
            SimpleDialogOption(
              onPressed: () => Navigator.of(dialogContext).pop(language),
              child: Row(
                children: [
                  Icon(
                    language == AppLocale.choice.value
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_unchecked_rounded,
                    color: AppTheme.accentColor,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(_languageLabel(language), style: const TextStyle(color: AppTheme.textColor)),
                ],
              ),
            ),
        ],
      ),
    );
    if (chosen == null || chosen == AppLocale.choice.value) return;
    try {
      await (await DatabaseService.getInstance()).saveAppLanguage(chosen.name);
    } catch (e) {
      debugPrint('SettingsScreen: could not save the language (${e.runtimeType})');
    }
    AppLocale.choice.value = chosen;
    if (mounted) setState(() {});
  }

  Widget _buildBackupCard() {
    final busy = _backupTask != null;
    Widget leading(_BackupTask task, IconData icon) {
      if (_backupTask == task) {
        return const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2));
      }
      return Icon(icon, color: AppTheme.accentColor);
    }

    return Card(
      child: Column(
        children: [
          ListTile(
            leading: leading(_BackupTask.saving, Icons.lock_rounded),
            title: Text(context.l10n.backupSaveTitle, style: const TextStyle(color: AppTheme.textColor)),
            subtitle: Text(
              _backupTask == _BackupTask.saving ? context.l10n.backupSaving : context.l10n.backupSaveHint,
              style: const TextStyle(color: AppTheme.subTextColor, fontSize: 12),
            ),
            onTap: busy ? null : _saveBackup,
          ),
          const Divider(height: 1),
          ListTile(
            leading: leading(_BackupTask.restoring, Icons.settings_backup_restore_rounded),
            title: Text(context.l10n.backupRestoreTitle, style: const TextStyle(color: AppTheme.textColor)),
            subtitle: Text(
              _backupTask == _BackupTask.restoring ? context.l10n.backupRestoring : context.l10n.backupRestoreHint,
              style: const TextStyle(color: AppTheme.subTextColor, fontSize: 12),
            ),
            onTap: busy ? null : _restoreBackup,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    final profile = _profile;
    final name = profile?.name ?? '';
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.person_rounded, color: AppTheme.accentColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    name.isEmpty ? context.l10n.profileNoName : name,
                    style: const TextStyle(
                      color: AppTheme.textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _editProfile,
                  child: Text(context.l10n.profileEdit, style: const TextStyle(color: AppTheme.accentColor)),
                ),
              ],
            ),
            if (profile != null && profile.interests.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final interest in profile.interests)
                    Chip(
                      label: Text(interest, style: const TextStyle(fontSize: 12)),
                      backgroundColor: AppTheme.surfaceColor,
                    ),
                ],
              ),
            ],
            if (profile != null && profile.goals.isNotEmpty) ...[
              const SizedBox(height: 8),
              for (final goal in profile.goals)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    '• $goal',
                    style: const TextStyle(color: AppTheme.subTextColor, fontSize: 13),
                  ),
                ),
            ],
            if (profile == null || profile.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  context.l10n.profileEmpty,
                  style: const TextStyle(color: AppTheme.subTextColor, fontSize: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// كلمة مرور النسخة الاحتياطية. عند [confirm] تُكتب مرتين مع تحذير أنها لا تُسترجع.
class _PasswordDialog extends StatefulWidget {
  const _PasswordDialog({required this.confirm});

  final bool confirm;

  @override
  State<_PasswordDialog> createState() => _PasswordDialogState();
}

class _PasswordDialogState extends State<_PasswordDialog> {
  final TextEditingController _password = TextEditingController();
  final TextEditingController _repeat = TextEditingController();
  bool _hidden = true;
  String? _error;

  @override
  void dispose() {
    _password.dispose();
    _repeat.dispose();
    super.dispose();
  }

  void _submit() {
    final password = _password.text;
    if (widget.confirm) {
      if (password.runes.length < BackupService.minPasswordLength) {
        setState(() => _error = BackupFailure.weakPassword.message);
        return;
      }
      if (password != _repeat.text) {
        setState(() => _error = context.l10n.passwordMismatch);
        return;
      }
    } else if (password.isEmpty) {
      setState(() => _error = context.l10n.passwordRequired);
      return;
    }
    Navigator.of(context).pop(password);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
        backgroundColor: AppTheme.cardColor,
        title: Text(l10n.passwordTitle, style: const TextStyle(color: AppTheme.textColor)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.confirm)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  l10n.passwordNoRecovery,
                  style: const TextStyle(color: AppTheme.subTextColor, height: 1.7, fontSize: 13),
                ),
              ),
            TextField(
              controller: _password,
              obscureText: _hidden,
              autofocus: true,
              enableSuggestions: false,
              autocorrect: false,
              style: const TextStyle(color: AppTheme.textColor),
              decoration: InputDecoration(
                hintText: widget.confirm
                    ? l10n.passwordHintNew(BackupService.minPasswordLength)
                    : l10n.passwordHint,
                hintStyle: const TextStyle(color: AppTheme.subTextColor),
                suffixIcon: IconButton(
                  tooltip: _hidden ? l10n.show : l10n.hide,
                  icon: Icon(_hidden ? Icons.visibility_rounded : Icons.visibility_off_rounded),
                  onPressed: () => setState(() => _hidden = !_hidden),
                ),
              ),
              onSubmitted: (_) => widget.confirm ? null : _submit(),
            ),
            if (widget.confirm)
              TextField(
                controller: _repeat,
                obscureText: _hidden,
                enableSuggestions: false,
                autocorrect: false,
                style: const TextStyle(color: AppTheme.textColor),
                decoration: InputDecoration(
                  hintText: l10n.passwordConfirmHint,
                  hintStyle: const TextStyle(color: AppTheme.subTextColor),
                ),
                onSubmitted: (_) => _submit(),
              ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(_error!, style: const TextStyle(color: Colors.redAccent, fontSize: 13)),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel, style: const TextStyle(color: AppTheme.subTextColor)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
          onPressed: _submit,
          child: Text(
            widget.confirm ? l10n.continueAction : l10n.restoreAction,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
