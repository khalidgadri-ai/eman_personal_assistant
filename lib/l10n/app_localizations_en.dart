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

  @override
  String get kitchenTitle => '🥗 Kitchen, pantry & laundry';

  @override
  String get tabRecipes => 'Recipes';

  @override
  String get tabPantry => 'Pantry & supplies';

  @override
  String get tabShopping => 'Shopping';

  @override
  String get tabLaundry => 'Laundry';

  @override
  String get addRecipe => 'Add recipe';

  @override
  String get addPantryItem => 'Add item';

  @override
  String get addShoppingItem => 'Add to shopping';

  @override
  String get addLaundry => 'Add laundry day';

  @override
  String get recipeBreakfast => 'Breakfast';

  @override
  String get recipeLunch => 'Lunch';

  @override
  String get recipeDinner => 'Dinner';

  @override
  String get recipeSnack => 'Snack';

  @override
  String get recipeDessert => 'Dessert';

  @override
  String get recipeAi => 'AI';

  @override
  String get otherCategory => 'Other';

  @override
  String get pantryOils => 'Oils & spices';

  @override
  String get pantryGrains => 'Grains & legumes';

  @override
  String get pantryProduce => 'Fruit & vegetables';

  @override
  String get pantryDairyMeat => 'Dairy & meat';

  @override
  String get pantryNuts => 'Nuts';

  @override
  String get pantryCleaning => 'Cleaning supplies';

  @override
  String get daySat => 'Saturday';

  @override
  String get daySun => 'Sunday';

  @override
  String get dayMon => 'Monday';

  @override
  String get dayTue => 'Tuesday';

  @override
  String get dayWed => 'Wednesday';

  @override
  String get dayThu => 'Thursday';

  @override
  String get dayFri => 'Friday';

  @override
  String get sourceOutOfStock => 'Ran out in the pantry';

  @override
  String get recipeNeedIngredients => '⚠️ Please write the ingredients first';

  @override
  String get recipeSuggested => 'Suggested recipe 🍽️';

  @override
  String get saveToRecipes => 'Save to recipes';

  @override
  String aiRecipeFallbackTitle(String first) {
    return 'Smart recipe: $first';
  }

  @override
  String get recipeAdded => '✅ Recipe added';

  @override
  String recipeDeleted(String title) {
    return 'Deleted \"$title\"';
  }

  @override
  String get recipesHeader => 'Your recipes and their ingredients';

  @override
  String get recipesEmpty =>
      'No recipes yet. Tap + to add one, or let the AI suggest one.';

  @override
  String servingsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count servings',
      one: '1 serving',
    );
    return '$_temp0';
  }

  @override
  String ingredientsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ingredients',
      one: '1 ingredient',
    );
    return '$_temp0';
  }

  @override
  String stepsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count steps',
      one: '1 step',
    );
    return '$_temp0';
  }

  @override
  String get recipePin => 'Pin recipe';

  @override
  String get recipeUnpin => 'Unpin recipe';

  @override
  String get recipeDelete => 'Delete recipe';

  @override
  String ingredientsLine(String text) {
    return 'Ingredients: $text';
  }

  @override
  String get aiRecipeTitle => '🧑‍🍳 Create a recipe with AI';

  @override
  String get aiRecipePrompt =>
      'Write the ingredients you have (separated by commas):';

  @override
  String get aiRecipeHint =>
      'Example: chicken, rice, tomatoes, onion, spices...';

  @override
  String get aiRecipeWorking => 'Creating the recipe...';

  @override
  String get aiRecipeSuggest => 'Suggest a recipe ✨';

  @override
  String get pantryAddTitle => 'Add a pantry item';

  @override
  String get itemField => 'Item';

  @override
  String get qtyOptionalField => 'Quantity (optional)';

  @override
  String get pantryQtyHint => 'Example: 2 litres';

  @override
  String get pantryEditTitle => 'Edit item';

  @override
  String itemDeleted(String name) {
    return 'Deleted \"$name\"';
  }

  @override
  String movedToShopping(String name) {
    return 'Moved \"$name\" to shopping';
  }

  @override
  String get pantryHeader => 'Kitchen stock and home supplies';

  @override
  String get pantryEmpty => 'The pantry is empty. Tap + to add the first item.';

  @override
  String get pantrySearchHint => 'Search the pantry and supplies';

  @override
  String get clearSearch => 'Clear search';

  @override
  String get filterAll => 'All';

  @override
  String get noSearchResults => 'Nothing matches the search.';

  @override
  String get pinnedSection => '📌 Pinned';

  @override
  String get qtyLess => 'Less';

  @override
  String get qtyMore => 'More';

  @override
  String get moreActions => 'More';

  @override
  String get editAction => 'Edit';

  @override
  String get pinAction => 'Pin';

  @override
  String get unpinAction => 'Unpin';

  @override
  String get outToShopping => 'Ran out: to shopping';

  @override
  String get shoppingAddTitle => 'Add a shopping item';

  @override
  String get shoppingItemField => 'Item';

  @override
  String get shoppingQtyHint => 'Example: 2 kg';

  @override
  String get shoppingEditTitle => 'Edit item';

  @override
  String get shoppingHeader => 'Shopping list';

  @override
  String get shoppingEmpty =>
      'The shopping list is empty. Tap + to add an item, or add a recipe\'s ingredients from its page.';

  @override
  String movedToPantry(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items moved to the pantry',
      one: '1 item moved to the pantry',
    );
    return '$_temp0';
  }

  @override
  String get moveBoughtToPantry => 'Move bought items to the pantry';

  @override
  String get clearBought => 'Clear bought items';

  @override
  String shoppingFrom(String source) {
    return 'From: $source';
  }

  @override
  String get shoppingDelete => 'Delete item';

  @override
  String get laundryAddTitle => 'Add a laundry day';

  @override
  String get dayField => 'Day';

  @override
  String get laundryTypeField => 'Laundry type';

  @override
  String get laundryTypeHint => 'Example: coloured clothes';

  @override
  String get instructionsOptional => 'Instructions (optional)';

  @override
  String get laundryEditTitle => 'Edit laundry day';

  @override
  String laundryDeleted(String type) {
    return 'Deleted \"$type\"';
  }

  @override
  String get laundryHeader => 'Weekly laundry and fabric care';

  @override
  String get laundryEmpty => 'No laundry days yet. Tap + to add one.';

  @override
  String instructionsLine(String text) {
    return 'Instructions: $text';
  }

  @override
  String get laundryDelete => 'Delete';

  @override
  String get recipeDeleteAsk => 'Delete the recipe?';

  @override
  String recipeDeleteBody(String title) {
    return '\"$title\" will be deleted from your recipes.';
  }

  @override
  String addedToShopping(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items added to shopping',
      one: '1 item added to shopping',
    );
    return '$_temp0';
  }

  @override
  String alreadyInList(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count were already on the list',
      one: '1 was already on the list',
    );
    return '$_temp0';
  }

  @override
  String get recipeEdit => 'Edit recipe';

  @override
  String get ingredientsHeader => 'Ingredients';

  @override
  String get noIngredients => 'No ingredients yet.';

  @override
  String get addIngredientsToShopping => 'Add the ingredients to shopping';

  @override
  String get prepSteps => 'Method';

  @override
  String servingsScaled(int servings, int original) {
    String _temp0 = intl.Intl.pluralLogic(
      servings,
      locale: localeName,
      other: '$servings servings',
      one: '1 serving',
    );
    return '$_temp0 (originally $original)';
  }

  @override
  String get servingsLess => 'Fewer servings';

  @override
  String get servingsMore => 'More servings';

  @override
  String get whatToShopping => 'What do you want to add to shopping?';

  @override
  String get inPantry => 'In the pantry';

  @override
  String addCount(int count) {
    return 'Add ($count)';
  }

  @override
  String get ingredientNameRequired => 'The ingredient name is required';

  @override
  String get invalidAmount => 'Not a valid amount';

  @override
  String get mealNameField => 'Dish name';

  @override
  String get servingsField => 'Servings';

  @override
  String get freeTextIngredients => 'Ingredients written as free text:';

  @override
  String get convertIngredients => 'Turn into a structured list';

  @override
  String get addIngredient => 'Add ingredient';

  @override
  String get ingredientField => 'Ingredient';

  @override
  String get amountField => 'Amount';

  @override
  String get unitField => 'Unit';

  @override
  String get unitHint => 'cup';

  @override
  String get deleteIngredient => 'Delete ingredient';

  @override
  String stepNumber(int number) {
    return 'Step $number';
  }

  @override
  String get recipeTypeField => 'Type';

  @override
  String get expenseFood => 'Food';

  @override
  String get expenseTransport => 'Transport';

  @override
  String get expenseEntertainment => 'Entertainment';

  @override
  String get expenseBills => 'Bills';

  @override
  String get expenseShopping => 'Shopping';

  @override
  String get percentSign => '%';

  @override
  String get listSeparator => ', ';

  @override
  String get planSaved => 'Budget plan saved';

  @override
  String get limitsSaved => 'Limits saved. Change them from \"Edit plan\"';

  @override
  String get budgetTitle => '💰 Wallet & budget';

  @override
  String get monthlyExpenses => 'My monthly expenses';

  @override
  String get budgetOpenFailed => 'Couldn\'t open the budget data';

  @override
  String get setupBudgetTitle => 'Set up your budget';

  @override
  String get setupBudgetBody =>
      'Enter your monthly income, your payday and your fixed expenses, and we\'ll work out what is left and how much you can spend each day. All your data stays on your device, encrypted.';

  @override
  String get setupBudgetButton => 'Set up budget';

  @override
  String get currentCycleBudget => 'This cycle\'s budget';

  @override
  String daysLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days left',
      one: '1 day left',
    );
    return '$_temp0';
  }

  @override
  String cycleRange(String start, String end) {
    return '$start to $end';
  }

  @override
  String get remainingLabel => 'Remaining';

  @override
  String spentPercent(int percent) {
    return 'Spent $percent% of the available amount';
  }

  @override
  String get incomeLabel => 'Income';

  @override
  String get fixedExpenses => 'Fixed expenses';

  @override
  String get savingsLabel => 'Savings';

  @override
  String get availableToSpend => 'Available to spend';

  @override
  String get spentSoFar => 'Spent so far';

  @override
  String get dailyAvailable => 'Available per day';

  @override
  String overcommittedWarning(String amount) {
    return 'Fixed expenses and savings ($amount) are more than your income. Adjust the plan.';
  }

  @override
  String overspentWarning(String amount) {
    return 'You went over the available amount this cycle by $amount.';
  }

  @override
  String nearEndWarning(int percent, String amount) {
    return 'Close to the end of the available amount: $percent% spent, $amount left.';
  }

  @override
  String get editPlan => 'Edit plan';

  @override
  String get suggestBudget => 'Suggest a budget';

  @override
  String paidCount(int paid, int total) {
    return '$paid of $total paid';
  }

  @override
  String dueDayLine(int day) {
    return 'Day $day of the month';
  }

  @override
  String dueDayAmount(int day, String amount) {
    return 'Day $day of the month · $amount';
  }

  @override
  String get byCategory => 'Spending by category';

  @override
  String get noCategorySpending =>
      'No spending recorded this cycle and no category limits. You can get suggested limits from \"Suggest a budget\".';

  @override
  String overLimit(String category, String amount) {
    return 'Over the \"$category\" limit by $amount.';
  }

  @override
  String nearLimit(String category, int percent) {
    return 'Close to the \"$category\" limit: $percent% spent.';
  }

  @override
  String get recentExpenses => 'Recent expenses';

  @override
  String get noRecentExpenses => 'No expenses recorded this cycle yet.';

  @override
  String get recordExpense => 'Add expense';

  @override
  String get allExpenses => 'All expenses';

  @override
  String get invalidAmountPositive => 'Enter a valid amount greater than zero';

  @override
  String get percentRange => 'Enter a percentage from 0 to 100';

  @override
  String get savingsAmountInvalid => 'Enter a valid amount (or leave it empty)';

  @override
  String get checkRedFields =>
      'Check the fields marked in red, then save again';

  @override
  String get planSaveFailed => 'Couldn\'t save the plan. Please try again';

  @override
  String get unsavedChanges => 'Unsaved changes';

  @override
  String get unsavedPlanBody =>
      'The changes to the budget plan aren\'t saved. Save them before leaving?';

  @override
  String get keepEditing => 'Keep editing';

  @override
  String get leaveWithoutSaving => 'Leave without saving';

  @override
  String get savePlan => 'Save plan';

  @override
  String get newFixedExpense => 'New fixed expense';

  @override
  String get editFixedExpense => 'Edit fixed expense';

  @override
  String get expenseName => 'Expense name';

  @override
  String get expenseNameHint => 'e.g. Rent';

  @override
  String get amountLabel => 'Amount';

  @override
  String get dueDayField => 'Due day (1 to 31)';

  @override
  String get dueDayInvalid => 'Enter a day from 1 to 31';

  @override
  String get budgetPlanTitle => 'Budget plan';

  @override
  String get incomeAndCycle => 'Income & cycle';

  @override
  String get monthlyIncome => 'Monthly income';

  @override
  String get paydayField => 'Payday';

  @override
  String get paydayHelper => 'The budget cycle starts on this day every month';

  @override
  String get currencyField => 'Currency';

  @override
  String get fixedEmptyHint =>
      'Add what repeats every month: rent, installments, subscriptions, bills.';

  @override
  String deleteNamed(String name) {
    return 'Delete $name';
  }

  @override
  String totalLine(String amount) {
    return 'Total: $amount';
  }

  @override
  String get addFixedExpense => 'Add fixed expense';

  @override
  String get monthlySavingsGoal => 'Monthly savings goal';

  @override
  String get savingsModeAmount => 'Amount';

  @override
  String get savingsModePercent => 'Share of income';

  @override
  String get savingsPercentField => 'Savings rate';

  @override
  String get savingsAmountField => 'Savings amount';

  @override
  String equalsMonthly(String amount) {
    return 'That is $amount a month';
  }

  @override
  String get categoryLimitsOptional => 'Category limits (optional)';

  @override
  String get categoryLimitsHint =>
      'A spending cap for each category during the cycle. Leave it empty for no limit.';

  @override
  String categoryLimitField(String category) {
    return '$category limit';
  }

  @override
  String planOvercommitted(String committed, String income) {
    return 'Fixed expenses and savings ($committed) are more than the income ($income). Nothing will be left to spend.';
  }

  @override
  String limitsOverAvailable(String limits, String available) {
    return 'The category limits ($limits) add up to more than is available to spend ($available).';
  }

  @override
  String get planSummary => 'Plan summary';

  @override
  String get limitsSaveFailed => 'Couldn\'t save the limits. Please try again';

  @override
  String get yourAiProvider => 'the AI provider you chose';

  @override
  String get sendFinancialData => 'Send your financial data?';

  @override
  String financialConsentBody(
    String provider,
    String income,
    String fixed,
    String savings,
    String available,
  ) {
    return 'Only these numbers will be sent to \"$provider\":\n• Monthly income: $income\n• Fixed expenses total: $fixed\n• Savings goal: $savings\n• Available to spend: $available\n\nThe names of your fixed expenses and your recorded expenses are not sent. What is sent is subject to this provider\'s policy. We ask every time, and nothing is sent before you agree.';
  }

  @override
  String get agreeAndSend => 'Agree and send this time';

  @override
  String aiSuggestionUnreadable(String reply) {
    return 'Couldn\'t read the suggestion as category limits. $reply';
  }

  @override
  String get saveAsLimits => 'Save as category limits';

  @override
  String get availableMonthly => 'Available to spend per month';

  @override
  String get noAvailableForLimits =>
      'Your plan has nothing available to spend right now, so no limits can be suggested. Adjust the income, fixed expenses or savings first.';

  @override
  String get localSuggestion => 'Local suggestion (offline)';

  @override
  String localRuleText(String rule) {
    return 'A simple rule splits the available amount like this: $rule. After saving, change any limit from \"Edit plan\".';
  }

  @override
  String get aiSuggestionOptional => 'AI suggestion (optional)';

  @override
  String get aiSuggestionNote =>
      'Sends your plan\'s numbers to the provider you chose; nothing is sent without your OK, every time.';

  @override
  String get askAiSuggestion => 'Ask the AI for a suggestion';

  @override
  String aiSuggestionOver(String amount) {
    return 'This suggestion adds up to $amount, more than is available to spend. Adjust it after saving.';
  }

  @override
  String expenseDeleted(String amount) {
    return 'Expense of $amount deleted';
  }

  @override
  String get noMonthExpenses => 'No expenses recorded this month';

  @override
  String get previousMonth => 'Previous month';

  @override
  String get nextMonth => 'Next month';

  @override
  String get totalSpending => 'Total spending';

  @override
  String get breakdownByCategory => 'Breakdown by category';

  @override
  String percentOfTotal(int percent) {
    return '$percent% of the total';
  }

  @override
  String get monthExpenses => 'This month\'s expenses';

  @override
  String get deleteExpense => 'Delete expense';

  @override
  String get recordExpenseTitle => 'Add expense';

  @override
  String get editExpenseTitle => 'Edit expense';

  @override
  String get expenseCategoryField => 'Category';

  @override
  String dateLine(String date) {
    return 'Date: $date';
  }

  @override
  String get changeDate => 'Change date';

  @override
  String get aiMissingKey =>
      'Set up the AI provider and its key in Settings first.';

  @override
  String get aiInvalidKey =>
      'The key is invalid or expired. Update it in the AI provider settings, then try again.';

  @override
  String get aiModelNotFound =>
      'The chosen model doesn\'t exist or was shut down. Refresh the model list in Settings and pick another model.';

  @override
  String get aiRateLimited =>
      'The provider\'s usage limit or credit has been reached. Wait a little or check your account with them, then try again.';

  @override
  String get aiBusy =>
      'The provider\'s servers are busy right now; the problem is on their side, not in the app. Try again shortly, or choose a lighter model in the AI settings (such as models with lite, mini or haiku in their name).';

  @override
  String get aiNetwork =>
      'Couldn\'t connect to the internet. Check your connection, then try again.';

  @override
  String get aiTimeout =>
      'The provider didn\'t reply in time; its servers are probably busy. Try again, or choose a lighter, faster model in the AI settings (such as models with lite, mini or haiku in their name).';

  @override
  String get aiBadRequest =>
      'The provider refused the request. The model may not support this kind of request, so try another model.';

  @override
  String get aiImageUnsupported =>
      'The chosen model doesn\'t support images. Choose a model that does in the AI provider settings.';

  @override
  String get aiBlocked =>
      'Couldn\'t produce a reply to this request. Try wording it differently.';

  @override
  String get aiUnsupportedLocation =>
      'The provider\'s service isn\'t available in your country right now.';

  @override
  String get aiInsecureUrl =>
      'The provider address must start with https:// and be a valid address.';

  @override
  String get aiInvalidModelName =>
      'The model name isn\'t valid. Only letters, digits and - _ . : / @ are allowed.';

  @override
  String get aiEmptyReply => 'No reply was received from the AI assistant.';

  @override
  String get aiUnknown =>
      'Something unexpected went wrong with the AI assistant. Please try again shortly.';

  @override
  String get aiEmptyImageReply => 'I couldn\'t analyse the image.';

  @override
  String get aiNoKeySet => 'No key set';

  @override
  String get customProviderLabel => 'Custom (OpenAI-compatible)';

  @override
  String get providerConnectionOk =>
      'The connection works and the model replies.';

  @override
  String get providerImageRejected =>
      'The model didn\'t accept the image, so it is marked as not supporting images.';

  @override
  String get providerImagesOk => 'The model supports images.';

  @override
  String get providerNoModels => 'The provider returned no models.';

  @override
  String get providerSaved => 'AI settings saved.';

  @override
  String get providerKeyDeleted => 'The key was deleted from this device.';

  @override
  String get linkCopied => 'Link copied';

  @override
  String get providerIntro =>
      'Choose the provider you want to use and enter your own key from it.\nThe key is kept only on your device in secure storage and is sent only to the provider you choose, with your requests, without any server in between. What you send is subject to that provider\'s privacy policy.';

  @override
  String get providerField => 'Provider';

  @override
  String get providerUrlField => 'Provider address';

  @override
  String get modelNameField => 'Model name';

  @override
  String get modelNameHint => 'Type the name or fetch it from the provider';

  @override
  String get fetchModels => 'Fetch available models';

  @override
  String get keyField => 'Key';

  @override
  String get copyLink => 'Copy link';

  @override
  String get pasteKeyHint => 'Paste your key here';

  @override
  String savedKeyHint(String preview) {
    return 'Saved: $preview (leave empty to keep it)';
  }

  @override
  String get showKey => 'Show key';

  @override
  String get hideKey => 'Hide key';

  @override
  String get deleteSavedKey => 'Delete the saved key';

  @override
  String get modelImagesQuestion => 'Does the model support images?';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get unknownSupport => 'Unknown';

  @override
  String get testImagesAuto => 'Test image support automatically';

  @override
  String get testConnection => 'Test connection';

  @override
  String get saveAndActivate => 'Save and activate';

  @override
  String searchModels(int count) {
    return 'Search $count models';
  }

  @override
  String get assistantActivated =>
      '✅ The provider is active! You can now use all the AI features.';

  @override
  String get assistantTitle => '🤖 AI assistant';

  @override
  String get assistantProviderSetup => 'Set up the AI provider';

  @override
  String get assistantStarting => 'Starting the AI assistant...';

  @override
  String get assistantThinking => 'Thinking...';

  @override
  String get assistantHint => 'Ask the assistant or request a suggestion...';

  @override
  String get send => 'Send';

  @override
  String get coachDomainBeliefs => 'Beliefs';

  @override
  String get coachDomainEmotions => 'Emotions';

  @override
  String get coachDomainGoals => 'Goals & planning';

  @override
  String get coachDomainOrganization => 'Organization & balance';

  @override
  String get coachDomainSkills => 'Skills & techniques';

  @override
  String get coachHintBudget =>
      'We noticed a pattern in your spending this week';

  @override
  String get coachHintUsage =>
      'This question relates to how your time was spent today';

  @override
  String get coachHintReflection =>
      'We noticed an idea repeating in your recent answers';

  @override
  String coachQuotaRemaining(int remaining, int limit) {
    return '$remaining of $limit free left this month';
  }

  @override
  String coachQuotaUsedUp(String date) {
    return 'The free uses for this month are used up; they renew on $date';
  }

  @override
  String coachQuotaRenews(String date) {
    return 'Your free uses renew on $date';
  }

  @override
  String coachQuotaOffer(int limit) {
    String _temp0 = intl.Intl.pluralLogic(
      limit,
      locale: localeName,
      other: 'You get $limit free follow-up questions every month.',
      one: 'You get 1 free follow-up question every month.',
    );
    return '$_temp0 A subscription makes them unlimited.';
  }

  @override
  String get crisisResponse =>
      'If you are going through a real crisis or thinking about harming yourself, please contact a specialist helpline or the nearest emergency service right away. This app is only a self-reflection tool, not a substitute for a licensed therapist.';

  @override
  String get crisisSaudiNote => 'In Saudi Arabia (official government lines):';

  @override
  String get crisisLocalEmergency =>
      'If there is immediate danger, call your country\'s emergency number now, or go to the nearest emergency department.';

  @override
  String get crisisFinderLabel => 'Find a free helpline in your country';

  @override
  String get crisisImportant => 'Important';

  @override
  String get gotIt => 'Got it';

  @override
  String get coachHistory => 'Coach session history';

  @override
  String get coachDisclaimer =>
      'This is a self-reflection tool, not a substitute for a licensed therapist.';

  @override
  String get coachAnswerHint => 'Your answer (optional)...';

  @override
  String get coachDeepen => 'Go deeper';

  @override
  String get coachSessionDeleted => 'Session deleted';

  @override
  String get coachNoSessions => 'No saved sessions yet';

  @override
  String get coachDeleteSession => 'Delete session';

  @override
  String get payPending =>
      'The payment is being processed by Google Play; the subscription will turn on by itself once it completes.';

  @override
  String get payError =>
      'The purchase couldn\'t be completed. Please try again.';

  @override
  String get payOpenFailed =>
      'The purchase window couldn\'t be opened. Please try again.';

  @override
  String get payNoSubscription =>
      'There is no active subscription on this Google Play account.';

  @override
  String get payTitle => 'Monthly subscription';

  @override
  String get payHeadingMeditation => 'All meditation sessions';

  @override
  String get payHeadingCoach => 'Go deeper in your reflection';

  @override
  String get payBenefitDeepen =>
      'Unlimited \"Go deeper\": a follow-up question built on your own answer, with no advice and no judgement.';

  @override
  String get payBenefitMeditation =>
      'All guided and active meditation sessions: body scan, present moment, and move, then be still.';

  @override
  String get payBenefitControl =>
      'You decide when to use them; nothing happens automatically.';

  @override
  String get payFreeNote =>
      'The local questions, your session history and budget tracking stay completely free, as do the wheel of life and naming feelings, the silent timer, gamma waves and the calm breathing session.\nThe follow-up question works with the AI provider key you set in Settings.';

  @override
  String get payUnavailable => 'Subscription not available right now';

  @override
  String paySubscribe(String price) {
    return 'Subscribe now — $price a month';
  }

  @override
  String get payAndroidOnly =>
      'The subscription is available in the Android version installed from Google Play.';

  @override
  String get payRestore => 'Restore purchases';

  @override
  String get payRenewal =>
      'The subscription renews automatically every month at the same price until you cancel. You can cancel any time in Google Play → Payments & subscriptions → Subscriptions.';

  @override
  String hoursShort(int h) {
    return '$h h';
  }

  @override
  String hoursMinutesShort(int h, int m) {
    return '$h h $m min';
  }

  @override
  String get refresh => 'Refresh';

  @override
  String get usageAndroidOnly =>
      'This feature works on Android devices only, because it relies on the system\'s \"Usage access\" permission.';

  @override
  String get usageReadFailed =>
      'The usage data couldn\'t be read from the system. Please try again later.';

  @override
  String get usageToday => 'Your time in social apps today';

  @override
  String get usageNone => 'No use of these apps was recorded today.';

  @override
  String get usageBreakdown => 'Breakdown by app (minutes)';

  @override
  String usageShare(int percent) {
    return '$percent% of today\'s social time';
  }

  @override
  String get usageSource =>
      'From midnight until now, as recorded by Android. The numbers stay on your device only.';

  @override
  String get usageHowTitle => 'How does this feature work?';

  @override
  String usageHowBody(String apps) {
    return 'We read from Android how many minutes you spent today in: $apps. One number per app, nothing more.\nWe don\'t read your messages, your notifications or any content inside these apps, and we don\'t ask you to sign in to any account.\nThe numbers stay on your device only and are never sent anywhere. You can turn the permission off at any time in the same settings.';
  }

  @override
  String get usageEnableTitle => 'To turn it on:';

  @override
  String get usageStep1 => 'Tap \"Open settings\" below.';

  @override
  String usageStep2(String app) {
    return 'Find the app \"$app\" in the list.';
  }

  @override
  String get usageStep3 =>
      'Turn on the option that allows usage access (the name may differ a little depending on the device).';

  @override
  String get usageStep4 =>
      'Come back to the app, and today\'s numbers will show by themselves.';

  @override
  String get openSettings => 'Open settings';

  @override
  String get notNow => 'Not now';

  @override
  String backupWeakPassword(int min) {
    return 'The password is too short: at least $min characters are needed.';
  }

  @override
  String get backupNotABackup => 'This file isn\'t a backup from this app.';

  @override
  String get backupUnsupportedVersion =>
      'This backup is newer than this version of the app. Please update the app, then try again.';

  @override
  String get backupWrongPassword =>
      'The password is wrong, or the file is damaged.';

  @override
  String get backupRestoreFailed =>
      'The restore failed, and the data was put back as it was.';

  @override
  String get backupRestoreFailedUnsafe =>
      'The restore failed and some data may be missing. Please try again with the same file.';

  @override
  String get backupSaveDialog => 'Save the backup';

  @override
  String get backupPickDialog => 'Choose the backup file';

  @override
  String get contactSubject => 'About the app';

  @override
  String get assistantHello => 'Welcome!';

  @override
  String assistantHelloName(String name) {
    return 'Welcome, $name!';
  }

  @override
  String get assistantGreetingBody =>
      'I\'m your AI assistant. How can I help you organise your day, suggest meals, or review your exercises?\n\n🔑 To start, set up the AI provider and your own key from the key icon at the top.';

  @override
  String get coachToolsTitle => 'Coach tools';

  @override
  String get coachToolsIntro =>
      'Short step-by-step exercises; the results are saved on this device so you can compare them with earlier ones.';

  @override
  String get coachToolsEntry => 'Coach tools: wheel of life, feelings and more';

  @override
  String get wheelTitle => 'Wheel of life';

  @override
  String get wheelSubtitle =>
      'Rate the eight areas of your life and pick one small step.';

  @override
  String get emotionTitle => 'Name the feeling';

  @override
  String get emotionSubtitle =>
      'Name what you feel and follow it over the days.';

  @override
  String get wheelHealth => 'Health';

  @override
  String get wheelWork => 'Work or study';

  @override
  String get wheelMoney => 'Money';

  @override
  String get wheelFamily => 'Family';

  @override
  String get wheelRelationships => 'Friends & relationships';

  @override
  String get wheelGrowth => 'Personal growth';

  @override
  String get wheelSpirit => 'Spiritual life';

  @override
  String get wheelFun => 'Fun & rest';

  @override
  String get wheelIntro =>
      'Rate how satisfied you are with each area from 0 to 10, then choose one area to work on.';

  @override
  String get wheelNow => 'Now';

  @override
  String wheelLastTime(String date) {
    return 'Last time ($date)';
  }

  @override
  String wheelWas(int score) {
    return 'was $score';
  }

  @override
  String get wheelFocus => 'Focus area';

  @override
  String wheelQ1(String area, int score) {
    return 'What keeps \"$area\" at $score and not lower?';
  }

  @override
  String wheelQ2(String area, int target) {
    return 'If \"$area\" were at $target, what is the first thing that would change in your day?';
  }

  @override
  String wheelQ2Keep(String area) {
    return 'What helps keep \"$area\" at this level?';
  }

  @override
  String get wheelQ3 => 'What is standing in the way right now?';

  @override
  String get wheelQ4 =>
      'What is one small step that would bring this area one point closer this week?';

  @override
  String get answerOptional => 'Answer (optional)';

  @override
  String get stepToTask => 'Add the step to my tasks';

  @override
  String stepReminder(String time) {
    return 'Reminder: $time';
  }

  @override
  String get stepNoReminder => 'No reminder';

  @override
  String get stepSetReminder => 'Set a reminder';

  @override
  String get wheelSave => 'Save the wheel';

  @override
  String get wheelSaved => 'Wheel of life saved.';

  @override
  String get wheelSavedWithTask =>
      'Wheel of life saved, and the step was added to your tasks.';

  @override
  String get emotionIntro =>
      'Naming a feeling precisely is a first step to understanding it. There are no right or wrong answers.';

  @override
  String get emotionWhich => 'Which feeling is closest right now?';

  @override
  String get emotionWord => 'A more precise word (optional)';

  @override
  String emotionIntensity(int value) {
    return 'Intensity now: $value out of 10';
  }

  @override
  String get emotionWhere => 'Where does this feeling show up in the body?';

  @override
  String get emotionTrigger => 'What set it off? (optional)';

  @override
  String get emotionNeed => 'What does this feeling need right now?';

  @override
  String get emotionPickFirst => 'Choose the feeling first';

  @override
  String get emotionSaved => 'Saved to your feelings log.';

  @override
  String get emotionStrong =>
      'The feeling is strong right now. If you like, the \"Calm breathing\" session in the Meditation tab gives you a few minutes of slow breathing.';

  @override
  String get openMeditation => 'Open meditation';

  @override
  String get emotionLog => 'Feelings log';

  @override
  String get emotionLogEmpty => 'No feelings logged yet.';

  @override
  String emotionMostFrequent(String feeling) {
    return 'Most frequent in the last 30 days: $feeling';
  }

  @override
  String emotionLine(String feeling, int value) {
    return '$feeling · $value/10';
  }

  @override
  String get toolRecordDeleted => 'Entry deleted';

  @override
  String get deleteEntry => 'Delete entry';

  @override
  String get feelingHappy => 'Happy';

  @override
  String get feelingCalm => 'Calm';

  @override
  String get feelingGrateful => 'Grateful';

  @override
  String get feelingHopeful => 'Hopeful';

  @override
  String get feelingProud => 'Proud';

  @override
  String get feelingTired => 'Tired';

  @override
  String get feelingAnxious => 'Anxious';

  @override
  String get feelingStressed => 'Stressed';

  @override
  String get feelingSad => 'Sad';

  @override
  String get feelingLonely => 'Lonely';

  @override
  String get feelingAngry => 'Angry';

  @override
  String get feelingFrustrated => 'Frustrated';

  @override
  String get feelingAfraid => 'Afraid';

  @override
  String get feelingGuilty => 'Guilty';

  @override
  String get feelingBored => 'Bored';

  @override
  String get feelingOverwhelmed => 'Overwhelmed';

  @override
  String get bodyHead => 'Head';

  @override
  String get bodyThroat => 'Throat';

  @override
  String get bodyChest => 'Chest';

  @override
  String get bodyStomach => 'Stomach';

  @override
  String get bodyShoulders => 'Shoulders';

  @override
  String get bodyHands => 'Hands';

  @override
  String get bodyWhole => 'Whole body';

  @override
  String get bodyUnsure => 'Not sure';

  @override
  String get needRest => 'Rest';

  @override
  String get needTalk => 'Talking to someone';

  @override
  String get needMovement => 'Movement';

  @override
  String get needQuiet => 'Quiet time';

  @override
  String get needSolve => 'Sorting something out';

  @override
  String get needWrite => 'Writing about it';

  @override
  String get needNothing => 'Nothing right now';

  @override
  String get followUpTitle => 'Your last step';

  @override
  String followUpQuestion(String step) {
    return '\"$step\". How did it go?';
  }

  @override
  String get followUpDone => 'Done';

  @override
  String get followUpNotYet => 'Not yet';

  @override
  String get followUpNoted => 'Noted.';

  @override
  String get historyToolsSection => 'Coach tools';

  @override
  String historyWheelFocus(String area, int score) {
    return 'Focus: $area ($score)';
  }

  @override
  String historyStep(String step) {
    return 'Step: $step';
  }

  @override
  String get toolSaved => 'Saved.';

  @override
  String get toolSavedWithTask =>
      'Saved, and the step was added to your tasks.';

  @override
  String get writeSentenceFirst => 'Write the sentence first';

  @override
  String get beliefTitle => 'Belief check';

  @override
  String get beliefSubtitle =>
      'Examine a sentence that keeps repeating in your head, and find a more accurate version.';

  @override
  String get beliefIntro =>
      'A sentence that keeps repeating in your head about yourself or life, examined here as a thought, not a fact.';

  @override
  String get beliefSentence =>
      'What is the sentence? (for example: \"I never succeed at anything\")';

  @override
  String get beliefOrigin =>
      'When did this thought start, and where did it come from?';

  @override
  String get beliefFor => 'What supports it?';

  @override
  String get beliefAgainst => 'What goes against it, even if it is small?';

  @override
  String beliefStrengthBefore(int value) {
    return 'How true does it feel right now? $value out of 10';
  }

  @override
  String get beliefNew =>
      'A more accurate, fairer version of the same sentence:';

  @override
  String get beliefNewFor => 'What supports the new version?';

  @override
  String beliefStrengthAfter(int value) {
    return 'And how true does the old sentence feel after this? $value out of 10';
  }

  @override
  String get beliefStep => 'A small step that tests the new version this week:';

  @override
  String get innerVoiceTitle => 'Inner voice';

  @override
  String get innerVoiceSubtitle =>
      'Get to know the critical voice and reword what it says.';

  @override
  String get innerVoiceIntro =>
      'The critical inner voice has repeating patterns. Giving it a name makes it easier to notice when it speaks.';

  @override
  String get innerVoiceType => 'Which pattern is closest?';

  @override
  String get voiceWorrier => 'The worrier: expects the worst';

  @override
  String get voiceCritic => 'The critic: counts every mistake';

  @override
  String get voiceHopeless => 'The hopeless one: says there is no point';

  @override
  String get voicePerfectionist =>
      'The perfectionist: accepts nothing less than perfect';

  @override
  String get innerVoiceName => 'A name for it (optional)';

  @override
  String get innerVoiceSentence => 'Which sentence does it repeat most?';

  @override
  String get innerVoiceWhen => 'When does it usually get loudest?';

  @override
  String get innerVoiceFriend =>
      'If a friend said it about themselves, what would the reply be?';

  @override
  String get innerVoiceReframe =>
      'A new version of the same sentence, in a calmer and fairer voice:';

  @override
  String get innerVoiceStep => 'A small practical step for this week:';

  @override
  String get decisionTitle => 'Decide between two options';

  @override
  String get decisionSubtitle =>
      'Compare two options by what is gained and lost, then take a first step.';

  @override
  String get decisionIntro =>
      'The app gives no opinion: the questions here are for seeing both options clearly.';

  @override
  String get decisionOptionA => 'Option one';

  @override
  String get decisionOptionB => 'Option two';

  @override
  String decisionGain(String option) {
    return 'What is gained with \"$option\"?';
  }

  @override
  String decisionLoss(String option) {
    return 'What is lost with \"$option\"?';
  }

  @override
  String get decisionRegret =>
      'Five years from now, giving up which option might be regretted more?';

  @override
  String get decisionUnsure => 'Not clear yet';

  @override
  String get decisionExperiment =>
      'A small experiment to test one option before deciding:';

  @override
  String get decisionChosen => 'Chosen for now';

  @override
  String get decisionUndecided => 'Not decided yet';

  @override
  String get decisionStep => 'First step:';

  @override
  String get decisionNeedOptions => 'Write both options first';

  @override
  String get habitTitle => 'Change a habit';

  @override
  String get habitSubtitle =>
      'Understand what sets a habit off, with a daily step and 21 days of tracking.';

  @override
  String get habitIntro =>
      'A habit often starts from a place, a time, people or a feeling. Noticing them is the first step to changing it.';

  @override
  String get habitName => 'The habit to change:';

  @override
  String get habitWhere => 'Where does it usually happen?';

  @override
  String get habitWhen => 'When?';

  @override
  String get habitWho => 'With whom?';

  @override
  String get habitFeeling => 'After which feeling?';

  @override
  String get habitEnvironment =>
      'A small change to the place or tools that makes the change easier:';

  @override
  String get habitDailyStep => 'A small daily step:';

  @override
  String get habitDailyReminder => 'Daily reminder (optional)';

  @override
  String get habitStart => 'Start 21 days';

  @override
  String get habitNeedFields => 'Write the habit and the daily step first';

  @override
  String get habitStarted => 'The 21 days have started.';

  @override
  String habitDay(int day) {
    return 'Day $day of 21';
  }

  @override
  String habitDoneCount(int done) {
    return 'Days done: $done of 21';
  }

  @override
  String get habitCheckToday => 'Today\'s step is done';

  @override
  String get habitUncheckToday => 'Undo today\'s mark';

  @override
  String get habitStop => 'Stop tracking';

  @override
  String get habitStopAsk =>
      'Stop tracking this habit? What was recorded stays, and the daily reminder stops.';

  @override
  String habitFinished(int done) {
    return 'The 21 days are complete. Days done: $done.';
  }

  @override
  String get habitPast => 'Earlier habits';

  @override
  String get reminderHabitTitle => 'Today\'s step';

  @override
  String get payHeadingTools => 'Advanced coach tools';

  @override
  String get payBenefitTools =>
      'Four coach tools: belief check, inner voice, deciding between two options, and changing a habit.';
}
