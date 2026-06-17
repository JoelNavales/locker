import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/locker_model.dart';
import 'auth_repository.dart';
import 'firebase_providers.dart';

class LockerRepository {
  LockerRepository(this._db);

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> _col(String uid) =>
      _db.collection('users').doc(uid).collection('lockers');

  Stream<List<LockerModel>> watch(String uid) {
    return _col(uid).orderBy('createdAt').snapshots().map(
          (snap) => snap.docs
              .map((d) => LockerModel.fromMap(d.id, d.data()))
              .toList(),
        );
  }

  Future<void> add(
    String uid, {
    required String subjectName,
    required Priority priority,
  }) {
    return _col(uid).add({
      'subjectName': subjectName.trim(),
      'priority': priority.name,
      'taskCount': 0,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> update(
    String uid,
    String lockerId, {
    required String subjectName,
    required Priority priority,
  }) {
    return _col(uid).doc(lockerId).update({
      'subjectName': subjectName.trim(),
      'priority': priority.name,
    });
  }

  Future<void> delete(String uid, String lockerId) =>
      _col(uid).doc(lockerId).delete();
}

final lockerRepositoryProvider = Provider<LockerRepository>((ref) {
  return LockerRepository(ref.watch(firestoreProvider));
});

/// Live list of the signed-in user's lockers.
final lockersProvider = StreamProvider<List<LockerModel>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value(const []);
  return ref.watch(lockerRepositoryProvider).watch(user.uid);
});
