import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../medications/domain/medication.dart';
import '../domain/field_spec.dart';
import '../domain/symptom_report.dart';

class AssessmentStep {
  const AssessmentStep({
    required this.title,
    required this.subtitle,
    required this.fieldNames,
    this.collectsSymptoms = false,
  });

  final String title;
  final String subtitle;
  final List<String> fieldNames;

  /// Whether this step also shows the symptom selector.
  final bool collectsSymptoms;

  static const List<AssessmentStep> all = <AssessmentStep>[
    AssessmentStep(
      title: 'About you',
      subtitle: 'Your details, and how long you have been on these medicines',
      fieldNames: <String>['Age', 'Gender', 'Treatment_Duration_Days'],
    ),
    // Side_Effect and Severity are collected by the symptom selector, which can
    // report several at once. Seriousness is derived from severity.
    AssessmentStep(
      title: 'Side effects',
      subtitle: 'The effects you have noticed since starting',
      fieldNames: <String>['Onset_Days'],
      collectsSymptoms: true,
    ),
    AssessmentStep(
      title: 'Daily life',
      subtitle: 'Sleep, activity and habits over a typical week',
      fieldNames: <String>[
        'Sleep_Quality',
        'Sleep_Disorders',
        'Physical_Activity_Level',
        'Daily_Steps',
        'Dietary_Habits',
        'Smoker',
        'Alcohol_Use',
      ],
    ),
  ];
}

/// An assessment in progress.

class AssessmentDraft {
  const AssessmentDraft({
    this.medications = const <Medication>[],
    this.doses = const <String, double>{},
    this.symptoms = const <SymptomReport>[],
    this.hasSideEffects,
    this.answers = const <String, Object>{},
    this.stepIndex = 0,
  });

  final List<Medication> medications;
  final Map<String, double> doses;

  /// Every effect reported, each with its own severity.
  final List<SymptomReport> symptoms;

  /// Null until the patient answers. False skips the model entirely.
  final bool? hasSideEffects;

  bool get reportsNoSideEffects => hasSideEffects == false;

  /// The symptoms step cannot be left until the yes/no question is answered,
  /// and a yes needs at least one effect.
  bool get canLeaveCurrentStep =>
      !step.collectsSymptoms ||
      reportsNoSideEffects ||
      (hasSideEffects == true && symptoms.isNotEmpty);

  final Map<String, Object> answers;
  final int stepIndex;

  Medication? get medication =>
      medications.isEmpty ? null : medications.first;
  double doseFor(Medication medication) =>
      doses[medication.name] ?? medication.defaultDose;

  bool get isFirstStep => stepIndex == 0;
  bool get isLastStep => stepIndex == AssessmentStep.all.length - 1;
  AssessmentStep get step => AssessmentStep.all[stepIndex];
  double get progress => (stepIndex + 1) / AssessmentStep.all.length;

  AssessmentDraft copyWith({
    List<Medication>? medications,
    Map<String, double>? doses,
    List<SymptomReport>? symptoms,
    bool? hasSideEffects,
    Map<String, Object>? answers,
    int? stepIndex,
  }) {
    return AssessmentDraft(
      medications: medications ?? this.medications,
      doses: doses ?? this.doses,
      symptoms: symptoms ?? this.symptoms,
      hasSideEffects: hasSideEffects ?? this.hasSideEffects,
      answers: answers ?? this.answers,
      stepIndex: stepIndex ?? this.stepIndex,
    );
  }

  /// One request: this medication scored against this one reported effect.
  Map<String, dynamic> toRequestFor(
    Medication medication,
    SymptomReport symptom,
  ) =>
      <String, dynamic>{
        'Drug_Name': medication.name,
        ...answers,
        if (answers.containsKey('Dosage_mg')) 'Dosage_mg': doseFor(medication),
        if (answers.containsKey('Side_Effect'))
          'Side_Effect': symptom.sideEffect,
        if (answers.containsKey('Severity')) 'Severity': symptom.severity,
        if (answers.containsKey('Seriousness'))
          'Seriousness': symptom.seriousness,
      };
}

