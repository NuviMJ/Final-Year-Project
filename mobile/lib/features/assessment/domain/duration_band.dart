
class DurationBand {
  const DurationBand({
    required this.label,
    required this.minDays,
    required this.maxDays,
    required this.representativeDays,
  });

  final String label;
  final int minDays;
  final int maxDays;

  final int representativeDays;

  bool contains(double days) => days >= minDays && days <= maxDays;

  static const List<DurationBand> all = <DurationBand>[
    DurationBand(
      label: 'Less than 3 months',
      minDays: 1,
      maxDays: 89,
      representativeDays: 45,
    ),
    DurationBand(
      label: '3 to 6 months',
      minDays: 90,
      maxDays: 182,
      representativeDays: 136,
    ),
    DurationBand(
      label: '6 to 12 months',
      minDays: 183,
      maxDays: 365,
      representativeDays: 274,
    ),
    DurationBand(
      label: '1 to 2 years',
      minDays: 366,
      maxDays: 730,
      representativeDays: 548,
    ),
    DurationBand(
      label: 'More than 2 years',
      minDays: 731,
      maxDays: 1825,
      representativeDays: 1278,
    ),
  ];

  static DurationBand forDays(double days) => all.firstWhere(
        (DurationBand band) => band.contains(days),
        orElse: () => days < all.first.minDays ? all.first : all.last,
      );

  static const String fieldName = 'Treatment_Duration_Days';
}
