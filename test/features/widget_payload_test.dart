import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:porzadmis/features/calendar/domain/event_models.dart';
import 'package:porzadmis/features/chores/domain/chore_models.dart';
import 'package:porzadmis/features/shopping/domain/shopping_models.dart';
import 'package:porzadmis/features/widgets/domain/widget_payload.dart';

void main() {
  final now = DateTime(2026, 11, 2, 9);
  ChoreOccurrence occ(String id, {String? assignee = 'me', bool done = false, String date = '2026-11-02'}) =>
      ChoreOccurrence(id: id, ruleId: 'r', date: date, title: id, status: done ? ChoreStatus.done : ChoreStatus.todo, assigneeId: assignee);
  ShoppingItem item(String name, {bool checked = false, int minute = 0}) => ShoppingItem(
        id: name,
        name: name,
        category: StoreCategory.other,
        checked: checked,
        addedBy: 'me',
        createdAt: DateTime(2026, 11, 2, 8, minute),
      );
  CalendarEvent ev(String id, DateTime start, {bool private = false}) =>
      CalendarEvent(id: id, title: id, start: start, end: start.add(const Duration(hours: 1)), allDay: false, isPrivate: private);

  WidgetPayloads build({List<ChoreOccurrence> o = const [], List<CalendarEvent> e = const [], List<ShoppingItem> i = const []}) =>
      buildWidgetPayloads(
        now: now,
        uid: 'me',
        occurrences: o,
        events: e,
        items: i,
        nextEventLabel: (t, s, a) => '$t @${s.hour}',
        todayEmptyText: 'pusto',
        shoppingEmptyText: 'nic',
      );

  test('Dziś: moje obowiązki (max 5), licznik otwartych, bez cudzych i nie z dziś', () {
    final p = build(o: [
      for (var n = 0; n < 7; n++) occ('a$n'),
      occ('done', done: true),
      occ('other', assignee: 'x'),
      occ('tomorrow', date: '2026-11-03'),
    ]);
    final today = jsonDecode(p.today) as Map<String, dynamic>;
    expect((today['items'] as List).length, 5);
    expect(today['open'], 7);
    expect((today['items'] as List).any((i) => i['id'] == 'other'), isFalse);
    expect(today['emptyText'], 'pusto');
  });

  test('Dziś: najbliższe wydarzenie bez prywatnych; kalendarz dostaje tytuł', () {
    final p = build(e: [ev('priv', DateTime(2026, 11, 2, 10), private: true), ev('pub', DateTime(2026, 11, 2, 12))]);
    expect((jsonDecode(p.today) as Map)['nextEvent'], 'pub @12');
    expect((jsonDecode(p.calendar) as Map)['title'], 'pub');
  });

  test('Zakupy: liczba niekupionych i pierwsze 5 nazw od najstarszej', () {
    final p = build(i: [
      item('f', minute: 6),
      item('a', minute: 1),
      item('b', minute: 2),
      item('c', minute: 3),
      item('d', minute: 4),
      item('e', minute: 5),
      item('kupione', checked: true),
    ]);
    final s = jsonDecode(p.shopping) as Map<String, dynamic>;
    expect(s['count'], 6);
    expect(s['bought'], 1);
    expect(s['names'], ['a', 'b', 'c', 'd', 'e']);
    expect((s['emoji'] as List).length, 5);
  });

  test('emoji przy każdym wierszu: dopasowane albo domyślne (🧹 obowiązek, 🛒 zakup)', () {
    final p = build(o: [occ('Wynieść śmieci'), occ('Qwerty')], i: [item('Mleko 2%'), item('Xyz')]);
    final items = (jsonDecode(p.today) as Map)['items'] as List;
    // Obowiązki są posortowane po tytule: „Qwerty” przed „Wynieść śmieci”.
    expect(items[0]['emoji'], '🧹');
    expect(items[1]['emoji'], '🗑️');
    expect((jsonDecode(p.shopping) as Map)['emoji'], ['🥛', '🛒']);
  });

  test('routeFromWidgetUri mapuje hosty, obce schematy ignoruje', () {
    expect(routeFromWidgetUri(Uri.parse('porzadmis://chores')), '/chores');
    expect(routeFromWidgetUri(Uri.parse('porzadmis://shopping')), '/shopping');
    expect(routeFromWidgetUri(Uri.parse('porzadmis://shopping?add=1')), '/shopping?add=1');
    expect(routeFromWidgetUri(Uri.parse('porzadmis://chores?add=1')), '/chores?add=1');
    expect(routeFromWidgetUri(Uri.parse('porzadmis://cokolwiek')), '/home');
    expect(routeFromWidgetUri(Uri.parse('https://example.com')), isNull);
    expect(routeFromWidgetUri(null), isNull);
  });
}
