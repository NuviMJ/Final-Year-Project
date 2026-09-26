import '../../../l10n/app_localizations.dart';
import '../../../core/localization/model_values.dart';
import '../../assessment/domain/symptom_report.dart';
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
