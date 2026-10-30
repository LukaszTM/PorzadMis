import 'package:flutter_test/flutter_test.dart';
import 'package:porzadmis/features/chores/domain/chore_models.dart';

ChoreOccurrence occ(String id, {String date = '2026-11-02', String? assignee = 'u1', bool done = false}) =>
    ChoreOccurrence(
      id: id,
      ruleId: 'r',
      date: date,
      title: id,
      status: done ? ChoreStatus.done : ChoreStatus.todo,
      assigneeId: assignee,
    );

void main() {
  test('dayKey i parseDayKey są odwrotne, z zerami wiodącymi', () {
    expect(dayKey(DateTime(2026, 1, 5)), '2026-01-05');
    expect(parseDayKey('2026-01-05'), DateTime(2026, 1, 5));
  });

  test('splitForDay: moje = przypisane do mnie lub „ktoś”; do zrobienia przed zrobionymi', () {
    final s = splitForDay([
      occ('b', done: true),
      occ('a'),
      occ('c', assignee: null),
      occ('d', assignee: 'u2'),
      occ('e', date: '2026-11-03'),
    ], '2026-11-02', 'u1');
    expect(s.mine.map((o) => o.id), ['a', 'c', 'b']);
    expect(s.others.map((o) => o.id), ['d']);
  });

  test('canToggle: przypisany, każdy przy „ktoś”, Administrator', () {
    expect(occ('a').canToggle('u1', isAdmin: false), isTrue);
    expect(occ('a').canToggle('u2', isAdmin: false), isFalse);
    expect(occ('a').canToggle('u2', isAdmin: true), isTrue);
    expect(occ('a', assignee: null).canToggle('u9', isAdmin: false), isTrue);
  });

  test('openCountOn liczy tylko niezrobione danego dnia', () {
    expect(openCountOn([occ('a'), occ('b', done: true), occ('c', date: '2026-11-03')], '2026-11-02'), 1);
  });

  test('ChoreRecurrence.toMap zapisuje tylko pola właściwe dla typu', () {
    final weekly = const ChoreRecurrence(type: ChoreRecurrenceType.weekly, interval: 2, weekdays: [1, 5]).toMap();
    expect(weekly, {'type': 'weekly', 'interval': 2, 'weekdays': [1, 5], 'until': null});
    final custom = const ChoreRecurrence(type: ChoreRecurrenceType.customDates, dates: ['2026-11-05']).toMap();
    expect(custom.containsKey('weekdays'), isFalse);
    expect(custom['dates'], ['2026-11-05']);
    final parsed = ChoreRecurrence.fromMap(weekly)!;
    expect(parsed.type, ChoreRecurrenceType.weekly);
    expect(parsed.weekdays, [1, 5]);
  });
}
