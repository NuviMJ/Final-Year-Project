import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_si.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('si'),
  ];

  /// Shown under the app name on the home screen
  ///
  /// In en, this message translates to:
  /// **'Quality of life, guarded'**
  String get appTagline;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @sectionLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get sectionLanguage;

  /// Explains why drug names are not translated
  ///
  /// In en, this message translates to:
  /// **'Medication names stay in English'**
  String get languageSubtitle;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// Always written in Sinhala, in both locales
  ///
  /// In en, this message translates to:
  /// **'සිංහල'**
  String get languageSinhala;

  /// No description provided for @latestResultTitle.
  ///
  /// In en, this message translates to:
  /// **'Latest QoL result'**
  String get latestResultTitle;

  /// No description provided for @qolScore.
  ///
  /// In en, this message translates to:
  /// **'QoL score'**
  String get qolScore;

  /// No description provided for @noEffectsRing.
  ///
  /// In en, this message translates to:
  /// **'No effects'**
  String get noEffectsRing;

  /// No description provided for @noEffectsRingCaption.
  ///
  /// In en, this message translates to:
  /// **'reported'**
  String get noEffectsRingCaption;

  /// No description provided for @takeFirstAssessment.
  ///
  /// In en, this message translates to:
  /// **'Take your first assessment'**
  String get takeFirstAssessment;

  /// No description provided for @lastChecked.
  ///
  /// In en, this message translates to:
  /// **'Last checked {when}'**
  String lastChecked(String when);

  /// No description provided for @relativeToday.
  ///
  /// In en, this message translates to:
  /// **'today'**
  String get relativeToday;

  /// No description provided for @relativeYesterday.
  ///
  /// In en, this message translates to:
  /// **'yesterday'**
  String get relativeYesterday;

  /// No description provided for @relativeDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} days ago'**
  String relativeDaysAgo(int count);

  /// No description provided for @relativeOnDate.
  ///
  /// In en, this message translates to:
  /// **'on {date}'**
  String relativeOnDate(String date);

  /// No description provided for @startAssessment.
  ///
  /// In en, this message translates to:
  /// **'Start assessment'**
  String get startAssessment;

  /// No description provided for @historyTitle.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get historyTitle;

  /// No description provided for @historySubtitle.
  ///
  /// In en, this message translates to:
  /// **'View past results'**
  String get historySubtitle;

  /// No description provided for @learnTitle.
  ///
  /// In en, this message translates to:
  /// **'Learning tips'**
  String get learnTitle;

  /// No description provided for @learnSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Improve your score'**
  String get learnSubtitle;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navReminders.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get navReminders;

  /// No description provided for @navTrends.
  ///
  /// In en, this message translates to:
  /// **'Trends'**
  String get navTrends;

  /// No description provided for @doNext.
  ///
  /// In en, this message translates to:
  /// **'Do next'**
  String get doNext;

  /// No description provided for @actionAssessTitle.
  ///
  /// In en, this message translates to:
  /// **'Start an assessment'**
  String get actionAssessTitle;

  /// No description provided for @actionAssessSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Four short steps, about two minutes'**
  String get actionAssessSubtitle;

  /// No description provided for @actionHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Your history'**
  String get actionHistoryTitle;

  /// No description provided for @historyNothingYet.
  ///
  /// In en, this message translates to:
  /// **'Nothing recorded yet'**
  String get historyNothingYet;

  /// No description provided for @historyOnDevice.
  ///
  /// In en, this message translates to:
  /// **'{count,plural, =1{1 assessment on this device} other{{count} assessments on this device}}'**
  String historyOnDevice(int count);

  /// No description provided for @actionLearnTitle.
  ///
  /// In en, this message translates to:
  /// **'Learn'**
  String get actionLearnTitle;

  /// No description provided for @actionLearnSubtitle.
  ///
  /// In en, this message translates to:
  /// **'What your result means, and what affects it'**
  String get actionLearnSubtitle;

  /// No description provided for @latestResultLabel.
  ///
  /// In en, this message translates to:
  /// **'LATEST RESULT'**
  String get latestResultLabel;

  /// Category stays as the model returns it until Stage 2 maps the names
  ///
  /// In en, this message translates to:
  /// **'{category} risk'**
  String riskLevel(String category);

  /// No description provided for @noAssessmentsYet.
  ///
  /// In en, this message translates to:
  /// **'No assessments yet'**
  String get noAssessmentsYet;

  /// No description provided for @completeOnePrompt.
  ///
  /// In en, this message translates to:
  /// **'Complete one to see your quality-of-life risk here.'**
  String get completeOnePrompt;

  /// No description provided for @modelVersion.
  ///
  /// In en, this message translates to:
  /// **'Model {version}'**
  String modelVersion(String version);

  /// No description provided for @assessmentAssessment.
  ///
  /// In en, this message translates to:
  /// **'Assessment'**
  String get assessmentAssessment;

  /// No description provided for @assessmentNoMedicationSelected.
  ///
  /// In en, this message translates to:
  /// **'No medication selected.'**
  String get assessmentNoMedicationSelected;

  /// No description provided for @assessmentLoadingQuestions.
  ///
  /// In en, this message translates to:
  /// **'Loading questions…'**
  String get assessmentLoadingQuestions;

  /// No description provided for @assessmentBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get assessmentBack;

  /// No description provided for @assessmentYears.
  ///
  /// In en, this message translates to:
  /// **'years'**
  String get assessmentYears;

  /// No description provided for @assessmentHaveYouExperiencedAny.
  ///
  /// In en, this message translates to:
  /// **'Have you experienced any side effects from your medication?'**
  String get assessmentHaveYouExperiencedAny;

  /// No description provided for @assessmentYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get assessmentYes;

  /// No description provided for @assessmentNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get assessmentNo;

  /// No description provided for @assessmentOhThatsGoodNews.
  ///
  /// In en, this message translates to:
  /// **'Oh, that’s good news!'**
  String get assessmentOhThatsGoodNews;

  /// No description provided for @assessmentYouHaventExperiencedAny.
  ///
  /// In en, this message translates to:
  /// **'You haven’t experienced any side effects. Tell us about your daily life next.'**
  String get assessmentYouHaventExperiencedAny;

  /// No description provided for @assessmentSelectTheSideEffects.
  ///
  /// In en, this message translates to:
  /// **'Select the side effects you experienced'**
  String get assessmentSelectTheSideEffects;

  /// No description provided for @assessmentThatsTheMostYou.
  ///
  /// In en, this message translates to:
  /// **'That’s the most you can report at once.'**
  String get assessmentThatsTheMostYou;

  /// No description provided for @coreTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get coreTryAgain;

  /// No description provided for @historyYourResultsAppearHere.
  ///
  /// In en, this message translates to:
  /// **'Your results appear here once you complete an assessment. Everything stays on this device.'**
  String get historyYourResultsAppearHere;

  /// No description provided for @historyDeleteThisAssessment.
  ///
  /// In en, this message translates to:
  /// **'Delete this assessment?'**
  String get historyDeleteThisAssessment;

  /// No description provided for @historyItWillBeRemoved.
  ///
  /// In en, this message translates to:
  /// **'It will be removed from this device permanently.'**
  String get historyItWillBeRemoved;

  /// No description provided for @historyKeep.
  ///
  /// In en, this message translates to:
  /// **'Keep'**
  String get historyKeep;

  /// No description provided for @historyDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get historyDelete;

  /// No description provided for @historyPastResult.
  ///
  /// In en, this message translates to:
  /// **'Past result'**
  String get historyPastResult;

  /// No description provided for @historyThatAssessmentIsNo.
  ///
  /// In en, this message translates to:
  /// **'That assessment is no longer stored on this device.'**
  String get historyThatAssessmentIsNo;

  /// No description provided for @historyRisk.
  ///
  /// In en, this message translates to:
  /// **'RISK'**
  String get historyRisk;

  /// No description provided for @historyProbabilities.
  ///
  /// In en, this message translates to:
  /// **'Probabilities'**
  String get historyProbabilities;

  /// No description provided for @historyWhatWasReported.
  ///
  /// In en, this message translates to:
  /// **'What was reported'**
  String get historyWhatWasReported;

  /// No description provided for @historyMedicines.
  ///
  /// In en, this message translates to:
  /// **'Medicines'**
  String get historyMedicines;

  /// No description provided for @historySideEffects.
  ///
  /// In en, this message translates to:
  /// **'Side effects'**
  String get historySideEffects;

  /// No description provided for @historyNoneReported.
  ///
  /// In en, this message translates to:
  /// **'None reported'**
  String get historyNoneReported;

  /// No description provided for @historyEverythingElse.
  ///
  /// In en, this message translates to:
  /// **'Everything else'**
  String get historyEverythingElse;

  /// No description provided for @historyOnThisDayYou.
  ///
  /// In en, this message translates to:
  /// **'On this day you had no side effects'**
  String get historyOnThisDayYou;

  /// No description provided for @learnShortReadsOnThe.
  ///
  /// In en, this message translates to:
  /// **'Short reads on the things the model weighs most heavily, and what your results mean.'**
  String get learnShortReadsOnThe;

  /// No description provided for @learnThatArticleIsNo.
  ///
  /// In en, this message translates to:
  /// **'That article is no longer available.'**
  String get learnThatArticleIsNo;

  /// No description provided for @medicationsSelectYourMedications.
  ///
  /// In en, this message translates to:
  /// **'Select your medications'**
  String get medicationsSelectYourMedications;

  /// No description provided for @medicationsLoadingMedications.
  ///
  /// In en, this message translates to:
  /// **'Loading medications…'**
  String get medicationsLoadingMedications;

  /// No description provided for @medicationsChangeTheDose.
  ///
  /// In en, this message translates to:
  /// **'Change the dose'**
  String get medicationsChangeTheDose;

  /// No description provided for @medicationsHowMuchDoYou.
  ///
  /// In en, this message translates to:
  /// **'How much do you take each day?'**
  String get medicationsHowMuchDoYou;

  /// No description provided for @medicationsCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get medicationsCancel;

  /// No description provided for @predictionYourResult.
  ///
  /// In en, this message translates to:
  /// **'Your result'**
  String get predictionYourResult;

  /// No description provided for @predictionAnalyzingYourHealthInformation.
  ///
  /// In en, this message translates to:
  /// **'Analyzing your health information…'**
  String get predictionAnalyzingYourHealthInformation;

  /// No description provided for @predictionNoResultToShow.
  ///
  /// In en, this message translates to:
  /// **'No result to show.'**
  String get predictionNoResultToShow;

  /// No description provided for @predictionGoodNews.
  ///
  /// In en, this message translates to:
  /// **'Good news!'**
  String get predictionGoodNews;

  /// No description provided for @predictionYouHaventReportedAny.
  ///
  /// In en, this message translates to:
  /// **'You haven’t reported any symptoms or side effects from your medication, which is a positive sign for your quality of life.'**
  String get predictionYouHaventReportedAny;

  /// No description provided for @predictionKeepTakingCareOf.
  ///
  /// In en, this message translates to:
  /// **'Keep taking care of yourself and keep following your healthcare provider’s advice. 💚'**
  String get predictionKeepTakingCareOf;

  /// No description provided for @predictionStartAnotherAssessment.
  ///
  /// In en, this message translates to:
  /// **'Start another assessment'**
  String get predictionStartAnotherAssessment;

  /// No description provided for @predictionHowConfidentIsThis.
  ///
  /// In en, this message translates to:
  /// **'How confident is this?'**
  String get predictionHowConfidentIsThis;

  /// No description provided for @predictionYourSummary.
  ///
  /// In en, this message translates to:
  /// **'Your summary'**
  String get predictionYourSummary;

  /// No description provided for @predictionYourMedicines.
  ///
  /// In en, this message translates to:
  /// **'Your medicines'**
  String get predictionYourMedicines;

  /// No description provided for @predictionSideEffectsYouReported.
  ///
  /// In en, this message translates to:
  /// **'Side effects you reported'**
  String get predictionSideEffectsYouReported;

  /// No description provided for @predictionTreatment.
  ///
  /// In en, this message translates to:
  /// **'Treatment'**
  String get predictionTreatment;

  /// No description provided for @predictionDailyLife.
  ///
  /// In en, this message translates to:
  /// **'Daily life'**
  String get predictionDailyLife;

  /// No description provided for @predictionRiskByMedicine.
  ///
  /// In en, this message translates to:
  /// **'Risk by medicine'**
  String get predictionRiskByMedicine;

  /// No description provided for @predictionBarsShowTheChance.
  ///
  /// In en, this message translates to:
  /// **'Bars show the chance of the High band for each medicine.'**
  String get predictionBarsShowTheChance;

  /// No description provided for @remindersMedication.
  ///
  /// In en, this message translates to:
  /// **'Medication'**
  String get remindersMedication;

  /// No description provided for @remindersTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get remindersTime;

  /// No description provided for @remindersRepeatOn.
  ///
  /// In en, this message translates to:
  /// **'Repeat on'**
  String get remindersRepeatOn;

  /// No description provided for @remindersSaveReminder.
  ///
  /// In en, this message translates to:
  /// **'Save reminder'**
  String get remindersSaveReminder;

  /// No description provided for @remindersAddReminder.
  ///
  /// In en, this message translates to:
  /// **'Add reminder'**
  String get remindersAddReminder;

  /// No description provided for @remindersNotificationsAreTurnedOff.
  ///
  /// In en, this message translates to:
  /// **'Notifications are turned off'**
  String get remindersNotificationsAreTurnedOff;

  /// No description provided for @remindersYourRemindersAreSaved.
  ///
  /// In en, this message translates to:
  /// **'Your reminders are saved, but nothing will alert you until you allow notifications.'**
  String get remindersYourRemindersAreSaved;

  /// No description provided for @remindersAllowNotifications.
  ///
  /// In en, this message translates to:
  /// **'Allow notifications'**
  String get remindersAllowNotifications;

  /// No description provided for @remindersRemindersCanBeSet.
  ///
  /// In en, this message translates to:
  /// **'Reminders can be set up here, but only fire on an Android device.'**
  String get remindersRemindersCanBeSet;

  /// No description provided for @remindersNoRemindersYet.
  ///
  /// In en, this message translates to:
  /// **'No reminders yet'**
  String get remindersNoRemindersYet;

  /// No description provided for @remindersAddOneToBe.
  ///
  /// In en, this message translates to:
  /// **'Add one to be reminded when a medication is due.'**
  String get remindersAddOneToBe;

  /// No description provided for @settingsCopyMyData.
  ///
  /// In en, this message translates to:
  /// **'Copy my data'**
  String get settingsCopyMyData;

  /// No description provided for @settingsPutsEverythingStoredOn.
  ///
  /// In en, this message translates to:
  /// **'Puts everything stored on this device on the clipboard'**
  String get settingsPutsEverythingStoredOn;

  /// No description provided for @settingsDeleteEverything.
  ///
  /// In en, this message translates to:
  /// **'Delete everything'**
  String get settingsDeleteEverything;

  /// No description provided for @settingsRemovesAllAssessmentsAnd.
  ///
  /// In en, this message translates to:
  /// **'Removes all assessments and reminders permanently'**
  String get settingsRemovesAllAssessmentsAnd;

  /// No description provided for @settingsServer.
  ///
  /// In en, this message translates to:
  /// **'Server'**
  String get settingsServer;

  /// No description provided for @settingsModel.
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get settingsModel;

  /// No description provided for @settingsMedications.
  ///
  /// In en, this message translates to:
  /// **'Medications'**
  String get settingsMedications;

  /// No description provided for @settingsApp.
  ///
  /// In en, this message translates to:
  /// **'App'**
  String get settingsApp;

  /// No description provided for @settingsPurpose.
  ///
  /// In en, this message translates to:
  /// **'Purpose'**
  String get settingsPurpose;

  /// No description provided for @settingsDeleteEverything2.
  ///
  /// In en, this message translates to:
  /// **'Delete everything?'**
  String get settingsDeleteEverything2;

  /// No description provided for @settingsAllYourAssessmentsAnd.
  ///
  /// In en, this message translates to:
  /// **'All your assessments and reminders will be removed from this device. This cannot be undone.'**
  String get settingsAllYourAssessmentsAnd;

  /// No description provided for @settingsKeepMyData.
  ///
  /// In en, this message translates to:
  /// **'Keep my data'**
  String get settingsKeepMyData;

  /// No description provided for @settingsEverythingHasBeenDeleted.
  ///
  /// In en, this message translates to:
  /// **'Everything has been deleted'**
  String get settingsEverythingHasBeenDeleted;

  /// No description provided for @settingsYourDataStaysHere.
  ///
  /// In en, this message translates to:
  /// **'Your data stays here'**
  String get settingsYourDataStaysHere;

  /// No description provided for @settingsAssessmentsAndRemindersAre.
  ///
  /// In en, this message translates to:
  /// **'Assessments and reminders are stored only on this phone. There is no account, and nothing is uploaded or backed up anywhere.'**
  String get settingsAssessmentsAndRemindersAre;

  /// No description provided for @settingsYourAnswersAreSent.
  ///
  /// In en, this message translates to:
  /// **'Your answers are sent to the prediction server to be scored, and the result comes straight back. Nothing is kept there.'**
  String get settingsYourAnswersAreSent;

  /// No description provided for @settingsAssessments.
  ///
  /// In en, this message translates to:
  /// **'assessments'**
  String get settingsAssessments;

  /// No description provided for @settingsReminders.
  ///
  /// In en, this message translates to:
  /// **'reminders'**
  String get settingsReminders;

  /// No description provided for @startupConnecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting…'**
  String get startupConnecting;

  /// No description provided for @trendsYourTrends.
  ///
  /// In en, this message translates to:
  /// **'Your trends'**
  String get trendsYourTrends;

  /// No description provided for @trendsProbabilityOfHighRisk.
  ///
  /// In en, this message translates to:
  /// **'Probability of high risk'**
  String get trendsProbabilityOfHighRisk;

  /// No description provided for @trendsTheModelsOwnLikelihood.
  ///
  /// In en, this message translates to:
  /// **'The model\'s own likelihood that your quality of life is at high risk of decline, at each assessment.'**
  String get trendsTheModelsOwnLikelihood;

  /// No description provided for @trendsAssessmentsInThisPeriod.
  ///
  /// In en, this message translates to:
  /// **'Assessments in this period'**
  String get trendsAssessmentsInThisPeriod;

  /// No description provided for @trendsATrendNeedsAt.
  ///
  /// In en, this message translates to:
  /// **'A trend needs at least two assessments to compare. Complete another to see how your risk is moving.'**
  String get trendsATrendNeedsAt;

  /// No description provided for @durationUnder3Months.
  ///
  /// In en, this message translates to:
  /// **'Less than 3 months'**
  String get durationUnder3Months;

  /// No description provided for @duration3To6Months.
  ///
  /// In en, this message translates to:
  /// **'3 to 6 months'**
  String get duration3To6Months;

  /// No description provided for @duration6To12Months.
  ///
  /// In en, this message translates to:
  /// **'6 to 12 months'**
  String get duration6To12Months;

  /// No description provided for @duration1To2Years.
  ///
  /// In en, this message translates to:
  /// **'1 to 2 years'**
  String get duration1To2Years;

  /// No description provided for @durationOver2Years.
  ///
  /// In en, this message translates to:
  /// **'More than 2 years'**
  String get durationOver2Years;

  /// No description provided for @onsetWithinDays.
  ///
  /// In en, this message translates to:
  /// **'Within a few days'**
  String get onsetWithinDays;

  /// No description provided for @onset1To2Weeks.
  ///
  /// In en, this message translates to:
  /// **'1 to 2 weeks'**
  String get onset1To2Weeks;

  /// No description provided for @onset3To4Weeks.
  ///
  /// In en, this message translates to:
  /// **'3 to 4 weeks'**
  String get onset3To4Weeks;

  /// No description provided for @sleepVeryPoor.
  ///
  /// In en, this message translates to:
  /// **'Very poor'**
  String get sleepVeryPoor;

  /// No description provided for @sleepPoor.
  ///
  /// In en, this message translates to:
  /// **'Poor'**
  String get sleepPoor;

  /// No description provided for @sleepFair.
  ///
  /// In en, this message translates to:
  /// **'Fair'**
  String get sleepFair;

  /// No description provided for @sleepGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get sleepGood;

  /// No description provided for @sleepVeryGood.
  ///
  /// In en, this message translates to:
  /// **'Very good'**
  String get sleepVeryGood;

  /// No description provided for @sleepExcellent.
  ///
  /// In en, this message translates to:
  /// **'Excellent'**
  String get sleepExcellent;

  /// No description provided for @assessmentMedicineCount.
  ///
  /// In en, this message translates to:
  /// **'{count,plural, =1{1 medicine} other{{count} medicines}}'**
  String assessmentMedicineCount(int count);

  /// No description provided for @assessmentStepOf.
  ///
  /// In en, this message translates to:
  /// **'Step {step} of {total}'**
  String assessmentStepOf(int step, int total);

  /// No description provided for @assessmentBetween.
  ///
  /// In en, this message translates to:
  /// **'Between {low} and {high}'**
  String assessmentBetween(int low, int high);

  /// No description provided for @assessmentChooseUpTo.
  ///
  /// In en, this message translates to:
  /// **'Choose up to {max}, and say how bad each one is.'**
  String assessmentChooseUpTo(int max);

  /// No description provided for @assessmentShowAllEffects.
  ///
  /// In en, this message translates to:
  /// **'Show all effects ({count} more)'**
  String assessmentShowAllEffects(int count);

  /// No description provided for @historyNothingReportedOn.
  ///
  /// In en, this message translates to:
  /// **'Nothing was reported on {date}, so no risk level was worked out for that day.'**
  String historyNothingReportedOn(String date);

  /// No description provided for @medicationsChooseEvery.
  ///
  /// In en, this message translates to:
  /// **'Choose every medicine you take regularly, up to {max}. Check the daily dose shown and change it if it is not yours.'**
  String medicationsChooseEvery(int max);

  /// No description provided for @medicationsNoMatch.
  ///
  /// In en, this message translates to:
  /// **'No medication matches \"{query}\".'**
  String medicationsNoMatch(String query);

  /// No description provided for @medicationsMaxAtATime.
  ///
  /// In en, this message translates to:
  /// **'You can assess up to {max} medicines at a time.'**
  String medicationsMaxAtATime(int max);

  /// No description provided for @predictionNotAHealthCheck.
  ///
  /// In en, this message translates to:
  /// **'This reflects what you told us today and is not a health check.'**
  String get predictionNotAHealthCheck;

  /// No description provided for @medicalDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'QoLGuard does not diagnose medical conditions and does not replace advice from a healthcare professional. Always consult your doctor or pharmacist before changing any medication.'**
  String get medicalDisclaimer;

  /// No description provided for @remindersNext.
  ///
  /// In en, this message translates to:
  /// **'Next {when}'**
  String remindersNext(String when);

  /// No description provided for @remindersTodayAt.
  ///
  /// In en, this message translates to:
  /// **'today at {time}'**
  String remindersTodayAt(String time);

  /// No description provided for @remindersTomorrowAt.
  ///
  /// In en, this message translates to:
  /// **'tomorrow at {time}'**
  String remindersTomorrowAt(String time);

  /// No description provided for @remindersDayAt.
  ///
  /// In en, this message translates to:
  /// **'{day} at {time}'**
  String remindersDayAt(String day, String time);

  /// No description provided for @settingsCopiedCount.
  ///
  /// In en, this message translates to:
  /// **'{count,plural, =1{1 assessment copied to the clipboard} other{{count} assessments copied to the clipboard}}'**
  String settingsCopiedCount(int count);

  /// No description provided for @startupLogo.
  ///
  /// In en, this message translates to:
  /// **'{appName} logo'**
  String startupLogo(String appName);

  /// No description provided for @trendsSummaryLine.
  ///
  /// In en, this message translates to:
  /// **'{count,plural, =1{1 assessment} other{{count} assessments}} · highest {percent}%'**
  String trendsSummaryLine(int count, String percent);

  /// No description provided for @stepAboutYouTitle.
  ///
  /// In en, this message translates to:
  /// **'About you'**
  String get stepAboutYouTitle;

  /// No description provided for @stepAboutYouSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your details, and how long you have been on these medicines'**
  String get stepAboutYouSubtitle;

  /// No description provided for @stepSideEffectsTitle.
  ///
  /// In en, this message translates to:
  /// **'Side effects'**
  String get stepSideEffectsTitle;

  /// No description provided for @stepSideEffectsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The effects you have noticed since starting'**
  String get stepSideEffectsSubtitle;

  /// No description provided for @stepDailyLifeTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily life'**
  String get stepDailyLifeTitle;

  /// No description provided for @stepDailyLifeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sleep, activity and habits over a typical week'**
  String get stepDailyLifeSubtitle;

  /// No description provided for @medicationsSearchByNameOr.
  ///
  /// In en, this message translates to:
  /// **'Search by name or drug class'**
  String get medicationsSearchByNameOr;

  /// No description provided for @errorUnreachableTitle.
  ///
  /// In en, this message translates to:
  /// **'Cannot reach the server'**
  String get errorUnreachableTitle;

  /// No description provided for @errorGenericTitle.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get errorGenericTitle;

  /// No description provided for @errorUnreachable.
  ///
  /// In en, this message translates to:
  /// **'Cannot reach the QoLGuard server. Check that it is running and that the app is pointed at the right address.'**
  String get errorUnreachable;

  /// No description provided for @errorTimeout.
  ///
  /// In en, this message translates to:
  /// **'The server took too long to respond. Please try again.'**
  String get errorTimeout;

  /// No description provided for @errorCancelled.
  ///
  /// In en, this message translates to:
  /// **'The request was cancelled.'**
  String get errorCancelled;

  /// No description provided for @errorValidation.
  ///
  /// In en, this message translates to:
  /// **'Some of the details entered are outside the accepted range.'**
  String get errorValidation;

  /// No description provided for @errorNotSupported.
  ///
  /// In en, this message translates to:
  /// **'That medication is not supported.'**
  String get errorNotSupported;

  /// No description provided for @errorServer.
  ///
  /// In en, this message translates to:
  /// **'The server could not complete the request. Please try again.'**
  String get errorServer;

  /// No description provided for @assessmentCouldNotGetResult.
  ///
  /// In en, this message translates to:
  /// **'Could not get a result.'**
  String get assessmentCouldNotGetResult;

  /// No description provided for @remindersNotificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Time for your {medicine}'**
  String remindersNotificationTitle(String medicine);

  /// No description provided for @remindersNotificationBody.
  ///
  /// In en, this message translates to:
  /// **'Tap when you have taken it.'**
  String get remindersNotificationBody;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'si'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'si':
      return AppLocalizationsSi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
