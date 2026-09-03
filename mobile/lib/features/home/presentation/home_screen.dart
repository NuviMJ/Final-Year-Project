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
            const SizedBox(height: 24),
            _LatestRiskCard(record: latest),
            const SizedBox(height: 24),
            Text(
              'Do next',
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            _ActionTile(
              icon: Icons.assignment_outlined,
              title: 'Start an assessment',
              subtitle: 'Four short steps, about two minutes',
              onTap: () => context.go(AppRoutes.medications),
            ),
            const SizedBox(height: 8),
            _ActionTile(
              icon: Icons.history,
              title: 'Your history',
              subtitle: history.isEmpty
                  ? 'Nothing recorded yet'
                  : '${history.length} assessment'
                      '${history.length == 1 ? '' : 's'} on this device',
              enabled: history.isNotEmpty,
              onTap: () => context.go(AppRoutes.history),
            ),
            const SizedBox(height: 8),
            _ActionTile(
              icon: Icons.menu_book_outlined,
              title: 'Learn',
              subtitle: 'What your result means, and what affects it',
              onTap: () => context.go(AppRoutes.learn),
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

class _LatestRiskCard extends StatelessWidget {
  const _LatestRiskCard({required this.record});

  final AssessmentRecord? record;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool hasResult = record != null;
    final Color accent =
        hasResult ? record!.prediction!.color : AppColors.primary;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: hasResult
          ? () => context.go('${AppRoutes.history}/${record!.id}')
          : null,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: hasResult
                ? accent.withValues(alpha: 0.45)
                : theme.colorScheme.outlineVariant,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'LATEST RESULT',
              style: theme.textTheme.labelSmall?.copyWith(
                letterSpacing: 1.1,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: <Widget>[
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accent.withValues(alpha: 0.12),
                    border: hasResult ? Border.all(color: accent, width: 2) : null,
                  ),
                  child: hasResult
                      ? Center(
                          child: Text(
                            record!.prediction!.riskCategory[0],
                            style: TextStyle(
                              color: accent,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        )
                      : Icon(Icons.health_and_safety_outlined,
                          color: accent, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        hasResult
                            ? '${record!.prediction!.riskCategory} risk'
                            : 'No assessments yet',
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        hasResult
                            ? '${record!.medicationName} · '
                                '${DateFormat('d MMM, HH:mm').format(record!.takenAt)}'
                            : 'Complete one to see your quality-of-life risk here.',
                        style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                if (hasResult) const Icon(Icons.chevron_right),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
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
      child: ListTile(
        enabled: enabled,
        onTap: enabled ? onTap : null,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Icon(icon,
            color: enabled ? AppColors.primary : foreground, size: 26),
        title: Text(
          title,
          style: theme.textTheme.titleSmall
              ?.copyWith(fontWeight: FontWeight.w600, color: foreground),
        ),
        subtitle: Text(
          subtitle,
          style: theme.textTheme.bodySmall
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        trailing: enabled ? const Icon(Icons.chevron_right) : null,
      ),
    );
  }
}
