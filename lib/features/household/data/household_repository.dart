import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/firebase_providers.dart';
import '../../auth/data/auth_repository.dart';
import '../domain/household_models.dart';

class HouseholdRepository {
  HouseholdRepository(this._db, this._functions, this._newId);

  final FirebaseFirestore _db;
  final FirebaseFunctions _functions;
  final String Function() _newId;

  Stream<UserProfile?> watchProfile(String uid) => _db
      .doc('users/$uid')
      .snapshots()
      .map((snap) => snap.exists ? UserProfile.fromMap(snap.data()) : null);

  Stream<Household?> watchHousehold(String hid) => _db.doc('households/$hid').snapshots().map(
        (snap) => snap.exists ? Household(id: hid, name: (snap.get('name') as String?) ?? '') : null,
      );

  Future<void> createHousehold({required String name, required String displayName}) async {
    await _functions.httpsCallable('createHousehold').call<Object?>({
      'householdId': _newId(),
      'name': name,
      'displayName': displayName,
    });
  }
}

final householdRepositoryProvider = Provider<HouseholdRepository>((ref) {
  final uuid = ref.watch(uuidProvider);
  return HouseholdRepository(
    ref.watch(firestoreProvider),
    ref.watch(functionsProvider),
    uuid.v4,
  );
});

/// Profil zalogowanej osoby; null, gdy nie ma sesji albo dokumentu profilu.
final profileProvider = StreamProvider<UserProfile?>((ref) async* {
  final user = await ref.watch(authStateProvider.future);
  if (user == null) {
    yield null;
    return;
  }
  yield* ref.watch(householdRepositoryProvider).watchProfile(user.uid);
});

final householdIdProvider = Provider<String?>(
  (ref) => ref.watch(profileProvider).value?.householdId,
);

final householdProvider = StreamProvider<Household?>((ref) {
  final hid = ref.watch(householdIdProvider);
  if (hid == null) return Stream.value(null);
  return ref.watch(householdRepositoryProvider).watchHousehold(hid);
});

/// Czytelny komunikat z błędu funkcji (serwer zwraca po polsku) albo null.
String? callableMessage(Object error) =>
    error is FirebaseFunctionsException ? error.message : null;
