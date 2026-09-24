import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/config/app_constants.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../history/data/assessment_store.dart';
import '../../history/domain/assessment_record.dart';
import '../../startup/data/health_repository.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final AsyncValue<ServiceStatus> service = ref.watch(serviceStatusProvider);
    final List<AssessmentRecord> history = ref.watch(assessmentHistoryProvider);
    final AssessmentRecord? latest = history.isEmpty ? null : history.first;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        AppConstants.appName,
                        style: theme.textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Quality of life, guarded',
                        style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.settings_outlined),
                  tooltip: 'Settings',
                  onPressed: () => context.go(AppRoutes.settings),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _LatestResultCard(record: latest),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => context.go(AppRoutes.medications),
                icon: const Icon(Icons.assignment_outlined),
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Text(
                    'Start assessment',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Expanded(
                    child: _ShortcutCard(
                      icon: Icons.bar_chart_rounded,
                      title: 'History',
                      subtitle: 'View past results',
                      enabled: history.isNotEmpty,
                      onTap: () => context.go(AppRoutes.history),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ShortcutCard(
                      icon: Icons.lightbulb_outline,
                      title: 'Learning tips',
                      subtitle: 'Improve your score',
                      onTap: () => context.go(AppRoutes.learn),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Icon(Icons.info_outline,
                      size: 20, color: theme.colorScheme.onSurfaceVariant),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      AppConstants.medicalDisclaimer,
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                service.maybeWhen(
                  data: (ServiceStatus status) =>
                      'Model ${status.modelVersion}',
                  orElse: () => '',
                ),
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LatestResultCard extends StatelessWidget {
  const _LatestResultCard({required this.record});

  final AssessmentRecord? record;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    // Three states: nothing recorded yet, a day with no reported effects, and
    // a scored assessment. A no-effects record carries no prediction.
    final bool hasRecord = record != null;
    final bool scored = record?.prediction != null;
    final bool noEffects = record?.noSideEffectsReported ?? false;

    final Color accent = scored
        ? record!.prediction!.color
        : noEffects
            ? AppColors.riskLow
            : theme.colorScheme.outlineVariant;

    final String footer = hasRecord
        ? 'Last checked ${_relativeDay(record!.takenAt)}'
        : 'Take your first assessment';

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: hasRecord
          ? () => context.go('${AppRoutes.history}/${record!.id}')
          : null,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasRecord
                ? accent.withValues(alpha: 0.35)
                : theme.colorScheme.outlineVariant,
          ),
        ),
        child: Column(
          children: <Widget>[
            Text(
              'Latest QoL result',
              style: theme.textTheme.titleMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 20),
            Container(
              width: 156,
              height: 156,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: hasRecord
                    ? accent.withValues(alpha: 0.10)
                    : Colors.transparent,
                border: Border.all(color: accent, width: 5),
              ),
              child: Center(
                child: hasRecord
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            scored
                                ? record!.prediction!.riskCategory
                                : 'No effects',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: accent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            scored ? 'QoL score' : 'reported',
                            style: theme.textTheme.bodyMedium
                                ?.copyWith(color: accent),
                          ),
                        ],
                      )
                    : Icon(
                        Icons.health_and_safety_outlined,
                        size: 46,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              footer,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

  /// "today", "yesterday", "3 days ago", then a date once a week has passed.
  static String _relativeDay(DateTime taken) {
    final DateTime now = DateTime.now();
    final int days = DateTime(now.year, now.month, now.day)
        .difference(DateTime(taken.year, taken.month, taken.day))
        .inDays;

    if (days <= 0) return 'today';
    if (days == 1) return 'yesterday';
    if (days < 7) return '$days days ago';
    return 'on ${DateFormat('d MMM yyyy').format(taken)}';
  }
}

class _ShortcutCard extends StatelessWidget {
  const _ShortcutCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.enabled = true,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color foreground = enabled
        ? theme.colorScheme.onSurface
        : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6);

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: enabled ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Icon(
                icon,
                size: 26,
                color: enabled ? AppColors.primary : foreground,
              ),
              const SizedBox(height: 18),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700, color: foreground),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
