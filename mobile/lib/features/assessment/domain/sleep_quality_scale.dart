/// Words for the sleep quality values the model was trained on (4-9).
///
/// A bare number scale asks a patient to distinguish 6 from 7, which they
/// cannot do meaningfully.
class SleepQualityScale {
  const SleepQualityScale._();

  static const Map<int, String> labels = <int, String>{
    4: 'Very poor',
    5: 'Poor',
    6: 'Fair',
    7: 'Good',
    8: 'Very good',
    9: 'Excellent',
  };

  static const Map<int, String> faces = <int, String>{
    4: '😞',
    5: '🙁',
    6: '😐',
    7: '🙂',
    8: '😊',
    9: '😄',
  };

  static const String fieldName = 'Sleep_Quality';

  static List<int> get values => labels.keys.toList();

  static String labelFor(double value) =>
      labels[value.round().clamp(values.first, values.last)]!;

  /// True when the scale matches the schema's trained range exactly.
  static bool covers(double min, double max) =>
      values.first == min.round() && values.last == max.round();
}
