// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Sinhala Sinhalese (`si`).
class AppLocalizationsSi extends AppLocalizations {
  AppLocalizationsSi([String locale = 'si']) : super(locale);

  @override
  String get appTagline => 'ජීවන තත්ත්වය, සුරැකිව';

  @override
  String get settingsTitle => 'සැකසුම්';

  @override
  String get sectionLanguage => 'භාෂාව';

  @override
  String get languageSubtitle => 'ඖෂධ නම් ඉංග්‍රීසියෙන්ම පවතී';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSinhala => 'සිංහල';

  @override
  String get latestResultTitle => 'නවතම ජීවන තත්ත්ව ප්‍රතිඵලය';

  @override
  String get qolScore => 'ජීවන තත්ත්වය';

  @override
  String get noEffectsRing => 'අතුරු ආබාධ නැත';

  @override
  String get noEffectsRingCaption => 'වාර්තා වී නැත';

  @override
  String get takeFirstAssessment => 'ඔබගේ පළමු තක්සේරුව සිදු කරන්න';

  @override
  String lastChecked(String when) {
    return 'අවසන් වරට පරීක්ෂා කළේ $when';
  }

  @override
  String get relativeToday => 'අද';

  @override
  String get relativeYesterday => 'ඊයේ';

  @override
  String relativeDaysAgo(int count) {
    return 'දින $countකට පෙර';
  }

  @override
  String relativeOnDate(String date) {
    return '$date දින';
  }

  @override
  String get startAssessment => 'තක්සේරුව අරඹන්න';

  @override
  String get historyTitle => 'ඉතිහාසය';

  @override
  String get historySubtitle => 'පෙර ප්‍රතිඵල බලන්න';

  @override
  String get learnTitle => 'උපදෙස්';

  @override
  String get learnSubtitle => 'ඔබගේ තත්ත්වය වැඩි දියුණු කරන්න';

  @override
  String get navHome => 'මුල් පිටුව';

  @override
  String get navReminders => 'මතක් කිරීම්';

  @override
  String get navTrends => 'ප්‍රවණතා';

  @override
  String get doNext => 'ඊළඟට කළ යුතු දේ';

  @override
  String get actionAssessTitle => 'තක්සේරුවක් අරඹන්න';

  @override
  String get actionAssessSubtitle => 'කෙටි පියවර හතරක්, විනාඩි දෙකක් පමණ';

  @override
  String get actionHistoryTitle => 'ඔබගේ ඉතිහාසය';

  @override
  String get historyNothingYet => 'තවම කිසිවක් වාර්තා වී නැත';

