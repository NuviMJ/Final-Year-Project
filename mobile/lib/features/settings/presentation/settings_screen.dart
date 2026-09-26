import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_constants.dart';
import '../../../core/config/env.dart';
import '../../../core/localization/locale_store.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../history/data/assessment_store.dart';
import '../../history/domain/assessment_record.dart';
import '../../reminders/data/reminder_store.dart';
import '../../reminders/domain/reminder.dart';
import '../../startup/data/health_repository.dart';
import '../../../l10n/app_localizations.dart';

/// Where the data lives, and how to get rid of it.
///
/// Privacy was the single largest concern in the requirements survey, at 51%.
/// A patient who cannot see what is stored, take a copy, or delete it does not
/// really control their own health data — so this gets a screen rather than a
/// line in an about box.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);
    final List<AssessmentRecord> assessments =
        ref.watch(assessmentHistoryProvider);
    final List<Reminder> reminders = ref.watch(remindersProvider);
    final AsyncValue<ServiceStatus> service = ref.watch(serviceStatusProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).settingsTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.home),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          children: <Widget>[
            _PrivacyCard(
              assessments: assessments.length,
              reminders: reminders.length,
            ),
            const SizedBox(height: 28),
            _SectionHeading(AppLocalizations.of(context).sectionLanguage),
            const _LanguageSelector(),
            const SizedBox(height: 28),
            _SectionHeading(l10n.settingsYourData),
            _ActionRow(
              icon: Icons.copy_all_outlined,
              title: l10n.settingsCopyMyData,
              subtitle: l10n.settingsPutsEverythingStoredOn,
              onTap: assessments.isEmpty && reminders.isEmpty
                  ? null
                  : () => _copyData(context, assessments, reminders),
            ),
            _ActionRow(
              icon: Icons.delete_outline,
              title: l10n.settingsDeleteEverything,
              subtitle: l10n.settingsRemovesAllAssessmentsAnd,
              destructive: true,
              onTap: assessments.isEmpty && reminders.isEmpty
                  ? null
                  : () => _confirmDelete(context, ref),
            ),
            const SizedBox(height: 28),
            _SectionHeading(l10n.settingsConnection),
            _InfoRow(label: l10n.settingsServer, value: Env.apiBaseUrl),
            _InfoRow(
              label: l10n.settingsModel,
              value: service.maybeWhen(
                data: (ServiceStatus status) => status.modelVersion,
                orElse: () => l10n.settingsNotConnected,
              ),
            ),
            _InfoRow(
              label: l10n.settingsMedications,
              value: service.maybeWhen(
                data: (ServiceStatus status) => '${status.supportedDrugs}',
                orElse: () => '—',
              ),
            ),
            const SizedBox(height: 28),
            _SectionHeading(l10n.settingsAbout),
            _InfoRow(label: l10n.settingsApp, value: AppConstants.appName),
            _InfoRow(label: l10n.settingsPurpose, value: l10n.settingsResearchPrototype),
            const SizedBox(height: 16),
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
                      l10n.medicalDisclaimer,
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Copies everything stored to the clipboard as JSON.
  ///
  /// Chosen over a file export because it works identically on every platform
  /// with no extra package, and it is enough to paste into an email to a
  /// clinician or into a note.
  Future<void> _copyData(
    BuildContext context,
    List<AssessmentRecord> assessments,
    List<Reminder> reminders,
  ) async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String payload = const JsonEncoder.withIndent('  ').convert(
      <String, dynamic>{
        'exported_at': DateTime.now().toIso8601String(),
        'assessments':
            assessments.map((AssessmentRecord r) => r.toJson()).toList(),
        'reminders': reminders.map((Reminder r) => r.toJson()).toList(),
      },
    );

    await Clipboard.setData(ClipboardData(text: payload));
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          l10n.settingsCopiedCount(assessments.length),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(l10n.settingsDeleteEverything2),
        content: Text(
          l10n.settingsAllYourAssessmentsAnd,
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.settingsKeepMyData),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.settingsDeleteEverything),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Reminders are removed one at a time so their scheduled notifications are
    // cancelled with them. Clearing storage alone would leave the operating
    // system still firing alarms for reminders the patient believes are gone.
    final List<Reminder> reminders = ref.read(remindersProvider);
    for (final Reminder reminder in reminders) {
      await ref.read(remindersProvider.notifier).remove(reminder.id);
    }
    await ref.read(assessmentHistoryProvider.notifier).clear();

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.settingsEverythingHasBeenDeleted)),
    );
  }
}

class _PrivacyCard extends StatelessWidget {
  const _PrivacyCard({required this.assessments, required this.reminders});

  final int assessments;
  final int reminders;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.07),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(Icons.lock_outline, color: AppColors.primary, size: 22),
              const SizedBox(width: 10),
              Text(
                l10n.settingsYourDataStaysHere,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            l10n.settingsAssessmentsAndRemindersAre,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          Text(
            l10n.settingsYourAnswersAreSent,
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          Row(
            children: <Widget>[
              _Stat(value: '$assessments', label: l10n.settingsAssessments),
              const SizedBox(width: 28),
              _Stat(value: '$reminders', label: l10n.settingsReminders),
            ],
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: <Widget>[
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
            fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: theme.textTheme.bodySmall
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              letterSpacing: 1.1,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.destructive = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool enabled = onTap != null;
    final Color accent = destructive ? theme.colorScheme.error : AppColors.primary;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      enabled: enabled,
      onTap: onTap,
      leading: Icon(
        icon,
        color: enabled ? accent : theme.colorScheme.onSurfaceVariant,
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: enabled && destructive ? theme.colorScheme.error : null,
        ),
      ),
      subtitle: Text(
        enabled
            ? subtitle
            : AppLocalizations.of(context).settingsNothingStored,
        style: theme.textTheme.bodySmall
            ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageSelector extends ConsumerWidget {
  const _LanguageSelector();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final AppLanguage selected = ref.watch(localeProvider);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              AppLocalizations.of(context).languageSubtitle,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<AppLanguage>(
                segments: <ButtonSegment<AppLanguage>>[
                  for (final AppLanguage language in AppLanguage.values)
                    ButtonSegment<AppLanguage>(
                      value: language,
                      label: Text(language.label),
                    ),
                ],
                selected: <AppLanguage>{selected},
                showSelectedIcon: false,
                onSelectionChanged: (Set<AppLanguage> choice) => ref
                    .read(localeProvider.notifier)
                    .select(choice.first),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
