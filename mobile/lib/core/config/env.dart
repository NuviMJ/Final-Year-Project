import 'package:flutter/foundation.dart';

/// Environment configuration resolved at build time.
abstract final class Env {
  /// Overrides the API host, for testing against a deployed backend:
  ///
  /// ```
  /// flutter run --dart-define=API_BASE_URL=https://api.example.com
  /// ```
  static const String _apiBaseUrlOverride =
      String.fromEnvironment('API_BASE_URL');

  static const String _localPort = '8000';

  /// Base URL of the FastAPI backend, excluding the version prefix.
  ///
  /// The Android emulator runs behind its own NAT, so `localhost` there means
  /// the emulator itself, not the development machine. `10.0.2.2` is the alias
  /// the emulator maps to the host loopback. Getting this wrong is the most
  /// common reason a first Flutter/FastAPI integration appears to hang.
  static String get apiBaseUrl {
    if (_apiBaseUrlOverride.isNotEmpty) return _apiBaseUrlOverride;
    if (kIsWeb) return 'http://localhost:$_localPort';

    return switch (defaultTargetPlatform) {
      TargetPlatform.android => 'http://10.0.2.2:$_localPort',
      _ => 'http://localhost:$_localPort',
    };
  }

  /// Full base URL including the API version prefix.
  static String get apiV1BaseUrl => '$apiBaseUrl/api/v1';

  static const Duration connectTimeout = Duration(seconds: 15);

  /// Generous enough to cover model inference while still satisfying the
  /// "prediction should complete within a few seconds" requirement.
  static const Duration receiveTimeout = Duration(seconds: 30);
}
