import 'package:flutter_test/flutter_test.dart';

import 'package:qolguard/features/history/domain/assessment_record.dart';
import 'package:qolguard/features/prediction/domain/prediction.dart';
import 'package:qolguard/features/trends/domain/trend_summary.dart';

AssessmentRecord _at(int day, double pHigh, {String? band}) {
  final String category = band ??
      (pHigh >= 0.6
          ? 'High'
          : pHigh >= 0.3
              ? 'Medium'
              : 'Low');

  return AssessmentRecord.create(
    takenAt: DateTime(2026, 8, day),
    medicationName: 'Atorvastatin',
    doseUnit: 'mg/day',
    answers: const <String, Object>{'Dosage_mg': 40.0},
    prediction: Prediction(
      riskCategory: category,
      confidence: pHigh,
      probabilities: <String, double>{
        'Low': (1 - pHigh) * 0.6,
        'Medium': (1 - pHigh) * 0.4,
        'High': pHigh,
      },
      modelVersion: 'test',
    ),
  );
}

List<AssessmentRecord> _newestFirst(List<AssessmentRecord> records) =>
    records.reversed.toList();

void main() {
  final DateTime now = DateTime(2026, 8, 31);

  group('TrendSummary', () {
    test('a single assessment is not a trend', () {
      final TrendSummary summary = TrendSummary.from(
        <AssessmentRecord>[_at(10, 0.2)],
        TrendPeriod.all,
        now: now,
      );

      expect(summary.hasEnoughData, isFalse);
      expect(summary.direction, TrendDirection.unknown);
      expect(summary.message, contains('at least two'));
    });

    test('no assessments yields an empty summary rather than an error', () {
      final TrendSummary summary =
          TrendSummary.from(const <AssessmentRecord>[], TrendPeriod.all, now: now);

      expect(summary.points, isEmpty);
      expect(summary.hasEnoughData, isFalse);
      expect(summary.highest, 0);
    });

    test('orders points oldest first so time runs left to right', () {
      final TrendSummary summary = TrendSummary.from(
        _newestFirst(<AssessmentRecord>[
          _at(10, 0.1),
          _at(15, 0.3),
          _at(20, 0.5),
        ]),
        TrendPeriod.all,
        now: now,
      );

      expect(
        summary.points.map((TrendPoint p) => p.takenAt.day),
        <int>[10, 15, 20],
      );
    });

    test('reports rising risk when the later half is worse', () {
      final TrendSummary summary = TrendSummary.from(
        _newestFirst(<AssessmentRecord>[
          _at(10, 0.05),
          _at(14, 0.10),
          _at(18, 0.55),
          _at(22, 0.70),
        ]),
        TrendPeriod.all,
        now: now,
      );

      expect(summary.direction, TrendDirection.rising);
      expect(summary.change, greaterThan(0));
      expect(summary.message, contains('rising'));
      expect(summary.message, contains('doctor'));
    });

    test('reports falling risk when the later half is better', () {
      final TrendSummary summary = TrendSummary.from(
        _newestFirst(<AssessmentRecord>[
          _at(10, 0.80),
          _at(14, 0.70),
          _at(18, 0.15),
          _at(22, 0.05),
        ]),
        TrendPeriod.all,
        now: now,
      );

      expect(summary.direction, TrendDirection.falling);
      expect(summary.change, lessThan(0));
      expect(summary.message, contains('falling'));
    });

    test('small variation is reported as steady, not as a trend', () {
      // Ordinary movement between assessments must not be presented to a
      // patient as their risk changing.
      final TrendSummary summary = TrendSummary.from(
        _newestFirst(<AssessmentRecord>[
          _at(10, 0.40),
          _at(14, 0.42),
          _at(18, 0.44),
          _at(22, 0.41),
        ]),
        TrendPeriod.all,
        now: now,
      );

      expect(summary.direction, TrendDirection.steady);
      expect(summary.message, contains('steady'));
    });

    test('catches a climb that never changes the predicted band', () {
      // Every one of these is "Medium", so a band-only chart would draw a flat
      // line — yet the probability of High more than triples. This is exactly
      // the early movement the screen exists to surface.
      final TrendSummary summary = TrendSummary.from(
        _newestFirst(<AssessmentRecord>[
          _at(10, 0.10, band: 'Medium'),
          _at(14, 0.14, band: 'Medium'),
          _at(18, 0.30, band: 'Medium'),
          _at(22, 0.38, band: 'Medium'),
        ]),
        TrendPeriod.all,
        now: now,
      );

      expect(
        summary.points.map((TrendPoint p) => p.category).toSet(),
        <String>{'Medium'},
      );
      expect(summary.direction, TrendDirection.rising);
    });

    test('a 30-day period excludes anything older', () {
      final TrendSummary summary = TrendSummary.from(
        _newestFirst(<AssessmentRecord>[
          _at(1, 0.9), // 30 days before 31 August — outside the window
          _at(20, 0.2),
          _at(25, 0.3),
        ]),
        TrendPeriod.month,
        now: now,
      );

      expect(summary.points, hasLength(2));
      expect(summary.points.first.takenAt.day, 20);
    });

    test('counts how many assessments fell in each band', () {
      final TrendSummary summary = TrendSummary.from(
        _newestFirst(<AssessmentRecord>[
          _at(10, 0.10),
          _at(14, 0.45),
          _at(18, 0.50),
          _at(22, 0.90),
        ]),
        TrendPeriod.all,
        now: now,
      );

      expect(summary.bandCounts, <String, int>{
        'Low': 1,
        'Medium': 2,
        'High': 1,
      });
    });

    test('reports the highest probability reached in the period', () {
      final TrendSummary summary = TrendSummary.from(
        _newestFirst(<AssessmentRecord>[
          _at(10, 0.20),
          _at(14, 0.87),
          _at(18, 0.35),
        ]),
        TrendPeriod.all,
        now: now,
      );

      expect(summary.highest, closeTo(0.87, 1e-9));
    });

    test('never tells a patient to change or stop their medication', () {
      for (final TrendDirection _ in TrendDirection.values) {
        for (final TrendSummary summary in <TrendSummary>[
          TrendSummary.from(
            _newestFirst(<AssessmentRecord>[_at(10, 0.05), _at(20, 0.85)]),
            TrendPeriod.all,
            now: now,
          ),
          TrendSummary.from(
            _newestFirst(<AssessmentRecord>[_at(10, 0.85), _at(20, 0.05)]),
            TrendPeriod.all,
            now: now,
          ),
        ]) {
          final String message = summary.message.toLowerCase();
          expect(message, isNot(contains('stop taking')));
          expect(message, isNot(contains('reduce your dose')));
        }
      }
    });
  });
}
