import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:qolguard/features/assessment/application/assessment_controller.dart';
import 'package:qolguard/features/assessment/domain/duration_band.dart';
import 'package:qolguard/features/assessment/domain/field_spec.dart';
import 'package:qolguard/features/assessment/domain/onset_band.dart';
import 'package:qolguard/features/assessment/domain/sleep_quality_scale.dart';
import 'package:qolguard/features/assessment/domain/symptom_report.dart';
import 'package:qolguard/features/assessment/presentation/option_labels.dart';
import 'package:qolguard/l10n/app_localizations.dart';
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
      'name': 'Severity',
      'type': 'categorical_ordered',
      'required': true,
      'allowed_values': <dynamic>['Mild', 'Moderate', 'Severe'],
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
      controller.setHasSideEffects(true);
      controller.toggleSymptom('Fatigue', 'Mild');
      controller.setAnswer('Age', 62.0);

      final AssessmentDraft draft = container.read(assessmentControllerProvider);
      final Map<String, dynamic> body =
          draft.toRequestFor(_atorvastatin, draft.symptoms.first);

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
      expect(grouped.length, 11,
          reason: 'of the 16 user-supplied fields, Concomitant_Drug_Count is '
              'derived, Dosage_mg is per medication on the selection screen, '
              'and Side_Effect, Severity and Seriousness come from the '
              'symptom selector');
      expect(grouped, isNot(contains('Concomitant_Drug_Count')),
          reason: 'asking for it would invite an answer contradicting the '
              'medication list the patient already gave');
      expect(grouped, isNot(contains('Dosage_mg')),
          reason: 'one dose field cannot describe four tablets');
      expect(grouped, isNot(contains('Side_Effect')));
      expect(grouped, isNot(contains('Severity')));
      expect(grouped, isNot(contains('Seriousness')));
    });

    test('the side effect step follows the patient details step', () {
      expect(AssessmentStep.all[0].id, AssessmentStepId.aboutYou);
      expect(AssessmentStep.all[1].id, AssessmentStepId.sideEffects);
      expect(AssessmentStep.all.length, 3);
    });

    test('each medication carries its own dose', () {
      controller.startAll(
        <Medication>[_atorvastatin, _metformin],
        schema,
        doses: <String, double>{'Atorvastatin': 20, 'Metformin': 1500},
      );
      controller.setHasSideEffects(true);
      controller.toggleSymptom('Fatigue', 'Mild');
      final AssessmentDraft draft = container.read(assessmentControllerProvider);

      expect(draft.doseFor(_atorvastatin), 20.0);
      expect(draft.doseFor(_metformin), 1500.0);
      final SymptomReport symptom = draft.symptoms.first;
      expect(draft.toRequestFor(_atorvastatin, symptom)['Dosage_mg'], 20.0);
      expect(draft.toRequestFor(_metformin, symptom)['Dosage_mg'], 1500.0);
      expect(draft.toRequestFor(_metformin, symptom)['Drug_Name'], 'Metformin');
    });

    test('a medication with no dose given falls back to its usual dose', () {
      controller.startAll(<Medication>[_atorvastatin, _metformin], schema);
      final AssessmentDraft draft = container.read(assessmentControllerProvider);

      expect(draft.doseFor(_atorvastatin), 40.0);
      expect(draft.doseFor(_metformin), 1000.0);
    });

    test('every medication shares the answers the patient gave once', () {
      controller.startAll(<Medication>[_atorvastatin, _metformin], schema);
      controller.setHasSideEffects(true);
      controller.toggleSymptom('Fatigue', 'Mild');
      controller.setAnswer('Age', 71.0);
      final AssessmentDraft draft = container.read(assessmentControllerProvider);

      final SymptomReport symptom = draft.symptoms.first;
      expect(draft.toRequestFor(_atorvastatin, symptom)['Age'], 71.0);
      expect(draft.toRequestFor(_metformin, symptom)['Age'], 71.0);
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
      expect(draft.symptoms, isEmpty);
    });

    test('at most five medications may be assessed together', () {
      expect(AssessmentController.maxMedications, 5);
    });

    test('an assessment starts with the side effect question unanswered', () {
      controller.start(_atorvastatin, schema);
      final AssessmentDraft draft = container.read(assessmentControllerProvider);

      expect(draft.hasSideEffects, isNull);
      expect(draft.symptoms, isEmpty);
    });

    test('answering no clears any effects and skips the model', () {
      controller.start(_atorvastatin, schema);
      controller.setHasSideEffects(true);
      controller.toggleSymptom('Fatigue', 'Mild');
      controller.setHasSideEffects(false);

      final AssessmentDraft draft = container.read(assessmentControllerProvider);
      expect(draft.reportsNoSideEffects, isTrue);
      expect(draft.symptoms, isEmpty);
    });

    test('several effects can be reported, each with its own severity', () {
      controller.start(_atorvastatin, schema);
      controller.setHasSideEffects(true);
      controller.toggleSymptom('Fatigue', 'Mild');
      controller.toggleSymptom('Nausea', 'Mild');
      controller.setSymptomSeverity('Nausea', 'Severe');
      final AssessmentDraft draft = container.read(assessmentControllerProvider);

      expect(draft.symptoms.length, 2);
      expect(draft.symptoms[0].severity, 'Mild');
      expect(draft.symptoms[1].severity, 'Severe');
    });

    test('a yes cannot be submitted without choosing an effect', () {
      controller.start(_atorvastatin, schema);
      controller.setHasSideEffects(true);
      controller.next();

      expect(
        container.read(assessmentControllerProvider).canLeaveCurrentStep,
        isFalse,
      );

      controller.toggleSymptom('Fatigue', 'Mild');
      expect(
        container.read(assessmentControllerProvider).canLeaveCurrentStep,
        isTrue,
      );
    });

    test('a no can be submitted with no effects chosen', () {
      controller.start(_atorvastatin, schema);
      controller.setHasSideEffects(false);
      controller.next();

      expect(
        container.read(assessmentControllerProvider).canLeaveCurrentStep,
        isTrue,
      );
    });

    test('no more than three effects are accepted', () {
      controller.start(_atorvastatin, schema);
      controller.setHasSideEffects(true);
      controller.toggleSymptom('Fatigue', 'Mild');
      controller.toggleSymptom('Nausea', 'Mild');
      controller.toggleSymptom('Muscle Pain', 'Mild');

      expect(
        container.read(assessmentControllerProvider).symptoms.length,
        SymptomReport.maxPerAssessment,
      );
    });

    test('an effect can be unticked', () {
      controller.start(_atorvastatin, schema);
      controller.setHasSideEffects(true);
      controller.toggleSymptom('Nausea', 'Mild');
      controller.toggleSymptom('Fatigue', 'Mild');
      controller.toggleSymptom('Fatigue', 'Mild');

      final AssessmentDraft draft = container.read(assessmentControllerProvider);
      expect(draft.symptoms.length, 1);
      expect(draft.symptoms.first.sideEffect, 'Nausea');
    });

    test('each request carries its own effect and derived seriousness', () {
      controller.start(_atorvastatin, schema);
      controller.setHasSideEffects(true);
      controller.toggleSymptom('Fatigue', 'Mild');
      controller.toggleSymptom('Nausea', 'Mild');
      controller.setSymptomSeverity('Nausea', 'Severe');
      final AssessmentDraft draft = container.read(assessmentControllerProvider);

      final Map<String, dynamic> first =
          draft.toRequestFor(_atorvastatin, draft.symptoms[0]);
      final Map<String, dynamic> second =
          draft.toRequestFor(_atorvastatin, draft.symptoms[1]);

      expect(first['Side_Effect'], 'Fatigue');
      expect(first['Severity'], 'Mild');
      expect(second['Side_Effect'], 'Nausea');
      expect(second['Severity'], 'Severe');
    });

    test('a rejected effect returns the patient to the symptoms step', () {
      controller.start(_atorvastatin, schema);
      controller.next();
      controller.next();

      controller.goToStepContaining('Severity');

      final int index =
          container.read(assessmentControllerProvider).stepIndex;
      expect(AssessmentStep.all[index].collectsSymptoms, isTrue);
    });
  });

  group('SymptomReport', () {
    test('seriousness is derived from severity, never asked', () {
      expect(
        const SymptomReport(sideEffect: 'Fatigue', severity: 'Mild')
            .seriousness,
        'mild',
      );
      expect(
        const SymptomReport(sideEffect: 'Fatigue', severity: 'Moderate')
            .seriousness,
        'moderate',
      );
      expect(
        const SymptomReport(sideEffect: 'Fatigue', severity: 'Severe')
            .seriousness,
        'severe',
      );
    });
  });

  group('OnsetBand', () {
    test('covers the trained range with no gap and no overlap', () {
      expect(OnsetBand.values.first.minDays, 0);
      expect(OnsetBand.values.last.maxDays, 31);

      for (int i = 1; i < OnsetBand.values.length; i++) {
        expect(OnsetBand.values[i].minDays, OnsetBand.values[i - 1].maxDays + 1);
      }
    });

    test('every band sends a value inside its own range', () {
      for (final OnsetBand band in OnsetBand.values) {
        expect(band.contains(band.representativeDays.toDouble()), isTrue,
            reason: '${band.name} sends a value outside itself');
      }
    });

    test('a stored day count maps back to the band the patient chose', () {
      expect(OnsetBand.forDays(4), OnsetBand.withinDays);
      expect(OnsetBand.forDays(11), OnsetBand.weeks1To2);
      expect(OnsetBand.forDays(23), OnsetBand.weeks3To4);
      expect(OnsetBand.forDays(999), OnsetBand.weeks3To4);
    });
  });

  group('DurationBand', () {
    test('covers the trained range with no gap and no overlap', () {
      expect(DurationBand.values.first.minDays, 1);
      expect(DurationBand.values.last.maxDays, 1825);

      for (int i = 1; i < DurationBand.values.length; i++) {
        expect(DurationBand.values[i].minDays,
            DurationBand.values[i - 1].maxDays + 1,
            reason: 'band ${DurationBand.values[i].name} does not abut the one '
                'before it');
      }
    });

    test('every band sends a value inside its own range', () {
      for (final DurationBand band in DurationBand.values) {
        expect(band.contains(band.representativeDays.toDouble()), isTrue,
            reason: '${band.name} sends a value outside itself');
      }
    });

    test('a stored day count maps back to the band the patient chose', () {
      expect(DurationBand.forDays(45), DurationBand.under3Months);
      expect(DurationBand.forDays(136), DurationBand.months3To6);
      expect(DurationBand.forDays(274), DurationBand.months6To12);
      expect(DurationBand.forDays(548), DurationBand.years1To2);
      expect(DurationBand.forDays(1278), DurationBand.over2Years);
    });

    test('a day count outside the trained range still resolves to a band', () {
      // The schema midpoint seeds this field at 913 days before the patient
      // answers, and a stored assessment could predate a range change.
      expect(DurationBand.forDays(913), DurationBand.over2Years);
      expect(DurationBand.forDays(0), DurationBand.under3Months);
      expect(DurationBand.forDays(99999), DurationBand.over2Years);
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

  group('SleepQualityScale', () {
    test('covers the trained range exactly, with no value outside it', () {
      expect(SleepQualityScale.covers(4, 9), isTrue);
      expect(SleepQualityScale.values.first, 4);
      expect(SleepQualityScale.values.last, 9);
      expect(SleepQualityScale.values.length, 6);
    });

    test('refuses to render if the model is retrained on a wider range', () {
      // Falls back to the slider rather than silently offering 4-9 for 0-10.
      expect(SleepQualityScale.covers(0, 10), isFalse);
    });

    test('a value outside the scale still resolves to a level', () {
      expect(SleepQualityScale.levelFor(1), 4);
      expect(SleepQualityScale.levelFor(6.6), 7);
      expect(SleepQualityScale.levelFor(99), 9);
    });
  });

  group('Answer option labels', () {
    final AppLocalizations en = lookupAppLocalizations(const Locale('en'));
    final AppLocalizations si = lookupAppLocalizations(const Locale('si'));

    test('English labels read as before', () {
      expect(DurationBand.over2Years.label(en), 'More than 2 years');
      expect(OnsetBand.withinDays.label(en), 'Within a few days');
      expect(sleepQualityLabel(en, 4), 'Very poor');
      expect(sleepQualityLabel(en, 99), 'Excellent');
    });

    test('every option has its own Sinhala label', () {
      final List<(String, String)> pairs = <(String, String)>[
        for (final DurationBand b in DurationBand.values) (b.label(en), b.label(si)),
        for (final OnsetBand b in OnsetBand.values) (b.label(en), b.label(si)),
        for (final int v in SleepQualityScale.values)
          (sleepQualityLabel(en, v.toDouble()), sleepQualityLabel(si, v.toDouble())),
      ];
      for (final (String english, String sinhala) in pairs) {
        expect(sinhala, isNotEmpty);
        expect(sinhala, isNot(english), reason: '$english is untranslated');
      }
      expect(pairs.map(((String, String) p) => p.$2).toSet().length, pairs.length);
    });
  });
}
