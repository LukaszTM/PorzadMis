import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/firebase_providers.dart';
import '../../household/data/household_repository.dart';
import '../domain/chore_models.dart';

class ChoresRepository {
  ChoresRepository(this._db, this._newId);

  final FirebaseFirestore _db;
  final String Function() _newId;

  CollectionReference<Map<String, dynamic>> _rules(String hid) =>
      _db.collection('households/$hid/choreRules');

  CollectionReference<Map<String, dynamic>> _occ(String hid) =>
      _db.collection('households/$hid/choreOccurrences');

  String newId() => _newId();

  Stream<List<ChoreRule>> watchRules(String hid) => _rules(hid).snapshots().map(
        (s) => [for (final d in s.docs) _ruleFrom(d.id, d.data())],
      );

  /// Wystąpienia od [fromDay] (tekst `yyyy-MM-dd`) w przód; dziś i przyszłość plus kilka dni wstecz.
  Stream<List<ChoreOccurrence>> watchOccurrences(String hid, {required String fromDay}) => _occ(hid)
      .where('date', isGreaterThanOrEqualTo: fromDay)
      .snapshots()
      .map((s) => [for (final d in s.docs) _occFrom(d.id, d.data())]);

  Future<void> saveRule({required String hid, required String uid, required ChoreRule rule, bool isNew = false}) =>
      _rules(hid).doc(rule.id).set({
        'title': rule.title.trim(),
        'description': rule.description.trim(),
        'assigneeId': rule.assigneeId,
        'mode': rule.mode.name,
        'startDate': rule.startDate,
        'recurrence': rule.mode == ChoreMode.recurring ? rule.recurrence?.toMap() : null,
        'reminderTime': rule.reminderTime,
        'createdBy': rule.createdBy ?? uid,
        'updatedAt': FieldValue.serverTimestamp(),
      });

  Future<void> deleteRule(String hid, String id) => _rules(hid).doc(id).delete();

  Future<void> setStatus({
    required String hid,
    required String id,
    required String uid,
    required ChoreStatus status,
  }) =>
      _occ(hid).doc(id).update({
        'status': status.name,
        'doneBy': status == ChoreStatus.todo ? null : uid,
        'doneAt': status == ChoreStatus.todo ? null : FieldValue.serverTimestamp(),
      });

  ChoreRule _ruleFrom(String id, Map<String, dynamic> d) => ChoreRule(
        id: id,
        title: (d['title'] as String?) ?? '',
        description: (d['description'] as String?) ?? '',
        assigneeId: d['assigneeId'] as String?,
        mode: d['mode'] == 'recurring' ? ChoreMode.recurring : ChoreMode.once,
        startDate: (d['startDate'] as String?) ?? dayKey(DateTime.now()),
        recurrence: ChoreRecurrence.fromMap(d['recurrence']),
        reminderTime: d['reminderTime'] as String?,
        createdBy: d['createdBy'] as String?,
      );

  ChoreOccurrence _occFrom(String id, Map<String, dynamic> d) => ChoreOccurrence(
        id: id,
        ruleId: (d['ruleId'] as String?) ?? '',
        date: (d['date'] as String?) ?? '',
        title: (d['title'] as String?) ?? '',
        status: ChoreStatus.parse(d['status']),
        assigneeId: d['assigneeId'] as String?,
        doneBy: d['doneBy'] as String?,
        doneAt: (d['doneAt'] as Timestamp?)?.toDate(),
      );
}

final choresRepositoryProvider = Provider<ChoresRepository>(
  (ref) => ChoresRepository(ref.watch(firestoreProvider), ref.watch(uuidProvider).v4),
);

final choreRulesProvider = StreamProvider<List<ChoreRule>>((ref) {
  final hid = ref.watch(householdIdProvider);
  if (hid == null) return Stream.value(const []);
  return ref.watch(choresRepositoryProvider).watchRules(hid);
});

/// Wystąpienia od 7 dni wstecz (żeby zaległe były widoczne) do końca horyzontu.
final choreOccurrencesProvider = StreamProvider<List<ChoreOccurrence>>((ref) {
  final hid = ref.watch(householdIdProvider);
  if (hid == null) return Stream.value(const []);
  final from = dayKey(DateTime.now().subtract(const Duration(days: 7)));
  return ref.watch(choresRepositoryProvider).watchOccurrences(hid, fromDay: from);
});
