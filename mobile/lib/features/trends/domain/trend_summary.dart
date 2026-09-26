import '../../history/domain/assessment_record.dart';

enum TrendPeriod {
  month(30),
  quarter(90),
  all(null);

  const TrendPeriod(this.days);

  final int? days;
}

enum TrendDirection { rising, steady, falling, unknown }

class TrendPoint {
  const TrendPoint({
    required this.id,
    required this.takenAt,
    required this.probabilityOfHigh,
    required this.category,
  });

  final String id;
  final DateTime takenAt;

  final double probabilityOfHigh;

  final String category;
}

class TrendSummary {
  const TrendSummary({
    required this.points,
    required this.direction,
    required this.change,
    this.unscoredCount = 0,
  });

  final List<TrendPoint> points;
  final TrendDirection direction;

  final double change;

  /// Days in the period with no reported effects, which the model never saw.
  final int unscoredCount;

  bool get hasEnoughData => points.length >= 2;

  TrendPoint? get latest => points.isEmpty ? null : points.last;

  double get highest => points.isEmpty
      ? 0
      : points
          .map((TrendPoint p) => p.probabilityOfHigh)
          .reduce((double a, double b) => a > b ? a : b);

  Map<String, int> get bandCounts {
    final Map<String, int> counts = <String, int>{
      'Low': 0,
      'Medium': 0,
      'High': 0,
    };
    for (final TrendPoint point in points) {
      counts[point.category] = (counts[point.category] ?? 0) + 1;
    }
    return counts;
  }

  static const double _threshold = 0.05;
  
  factory TrendSummary.from(
    List<AssessmentRecord> records,
    TrendPeriod period, {
    DateTime? now,
  }) {
    final DateTime reference = now ?? DateTime.now();

    final Iterable<AssessmentRecord> inPeriod = period.days == null
        ? records
        : records.where((AssessmentRecord record) => record.takenAt
            .isAfter(reference.subtract(Duration(days: period.days!))));

    // A day with no reported effects never reached the model, so it
    // carries no probability and must not shift the line.
    final int unscored =
        inPeriod.where((AssessmentRecord r) => !r.hasPrediction).length;
    final List<TrendPoint> points = inPeriod
        .where((AssessmentRecord record) => record.hasPrediction)
        .map((AssessmentRecord record) => TrendPoint(
              id: record.id,
              takenAt: record.takenAt,
              probabilityOfHigh:
                  record.prediction!.probabilities['High'] ?? 0,
              category: record.prediction!.riskCategory,
            ))
        .toList()
      ..sort((TrendPoint a, TrendPoint b) => a.takenAt.compareTo(b.takenAt));

    if (points.length < 2) {
      return TrendSummary(
        points: points,
        direction: TrendDirection.unknown,
        change: 0,
        unscoredCount: unscored,
      );
    }

    final int midpoint = points.length ~/ 2;
    final double earlier = _mean(points.take(midpoint).toList());
    final double later = _mean(points.skip(midpoint).toList());
    final double change = later - earlier;

    return TrendSummary(
      points: points,
      direction: change > _threshold
          ? TrendDirection.rising
          : change < -_threshold
              ? TrendDirection.falling
              : TrendDirection.steady,
      change: change,
      unscoredCount: unscored,
    );
  }

  static double _mean(List<TrendPoint> points) {
    if (points.isEmpty) return 0;
    final double total = points.fold<double>(
      0,
      (double sum, TrendPoint point) => sum + point.probabilityOfHigh,
    );
    return total / points.length;
  }
}
