import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/firebase_providers.dart';
import '../../household/domain/household_models.dart';

class InvitesRepository {
  InvitesRepository(this._db, this._functions);

  final FirebaseFirestore _db;
  final FirebaseFunctions _functions;

  Future<Invite> create({required String hid, required bool multiUse}) async {
    final res = await _functions.httpsCallable('createInvite').call<Map<Object?, Object?>>({
      'householdId': hid,
      'multiUse': multiUse,
    });
    final data = res.data;
    return Invite(
      code: data['code']! as String,
      qrToken: data['qrToken']! as String,
      expiresAt: DateTime.fromMillisecondsSinceEpoch((data['expiresAt']! as num).toInt()),
      multiUse: multiUse,
      revoked: false,
      usedBy: const [],
    );
  }

  /// Na żywo: kto skorzystał z zaproszenia i czy zostało unieważnione.
  Stream<Invite?> watch({required String hid, required String code}) =>
      _db.doc('households/$hid/invites/$code').snapshots().map((snap) {
        if (!snap.exists) return null;
        final d = snap.data()!;
        return Invite(
          code: code,
          qrToken: d['qrToken'] as String,
          expiresAt: (d['expiresAt'] as Timestamp).toDate(),
          multiUse: d['multiUse'] == true,
          revoked: d['revoked'] == true,
          usedBy: List<String>.from(d['usedBy'] as List? ?? const []),
        );
      });

  Future<void> revoke({required String hid, required String code}) =>
      _functions.httpsCallable('revokeInvite').call<Object?>({
        'householdId': hid,
        'code': code,
      });

  /// Dołącza kodem tekstowym albo tokenem z QR (dokładnie jedno z nich).
  Future<void> redeem({String? code, String? qrToken, required String displayName}) =>
      _functions.httpsCallable('redeemInvite').call<Object?>({
        'code': ?code,
        'qrToken': ?qrToken,
        'displayName': displayName,
      });
}

final invitesRepositoryProvider = Provider<InvitesRepository>(
  (ref) => InvitesRepository(ref.watch(firestoreProvider), ref.watch(functionsProvider)),
);
