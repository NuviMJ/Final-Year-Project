/// How soon after starting the medicine the effects appeared.
///
/// The model wants a day count over its trained 0-31 range; the band midpoint
/// is sent.
class OnsetBand {
  const OnsetBand({
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

  static const List<OnsetBand> all = <OnsetBand>[
    OnsetBand(
      label: 'Within a few days',
      minDays: 0,
      maxDays: 7,
      representativeDays: 4,
    ),
    OnsetBand(
      label: '1 to 2 weeks',
      minDays: 8,
      maxDays: 14,
      representativeDays: 11,
    ),
    OnsetBand(
      label: '3 to 4 weeks',
      minDays: 15,
      maxDays: 31,
      representativeDays: 23,
    ),
  ];

  static OnsetBand forDays(double days) => all.firstWhere(
        (OnsetBand band) => band.contains(days),
        orElse: () => days < all.first.minDays ? all.first : all.last,
      );

  static const String fieldName = 'Onset_Days';
}
