import '../../../l10n/app_localizations.dart';
import '../../../core/localization/model_values.dart';
import '../../assessment/domain/duration_band.dart';
import '../../assessment/domain/onset_band.dart';
import '../../assessment/domain/sleep_quality_scale.dart';
import '../../assessment/domain/symptom_report.dart';
import '../../assessment/presentation/option_labels.dart';
import '../domain/assessment_record.dart';

extension AssessmentRecordText on AssessmentRecord {
  /// e.g. "Omeprazole, Atorvastatin and Metformin"
  String medicinesLabel(AppLocalizations l10n) {
    final List<String> names =
        medicines.map((RecordedMedicine m) => m.name).toList();
    if (names.isEmpty) return '';
    if (names.length == 1) return names.first;
    return l10n.historyNamesAnd(
        names.sublist(0, names.length - 1).join(', '), names.last);
  }

  String sideEffectLabel(AppLocalizations l10n) {
    if (noSideEffectsReported) return l10n.historyNoSideEffectsReported;
    if (symptoms.isEmpty) return '';
    return symptoms
        .map((SymptomReport s) =>
            '${sideEffectName(l10n, s.sideEffect)} · '
            '${valueLabel(l10n, 'Severity', s.severity)}')
        .join(', ');
  }
}

/// Answers shown elsewhere, or sent to the model but never chosen directly.
const Set<String> hiddenAnswers = <String>{
  'Dosage_mg',
  'Side_Effect',
  'Severity',
  'Seriousness',
  'Concomitant_Drug_Count',
};

String answerLabel(AppLocalizations l10n, String field, Object value) {
  final double number = value is num ? value.toDouble() : 0;
  if (value is num && field == DurationBand.fieldName) {
    return DurationBand.forDays(number).label(l10n);
  }
  if (value is num && field == OnsetBand.fieldName) {
    return OnsetBand.forDays(number).label(l10n);
  }
  if (value is num && field == SleepQualityScale.fieldName) {
    return sleepQualityWithFace(l10n, number);
  }
  return valueLabel(l10n, field, value.toString());
}
