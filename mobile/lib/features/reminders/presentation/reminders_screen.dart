import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../data/notification_service.dart';
import '../data/reminder_store.dart';
import '../domain/reminder.dart';
import '../../../l10n/app_localizations.dart';

/// Scheduled medication reminders.
///
/// The most requested feature in the requirements survey (62%), and the one
/// most likely to bring a patient back to the app — which in turn produces the
/// repeat assessments the trend screen needs.
class RemindersScreen extends ConsumerStatefulWidget {
  const RemindersScreen({super.key});

  @override
  ConsumerState<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends ConsumerState<RemindersScreen> {
  bool? _notificationsAllowed;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    final bool allowed =
        await ref.read(notificationServiceProvider).hasPermission();
    if (mounted) setState(() => _notificationsAllowed = allowed);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final List<Reminder> reminders = ref.watch(remindersProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navReminders),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go(AppRoutes.addReminder),
        icon: const Icon(Icons.add),
        label: Text(l10n.remindersAddReminder),
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            if (NotificationService.isSupported && _notificationsAllowed == false)
              _PermissionBanner(onGrant: _requestPermission)
            else if (!NotificationService.isSupported)
              const _UnsupportedBanner(),
            Expanded(
              child: reminders.isEmpty
                  ? const _Empty()
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                      itemCount: reminders.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (BuildContext context, int index) =>
                          _ReminderTile(reminder: reminders[index]),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _requestPermission() async {
    final bool granted =
        await ref.read(notificationServiceProvider).requestPermission();
    if (!mounted) return;

    setState(() => _notificationsAllowed = granted);
    if (granted) await ref.read(remindersProvider.notifier).rescheduleAll();
  }
}

/// Shown when the patient has not granted notification permission.
///
/// Says plainly that reminders will not fire, rather than leaving them to
/// discover it by missing a dose.
class _PermissionBanner extends StatelessWidget {
  const _PermissionBanner({required this.onGrant});

  final VoidCallback onGrant;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.riskMedium.withValues(alpha: 0.10),
        border: Border.all(color: AppColors.riskMedium.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Icon(Icons.notifications_off_outlined,
              size: 20, color: AppColors.riskMedium),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  l10n.remindersNotificationsAreTurnedOff,
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.remindersYourRemindersAreSaved,
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                FilledButton.tonal(
                  onPressed: onGrant,
                  child: Text(l10n.remindersAllowNotifications),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UnsupportedBanner extends StatelessWidget {
  const _UnsupportedBanner();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: <Widget>[
          Icon(Icons.info_outline,
              size: 20, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.remindersRemindersCanBeSet,
              style: theme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(Icons.alarm_outlined,
                size: 46, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(height: 16),
            Text(
              l10n.remindersNoRemindersYet,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(
              l10n.remindersAddOneToBe,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReminderTile extends ConsumerWidget {
  const _ReminderTile({required this.reminder});

  final Reminder reminder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final DateTime? next = reminder.nextOccurrence();

    return Dismissible(
      key: ValueKey<String>(reminder.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: theme.colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.delete_outline,
            color: theme.colorScheme.onErrorContainer),
      ),
      onDismissed: (_) =>
          ref.read(remindersProvider.notifier).remove(reminder.id),
      child: Card(
        margin: EdgeInsets.zero,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => context.go('${AppRoutes.reminders}/${reminder.id}'),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
            child: Row(
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      reminder.timeLabel,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: reminder.enabled
                            ? theme.colorScheme.onSurface
                            : theme.colorScheme.onSurfaceVariant,
                        fontFeatures: const <FontFeature>[
                          FontFeature.tabularFigures(),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        reminder.medicationName,
                        style: theme.textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        reminder.daysLabel,
                        style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant),
                      ),
                      if (reminder.enabled && next != null)
                        Text(
                          'Next ${_relative(next)}',
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: AppColors.primary),
                        ),
                    ],
                  ),
                ),
                Switch(
                  value: reminder.enabled,
                  onChanged: (bool value) => ref
                      .read(remindersProvider.notifier)
                      .setEnabled(reminder.id, value),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// "today at 20:00", "tomorrow at 08:00", or "Thu at 08:00" — easier to act
  /// on than a bare date.
  static String _relative(DateTime at) {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final int days = DateTime(at.year, at.month, at.day).difference(today).inDays;
    final String time = DateFormat('HH:mm').format(at);

    return switch (days) {
      0 => 'today at $time',
      1 => 'tomorrow at $time',
      _ => '${DateFormat('EEE').format(at)} at $time',
    };
  }
}
