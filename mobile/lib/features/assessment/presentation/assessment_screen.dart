import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_error_text.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/router/app_router.dart';
import '../../../core/widgets/app_state_views.dart';
import '../../history/data/assessment_store.dart';
import '../../history/domain/assessment_record.dart';
import '../../prediction/data/prediction_repository.dart';
import '../../prediction/domain/assessment_outcome.dart';
import '../application/assessment_controller.dart';
import '../data/schema_repository.dart';
import '../../medications/domain/medication.dart';
import '../domain/field_spec.dart';
import '../domain/symptom_report.dart';
import 'widgets/schema_field_input.dart';
import 'option_labels.dart';
import 'widgets/symptom_selector.dart';
import '../../../l10n/app_localizations.dart';

/// The four-step assessment, built entirely from the backend's `/schema`.
///
/// Nothing here knows what the model's fields are called or what values they
/// accept — that comes from the API. Adding a field to the model requires only
/// listing it in the relevant [AssessmentStep].
class AssessmentScreen extends ConsumerWidget {
  const AssessmentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AsyncValue<AssessmentSchema> schema =
        ref.watch(assessmentSchemaProvider);
    final AssessmentDraft draft = ref.watch(assessmentControllerProvider);

    if (draft.medication == null) {
      // Reached by deep link or hot restart without a medication chosen.
      return Scaffold(
        appBar: AppBar(title: Text(l10n.assessmentAssessment)),
        body: AppErrorView(
          error: l10n.assessmentNoMedicationSelected,
          onRetry: () => context.go(AppRoutes.medications),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          draft.medications.length == 1
              ? draft.medication!.name
              : l10n.assessmentMedicineCount(draft.medications.length),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => draft.isFirstStep
              ? context.go(AppRoutes.medications)
              : ref.read(assessmentControllerProvider.notifier).previous(),
        ),
      ),
      body: SafeArea(
        child: schema.when(
          loading: () => AppLoadingView(message: l10n.assessmentLoadingQuestions),
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
    final AppLocalizations l10n = AppLocalizations.of(context);
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
                l10n.assessmentStepOf(draft.stepIndex + 1, AssessmentStep.all.length),
                style: theme.textTheme.labelMedium
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 4),
              Text(
                draft.step.title(l10n),
                style: theme.textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                draft.step.subtitle(l10n),
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
              if (draft.step.collectsSymptoms)
                Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: SymptomSelector(
                    options:
                        schema.byName('Side_Effect')?.allowedValues ??
                            const <String>[],
                    severityOptions:
                        schema.byName('Severity')?.allowedValues ??
                            const <String>[],
                    selected: draft.symptoms,
                    hasSideEffects: draft.hasSideEffects,
                    onHasSideEffectsChanged: controller.setHasSideEffects,
                    errorText: fieldErrors['Side_Effect'] ??
                        fieldErrors['Severity'] ??
                        fieldErrors['Seriousness'],
                    onToggle: (String name) => controller.toggleSymptom(
                      name,
                      schema.byName('Severity')?.allowedValues?.first ?? 'Mild',
                    ),
                    onSeverityChanged: controller.setSymptomSeverity,
                  ),
                ),
              if (!draft.step.collectsSymptoms ||
                  draft.hasSideEffects == true)
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
        _Actions(
          draft: draft,
          isSubmitting: submission.isLoading,
          canContinue: draft.canLeaveCurrentStep,
        ),
      ],
    );
  }
}

class _Actions extends ConsumerWidget {
  const _Actions({
    required this.draft,
    required this.isSubmitting,
    required this.canContinue,
  });

  final AssessmentDraft draft;
  final bool isSubmitting;
  final bool canContinue;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
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
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text(l10n.assessmentBack),
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              flex: 2,
              child: FilledButton(
                onPressed: isSubmitting || !canContinue
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
                      : Text(draft.isLastStep
                          ? l10n.assessmentGetMyResult
                          : l10n.commonContinue),
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
    final AppLocalizations l10n = AppLocalizations.of(context);
    if (!draft.isLastStep) {
      controller.next();
      return;
    }

    if (draft.reportsNoSideEffects) {
      ref.read(predictionControllerProvider.notifier).skipForNoSideEffects();
      await ref.read(assessmentHistoryProvider.notifier).add(
            AssessmentRecord.create(
              takenAt: DateTime.now(),
              medicines: <RecordedMedicine>[
                for (final Medication drug in draft.medications)
                  RecordedMedicine(
                    name: drug.name,
                    doseUnit: drug.doseUnit,
                    dose: draft.doseFor(drug),
                  ),
              ],
              symptoms: const <SymptomReport>[],
              answers: draft.answers,
              noSideEffectsReported: true,
            ),
          );
      if (context.mounted) context.go(AppRoutes.result);
      return;
    }

    // One request per selected medication and reported effect.
    await ref.read(predictionControllerProvider.notifier).submit(draft);

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
            error is ApiException
                ? error.localized(l10n)
                : l10n.assessmentCouldNotGetResult,
          ),
        ),
      );
      return;
    }

    // Persist before navigating, so the result the patient is about to read is
    // already in their history rather than appearing only if they look later.
    //
    // History still stores one entry per assessment, recording the medication
    // of greatest concern. Storing every medication separately is a change to
    // the record format and to the trend view, handled on its own.
    final AssessmentOutcome? outcome =
        ref.read(predictionControllerProvider).value;
    if (outcome != null && !outcome.isEmpty) {
      await ref.read(assessmentHistoryProvider.notifier).add(
            AssessmentRecord.create(
              takenAt: DateTime.now(),
              medicines: <RecordedMedicine>[
                for (final MedicationPrediction result
                    in outcome.byRiskDescending)
                  RecordedMedicine(
                    name: result.medication.name,
                    doseUnit: result.medication.doseUnit,
                    dose: result.dose,
                    sideEffect: result.symptom.sideEffect,
                    prediction: result.prediction,
                  ),
              ],
              symptoms: draft.symptoms,
              answers: draft.answers,
            ),
          );
    }

    if (!context.mounted) return;
    context.go(AppRoutes.result);
  }
}
