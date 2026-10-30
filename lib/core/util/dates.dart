import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';

String _capitalize(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

/// „Środa, 14 października” (GUI 3: daty po polsku, bez skrótów w nagłówkach).
String formatDayLong(DateTime d) => _capitalize(DateFormat('EEEE, d MMMM', 'pl').format(d));

/// „13 paź” do list.
String formatDayShort(DateTime d) => DateFormat('d MMM', 'pl').format(d);

/// „14:30”.
String formatTime(DateTime d) => DateFormat('HH:mm', 'pl').format(d);

/// „Dziś”, „Jutro” albo „Środa, 14 października”.
String formatRelativeDay(AppLocalizations l, DateTime d, DateTime now) {
  final day = DateTime(d.year, d.month, d.day);
  final today = DateTime(now.year, now.month, now.day);
  final diff = day.difference(today).inDays;
  if (diff == 0) return l.dateToday;
  if (diff == 1) return l.dateTomorrow;
  return formatDayLong(d);
}

/// „Dziś 14:30”, „Jutro, cały dzień”, „13 paź 09:00”.
String formatWhen(AppLocalizations l, DateTime start, {required bool allDay, required DateTime now}) {
  final day = formatRelativeDay(l, start, now);
  if (allDay) return '$day, ${l.allDayLabel}';
  return '$day ${formatTime(start)}';
}
