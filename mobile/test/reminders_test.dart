import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:qolguard/features/reminders/data/reminder_store.dart';
import 'package:qolguard/features/reminders/domain/reminder.dart';

Reminder _reminder({
  String medication = 'Atorvastatin',
  int hour = 8,
  int minute = 0,
  Set<int> weekdays = Reminder.everyDay,
  bool enabled = true,
  int idSeed = 1,
}) {
  return Reminder(
    id: 'reminder-$idSeed',
    medicationName: medication,
    hour: hour,
    minute: minute,
    weekdays: weekdays,
    enabled: enabled,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Reminder labels', () {
    test('pads the time to a 24-hour clock', () {
      expect(_reminder(hour: 8, minute: 5).timeLabel, '08:05');
      expect(_reminder(hour: 20, minute: 30).timeLabel, '20:30');
      expect(_reminder(hour: 0, minute: 0).timeLabel, '00:00');
    });

    test('names common day patterns instead of listing them', () {
      expect(_reminder().daysLabel, 'Every day');
      expect(
        _reminder(weekdays: const <int>{1, 2, 3, 4, 5}).daysLabel,
        'Weekdays',
      );
      expect(_reminder(weekdays: const <int>{6, 7}).daysLabel, 'Weekends');
    });

    test('lists an irregular pattern in day order', () {
      expect(
        _reminder(weekdays: const <int>{5, 1, 3}).daysLabel,
        'Mon, Wed, Fri',
      );
    });
  });

  group('Reminder scheduling identifiers', () {
    test('gives each weekday its own id so days do not overwrite each other',
        () {
      final Reminder reminder =
          _reminder(weekdays: const <int>{1, 3, 5});

      expect(reminder.notificationIds.toSet(), hasLength(3));
    });

    test('ids are stable across instances, so rescheduling replaces', () {
      // If these drifted, every save would add a duplicate alarm rather than
      // updating the existing one.
      expect(
        _reminder(idSeed: 7).notificationId(3),
        _reminder(idSeed: 7).notificationId(3),
      );
    });

    test('two different reminders do not collide', () {
      expect(
        _reminder(idSeed: 1).notificationId(1),
        isNot(_reminder(idSeed: 2).notificationId(1)),
      );
    });
  });

  group('Reminder.nextOccurrence', () {
    // Saturday 15 August 2026, 09:00.
    final DateTime saturdayMorning = DateTime(2026, 8, 15, 9, 0);

    test('finds later today when the time has not passed', () {
      final DateTime? next = _reminder(hour: 20, minute: 0)
          .nextOccurrence(from: saturdayMorning);

      expect(next, DateTime(2026, 8, 15, 20, 0));
    });

    test('rolls to the next matching day once today has passed', () {
      final DateTime? next =
          _reminder(hour: 8, minute: 0).nextOccurrence(from: saturdayMorning);

      expect(next, DateTime(2026, 8, 16, 8, 0));
    });

    test('skips days the reminder does not run on', () {
      // Weekdays only, asked on a Saturday — the answer is Monday.
      final DateTime? next = _reminder(
        hour: 8,
        weekdays: const <int>{1, 2, 3, 4, 5},
      ).nextOccurrence(from: saturdayMorning);

      expect(next, DateTime(2026, 8, 17, 8, 0));
      expect(next!.weekday, DateTime.monday);
    });

    test('a disabled reminder has no next occurrence', () {
      expect(
        _reminder(enabled: false).nextOccurrence(from: saturdayMorning),
        isNull,
      );
    });

    test('a reminder with no days has no next occurrence', () {
      expect(
        _reminder(weekdays: const <int>{}).nextOccurrence(from: saturdayMorning),
        isNull,
      );
    });
  });

  group('ReminderStore', () {
    Future<ReminderStore> freshStore() async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      return ReminderStore(await SharedPreferences.getInstance());
    }

    test('starts empty', () async {
      expect((await freshStore()).readAll(), isEmpty);
    });

    test('round-trips a reminder through JSON', () async {
      final ReminderStore store = await freshStore();
      await store.write(<Reminder>[
        _reminder(medication: 'Metformin', hour: 21, minute: 45,
            weekdays: const <int>{2, 4}, enabled: false),
      ]);

      final Reminder restored = store.readAll().single;
      expect(restored.medicationName, 'Metformin');
      expect(restored.hour, 21);
      expect(restored.minute, 45);
      expect(restored.weekdays, const <int>{2, 4});
      expect(restored.enabled, isFalse);
    });

    test('orders reminders by time of day, as a patient reads their day',
        () async {
      final ReminderStore store = await freshStore();
      await store.write(<Reminder>[
        _reminder(hour: 20, idSeed: 1),
        _reminder(hour: 8, idSeed: 2),
        _reminder(hour: 13, idSeed: 3),
      ]);

      expect(
        store.readAll().map((Reminder r) => r.hour),
        <int>[8, 13, 20],
      );
    });

    test('a corrupt document yields no reminders rather than crashing',
        () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'qolguard.reminders.v1': '{{ not json',
      });
      final ReminderStore store =
          ReminderStore(await SharedPreferences.getInstance());

      expect(store.readAll(), isEmpty);
    });

    test('reminders survive a new store instance', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final ReminderStore first =
          ReminderStore(await SharedPreferences.getInstance());
      await first.write(<Reminder>[_reminder(medication: 'Insulin')]);

      final ReminderStore second =
          ReminderStore(await SharedPreferences.getInstance());

      expect(second.readAll().single.medicationName, 'Insulin');
    });
  });
}
