import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/router/app_router.dart';
import '../../../core/widgets/app_state_views.dart';
import '../../prediction/data/prediction_repository.dart';
import '../application/assessment_controller.dart';
import '../data/schema_repository.dart';
import '../domain/field_spec.dart';
import 'widgets/schema_field_input.dart';

/// The four-step assessment, built entirely from the backend's `/schema`.
///
/// Nothing here knows what the model's fields are called or what values they
/// accept — that comes from the API. Adding a field to the model requires only
/// listing it in the relevant [AssessmentStep].
class AssessmentScreen extends ConsumerWidget {
  const AssessmentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<AssessmentSchema> schema =
        ref.watch(assessmentSchemaProvider);
    final AssessmentDraft draft = ref.watch(assessmentControllerProvider);

    if (draft.medication == null) {
      // Reached by deep link or hot restart without a medication chosen.
      return Scaffold(
        appBar: AppBar(title: const Text('Assessment')),
        body: AppErrorView(
          error: 'No medication selected.',
          onRetry: () => context.go(AppRoutes.medications),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(draft.medication!.name),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => draft.isFirstStep
              ? context.go(AppRoutes.medications)
              : ref.read(assessmentControllerProvider.notifier).previous(),
        ),
      ),
      body: SafeArea(
        child: schema.when(
          loading: () => const AppLoadingView(message: 'Loading questions…'),
          error: (Object error, StackTrace _) => AppErrorView(
            error: error,
            onRetry: () => ref.invalidate(assessmentSchemaProvider),
          ),
          data: (AssessmentSchema contract) =>
              _Form(schema: contract, draft: draft),
        ),
      ),
    );
  }
}

class _Form extends ConsumerWidget {
  const _Form({required this.schema, required this.draft});

  final AssessmentSchema schema;
  final AssessmentDraft draft;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final AssessmentController controller =
        ref.read(assessmentControllerProvider.notifier);
    final AsyncValue<dynamic> submission =
        ref.watch(predictionControllerProvider);

    // A 422 names the field that was rejected, so send the patient back to the
    // step containing it rather than showing a banner they cannot act on.
    final Map<String, String> fieldErrors =
        submission.hasError && submission.error is ApiException
            ? (submission.error! as ApiException).fieldErrors
            : const <String, String>{};

    return Column(
      children: <Widget>[
        LinearProgressIndicator(value: draft.progress),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Step ${draft.stepIndex + 1} of ${AssessmentStep.all.length}',
                style: theme.textTheme.labelMedium
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 4),
              Text(
                draft.step.title,
                style: theme.textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                draft.step.subtitle,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            children: <Widget>[
              for (final String name in draft.step.fieldNames)
                if (schema.byName(name) case final FieldSpec spec)
                  SchemaFieldInput(
                    spec: spec,
                    value: draft.answers[name] ?? spec.initialValue(),
                    medication: draft.medication,
                    errorText: fieldErrors[name],
                    onChanged: (Object value) =>
                        controller.setAnswer(name, value),
                  ),
            ],
          ),
        ),
        _Actions(draft: draft, isSubmitting: submission.isLoading),
      ],
    );
  }
}

class _Actions extends ConsumerWidget {
  const _Actions({required this.draft, required this.isSubmitting});

  final AssessmentDraft draft;
  final bool isSubmitting;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AssessmentController controller =
        ref.read(assessmentControllerProvider.notifier);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        child: Row(
          children: <Widget>[
            if (!draft.isFirstStep) ...<Widget>[
              Expanded(
                child: OutlinedButton(
                  onPressed: isSubmitting ? null : controller.previous,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('Back'),
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              flex: 2,
              child: FilledButton(
                onPressed: isSubmitting
                    ? null
                    : () => _advance(context, ref, controller),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(draft.isLastStep ? 'Get my result' : 'Continue'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _advance(
    BuildContext context,
    WidgetRef ref,
    AssessmentController controller,
  ) async {
    if (!draft.isLastStep) {
      controller.next();
      return;
    }

    await ref
        .read(predictionControllerProvider.notifier)
        .submit(draft.toRequest());

    if (!context.mounted) return;

    final AsyncValue<dynamic> result = ref.read(predictionControllerProvider);
    if (result.hasError) {
      final Object error = result.error!;
      if (error is ApiException && error.isValidation &&
          error.fieldErrors.isNotEmpty) {
        // Return to the step holding the rejected field so the patient can see
        // and correct it in place.
        controller.goToStepContaining(error.fieldErrors.keys.first);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error is ApiException ? error.message : 'Could not get a result.',
          ),
        ),
      );
      return;
    }

    context.go(AppRoutes.result);
  }
}
