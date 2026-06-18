import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_prefs.dart';
import 'firebase_providers.dart';

/// Maps a [FirebaseAuthException] to a short, user-facing message.
String authErrorMessage(FirebaseAuthException e) {
  return switch (e.code) {
    'invalid-email' => 'That email address looks invalid.',
    'user-disabled' => 'This account has been disabled.',
    'user-not-found' ||
    'wrong-password' ||
    'invalid-credential' =>
      'Email or password is incorrect.',
    'email-already-in-use' => 'An account already exists for that email.',
    'weak-password' => 'Password is too weak — use at least 6 characters.',
    'network-request-failed' => 'Network error. Check your connection.',
    _ => e.message ?? 'Something went wrong. Please try again.',
  };
}

class AuthRepository {
  AuthRepository(this._auth, this._db, this._prefs);

  final FirebaseAuth _auth;
  final FirebaseFirestore _db;
  final AppPrefs _prefs;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<void> signIn({required String email, required String password}) async {
    await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    await _prefs.markHasAccount();
  }

  /// Creates the auth account and seeds the user's Firestore profile document
  /// (with no level/track yet — that's collected on the next screen).
  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    final UserCredential cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final User user = cred.user!;
    await user.updateDisplayName(name.trim());
    await _db.collection('users').doc(user.uid).set({
      'name': name.trim(),
      'email': email.trim(),
      'level': null,
      'track': null,
      'createdAt': FieldValue.serverTimestamp(),
    });
    await _prefs.markHasAccount();
  }

  /// Signs out. Records that this device has had an account so the next launch
  /// routes to login (not onboarding) and greets the user with "Welcome back".
  Future<void> signOut() async {
    await _prefs.markHasAccount();
    await _auth.signOut();
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    ref.watch(firebaseAuthProvider),
    ref.watch(firestoreProvider),
    ref.watch(appPrefsProvider),
  );
});

/// Emits the current signed-in user (or null) and drives top-level routing.
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
});
