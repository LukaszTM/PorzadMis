enum ChoreMode { once, recurring }

enum ChoreRecurrenceType {
  daily,
  weekly,
  monthly,
  customDates;

  static ChoreRecurrenceType parse(Object? v) =>
      ChoreRecurrenceType.values.firstWhere((t) => t.name == v, orElse: () => ChoreRecurrenceType.daily);
}

enum ChoreStatus {
  todo,
  done,
  skipped;

  static ChoreStatus parse(Object? v) =>
      ChoreStatus.values.firstWhere((s) => s.name == v, orElse: () => ChoreStatus.todo);
}

/// Dzień kalendarzowy jako tekst `yyyy-MM-dd` (daty obowiązków nie mają strefy).
String dayKey(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

DateTime parseDayKey(String s) {
  final p = s.split('-').map(int.parse).toList();
  return DateTime(p[0], p[1], p[2]);
}

class ChoreRecurrence {
  const ChoreRecurrence({
    required this.type,
    this.interval = 1,
    this.weekdays = const [],
    this.monthDay,
    this.dates = const [],
    this.until,
  });

  final ChoreRecurrenceType type;
  final int interval;

  /// 1 = poniedziałek … 7 = niedziela.
  final List<int> weekdays;
  final int? monthDay;
  final List<String> dates;
  final String? until;

  Map<String, dynamic> toMap() => {
        'type': type.name,
        'interval': interval,
        if (type == ChoreRecurrenceType.weekly) 'weekdays': weekdays,
        if (type == ChoreRecurrenceType.monthly && monthDay != null) 'monthDay': monthDay,
        if (type == ChoreRecurrenceType.customDates) 'dates': dates,
        'until': until,
      };

  static ChoreRecurrence? fromMap(Object? v) {
    if (v is! Map) return null;
    return ChoreRecurrence(
      type: ChoreRecurrenceType.parse(v['type']),
      interval: (v['interval'] as num?)?.toInt() ?? 1,
      weekdays: List<int>.from((v['weekdays'] as List?)?.map((e) => (e as num).toInt()) ?? const []),
      monthDay: (v['monthDay'] as num?)?.toInt(),
      dates: List<String>.from(v['dates'] as List? ?? const []),
      until: v['until'] as String?,
    );
  }
}

class ChoreRule {
  const ChoreRule({
    required this.id,
    required this.title,
    required this.mode,
    required this.startDate,
    this.description = '',
    this.assigneeId,
    this.recurrence,
    this.reminderTime,
    this.createdBy,
  });

  final String id;
  final String title;
  final String description;

  /// null = „ktoś” (każdy może odhaczyć).
  final String? assigneeId;
  final ChoreMode mode;
  final String startDate;
  final ChoreRecurrence? recurrence;
  final String? reminderTime;
  final String? createdBy;
}

class ChoreOccurrence {
  const ChoreOccurrence({
    required this.id,
    required this.ruleId,
    required this.date,
    required this.title,
    required this.status,
    this.assigneeId,
    this.doneBy,
    this.doneAt,
  });

  final String id;
  final String ruleId;
  final String date;
  final String title;
  final ChoreStatus status;
  final String? assigneeId;
  final String? doneBy;
  final DateTime? doneAt;

  bool get isDone => status == ChoreStatus.done;
  DateTime get day => parseDayKey(date);

  /// Czy [uid] może odhaczyć: przypisany, każdy przy „ktoś”, albo Administrator.
  bool canToggle(String uid, {required bool isAdmin}) =>
      isAdmin || assigneeId == null || assigneeId == uid;
}

/// Podział wystąpień dnia na moje i cudze; w każdej grupie do zrobienia przed zrobionymi.
({List<ChoreOccurrence> mine, List<ChoreOccurrence> others}) splitForDay(
  List<ChoreOccurrence> all,
  String day,
  String uid,
) {
  int order(ChoreOccurrence o) => o.isDone ? 1 : 0;
  final today = all.where((o) => o.date == day).toList()
    ..sort((a, b) {
      final byDone = order(a).compareTo(order(b));
      return byDone != 0 ? byDone : a.title.toLowerCase().compareTo(b.title.toLowerCase());
    });
  return (
    mine: today.where((o) => o.assigneeId == uid || o.assigneeId == null).toList(),
    others: today.where((o) => o.assigneeId != uid && o.assigneeId != null).toList(),
  );
}

/// Liczba niezrobionych wystąpień w danym dniu (do kropek w kalendarzu i paska tygodnia).
int openCountOn(List<ChoreOccurrence> all, String day) =>
    all.where((o) => o.date == day && !o.isDone).length;
