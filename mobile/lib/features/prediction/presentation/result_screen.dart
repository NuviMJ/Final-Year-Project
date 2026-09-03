import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_constants.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_state_views.dart';
import '../../assessment/application/assessment_controller.dart';
import '../data/prediction_repository.dart';
import '../domain/assessment_outcome.dart';
import '../domain/prediction.dart';
import 'widgets/result_summary.dart';

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
                  : outcome.noSideEffectsReported
                      ? const _NoSideEffectsResult()
                      : _Result(outcome: outcome),
        ),
      ),
    );
  }
}

/// Shown when the patient reported no side effects. The model is not
/// consulted, so this states what was reported rather than a risk band.
class _NoSideEffectsResult extends ConsumerWidget {
  const _NoSideEffectsResult();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 32),
      children: <Widget>[
        Center(
          child: Container(
            width: 148,
            height: 148,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.riskLow.withValues(alpha: 0.12),
              border: Border.all(color: AppColors.riskLow, width: 3),
            ),
            child: const Center(
              child: Text('🎉', style: TextStyle(fontSize: 56)),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Good news!',
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Text(
          'You haven\u2019t reported any symptoms or side effects from your '
          'medication, which is a positive sign for your quality of life.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge,
        ),
        const SizedBox(height: 10),
        Text(
          'Keep taking care of yourself and keep following your healthcare '
          'provider\u2019s advice. 💚',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 28),
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
                  'This reflects what you told us today and is not a health '
                  'check. ${AppConstants.medicalDisclaimer}',
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
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
      ],
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
        const SizedBox(height: 28),
        ResultSummary(outcome: outcome, draft: draft),
        const SizedBox(height: 12),
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
