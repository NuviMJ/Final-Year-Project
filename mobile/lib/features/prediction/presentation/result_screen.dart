import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_constants.dart';
import '../../../core/router/app_router.dart';
import '../../../core/widgets/app_state_views.dart';
import '../../assessment/application/assessment_controller.dart';
import '../../assessment/domain/duration_band.dart';
import '../data/prediction_repository.dart';
import '../domain/assessment_outcome.dart';
import '../domain/prediction.dart';

/// The outcome of one assessment.

class ResultScreen extends ConsumerWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<AssessmentOutcome?> result =
        ref.watch(predictionControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your result'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: result.when(
          loading: () => const AppLoadingView(
            message: 'Analyzing your health information…',
          ),
          error: (Object error, StackTrace _) => AppErrorView(
            error: error,
            onRetry: () => context.go(AppRoutes.assessment),
          ),
          data: (AssessmentOutcome? outcome) =>
              outcome == null || outcome.isEmpty
                  ? AppErrorView(
                      error: 'No result to show.',
                      onRetry: () => context.go(AppRoutes.medications),
                    )
                  : _Result(outcome: outcome),
        ),
      ),
    );
  }
}

class _Result extends ConsumerWidget {
  const _Result({required this.outcome});

  final AssessmentOutcome outcome;

  /// The medication of greatest concern. Never an average across medications:
  /// see [AssessmentOutcome] for why that would report the wrong direction.
  MedicationPrediction get worst => outcome.highest;

  Prediction get prediction => worst.prediction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final AssessmentDraft draft = ref.watch(assessmentControllerProvider);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      children: <Widget>[
        Center(
          child: Container(
            width: 168,
            height: 168,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: prediction.color.withValues(alpha: 0.12),
              border: Border.all(color: prediction.color, width: 3),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  prediction.riskCategory.toUpperCase(),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: prediction.color,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text('RISK', style: theme.textTheme.labelMedium),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          outcome.isSingle
              ? worst.medication.name
              : 'Highest risk: ${worst.medication.name}',
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        if (!outcome.isSingle) ...<Widget>[
          const SizedBox(height: 4),
          Text(
            outcome.bandSummary,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
        const SizedBox(height: 16),
        Text(
          prediction.summary,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge,
        ),
        const SizedBox(height: 28),
        Text(
          'How confident is this?',
          style: theme.textTheme.titleSmall
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        for (final String category in const <String>['Low', 'Medium', 'High'])
          _ProbabilityBar(
            label: category,
            value: prediction.probabilities[category] ?? 0,
            isPredicted: category == prediction.riskCategory,
          ),
        const SizedBox(height: 24),
        if (draft.medication != null) ...<Widget>[
          Text(
            'Based on',
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
                  // Describes the medication this result is about, which is
                  // the highest-risk one — not simply the first selected.
                  _Detail(
                    label: 'Medication',
                    value: '${worst.medication.name} '
                        '(${worst.medication.doseLabel(worst.dose)})',
                  ),
                  _Detail(
                    label: 'Side effect',
                    value: '${draft.answers['Side_Effect']} · '
                        '${draft.answers['Severity']}',
                  ),
                  _Detail(
                    label: 'Treatment so far',
                    // The band the patient chose, not the day count sent to
                    // the model — they answered the former.
                    value: DurationBand.forDays(
                      (draft.answers[DurationBand.fieldName] as num?)
                              ?.toDouble() ??
                          0,
                    ).label,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
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
        const SizedBox(height: 20),
        FilledButton(
          onPressed: () {
            ref.read(predictionControllerProvider.notifier).reset();
            context.go(AppRoutes.medications);
          },
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text('Start another assessment'),
          ),
        ),
        const SizedBox(height: 12),
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

class _ProbabilityBar extends StatelessWidget {
  const _ProbabilityBar({
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

class _Detail extends StatelessWidget {
  const _Detail({required this.label, required this.value});

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
            width: 120,
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
