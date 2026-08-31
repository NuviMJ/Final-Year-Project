import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../medications/domain/medication.dart';
import '../domain/field_spec.dart';

class AssessmentStep {
  const AssessmentStep({
    required this.title,
    required this.subtitle,
    required this.fieldNames,
  });

  final String title;
  final String subtitle;
  final List<String> fieldNames;

  static const List<AssessmentStep> all = <AssessmentStep>[
    AssessmentStep(
      title: 'About you',
      subtitle: 'Your details, and how long you have been on these medicines',
      fieldNames: <String>['Age', 'Gender', 'Treatment_Duration_Days'],
    ),
    AssessmentStep(
      title: 'Side effect',
      subtitle: 'The main effect you have noticed since starting',
      fieldNames: <String>[
        'Side_Effect',
        'Severity',
        'Seriousness',
        'Onset_Days',
      ],
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
    this.answers = const <String, Object>{},
    this.stepIndex = 0,
  });

  final List<Medication> medications;
  final Map<String, double> doses;
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
    Map<String, Object>? answers,
    int? stepIndex,
  }) {
    return AssessmentDraft(
      medications: medications ?? this.medications,
      doses: doses ?? this.doses,
      answers: answers ?? this.answers,
      stepIndex: stepIndex ?? this.stepIndex,
    );
  }

  Map<String, dynamic> toRequestFor(Medication medication) =>
      <String, dynamic>{
        'Drug_Name': medication.name,
        ...answers,
        if (answers.containsKey('Dosage_mg')) 'Dosage_mg': doseFor(medication),
      };

  Map<String, dynamic> toRequest() => toRequestFor(medication!);
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

  /// Change one medication's dose after the assessment has begun.
  void setDose(String medicationName, double dose) {
    state = state.copyWith(
      doses: <String, double>{...state.doses, medicationName: dose},
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

  void goToStepContaining(String field) {
    for (int i = 0; i < AssessmentStep.all.length; i++) {
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
