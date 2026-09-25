import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_state_views.dart';
import '../../medications/data/medication_repository.dart';
import '../../medications/domain/medication.dart';
import '../data/notification_service.dart';
import '../data/reminder_store.dart';
import '../domain/reminder.dart';
import '../../../l10n/app_localizations.dart';

/// Creates or edits a reminder.
///
/// Three fields and nothing else: medication, time, days. Interface complexity
/// was named as a concern by 32.7% of survey respondents, and this is a
/// supporting feature — every extra option here is a cost with no research
/// benefit.
class EditReminderScreen extends ConsumerStatefulWidget {
  const EditReminderScreen({super.key, this.reminderId});

  /// Null when adding a new reminder.
  final String? reminderId;

  @override
  ConsumerState<EditReminderScreen> createState() => _EditReminderScreenState();
}

class _EditReminderScreenState extends ConsumerState<EditReminderScreen> {
  String? _medication;
  TimeOfDay _time = const TimeOfDay(hour: 8, minute: 0);
  Set<int> _weekdays = Reminder.everyDay;
  bool _loaded = false;

  bool get _isEditing => widget.reminderId != null;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AsyncValue<List<Medication>> medications =
        ref.watch(medicationsProvider);
    _loadExisting();

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit reminder' : 'New reminder'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.go(AppRoutes.reminders),
        ),
        actions: <Widget>[
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: l10n.historyDelete,
              onPressed: _delete,
            ),
        ],
      ),
      body: SafeArea(
        child: medications.when(
          loading: () => AppLoadingView(message: l10n.medicationsLoadingMedications),
          error: (Object error, StackTrace _) => AppErrorView(
            error: error,
            onRetry: () => ref.invalidate(medicationsProvider),
          ),
          data: (List<Medication> all) => _Form(
            medications: all,
            medication: _medication ?? all.first.name,
            time: _time,
            weekdays: _weekdays,
            onMedicationChanged: (String value) =>
                setState(() => _medication = value),
            onPickTime: _pickTime,
            onToggleDay: _toggleDay,
            onSave: () => _save(all),
          ),
        ),
      ),
    );
  }

  void _loadExisting() {
    if (_loaded || !_isEditing) return;

    final Reminder? existing = ref
        .read(remindersProvider)
        .where((Reminder reminder) => reminder.id == widget.reminderId)
        .firstOrNull;
    if (existing == null) return;

    _medication = existing.medicationName;
    _time = TimeOfDay(hour: existing.hour, minute: existing.minute);
    _weekdays = Set<int>.of(existing.weekdays);
    _loaded = true;
  }

  Future<void> _pickTime() async {
    final TimeOfDay? picked =
        await showTimePicker(context: context, initialTime: _time);
    if (picked != null) setState(() => _time = picked);
  }

  void _toggleDay(int weekday) {
    setState(() {
      final Set<int> updated = Set<int>.of(_weekdays);
      if (updated.contains(weekday)) {
        updated.remove(weekday);
      } else {
        updated.add(weekday);
      }
      // A reminder with no days would never fire, so the last one cannot be
      // removed — the switch on the list is how you pause a reminder.
      if (updated.isNotEmpty) _weekdays = updated;
    });
  }

  Future<void> _save(List<Medication> medications) async {
    final String name = _medication ?? medications.first.name;
    final Reminders controller = ref.read(remindersProvider.notifier);

    if (_isEditing) {
      final Reminder? existing = ref
          .read(remindersProvider)
          .where((Reminder reminder) => reminder.id == widget.reminderId)
          .firstOrNull;
      if (existing != null) {
        await controller.update(existing.copyWith(
          medicationName: name,
          hour: _time.hour,
          minute: _time.minute,
          weekdays: _weekdays,
        ));
      }
    } else {
      await controller.add(Reminder.create(
        medicationName: name,
        hour: _time.hour,
        minute: _time.minute,
        weekdays: _weekdays,
      ));

      // Ask only once something exists to be notified about, rather than
      // prompting on first launch for a feature not yet in use.
      if (NotificationService.isSupported) {
        final NotificationService service =
            ref.read(notificationServiceProvider);
        if (!await service.hasPermission()) await service.requestPermission();
      }
    }

    if (!mounted) return;
    context.go(AppRoutes.reminders);
  }

  Future<void> _delete() async {
    await ref.read(remindersProvider.notifier).remove(widget.reminderId!);
    if (!mounted) return;
    context.go(AppRoutes.reminders);
  }
}

class _Form extends StatelessWidget {
  const _Form({
    required this.medications,
    required this.medication,
    required this.time,
    required this.weekdays,
    required this.onMedicationChanged,
    required this.onPickTime,
    required this.onToggleDay,
    required this.onSave,
  });

  final List<Medication> medications;
  final String medication;
  final TimeOfDay time;
  final Set<int> weekdays;
  final ValueChanged<String> onMedicationChanged;
  final VoidCallback onPickTime;
  final ValueChanged<int> onToggleDay;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);

    return Column(
      children: <Widget>[
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
            children: <Widget>[
              Text(l10n.remindersMedication,
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: medication,
                isExpanded: true,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: medications
                    .map((Medication drug) => DropdownMenuItem<String>(
                          value: drug.name,
                          child: Text(drug.name),
                        ))
                    .toList(),
                onChanged: (String? value) {
                  if (value != null) onMedicationChanged(value);
                },
              ),
              const SizedBox(height: 28),
              Text(l10n.remindersTime,
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: onPickTime,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 22),
                  decoration: BoxDecoration(
                    border: Border.all(color: theme.colorScheme.outline),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        '${time.hour.toString().padLeft(2, '0')}:'
                        '${time.minute.toString().padLeft(2, '0')}',
                        style: theme.textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                          fontFeatures: const <FontFeature>[
                            FontFeature.tabularFigures(),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      Icon(Icons.schedule,
                          color: theme.colorScheme.onSurfaceVariant),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Text(l10n.remindersRepeatOn,
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  for (int day = 1; day <= 7; day++)
                    FilterChip(
                      label: Text(Reminder.weekdayLabels[day - 1]),
                      selected: weekdays.contains(day),
                      onSelected: (_) => onToggleDay(day),
                    ),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onSave,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text(l10n.remindersSaveReminder),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
