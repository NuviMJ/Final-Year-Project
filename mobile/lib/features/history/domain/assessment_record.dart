import '../../prediction/domain/prediction.dart';

class AssessmentRecord {
  const AssessmentRecord({
    required this.id,
    required this.takenAt,
    required this.medicationName,
    required this.doseUnit,
    required this.answers,
    required this.prediction,
  });

  final String id;

  final DateTime takenAt;
  final String medicationName;
  final String doseUnit;

  final Map<String, Object> answers;

  final Prediction prediction;

  factory AssessmentRecord.create({
    required DateTime takenAt,
    required String medicationName,
    required String doseUnit,
    required Map<String, Object> answers,
    required Prediction prediction,
  }) {
    return AssessmentRecord(
      id: takenAt.millisecondsSinceEpoch.toString(),
      takenAt: takenAt,
      medicationName: medicationName,
      doseUnit: doseUnit,
      answers: answers,
      prediction: prediction,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'taken_at': takenAt.toIso8601String(),
        'medication_name': medicationName,
        'dose_unit': doseUnit,
        'answers': answers,
        'prediction': <String, dynamic>{
          'risk_category': prediction.riskCategory,
          'confidence': prediction.confidence,
          'probabilities': prediction.probabilities,
          'model_version': prediction.modelVersion,
        },
      };

  factory AssessmentRecord.fromJson(Map<String, dynamic> json) {
    return AssessmentRecord(
      id: json['id'] as String,
      takenAt: DateTime.parse(json['taken_at'] as String),
      medicationName: json['medication_name'] as String,
      doseUnit: json['dose_unit'] as String? ?? 'mg/day',
      answers: (json['answers'] as Map<String, dynamic>).map(
        (String key, dynamic value) =>
            MapEntry<String, Object>(key, value as Object),
      ),
      prediction:
          Prediction.fromJson(json['prediction'] as Map<String, dynamic>),
    );
  }

  String get doseLabel {
    final Object? dose = answers['Dosage_mg'];
    if (dose is! num) return '';
    final String value =
        dose == dose.roundToDouble() ? dose.toInt().toString() : dose.toString();
    return '$value $doseUnit';
  }

  String get sideEffectLabel {
    final Object? effect = answers['Side_Effect'];
    final Object? severity = answers['Severity'];
    if (effect == null) return '';
    return severity == null ? '$effect' : '$effect · $severity';
  }
}
