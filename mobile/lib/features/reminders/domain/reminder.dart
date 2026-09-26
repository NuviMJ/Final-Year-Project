/// A recurring medication reminder, stored on the device.
///
/// The most requested feature in the requirements survey, at 62% — ahead of the
/// risk prediction itself. It is a supporting feature rather than part of the
/// research contribution: the model is not involved at any point.
class Reminder {
  const Reminder({
    required this.id,
    required this.medicationName,
    required this.hour,
    required this.minute,
    required this.weekdays,
    this.enabled = true,
  });

  final String id;
  final String medicationName;

  /// 24-hour clock.
  final int hour;
  final int minute;

  /// Days this reminder fires, using Dart's convention where Monday is 1 and
  /// Sunday is 7 — the same numbering as [DateTime.weekday], so no conversion
  /// is needed when scheduling.
  final Set<int> weekdays;

  /// A disabled reminder is kept but not scheduled, so a patient can pause one
  /// without losing the setup.
  final bool enabled;

  static const Set<int> everyDay = <int>{1, 2, 3, 4, 5, 6, 7};

  factory Reminder.create({
    required String medicationName,
    required int hour,
    required int minute,
    required Set<int> weekdays,
    DateTime? createdAt,
  }) {
    return Reminder(
      id: (createdAt ?? DateTime.now()).microsecondsSinceEpoch.toString(),
      medicationName: medicationName,
      hour: hour,
      minute: minute,
      weekdays: weekdays,
    );
  }

  Reminder copyWith({
    String? medicationName,
    int? hour,
    int? minute,
    Set<int>? weekdays,
    bool? enabled,
  }) {
    return Reminder(
      id: id,
      medicationName: medicationName ?? this.medicationName,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      weekdays: weekdays ?? this.weekdays,
      enabled: enabled ?? this.enabled,
    );
  }

  /// "08:00"
  String get timeLabel =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

  /// Each weekday needs its own scheduled notification, and each needs a
  /// distinct integer id for the OS. Deriving it from the reminder id plus the
  /// weekday keeps them stable across restarts, so rescheduling replaces rather
  /// than duplicates.
  int notificationId(int weekday) =>
      (id.hashCode.abs() % 100000) * 10 + weekday;

  List<int> get notificationIds =>
      weekdays.map(notificationId).toList(growable: false);

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'medication_name': medicationName,
        'hour': hour,
        'minute': minute,
        'weekdays': weekdays.toList()..sort(),
        'enabled': enabled,
      };

  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      id: json['id'] as String,
      medicationName: json['medication_name'] as String,
      hour: json['hour'] as int,
      minute: json['minute'] as int,
      weekdays: (json['weekdays'] as List<dynamic>)
          .map((dynamic day) => day as int)
          .toSet(),
      enabled: json['enabled'] as bool? ?? true,
    );
  }

  /// When this reminder next fires, or null if it is disabled or has no days.
  ///
  /// Used to tell the patient "next at 08:00 tomorrow" rather than making them
  /// work it out from a list of days.
  DateTime? nextOccurrence({DateTime? from}) {
    if (!enabled || weekdays.isEmpty) return null;

    final DateTime reference = from ?? DateTime.now();
    for (int offset = 0; offset < 8; offset++) {
      final DateTime day = reference.add(Duration(days: offset));
      if (!weekdays.contains(day.weekday)) continue;

      final DateTime candidate =
          DateTime(day.year, day.month, day.day, hour, minute);
      if (candidate.isAfter(reference)) return candidate;
    }
    return null;
  }
}
