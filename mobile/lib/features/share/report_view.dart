import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/config/app_constants.dart';
import '../../core/localization/model_values.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../assessment/domain/symptom_report.dart';
import '../history/domain/assessment_record.dart';
import '../history/presentation/record_text.dart';
import '../prediction/domain/prediction.dart';
import '../prediction/presentation/prediction_text.dart';

/// One assessment laid out as a shareable report.
///
/// Drawn off-screen into an image, so it takes its strings as [l10n] and uses
/// fixed light colours: the file looks the same whatever the phone's theme.
class ReportView extends StatelessWidget {
  const ReportView({super.key, required this.record, required this.l10n});

  static const double width = 420;

  final AssessmentRecord record;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final Prediction? prediction = record.prediction;
    final String takenOn =
        DateFormat('d MMMM yyyy, HH:mm', l10n.localeName).format(record.takenAt);

    return Container(
      width: width,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(
                AppConstants.appName,
                style: text.titleLarge?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  takenOn,
                  textAlign: TextAlign.end,
                  style: _muted(text.bodySmall),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            l10n.reportTitle,
            style: text.titleMedium?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Divider(height: 28, color: AppColors.outline),
          _Heading(l10n.predictionYourResult),
          if (prediction == null)
            _Banner(
              colour: AppColors.riskLow,
              title: l10n.historyNoSideEffectsReported,
            )
          else
            _Banner(
              colour: prediction.color,
              title: riskLabel(l10n, prediction.riskCategory).toUpperCase(),
              body: prediction.summary(l10n),
            ),
          _Heading(l10n.historyMedicines),
          for (final RecordedMedicine medicine in record.byRiskDescending)
            _MedicineRow(medicine: medicine, l10n: l10n),
          _Heading(l10n.historySideEffects),
          if (record.symptoms.isEmpty)
            _Line(l10n.historyNoneReported, '')
          else
            for (final SymptomReport symptom in record.symptoms)
              _Line(
                sideEffectName(l10n, symptom.sideEffect),
                valueLabel(l10n, 'Severity', symptom.severity),
              ),
          _Heading(l10n.reportPatientDetails),
          for (final MapEntry<String, Object> entry in record.answers.entries)
            if (!hiddenAnswers.contains(entry.key))
              _Line(
                fieldLabel(l10n, entry.key, humanise(entry.key)),
                answerLabel(l10n, entry.key, entry.value),
              ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.outline),
            ),
            child: Text(l10n.medicalDisclaimer, style: _muted(text.bodySmall)),
          ),
          const SizedBox(height: 12),
          Text(
            prediction == null
                ? l10n.reportCreatedWith
                : '${l10n.reportCreatedWith} · '
                    '${l10n.modelVersion(prediction.modelVersion)}',
            style: _muted(text.labelSmall),
          ),
        ],
      ),
    );
  }
}

TextStyle? _muted(TextStyle? style) =>
    style?.copyWith(color: AppColors.textSecondary);

class _Heading extends StatelessWidget {
  const _Heading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 6),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: AppColors.primaryDark,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.colour, required this.title, this.body});

  final Color colour;
  final String title;
  final String? body;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colour.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colour.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: text.titleMedium
                ?.copyWith(color: colour, fontWeight: FontWeight.bold),
          ),
          if (body != null) ...<Widget>[
            const SizedBox(height: 6),
            Text(
              body!,
              style: text.bodyMedium?.copyWith(color: AppColors.textPrimary),
            ),
          ],
        ],
      ),
    );
  }
}

class _MedicineRow extends StatelessWidget {
  const _MedicineRow({required this.medicine, required this.l10n});

  final RecordedMedicine medicine;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final Prediction? prediction = medicine.prediction;
    final String? odds = prediction == null
        ? null
        : <String>['Low', 'Medium', 'High'].map((String band) {
            final double value = (prediction.probabilities[band] ?? 0) * 100;
            return '${riskLabel(l10n, band)} ${value.toStringAsFixed(1)}%';
          }).join(' · ');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  '${medicine.name} · ${medicine.doseLabel}',
                  style: text.bodyMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (prediction != null)
                Text(
                  riskLabel(l10n, prediction.riskCategory),
                  style: text.labelLarge?.copyWith(
                    color: prediction.color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
          if (medicine.sideEffect != null)
            Text(
              sideEffectName(l10n, medicine.sideEffect!),
              style: _muted(text.bodySmall),
            ),
          if (odds != null)
            Text(
              '${l10n.historyProbabilities}: $odds',
              style: _muted(text.bodySmall),
            ),
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final TextStyle? style = Theme.of(context)
        .textTheme
        .bodyMedium
        ?.copyWith(color: AppColors.textPrimary);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(child: Text(label, style: _muted(style))),
          const SizedBox(width: 12),
          Expanded(child: Text(value, style: style, textAlign: TextAlign.end)),
        ],
      ),
    );
  }
}
