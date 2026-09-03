import '../../assessment/domain/symptom_report.dart';
import '../../prediction/domain/prediction.dart';

/// One medicine as it was assessed, with the effect that produced its result.
class RecordedMedicine {
  const RecordedMedicine({
    required this.name,
    required this.doseUnit,
    required this.dose,
    this.sideEffect,
    this.prediction,
  });

  final String name;
  final String doseUnit;
  final double dose;

  /// The effect that gave this medicine its band. Absent when none were
  /// reported, since the model was not consulted.
  final String? sideEffect;
  final Prediction? prediction;

  String get doseLabel {
    final String value =
        dose == dose.roundToDouble() ? dose.toInt().toString() : dose.toString();
    return '$value $doseUnit';
  }

  double get highRiskProbability => prediction?.probabilities['High'] ?? 0;

  int get riskRank => prediction == null
      ? -1
      : const <String>['Low', 'Medium', 'High']
          .indexOf(prediction!.riskCategory);

  Map<String, dynamic> toJson() => <String, dynamic>{
        'name': name,
        'dose_unit': doseUnit,
        'dose': dose,
        if (sideEffect != null) 'side_effect': sideEffect,
        if (prediction != null)
          'prediction': <String, dynamic>{
            'risk_category': prediction!.riskCategory,
            'confidence': prediction!.confidence,
            'probabilities': prediction!.probabilities,
            'model_version': prediction!.modelVersion,
          },
      };

  factory RecordedMedicine.fromJson(Map<String, dynamic> json) {
    return RecordedMedicine(
      name: json['name'] as String,
      doseUnit: json['dose_unit'] as String? ?? 'mg/day',
      dose: (json['dose'] as num?)?.toDouble() ?? 0,
      sideEffect: json['side_effect'] as String?,
      prediction: json['prediction'] == null
          ? null
          : Prediction.fromJson(json['prediction'] as Map<String, dynamic>),
    );
  }
}

class AssessmentRecord {
  const AssessmentRecord({
    required this.id,
    required this.takenAt,
    required this.medicines,
    required this.symptoms,
    required this.answers,
    this.noSideEffectsReported = false,
  });

  final String id;
  final DateTime takenAt;

  /// Every medicine assessed, not only the one of greatest concern.
  final List<RecordedMedicine> medicines;

  /// Every effect reported, each with its own severity.
  final List<SymptomReport> symptoms;

  /// The answers shared across medicines: age, treatment, daily life.
  final Map<String, Object> answers;

  /// The patient reported no effects, so no medicine carries a prediction.
  final bool noSideEffectsReported;

  factory AssessmentRecord.create({
    required DateTime takenAt,
    required List<RecordedMedicine> medicines,
    required List<SymptomReport> symptoms,
    required Map<String, Object> answers,
    bool noSideEffectsReported = false,
  }) {
    return AssessmentRecord(
      id: takenAt.millisecondsSinceEpoch.toString(),
      takenAt: takenAt,
      medicines: medicines,
      symptoms: symptoms,
      answers: answers,
      noSideEffectsReported: noSideEffectsReported,
    );
  }

  /// Medicines ordered most concerning first.
  List<RecordedMedicine> get byRiskDescending {
    final List<RecordedMedicine> sorted = List<RecordedMedicine>.of(medicines)
      ..sort((RecordedMedicine a, RecordedMedicine b) {
        final int byRank = b.riskRank.compareTo(a.riskRank);
        return byRank != 0
            ? byRank
            : b.highRiskProbability.compareTo(a.highRiskProbability);
      });
    return sorted;
  }

  RecordedMedicine? get worst {
    final List<RecordedMedicine> scored = byRiskDescending
        .where((RecordedMedicine m) => m.prediction != null)
        .toList();
    return scored.isEmpty ? null : scored.first;
  }

  Prediction? get prediction => worst?.prediction;
  bool get hasPrediction => prediction != null;

  String get medicationName =>
      worst?.name ?? (medicines.isEmpty ? '' : medicines.first.name);

  String get doseLabel =>
      worst?.doseLabel ?? (medicines.isEmpty ? '' : medicines.first.doseLabel);

  /// e.g. "Omeprazole, Atorvastatin and Metformin"
  String get medicinesLabel {
    final List<String> names =
        medicines.map((RecordedMedicine m) => m.name).toList();
    if (names.isEmpty) return '';
    if (names.length == 1) return names.first;
    return '${names.sublist(0, names.length - 1).join(', ')} and ${names.last}';
  }

  String get sideEffectLabel {
    if (noSideEffectsReported) return 'No side effects reported';
    if (symptoms.isEmpty) return '';
    return symptoms
        .map((SymptomReport s) =>
            '${SymptomReport.labelFor(s.sideEffect)} · ${s.severity}')
        .join(', ');
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'taken_at': takenAt.toIso8601String(),
        'answers': answers,
        'no_side_effects': noSideEffectsReported,
        'symptoms': <Map<String, dynamic>>[
          for (final SymptomReport s in symptoms)
            <String, dynamic>{
              'side_effect': s.sideEffect,
              'severity': s.severity,
            },
        ],
        'medicines': <Map<String, dynamic>>[
          for (final RecordedMedicine m in medicines) m.toJson(),
        ],
      };

  factory AssessmentRecord.fromJson(Map<String, dynamic> json) {
    final Map<String, Object> answers =
        (json['answers'] as Map<String, dynamic>).map(
      (String key, dynamic value) =>
          MapEntry<String, Object>(key, value as Object),
    );

    // Records written before multi-medicine support held one prediction and
    // one medication name at the top level. Read them as a single medicine so
    // nothing already on the device is lost.
    if (json['medicines'] == null && json['prediction'] != null) {
      return AssessmentRecord(
        id: json['id'] as String,
        takenAt: DateTime.parse(json['taken_at'] as String),
        answers: answers,
        symptoms: <SymptomReport>[
          if (answers['Side_Effect'] != null)
            SymptomReport(
              sideEffect: answers['Side_Effect'].toString(),
              severity: answers['Severity']?.toString() ?? 'Moderate',
            ),
        ],
        medicines: <RecordedMedicine>[
          RecordedMedicine(
            name: json['medication_name'] as String? ?? '',
            doseUnit: json['dose_unit'] as String? ?? 'mg/day',
            dose: (answers['Dosage_mg'] as num?)?.toDouble() ?? 0,
            sideEffect: answers['Side_Effect']?.toString(),
            prediction:
                Prediction.fromJson(json['prediction'] as Map<String, dynamic>),
          ),
        ],
      );
    }

    return AssessmentRecord(
      id: json['id'] as String,
      takenAt: DateTime.parse(json['taken_at'] as String),
      answers: answers,
      noSideEffectsReported: json['no_side_effects'] as bool? ?? false,
      symptoms: <SymptomReport>[
        for (final dynamic entry
            in json['symptoms'] as List<dynamic>? ?? <dynamic>[])
          SymptomReport(
            sideEffect: (entry as Map<String, dynamic>)['side_effect'] as String,
            severity: entry['severity'] as String,
          ),
      ],
      medicines: <RecordedMedicine>[
        for (final dynamic entry
            in json['medicines'] as List<dynamic>? ?? <dynamic>[])
          RecordedMedicine.fromJson(entry as Map<String, dynamic>),
      ],
    );
  }
}
