import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../domain/medication.dart';

class MedicationRepository {
  const MedicationRepository(this._client);

  final ApiClient _client;

  Future<List<Medication>> fetchAll() async {
    final List<dynamic> data = await _client.get<List<dynamic>>('/drugs');
    return data
        .map((dynamic entry) =>
            Medication.fromJson(entry as Map<String, dynamic>))
        .toList();
  }
}

final Provider<MedicationRepository> medicationRepositoryProvider =
    Provider<MedicationRepository>(
  (Ref ref) => MedicationRepository(ref.watch(apiClientProvider)),
);

/// The supported medications, fetched once and cached for the session.
///
/// The list is fixed by the trained model, so re-fetching it on every visit to
/// the screen would be wasted traffic.
final FutureProvider<List<Medication>> medicationsProvider =
    FutureProvider<List<Medication>>(
  (Ref ref) => ref.watch(medicationRepositoryProvider).fetchAll(),
);
