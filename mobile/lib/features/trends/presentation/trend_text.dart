import '../../../l10n/app_localizations.dart';
import '../domain/trend_summary.dart';

extension TrendPeriodLabel on TrendPeriod {
  String label(AppLocalizations l10n) => switch (this) {
        TrendPeriod.month => l10n.trendsPeriodMonth,
        TrendPeriod.quarter => l10n.trendsPeriodQuarter,
        TrendPeriod.all => l10n.trendsPeriodAll,
      };
}

extension TrendSummaryText on TrendSummary {
  /// Wording that describes the movement without instructing the patient.
  String message(AppLocalizations l10n) => switch (direction) {
        TrendDirection.rising => l10n.trendsMessageRising,
        TrendDirection.falling => l10n.trendsMessageFalling,
        TrendDirection.steady => l10n.trendsMessageSteady,
        TrendDirection.unknown => l10n.trendsMessageUnknown,
      };
}
