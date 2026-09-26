enum DurationBand {
  under3Months(minDays: 1, maxDays: 89, representativeDays: 45),
  months3To6(minDays: 90, maxDays: 182, representativeDays: 136),
  months6To12(minDays: 183, maxDays: 365, representativeDays: 274),
  years1To2(minDays: 366, maxDays: 730, representativeDays: 548),
  over2Years(minDays: 731, maxDays: 1825, representativeDays: 1278);

  const DurationBand({
    required this.minDays,
    required this.maxDays,
    required this.representativeDays,
  });

  final int minDays;
  final int maxDays;

  final int representativeDays;

  bool contains(double days) => days >= minDays && days <= maxDays;

  static DurationBand forDays(double days) => values.firstWhere(
        (DurationBand band) => band.contains(days),
        orElse: () => days < values.first.minDays ? values.first : values.last,
      );

  static const String fieldName = 'Treatment_Duration_Days';
}
