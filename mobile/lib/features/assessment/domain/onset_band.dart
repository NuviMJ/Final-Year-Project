/// How soon after starting the medicine the effects appeared.
///
/// The model wants a day count over its trained 0-31 range; the band midpoint
/// is sent.
enum OnsetBand {
  withinDays(minDays: 0, maxDays: 7, representativeDays: 4),
  weeks1To2(minDays: 8, maxDays: 14, representativeDays: 11),
  weeks3To4(minDays: 15, maxDays: 31, representativeDays: 23);

  const OnsetBand({
    required this.minDays,
    required this.maxDays,
    required this.representativeDays,
  });

  final int minDays;
  final int maxDays;
  final int representativeDays;

  bool contains(double days) => days >= minDays && days <= maxDays;

  static OnsetBand forDays(double days) => values.firstWhere(
        (OnsetBand band) => band.contains(days),
        orElse: () => days < values.first.minDays ? values.first : values.last,
      );

  static const String fieldName = 'Onset_Days';
}
