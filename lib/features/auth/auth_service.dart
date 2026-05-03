import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  AuthService({FirebaseAuth? firebaseAuth})
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseAuth _firebaseAuth;

  Stream<User?> authStateChanges() {
    if (_usePollingAuthState) {
      return _pollAuthState();
    }

    return _firebaseAuth.authStateChanges();
  }

  User? get currentUser => _firebaseAuth.currentUser;

  Future<void> signIn({required String email, required String password}) async {
    await _firebaseAuth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> signUp({required String email, required String password}) async {
    await _firebaseAuth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> signOut() => _firebaseAuth.signOut();

  Future<void> reauthenticateWithPassword(String password) async {
    final user = _firebaseAuth.currentUser;
    final email = user?.email?.trim();

    if (user == null || email == null || email.isEmpty) {
      throw StateError('No email/password account is signed in.');
    }

    final credential = EmailAuthProvider.credential(
      email: email,
      password: password,
    );

    await user.reauthenticateWithCredential(credential);
  }

  Future<void> deleteCurrentUser() async {
    final user = _firebaseAuth.currentUser;

    if (user == null) {
      throw StateError('No account is signed in.');
    }

    await user.delete();
  }

  Stream<User?> _pollAuthState() async* {
    User? lastUser;
    var hasEmitted = false;

    while (true) {
      final user = _firebaseAuth.currentUser;

      if (!hasEmitted || user?.uid != lastUser?.uid) {
        yield user;
        lastUser = user;
        hasEmitted = true;
      }

      await Future<void>.delayed(const Duration(seconds: 1));
    }
  }

  bool get _usePollingAuthState {
    return !kIsWeb && defaultTargetPlatform == TargetPlatform.windows;
  }
}
