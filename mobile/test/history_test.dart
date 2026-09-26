import 'package:flutter_test/flutter_test.dart';

import 'package:qolguard/features/assessment/domain/symptom_report.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:qolguard/features/history/data/assessment_store.dart';
import 'package:qolguard/features/history/domain/assessment_record.dart';
import 'package:qolguard/features/prediction/domain/prediction.dart';
import 'package:flutter/widgets.dart';
import 'package:qolguard/l10n/app_localizations.dart';
import 'package:qolguard/features/history/presentation/record_text.dart';

final AppLocalizations _en = lookupAppLocalizations(const Locale('en'));

AssessmentRecord _record({
  required DateTime takenAt,
  String medication = 'Atorvastatin',
  String band = 'Medium',
  double high = 0.31,
}) {
  final double rest = (1 - high) / 2;
  return AssessmentRecord.create(
    takenAt: takenAt,
    medicines: <RecordedMedicine>[
      RecordedMedicine(
        name: medication,
        doseUnit: 'mg/day',
        dose: 40,
        sideEffect: 'Fatigue',
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
      ),
    ],
    symptoms: const <SymptomReport>[
      SymptomReport(sideEffect: 'Fatigue', severity: 'Mild'),
    ],
    answers: <String, Object>{'Age': 62.0, 'Treatment_Duration_Days': 548.0},
  );
}

