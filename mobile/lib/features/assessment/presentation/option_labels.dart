import '../../../l10n/app_localizations.dart';
import '../application/assessment_controller.dart';
import '../domain/duration_band.dart';
import '../domain/onset_band.dart';
import '../domain/sleep_quality_scale.dart';

extension AssessmentStepLabels on AssessmentStep {
  String title(AppLocalizations l10n) => switch (id) {
        AssessmentStepId.aboutYou => l10n.stepAboutYouTitle,
        AssessmentStepId.sideEffects => l10n.stepSideEffectsTitle,
        AssessmentStepId.dailyLife => l10n.stepDailyLifeTitle,
      };

  String subtitle(AppLocalizations l10n) => switch (id) {
        AssessmentStepId.aboutYou => l10n.stepAboutYouSubtitle,
        AssessmentStepId.sideEffects => l10n.stepSideEffectsSubtitle,
        AssessmentStepId.dailyLife => l10n.stepDailyLifeSubtitle,
      };
}

extension DurationBandLabel on DurationBand {
  String label(AppLocalizations l10n) => switch (this) {
        DurationBand.under3Months => l10n.durationUnder3Months,
        DurationBand.months3To6 => l10n.duration3To6Months,
        DurationBand.months6To12 => l10n.duration6To12Months,
        DurationBand.years1To2 => l10n.duration1To2Years,
        DurationBand.over2Years => l10n.durationOver2Years,
      };
}

extension OnsetBandLabel on OnsetBand {
  String label(AppLocalizations l10n) => switch (this) {
        OnsetBand.withinDays => l10n.onsetWithinDays,
        OnsetBand.weeks1To2 => l10n.onset1To2Weeks,
        OnsetBand.weeks3To4 => l10n.onset3To4Weeks,
      };
}

String sleepQualityLabel(AppLocalizations l10n, double value) =>
    switch (SleepQualityScale.levelFor(value)) {
      4 => l10n.sleepVeryPoor,
      5 => l10n.sleepPoor,
      6 => l10n.sleepFair,
      7 => l10n.sleepGood,
      8 => l10n.sleepVeryGood,
      _ => l10n.sleepExcellent,
    };

/// Face and word together, e.g. "🙂 Good".
String sleepQualityWithFace(AppLocalizations l10n, double value) =>
    '${SleepQualityScale.faces[SleepQualityScale.levelFor(value)]} '
    '${sleepQualityLabel(l10n, value)}';
