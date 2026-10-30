import 'dart:convert';

import '../../../core/util/emoji.dart';
import '../../calendar/domain/event_models.dart';
import '../../chores/domain/chore_models.dart';
import '../../shopping/domain/shopping_models.dart';

/// Dane dla widżetów ekranu głównego (GUI 5.13). Nigdy budżet ani wpisy prywatne.
class WidgetPayloads {
  const WidgetPayloads({required this.today, required this.shopping, required this.calendar});

  final String today;
  final String shopping;
  final String calendar;
}

WidgetPayloads buildWidgetPayloads({
  required DateTime now,
  required String uid,
  required List<ChoreOccurrence> occurrences,
  required List<CalendarEvent> events,
  required List<ShoppingItem> items,
  required String Function(String title, DateTime start, bool allDay) nextEventLabel,
  required String todayEmptyText,
  required String shoppingEmptyText,
  String todayLabel = '',
  String noEventText = '',
  String Function(DateTime start, bool allDay)? whenLabel,
}) {
  final mine = splitForDay(occurrences, dayKey(now), uid).mine;
  final next = nextOccurrence(events.where((e) => !e.isPrivate).toList(), now);
  final today = jsonEncode({
    'items': [
      for (final o in mine.take(5)) {'id': o.id, 'title': o.title, 'done': o.isDone, 'icon': miniIconFor(o.title)},
    ],
    'open': mine.where((o) => !o.isDone).length,
    'nextEvent': next == null ? '' : nextEventLabel(next.event.title, next.start, next.event.allDay),
    'emptyText': todayEmptyText,
  });

  final toBuy = items.where((i) => !i.checked).toList()..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  final shopping = jsonEncode({
    'count': toBuy.length,
    'bought': items.where((i) => i.checked).length,
    'names': [for (final i in toBuy.take(5)) i.name],
    'icons': [for (final i in toBuy.take(5)) miniIconFor(i.name)],
    'emptyText': shoppingEmptyText,
  });
  final calendar = jsonEncode({
    'today': todayLabel,
    'title': next?.event.title ?? noEventText,
    'when': next == null ? '' : (whenLabel?.call(next.start, next.event.allDay) ?? ''),
  });
  return WidgetPayloads(today: today, shopping: shopping, calendar: calendar);
}

/// Trasa z adresu dotkniętego widżetu (`porzadmis://chores` → `/chores`).
String? routeFromWidgetUri(Uri? uri) {
  if (uri == null || uri.scheme != 'porzadmis') return null;
  // „?add=1” z przycisku „+” na widżecie: ekran otwiera arkusz dodawania.
  final add = uri.queryParameters['add'] == '1' ? '?add=1' : '';
  return switch (uri.host) {
    'chores' => '/chores$add',
    'shopping' => '/shopping$add',
    'calendar' => '/calendar',
    _ => '/home',
  };
}
