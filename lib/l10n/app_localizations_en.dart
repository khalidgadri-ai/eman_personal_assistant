// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get navGoals => 'Goals & tasks';

  @override
  String get navHealth => 'Health & fitness';

  @override
  String get navKitchen => 'Kitchen & home';

  @override
  String get navBudget => 'Budget';

  @override
  String get navAssistant => 'Assistant';

  @override
  String get coachTooltip => 'Life coach';

  @override
  String get contactUs => 'Contact us';

  @override
  String get contactMailFailed =>
      'The mail app did not open. You can write to us at this address:';

  @override
  String get close => 'Close';

  @override
  String get copyAddress => 'Copy address';

  @override
  String get cancel => 'Cancel';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsAiProvider => 'AI provider';

  @override
  String get settingsAiProviderHint => 'Turn on AI features with your own key';

  @override
  String get settingsTour => 'App tour';

  @override
  String get settingsTourHint =>
      'A short guide to every part of the app and how to get a key';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get languageSystem => 'Phone language';

  @override
  String get languageArabic => 'العربية';

  @override
  String get languageEnglish => 'English';

  @override
  String get profileNoName => 'No name';

  @override
  String get profileEdit => 'Edit my profile';

  @override
  String get profileEmpty =>
      'No name or interests yet. They are stored encrypted on this device only.';

  @override
  String get backupSaveTitle => 'Save an encrypted backup';

  @override
  String get backupSaveHint =>
      'A password-protected file saved outside the app';

  @override
  String get backupSaving => 'Encrypting, this can take a few seconds...';

  @override
  String get backupRestoreTitle => 'Restore from a backup';

  @override
  String get backupRestoreHint =>
      'Replace this device\'s data with the backup file';

  @override
  String get backupRestoring =>
      'Opening the backup, this can take a few seconds...';

  @override
  String get backupSaved =>
      'Backup saved. The password cannot be recovered, so keep it safe.';

  @override
  String get backupNotSaved => 'The backup was not saved.';

  @override
  String get backupRestoreAsk => 'Restore a backup?';

  @override
  String get backupRestoreBody =>
      'All data on this device (profile, tasks, goals, health, kitchen, expenses and coach sessions) will be replaced by the backup. AI keys are not affected.';

  @override
  String get backupChooseFile => 'Choose file';

  @override
  String get backupRestored => 'The backup was restored.';

  @override
  String get backupGenericError =>
      'This could not be completed. Your data has not changed.';

  @override
  String get passwordTitle => 'Backup password';

  @override
  String get passwordNoRecovery =>
      'There is no way to recover the password. Without it the backup can never be opened.';

  @override
  String passwordHintNew(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'at least $count characters',
      one: 'at least 1 character',
    );
    return 'Password ($_temp0)';
  }

  @override
  String get passwordHint => 'Password';

  @override
  String get passwordConfirmHint => 'Confirm password';

  @override
  String get passwordMismatch => 'The passwords do not match.';

  @override
  String get passwordRequired => 'Please enter the password.';

  @override
  String get show => 'Show';

  @override
  String get hide => 'Hide';

  @override
  String get continueAction => 'Continue';

  @override
  String get restoreAction => 'Restore';

  @override
  String get eraseTitle => 'Erase all my data';

  @override
  String get eraseHint =>
      'Deletes everything you entered on this device and starts the app fresh';

  @override
  String get eraseAsk => 'Erase all my data?';

  @override
  String get eraseBody =>
      'Everything you entered will be permanently deleted from this device: profile, tasks, goals, health, kitchen, expenses, coach sessions and AI keys. This cannot be undone.';

  @override
  String get eraseConfirm => 'Erase everything';

  @override
  String get eraseFailed =>
      'The data could not be erased. Nothing was deleted, please try again.';
}
