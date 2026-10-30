import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/firebase_providers.dart';
import '../../auth/data/auth_repository.dart';
import '../../household/data/household_repository.dart';
import '../domain/event_models.dart';

/// Czas w bazie jest w UTC (Timestamp); w modelu trzymamy czas lokalny.
class EventsRepository {
  EventsRepository(this._db, this._newId);

  final FirebaseFirestore _db;
  final String Function() _newId;

  CollectionReference<Map<String, dynamic>> _shared(String hid) =>
      _db.collection('households/$hid/events');

  CollectionReference<Map<String, dynamic>> _private(String uid) =>
      _db.collection('users/$uid/privateEvents');

  Stream<List<CalendarEvent>> watchShared(String hid) => _shared(hid).snapshots().map(
        (s) => [for (final d in s.docs) _from(d.id, d.data(), isPrivate: false)],
      );

  Stream<List<CalendarEvent>> watchPrivate(String uid) => _private(uid).snapshots().map(
        (s) => [for (final d in s.docs) _from(d.id, d.data(), isPrivate: true)],
      );

  String newId() => _newId();

  Future<void> save({
    required String hid,
    required String uid,
    required CalendarEvent event,
    CalendarEvent? previous,
  }) {
    final batch = _db.batch();
    if (previous != null && previous.isPrivate != event.isPrivate) {
      batch.delete(_ref(hid, uid, previous));
    }
    batch.set(_ref(hid, uid, event), _toMap(event, createdBy: previous?.createdBy ?? event.createdBy ?? uid));
    return batch.commit();
  }

  Future<void> delete({required String hid, required String uid, required CalendarEvent event}) =>
      _ref(hid, uid, event).delete();

  Future<void> restore({required String hid, required String uid, required CalendarEvent event}) =>
      _ref(hid, uid, event).set(_toMap(event, createdBy: event.createdBy ?? uid));

  Map<String, dynamic> _toMap(CalendarEvent e, {required String createdBy}) => {
        'title': e.title.trim(),
        'start': Timestamp.fromDate(e.start.toUtc()),
        'end': Timestamp.fromDate(e.end.toUtc()),
        'allDay': e.allDay,
        'location': e.location.trim(),
        'description': e.description.trim(),
        'reminderMinutes': e.reminderMinutes,
        'recurrence': e.recurrence == null
            ? null
            : {
                'type': e.recurrence!.type.name,
                'until': e.recurrence!.until == null
                    ? null
                    : Timestamp.fromDate(e.recurrence!.until!.toUtc()),
              },
        if (!e.isPrivate) 'participants': e.participants,
        if (!e.isPrivate) 'createdBy': createdBy,
      };

  DocumentReference<Map<String, dynamic>> _ref(String hid, String uid, CalendarEvent e) =>
      e.isPrivate ? _private(uid).doc(e.id) : _shared(hid).doc(e.id);

  CalendarEvent _from(String id, Map<String, dynamic> d, {required bool isPrivate}) {
    final rec = d['recurrence'];
    Recurrence? recurrence;
    if (rec is Map) {
      final type = RecurrenceType.parse(rec['type']);
      if (type != null) {
        recurrence = Recurrence(type: type, until: (rec['until'] as Timestamp?)?.toDate().toLocal());
      }
    }
    return CalendarEvent(
      id: id,
      title: (d['title'] as String?) ?? '',
      start: ((d['start'] as Timestamp?)?.toDate() ?? DateTime.now()).toLocal(),
      end: ((d['end'] as Timestamp?)?.toDate() ?? DateTime.now()).toLocal(),
      allDay: d['allDay'] == true,
      isPrivate: isPrivate,
      location: (d['location'] as String?) ?? '',
      description: (d['description'] as String?) ?? '',
      participants: List<String>.from(d['participants'] as List? ?? const []),
      reminderMinutes: (d['reminderMinutes'] as num?)?.toInt(),
      recurrence: recurrence,
      createdBy: d['createdBy'] as String?,
    );
  }
}

final eventsRepositoryProvider = Provider<EventsRepository>(
  (ref) => EventsRepository(ref.watch(firestoreProvider), ref.watch(uuidProvider).v4),
);

final sharedEventsProvider = StreamProvider<List<CalendarEvent>>((ref) {
  final hid = ref.watch(householdIdProvider);
  if (hid == null) return Stream.value(const []);
  return ref.watch(eventsRepositoryProvider).watchShared(hid);
});

final privateEventsProvider = StreamProvider<List<CalendarEvent>>((ref) {
  final uid = ref.watch(authStateProvider).value?.uid;
  if (uid == null) return Stream.value(const []);
  return ref.watch(eventsRepositoryProvider).watchPrivate(uid);
});

final allEventsProvider = Provider<List<CalendarEvent>>((ref) => [
      ...?ref.watch(sharedEventsProvider).value,
      ...?ref.watch(privateEventsProvider).value,
    ]);
