import '../../medications/domain/medication.dart';
import 'prediction.dart';

class MedicationPrediction {
  const MedicationPrediction({
    required this.medication,
    required this.dose,
    required this.prediction,
  });

  final Medication medication;
  final double dose;
  final Prediction prediction;

  double get highRiskProbability => prediction.probabilities['High'] ?? 0;

  static const List<String> bandOrder = <String>['Low', 'Medium', 'High'];

  int get riskRank => bandOrder.indexOf(prediction.riskCategory);
}

class AssessmentOutcome {
  const AssessmentOutcome({required this.results});

  final List<MedicationPrediction> results;

  bool get isEmpty => results.isEmpty;
  bool get isSingle => results.length == 1;

  MedicationPrediction get highest => results.reduce(
        (MedicationPrediction a, MedicationPrediction b) {
          if (b.riskRank != a.riskRank) return b.riskRank > a.riskRank ? b : a;
          return b.highRiskProbability > a.highRiskProbability ? b : a;
        },
      );

  List<MedicationPrediction> get byRiskDescending {
    final List<MedicationPrediction> sorted =
        List<MedicationPrediction>.of(results)
          ..sort((MedicationPrediction a, MedicationPrediction b) {
            final int byRank = b.riskRank.compareTo(a.riskRank);
            return byRank != 0
                ? byRank
                : b.highRiskProbability.compareTo(a.highRiskProbability);
          });
    return sorted;
  }

  Map<String, int> get bandCounts {
    final Map<String, int> counts = <String, int>{
      for (final String band in MedicationPrediction.bandOrder) band: 0,
    };
    for (final MedicationPrediction result in results) {
      counts.update(
        result.prediction.riskCategory,
        (int value) => value + 1,
        ifAbsent: () => 1,
      );
    }
    return counts;
  }

  String get bandSummary {
    final String band = highest.prediction.riskCategory;
    final int count = bandCounts[band] ?? 0;
    final String verb = count == 1 ? 'is' : 'are';
    return '$count of ${results.length} '
        '${results.length == 1 ? 'medicine' : 'medicines'} $verb '
        'in the $band band.';
  }
}
