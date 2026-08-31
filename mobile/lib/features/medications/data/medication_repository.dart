import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../domain/medication.dart';

class MedicationRepository {
  const MedicationRepository(this._client);

  final ApiClient _client;

  static const Set<String> acuteTherapies = <String>{
    'Amoxicillin',
    'Ibuprofen',
    'Paracetamol',
  };

  Future<List<Medication>> fetchAll() async {
    final List<dynamic> data = await _client.get<List<dynamic>>('/drugs');
    return data
        .map((dynamic entry) =>
            Medication.fromJson(entry as Map<String, dynamic>))
        .where((Medication drug) => !acuteTherapies.contains(drug.name))
        .toList();
  }
}

final Provider<MedicationRepository> medicationRepositoryProvider =
    Provider<MedicationRepository>(
  (Ref ref) => MedicationRepository(ref.watch(apiClientProvider)),
);

final FutureProvider<List<Medication>> medicationsProvider =
    FutureProvider<List<Medication>>(
  (Ref ref) => ref.watch(medicationRepositoryProvider).fetchAll(),
);
