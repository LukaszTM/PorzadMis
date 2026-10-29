import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/firebase_providers.dart';
import '../../auth/data/auth_repository.dart';
import '../../household/data/household_repository.dart';
import '../../household/domain/household_models.dart';

class MembersRepository {
  MembersRepository(this._db, this._functions);

  final FirebaseFirestore _db;
  final FirebaseFunctions _functions;

  Stream<List<Member>> watchMembers(String hid) =>
      _db.collection('households/$hid/members').snapshots().map((snap) {
        final members = [for (final d in snap.docs) Member.fromMap(d.id, d.data())];
        members.sort((a, b) {
          if (a.isAdmin != b.isAdmin) return a.isAdmin ? -1 : 1;
          return a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase());
        });
        return members;
      });

  Future<void> setRole({required String hid, required String uid, required Role role}) =>
      _functions.httpsCallable('setMemberRole').call<Object?>({
        'householdId': hid,
        'targetUid': uid,
        'role': role.name,
      });

  Future<void> remove({required String hid, required String uid}) =>
      _functions.httpsCallable('removeMember').call<Object?>({
        'householdId': hid,
        'targetUid': uid,
      });
}

final membersRepositoryProvider = Provider<MembersRepository>(
  (ref) => MembersRepository(ref.watch(firestoreProvider), ref.watch(functionsProvider)),
);

final membersProvider = StreamProvider<List<Member>>((ref) {
  final hid = ref.watch(householdIdProvider);
  if (hid == null) return Stream.value(const []);
  return ref.watch(membersRepositoryProvider).watchMembers(hid);
});

/// Rola zalogowanej osoby w bieżącym domu.
final myRoleProvider = Provider<Role?>((ref) {
  final uid = ref.watch(authStateProvider).value?.uid;
  final members = ref.watch(membersProvider).value;
  if (uid == null || members == null) return null;
  for (final m in members) {
    if (m.uid == uid) return m.role;
  }
  return null;
});
