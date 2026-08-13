import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/env.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';

/// What the backend reports about itself on startup.
class ServiceStatus {
  const ServiceStatus({
    required this.appName,
    required this.version,
    required this.modelLoaded,
    required this.modelVersion,
    required this.supportedDrugs,
  });

  final String appName;
  final String version;
  final bool modelLoaded;

  /// Identifies the deployment bundle in use, so a demo can never silently run
  /// against the wrong model.
  final String modelVersion;

  final int supportedDrugs;

  factory ServiceStatus.fromJson(Map<String, dynamic> json) {
    return ServiceStatus(
      appName: json['app'] as String? ?? 'QoLGuard API',
      version: json['version'] as String? ?? '',
      modelLoaded: json['model_loaded'] as bool? ?? false,
      modelVersion: json['model_version'] as String? ?? 'unknown',
      supportedDrugs: json['supported_drugs'] as int? ?? 0,
    );
  }
}

class HealthRepository {
  const HealthRepository(this._dio);

  final Dio _dio;

  /// Calls `/health`, which sits outside the versioned API prefix — hence the
  /// absolute URL rather than a path relative to the Dio base.
  Future<ServiceStatus> check() async {
    try {
      final Response<Map<String, dynamic>> response =
          await _dio.get<Map<String, dynamic>>('${Env.apiBaseUrl}/health');
      return ServiceStatus.fromJson(response.data ?? <String, dynamic>{});
    } on DioException catch (error) {
      throw ApiException.from(error);
    }
  }
}

final Provider<HealthRepository> healthRepositoryProvider =
    Provider<HealthRepository>(
  (Ref ref) => HealthRepository(ref.watch(dioProvider)),
);

final FutureProvider<ServiceStatus> serviceStatusProvider =
    FutureProvider<ServiceStatus>(
  (Ref ref) => ref.watch(healthRepositoryProvider).check(),
);
