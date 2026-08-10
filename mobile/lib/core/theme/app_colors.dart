import 'package:flutter/material.dart';

/// The application colour palette.
///
/// Two groups live here:
///  * brand colours, used for chrome and navigation, and
///  * semantic colours, which carry clinical meaning and must stay consistent
///    everywhere a risk level is shown.
abstract final class AppColors {
  // --- Brand ---
  /// Calm medical teal. Chosen over a clinical red/blue so the app does not
  /// read as an emergency tool — it is a monitoring aid.
  static const Color primary = Color(0xFF0F766E);
  static const Color primaryLight = Color(0xFF14B8A6);
  static const Color primaryDark = Color(0xFF115E59);
  static const Color accent = Color(0xFF0EA5E9);

  // --- Neutrals ---
  static const Color surfaceLight = Color(0xFFF8FAFC);
  static const Color surfaceDark = Color(0xFF0F172A);
  static const Color outline = Color(0xFFCBD5E1);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);

  // --- QoL risk categories ---
  /// The model's three output classes, in the order the backend reports them.
  static const Color riskLow = Color(0xFF16A34A);
  static const Color riskMedium = Color(0xFFD97706);
  static const Color riskHigh = Color(0xFFDC2626);
}