Future<AssessmentStore> _freshStore() async {
  SharedPreferences.setMockInitialValues(<String, Object>{});
  return AssessmentStore(await SharedPreferences.getInstance());
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AssessmentRecord', () {
    test('survives a round trip through JSON intact', () {
      final AssessmentRecord original =
          _record(takenAt: DateTime(2026, 8, 14, 9, 30));

      final AssessmentRecord restored =
          AssessmentRecord.fromJson(original.toJson());

      expect(restored.id, original.id);
      expect(restored.takenAt, original.takenAt);
      expect(restored.medicationName, 'Atorvastatin');
      expect(restored.prediction!.riskCategory, 'Medium');
      expect(restored.answers['Age'], 62.0);
      expect(restored.prediction!.probabilities['High'], closeTo(0.31, 1e-6));
    });

    test('formats the dose with the unit that applies to the drug', () {
      expect(_record(takenAt: DateTime(2026)).doseLabel, '40 mg/day');
    });

    test('summarises the side effect with its severity', () {
      expect(_record(takenAt: DateTime(2026)).sideEffectLabel(_en),
          'Fatigue · Mild');
    });
  });

  group('AssessmentStore', () {
    test('starts empty', () async {
      final AssessmentStore store = await _freshStore();
      expect(store.readAll(), isEmpty);
      expect(store.readLatest(), isNull);
    });

    test('saves a record and reads it back', () async {
      final AssessmentStore store = await _freshStore();
      await store.save(_record(takenAt: DateTime(2026, 8, 14, 9, 0)));

      final List<AssessmentRecord> all = store.readAll();
      expect(all, hasLength(1));
      expect(all.first.prediction!.riskCategory, 'Medium');
    });

    test('returns records newest first regardless of insertion order',
        () async {
      final AssessmentStore store = await _freshStore();
      await store.save(_record(takenAt: DateTime(2026, 8, 10)));
      await store.save(_record(takenAt: DateTime(2026, 8, 14)));
      await store.save(_record(takenAt: DateTime(2026, 8, 12)));

      final List<AssessmentRecord> all = store.readAll();
      expect(all.map((AssessmentRecord r) => r.takenAt.day), <int>[14, 12, 10]);
      expect(store.readLatest()!.takenAt.day, 14);
    });

    test('finds a stored record by id', () async {
      final AssessmentStore store = await _freshStore();
      final AssessmentRecord record = _record(takenAt: DateTime(2026, 8, 14));
      await store.save(record);

      expect(store.readById(record.id)!.medicationName, 'Atorvastatin');
      expect(store.readById('does-not-exist'), isNull);
    });

    test('deletes one record and leaves the rest', () async {
      final AssessmentStore store = await _freshStore();
      final AssessmentRecord keep = _record(takenAt: DateTime(2026, 8, 10));
      final AssessmentRecord drop = _record(takenAt: DateTime(2026, 8, 14));
      await store.save(keep);
      await store.save(drop);

      await store.delete(drop.id);

      expect(store.readAll(), hasLength(1));
      expect(store.readAll().first.id, keep.id);
    });

    test('clearing removes everything, as the settings screen offers',
        () async {
      final AssessmentStore store = await _freshStore();
      await store.save(_record(takenAt: DateTime(2026, 8, 14)));

      await store.clear();

      expect(store.readAll(), isEmpty);
    });

    test('a corrupt document yields an empty history rather than crashing',
        () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'qolguard.assessments.v1': 'not valid json at all',
      });
      final AssessmentStore store =
          AssessmentStore(await SharedPreferences.getInstance());

      // Failing every launch on data the user cannot see or repair would be
      // worse than starting over.
      expect(store.readAll(), isEmpty);
    });

    test('records persist across a new store instance', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final AssessmentStore first =
          AssessmentStore(await SharedPreferences.getInstance());
      await first.save(_record(takenAt: DateTime(2026, 8, 14), band: 'Low', high: 0.04));

      final AssessmentStore second =
          AssessmentStore(await SharedPreferences.getInstance());

      expect(second.readAll(), hasLength(1));
      expect(second.readLatest()!.prediction!.riskCategory, 'Low');
    });
  });

  group('Record format', () {
    test('a record written before multi-medicine support still loads', () {
      // Anything already on a patient's device must survive the upgrade.
      final Map<String, dynamic> v1 = <String, dynamic>{
        'id': '1700000000000',
        'taken_at': '2026-08-01T09:30:00.000',
        'medication_name': 'Metformin',
        'dose_unit': 'mg/day',
        'answers': <String, dynamic>{
          'Dosage_mg': 1000.0,
          'Side_Effect': 'Nausea',
          'Severity': 'Moderate',
          'Age': 58.0,
        },
        'prediction': <String, dynamic>{
          'risk_category': 'Medium',
          'confidence': 0.44,
          'probabilities': <String, dynamic>{
            'Low': 0.25,
            'Medium': 0.44,
            'High': 0.31,
          },
          'model_version': 'xgboost-3class-49f-300r',
        },
      };

      final AssessmentRecord record = AssessmentRecord.fromJson(v1);

      expect(record.medicines.length, 1);
      expect(record.medicines.first.name, 'Metformin');
      expect(record.medicines.first.dose, 1000.0);
      expect(record.prediction!.riskCategory, 'Medium');
      expect(record.symptoms.single.sideEffect, 'Nausea');
      expect(record.symptoms.single.severity, 'Moderate');
      expect(record.noSideEffectsReported, isFalse);
    });

    test('several medicines round-trip through JSON', () {
      final AssessmentRecord record = AssessmentRecord.create(
        takenAt: DateTime(2026, 9, 1, 8),
        medicines: <RecordedMedicine>[
          RecordedMedicine(
            name: 'Omeprazole',
            doseUnit: 'mg/day',
            dose: 20,
            sideEffect: 'Stomach Pain',
            prediction: const Prediction(
              riskCategory: 'Medium',
              confidence: 0.45,
              probabilities: <String, double>{
                'Low': 0.24,
                'Medium': 0.45,
                'High': 0.31,
              },
              modelVersion: 'test',
            ),
          ),
          RecordedMedicine(
            name: 'Metformin',
            doseUnit: 'mg/day',
            dose: 1000,
            sideEffect: 'Fatigue',
            prediction: const Prediction(
              riskCategory: 'Low',
              confidence: 0.80,
              probabilities: <String, double>{
                'Low': 0.80,
                'Medium': 0.16,
                'High': 0.04,
              },
              modelVersion: 'test',
            ),
          ),
        ],
        symptoms: const <SymptomReport>[
          SymptomReport(sideEffect: 'Stomach Pain', severity: 'Moderate'),
          SymptomReport(sideEffect: 'Fatigue', severity: 'Mild'),
        ],
        answers: <String, Object>{'Age': 62.0},
      );

      final AssessmentRecord restored =
          AssessmentRecord.fromJson(record.toJson());

      expect(restored.medicines.length, 2);
      expect(restored.symptoms.length, 2);
      expect(restored.medicinesLabel(_en), 'Omeprazole and Metformin');
      // The worst medicine is the one the list and the home card name.
      expect(restored.medicationName, 'Omeprazole');
      expect(restored.prediction!.riskCategory, 'Medium');
    });

    test('a no-side-effects day is stored without a prediction', () {
      final AssessmentRecord record = AssessmentRecord.create(
        takenAt: DateTime(2026, 9, 2, 8),
        medicines: const <RecordedMedicine>[
          RecordedMedicine(name: 'Metformin', doseUnit: 'mg/day', dose: 1000),
        ],
        symptoms: const <SymptomReport>[],
        answers: <String, Object>{'Age': 62.0},
        noSideEffectsReported: true,
      );

      final AssessmentRecord restored =
          AssessmentRecord.fromJson(record.toJson());

      expect(restored.noSideEffectsReported, isTrue);
      expect(restored.hasPrediction, isFalse);
      expect(restored.prediction, isNull);
      expect(restored.medicines.single.name, 'Metformin');
      expect(restored.sideEffectLabel(_en), 'No side effects reported');
    });
  });

  group('Stored answers', () {
    test('a record keeps text and numeric answers side by side', () {
      // Gender and Smoker are Strings while Age is a number; reading a stored
      // record must cope with both.
      final AssessmentRecord record = AssessmentRecord.create(
        takenAt: DateTime(2026, 9, 3),
        medicines: const <RecordedMedicine>[
          RecordedMedicine(name: 'Metformin', doseUnit: 'mg/day', dose: 1000),
        ],
        symptoms: const <SymptomReport>[],
        answers: const <String, Object>{
          'Age': 62.0,
          'Gender': 'Male',
          'Smoker': 'No',
          'Alcohol_Use': 'No_Alcohol',
          'Sleep_Quality': 8.0,
          'Treatment_Duration_Days': 548.0,
        },
        noSideEffectsReported: true,
      );

      final AssessmentRecord restored =
          AssessmentRecord.fromJson(record.toJson());

      expect(restored.answers['Gender'], 'Male');
      expect(restored.answers['Age'], 62.0);
      expect(restored.answers['Sleep_Quality'], 8.0);
      expect(restored.answers['Alcohol_Use'], 'No_Alcohol');
    });
  });
}
