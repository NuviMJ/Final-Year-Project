import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../domain/field_spec.dart';

class SchemaRepository {
  const SchemaRepository(this._client);

  final ApiClient _client;

  Future<AssessmentSchema> fetch() async {
    final Map<String, dynamic> data =
        await _client.get<Map<String, dynamic>>('/schema');
    return AssessmentSchema.fromJson(data);
  }
}

final Provider<SchemaRepository> schemaRepositoryProvider =
    Provider<SchemaRepository>(
  (Ref ref) => SchemaRepository(ref.watch(apiClientProvider)),
);

/// The input contract, fetched once per session.
///
/// It only changes when the model is retrained and redeployed, so re-fetching
/// it per assessment would be wasted traffic.
final FutureProvider<AssessmentSchema> assessmentSchemaProvider =
    FutureProvider<AssessmentSchema>(
  (Ref ref) => ref.watch(schemaRepositoryProvider).fetch(),
);
