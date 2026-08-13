import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
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
}

final Provider<PredictionRepository> predictionRepositoryProvider =
    Provider<PredictionRepository>(
  (Ref ref) => PredictionRepository(ref.watch(apiClientProvider)),
);

/// Holds the outcome of the submission currently on screen.
///
/// `AsyncValue` carries the loading, success and failure states together, so
/// the result screen renders all three without a separate flag for each.
class PredictionController extends AsyncNotifier<Prediction?> {
  @override
  Future<Prediction?> build() async => null;

  Future<void> submit(Map<String, dynamic> assessment) async {
    state = const AsyncValue<Prediction?>.loading();
    state = await AsyncValue.guard<Prediction?>(
      () => ref.read(predictionRepositoryProvider).predict(assessment),
    );
  }

  void reset() => state = const AsyncValue<Prediction?>.data(null);
}

final AsyncNotifierProvider<PredictionController, Prediction?>
    predictionControllerProvider =
    AsyncNotifierProvider<PredictionController, Prediction?>(
  PredictionController.new,
);
