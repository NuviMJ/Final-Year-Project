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
