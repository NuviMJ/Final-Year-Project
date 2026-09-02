import '../../assessment/domain/symptom_report.dart';
import '../../medications/domain/medication.dart';
import 'prediction.dart';

/// One medication scored against one reported effect.
class MedicationPrediction {
  const MedicationPrediction({
    required this.medication,
    required this.dose,
    required this.symptom,
    required this.prediction,
  });

  final Medication medication;
  final double dose;
  final SymptomReport symptom;
  final Prediction prediction;

  double get highRiskProbability => prediction.probabilities['High'] ?? 0;

  static const List<String> bandOrder = <String>['Low', 'Medium', 'High'];

  int get riskRank => bandOrder.indexOf(prediction.riskCategory);
}

/// Everything one completed assessment produced.
///
/// No combined score is computed: averaging would rank a patient on a risky
/// medicine plus two safe ones below the same patient on the risky one alone.
class AssessmentOutcome {
  const AssessmentOutcome({required this.results});

  /// Every medication-and-effect pair that was scored.
  final List<MedicationPrediction> results;

  bool get isEmpty => results.isEmpty;

  static int _compare(MedicationPrediction a, MedicationPrediction b) {
    final int byRank = b.riskRank.compareTo(a.riskRank);
    return byRank != 0
        ? byRank
        : b.highRiskProbability.compareTo(a.highRiskProbability);
  }

  /// The worst effect reported for each medication, in selection order.
  List<MedicationPrediction> get worstPerMedication {
    final Map<String, MedicationPrediction> worst =
        <String, MedicationPrediction>{};
    for (final MedicationPrediction result in results) {
      final MedicationPrediction? held = worst[result.medication.name];
      if (held == null || _compare(result, held) < 0) {
        worst[result.medication.name] = result;
      }
    }
    return worst.values.toList();
  }

  bool get isSingle => worstPerMedication.length == 1;

  /// The medication of greatest concern.
  MedicationPrediction get highest =>
      worstPerMedication.reduce((MedicationPrediction a, MedicationPrediction b) =>
          _compare(a, b) <= 0 ? a : b);

  /// One row per medication, most concerning first.
  List<MedicationPrediction> get byRiskDescending =>
      worstPerMedication..sort(_compare);

  /// Every effect scored for one medication, most concerning first.
  List<MedicationPrediction> resultsFor(Medication medication) =>
      results.where((MedicationPrediction r) => r.medication.name == medication.name).toList()
        ..sort(_compare);

  /// How many medications fell in each band.
  Map<String, int> get bandCounts {
    final Map<String, int> counts = <String, int>{
      for (final String band in MedicationPrediction.bandOrder) band: 0,
    };
    for (final MedicationPrediction result in worstPerMedication) {
      counts.update(
        result.prediction.riskCategory,
        (int value) => value + 1,
        ifAbsent: () => 1,
      );
    }
    return counts;
  }

  /// e.g. "1 of 3 medicines is in the Medium band".
  String get bandSummary {
    final int total = worstPerMedication.length;
    final String band = highest.prediction.riskCategory;
    final int count = bandCounts[band] ?? 0;
    return '$count of $total ${total == 1 ? 'medicine' : 'medicines'} '
        '${count == 1 ? 'is' : 'are'} in the $band band.';
  }
}
