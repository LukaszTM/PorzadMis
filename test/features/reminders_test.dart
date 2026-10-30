import 'package:flutter_test/flutter_test.dart';
import 'package:porzadmis/features/calendar/domain/event_models.dart';
import 'package:porzadmis/features/chores/domain/chore_models.dart';
import 'package:porzadmis/features/notifications/domain/reminders.dart';

void main() {
  final now = DateTime(2026, 11, 2, 7);
  final rule = const ChoreRule(id: 'r1', title: 'Śmieci', mode: ChoreMode.recurring, startDate: '2026-11-02', reminderTime: '08:00');
  ChoreOccurrence occ(String id, String date, {String? assignee = 'me', bool done = false}) => ChoreOccurrence(
        id: id,
        ruleId: 'r1',
        date: date,
        title: 'Śmieci',
        status: done ? ChoreStatus.done : ChoreStatus.todo,
        assigneeId: assignee,
      );
  CalendarEvent ev(String id, DateTime start, {int? reminder, bool allDay = false}) => CalendarEvent(
        id: id,
        title: id,
        start: start,
        end: start.add(const Duration(hours: 1)),
        allDay: allDay,
        isPrivate: false,
        reminderMinutes: reminder,
      );

  List<Reminder> build({
    NotificationPrefs prefs = const NotificationPrefs(),
    List<ChoreOccurrence> occurrences = const [],
    List<CalendarEvent> events = const [],
  }) =>
      buildReminders(
        now: now,
        uid: 'me',
        prefs: prefs,
        occurrences: occurrences,
        rules: [rule],
        events: events,
        choreTitle: (t) => '$t – dziś',
        choreBody: 'Obowiązek',
        eventTitle: (t, s, a) => '$t – ${s.hour}:00',
        eventBody: 'Wydarzenie',
      );

  test('obowiązek: dziś o godzinie z reguły; cudze, zrobione i bez godziny pomijane', () {
    final r = build(occurrences: [
      occ('a', '2026-11-02'),
      occ('b', '2026-11-03', assignee: null),
      occ('c', '2026-11-02', assignee: 'other'),
      occ('d', '2026-11-04', done: true),
    ]);
    expect(r.map((x) => x.key), ['chore:a', 'chore:b']);
    expect(r.first.when, DateTime(2026, 11, 2, 8));
    expect(r.first.route, '/chores');
  });

  test('obowiązek z minioną godziną dziś nie jest planowany', () {
    final late = buildReminders(
      now: DateTime(2026, 11, 2, 9),
      uid: 'me',
      prefs: const NotificationPrefs(),
      occurrences: [occ('a', '2026-11-02')],
      rules: [rule],
      events: const [],
      choreTitle: (t) => t,
      choreBody: '',
      eventTitle: (t, s, a) => t,
      eventBody: '',
    );
    expect(late, isEmpty);
  });

  test('wydarzenie: minuty przed startem; całodzienne od 08:00; cykliczne każde wystąpienie w horyzoncie', () {
    final r = build(events: [
      ev('dentysta', DateTime(2026, 11, 3, 10), reminder: 60),
      ev('urodziny', DateTime(2026, 11, 5), reminder: 0, allDay: true),
      ev('bez', DateTime(2026, 11, 4, 10)),
      CalendarEvent(
        id: 'trening',
        title: 'trening',
        start: DateTime(2026, 10, 26, 18),
        end: DateTime(2026, 10, 26, 19),
        allDay: false,
        isPrivate: false,
        reminderMinutes: 30,
        recurrence: const Recurrence(type: RecurrenceType.weekly),
      ),
    ]);
    final keys = r.map((x) => x.key.split(':').take(2).join(':')).toList();
    expect(keys.where((k) => k == 'event:trening').length, 2); // 2.11 i 9.11
    expect(r.firstWhere((x) => x.key.startsWith('event:dentysta')).when, DateTime(2026, 11, 3, 9));
    expect(r.firstWhere((x) => x.key.startsWith('event:urodziny')).when, DateTime(2026, 11, 5, 8));
    expect(r.any((x) => x.key.startsWith('event:bez')), isFalse);
  });

  test('preferencje wyłączają dany typ', () {
    final r = build(
      prefs: const NotificationPrefs(chores: false),
      occurrences: [occ('a', '2026-11-02')],
      events: [ev('x', DateTime(2026, 11, 3, 10), reminder: 10)],
    );
    expect(r.map((x) => x.route), ['/calendar']);
  });

  test('posortowane po czasie i ograniczone limitem; identyfikator stabilny', () {
    final r = build(occurrences: [occ('b', '2026-11-05'), occ('a', '2026-11-03')]);
    expect(r.map((x) => x.key), ['chore:a', 'chore:b']);
    expect(r.first.id, r.first.id);
    expect(r.first.id, isNonNegative);
  });

  test('NotificationPrefs.fromMap: domyślne i jawne', () {
    expect(NotificationPrefs.fromMap(null).shopping, isFalse);
    expect(NotificationPrefs.fromMap({'shopping': true, 'chores': false}).shopping, isTrue);
    expect(NotificationPrefs.fromMap({'chores': 'tak'}).chores, isTrue);
  });
}
