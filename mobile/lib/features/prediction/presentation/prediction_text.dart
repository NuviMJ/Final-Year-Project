import '../../../core/localization/model_values.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/assessment_outcome.dart';
import '../domain/prediction.dart';

extension PredictionText on Prediction {
  /// Wording chosen to prompt a conversation, never to instruct. The system is
  /// decision support: it must not tell a patient what to do about their
  /// medication.
  String summary(AppLocalizations l10n) => switch (riskCategory) {
        'Low' => l10n.predictionSummaryLow,
        'Medium' => l10n.predictionSummaryMedium,
        _ => l10n.predictionSummaryHigh,
      };
}

extension AssessmentOutcomeText on AssessmentOutcome {
  /// e.g. "1 of 3 medicines is in the Medium band".
  String bandSummary(AppLocalizations l10n) {
    final int total = worstPerMedication.length;
    final String category = highest.prediction.riskCategory;
    final int count = bandCounts[category] ?? 0;
    final String band = riskLabel(l10n, category);
    return total == 1
        ? l10n.predictionBandSummarySingle(band)
        : l10n.predictionBandSummary(count, total, band);
  }
}
