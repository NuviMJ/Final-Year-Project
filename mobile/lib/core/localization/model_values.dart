import '../../l10n/app_localizations.dart';

/// Display text for the model's own field names and values.
///
/// Only what the patient reads is translated. Answers are stored and sent to
/// the backend exactly as the model was trained on them (`No_Alcohol`,
/// `Dizziness`, `Mild`), whatever language the screen is in.

String riskLabel(AppLocalizations l10n, String category) => switch (category) {
      'Low' => l10n.riskLow,
      'Medium' => l10n.riskMedium,
      'High' => l10n.riskHigh,
      _ => category,
    };

String sideEffectName(AppLocalizations l10n, String value) => switch (value) {
      'Abdominal Pain' => l10n.sideEffectAbdominalPain,
      'Anxiety' => l10n.sideEffectAnxiety,
      'Constipation' => l10n.sideEffectConstipation,
      'Diarrhea' => l10n.sideEffectDiarrhea,
      'Dizziness' => l10n.sideEffectDizziness,
      'Dry Cough' => l10n.sideEffectDryCough,
      'Dry Mouth' => l10n.sideEffectDryMouth,
      'Fatigue' => l10n.sideEffectFatigue,
      'Headache' => l10n.sideEffectHeadache,
      'Heartburn' => l10n.sideEffectHeartburn,
      'Hypoglycemia' => l10n.sideEffectHypoglycemia,
      'Insomnia' => l10n.sideEffectInsomnia,
      'Liver Toxicity' => l10n.sideEffectLiverToxicity,
      'Muscle Pain' => l10n.sideEffectMusclePain,
      'Nausea' => l10n.sideEffectNausea,
      'Palpitations' => l10n.sideEffectPalpitations,
      'Rash' => l10n.sideEffectRash,
      'Stomach Pain' => l10n.sideEffectStomachPain,
      'Sweating' => l10n.sideEffectSweating,
      'Swelling' => l10n.sideEffectSwelling,
      'Weight Gain' => l10n.sideEffectWeightGain,
      _ => value,
    };

String valueLabel(AppLocalizations l10n, String field, String value) =>
    switch ((field, value)) {
      ('Side_Effect', _) => sideEffectName(l10n, value),
      ('Severity', 'Mild') => l10n.severityMild,
      ('Severity', 'Moderate') => l10n.severityModerate,
      ('Severity', 'Severe') => l10n.severitySevere,
      ('Gender', 'Female') => l10n.genderFemale,
      ('Gender', 'Male') => l10n.genderMale,
      ('Smoker' || 'Sleep_Disorders', 'No' || 'no') => l10n.valueNo,
      ('Smoker' || 'Sleep_Disorders', 'Yes' || 'yes') => l10n.valueYes,
      ('Alcohol_Use', 'No_Alcohol') => l10n.alcoholNone,
      ('Alcohol_Use', 'Occasional') => l10n.alcoholOccasional,
      ('Alcohol_Use', 'Frequent') => l10n.alcoholFrequent,
      ('Physical_Activity_Level', 'low') => l10n.levelLow,
      ('Physical_Activity_Level', 'medium') => l10n.levelMedium,
      ('Physical_Activity_Level', 'high') => l10n.levelHigh,
      ('Dietary_Habits', 'unhealthy') => l10n.dietUnhealthy,
      ('Dietary_Habits', 'medium') => l10n.dietMedium,
      ('Dietary_Habits', 'healthy') => l10n.dietHealthy,
      _ => humanise(value),
    };

/// Falls back to [fallback] for a field the app has no wording for, such as
/// one added by a retrained model.
String fieldLabel(AppLocalizations l10n, String field, String fallback) =>
    switch (field) {
      'Age' => l10n.fieldAge,
      'Gender' => l10n.fieldGender,
      'Smoker' => l10n.fieldSmoker,
      'Alcohol_Use' => l10n.fieldAlcoholUse,
      'Sleep_Quality' => l10n.fieldSleepQuality,
      'Physical_Activity_Level' => l10n.fieldPhysicalActivityLevel,
      'Daily_Steps' => l10n.fieldDailySteps,
      'Dietary_Habits' => l10n.fieldDietaryHabits,
      'Sleep_Disorders' => l10n.fieldSleepDisorders,
      'Treatment_Duration_Days' => l10n.fieldTreatmentDuration,
      'Onset_Days' => l10n.assessmentWhenDidTheseStart,
      'Dosage_mg' => l10n.assessmentDailyDose,
      _ => fallback,
    };

String? fieldDescription(AppLocalizations l10n, String field, String? fallback) =>
    switch (field) {
      'Age' => l10n.fieldAgeHelp,
      'Gender' => l10n.fieldGenderHelp,
      'Smoker' => l10n.fieldSmokerHelp,
      'Alcohol_Use' => l10n.fieldAlcoholUseHelp,
      'Sleep_Quality' => l10n.fieldSleepQualityHelp,
      'Physical_Activity_Level' => l10n.fieldPhysicalActivityLevelHelp,
      'Daily_Steps' => l10n.fieldDailyStepsHelp,
      'Dietary_Habits' => l10n.fieldDietaryHabitsHelp,
      'Sleep_Disorders' => l10n.fieldSleepDisordersHelp,
      'Treatment_Duration_Days' => l10n.fieldTreatmentDurationHelp,
      'Onset_Days' => l10n.fieldOnsetHelp,
      'Dosage_mg' => l10n.fieldDosageHelp,
      _ => fallback,
    };

/// `No_Alcohol` becomes "No alcohol".
String humanise(String value) {
  if (value.isEmpty) return value;
  final String spaced = value.replaceAll('_', ' ');
  return spaced[0].toUpperCase() + spaced.substring(1);
}
