import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_model.dart';
import 'auth_repository.dart';
import 'firebase_providers.dart';

class UserRepository {
  UserRepository(this._db);

  final FirebaseFirestore _db;

  DocumentReference<Map<String, dynamic>> _doc(String uid) =>
      _db.collection('users').doc(uid);

  Stream<UserModel?> watch(String uid) {
    return _doc(uid).snapshots().map((snap) {
      final Map<String, dynamic>? data = snap.data();
      if (data == null) return null;
      return UserModel.fromMap(snap.id, data);
    });
  }

  Future<void> setTrack(String uid, EducationLevel level, String track) {
    return _doc(uid).set({
      'level': level.name,
      'track': track.trim(),
    }, SetOptions(merge: true));
  }
}

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(ref.watch(firestoreProvider));
});

/// The signed-in user's profile document, or null when signed out / missing.
final userProfileProvider = StreamProvider<UserModel?>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value(null);
  return ref.watch(userRepositoryProvider).watch(user.uid);
});
