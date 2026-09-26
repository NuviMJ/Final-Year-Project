import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// A quality-of-life risk classification returned by the model.
class Prediction {
  const Prediction({
    required this.riskCategory,
    required this.confidence,
    required this.probabilities,
    required this.modelVersion,
  });

  final String riskCategory;

  /// Probability assigned to the predicted class.
  final double confidence;

  /// Probability for every class, so the result screen can show how close the
  /// call was rather than presenting a single category as certainty.
  final Map<String, double> probabilities;

  /// Identifies the deployment bundle that produced this result, so a stored
  /// prediction can later be traced to the model behind it.
  final String modelVersion;

  factory Prediction.fromJson(Map<String, dynamic> json) {
    return Prediction(
      riskCategory: json['risk_category'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      probabilities: (json['probabilities'] as Map<String, dynamic>).map(
        (String key, dynamic value) =>
            MapEntry<String, double>(key, (value as num).toDouble()),
      ),
      modelVersion: json['model_version'] as String? ?? 'unknown',
    );
  }

  Color get color => switch (riskCategory) {
        'Low' => AppColors.riskLow,
        'Medium' => AppColors.riskMedium,
        _ => AppColors.riskHigh,
      };
}
