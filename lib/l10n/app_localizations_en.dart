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

  @override
  String get add => 'Add';

  @override
  String get undo => 'Undo';

  @override
  String get fieldRequired => 'This field is required';

  @override
  String get reminderNone => 'No reminder';

  @override
  String reminderAt(String time) {
    return 'Daily at $time';
  }

  @override
  String get reminderSet => 'Set reminder';

  @override
  String get reminderChange => 'Change time';

  @override
  String get reminderRemove => 'Remove reminder';

  @override
  String get reminderMedicationTitle => 'Medicine reminder';

  @override
  String get reminderRoutineTitle => 'Care reminder';

  @override
  String get reminderTaskTitle => 'Task reminder';

  @override
  String get reminderNotScheduled =>
      'The reminder was not set. Turn on notifications for this app in the phone settings, then try again.';

  @override
  String get notificationChannelName => 'Life and home reminders';

  @override
  String get notificationChannelDescription =>
      'Reminders for the medicines, care routine and tasks you set yourself';

  @override
  String get tasksTitle => '🎯 Goals & daily tasks';

  @override
  String get voiceImportTooltip => 'Import tasks from a voice note';

  @override
  String get tabDailyTasks => 'Daily tasks';

  @override
  String get tabGoals => 'Goal ladder';

  @override
  String get tabWird => 'Quran reading';

  @override
  String get taskAddTitle => 'New task';

  @override
  String get taskField => 'Task';

  @override
  String get taskHint => 'Write the task...';

  @override
  String get categoryField => 'Category';

  @override
  String get reminderField => 'Reminder';

  @override
  String get taskEditTitle => 'Edit task';

  @override
  String taskDeleted(String title) {
    return 'Deleted \"$title\"';
  }

  @override
  String get addTask => 'Add task';

  @override
  String get taskPin => 'Pin task';

  @override
  String get taskUnpin => 'Unpin task';

  @override
  String get taskDelete => 'Delete task';

  @override
  String get tasksHeader => 'Task center';

  @override
  String get tasksVoiceTip =>
      'Tap the microphone icon 🎙️ at the top to import tasks from a voice note';

  @override
  String get tasksEmpty =>
      'No tasks yet. Tap + to add one, or use a voice note.';

  @override
  String get catPersonal => 'Personal';

  @override
  String get catHome => 'Home';

  @override
  String get catWork => 'Work';

  @override
  String get catFamily => 'Family';

  @override
  String get goalAdd => 'Add goal';

  @override
  String get goalField => 'Goal';

  @override
  String get goalTypeField => 'Type';

  @override
  String get goalEditTitle => 'Edit goal';

  @override
  String goalDeleted(String title) {
    return 'Deleted goal \"$title\"';
  }

  @override
  String get goalPin => 'Pin goal';

  @override
  String get goalUnpin => 'Unpin goal';

  @override
  String get goalDelete => 'Delete goal';

  @override
  String get goalsHeader => 'Goal ladder (yearly ➡️ monthly ➡️ weekly)';

  @override
  String get goalsEmpty => 'No goals yet. Tap + to add your first goal.';

  @override
  String get goalTypeGeneral => 'General goal';

  @override
  String get goalTypeYearly => 'Yearly goal';

  @override
  String get goalTypeMonthly => 'Monthly goal';

  @override
  String get goalTypeWeekly => 'Weekly goal';

  @override
  String get wirdTitle => 'Daily Quran reading tracker';

  @override
  String wirdCurrentPage(int page) {
    return 'Current page: $page';
  }

  @override
  String get wirdFinished =>
      'You have finished the whole Quran 🎉 May God bless you';

  @override
  String wirdRemaining(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pages',
      one: '1 page',
    );
    return 'Left to finish: $_temp0';
  }

  @override
  String get wirdReadOne => 'Read one page (+1)';

  @override
  String get wirdSetPage => 'Set page';

  @override
  String get wirdSetTitle => 'Set the current page';

  @override
  String wirdPageField(int max) {
    return 'Page number (0 - $max)';
  }

  @override
  String wirdPageError(int max) {
    return 'Enter a number from 0 to $max';
  }

  @override
  String get voiceTitle => '🎙️ Import from a voice note';

  @override
  String get voicePrompt =>
      'Type the voice note, or whatever you want to turn into tasks:';

  @override
  String get voiceHint =>
      'Example: today I want to finish the report, go to the market and tidy the wardrobe...';

  @override
  String get voiceExtracted => 'Tasks found:';

  @override
  String get voiceExtracting => 'Finding tasks...';

  @override
  String get voiceExtract => 'Find tasks 🧠';

  @override
  String get voiceImport => 'Add the tasks to the list ✅';

  @override
  String voiceImported(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '✅ $count tasks imported',
      one: '✅ 1 task imported',
      zero: 'No tasks were imported',
    );
    return '$_temp0';
  }

  @override
  String get healthTitle => '🏋️ Health, fitness & care';

  @override
  String get awarenessTooltip => 'Usage awareness';

  @override
  String get tabExercises => 'Exercises';

  @override
  String get tabMeds => 'Medicines';

  @override
  String get tabCare => 'Skin care';

  @override
  String get tabMeditation => 'Meditation';

  @override
  String exerciseDeleted(String name) {
    return 'Deleted \"$name\"';
  }

  @override
  String get medAddTitle => 'Add a medicine or supplement';

  @override
  String get nameField => 'Name';

  @override
  String get medNameHint => 'Example: vitamin D';

  @override
  String get timeOptionalField => 'Time (optional)';

  @override
  String get medTimeHint => 'Example: 9:00 am';

  @override
  String get medEditTitle => 'Edit medicine';

  @override
  String get careAddTitle => 'Add a routine product';

  @override
  String get productField => 'Product';

  @override
  String get careProductHint => 'Example: moisturizer';

  @override
  String get timeField => 'Time';

  @override
  String get careStepField => 'How to use (optional)';

  @override
  String get careEditTitle => 'Edit product';

  @override
  String get careMorning => 'Morning';

  @override
  String get careEvening => 'Evening';

  @override
  String get careBoth => 'Morning and evening';

  @override
  String get exerciseAnalysisTitle => '🏋️ Exercise and muscle analysis';

  @override
  String get saveAsExercise => 'Save as exercise';

  @override
  String get medReadTitle => '💊 Medicine box reading';

  @override
  String get medLabelNotice =>
      'This is an automatic reading of the box and may be wrong. Check the leaflet, a pharmacist or a doctor before taking any dose.';

  @override
  String get okAction => 'OK';

  @override
  String get addExercise => 'Add exercise';

  @override
  String get addMedication => 'Add medicine';

  @override
  String get addProduct => 'Add product';

  @override
  String get healthLoadFailed => 'Your saved health data could not be opened.';

  @override
  String get retry => 'Try again';

  @override
  String get yourExercises => 'Your exercises';

  @override
  String get analyzingImage => 'Analyzing the photo with AI...';

  @override
  String get analyzeExerciseImage => 'Analyze an exercise photo with AI';

  @override
  String get exerciseCardsHeader => 'Exercise cards with sets and reps';

  @override
  String get logLabel => 'Log';

  @override
  String get noExercises => 'No exercises yet.';

  @override
  String get exercisePin => 'Pin exercise';

  @override
  String get exerciseUnpin => 'Unpin exercise';

  @override
  String get exerciseDelete => 'Delete exercise';

  @override
  String get medReadHeader => 'Read a medicine box with AI';

  @override
  String get medReadBody =>
      'Take a photo of a medicine or supplement box and the app reads what is printed on it: the name, the written dose and the warnings. An automatic reading can be wrong; the leaflet or a pharmacist has the final word.';

  @override
  String get analyzingMed => 'Reading the medicine box...';

  @override
  String get analyzeMed => 'Read the medicine box 💊';

  @override
  String get medsHeader => 'Daily medicine and supplement times';

  @override
  String get noMeds => 'No medicines or supplements yet. Tap + to add one.';

  @override
  String get medDelete => 'Delete medicine';

  @override
  String get careHeader => 'Daily skin and hair routine products';

  @override
  String get noCare => 'No products yet. Tap + to add one.';

  @override
  String get careDelete => 'Delete product';

  @override
  String get workoutLogTitle => 'Log today\'s workout';

  @override
  String get logAction => 'Log';

  @override
  String get setsField => 'Sets';

  @override
  String setsError(int max) {
    return 'Enter a number from 1 to $max';
  }

  @override
  String get repsField => 'Reps';

  @override
  String get weightField => 'Weight (optional)';

  @override
  String get weightHint => 'Example: 40 kg';

  @override
  String get noteOptionalField => 'Note (optional)';

  @override
  String get workoutLogged => 'Today\'s workout was logged';

  @override
  String get exerciseDeleteAsk => 'Delete the exercise?';

  @override
  String exerciseDeleteBody(String name) {
    return '\"$name\" and its photo will be deleted. Your past workout log stays.';
  }

  @override
  String get deleteAction => 'Delete';

  @override
  String get exerciseEdit => 'Edit exercise';

  @override
  String setsRepsLine(String value) {
    return 'Sets and reps: $value';
  }

  @override
  String get logToday => 'Log today';

  @override
  String exerciseLogOf(String name) {
    return 'Log of \"$name\"';
  }

  @override
  String get latestLogs => 'Latest entries';

  @override
  String get stepsHeader => 'Steps';

  @override
  String get notesHeader => 'Notes';

  @override
  String get exerciseNameField => 'Exercise name';

  @override
  String get musclesField => 'Target muscles';

  @override
  String get setsLess => 'Fewer sets';

  @override
  String get setsMore => 'More sets';

  @override
  String get repsHint => '10 or 8-12';

  @override
  String get addStep => 'Add step';

  @override
  String get notesOptional => 'Notes (optional)';

  @override
  String get addImage => 'Add photo';

  @override
  String get changeImage => 'Change photo';

  @override
  String get removeImage => 'Remove photo';

  @override
  String get deleteStep => 'Delete step';

  @override
  String get workoutLogDefaultTitle => 'Workout log';

  @override
  String get workoutEntryDeleted => 'Entry deleted';

  @override
  String get noWorkouts =>
      'No workouts logged yet. Open an exercise and tap \"Log today\".';

  @override
  String get exerciseFallbackName => 'Exercise';

  @override
  String get workoutEntryDelete => 'Delete entry';

  @override
  String get imageSourceTitle => 'Choose a photo source';

  @override
  String get camera => 'Camera';

  @override
  String get gallery => 'Gallery';

  @override
  String draftExercise(String name) {
    return 'Exercise: $name';
  }

  @override
  String draftMuscles(String muscles) {
    return 'Muscles: $muscles';
  }

  @override
  String get draftSteps => 'Steps:';

  @override
  String draftNotes(String notes) {
    return 'Notes: $notes';
  }

  @override
  String get meditationGammaNotice =>
      'A gamma tone to listen to while meditating, at a low volume. Do not use it while driving or operating machinery. Anyone with epilepsy or an implanted medical device should ask a doctor before using it. The binaural kind needs headphones.';

  @override
  String get meditationActiveNotice =>
      'Move gently, in a roomy and safe place, and stop if you feel dizzy or any pain. Anyone with a heart condition, a pregnancy or an injury should ask a doctor before this session.';

  @override
  String get meditationAiVoiceNotice => 'The guide voice is generated by AI.';

  @override
  String get noticeBeforeStart => 'Before you start';

  @override
  String get understoodStart => 'Got it, start';

  @override
  String get meditationLoadFailed =>
      'Could not open the meditation sessions. Try again';

  @override
  String meditationWeekMinutes(int count) {
    return 'Meditation minutes in the last 7 days: $count';
  }

  @override
  String get meditationScreenOffTip =>
      'Sound keeps playing with the screen off, and you can stop it from the notification.';

  @override
  String get withSubscription => 'Subscription';

  @override
  String get toneNone => 'No tone';

  @override
  String get toneBinauralShort => 'Binaural gamma (headphones)';

  @override
  String get toneIsochronicShort => 'Pulsed gamma';

  @override
  String get toneBinaural => 'Binaural (headphones)';

  @override
  String get toneIsochronic => 'Pulsed (no headphones)';

  @override
  String get durationLabel => 'Duration';

  @override
  String get backgroundSound => 'Background sound';

  @override
  String get startSession => 'Start session';

  @override
  String minutesShort(int count) {
    return '$count min';
  }

  @override
  String minutesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minutes',
      one: '1 minute',
    );
    return '$_temp0';
  }

  @override
  String minutesRange(int from, int to) {
    return '$from to $to minutes';
  }

  @override
  String get soundFailed => 'The sound could not start. Please try again.';

  @override
  String get endSessionAsk => 'End the session?';

  @override
  String get endSessionBody =>
      'The minutes so far are saved if they add up to one minute or more.';

  @override
  String get continueSession => 'Keep going';

  @override
  String get endAction => 'End';

  @override
  String phaseOf(int current, int total) {
    return 'Stage $current of $total';
  }

  @override
  String get timeLeft => 'Time left';

  @override
  String get gammaLevel => 'Gamma tone level';

  @override
  String get pauseAction => 'Pause';

  @override
  String get resumeAction => 'Resume';

  @override
  String get sessionFinished => 'Session complete';

  @override
  String sessionMinutes(int count) {
    return 'Minutes in this session: $count';
  }

  @override
  String get sessionUnderMinute =>
      'Sessions shorter than a minute are not saved in the log.';

  @override
  String get meditationChannelName => 'Meditation sessions';
}
