import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../history/data/assessment_store.dart';
import '../../history/domain/assessment_record.dart';
import '../domain/trend_summary.dart';
import 'trend_text.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/localization/model_values.dart';

class TrendsScreen extends ConsumerStatefulWidget {
  const TrendsScreen({super.key});

  @override
  ConsumerState<TrendsScreen> createState() => _TrendsScreenState();
}

class _TrendsScreenState extends ConsumerState<TrendsScreen> {
  TrendPeriod _period = TrendPeriod.all;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final List<AssessmentRecord> records =
        ref.watch(assessmentHistoryProvider);
    final TrendSummary summary = TrendSummary.from(records, _period);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.trendsYourTrends),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          children: <Widget>[
            _PeriodSelector(
              selected: _period,
              onChanged: (TrendPeriod period) =>
                  setState(() => _period = period),
            ),
            const SizedBox(height: 20),
            if (!summary.hasEnoughData)
              _NotEnoughData(count: summary.points.length)
            else ...<Widget>[
              _ChartCard(summary: summary),
              const SizedBox(height: 20),
              _DirectionCard(summary: summary),
              const SizedBox(height: 20),
              _BandBreakdown(summary: summary),
            ],
          ],
        ),
      ),
    );
  }
}

class _PeriodSelector extends StatelessWidget {
  const _PeriodSelector({required this.selected, required this.onChanged});

