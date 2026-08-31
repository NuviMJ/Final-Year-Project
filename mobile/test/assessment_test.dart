import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:qolguard/features/assessment/application/assessment_controller.dart';
import 'package:qolguard/features/assessment/domain/duration_band.dart';
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
    <String, dynamic>{
      'name': 'Concomitant_Drug_Count',
      'type': 'number',
      'required': true,
      'min': 0.0,
      'max': 3.0,
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

/// Four more, so a realistic polypharmacy selection can be assembled.
const Medication _metformin = Medication(
  name: 'Metformin',
  drugClass: 'Non-sulfonylureas',
  doseUnit: 'mg/day',
  doseMin: 500,
  doseMax: 2000,
  typicalDoses: <double>[500, 850, 1000, 1500, 2000],
);

const Medication _omeprazole = Medication(
  name: 'Omeprazole',
  drugClass: 'Proton pump inhibitors',
  doseUnit: 'mg/day',
  doseMin: 10,
  doseMax: 40,
  typicalDoses: <double>[10, 20, 40],
);

const Medication _lisinopril = Medication(
  name: 'Lisinopril',
  drugClass: 'Angiotensin Converting Enzyme Inhibitors',
  doseUnit: 'mg/day',
  doseMin: 5,
  doseMax: 40,
  typicalDoses: <double>[5, 10, 20, 30, 40],
);

const Medication _insulin = Medication(
  name: 'Insulin',
  drugClass: 'Insulin',
  doseUnit: 'IU/day',
  doseMin: 10,
  doseMax: 80,
  typicalDoses: <double>[10, 20, 30, 40, 60, 80],
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

    test('every field the patient answers appears in exactly one step', () {
      final List<String> grouped = <String>[
        for (final AssessmentStep step in AssessmentStep.all) ...step.fieldNames,
      ];

      expect(grouped.toSet().length, grouped.length,
          reason: 'a field is listed in more than one step');
      expect(grouped.length, 14,
          reason: 'the model takes 16 user-supplied fields; '
              'Concomitant_Drug_Count is derived from the medication list and '
              'Dosage_mg is answered per medication on the selection screen');
      expect(grouped, isNot(contains('Concomitant_Drug_Count')),
          reason: 'asking for it would invite an answer contradicting the '
              'medication list the patient already gave');
      expect(grouped, isNot(contains('Dosage_mg')),
          reason: 'one dose field cannot describe four tablets');
    });

    test('the side effect step follows the patient details step', () {
      expect(AssessmentStep.all[0].title, 'About you');
      expect(AssessmentStep.all[1].title, 'Side effect');
      expect(AssessmentStep.all.length, 3);
    });

    test('each medication carries its own dose', () {
      controller.startAll(
        <Medication>[_atorvastatin, _metformin],
        schema,
        doses: <String, double>{'Atorvastatin': 20, 'Metformin': 1500},
      );
      final AssessmentDraft draft = container.read(assessmentControllerProvider);

      expect(draft.doseFor(_atorvastatin), 20.0);
      expect(draft.doseFor(_metformin), 1500.0);
      expect(draft.toRequestFor(_atorvastatin)['Dosage_mg'], 20.0);
      expect(draft.toRequestFor(_metformin)['Dosage_mg'], 1500.0);
      expect(draft.toRequestFor(_metformin)['Drug_Name'], 'Metformin');
    });

    test('a medication with no dose given falls back to its usual dose', () {
      controller.startAll(<Medication>[_atorvastatin, _metformin], schema);
      final AssessmentDraft draft = container.read(assessmentControllerProvider);

      expect(draft.doseFor(_atorvastatin), 40.0);
      expect(draft.doseFor(_metformin), 1000.0);
    });

    test('every medication shares the answers the patient gave once', () {
      controller.startAll(<Medication>[_atorvastatin, _metformin], schema);
      controller.setAnswer('Age', 71.0);
      final AssessmentDraft draft = container.read(assessmentControllerProvider);

      expect(draft.toRequestFor(_atorvastatin)['Age'], 71.0);
      expect(draft.toRequestFor(_metformin)['Age'], 71.0);
    });

    test('a dose can be changed after the assessment has started', () {
      controller.startAll(<Medication>[_atorvastatin], schema);
      controller.setDose('Atorvastatin', 80);

      expect(
        container.read(assessmentControllerProvider).doseFor(_atorvastatin),
        80.0,
      );
    });

    test('several medications are carried through the whole assessment', () {
      controller.startAll(
        <Medication>[_atorvastatin, _metformin, _omeprazole],
        schema,
      );
      final AssessmentDraft draft = container.read(assessmentControllerProvider);

      expect(draft.medications.length, 3);
      expect(draft.medications.map((Medication m) => m.name).toList(),
          <String>['Atorvastatin', 'Metformin', 'Omeprazole']);
    });

    test('the other-medicine count is derived from the selection', () {
      controller.startAll(
        <Medication>[_atorvastatin, _metformin, _omeprazole],
        schema,
      );

      // Three medicines means two others alongside whichever is being scored.
      expect(
        container
            .read(assessmentControllerProvider)
            .answers['Concomitant_Drug_Count'],
        2.0,
      );
    });

    test('a single medication reports no other medicines', () {
      controller.start(_atorvastatin, schema);

      expect(
        container
            .read(assessmentControllerProvider)
            .answers['Concomitant_Drug_Count'],
        0.0,
      );
    });

    test('the other-medicine count saturates at the trained ceiling', () {
      // The model was trained on 0-3 concomitant drugs. Five medications means
      // four others, which it has no way to represent — so the value must be
      // clamped rather than sent outside the range the model has seen.
      controller.startAll(
        <Medication>[
          _atorvastatin,
          _metformin,
          _omeprazole,
          _lisinopril,
          _insulin,
        ],
        schema,
      );

      expect(
        container
            .read(assessmentControllerProvider)
            .answers['Concomitant_Drug_Count'],
        3.0,
      );
      expect(AssessmentController.concomitantCountFor(9), 3.0);
    });

    test('dose limits follow the first medication in the selection', () {
      controller.startAll(<Medication>[_atorvastatin, _metformin], schema);
      final AssessmentDraft draft = container.read(assessmentControllerProvider);

      expect(draft.medication, _atorvastatin);
      expect(draft.answers['Dosage_mg'], 40.0);
    });

    test('a field absent from the schema is never invented', () {
      // The deployed schema always carries Concomitant_Drug_Count, but a
      // reduced one must not gain a key the model never asked for.
      final AssessmentSchema reduced =
          AssessmentSchema.fromJson(<String, dynamic>{
        'fields': <dynamic>[
          <String, dynamic>{
            'name': 'Age',
            'type': 'number',
            'required': true,
            'min': 18.0,
            'max': 90.0,
          },
        ],
        'class_order': <dynamic>['Low', 'Medium', 'High'],
      });

      controller.startAll(<Medication>[_atorvastatin, _metformin], reduced);
      final AssessmentDraft draft = container.read(assessmentControllerProvider);

      expect(draft.answers.containsKey('Concomitant_Drug_Count'), isFalse);
      expect(draft.answers.containsKey('Dosage_mg'), isFalse);
      expect(draft.toRequest().keys.length, 2); // Age + Drug_Name
    });

    test('at most five medications may be assessed together', () {
      expect(AssessmentController.maxMedications, 5);
    });
  });

  group('DurationBand', () {
    test('covers the trained range with no gap and no overlap', () {
      expect(DurationBand.all.first.minDays, 1);
      expect(DurationBand.all.last.maxDays, 1825);

      for (int i = 1; i < DurationBand.all.length; i++) {
        expect(DurationBand.all[i].minDays,
            DurationBand.all[i - 1].maxDays + 1,
            reason: 'band ${DurationBand.all[i].label} does not abut the one '
                'before it');
      }
    });

    test('every band sends a value inside its own range', () {
      for (final DurationBand band in DurationBand.all) {
        expect(band.contains(band.representativeDays.toDouble()), isTrue,
            reason: '${band.label} sends a value outside itself');
      }
    });

    test('a stored day count maps back to the band the patient chose', () {
      expect(DurationBand.forDays(45).label, 'Less than 3 months');
      expect(DurationBand.forDays(136).label, '3 to 6 months');
      expect(DurationBand.forDays(274).label, '6 to 12 months');
      expect(DurationBand.forDays(548).label, '1 to 2 years');
      expect(DurationBand.forDays(1278).label, 'More than 2 years');
    });

    test('a day count outside the trained range still resolves to a band', () {
      // The schema midpoint seeds this field at 913 days before the patient
      // answers, and a stored assessment could predate a range change.
      expect(DurationBand.forDays(913).label, 'More than 2 years');
      expect(DurationBand.forDays(0).label, 'Less than 3 months');
      expect(DurationBand.forDays(99999).label, 'More than 2 years');
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
