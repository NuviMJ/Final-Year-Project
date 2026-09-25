// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTagline => 'Quality of life, guarded';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get sectionLanguage => 'Language';

  @override
  String get languageSubtitle => 'Medication names stay in English';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSinhala => 'සිංහල';

  @override
  String get latestResultTitle => 'Latest QoL result';

  @override
  String get qolScore => 'QoL score';

  @override
  String get noEffectsRing => 'No effects';

  @override
  String get noEffectsRingCaption => 'reported';

  @override
  String get takeFirstAssessment => 'Take your first assessment';

  @override
  String lastChecked(String when) {
    return 'Last checked $when';
  }

  @override
  String get relativeToday => 'today';

  @override
  String get relativeYesterday => 'yesterday';

  @override
  String relativeDaysAgo(int count) {
    return '$count days ago';
  }

  @override
  String relativeOnDate(String date) {
    return 'on $date';
  }

  @override
  String get startAssessment => 'Start assessment';

  @override
  String get historyTitle => 'History';

  @override
  String get historySubtitle => 'View past results';

  @override
  String get learnTitle => 'Learning tips';

  @override
  String get learnSubtitle => 'Improve your score';

  @override
  String get navHome => 'Home';

  @override
  String get navReminders => 'Reminders';

  @override
  String get navTrends => 'Trends';

  @override
  String get doNext => 'Do next';

  @override
  String get actionAssessTitle => 'Start an assessment';

  @override
  String get actionAssessSubtitle => 'Four short steps, about two minutes';

  @override
  String get actionHistoryTitle => 'Your history';

  @override
  String get historyNothingYet => 'Nothing recorded yet';

  @override
  String historyOnDevice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count assessments on this device',
      one: '1 assessment on this device',
    );
    return '$_temp0';
  }

  @override
  String get actionLearnTitle => 'Learn';

  @override
  String get actionLearnSubtitle =>
      'What your result means, and what affects it';

  @override
  String get latestResultLabel => 'LATEST RESULT';

  @override
  String riskLevel(String category) {
    return '$category risk';
  }

  @override
  String get noAssessmentsYet => 'No assessments yet';

  @override
  String get completeOnePrompt =>
      'Complete one to see your quality-of-life risk here.';

  @override
  String modelVersion(String version) {
    return 'Model $version';
  }

  @override
  String get assessmentAssessment => 'Assessment';

  @override
  String get assessmentNoMedicationSelected => 'No medication selected.';

  @override
  String get assessmentLoadingQuestions => 'Loading questions…';

  @override
  String get assessmentBack => 'Back';

  @override
  String get assessmentYears => 'years';

  @override
  String get assessmentHaveYouExperiencedAny =>
      'Have you experienced any side effects from your medication?';

  @override
  String get assessmentYes => 'Yes';

  @override
  String get assessmentNo => 'No';

  @override
  String get assessmentOhThatsGoodNews => 'Oh, that’s good news!';

  @override
  String get assessmentYouHaventExperiencedAny =>
      'You haven’t experienced any side effects. Tell us about your daily life next.';

  @override
  String get assessmentSelectTheSideEffects =>
      'Select the side effects you experienced';

  @override
  String get assessmentThatsTheMostYou =>
      'That’s the most you can report at once.';

  @override
  String get coreTryAgain => 'Try again';

  @override
  String get historyYourResultsAppearHere =>
      'Your results appear here once you complete an assessment. Everything stays on this device.';

  @override
  String get historyDeleteThisAssessment => 'Delete this assessment?';

  @override
  String get historyItWillBeRemoved =>
      'It will be removed from this device permanently.';

  @override
  String get historyKeep => 'Keep';

  @override
  String get historyDelete => 'Delete';

  @override
  String get historyPastResult => 'Past result';

  @override
  String get historyThatAssessmentIsNo =>
      'That assessment is no longer stored on this device.';

  @override
  String get historyRisk => 'RISK';

  @override
  String get historyProbabilities => 'Probabilities';

  @override
  String get historyWhatWasReported => 'What was reported';

  @override
  String get historyMedicines => 'Medicines';

  @override
  String get historySideEffects => 'Side effects';

  @override
  String get historyNoneReported => 'None reported';

  @override
  String get historyEverythingElse => 'Everything else';

  @override
  String get historyOnThisDayYou => 'On this day you had no side effects';

  @override
  String get learnShortReadsOnThe =>
      'Short reads on the things the model weighs most heavily, and what your results mean.';

  @override
  String get learnThatArticleIsNo => 'That article is no longer available.';

  @override
  String get medicationsSelectYourMedications => 'Select your medications';

  @override
  String get medicationsLoadingMedications => 'Loading medications…';

  @override
  String get medicationsChangeTheDose => 'Change the dose';

  @override
  String get medicationsHowMuchDoYou => 'How much do you take each day?';

  @override
  String get medicationsCancel => 'Cancel';

  @override
  String get predictionYourResult => 'Your result';

  @override
  String get predictionAnalyzingYourHealthInformation =>
      'Analyzing your health information…';

  @override
  String get predictionNoResultToShow => 'No result to show.';

  @override
  String get predictionGoodNews => 'Good news!';

  @override
  String get predictionYouHaventReportedAny =>
      'You haven’t reported any symptoms or side effects from your medication, which is a positive sign for your quality of life.';

  @override
  String get predictionKeepTakingCareOf =>
      'Keep taking care of yourself and keep following your healthcare provider’s advice. 💚';

  @override
  String get predictionStartAnotherAssessment => 'Start another assessment';

  @override
  String get predictionHowConfidentIsThis => 'How confident is this?';

  @override
  String get predictionYourSummary => 'Your summary';

  @override
  String get predictionYourMedicines => 'Your medicines';

  @override
  String get predictionSideEffectsYouReported => 'Side effects you reported';

  @override
  String get predictionTreatment => 'Treatment';

  @override
  String get predictionDailyLife => 'Daily life';

  @override
  String get predictionRiskByMedicine => 'Risk by medicine';

  @override
  String get predictionBarsShowTheChance =>
      'Bars show the chance of the High band for each medicine.';

  @override
  String get remindersMedication => 'Medication';

  @override
  String get remindersTime => 'Time';

  @override
  String get remindersRepeatOn => 'Repeat on';

  @override
  String get remindersSaveReminder => 'Save reminder';

  @override
  String get remindersAddReminder => 'Add reminder';

  @override
  String get remindersNotificationsAreTurnedOff =>
      'Notifications are turned off';

  @override
  String get remindersYourRemindersAreSaved =>
      'Your reminders are saved, but nothing will alert you until you allow notifications.';

  @override
  String get remindersAllowNotifications => 'Allow notifications';

  @override
  String get remindersRemindersCanBeSet =>
      'Reminders can be set up here, but only fire on an Android device.';

  @override
  String get remindersNoRemindersYet => 'No reminders yet';

  @override
  String get remindersAddOneToBe =>
      'Add one to be reminded when a medication is due.';

  @override
  String get settingsCopyMyData => 'Copy my data';

  @override
  String get settingsPutsEverythingStoredOn =>
      'Puts everything stored on this device on the clipboard';

  @override
  String get settingsDeleteEverything => 'Delete everything';

  @override
  String get settingsRemovesAllAssessmentsAnd =>
      'Removes all assessments and reminders permanently';

  @override
  String get settingsServer => 'Server';

  @override
  String get settingsModel => 'Model';

  @override
  String get settingsMedications => 'Medications';

  @override
  String get settingsApp => 'App';

  @override
  String get settingsPurpose => 'Purpose';

  @override
  String get settingsDeleteEverything2 => 'Delete everything?';

  @override
  String get settingsAllYourAssessmentsAnd =>
      'All your assessments and reminders will be removed from this device. This cannot be undone.';

  @override
  String get settingsKeepMyData => 'Keep my data';

  @override
  String get settingsEverythingHasBeenDeleted => 'Everything has been deleted';

  @override
  String get settingsYourDataStaysHere => 'Your data stays here';

  @override
  String get settingsAssessmentsAndRemindersAre =>
      'Assessments and reminders are stored only on this phone. There is no account, and nothing is uploaded or backed up anywhere.';

  @override
  String get settingsYourAnswersAreSent =>
      'Your answers are sent to the prediction server to be scored, and the result comes straight back. Nothing is kept there.';

  @override
  String get settingsAssessments => 'assessments';

  @override
  String get settingsReminders => 'reminders';

  @override
  String get startupConnecting => 'Connecting…';

  @override
  String get trendsYourTrends => 'Your trends';

  @override
  String get trendsProbabilityOfHighRisk => 'Probability of high risk';

  @override
  String get trendsTheModelsOwnLikelihood =>
      'The model\'s own likelihood that your quality of life is at high risk of decline, at each assessment.';

  @override
  String get trendsAssessmentsInThisPeriod => 'Assessments in this period';

  @override
  String get trendsATrendNeedsAt =>
      'A trend needs at least two assessments to compare. Complete another to see how your risk is moving.';
}