  final TrendPeriod selected;
  final ValueChanged<TrendPeriod> onChanged;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return SizedBox(
      width: double.infinity,
      child: SegmentedButton<TrendPeriod>(
        segments: TrendPeriod.values
            .map((TrendPeriod period) => ButtonSegment<TrendPeriod>(
                  value: period,
                  label: Text(period.label(l10n)),
                ))
            .toList(),
        selected: <TrendPeriod>{selected},
        showSelectedIcon: false,
        onSelectionChanged: (Set<TrendPeriod> selection) =>
            onChanged(selection.first),
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({required this.summary});

  final TrendSummary summary;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);
    final List<TrendPoint> points = summary.points;

    return Container(
      padding: const EdgeInsets.fromLTRB(8, 20, 20, 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  l10n.trendsProbabilityOfHighRisk,
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.trendsTheModelsOwnLikelihood,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 210,
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: 1,
                minX: 0,
                maxX: (points.length - 1).toDouble(),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 0.25,
                  getDrawingHorizontalLine: (double value) => FlLine(
                    color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 42,
                      interval: 0.25,
                      getTitlesWidget: (double value, TitleMeta meta) => Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: Text(
                          '${(value * 100).round()}%',
                          textAlign: TextAlign.right,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontFeatures: const <FontFeature>[
                              FontFeature.tabularFigures(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      interval: _labelInterval(points.length),
                      getTitlesWidget: (double value, TitleMeta meta) {
                        final int index = value.round();
                        if (index < 0 || index >= points.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            DateFormat('d MMM')
                                .format(points[index].takenAt),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (LineBarSpot spot) =>
                        theme.colorScheme.inverseSurface,
                    getTooltipItems: (List<LineBarSpot> spots) =>
                        spots.map((LineBarSpot spot) {
                      final TrendPoint point = points[spot.x.round()];
                      return LineTooltipItem(
                        '${(point.probabilityOfHigh * 100).toStringAsFixed(1)}%'
                        '  ·  ${point.category}\n',
                        TextStyle(
                          color: theme.colorScheme.onInverseSurface,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                        children: <TextSpan>[
                          TextSpan(
                            text: DateFormat('d MMM yyyy')
                                .format(point.takenAt),
                            style: TextStyle(
                              color: theme.colorScheme.onInverseSurface
                                  .withValues(alpha: 0.75),
                              fontWeight: FontWeight.normal,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
                lineBarsData: <LineChartBarData>[
                  LineChartBarData(
                    spots: <FlSpot>[
                      for (int i = 0; i < points.length; i++)
                        FlSpot(i.toDouble(), points[i].probabilityOfHigh),
                    ],
                    isCurved: true,
                    curveSmoothness: 0.22,
                    preventCurveOverShooting: true,
                    color: AppColors.primary,
                    barWidth: 2,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (FlSpot spot, double percent,
                              LineChartBarData bar, int index) =>
                          FlDotCirclePainter(
                        radius: 4.5,
                        color: _bandColour(points[index].category),
                        strokeWidth: 2,
                        strokeColor: theme.colorScheme.surface,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: <Color>[
                          AppColors.primary.withValues(alpha: 0.22),
                          AppColors.primary.withValues(alpha: 0.02),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.only(left: 12),
            child: _BandLegend(),
          ),
        ],
      ),
    );
  }

  /// Keeps date labels from colliding once there are more than a handful.
  static double _labelInterval(int count) {
    if (count <= 4) return 1;
    if (count <= 8) return 2;
    return (count / 4).ceilToDouble();
  }
}

/// Names each band beside its colour, so identity is never carried by colour
/// alone.
class _BandLegend extends StatelessWidget {
  const _BandLegend();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Wrap(
      spacing: 16,
      runSpacing: 6,
      children: <Widget>[
        for (final String band in const <String>['Low', 'Medium', 'High'])
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _bandColour(band),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                riskLabel(AppLocalizations.of(context), band),
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ],
          ),
      ],
    );
  }
}

class _DirectionCard extends StatelessWidget {
  const _DirectionCard({required this.summary});

  final TrendSummary summary;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);
    final (IconData icon, Color colour, String heading) = switch (summary.direction) {
      TrendDirection.rising => (
          Icons.trending_up,
          AppColors.riskHigh,
          l10n.trendsRising
        ),
      TrendDirection.falling => (
          Icons.trending_down,
          AppColors.riskLow,
          l10n.trendsFalling
        ),
      TrendDirection.steady => (
          Icons.trending_flat,
          AppColors.primary,
          l10n.trendsSteady
        ),
      TrendDirection.unknown => (
          Icons.help_outline,
          theme.colorScheme.onSurfaceVariant,
          l10n.trendsNotEnoughData
        ),
    };

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: colour.withValues(alpha: 0.07),
        border: Border.all(color: colour.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(icon, color: colour, size: 22),
              const SizedBox(width: 10),
              Text(
                heading,
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700, color: colour),
              ),
              const Spacer(),
              if (summary.direction != TrendDirection.unknown)
                Text(
                  '${summary.change >= 0 ? '+' : ''}'
                  '${(summary.change * 100).toStringAsFixed(1)} pts',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colour,
                    fontWeight: FontWeight.w600,
                    fontFeatures: const <FontFeature>[
                      FontFeature.tabularFigures(),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(summary.message(l10n), style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _BandBreakdown extends StatelessWidget {
  const _BandBreakdown({required this.summary});

  final TrendSummary summary;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);
    final Map<String, int> counts = summary.bandCounts;
    final int total = summary.points.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          l10n.trendsAssessmentsInThisPeriod,
          style: theme.textTheme.titleSmall
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Row(
          children: <Widget>[
            for (final String band in const <String>['Low', 'Medium', 'High'])
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: band == 'High' ? 0 : 10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: _bandColour(band).withValues(alpha: 0.10),
                    ),
                    child: Column(
                      children: <Widget>[
                        Text(
                          '${counts[band] ?? 0}',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: _bandColour(band),
                            fontWeight: FontWeight.bold,
                            fontFeatures: const <FontFeature>[
                              FontFeature.tabularFigures(),
                            ],
                          ),
                        ),
                        Text(riskLabel(l10n, band), style: theme.textTheme.bodySmall),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          l10n.trendsSummaryLine(
              total, (summary.highest * 100).toStringAsFixed(0)),
          style: theme.textTheme.bodySmall
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _NotEnoughData extends StatelessWidget {
  const _NotEnoughData({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 12),
      child: Column(
        children: <Widget>[
          Icon(Icons.show_chart,
              size: 46, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(height: 16),
          Text(
            count == 0
                ? l10n.trendsNoneInPeriod
                : l10n.trendsOneSoFar,
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            // Said plainly rather than shown as an empty chart: a trend from a
            // single point is not a weak trend, it is not a trend at all.
            l10n.trendsATrendNeedsAt,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

Color _bandColour(String band) => switch (band) {
      'Low' => AppColors.riskLow,
      'Medium' => AppColors.riskMedium,
      _ => AppColors.riskHigh,
    };
