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
        (snap) => snap.exists
            ? Household(
                id: hid,
                name: (snap.data()?['name'] as String?) ?? '',
                currency: (snap.data()?['currency'] as String?) ?? 'PLN',
                weekStartsOn: (snap.data()?['weekStartsOn'] as num?)?.toInt() == 7 ? 7 : 1,
              )
            : null,
      );

  Future<void> saveTheme({required String uid, required String themeId, required String themeMode}) =>
      _db.doc('users/$uid').set({'themeId': themeId, 'themeMode': themeMode}, SetOptions(merge: true));

  Future<void> setLargeText(String uid, bool value) =>
      _db.doc('users/$uid').set({'largeText': value}, SetOptions(merge: true));

  /// Ustawienia domu (Administrator): nazwa, waluta, początek tygodnia.
  Future<void> updateHousehold(String hid, {String? name, String? currency, int? weekStartsOn}) =>
      _db.doc('households/$hid').update({
        if (name != null) 'name': name.trim(),
        'currency': ?currency,
        'weekStartsOn': ?weekStartsOn,
      });

  Future<void> markOnboardingDone(String uid) =>
      _db.doc('users/$uid').set({'onboardingDone': true}, SetOptions(merge: true));

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

/// Waluta domu (do formatowania kwot) i pierwszy dzień tygodnia (1 = poniedziałek, 7 = niedziela).
final householdCurrencyProvider = Provider<String>((ref) => ref.watch(householdProvider).value?.currency ?? 'PLN');
final weekStartProvider = Provider<int>((ref) => ref.watch(householdProvider).value?.weekStartsOn ?? 1);
