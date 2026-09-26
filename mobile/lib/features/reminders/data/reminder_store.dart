import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/localization/locale_store.dart';
import '../../history/data/assessment_store.dart';
import '../domain/reminder.dart';
import 'notification_service.dart';

/// On-device store for medication reminders.
///
/// Uses the same mechanism as assessment history so the app has one storage
/// story rather than two, and nothing is sent anywhere.
class ReminderStore {
  const ReminderStore(this._preferences);

  static const String _key = 'qolguard.reminders.v1';

  final SharedPreferences _preferences;

  List<Reminder> readAll() {
    final String? raw = _preferences.getString(_key);
    if (raw == null || raw.isEmpty) return const <Reminder>[];

    try {
      final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
      final List<Reminder> reminders = decoded
          .map((dynamic entry) =>
              Reminder.fromJson(entry as Map<String, dynamic>))
          .toList();
      // Ordered by clock time, which is how a patient thinks about their day.
      reminders.sort((Reminder a, Reminder b) =>
          (a.hour * 60 + a.minute).compareTo(b.hour * 60 + b.minute));
      return reminders;
    } on FormatException {
      return const <Reminder>[];
    }
  }

  Future<void> write(List<Reminder> reminders) async {
    await _preferences.setString(
      _key,
      jsonEncode(reminders.map((Reminder r) => r.toJson()).toList()),
    );
  }

  Future<void> clear() => _preferences.remove(_key);
}

final Provider<ReminderStore> reminderStoreProvider =
    Provider<ReminderStore>((Ref ref) {
  return ReminderStore(ref.watch(sharedPreferencesProvider).requireValue);
});

/// The reminders, kept in sync with what the operating system has scheduled.
///
/// Every mutation writes to storage and updates the OS schedule together, so
/// the list on screen and the alarms that will actually fire cannot drift apart.
class Reminders extends Notifier<List<Reminder>> {
  @override
  List<Reminder> build() {
    // Scheduled notifications keep their text, so rewrite them on a switch.
    ref.listen(localeProvider, (AppLanguage? previous, AppLanguage next) {
      if (previous != next) rescheduleAll();
    });
    return ref.watch(reminderStoreProvider).readAll();
  }

  Future<void> add(Reminder reminder) async {
    final List<Reminder> updated = <Reminder>[...state, reminder];
    await _persist(updated);
    await ref.read(notificationServiceProvider).schedule(reminder);
  }

  Future<void> update(Reminder reminder) async {
    final List<Reminder> updated = state
        .map((Reminder existing) =>
            existing.id == reminder.id ? reminder : existing)
        .toList();
    await _persist(updated);
    await ref.read(notificationServiceProvider).schedule(reminder);
  }

  Future<void> remove(String id) async {
    final Reminder? doomed =
        state.where((Reminder reminder) => reminder.id == id).firstOrNull;
    final List<Reminder> updated =
        state.where((Reminder reminder) => reminder.id != id).toList();

    await _persist(updated);
    if (doomed != null) {
      await ref.read(notificationServiceProvider).cancel(doomed);
    }
  }

  Future<void> setEnabled(String id, bool enabled) async {
    final Reminder? target =
        state.where((Reminder reminder) => reminder.id == id).firstOrNull;
    if (target == null) return;
    await update(target.copyWith(enabled: enabled));
  }

  /// Re-registers every reminder with the OS.
  ///
  /// Called at startup because Android clears scheduled notifications when the
  /// device restarts.
  Future<void> rescheduleAll() =>
      ref.read(notificationServiceProvider).rescheduleAll(state);

  Future<void> _persist(List<Reminder> reminders) async {
    await ref.read(reminderStoreProvider).write(reminders);
    state = ref.read(reminderStoreProvider).readAll();
  }
}

final NotifierProvider<Reminders, List<Reminder>> remindersProvider =
    NotifierProvider<Reminders, List<Reminder>>(Reminders.new);

/// The reminder due soonest, for the home screen.
final Provider<Reminder?> nextReminderProvider = Provider<Reminder?>((Ref ref) {
  final List<Reminder> reminders = ref.watch(remindersProvider);
  final DateTime now = DateTime.now();

  Reminder? soonest;
  DateTime? soonestAt;

  for (final Reminder reminder in reminders) {
    final DateTime? at = reminder.nextOccurrence(from: now);
    if (at == null) continue;
    if (soonestAt == null || at.isBefore(soonestAt)) {
      soonest = reminder;
      soonestAt = at;
    }
  }
  return soonest;
});
