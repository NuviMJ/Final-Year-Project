import 'package:intl/intl.dart';

import '../../../l10n/app_localizations.dart';
import '../domain/reminder.dart';

/// Short weekday name, 1 = Monday. 1 January 2024 was a Monday.
String weekdayLabel(AppLocalizations l10n, int day) =>
    DateFormat.E(l10n.localeName).format(DateTime(2024, 1, day));

extension ReminderText on Reminder {
  /// "Every day", "Weekdays", or "Mon, Wed, Fri".
  String daysLabel(AppLocalizations l10n) {
    if (weekdays.length == 7) return l10n.remindersEveryDay;
    if (weekdays.length == 5 &&
        weekdays.containsAll(const <int>{1, 2, 3, 4, 5})) {
      return l10n.remindersWeekdays;
    }
    if (weekdays.length == 2 && weekdays.containsAll(const <int>{6, 7})) {
      return l10n.remindersWeekends;
    }

    final List<int> ordered = weekdays.toList()..sort();
    return ordered.map((int day) => weekdayLabel(l10n, day)).join(', ');
  }
}
