import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../../core/localization/locale_store.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/reminder.dart';

class NotificationService {
  NotificationService(this._plugin, this._l10n);

  final FlutterLocalNotificationsPlugin _plugin;

  /// Text in the language chosen when the reminder is scheduled.
  final AppLocalizations Function() _l10n;

  static const String _channelId = 'qolguard_medication_reminders';
  static const String _channelName = 'Medication reminders';

  bool _ready = false;

  /// True where the OS can actually schedule notifications.
  static bool get isSupported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  Future<void> initialise() async {
    if (!isSupported || _ready) return;

    // Without this tz.local stays UTC, so an 08:00 reminder fires at 13:30 in
    // Sri Lanka.
    tz_data.initializeTimeZones();
    tz.setLocalLocation(await _deviceLocation());

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
    );

    _ready = true;
  }

  /// The phone's timezone, or failing that any zone with the same UTC offset.
  static Future<tz.Location> _deviceLocation() async {
    try {
      final TimezoneInfo info = await FlutterTimezone.getLocalTimezone();
      return tz.getLocation(info.identifier);
    } catch (_) {
      final Duration offset = DateTime.now().timeZoneOffset;
      return tz.timeZoneDatabase.locations.values.firstWhere(
        (tz.Location location) =>
            location.currentTimeZone.offset == offset.inMilliseconds,
        orElse: () => tz.UTC,
      );
    }
  }

  /// Asks for permission to post notifications.
  ///
  /// Required from Android 13. Returns false if the patient declines, which is
  /// their right — reminders then stay saved but silent, and the UI says so
  /// rather than pretending they will fire.
  Future<bool> requestPermission() async {
    if (!isSupported) return false;
    await initialise();

    final AndroidFlutterLocalNotificationsPlugin? android =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    final bool granted = await android?.requestNotificationsPermission() ?? false;
    return granted;
  }

  Future<bool> hasPermission() async {
    if (!isSupported) return false;
    await initialise();

    final AndroidFlutterLocalNotificationsPlugin? android =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    return await android?.areNotificationsEnabled() ?? false;
  }

  /// Schedules one weekly-repeating notification per selected day.
  Future<void> schedule(Reminder reminder) async {
    if (!isSupported) return;
    await initialise();
    await cancel(reminder);

    if (!reminder.enabled) return;

    final AppLocalizations l10n = _l10n();
    for (final int weekday in reminder.weekdays) {
      await _plugin.zonedSchedule(
        id: reminder.notificationId(weekday),
        title: l10n.remindersNotificationTitle(reminder.medicationName),
        body: l10n.remindersNotificationBody,
        scheduledDate: _nextInstanceOf(weekday, reminder.hour, reminder.minute),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription:
                'Reminds you when a medication is due to be taken.',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        // Inexact scheduling avoids the SCHEDULE_EXACT_ALARM permission, which
        // Google Play restricts to alarm and calendar apps. A medication
        // reminder a few minutes either side of the hour is fine.
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        // Repeats at the same time on the same weekday, so one call covers
        // every future occurrence rather than needing a weekly refresh.
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    }
  }

  Future<void> cancel(Reminder reminder) async {
    if (!isSupported) return;
    await initialise();

    for (final int id in reminder.notificationIds) {
      await _plugin.cancel(id: id);
    }
  }

  /// Re-schedules everything, used at startup so reminders survive a reboot.
  Future<void> rescheduleAll(List<Reminder> reminders) async {
    if (!isSupported) return;
    for (final Reminder reminder in reminders) {
      await schedule(reminder);
    }
  }

  /// The next date and time matching this weekday and clock time.
  static tz.TZDateTime _nextInstanceOf(int weekday, int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime candidate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    while (candidate.weekday != weekday || !candidate.isAfter(now)) {
      candidate = candidate.add(const Duration(days: 1));
    }
    return candidate;
  }
}

final Provider<NotificationService> notificationServiceProvider =
    Provider<NotificationService>(
  (Ref ref) => NotificationService(
    FlutterLocalNotificationsPlugin(),
    () => lookupAppLocalizations(ref.read(localeProvider).locale),
  ),
);
