enum RecurrenceType {
  weekly,
  monthly,
  yearly;

  static RecurrenceType? parse(Object? value) {
    for (final t in RecurrenceType.values) {
      if (t.name == value) return t;
    }
    return null;
  }
}

class Recurrence {
  const Recurrence({required this.type, this.until});

  final RecurrenceType type;

  /// Ostatni dzień cyklu (włącznie), czas lokalny; null = bez końca.
  final DateTime? until;
}

class CalendarEvent {
  const CalendarEvent({
    required this.id,
    required this.title,
    required this.start,
    required this.end,
    required this.allDay,
    required this.isPrivate,
    this.location = '',
    this.description = '',
    this.participants = const [],
    this.reminderMinutes,
    this.recurrence,
    this.createdBy,
    this.colorIndex = 0,
  });

  final String id;
  final String title;

  /// Czas lokalny pierwszego wystąpienia. Dla całodziennych: północ dnia początku i północ
  /// dnia po końcu.
  final DateTime start;
  final DateTime end;
  final bool allDay;
  final bool isPrivate;
  final String location;
  final String description;
  final List<String> participants;
  final int? reminderMinutes;
  final Recurrence? recurrence;
  final String? createdBy;

  /// 0–4: kolor z tokenów chart1…chart5 (typ wydarzenia wybrany przez użytkownika).
  final int colorIndex;

  Duration get duration => end.difference(start);

  CalendarEvent copyWith({
    String? title,
    DateTime? start,
    DateTime? end,
    bool? allDay,
    bool? isPrivate,
    String? location,
    String? description,
    List<String>? participants,
    int? reminderMinutes,
    Recurrence? recurrence,
    bool clearRecurrence = false,
    bool clearReminder = false,
    int? colorIndex,
  }) =>
      CalendarEvent(
        id: id,
        title: title ?? this.title,
        start: start ?? this.start,
        end: end ?? this.end,
        allDay: allDay ?? this.allDay,
        isPrivate: isPrivate ?? this.isPrivate,
        location: location ?? this.location,
        description: description ?? this.description,
        participants: participants ?? this.participants,
        reminderMinutes: clearReminder ? null : (reminderMinutes ?? this.reminderMinutes),
        recurrence: clearRecurrence ? null : (recurrence ?? this.recurrence),
        createdBy: createdBy,
        colorIndex: colorIndex ?? this.colorIndex,
      );
}

/// Jedno wystąpienie wydarzenia (dla cyklicznych: przesunięte w czasie).
class EventOccurrence {
  const EventOccurrence({required this.event, required this.start, required this.end});

  final CalendarEvent event;
  final DateTime start;
  final DateTime end;

  /// Dzień kalendarzowy (lokalny), pod którym wystąpienie jest pokazywane.
  DateTime get day => DateTime(start.year, start.month, start.day);
}

DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// Dodaje [months] miesięcy; gdy dzień nie istnieje w docelowym miesiącu, zwraca null.
DateTime? _addMonthsExact(DateTime d, int months) {
  final total = d.month - 1 + months;
  final year = d.year + total ~/ 12;
  final month = total % 12 + 1;
  final candidate = DateTime(year, month, d.day, d.hour, d.minute);
  return candidate.month == month ? candidate : null;
}

/// Wystąpienia wydarzenia w przedziale [from, to) (daty lokalne). Nie zapisuje nic w bazie:
/// liczone w locie z `recurrence`. Pętla ma stały limit kroków (2000), więc zawsze się kończy.
List<EventOccurrence> occurrencesInRange(CalendarEvent event, DateTime from, DateTime to) {
  final result = <EventOccurrence>[];
  final limit = to;
  final duration = event.duration;
  final until = event.recurrence?.until;

  bool overlaps(DateTime s, DateTime e) => s.isBefore(limit) && e.isAfter(from);
  bool withinUntil(DateTime s) => until == null || !dateOnly(s).isAfter(dateOnly(until));

  if (event.recurrence == null) {
    if (overlaps(event.start, event.end)) {
      result.add(EventOccurrence(event: event, start: event.start, end: event.end));
    }
    return result;
  }

  for (var i = 0; i < 2000; i++) {
    final DateTime? s = switch (event.recurrence!.type) {
      RecurrenceType.weekly => event.start.add(Duration(days: 7 * i)),
      RecurrenceType.monthly => _addMonthsExact(event.start, i),
      RecurrenceType.yearly => _addMonthsExact(event.start, 12 * i),
    };
    if (s == null) continue;
    if (!withinUntil(s) || !s.isBefore(limit)) break;
    final e = s.add(duration);
    if (overlaps(s, e)) result.add(EventOccurrence(event: event, start: s, end: e));
  }
  return result;
}

/// Wystąpienia wszystkich wydarzeń w przedziale, posortowane po czasie startu
/// (całodzienne danego dnia przed godzinowymi).
List<EventOccurrence> occurrencesFor(List<CalendarEvent> events, DateTime from, DateTime to) {
  final all = [for (final e in events) ...occurrencesInRange(e, from, to)]
    ..sort((a, b) {
      final byDay = a.day.compareTo(b.day);
      if (byDay != 0) return byDay;
      if (a.event.allDay != b.event.allDay) return a.event.allDay ? -1 : 1;
      return a.start.compareTo(b.start);
    });
  return all;
}

/// Wystąpienia przypadające na dany dzień (wielodniowe liczą się każdego dnia trwania).
List<EventOccurrence> occurrencesOnDay(List<CalendarEvent> events, DateTime day) {
  final d = dateOnly(day);
  return occurrencesFor(events, d, d.add(const Duration(days: 1)));
}

/// Najbliższe wystąpienie od chwili [now] (trwające liczy się jako najbliższe).
EventOccurrence? nextOccurrence(List<CalendarEvent> events, DateTime now) {
  final list = occurrencesFor(events, now, now.add(const Duration(days: 366)))
      .where((o) => o.end.isAfter(now))
      .toList()
    ..sort((a, b) => a.start.compareTo(b.start));
  return list.isEmpty ? null : list.first;
}
