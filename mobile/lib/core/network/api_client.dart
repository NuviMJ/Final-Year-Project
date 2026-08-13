import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/env.dart';
import 'api_exception.dart';

/// Thin wrapper over Dio that guarantees every failure leaving it is an
/// [ApiException] rather than a raw [DioException].
///
/// Screens then never handle Dio types directly, and the "cannot reach the
/// server" case — overwhelmingly the most common during development — is
/// reported in words a patient could act on.
class ApiClient {
  ApiClient(this._dio);

  final Dio _dio;

  Future<T> get<T>(String path) async {
    try {
      final Response<T> response = await _dio.get<T>(path);
      return response.data as T;
    } on DioException catch (error) {
      throw ApiException.from(error);
    }
  }

  Future<T> post<T>(String path, {Object? body}) async {
    try {
      final Response<T> response = await _dio.post<T>(path, data: body);
      return response.data as T;
    } on DioException catch (error) {
      throw ApiException.from(error);
    }
  }
}

/// The configured Dio instance.
///
/// Dio's default behaviour already raises [DioException.badResponse] for any
/// non-2xx status with the response body attached, which is what
/// [ApiException] needs to pull the offending field out of a FastAPI 422. No
/// interceptor is required for that.
final Provider<Dio> dioProvider = Provider<Dio>((Ref ref) {
  return Dio(
    BaseOptions(
      baseUrl: Env.apiV1BaseUrl,
      connectTimeout: Env.connectTimeout,
      receiveTimeout: Env.receiveTimeout,
      headers: <String, String>{'Content-Type': 'application/json'},
      responseType: ResponseType.json,
    ),
  );
});

final Provider<ApiClient> apiClientProvider = Provider<ApiClient>(
  (Ref ref) => ApiClient(ref.watch(dioProvider)),
);
