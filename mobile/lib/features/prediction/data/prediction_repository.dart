import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../assessment/application/assessment_controller.dart';
import '../../assessment/domain/symptom_report.dart';
import '../../medications/domain/medication.dart';
import '../domain/assessment_outcome.dart';
import '../domain/prediction.dart';

class PredictionRepository {
  const PredictionRepository(this._client);

  final ApiClient _client;

  Future<Prediction> predict(Map<String, dynamic> assessment) async {
    final Map<String, dynamic> data = await _client.post<Map<String, dynamic>>(
      '/predict',
      body: assessment,
    );
    return Prediction.fromJson(data);
  }

  /// One prediction per medication and reported effect.
  ///
  /// Sequential, stopping at the first failure: every request shares the same
  /// answers, so a rejected field would fail them all identically.
  Future<AssessmentOutcome> predictAll(AssessmentDraft draft) async {
    final List<MedicationPrediction> results = <MedicationPrediction>[];

    for (final Medication medication in draft.medications) {
      for (final SymptomReport symptom in draft.symptoms) {
        final Prediction prediction =
            await predict(draft.toRequestFor(medication, symptom));
        results.add(
          MedicationPrediction(
            medication: medication,
            dose: draft.doseFor(medication),
            symptom: symptom,
            prediction: prediction,
          ),
        );
      }
    }

    return AssessmentOutcome(results: results);
  }
}

final Provider<PredictionRepository> predictionRepositoryProvider =
    Provider<PredictionRepository>(
  (Ref ref) => PredictionRepository(ref.watch(apiClientProvider)),
);

/// Holds the outcome of the submission currently on screen.
///
/// `AsyncValue` carries the loading, success and failure states together, so
/// the result screen renders all three without a separate flag for each.
class PredictionController extends AsyncNotifier<AssessmentOutcome?> {
  @override
  Future<AssessmentOutcome?> build() async => null;

  /// Submit the completed assessment for every medication it covers.
  Future<void> submit(AssessmentDraft draft) async {
    state = const AsyncValue<AssessmentOutcome?>.loading();
    state = await AsyncValue.guard<AssessmentOutcome?>(
      () => ref.read(predictionRepositoryProvider).predictAll(draft),
    );
  }

  void reset() => state = const AsyncValue<AssessmentOutcome?>.data(null);
}

final AsyncNotifierProvider<PredictionController, AssessmentOutcome?>
    predictionControllerProvider =
    AsyncNotifierProvider<PredictionController, AssessmentOutcome?>(
  PredictionController.new,
);
