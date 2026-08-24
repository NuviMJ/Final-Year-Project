import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../medications/domain/medication.dart';
import '../domain/field_spec.dart';

/// The four steps of the assessment, and which fields belong to each.
///
/// The backend returns the sixteen fields as a flat list — it describes the
/// model's contract, not a user journey. Grouping them is a presentation
/// decision, made here so a patient answers related questions together rather
/// than working through one long form.
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
      subtitle: 'Basic details used to interpret your other answers',
      fieldNames: <String>['Age', 'Gender'],
    ),
    AssessmentStep(
      title: 'Your medication',
      subtitle: 'How much you take, and for how long',
      fieldNames: <String>[
        'Dosage_mg',
        'Treatment_Duration_Days',
      ],
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
///
/// Answers are held in a map keyed by the model's own field names rather than
/// as sixteen typed properties. The whole point of driving the form from
/// `/schema` is that this layer does not need to know what the fields are —
/// typing them here would reintroduce the duplication the schema endpoint
/// exists to remove.
class AssessmentDraft {
  const AssessmentDraft({
    this.medications = const <Medication>[],
    this.answers = const <String, Object>{},
    this.stepIndex = 0,
  });

  final List<Medication> medications;

  final Map<String, Object> answers;
  final int stepIndex;
  T
  Medication? get medication =>
      medications.isEmpty ? null : medications.first;

  bool get isFirstStep => stepIndex == 0;
  bool get isLastStep => stepIndex == AssessmentStep.all.length - 1;
  AssessmentStep get step => AssessmentStep.all[stepIndex];
  double get progress => (stepIndex + 1) / AssessmentStep.all.length;

  AssessmentDraft copyWith({
    List<Medication>? medications,
    Map<String, Object>? answers,
    int? stepIndex,
  }) {
    return AssessmentDraft(
      medications: medications ?? this.medications,
      answers: answers ?? this.answers,
      stepIndex: stepIndex ?? this.stepIndex,
    );
  }

  /// The request body for `POST /predict`.
  Map<String, dynamic> toRequest() => <String, dynamic>{
        'Drug_Name': medication!.name,
        ...answers,
      };
}

class AssessmentController extends Notifier<AssessmentDraft> {
  @override
  AssessmentDraft build() => const AssessmentDraft();

  /// Begin a new assessment for a single medication.
  void start(Medication medication, AssessmentSchema schema) =>
      startAll(<Medication>[medication], schema);

  
  void startAll(List<Medication> medications, AssessmentSchema schema) {
    final Map<String, Object> answers = <String, Object>{
      for (final FieldSpec field in schema.fields)
        field.name: field.initialValue(),
    };

    if (answers.containsKey('Dosage_mg')) {
      answers['Dosage_mg'] = _defaultDose(medications.first);
    }
    if (answers.containsKey('Concomitant_Drug_Count')) {
      answers['Concomitant_Drug_Count'] =
          concomitantCountFor(medications.length);
    }

    state = AssessmentDraft(
      medications: List<Medication>.unmodifiable(medications),
      answers: answers,
      stepIndex: 0,
    );
  }

  static const int maxMedications = 5;

  static double concomitantCountFor(int selectedCount) =>
      (selectedCount - 1).clamp(0, 3).toDouble();

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

  /// Prefers a typical prescribed dose over the arithmetic midpoint, since
  /// "40 mg" is a dose a patient recognises and "45 mg" is not.
  static double _defaultDose(Medication medication) {
    if (medication.typicalDoses.isEmpty) {
      return (medication.doseMin + medication.doseMax) / 2;
    }
    return medication.typicalDoses[medication.typicalDoses.length ~/ 2];
  }
}

final NotifierProvider<AssessmentController, AssessmentDraft>
    assessmentControllerProvider =
    NotifierProvider<AssessmentController, AssessmentDraft>(
  AssessmentController.new,
);
