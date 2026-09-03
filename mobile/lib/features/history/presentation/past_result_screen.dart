import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/config/app_constants.dart';
import '../../../core/router/app_router.dart';
import '../../../core/widgets/app_state_views.dart';
import '../data/assessment_store.dart';
import '../../../core/theme/app_colors.dart';
import '../../assessment/domain/duration_band.dart';
import '../../assessment/domain/onset_band.dart';
import '../../assessment/domain/sleep_quality_scale.dart';
import '../../assessment/domain/symptom_report.dart';
import '../../prediction/domain/prediction.dart';
import '../domain/assessment_record.dart';

class PastResultScreen extends ConsumerWidget {
  const PastResultScreen({super.key, required this.recordId});

  final String recordId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<AssessmentRecord> records = ref.watch(assessmentHistoryProvider);
    final AssessmentRecord? record = records
        .where((AssessmentRecord candidate) => candidate.id == recordId)
        .firstOrNull;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Past result'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.history),
        ),
      ),
      body: SafeArea(
        child: record == null
            ? AppErrorView(
                error: 'That assessment is no longer stored on this device.',
                onRetry: () => context.go(AppRoutes.history),
              )
            : _Detail(record: record),
      ),
    );
  }
}

class _Detail extends StatelessWidget {
  const _Detail({required this.record});

  final AssessmentRecord record;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Prediction? prediction = record.prediction;
    final Color color = prediction?.color ?? AppColors.riskLow;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      children: <Widget>[
        Center(
          child: Text(
            DateFormat('EEEE d MMMM yyyy, HH:mm').format(record.takenAt),
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ),
        const SizedBox(height: 20),
        if (record.noSideEffectsReported)
          _NoEffectsBanner(takenAt: record.takenAt)
        else ...<Widget>[
          Center(
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: 0.12),
                border: Border.all(color: color, width: 3),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    prediction!.riskCategory.toUpperCase(),
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                  Text('RISK', style: theme.textTheme.labelSmall),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Probabilities',
            style: theme.textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          for (final String category in const <String>['Low', 'Medium', 'High'])
            _Bar(
              label: category,
              value: prediction.probabilities[category] ?? 0,
              isPredicted: category == prediction.riskCategory,
            ),
        ],
        const SizedBox(height: 24),
        Text(
          'What was reported',
          style: theme.textTheme.titleSmall
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _GroupTitle(icon: '\u{1F48A}', title: 'Medicines'),
                for (final RecordedMedicine medicine in record.byRiskDescending)
                  _Row(
                    label: medicine.name,
                    value: medicine.prediction == null
                        ? medicine.doseLabel
                        : '${medicine.doseLabel} · '
                            '${medicine.prediction!.riskCategory}',
                  ),
                const SizedBox(height: 10),
                _GroupTitle(icon: '\u{1FA79}', title: 'Side effects'),
                if (record.symptoms.isEmpty)
                  const _Row(label: 'None reported', value: '')
                else
                  for (final SymptomReport symptom in record.symptoms)
                    _Row(
                      label: SymptomReport.labelFor(symptom.sideEffect),
                      value: symptom.severity,
                    ),
                const SizedBox(height: 10),
                _GroupTitle(icon: '\u{1F4DD}', title: 'Everything else'),
                for (final MapEntry<String, Object> entry
                    in record.answers.entries)
                  if (!_hiddenAnswers.contains(entry.key))
                    _Row(
                      label: _humanise(entry.key),
                      value: _answerLabel(entry.key, entry.value),
                    ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(Icons.info_outline,
                  size: 20, color: theme.colorScheme.onSurfaceVariant),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  AppConstants.medicalDisclaimer,
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        if (prediction != null)
          Center(
            child: Text(
              'Model ${prediction.modelVersion}',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
      ],
    );
  }
}

/// Answers shown elsewhere, or sent to the model but never chosen directly.
const Set<String> _hiddenAnswers = <String>{
  'Dosage_mg',
  'Side_Effect',
  'Severity',
  'Seriousness',
  'Concomitant_Drug_Count',
};

String _answerLabel(String field, Object value) {
  final double number = value is num ? value.toDouble() : 0;
  if (value is num && field == DurationBand.fieldName) {
    return DurationBand.forDays(number).label;
  }
  if (value is num && field == OnsetBand.fieldName) {
    return OnsetBand.forDays(number).label;
  }
  if (value is num && field == SleepQualityScale.fieldName) {
    return '${SleepQualityScale.faces[number.round()] ?? ''} '
            '${SleepQualityScale.labelFor(number)}'
        .trim();
  }
  return _humanise(value.toString());
}

class _NoEffectsBanner extends StatelessWidget {
  const _NoEffectsBanner({required this.takenAt});

  final DateTime takenAt;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.riskLow.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.riskLow.withValues(alpha: 0.45)),
      ),
      child: Column(
        children: <Widget>[
          const Text('\u{1F389}', style: TextStyle(fontSize: 40)),
          const SizedBox(height: 10),
          Text(
            'On this day you had no side effects',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            'Nothing was reported on '
            '${DateFormat('d MMMM yyyy').format(takenAt)}, so no risk level '
            'was worked out for that day.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _GroupTitle extends StatelessWidget {
  const _GroupTitle({required this.icon, required this.title});

  final String icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: <Widget>[
          Text(icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context)
                .textTheme
                .labelLarge
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({
    required this.label,
    required this.value,
    required this.isPredicted,
  });

  final String label;
  final double value;
  final bool isPredicted;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color color = switch (label) {
      'Low' => const Color(0xFF16A34A),
      'Medium' => const Color(0xFFD97706),
      _ => const Color(0xFFDC2626),
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 64,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: isPredicted ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: value,
                minHeight: 10,
                backgroundColor: color.withValues(alpha: 0.12),
                valueColor: AlwaysStoppedAnimation<Color>(
                  isPredicted ? color : color.withValues(alpha: 0.45),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 56,
            child: Text(
              '${(value * 100).toStringAsFixed(1)}%',
              textAlign: TextAlign.right,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: isPredicted ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
          Expanded(child: Text(value, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}

String _humanise(String value) {
  if (value.isEmpty) return value;
  final String spaced = value.replaceAll('_', ' ');
  return spaced[0].toUpperCase() + spaced.substring(1);
}
