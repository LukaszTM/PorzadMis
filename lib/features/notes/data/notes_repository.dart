import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/firebase_providers.dart';
import '../../auth/data/auth_repository.dart';
import '../../household/data/household_repository.dart';
import '../domain/note_models.dart';

class NotesRepository {
  NotesRepository(this._db, this._newId);

  final FirebaseFirestore _db;
  final String Function() _newId;

  CollectionReference<Map<String, dynamic>> _shared(String hid) =>
      _db.collection('households/$hid/notes');

  CollectionReference<Map<String, dynamic>> _private(String uid) =>
      _db.collection('users/$uid/privateNotes');

  Stream<List<Note>> watchShared(String hid) => _shared(hid).snapshots().map(
        (s) => [for (final d in s.docs) _from(d.id, d.data(), isPrivate: false)],
      );

  Stream<List<Note>> watchPrivate(String uid) => _private(uid).snapshots().map(
        (s) => [for (final d in s.docs) _from(d.id, d.data(), isPrivate: true)],
      );

  String newId() => _newId();

  /// Zapis notatki. Gdy [previous] miała inną widoczność, przenosi dokument między kolekcjami
  /// (usunięcie + utworzenie pod tym samym identyfikatorem, jedna paczka).
  Future<void> save({
    required String hid,
    required String uid,
    required Note note,
    Note? previous,
  }) {
    final batch = _db.batch();
    if (previous != null && previous.isPrivate != note.isPrivate) {
      batch.delete(_ref(hid, uid, previous));
    }
    batch.set(_ref(hid, uid, note), {
      'title': note.title.trim(),
      'body': note.body,
      'pinned': note.pinned,
      'updatedAt': FieldValue.serverTimestamp(),
      if (!note.isPrivate) 'createdBy': previous?.createdBy ?? note.createdBy ?? uid,
    });
    return batch.commit();
  }

  Future<void> setPinned({
    required String hid,
    required String uid,
    required Note note,
    required bool pinned,
  }) =>
      _ref(hid, uid, note).update({'pinned': pinned, 'updatedAt': FieldValue.serverTimestamp()});

  Future<void> delete({required String hid, required String uid, required Note note}) =>
      _ref(hid, uid, note).delete();

  /// „Cofnij” po usunięciu: przywraca dokument z dawnym czasem zmiany.
  Future<void> restore({required String hid, required String uid, required Note note}) =>
      _ref(hid, uid, note).set({
        'title': note.title,
        'body': note.body,
        'pinned': note.pinned,
        'updatedAt': Timestamp.fromDate(note.updatedAt),
        if (!note.isPrivate) 'createdBy': note.createdBy ?? uid,
      });

  DocumentReference<Map<String, dynamic>> _ref(String hid, String uid, Note note) =>
      note.isPrivate ? _private(uid).doc(note.id) : _shared(hid).doc(note.id);

  Note _from(String id, Map<String, dynamic> d, {required bool isPrivate}) => Note(
        id: id,
        title: (d['title'] as String?) ?? '',
        body: (d['body'] as String?) ?? '',
        pinned: d['pinned'] == true,
        updatedAt: (d['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        isPrivate: isPrivate,
        createdBy: d['createdBy'] as String?,
      );
}

final notesRepositoryProvider = Provider<NotesRepository>(
  (ref) => NotesRepository(ref.watch(firestoreProvider), ref.watch(uuidProvider).v4),
);

final sharedNotesProvider = StreamProvider<List<Note>>((ref) {
  final hid = ref.watch(householdIdProvider);
  if (hid == null) return Stream.value(const []);
  return ref.watch(notesRepositoryProvider).watchShared(hid);
});

final privateNotesProvider = StreamProvider<List<Note>>((ref) {
  final uid = ref.watch(authStateProvider).value?.uid;
  if (uid == null) return Stream.value(const []);
  return ref.watch(notesRepositoryProvider).watchPrivate(uid);
});

/// Wspólne i prywatne razem; każda lista z osobnego strumienia, więc jedna może być pusta,
/// zanim druga dotrze.
final allNotesProvider = Provider<List<Note>>((ref) => [
      ...?ref.watch(sharedNotesProvider).value,
      ...?ref.watch(privateNotesProvider).value,
    ]);
