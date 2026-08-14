import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:qolguard/features/history/data/assessment_store.dart';
import 'package:qolguard/features/history/domain/assessment_record.dart';
import 'package:qolguard/features/prediction/domain/prediction.dart';

const Prediction _high = Prediction(
  riskCategory: 'High',
  confidence: 0.9997,
  probabilities: <String, double>{'Low': 0.0, 'Medium': 0.0003, 'High': 0.9997},
  modelVersion: 'xgboost-3class-49f-300r',
);

const Prediction _low = Prediction(
  riskCategory: 'Low',
  confidence: 0.85,
  probabilities: <String, double>{'Low': 0.85, 'Medium': 0.15, 'High': 0.0},
  modelVersion: 'xgboost-3class-49f-300r',
);

AssessmentRecord _record({
  required DateTime takenAt,
  Prediction prediction = _high,
  String medication = 'Atorvastatin',
}) {
  return AssessmentRecord.create(
    takenAt: takenAt,
    medicationName: medication,
    doseUnit: 'mg/day',
    answers: <String, Object>{
      'Age': 62.0,
      'Dosage_mg': 40.0,
      'Side_Effect': 'Muscle Pain',
      'Severity': 'Severe',
      'Alcohol_Use': 'No_Alcohol',
    },
    prediction: prediction,
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
      expect(restored.answers['Age'], 62.0);
      expect(restored.prediction.riskCategory, 'High');
      expect(restored.prediction.probabilities['High'], closeTo(0.9997, 1e-6));
    });

    test('formats the dose with the unit that applies to the drug', () {
      expect(_record(takenAt: DateTime(2026)).doseLabel, '40 mg/day');
    });

    test('summarises the side effect with its severity', () {
      expect(_record(takenAt: DateTime(2026)).sideEffectLabel,
          'Muscle Pain · Severe');
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
      expect(all.first.prediction.riskCategory, 'High');
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
      await first.save(_record(takenAt: DateTime(2026, 8, 14), prediction: _low));

      final AssessmentStore second =
          AssessmentStore(await SharedPreferences.getInstance());

      expect(second.readAll(), hasLength(1));
      expect(second.readLatest()!.prediction.riskCategory, 'Low');
    });
  });
}
