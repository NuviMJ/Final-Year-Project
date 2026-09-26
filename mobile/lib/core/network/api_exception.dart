import 'package:dio/dio.dart';

/// A failure the user can be shown, translated from a raw [DioException].
///
/// Dio throws one exception type for everything from a DNS failure to a 422.
/// Screens need to tell those apart — "check your connection" and "age must be
/// between 18 and 90" call for very different responses — so every error is
/// mapped to a [ApiFailure] the moment it leaves the client.
enum ApiFailure {
  /// The backend could not be reached at all: wrong URL, server not running,
  /// no network. By far the most common problem during development.
  unreachable,

  /// The request reached the server but took too long to come back.
  timeout,

  /// The request was cancelled before it completed.
  cancelled,

  /// The submitted data failed validation (HTTP 422).
  validation,

  /// The requested resource does not exist (HTTP 404).
  notFound,

  /// The server failed while handling a valid request (HTTP 5xx).
  server,

  /// Anything not covered above.
  unknown,
}

class ApiException implements Exception {
  const ApiException({
    required this.failure,
    required this.message,
    this.fieldErrors = const <String, String>{},
    this.statusCode,
  });

  final ApiFailure failure;

  /// Wording intended to be shown directly to a patient.
  final String message;

  /// Field name to error message, populated for validation failures so a form
  /// can mark the offending input rather than showing a banner.
  final Map<String, String> fieldErrors;

  final int? statusCode;

  bool get isValidation => failure == ApiFailure.validation;

  factory ApiException.from(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionError:
      case DioExceptionType.badCertificate:
        return const ApiException(
          failure: ApiFailure.unreachable,
          message:
              'Cannot reach the QoLGuard server. Check that it is running and '
              'that the app is pointed at the right address.',
        );

      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return const ApiException(
          failure: ApiFailure.timeout,
          message: 'The server took too long to respond. Please try again.',
        );

      case DioExceptionType.badResponse:
        return _fromResponse(error.response);

      case DioExceptionType.cancel:
        return const ApiException(
          failure: ApiFailure.cancelled,
          message: 'The request was cancelled.',
        );

      case DioExceptionType.unknown:
        return ApiException(
          failure: ApiFailure.unreachable,
          message:
              'Cannot reach the QoLGuard server. Check that it is running and '
              'that the app is pointed at the right address.',
          statusCode: error.response?.statusCode,
        );
    }
  }

  static ApiException _fromResponse(Response<dynamic>? response) {
    final int status = response?.statusCode ?? 0;

    if (status == 422) {
      return ApiException(
        failure: ApiFailure.validation,
        message: 'Some of the details entered are outside the accepted range.',
        fieldErrors: _parseFieldErrors(response?.data),
        statusCode: status,
      );
    }

    if (status == 404) {
      return ApiException(
        failure: ApiFailure.notFound,
        message: _detailMessage(response?.data) ??
            'That medication is not supported.',
        statusCode: status,
      );
    }

    if (status >= 500) {
      return ApiException(
        failure: ApiFailure.server,
        message: 'The server could not complete the request. Please try again.',
        statusCode: status,
      );
    }

    return ApiException(
      failure: ApiFailure.unknown,
      message: _detailMessage(response?.data) ?? 'Something went wrong.',
      statusCode: status,
    );
  }

  /// FastAPI returns validation errors as a list of entries shaped
  /// `{"loc": ["body", "Age"], "msg": "...", "type": "..."}`. The field name is
  /// the last element of `loc`; everything before it is the request location.
  static Map<String, String> _parseFieldErrors(dynamic data) {
    final Map<String, String> errors = <String, String>{};
    if (data is! Map || data['detail'] is! List) return errors;

    for (final dynamic entry in data['detail'] as List<dynamic>) {
      if (entry is! Map) continue;
      final dynamic location = entry['loc'];
      if (location is! List || location.isEmpty) continue;

      final String field = location.last.toString();
      final String message = (entry['msg'] ?? 'Invalid value').toString();
      errors[field] = message;
    }
    return errors;
  }

  static String? _detailMessage(dynamic data) {
    if (data is Map && data['detail'] is String) return data['detail'] as String;
    return null;
  }

  @override
  String toString() => 'ApiException($failure, $statusCode): $message';
}
