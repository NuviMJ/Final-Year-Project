import 'package:flutter/material.dart';

import '../../../assessment/application/assessment_controller.dart';
import '../../../assessment/domain/duration_band.dart';
import '../../../assessment/domain/onset_band.dart';
import '../../../assessment/domain/sleep_quality_scale.dart';
import '../../../assessment/domain/symptom_report.dart';
import '../../domain/assessment_outcome.dart';
import '../../../../l10n/app_localizations.dart';

/// What the patient told us, and the risk read back for each medicine.
class ResultSummary extends StatelessWidget {
  const ResultSummary({
    super.key,
    required this.outcome,
    required this.draft,
  });

  final AssessmentOutcome outcome;
  final AssessmentDraft draft;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          l10n.predictionYourSummary,
          style: theme.textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        _RiskChart(outcome: outcome),
        const SizedBox(height: 16),
        _Section(
          icon: '💊',
          title: l10n.predictionYourMedicines,
          rows: <_Row>[
            for (final MedicationPrediction result in outcome.byRiskDescending)
              _Row(
                result.medication.name,
                result.medication.doseLabel(result.dose),
              ),
          ],
        ),
        if (draft.symptoms.isNotEmpty)
          _Section(
            icon: '🩹',
            title: l10n.predictionSideEffectsYouReported,
            rows: <_Row>[
              for (final SymptomReport symptom in draft.symptoms)
                _Row(
                  SymptomReport.labelFor(symptom.sideEffect),
                  symptom.severity,
                ),
            ],
          ),
        _Section(
          icon: '📅',
          title: l10n.predictionTreatment,
          rows: <_Row>[
            _Row('Taking these', _band(DurationBand.fieldName)),
            if (draft.symptoms.isNotEmpty)
              _Row('Effects started', _band(OnsetBand.fieldName)),
          ],
        ),
        _Section(
          icon: '🌙',
          title: l10n.predictionDailyLife,
          rows: <_Row>[
            _Row('Sleep', _sleep()),
            _Row('Sleep problems', _text('Sleep_Disorders')),
            _Row('Activity', _text('Physical_Activity_Level')),
            _Row('Daily steps', _number('Daily_Steps')),
            _Row('Diet', _text('Dietary_Habits')),
            _Row('Smoker', _text('Smoker')),
            _Row('Alcohol', _text('Alcohol_Use')),
          ],
        ),
      ],
    );
  }

  double _value(String field) =>
      (draft.answers[field] as num?)?.toDouble() ?? 0;

  String _band(String field) => field == DurationBand.fieldName
      ? DurationBand.forDays(_value(field)).label
      : OnsetBand.forDays(_value(field)).label;

  String _sleep() {
    final int level = _value(SleepQualityScale.fieldName).round();
    return '${SleepQualityScale.faces[level] ?? ''} '
            '${SleepQualityScale.labelFor(level.toDouble())}'
        .trim();
  }

  String _number(String field) {
    final int value = _value(field).round();
    final String digits = value.toString();
    // Thousands separators, so 7000 reads as 7,000.
    final StringBuffer out = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) out.write(',');
      out.write(digits[i]);
    }
    return out.toString();
  }

  String _text(String field) {
    final String raw = draft.answers[field]?.toString() ?? '—';
    final String spaced = raw.replaceAll('_', ' ');
    return spaced.isEmpty
        ? '—'
        : spaced[0].toUpperCase() + spaced.substring(1);
  }
}

/// One labelled bar per medicine, showing the probability of the High band.
class _RiskChart extends StatelessWidget {
  const _RiskChart({required this.outcome});

  final AssessmentOutcome outcome;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              l10n.predictionRiskByMedicine,
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            for (final MedicationPrediction result in outcome.byRiskDescending)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            result.medication.name,
                            style: theme.textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                        Text(
                          result.prediction.riskCategory,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: result.prediction.color,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 550),
                        curve: Curves.easeOutCubic,
                        tween: Tween<double>(
                          begin: 0,
                          end: result.highRiskProbability.clamp(0.0, 1.0),
                        ),
                        builder: (_, double value, __) =>
                            LinearProgressIndicator(
                          value: value,
                          minHeight: 10,
                          backgroundColor: theme.colorScheme.surfaceContainerHighest,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            result.prediction.color,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Text(
              l10n.predictionBarsShowTheChance,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _Row {
  const _Row(this.label, this.value);

  final String label;
  final String value;
}

class _Section extends StatelessWidget {
  const _Section({
    required this.icon,
    required this.title,
    required this.rows,
  });

  final String icon;
  final String title;
  final List<_Row> rows;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text(icon, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              for (final _Row row in rows)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        flex: 5,
                        child: Text(
                          row.label,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: Text(
                          row.value,
                          textAlign: TextAlign.right,
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