class AssessmentController extends Notifier<AssessmentDraft> {
  @override
  AssessmentDraft build() => const AssessmentDraft();

  static const int maxMedications = 5;

  static double concomitantCountFor(int selectedCount) =>
      (selectedCount - 1).clamp(0, 3).toDouble();

  void start(Medication medication, AssessmentSchema schema) =>
      startAll(<Medication>[medication], schema);

  void startAll(
    List<Medication> medications,
    AssessmentSchema schema, {
    Map<String, double>? doses,
  }) {
    final Map<String, Object> answers = <String, Object>{
      for (final FieldSpec field in schema.fields)
        field.name: field.initialValue(),
    };

    final Map<String, double> resolved = <String, double>{
      for (final Medication drug in medications)
        drug.name: doses?[drug.name] ?? drug.defaultDose,
    };

    if (answers.containsKey('Dosage_mg')) {
      answers['Dosage_mg'] = resolved[medications.first.name]!;
    }
    if (answers.containsKey('Concomitant_Drug_Count')) {
      answers['Concomitant_Drug_Count'] =
          concomitantCountFor(medications.length);
    }

    state = AssessmentDraft(
      medications: List<Medication>.unmodifiable(medications),
      doses: Map<String, double>.unmodifiable(resolved),
      answers: answers,
      stepIndex: 0,
    );
  }

  /// Answering "no" clears any effects already picked.
  void setHasSideEffects(bool value) {
    state = state.copyWith(
      hasSideEffects: value,
      symptoms: value ? state.symptoms : const <SymptomReport>[],
    );
  }

  /// Change one medication's dose after the assessment has begun.
  void setDose(String medicationName, double dose) {
    state = state.copyWith(
      doses: <String, double>{...state.doses, medicationName: dose},
    );
  }

  /// Add or remove a reported effect. At least one must always remain.
  void toggleSymptom(String sideEffect, String defaultSeverity) {
    final List<SymptomReport> current = state.symptoms;
    final bool present =
        current.any((SymptomReport s) => s.sideEffect == sideEffect);

    if (present) {
      state = state.copyWith(
        symptoms: current
            .where((SymptomReport s) => s.sideEffect != sideEffect)
            .toList(),
      );
      return;
    }

    if (current.length >= SymptomReport.maxPerAssessment) return;
    state = state.copyWith(
      symptoms: <SymptomReport>[
        ...current,
        SymptomReport(sideEffect: sideEffect, severity: defaultSeverity),
      ],
    );
  }

  void setSymptomSeverity(String sideEffect, String severity) {
    state = state.copyWith(
      symptoms: state.symptoms
          .map((SymptomReport s) =>
              s.sideEffect == sideEffect ? s.withSeverity(severity) : s)
          .toList(),
    );
  }

  void setAnswer(String field, Object value) {
    state = state.copyWith(
      answers: <String, Object>{...state.answers, field: value},
    );
  }

  void next() {
    if (!state.isLastStep) {
      state = state.copyWith(stepIndex: state.stepIndex + 1);
    }
  }

  void previous() {
    if (!state.isFirstStep) {
      state = state.copyWith(stepIndex: state.stepIndex - 1);
    }
  }

  static const Set<String> _symptomFields = <String>{
    'Side_Effect',
    'Severity',
    'Seriousness',
  };

  void goToStepContaining(String field) {
    for (int i = 0; i < AssessmentStep.all.length; i++) {
      if (_symptomFields.contains(field) &&
          AssessmentStep.all[i].collectsSymptoms) {
        state = state.copyWith(stepIndex: i);
        return;
      }
      if (AssessmentStep.all[i].fieldNames.contains(field)) {
        state = state.copyWith(stepIndex: i);
        return;
      }
    }
  }

}

final NotifierProvider<AssessmentController, AssessmentDraft>
    assessmentControllerProvider =
    NotifierProvider<AssessmentController, AssessmentDraft>(
  AssessmentController.new,
);
