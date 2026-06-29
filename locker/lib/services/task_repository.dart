import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/locker_model.dart';
import '../models/task_model.dart';
import 'auth_repository.dart';
import 'firebase_providers.dart';
import 'locker_repository.dart';

class TaskRepository {
  TaskRepository(this._db);

  final FirebaseFirestore _db;

  DocumentReference<Map<String, dynamic>> _lockerDoc(
    String uid,
    String lockerId,
  ) => _db.collection('users').doc(uid).collection('lockers').doc(lockerId);

  CollectionReference<Map<String, dynamic>> _col(String uid, String lockerId) =>
      _lockerDoc(uid, lockerId).collection('tasks');

  Stream<List<TaskModel>> watch(String uid, String lockerId) {
    return _col(uid, lockerId)
        .orderBy('createdAt')
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((d) => TaskModel.fromMap(d.id, d.data())).toList(),
        );
  }

  /// Adds a task and bumps the locker's open-task counter in one batch so the
  /// home-grid tile stays accurate.
  Future<void> add(String uid, String lockerId, {required String title}) {
    final batch = _db.batch();
    batch.set(_col(uid, lockerId).doc(), {
      'title': title.trim(),
      'done': false,
      'subtasks': <Map<String, dynamic>>[],
      'createdAt': FieldValue.serverTimestamp(),
    });
    batch.update(_lockerDoc(uid, lockerId), {
      'taskCount': FieldValue.increment(1),
    });
    return batch.commit();
  }

  Future<void> rename(
    String uid,
    String lockerId,
    String taskId, {
    required String title,
  }) {
    return _col(uid, lockerId).doc(taskId).update({'title': title.trim()});
  }

  /// Sets or clears a task's deadline. Stored as epoch milliseconds; pass null
  /// to remove the deadline.
  Future<void> setDeadline(
    String uid,
    String lockerId,
    String taskId,
    DateTime? deadline,
  ) {
    return _col(
      uid,
      lockerId,
    ).doc(taskId).update({'deadline': deadline?.millisecondsSinceEpoch});
  }

  /// Flips a task's done state. Open count tracks incomplete tasks, so toggling
  /// adjusts it by one in the opposite direction.
  Future<void> toggleDone(String uid, String lockerId, TaskModel task) {
    final bool nowDone = !task.done;
    final batch = _db.batch();
    batch.update(_col(uid, lockerId).doc(task.id), {'done': nowDone});
    batch.update(_lockerDoc(uid, lockerId), {
      'taskCount': FieldValue.increment(nowDone ? -1 : 1),
    });
    return batch.commit();
  }

  /// Deletes a task, decrementing the open count only if it was still open.
  Future<void> delete(String uid, String lockerId, TaskModel task) {
    final batch = _db.batch();
    batch.delete(_col(uid, lockerId).doc(task.id));
    if (!task.done) {
      batch.update(_lockerDoc(uid, lockerId), {
        'taskCount': FieldValue.increment(-1),
      });
    }
    return batch.commit();
  }

  Future<void> addSubtask(
    String uid,
    String lockerId,
    TaskModel task, {
    required String title,
  }) {
    final updated = [...task.subtasks, SubTask(title: title.trim())];
    return _writeSubtasks(uid, lockerId, task.id, updated);
  }

  Future<void> toggleSubtask(
    String uid,
    String lockerId,
    TaskModel task,
    int index,
  ) {
    final updated = [
      for (int i = 0; i < task.subtasks.length; i++)
        i == index
            ? task.subtasks[i].copyWith(done: !task.subtasks[i].done)
            : task.subtasks[i],
    ];
    return _writeSubtasks(uid, lockerId, task.id, updated);
  }

  Future<void> deleteSubtask(
    String uid,
    String lockerId,
    TaskModel task,
    int index,
  ) {
    final updated = [
      for (int i = 0; i < task.subtasks.length; i++)
        if (i != index) task.subtasks[i],
    ];
    return _writeSubtasks(uid, lockerId, task.id, updated);
  }

  Future<void> _writeSubtasks(
    String uid,
    String lockerId,
    String taskId,
    List<SubTask> subtasks,
  ) {
    return _col(
      uid,
      lockerId,
    ).doc(taskId).update({'subtasks': subtasks.map((s) => s.toMap()).toList()});
  }
}

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepository(ref.watch(firestoreProvider));
});

/// Live list of tasks for one locker.
final tasksProvider = StreamProvider.family<List<TaskModel>, String>((
  ref,
  lockerId,
) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value(const []);
  return ref.watch(taskRepositoryProvider).watch(user.uid, lockerId);
});

/// A task paired with the locker it belongs to, for cross-locker views like
/// the calendar.
class AgendaEntry {
  const AgendaEntry({required this.locker, required this.task});

  final LockerModel locker;
  final TaskModel task;

  /// Non-null: only tasks with a deadline become agenda entries.
  DateTime get deadline => task.deadline!;
}

/// Every task across all of the user's lockers that has a deadline set. Watches
/// each locker's task stream, so it updates live as tasks or deadlines change.
final agendaProvider = Provider<List<AgendaEntry>>((ref) {
  final lockers = ref.watch(lockersProvider).valueOrNull ?? const [];
  final entries = <AgendaEntry>[];
  for (final locker in lockers) {
    final tasks = ref.watch(tasksProvider(locker.id)).valueOrNull ?? const [];
    for (final task in tasks) {
      if (task.deadline != null) {
        entries.add(AgendaEntry(locker: locker, task: task));
      }
    }
  }
  return entries;
});
