/// Faces for the sleep quality values the model was trained on (4-9).
///
/// A bare number scale asks a patient to distinguish 6 from 7, which they
/// cannot do meaningfully. The words are in the presentation layer.
class SleepQualityScale {
  const SleepQualityScale._();

  static const Map<int, String> faces = <int, String>{
    4: '😞',
    5: '🙁',
    6: '😐',
    7: '🙂',
    8: '😊',
    9: '😄',
  };

  static const String fieldName = 'Sleep_Quality';

  static List<int> get values => faces.keys.toList();

  static int levelFor(double value) =>
      value.round().clamp(values.first, values.last);

  /// True when the scale matches the schema's trained range exactly.
  static bool covers(double min, double max) =>
      values.first == min.round() && values.last == max.round();
}
