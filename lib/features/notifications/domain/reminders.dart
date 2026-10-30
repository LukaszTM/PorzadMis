import '../../calendar/domain/event_models.dart';
import '../../chores/domain/chore_models.dart';

/// Jedno zaplanowane lokalne przypomnienie.
class Reminder {
  const Reminder({required this.key, required this.when, required this.title, required this.body, required this.route});

  final String key;
  final DateTime when;
  final String title;
  final String body;
  final String route;

  /// Stabilny identyfikator dla systemu (int) z klucza.
  int get id => key.hashCode & 0x7fffffff;
}

class NotificationPrefs {
  const NotificationPrefs({
    this.chores = true,
    this.events = true,
    this.shopping = false,
    this.members = true,
    this.budget = true,
  });

  final bool chores;
  final bool events;
  final bool shopping;
  final bool members;
  final bool budget;

  static NotificationPrefs fromMap(Object? v) {
    final m = v is Map ? v : const {};
    bool get(String k, bool def) => m[k] is bool ? m[k] as bool : def;
    return NotificationPrefs(
      chores: get('chores', true),
      events: get('events', true),
      shopping: get('shopping', false),
      members: get('members', true),
      budget: get('budget', true),
    );
  }

  Map<String, bool> toMap() => {'chores': chores, 'events': events, 'shopping': shopping, 'members': members, 'budget': budget};

  NotificationPrefs copyWith({bool? chores, bool? events, bool? shopping, bool? members, bool? budget}) =>
      NotificationPrefs(
        chores: chores ?? this.chores,
        events: events ?? this.events,
        shopping: shopping ?? this.shopping,
        members: members ?? this.members,
        budget: budget ?? this.budget,
      );
}

DateTime? _parseHm(String? hm) {
  if (hm == null) return null;
  final p = hm.split(':');
  if (p.length != 2) return null;
  final h = int.tryParse(p[0]);
  final m = int.tryParse(p[1]);
  if (h == null || m == null) return null;
  return DateTime(0, 1, 1, h, m);
}

/// Przypomnienia o moich obowiązkach (rano w dniu wykonania, o godzinie z reguły)
/// i o wydarzeniach (`reminderMinutes` przed startem) – tylko przyszłe, w zadanym horyzoncie.
List<Reminder> buildReminders({
  required DateTime now,
  required String uid,
  required NotificationPrefs prefs,
  required List<ChoreOccurrence> occurrences,
  required List<ChoreRule> rules,
  required List<CalendarEvent> events,
  required String Function(String title) choreTitle,
  required String choreBody,
  required String Function(String title, DateTime start, bool allDay) eventTitle,
  required String eventBody,
  int horizonDays = 14,
  int limit = 60,
}) {
  final result = <Reminder>[];
  final horizon = now.add(Duration(days: horizonDays));

  if (prefs.chores) {
    final rulesById = {for (final r in rules) r.id: r};
    for (final o in occurrences) {
      if (o.isDone) continue;
      if (o.assigneeId != null && o.assigneeId != uid) continue;
      final hm = _parseHm(rulesById[o.ruleId]?.reminderTime);
      if (hm == null) continue;
      final day = o.day;
      final when = DateTime(day.year, day.month, day.day, hm.hour, hm.minute);
      if (when.isBefore(now) || when.isAfter(horizon)) continue;
      result.add(Reminder(key: 'chore:${o.id}', when: when, title: choreTitle(o.title), body: choreBody, route: '/chores'));
    }
  }

  if (prefs.events) {
    for (final occ in occurrencesFor(events, now, horizon)) {
      final minutes = occ.event.reminderMinutes;
      if (minutes == null) continue;
      // Całodzienne: liczymy od 08:00 dnia wydarzenia, żeby nie budzić o północy.
      final base = occ.event.allDay ? DateTime(occ.start.year, occ.start.month, occ.start.day, 8) : occ.start;
      final when = base.subtract(Duration(minutes: minutes));
      if (when.isBefore(now) || when.isAfter(horizon)) continue;
      result.add(Reminder(
        key: 'event:${occ.event.id}:${occ.start.millisecondsSinceEpoch}',
        when: when,
        title: eventTitle(occ.event.title, occ.start, occ.event.allDay),
        body: eventBody,
        route: '/calendar',
      ));
    }
  }

  result.sort((a, b) => a.when.compareTo(b.when));
  return result.take(limit).toList();
}
