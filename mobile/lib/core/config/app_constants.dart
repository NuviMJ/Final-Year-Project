/// Application-wide constants.
abstract final class AppConstants {
  static const String appName = 'QoLGuard';
  static const String appTagline =
      'Early detection of quality-of-life decline in long-term medication users';

  /// Shown wherever a risk result is displayed.
  ///
  /// Required by the specification: the application is decision support, not a
  /// diagnosis. This wording is deliberately kept in one place so it cannot
  /// drift between screens.
  static const String medicalDisclaimer =
      'QoLGuard does not diagnose medical conditions and does not replace '
      'advice from a healthcare professional. Always consult your doctor or '
      'pharmacist before changing any medication.';
}
