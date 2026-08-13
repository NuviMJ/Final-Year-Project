import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:qolguard/features/assessment/application/assessment_controller.dart';
import 'package:qolguard/features/assessment/domain/field_spec.dart';
import 'package:qolguard/features/medications/domain/medication.dart';
import 'package:qolguard/features/prediction/domain/prediction.dart';

/// A cut-down copy of what `GET /api/v1/schema` returns, covering one field of
/// each kind the form has to render.
final Map<String, dynamic> _schemaJson = <String, dynamic>{
  'fields': <dynamic>[
    <String, dynamic>{
      'name': 'Age',
      'type': 'number',
      'required': true,
      'description': 'Patient age in years',
      'min': 18.0,
      'max': 90.0,
    },
    <String, dynamic>{
      'name': 'Gender',
      'type': 'categorical_ordered',
      'required': true,
      'allowed_values': <dynamic>['Female', 'Male'],
    },
    <String, dynamic>{
      'name': 'Dosage_mg',
      'type': 'number',
      'required': true,
      'min': 2.5,
      'max': 4000.0,
    },
    <String, dynamic>{
      'name': 'Treatment_Duration_Days',
      'type': 'number',
      'required': true,
      'min': 1.0,
      'max': 1825.0,
    },
    <String, dynamic>{
      'name': 'Side_Effect',
      'type': 'categorical',
      'required': true,
      'allowed_values': <dynamic>['Fatigue', 'Muscle Pain', 'Nausea'],
    },
  ],
  'class_order': <dynamic>['Low', 'Medium', 'High'],
};

const Medication _atorvastatin = Medication(
  name: 'Atorvastatin',
  drugClass: 'Statins',
  doseUnit: 'mg/day',
  doseMin: 10,
  doseMax: 80,
  typicalDoses: <double>[10, 20, 40, 80],
);

void main() {
  group('FieldSpec', () {
    final AssessmentSchema schema = AssessmentSchema.fromJson(_schemaJson);

    test('turns the model’s column names into readable labels', () {
      expect(schema.byName('Treatment_Duration_Days')!.label,
          'Treatment duration days');
    });

    test('seeds numeric fields at the midpoint of the trained range', () {
      // Age spans 18-90, so the midpoint is 54 — a valid value, which means the
      // form is submittable before the patient touches anything.
      expect(schema.byName('Age')!.initialValue(), 54.0);
    });

    test('seeds a categorical field with its first allowed value', () {
      expect(schema.byName('Side_Effect')!.initialValue(), 'Fatigue');
    });

    test('distinguishes ordered categories, which render as a ranked control', () {
      expect(schema.byName('Gender')!.isOrdered, isTrue);
      expect(schema.byName('Side_Effect')!.isOrdered, isFalse);
    });
  });

  group('AssessmentController', () {
    late ProviderContainer container;
    late AssessmentController controller;
    final AssessmentSchema schema = AssessmentSchema.fromJson(_schemaJson);

    setUp(() {
      container = ProviderContainer();
      controller = container.read(assessmentControllerProvider.notifier);
    });

    tearDown(() => container.dispose());

    test('starting an assessment seeds every field from the schema', () {
      controller.start(_atorvastatin, schema);
      final AssessmentDraft draft = container.read(assessmentControllerProvider);

      expect(draft.medication, _atorvastatin);
      expect(draft.stepIndex, 0);
      for (final FieldSpec field in schema.fields) {
        expect(draft.answers.containsKey(field.name), isTrue,
            reason: '${field.name} was not seeded');
      }
    });

    test('dose is seeded from the drug, not from the schema midpoint', () {
      controller.start(_atorvastatin, schema);
      final AssessmentDraft draft = container.read(assessmentControllerProvider);

      // The schema's global range spans every drug (2.5-4000), so its midpoint
      // of about 2000 mg would be nonsense for a statin capped at 80.
      expect(draft.answers['Dosage_mg'], 40.0);
      expect(draft.answers['Dosage_mg'] as double,
          inInclusiveRange(_atorvastatin.doseMin, _atorvastatin.doseMax));
    });

    test('the request body carries the drug name alongside every answer', () {
      controller.start(_atorvastatin, schema);
      controller.setAnswer('Age', 62.0);

      final Map<String, dynamic> body =
          container.read(assessmentControllerProvider).toRequest();

      expect(body['Drug_Name'], 'Atorvastatin');
      expect(body['Age'], 62.0);
      expect(body.keys.length, schema.fields.length + 1);
    });

    test('steps advance and reverse without running past either end', () {
      controller.start(_atorvastatin, schema);

      controller.previous(); // already at the first step
      expect(container.read(assessmentControllerProvider).stepIndex, 0);

      for (int i = 0; i < 10; i++) {
        controller.next();
      }
      expect(container.read(assessmentControllerProvider).isLastStep, isTrue);
      expect(container.read(assessmentControllerProvider).stepIndex,
          AssessmentStep.all.length - 1);
    });

    test('a rejected field sends the patient back to the step holding it', () {
      controller.start(_atorvastatin, schema);
      controller.next();
      controller.next();

      // Mirrors a 422 naming Age, which lives on the first step.
      controller.goToStepContaining('Age');

      expect(container.read(assessmentControllerProvider).stepIndex, 0);
    });

    test('every schema field appears in exactly one step', () {
      final List<String> grouped = <String>[
        for (final AssessmentStep step in AssessmentStep.all) ...step.fieldNames,
      ];

      expect(grouped.toSet().length, grouped.length,
          reason: 'a field is listed in more than one step');
      expect(grouped.length, 16,
          reason: 'the model takes 16 user-supplied fields');
    });
  });

  group('Prediction', () {
    test('parses the prediction response', () {
      final Prediction prediction = Prediction.fromJson(<String, dynamic>{
        'risk_category': 'High',
        'confidence': 0.9997,
        'probabilities': <String, dynamic>{
          'Low': 0.0,
          'Medium': 0.0003,
          'High': 0.9997,
        },
        'model_version': 'xgboost-3class-49f-300r',
      });

      expect(prediction.riskCategory, 'High');
      expect(prediction.confidence, closeTo(0.9997, 1e-6));
      expect(prediction.probabilities.values.reduce((double a, double b) => a + b),
          closeTo(1.0, 1e-3));
    });

    test('wording prompts consultation rather than instructing', () {
      const Prediction high = Prediction(
        riskCategory: 'High',
        confidence: 0.9,
        probabilities: <String, double>{'Low': 0.05, 'Medium': 0.05, 'High': 0.9},
        modelVersion: 'test',
      );

      // The system is decision support; it must never tell a patient to change
      // or stop a medication.
      expect(high.summary.toLowerCase(), contains('doctor'));
      expect(high.summary.toLowerCase(), isNot(contains('stop taking')));
    });
  });
}
