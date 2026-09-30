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
  String get actionHistoryTitle => 'Your history';

  @override
  String get actionLearnTitle => 'Learn';

  @override
  String get noAssessmentsYet => 'No assessments yet';

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

  @override
  String get durationUnder3Months => 'Less than 3 months';

  @override
  String get duration3To6Months => '3 to 6 months';

  @override
  String get duration6To12Months => '6 to 12 months';

  @override
  String get duration1To2Years => '1 to 2 years';

  @override
  String get durationOver2Years => 'More than 2 years';

  @override
  String get onsetWithinDays => 'Within a few days';

  @override
  String get onset1To2Weeks => '1 to 2 weeks';

  @override
  String get onset3To4Weeks => '3 to 4 weeks';

  @override
  String get sleepVeryPoor => 'Very poor';

  @override
  String get sleepPoor => 'Poor';

  @override
  String get sleepFair => 'Fair';

  @override
  String get sleepGood => 'Good';

  @override
  String get sleepVeryGood => 'Very good';

  @override
  String get sleepExcellent => 'Excellent';

  @override
  String assessmentMedicineCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count medicines',
      one: '1 medicine',
    );
    return '$_temp0';
  }

  @override
  String assessmentStepOf(int step, int total) {
    return 'Step $step of $total';
  }

  @override
  String assessmentBetween(int low, int high) {
    return 'Between $low and $high';
  }

  @override
  String assessmentChooseUpTo(int max) {
    return 'Choose up to $max, and say how bad each one is.';
  }

  @override
  String assessmentShowAllEffects(int count) {
    return 'Show all effects ($count more)';
  }

  @override
  String historyNothingReportedOn(String date) {
    return 'Nothing was reported on $date, so no risk level was worked out for that day.';
  }

  @override
  String medicationsChooseEvery(int max) {
    return 'Choose every medicine you take regularly, up to $max. Check the daily dose shown and change it if it is not yours.';
  }

  @override
  String medicationsNoMatch(String query) {
    return 'No medication matches \"$query\".';
  }

  @override
  String medicationsMaxAtATime(int max) {
    return 'You can assess up to $max medicines at a time.';
  }

  @override
  String get predictionNotAHealthCheck =>
      'This reflects what you told us today and is not a health check.';

  @override
  String get medicalDisclaimer =>
      'QoLGuard does not diagnose medical conditions and does not replace advice from a healthcare professional. Always consult your doctor or pharmacist before changing any medication.';

  @override
  String remindersNext(String when) {
    return 'Next $when';
  }

  @override
  String remindersTodayAt(String time) {
    return 'today at $time';
  }

  @override
  String remindersTomorrowAt(String time) {
    return 'tomorrow at $time';
  }

  @override
  String remindersDayAt(String day, String time) {
    return '$day at $time';
  }

  @override
  String settingsCopiedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count assessments copied to the clipboard',
      one: '1 assessment copied to the clipboard',
    );
    return '$_temp0';
  }

  @override
  String startupLogo(String appName) {
    return '$appName logo';
  }

  @override
  String trendsSummaryLine(int count, String percent) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count assessments',
      one: '1 assessment',
    );
    return '$_temp0 · highest $percent%';
  }

  @override
  String get stepAboutYouTitle => 'About you';

  @override
  String get stepAboutYouSubtitle =>
      'Your details, and how long you have been on these medicines';

  @override
  String get stepSideEffectsTitle => 'Side effects';

  @override
  String get stepSideEffectsSubtitle =>
      'The effects you have noticed since starting';

  @override
  String get stepDailyLifeTitle => 'Daily life';

  @override
  String get stepDailyLifeSubtitle =>
      'Sleep, activity and habits over a typical week';

  @override
  String get medicationsSearchByNameOr => 'Search by name or drug class';

  @override
  String get errorUnreachableTitle => 'Cannot reach the server';

  @override
  String get errorGenericTitle => 'Something went wrong';

  @override
  String get errorUnreachable =>
      'Cannot reach the QoLGuard server. Check that it is running and that the app is pointed at the right address.';

  @override
  String get errorTimeout =>
      'The server took too long to respond. Please try again.';

  @override
  String get errorCancelled => 'The request was cancelled.';

  @override
  String get errorValidation =>
      'Some of the details entered are outside the accepted range.';

  @override
  String get errorNotSupported => 'That medication is not supported.';

  @override
  String get errorServer =>
      'The server could not complete the request. Please try again.';

  @override
  String get assessmentCouldNotGetResult => 'Could not get a result.';

  @override
  String remindersNotificationTitle(String medicine) {
    return 'Time for your $medicine';
  }

  @override
  String get remindersNotificationBody => 'Tap when you have taken it.';

  @override
  String get learnArticlesHeading => 'Articles';

  @override
  String get learnTipsHeading => 'Health tips';

  @override
  String get commonContinue => 'Continue';

  @override
  String get assessmentGetMyResult => 'Get my result';

  @override
  String get assessmentDailyDose => 'Daily dose';

  @override
  String get assessmentWhenDidTheseStart => 'When did these start?';

  @override
  String get assessmentEnterNumber => 'Enter a number';

  @override
  String assessmentMustBeBetween(int low, int high) {
    return 'Must be between $low and $high';
  }

  @override
  String get medicationsNoneSelected => 'No medicine selected yet';

  @override
  String medicationsSelectedCount(int count, int max) {
    return '$count of $max selected';
  }

  @override
  String medicationsContinueWith(int count) {
    return 'Continue with $count medicines';
  }

  @override
  String get medicationsAssessedSeparately =>
      'Each medicine is assessed separately.';

  @override
  String get medicationsCountCap =>
      'The model counts at most 3 other medicines, so the extra ones are not reflected in that count.';

  @override
  String get predictionSummaryLow =>
      'Your current answers do not suggest a raised risk of quality-of-life decline. Keep taking your medication as prescribed.';

  @override
  String get predictionSummaryMedium =>
      'Your answers suggest some risk of quality-of-life decline. It would be worth mentioning these symptoms at your next appointment.';

  @override
  String get predictionSummaryHigh =>
      'Your answers suggest a raised risk of quality-of-life decline. Consider speaking to your doctor or pharmacist soon.';

  @override
  String predictionBandSummary(int count, int total, String band) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count of $total medicines are in the $band band.',
      one: '$count of $total medicines is in the $band band.',
    );
    return '$_temp0';
  }

  @override
  String predictionBandSummarySingle(String band) {
    return '1 of 1 medicine is in the $band band.';
  }

  @override
  String predictionHighestRisk(String medicine) {
    return 'Highest risk: $medicine';
  }

  @override
  String get predictionTakingThese => 'Taking these';

  @override
  String get predictionEffectsStarted => 'Effects started';

  @override
  String get predictionSleep => 'Sleep';

  @override
  String get predictionSleepProblems => 'Sleep problems';

  @override
  String get predictionActivity => 'Activity';

  @override
  String get predictionDailySteps => 'Daily steps';

  @override
  String get predictionDiet => 'Diet';

  @override
  String get predictionSmoker => 'Smoker';

  @override
  String get predictionAlcohol => 'Alcohol';

  @override
  String get historyNone => 'None';

  @override
  String historyNamesAnd(String names, String last) {
    return '$names and $last';
  }

  @override
  String get historyNoSideEffectsReported => 'No side effects reported';

  @override
  String get remindersEveryDay => 'Every day';

  @override
  String get remindersWeekdays => 'Weekdays';

  @override
  String get remindersWeekends => 'Weekends';

  @override
  String get remindersEditTitle => 'Edit reminder';

  @override
  String get remindersNewTitle => 'New reminder';

  @override
  String get settingsYourData => 'Your data';

  @override
  String get settingsConnection => 'Connection';

  @override
  String get settingsNotConnected => 'Not connected';

  @override
  String get settingsAbout => 'About';

  @override
  String get settingsResearchPrototype => 'Research prototype';

  @override
  String get settingsNothingStored => 'Nothing stored yet';

  @override
  String get startupTagline =>
      'Early detection of quality-of-life decline in long-term medication users';

  @override
  String get trendsPeriodMonth => '30 days';

  @override
  String get trendsPeriodQuarter => '90 days';

  @override
  String get trendsPeriodAll => 'All time';

  @override
  String get trendsMessageRising =>
      'Your risk of quality-of-life decline has been rising over this period. It would be worth discussing these symptoms with your doctor or pharmacist.';

  @override
  String get trendsMessageFalling =>
      'Your risk of quality-of-life decline has been falling over this period. Keep taking your medication as prescribed.';

  @override
  String get trendsMessageSteady =>
      'Your risk of quality-of-life decline has stayed broadly steady over this period.';

  @override
  String get trendsMessageUnknown =>
      'Complete at least two assessments to see how your risk is moving.';

  @override
  String get trendsRising => 'Rising';

  @override
  String get trendsFalling => 'Falling';

  @override
  String get trendsSteady => 'Steady';

  @override
  String get trendsNotEnoughData => 'Not enough data';

  @override
  String get trendsNoneInPeriod => 'No assessments in this period';

  @override
  String get trendsOneSoFar => 'One assessment so far';

  @override
  String get riskLow => 'Low';

  @override
  String get riskMedium => 'Medium';

  @override
  String get riskHigh => 'High';

  @override
  String get sideEffectAbdominalPain => 'Abdominal Pain';

  @override
  String get sideEffectAnxiety => 'Anxiety';

  @override
  String get sideEffectConstipation => 'Constipation';

  @override
  String get sideEffectDiarrhea => 'Diarrhea';

  @override
  String get sideEffectDizziness => 'Dizziness';

  @override
  String get sideEffectDryCough => 'Dry cough';

  @override
  String get sideEffectDryMouth => 'Dry mouth';

  @override
  String get sideEffectFatigue => 'Fatigue';

  @override
  String get sideEffectHeadache => 'Headache';

  @override
  String get sideEffectHeartburn => 'Heartburn';

  @override
  String get sideEffectHypoglycemia => 'Low blood sugar';

  @override
  String get sideEffectInsomnia => 'Sleep problems';

  @override
  String get sideEffectLiverToxicity => 'Liver problems';

  @override
  String get sideEffectMusclePain => 'Muscle Pain';

  @override
  String get sideEffectNausea => 'Nausea';

  @override
  String get sideEffectPalpitations => 'Heart racing';

  @override
  String get sideEffectRash => 'Rash';

  @override
  String get sideEffectStomachPain => 'Stomach Pain';

  @override
  String get sideEffectSweating => 'Sweating';

  @override
  String get sideEffectSwelling => 'Swelling';

  @override
  String get sideEffectWeightGain => 'Weight Gain';

  @override
  String get severityMild => 'Mild';

  @override
  String get severityModerate => 'Moderate';

  @override
  String get severitySevere => 'Severe';

  @override
  String get genderFemale => 'Female';

  @override
  String get genderMale => 'Male';

  @override
  String get valueNo => 'No';

  @override
  String get valueYes => 'Yes';

  @override
  String get alcoholNone => 'No alcohol';

  @override
  String get alcoholOccasional => 'Occasional';

  @override
  String get alcoholFrequent => 'Frequent';

  @override
  String get levelLow => 'Low';

  @override
  String get levelMedium => 'Medium';

  @override
  String get levelHigh => 'High';

  @override
  String get dietUnhealthy => 'Unhealthy';

  @override
  String get dietMedium => 'Medium';

  @override
  String get dietHealthy => 'Healthy';

  @override
  String get fieldAge => 'Age';

  @override
  String get fieldGender => 'Gender';

  @override
  String get fieldSmoker => 'Smoker';

  @override
  String get fieldAlcoholUse => 'Alcohol use';

  @override
  String get fieldSleepQuality => 'Sleep quality';

  @override
  String get fieldPhysicalActivityLevel => 'Physical activity level';

  @override
  String get fieldDailySteps => 'Daily steps';

  @override
  String get fieldDietaryHabits => 'Dietary habits';

  @override
  String get fieldSleepDisorders => 'Sleep disorders';

  @override
  String get fieldTreatmentDuration => 'Treatment duration days';

  @override
  String get fieldAgeHelp => 'Patient age in years';

  @override
  String get fieldGenderHelp => 'Patient gender';

  @override
  String get fieldSmokerHelp => 'Current smoker';

  @override
  String get fieldAlcoholUseHelp => 'Alcohol consumption';

  @override
  String get fieldSleepQualityHelp =>
      'Self-rated sleep quality (1 = worst, 10 = best)';

  @override
  String get fieldPhysicalActivityLevelHelp =>
      'General physical activity level';

  @override
  String get fieldDailyStepsHelp => 'Typical daily step count';

  @override
  String get fieldDietaryHabitsHelp => 'General diet quality';

  @override
  String get fieldSleepDisordersHelp => 'Diagnosed sleep disorder';

  @override
  String get fieldTreatmentDurationHelp => 'Days on this medication so far';

  @override
  String get fieldOnsetHelp =>
      'Days from starting the drug until the side effect appeared';

  @override
  String get fieldDosageHelp =>
      'Total daily dose (mg; international units for Insulin)';

  @override
  String get shareReport => 'Share report';

  @override
  String get shareAsPdf => 'Share as PDF';

  @override
  String get shareAsImage => 'Share as image';

  @override
  String get sharePreparing => 'Preparing report…';

  @override
  String get shareFailed => 'Could not create the report. Please try again.';

  @override
  String shareSubject(String date) {
    return 'QoLGuard report – $date';
  }

  @override
  String get reportTitle => 'Quality-of-life assessment report';

  @override
  String get reportPatientDetails => 'Patient details';

  @override
  String get reportCreatedWith => 'Created with QoLGuard';
}