  @override
  String historyOnDevice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'මෙම උපාංගයේ තක්සේරු $countක්',
      one: 'මෙම උපාංගයේ තක්සේරු 1ක්',
    );
    return '$_temp0';
  }

  @override
  String get actionLearnTitle => 'ඉගෙන ගන්න';

  @override
  String get actionLearnSubtitle => 'ඔබගේ ප්‍රතිඵලයේ තේරුම සහ එයට බලපාන දේ';

  @override
  String get latestResultLabel => 'නවතම ප්‍රතිඵලය';

  @override
  String riskLevel(String category) {
    return '$category අවදානම';
  }

  @override
  String get noAssessmentsYet => 'තවම තක්සේරු කර නැත';

  @override
  String get completeOnePrompt =>
      'ඔබගේ ජීවන තත්ත්ව අවදානම මෙහි බැලීමට එකක් සම්පූර්ණ කරන්න.';

  @override
  String modelVersion(String version) {
    return 'ආකෘතිය $version';
  }

  @override
  String get assessmentAssessment => 'තක්සේරුව';

  @override
  String get assessmentNoMedicationSelected => 'ඖෂධයක් තෝරා නැත.';

  @override
  String get assessmentLoadingQuestions => 'ප්‍රශ්න පූරණය වෙමින්…';

  @override
  String get assessmentBack => 'ආපසු';

  @override
  String get assessmentYears => 'අවුරුදු';

  @override
  String get assessmentHaveYouExperiencedAny =>
      'ඔබගේ ඖෂධ නිසා ඔබට කිසියම් අතුරු ආබාධයක් ඇති වූවාද?';

  @override
  String get assessmentYes => 'ඔව්';

  @override
  String get assessmentNo => 'නැත';

  @override
  String get assessmentOhThatsGoodNews => 'එය සුබ ආරංචියකි!';

  @override
  String get assessmentYouHaventExperiencedAny =>
      'ඔබට කිසිදු අතුරු ආබාධයක් ඇති වී නැත. ඊළඟට ඔබගේ දෛනික ජීවිතය ගැන අපට කියන්න.';

  @override
  String get assessmentSelectTheSideEffects =>
      'Select the side effects you experienced';

  @override
  String get assessmentThatsTheMostYou => 'එකවර වාර්තා කළ හැක්කේ මෙපමණකි.';

  @override
  String get coreTryAgain => 'නැවත උත්සාහ කරන්න';

  @override
  String get historyYourResultsAppearHere =>
      'ඔබ තක්සේරුවක් සම්පූර්ණ කළ පසු ඔබගේ ප්‍රතිඵල මෙහි දිස් වේ. සියල්ල මෙම උපාංගයේම පවතී.';

  @override
  String get historyDeleteThisAssessment => 'මෙම තක්සේරුව මකන්නද?';

  @override
  String get historyItWillBeRemoved => 'එය මෙම උපාංගයෙන් ස්ථිරවම ඉවත් කෙරේ.';

  @override
  String get historyKeep => 'තබා ගන්න';

  @override
  String get historyDelete => 'මකන්න';

  @override
  String get historyPastResult => 'පෙර ප්‍රතිඵලය';

  @override
  String get historyThatAssessmentIsNo =>
      'එම තක්සේරුව තවදුරටත් මෙම උපාංගයේ ගබඩා කර නැත.';

  @override
  String get historyRisk => 'RISK';

  @override
  String get historyProbabilities => 'සම්භාවිතා';

  @override
  String get historyWhatWasReported => 'වාර්තා කළ දේ';

  @override
  String get historyMedicines => 'ඖෂධ';

  @override
  String get historySideEffects => 'Side effects';

  @override
  String get historyNoneReported => 'කිසිවක් වාර්තා වී නැත';

  @override
  String get historyEverythingElse => 'අනෙකුත් සියල්ල';

  @override
  String get historyOnThisDayYou => 'මෙම දිනයේ ඔබට අතුරු ආබාධ නොතිබුණි';

  @override
  String get learnShortReadsOnThe =>
      'ආකෘතිය වැඩිපුරම සලකා බලන කරුණු සහ ඔබගේ ප්‍රතිඵලවල තේරුම පිළිබඳ කෙටි ලිපි.';

  @override
  String get learnThatArticleIsNo => 'එම ලිපිය තවදුරටත් ලබා ගත නොහැක.';

  @override
  String get medicationsSelectYourMedications => 'ඔබගේ ඖෂධ තෝරන්න';

  @override
  String get medicationsLoadingMedications => 'ඖෂධ පූරණය වෙමින්…';

  @override
  String get medicationsChangeTheDose => 'Change the dose';

  @override
  String get medicationsHowMuchDoYou => 'How much do you take each day?';

  @override
  String get medicationsCancel => 'අවලංගු කරන්න';

  @override
  String get predictionYourResult => 'ඔබගේ ප්‍රතිඵලය';

  @override
  String get predictionAnalyzingYourHealthInformation =>
      'ඔබගේ සෞඛ්‍ය තොරතුරු විශ්ලේෂණය කරමින්…';

  @override
  String get predictionNoResultToShow => 'පෙන්වීමට ප්‍රතිඵලයක් නැත.';

  @override
  String get predictionGoodNews => 'සුබ ආරංචියක්!';

  @override
  String get predictionYouHaventReportedAny =>
      'ඔබ ඔබගේ ඖෂධවලින් කිසිදු රෝග ලක්ෂණයක් හෝ අතුරු ආබාධයක් වාර්තා කර නැත, එය ඔබගේ ජීවන තත්ත්වය සඳහා යහපත් ලකුණකි.';

  @override
  String get predictionKeepTakingCareOf =>
      'ඔබ ගැන දිගටම සැලකිලිමත් වන්න, ඔබගේ සෞඛ්‍ය සේවා සපයන්නාගේ උපදෙස් දිගටම පිළිපදින්න. 💚';

  @override
  String get predictionStartAnotherAssessment => 'තවත් තක්සේරුවක් අරඹන්න';

  @override
  String get predictionHowConfidentIsThis => 'මෙය කෙතරම් විශ්වාසදායකද?';

  @override
  String get predictionYourSummary => 'ඔබගේ සාරාංශය';

  @override
  String get predictionYourMedicines => 'ඔබගේ ඖෂධ';

  @override
  String get predictionSideEffectsYouReported => 'Side effects you reported';

  @override
  String get predictionTreatment => 'ප්‍රතිකාර';

  @override
  String get predictionDailyLife => 'දෛනික ජීවිතය';

  @override
  String get predictionRiskByMedicine => 'Risk by medicine';

  @override
  String get predictionBarsShowTheChance =>
      'තීරු මඟින් එක් එක් ඖෂධය සඳහා High කාණ්ඩයේ සම්භාවිතාව පෙන්වයි.';

  @override
  String get remindersMedication => 'ඖෂධය';

  @override
  String get remindersTime => 'වේලාව';

  @override
  String get remindersRepeatOn => 'නැවත සිදු වන දින';

  @override
  String get remindersSaveReminder => 'මතක් කිරීම සුරකින්න';

  @override
  String get remindersAddReminder => 'මතක් කිරීමක් එක් කරන්න';

  @override
  String get remindersNotificationsAreTurnedOff => 'දැනුම්දීම් අක්‍රිය කර ඇත';

  @override
  String get remindersYourRemindersAreSaved =>
      'ඔබගේ මතක් කිරීම් සුරැකී ඇත, නමුත් ඔබ දැනුම්දීම්වලට ඉඩ දෙන තුරු කිසිවක් ඔබට දැනුම් නොදේ.';

  @override
  String get remindersAllowNotifications => 'දැනුම්දීම්වලට ඉඩ දෙන්න';

  @override
  String get remindersRemindersCanBeSet =>
      'මතක් කිරීම් මෙහි සැකසිය හැකි නමුත්, ඒවා ක්‍රියාත්මක වන්නේ Android උපාංගයක පමණි.';

  @override
  String get remindersNoRemindersYet => 'තවම මතක් කිරීම් නැත';

  @override
  String get remindersAddOneToBe =>
      'ඖෂධයක් ගැනීමට වේලාව පැමිණි විට මතක් කිරීමට එකක් එක් කරන්න.';

  @override
  String get settingsCopyMyData => 'මගේ දත්ත පිටපත් කරන්න';

  @override
  String get settingsPutsEverythingStoredOn =>
      'මෙම උපාංගයේ ගබඩා කර ඇති සියල්ල පසුරු පුවරුවට පිටපත් කරයි';

  @override
  String get settingsDeleteEverything => 'සියල්ල මකන්න';

  @override
  String get settingsRemovesAllAssessmentsAnd =>
      'සියලුම් තක්සේරු සහ මතක් කිරීම් ස්ථිරවම ඉවත් කරයි';

  @override
  String get settingsServer => 'සේවාදායකය';

  @override
  String get settingsModel => 'ආකෘතිය';

  @override
  String get settingsMedications => 'ඖෂධ';

  @override
  String get settingsApp => 'යෙදුම';

  @override
  String get settingsPurpose => 'අරමුණ';

  @override
  String get settingsDeleteEverything2 => 'සියල්ල මකන්නද?';

  @override
  String get settingsAllYourAssessmentsAnd =>
      'ඔබගේ සියලුම් තක්සේරු සහ මතක් කිරීම් මෙම උපාංගයෙන් ඉවත් කෙරේ. මෙය අහෝසි කළ නොහැක.';

  @override
  String get settingsKeepMyData => 'මගේ දත්ත තබා ගන්න';

  @override
  String get settingsEverythingHasBeenDeleted => 'සියල්ල මකා දමා ඇත';

  @override
  String get settingsYourDataStaysHere => 'ඔබගේ දත්ත මෙහිම පවතී';

  @override
  String get settingsAssessmentsAndRemindersAre =>
      'තක්සේරු සහ මතක් කිරීම් ගබඩා කර ඇත්තේ මෙම දුරකථනයේ පමණි. ගිණුමක් නැත, කිසිවක් කොතැනකවත් උඩුගත කිරීම හෝ උපස්ථ කිරීම සිදු නොවේ.';

  @override
  String get settingsYourAnswersAreSent =>
      'ලකුණු ලබා දීම සඳහා ඔබගේ පිළිතුරු පුරෝකථන සේවාදායකයට යවනු ලබන අතර, ප්‍රතිඵලය වහාම ආපසු ලැබේ. එහි කිසිවක් තබා නොගැනේ.';

  @override
  String get settingsAssessments => 'තක්සේරු';

  @override
  String get settingsReminders => 'මතක් කිරීම්';

  @override
  String get startupConnecting => 'සම්බන්ධ වෙමින්…';

  @override
  String get trendsYourTrends => 'ඔබගේ ප්‍රවණතා';

  @override
  String get trendsProbabilityOfHighRisk => 'Probability of high risk';

  @override
  String get trendsTheModelsOwnLikelihood =>
      'එක් එක් තක්සේරුවේදී, ඔබගේ ජීවන තත්ත්වය පිරිහීමේ ඉහළ අවදානමක පවතින බවට ආකෘතිය දක්වන සම්භාවිතාව.';

  @override
  String get trendsAssessmentsInThisPeriod => 'මෙම කාලය තුළ තක්සේරු';

  @override
  String get trendsATrendNeedsAt =>
      'ප්‍රවණතාවක් සඳහා සැසඳීමට අවම වශයෙන් තක්සේරු දෙකක් අවශ්‍ය වේ. ඔබගේ අවදානම වෙනස් වන ආකාරය බැලීමට තවත් එකක් සම්පූර්ණ කරන්න.';

  @override
  String get durationUnder3Months => 'මාස 3කට අඩු';

  @override
  String get duration3To6Months => 'මාස 3 සිට 6 දක්වා';

  @override
  String get duration6To12Months => 'මාස 6 සිට 12 දක්වා';

  @override
  String get duration1To2Years => 'අවුරුදු 1 සිට 2 දක්වා';

  @override
  String get durationOver2Years => 'අවුරුදු 2කට වඩා';

  @override
  String get onsetWithinDays => 'දින කිහිපයක් ඇතුළත';

  @override
  String get onset1To2Weeks => 'සති 1 සිට 2 දක්වා';

  @override
  String get onset3To4Weeks => 'සති 3 සිට 4 දක්වා';

  @override
  String get sleepVeryPoor => 'ඉතා දුර්වල';

  @override
  String get sleepPoor => 'දුර්වල';

  @override
  String get sleepFair => 'සාමාන්‍ය';

  @override
  String get sleepGood => 'හොඳ';

  @override
  String get sleepVeryGood => 'ඉතා හොඳ';

  @override
  String get sleepExcellent => 'විශිෂ්ට';

  @override
  String assessmentMedicineCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ඖෂධ $count',
      one: 'ඖෂධ 1',
    );
    return '$_temp0';
  }

  @override
  String assessmentStepOf(int step, int total) {
    return 'පියවර $step / $total';
  }

  @override
  String assessmentBetween(int low, int high) {
    return '$low සහ $high අතර';
  }

  @override
  String assessmentChooseUpTo(int max) {
    return 'උපරිම $maxක් තෝරා, එක් එක් එක කෙතරම් දරුණුද යන්න සඳහන් කරන්න.';
  }

  @override
  String assessmentShowAllEffects(int count) {
    return 'සියලු අතුරු ආබාධ පෙන්වන්න (තවත් $count)';
  }

  @override
  String historyNothingReportedOn(String date) {
    return '$date දින කිසිවක් වාර්තා නොවූ බැවින්, එදින සඳහා අවදානම් මට්ටමක් ගණනය නොකෙරිණි.';
  }

  @override
  String medicationsChooseEvery(int max) {
    return 'ඔබ නිතිපතා ගන්නා සියලුම් ඖෂධ, උපරිම $maxක් දක්වා තෝරන්න. පෙන්වා ඇති දෛනික මාත්‍රාව පරීක්ෂා කර, එය ඔබගේ නොවේ නම් වෙනස් කරන්න.';
  }

  @override
  String medicationsNoMatch(String query) {
    return '\"$query\" ට ගැළපෙන ඖෂධයක් නැත.';
  }

  @override
  String medicationsMaxAtATime(int max) {
    return 'එකවර ඖෂධ $maxක් දක්වා තක්සේරු කළ හැක.';
  }

  @override
  String get predictionNotAHealthCheck =>
      'මෙය ඔබ අද අපට පැවසූ දේ පිළිබිඹු කරන අතර සෞඛ්‍ය පරීක්ෂණයක් නොවේ.';

  @override
  String get medicalDisclaimer =>
      'QoLGuard රෝග විනිශ්චය නොකරන අතර සෞඛ්‍ය වෘත්තිකයෙකුගේ උපදෙස් වෙනුවට නොවේ. කිසියම් ඖෂධයක් වෙනස් කිරීමට පෙර සැමවිටම ඔබගේ වෛද්‍යවරයා හෝ ඖෂධවේදියා සමඟ සාකච්ඡා කරන්න.';

  @override
  String remindersNext(String when) {
    return 'ඊළඟට $when';
  }

  @override
  String remindersTodayAt(String time) {
    return 'අද $timeට';
  }

  @override
  String remindersTomorrowAt(String time) {
    return 'හෙට $timeට';
  }

  @override
  String remindersDayAt(String day, String time) {
    return '$day $timeට';
  }

  @override
  String settingsCopiedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'තක්සේරු $countක් පසුරු පුවරුවට පිටපත් කරන ලදී',
      one: 'තක්සේරු 1ක් පසුරු පුවරුවට පිටපත් කරන ලදී',
    );
    return '$_temp0';
  }

  @override
  String startupLogo(String appName) {
    return '$appName ලාංඡනය';
  }

  @override
  String trendsSummaryLine(int count, String percent) {
    return 'තක්සේරු $count · ඉහළම $percent%';
  }

  @override
  String get stepAboutYouTitle => 'ඔබ ගැන';

  @override
  String get stepAboutYouSubtitle =>
      'ඔබගේ විස්තර සහ ඔබ මෙම ඖෂධ කොතරම් කාලයක් සිට ගන්නවාද යන්න';

  @override
  String get stepSideEffectsTitle => 'Side effects';

  @override
  String get stepSideEffectsSubtitle =>
      'The effects you have noticed since starting';

  @override
  String get stepDailyLifeTitle => 'දෛනික ජීවිතය';

  @override
  String get stepDailyLifeSubtitle =>
      'සාමාන්‍ය සතියක් තුළ නින්ද, ක්‍රියාකාරකම් සහ පුරුදු';

  @override
  String get medicationsSearchByNameOr => 'නම හෝ ඖෂධ වර්ගය අනුව සොයන්න';

  @override
  String get errorUnreachableTitle => 'සේවාදායකයට සම්බන්ධ විය නොහැක';

  @override
  String get errorGenericTitle => 'යමක් වැරදී ඇත';

  @override
  String get errorUnreachable =>
      'QoLGuard සේවාදායකයට සම්බන්ධ විය නොහැක. එය ක්‍රියාත්මක වන බව සහ යෙදුම නිවැරදි ලිපිනයට යොමු කර ඇති බව පරීක්ෂා කරන්න.';

  @override
  String get errorTimeout =>
      'සේවාදායකය ප්‍රතිචාර දක්වන්නට වැඩි කාලයක් ගත්තා. කරුණාකර නැවත උත්සාහ කරන්න.';

  @override
  String get errorCancelled => 'ඉල්ලීම අවලංගු කළා.';

  @override
  String get errorValidation =>
      'ඇතුළත් කළ සමහර විස්තර පිළිගත් පරාසයෙන් පිටත පවතී.';

  @override
  String get errorNotSupported => 'එම ඖෂධයට සහාය නොදක්වේ.';

  @override
  String get errorServer =>
      'සේවාදායකයට ඉල්ලීම සම්පූර්ණ කළ නොහැකි විය. කරුණාකර නැවත උත්සාහ කරන්න.';

  @override
  String get assessmentCouldNotGetResult => 'ප්‍රතිඵලයක් ලබා ගත නොහැකි විය.';

  @override
  String remindersNotificationTitle(String medicine) {
    return 'ඔබගේ $medicine ගැනීමට කාලයයි';
  }

  @override
  String get remindersNotificationBody => 'ගත් පසු මෙය තට්ටු කරන්න.';

  @override
  String get learnArticlesHeading => 'ලිපි';

  @override
  String get learnTipsHeading => 'සෞඛ්‍ය උපදෙස්';
}
