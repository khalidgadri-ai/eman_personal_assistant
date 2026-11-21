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

  @override
  String get back => 'Back';

  @override
  String get next => 'Next';

  @override
  String get skip => 'Skip';

  @override
  String get save => 'Save';

  @override
  String get start => 'Start';

  @override
  String get interestHealth => 'Health & fitness';

  @override
  String get interestGrowth => 'Personal growth';

  @override
  String get interestReading => 'Reading';

  @override
  String get interestFaith => 'Worship & spirituality';

  @override
  String get interestBudget => 'Budget & saving';

  @override
  String get interestKitchen => 'Cooking & recipes';

  @override
  String get interestHome => 'Home organizing';

  @override
  String get interestSkills => 'Learning new skills';

  @override
  String get interestWork => 'Work & productivity';

  @override
  String get interestFamily => 'Family';

  @override
  String get onboardingWelcome => 'Welcome to Eman';

  @override
  String get onboardingIntro =>
      'Your personal assistant for tasks, health, cooking and budget. Everything you enter stays on your device.';

  @override
  String get onboardingNameQuestion => 'What\'s your name?';

  @override
  String get onboardingNameLabel => 'What\'s your name? (optional)';

  @override
  String get onboardingInterestsTitle => 'What matters to you?';

  @override
  String get onboardingInterestsHint =>
      'Pick what fits you. You can change it later in Settings.';

  @override
  String get onboardingGoalsTitle => 'Your goals (optional)';

  @override
  String get onboardingGoalLabel => 'Type a goal, then tap +';

  @override
  String get onboardingGoalHint => 'Example: read 20 pages a day';

  @override
  String get onboardingAddGoal => 'Add goal';

  @override
  String get onboardingRemoveGoal => 'Remove goal';

  @override
  String get onboardingPrivacy =>
      'This is stored encrypted on your device. If you turn on the AI assistant with your key, it is sent with the assistant\'s requests to the AI provider you choose, to tailor the replies.';

  @override
  String get onboardingSaveFailed =>
      'Could not save on your device. Please try again.';

  @override
  String tourPageOf(int page, int total) {
    return 'Page $page of $total';
  }

  @override
  String get tourIntroTitle => 'A short tour';

  @override
  String get tourIntro1 => 'We\'ll show you the app in 10 short pages.';

  @override
  String get tourIntro2 => 'Each page has just one idea.';

  @override
  String get tourIntro3 => 'You can go back to any page with \"Back\".';

  @override
  String get tourTasksTitle => 'Goals & tasks';

  @override
  String get tourTasks1 => 'Add one small task with the \"+\" button.';

  @override
  String get tourTasks2 => 'When it\'s done, tick it ✓.';

  @override
  String get tourTasksExample => 'Example: \"Buy bread\".';

  @override
  String get tourGoalsTitle => 'Break big into small';

  @override
  String get tourGoals1 => 'A big goal gets easier when you split it.';

  @override
  String get tourGoals2 => 'Move the progress bar each time you finish a part.';

  @override
  String get tourGoalsExample =>
      'Example: \"Tidy the house\" is a monthly goal, \"Tidy the bedroom\" a weekly one, and \"Tidy one drawer\" today\'s task.';

  @override
  String get tourRemindersTitle => 'Reminders';

  @override
  String get tourReminders1 =>
      'You can give a task or a medicine a time, and you\'ll get a notification.';

  @override
  String get tourReminders2 =>
      'When the phone asks about notifications, tap \"Allow\".';

  @override
  String get tourReminders3 => 'A reminder can arrive a few minutes late.';

  @override
  String get tourHealthTitle => 'Health & fitness';

  @override
  String get tourHealth1 =>
      'Log your exercises, your medicine times and your care routine.';

  @override
  String get tourHealthExample => 'Example: morning medicine at 8.';

  @override
  String get tourKitchenTitle => 'Kitchen & home';

  @override
  String get tourKitchen1 =>
      'Your recipes, what you have at home, the shopping list and the laundry schedule.';

  @override
  String get tourKitchen2 =>
      'Anything running low at home can move to the shopping list.';

  @override
  String get tourBudgetTitle => 'Budget';

  @override
  String get tourBudget1 =>
      'Enter your income and fixed costs once, and the app works out how much you can spend today.';

  @override
  String get tourBudget2 => 'All the numbers stay on your phone.';

  @override
  String get tourCoachTitle => 'Coach and AI assistant';

  @override
  String get tourCoach1 =>
      'The coach button (the head icon at the bottom centre) asks you questions that help you think things through.';

  @override
  String get tourCoach2 =>
      'The AI assistant answers your questions, but it needs a key: the next page shows how to get one.';

  @override
  String get tourKeyTitle => 'AI key';

  @override
  String get tourStartTitle => 'Start with one step';

  @override
  String get tourStart1 => 'Don\'t try to sort everything out today.';

  @override
  String get tourStart2 => 'Choose one small thing and start with it.';

  @override
  String get tourStart3 => 'You can replay this tour from Settings.';

  @override
  String get tourSaveFailed =>
      'Could not save that you finished the tour on this device.';

  @override
  String get tourKeySaved => '✓ Key saved';

  @override
  String get tourAddKeyNow => 'Add the key now';

  @override
  String get tourAddKeyLater => 'I\'ll add it later';

  @override
  String get tourFinishFirstRun => 'Start using the app';

  @override
  String get tourFinish => 'Finish';

  @override
  String get keyGuideTitle => 'How do I get a key?';

  @override
  String get keyGuideIntro =>
      'A key is like your own password from the provider. It lets the app ask the AI on your behalf.';

  @override
  String keyGuideStepsWith(String provider) {
    return 'Steps with $provider:';
  }

  @override
  String get keyGuideGemini1 => 'Tap \"Open the keys page\".';

  @override
  String get keyGuideGemini2 => 'Sign in with your Google account.';

  @override
  String get keyGuideGemini3 => 'Accept the terms if they appear.';

  @override
  String get keyGuideGemini4 =>
      'Tap the button labelled Create API key (it may appear in your phone\'s language).';

  @override
  String get keyGuideGemini5 => 'Copy the key.';

  @override
  String get keyGuideGemini6 =>
      'Come back to the app, paste it in the \"Key\" field, then tap \"Save and activate\".';

  @override
  String get keyGuideOther1 => 'Tap \"Open the keys page\".';

  @override
  String get keyGuideOther2 => 'Sign in.';

  @override
  String get keyGuideOther3 => 'Create a new key.';

  @override
  String get keyGuideOther4 =>
      'Copy the key, come back to the app, paste it in the \"Key\" field, then tap \"Save and activate\".';

  @override
  String get keyGuideGeminiFree =>
      'Gemini has free use within limits set by Google. If you turn on billing in your Google account, you may be charged.';

  @override
  String get keyGuidePaymentNote =>
      'Some providers ask for a payment method before the key works.';

  @override
  String get keyGuideDontShare =>
      'Never share or post your key. It is stored on your phone only.';

  @override
  String get keyGuideOpenPage => 'Open the keys page';

  @override
  String get keyGuideLinkCopied => 'Link copied. Paste it in your browser.';
}
