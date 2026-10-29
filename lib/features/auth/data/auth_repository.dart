import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/firebase/firebase_providers.dart';

enum AuthFailureKind { wrongCredentials, emailInUse, network, cancelled, generic }

class AuthFailure implements Exception {
  const AuthFailure(this.kind);

  final AuthFailureKind kind;
}

class AuthRepository {
  AuthRepository(this._auth);

  final FirebaseAuth _auth;
  bool _googleReady = false;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  Future<void> signIn({required String email, required String password}) =>
      _guard(() => _auth.signInWithEmailAndPassword(email: email.trim(), password: password));

  Future<void> register({
    required String email,
    required String password,
    required String displayName,
  }) =>
      _guard(() async {
        final cred = await _auth.createUserWithEmailAndPassword(
          email: email.trim(),
          password: password,
        );
        await cred.user?.updateDisplayName(displayName.trim());
      });

  Future<void> signInWithGoogle() async {
    final google = GoogleSignIn.instance;
    try {
      if (!_googleReady) {
        await google.initialize();
        _googleReady = true;
      }
      final account = await google.authenticate();
      final idToken = account.authentication.idToken;
      await _guard(
        () => _auth.signInWithCredential(GoogleAuthProvider.credential(idToken: idToken)),
      );
    } on GoogleSignInException catch (e) {
      throw AuthFailure(
        e.code == GoogleSignInExceptionCode.canceled
            ? AuthFailureKind.cancelled
            : AuthFailureKind.generic,
      );
    }
  }

  Future<void> signOut() async {
    try {
      if (_googleReady) await GoogleSignIn.instance.signOut();
    } catch (_) {
      // Wylogowanie z Firebase ma się udać nawet bez Google.
    }
    await _auth.signOut();
  }

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(switch (e.code) {
        'invalid-credential' ||
        'wrong-password' ||
        'user-not-found' ||
        'invalid-email' =>
          AuthFailureKind.wrongCredentials,
        'email-already-in-use' => AuthFailureKind.emailInUse,
        'network-request-failed' => AuthFailureKind.network,
        _ => AuthFailureKind.generic,
      });
    }
  }
}

final authRepositoryProvider =
    Provider<AuthRepository>((ref) => AuthRepository(ref.watch(firebaseAuthProvider)));

final authStateProvider = StreamProvider<User?>(
  (ref) => ref.watch(authRepositoryProvider).authStateChanges(),
);
