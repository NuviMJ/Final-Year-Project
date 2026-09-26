/// One side effect the patient reports, with how bad it is for them.
class SymptomReport {
  const SymptomReport({required this.sideEffect, required this.severity});

  final String sideEffect;
  final String severity;

  /// The model also wants a regulatory seriousness grade, which a patient
  /// cannot supply. It is derived from severity rather than asked.
  String get seriousness => switch (severity) {
        'Mild' => 'mild',
        'Moderate' => 'moderate',
        _ => 'severe',
      };

  SymptomReport withSeverity(String value) =>
      SymptomReport(sideEffect: sideEffect, severity: value);

  @override
  bool operator ==(Object other) =>
      other is SymptomReport &&
      other.sideEffect == sideEffect &&
      other.severity == severity;

  @override
  int get hashCode => Object.hash(sideEffect, severity);

  static const int maxPerAssessment = 3;

  /// Shown first, being the effects patients report most often.
  static const List<String> common = <String>[
    'Fatigue',
    'Dizziness',
    'Nausea',
    'Headache',
    'Insomnia',
    'Anxiety',
    'Stomach Pain',
    'Muscle Pain',
  ];
}
