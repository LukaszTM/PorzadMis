import 'dart:convert';

import '../../../core/util/emoji.dart';
import '../../calendar/domain/event_models.dart';
import '../../chores/domain/chore_models.dart';
import '../../shopping/domain/shopping_models.dart';

/// Dane dla widżetów ekranu głównego (GUI 5.13). Nigdy budżet ani wpisy prywatne.
class WidgetPayloads {
  const WidgetPayloads({required this.today, required this.shopping});

  final String today;
  final String shopping;
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
    'names': [for (final i in toBuy.take(5)) i.name],
    'icons': [for (final i in toBuy.take(5)) miniIconFor(i.name)],
    'emptyText': shoppingEmptyText,
  });
  return WidgetPayloads(today: today, shopping: shopping);
}

/// Trasa z adresu dotkniętego widżetu (`porzadmis://chores` → `/chores`).
String? routeFromWidgetUri(Uri? uri) {
  if (uri == null || uri.scheme != 'porzadmis') return null;
  return switch (uri.host) {
    'chores' => '/chores',
    'shopping' => '/shopping',
    'calendar' => '/calendar',
    _ => '/home',
  };
}
