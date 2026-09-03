import 'package:flutter_test/flutter_test.dart';

import 'package:qolguard/features/assessment/domain/symptom_report.dart';
import 'package:qolguard/features/medications/domain/medication.dart';
import 'package:qolguard/features/prediction/domain/assessment_outcome.dart';
import 'package:qolguard/features/prediction/domain/prediction.dart';

const Medication _atorvastatin = Medication(
  name: 'Atorvastatin',
  drugClass: 'Statins',
  doseUnit: 'mg/day',
  doseMin: 10,
  doseMax: 80,
  typicalDoses: <double>[10, 20, 40, 80],
);

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

MedicationPrediction _result(
  Medication medication,
  String symptom,
  String band,
  double high,
) {
  final double rest = (1 - high) / 2;
  return MedicationPrediction(
    medication: medication,
    dose: medication.defaultDose,
    symptom: SymptomReport(sideEffect: symptom, severity: 'Moderate'),
    prediction: Prediction(
      riskCategory: band,
      confidence: high,
      probabilities: <String, double>{
        'Low': rest,
        'Medium': rest,
        'High': high,
      },
      modelVersion: 'test',
    ),
  );
}

void main() {
  group('AssessmentOutcome', () {
    test('each medicine is represented by its worst effect', () {
      final AssessmentOutcome outcome = AssessmentOutcome(
        results: <MedicationPrediction>[
          _result(_atorvastatin, 'Fatigue', 'Low', 0.04),
          _result(_atorvastatin, 'Muscle Pain', 'Medium', 0.28),
          _result(_metformin, 'Fatigue', 'Low', 0.06),
        ],
      );

      expect(outcome.worstPerMedication.length, 2);
      final MedicationPrediction statin = outcome.worstPerMedication
          .firstWhere((MedicationPrediction r) => r.medication == _atorvastatin);
      expect(statin.symptom.sideEffect, 'Muscle Pain');
    });

    test('medicines are ordered most concerning first', () {
      final AssessmentOutcome outcome = AssessmentOutcome(
        results: <MedicationPrediction>[
          _result(_metformin, 'Fatigue', 'Low', 0.04),
          _result(_omeprazole, 'Stomach Pain', 'Medium', 0.31),
          _result(_atorvastatin, 'Fatigue', 'Medium', 0.19),
        ],
      );

      expect(
        outcome.byRiskDescending
            .map((MedicationPrediction r) => r.medication.name)
            .toList(),
        <String>['Omeprazole', 'Atorvastatin', 'Metformin'],
      );
    });

    test('a High band outranks a Medium with a greater High probability', () {
      // Band before probability: a High result must never be presented below
      // a Medium one, however close the probabilities are.
      final AssessmentOutcome outcome = AssessmentOutcome(
        results: <MedicationPrediction>[
          _result(_metformin, 'Fatigue', 'Medium', 0.40),
          _result(_omeprazole, 'Nausea', 'High', 0.38),
        ],
      );

      expect(outcome.highest.medication, _omeprazole);
      expect(outcome.byRiskDescending.first.medication, _omeprazole);
    });

    test('bands are counted per medicine, not per effect', () {
      final AssessmentOutcome outcome = AssessmentOutcome(
        results: <MedicationPrediction>[
          _result(_atorvastatin, 'Fatigue', 'Medium', 0.22),
          _result(_atorvastatin, 'Nausea', 'Medium', 0.19),
          _result(_metformin, 'Fatigue', 'Low', 0.04),
          _result(_metformin, 'Nausea', 'Low', 0.05),
        ],
      );

      expect(outcome.bandCounts['Medium'], 1);
      expect(outcome.bandCounts['Low'], 1);
      expect(outcome.bandCounts['High'], 0);
    });

    test('the summary counts medicines in the highest band reached', () {
      final AssessmentOutcome outcome = AssessmentOutcome(
        results: <MedicationPrediction>[
          _result(_omeprazole, 'Stomach Pain', 'Medium', 0.31),
          _result(_atorvastatin, 'Fatigue', 'Medium', 0.19),
          _result(_metformin, 'Fatigue', 'Low', 0.04),
        ],
      );

      expect(outcome.bandSummary, '2 of 3 medicines are in the Medium band.');
    });

    test('the summary reads correctly for a single medicine', () {
      final AssessmentOutcome outcome = AssessmentOutcome(
        results: <MedicationPrediction>[
          _result(_metformin, 'Fatigue', 'Low', 0.04),
        ],
      );

      expect(outcome.isSingle, isTrue);
      expect(outcome.bandSummary, '1 of 1 medicine is in the Low band.');
    });

    test('effects for one medicine come back worst first', () {
      final AssessmentOutcome outcome = AssessmentOutcome(
        results: <MedicationPrediction>[
          _result(_atorvastatin, 'Fatigue', 'Low', 0.04),
          _result(_atorvastatin, 'Muscle Pain', 'Medium', 0.28),
          _result(_metformin, 'Fatigue', 'Low', 0.06),
        ],
      );

      expect(
        outcome
            .resultsFor(_atorvastatin)
            .map((MedicationPrediction r) => r.symptom.sideEffect)
            .toList(),
        <String>['Muscle Pain', 'Fatigue'],
      );
    });

    test('a no-side-effects outcome is not treated as empty', () {
      const AssessmentOutcome outcome = AssessmentOutcome(
        results: <MedicationPrediction>[],
        noSideEffectsReported: true,
      );

      expect(outcome.isEmpty, isFalse);
      expect(outcome.results, isEmpty);
    });
  });
}
