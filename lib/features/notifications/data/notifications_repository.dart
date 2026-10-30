import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/firebase_providers.dart';
import '../../auth/data/auth_repository.dart';
import '../domain/reminders.dart';

class NotificationsRepository {
  NotificationsRepository(this._db);

  final FirebaseFirestore _db;

  Stream<NotificationPrefs> watchPrefs(String uid) =>
      _db.doc('users/$uid').snapshots().map((d) => NotificationPrefs.fromMap(d.data()?['notificationPrefs']));

  Future<void> savePrefs(String uid, NotificationPrefs prefs) =>
      _db.doc('users/$uid').set({'notificationPrefs': prefs.toMap()}, SetOptions(merge: true));

  Future<void> addToken(String uid, String token) =>
      _db.doc('users/$uid').set({'fcmTokens': FieldValue.arrayUnion([token])}, SetOptions(merge: true));

  Future<void> removeToken(String uid, String token) =>
      _db.doc('users/$uid').set({'fcmTokens': FieldValue.arrayRemove([token])}, SetOptions(merge: true));
}

final notificationsRepositoryProvider = Provider<NotificationsRepository>(
  (ref) => NotificationsRepository(ref.watch(firestoreProvider)),
);

final notificationPrefsProvider = StreamProvider<NotificationPrefs>((ref) {
  final uid = ref.watch(authStateProvider).value?.uid;
  if (uid == null) return Stream.value(const NotificationPrefs());
  return ref.watch(notificationsRepositoryProvider).watchPrefs(uid);
});
