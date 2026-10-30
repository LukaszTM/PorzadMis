import 'package:flutter_test/flutter_test.dart';
import 'package:porzadmis/features/calendar/domain/event_models.dart';

CalendarEvent ev({
  required DateTime start,
  Duration duration = const Duration(hours: 1),
  bool allDay = false,
  Recurrence? recurrence,
  String id = 'e',
}) =>
    CalendarEvent(
      id: id,
      title: id,
      start: start,
      end: start.add(duration),
      allDay: allDay,
      isPrivate: false,
      recurrence: recurrence,
    );

void main() {
  final monday = DateTime(2026, 11, 2, 10); // poniedziałek

  group('occurrencesInRange', () {
    test('jednorazowe: jedno wystąpienie w zakresie, zero poza', () {
      final e = ev(start: monday);
      expect(occurrencesInRange(e, DateTime(2026, 11, 1), DateTime(2026, 11, 8)), hasLength(1));
      expect(occurrencesInRange(e, DateTime(2026, 11, 3), DateTime(2026, 11, 8)), isEmpty);
    });

    test('co tydzień: ten sam dzień tygodnia, zachowany czas', () {
      final e = ev(start: monday, recurrence: const Recurrence(type: RecurrenceType.weekly));
      final list = occurrencesInRange(e, DateTime(2026, 11, 1), DateTime(2026, 12, 1));
      expect(list.map((o) => o.start.day), [2, 9, 16, 23, 30]);
      expect(list.every((o) => o.start.weekday == DateTime.monday && o.start.hour == 10), isTrue);
      expect(list.first.end, DateTime(2026, 11, 2, 11));
    });

    test('co tydzień z „until” kończy cykl (włącznie z dniem until)', () {
      final e = ev(
        start: monday,
        recurrence: Recurrence(type: RecurrenceType.weekly, until: DateTime(2026, 11, 16)),
      );
      final list = occurrencesInRange(e, DateTime(2026, 11, 1), DateTime(2027, 1, 1));
      expect(list.map((o) => o.start.day), [2, 9, 16]);
    });

    test('co miesiąc: ten sam dzień miesiąca; 31. pomija krótsze miesiące', () {
      final e = ev(start: DateTime(2026, 1, 31, 9), recurrence: const Recurrence(type: RecurrenceType.monthly));
      final list = occurrencesInRange(e, DateTime(2026, 1, 1), DateTime(2026, 6, 1));
      expect(list.map((o) => '${o.start.month}-${o.start.day}'), ['1-31', '3-31', '5-31']);
    });

    test('co rok: ta sama data; 29 lutego tylko w latach przestępnych', () {
      final e = ev(start: DateTime(2024, 2, 29, 12), recurrence: const Recurrence(type: RecurrenceType.yearly));
      final list = occurrencesInRange(e, DateTime(2024, 1, 1), DateTime(2029, 1, 1));
      expect(list.map((o) => o.start.year), [2024, 2028]);
    });

    test('wystąpienia sprzed zakresu nie są zwracane, ale cykl liczy się od początku', () {
      final e = ev(start: monday, recurrence: const Recurrence(type: RecurrenceType.weekly));
      final list = occurrencesInRange(e, DateTime(2026, 11, 20), DateTime(2026, 11, 27));
      expect(list.map((o) => o.start.day), [23]);
    });
  });

  group('occurrencesOnDay / nextOccurrence', () {
    test('całodzienne wielodniowe liczy się każdego dnia trwania', () {
      final e = ev(start: DateTime(2026, 11, 2), duration: const Duration(days: 3), allDay: true);
      expect(occurrencesOnDay([e], DateTime(2026, 11, 3)), hasLength(1));
      expect(occurrencesOnDay([e], DateTime(2026, 11, 5)), isEmpty);
    });

    test('sortowanie: całodzienne przed godzinowymi, potem po czasie', () {
      final list = occurrencesOnDay([
        ev(id: 'b', start: DateTime(2026, 11, 2, 15)),
        ev(id: 'c', start: DateTime(2026, 11, 2), duration: const Duration(days: 1), allDay: true),
        ev(id: 'a', start: DateTime(2026, 11, 2, 8)),
      ], DateTime(2026, 11, 2));
      expect(list.map((o) => o.event.id), ['c', 'a', 'b']);
    });

    test('nextOccurrence: trwające liczy się jako najbliższe, minione pomija', () {
      final past = ev(id: 'past', start: DateTime(2026, 11, 1, 8));
      final ongoing = ev(id: 'now', start: DateTime(2026, 11, 2, 9, 30), duration: const Duration(hours: 2));
      final later = ev(id: 'later', start: DateTime(2026, 11, 2, 14));
      final next = nextOccurrence([past, later, ongoing], DateTime(2026, 11, 2, 10));
      expect(next!.event.id, 'now');
    });

    test('nextOccurrence: cykliczne z przeszłości daje najbliższe przyszłe wystąpienie', () {
      final e = ev(start: DateTime(2026, 1, 5, 18), recurrence: const Recurrence(type: RecurrenceType.weekly));
      final next = nextOccurrence([e], DateTime(2026, 11, 2, 10));
      expect(next!.start, DateTime(2026, 11, 2, 18));
    });

    test('nextOccurrence: brak wydarzeń daje null', () {
      expect(nextOccurrence(const [], DateTime(2026, 11, 2)), isNull);
    });
  });
}
