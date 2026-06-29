/// A single checklist step under a [TaskModel]. Subtasks live embedded as an
/// array on the parent task document, so they carry no id of their own.
class SubTask {
  const SubTask({required this.title, this.done = false});

  final String title;
  final bool done;

  factory SubTask.fromMap(Map<String, dynamic> map) {
    return SubTask(
      title: (map['title'] as String?) ?? '',
      done: (map['done'] as bool?) ?? false,
    );
  }

  Map<String, dynamic> toMap() => {'title': title, 'done': done};

  SubTask copyWith({String? title, bool? done}) {
    return SubTask(title: title ?? this.title, done: done ?? this.done);
  }
}

/// A task belonging to a single locker (subject). Plain immutable data — no
/// Flutter imports.
class TaskModel {
  const TaskModel({
    required this.id,
    required this.title,
    required this.done,
    required this.subtasks,
    this.deadline,
  });

  final String id;
  final String title;
  final bool done;
  final List<SubTask> subtasks;

  /// When the task is due. Null means no deadline set. Stored in Firestore as
  /// epoch milliseconds so the model stays free of Firestore types.
  final DateTime? deadline;

  /// Number of subtasks already completed.
  int get completedSubtasks => subtasks.where((s) => s.done).length;

  bool get hasSubtasks => subtasks.isNotEmpty;

  factory TaskModel.fromMap(String id, Map<String, dynamic> map) {
    final List<dynamic> raw = (map['subtasks'] as List<dynamic>?) ?? const [];
    final int? deadlineMs = (map['deadline'] as num?)?.toInt();
    return TaskModel(
      id: id,
      title: (map['title'] as String?) ?? '',
      done: (map['done'] as bool?) ?? false,
      subtasks: raw
          .map((e) => SubTask.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList(),
      deadline: deadlineMs == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(deadlineMs),
    );
  }

  TaskModel copyWith({
    String? id,
    String? title,
    bool? done,
    List<SubTask>? subtasks,
    DateTime? deadline,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      done: done ?? this.done,
      subtasks: subtasks ?? this.subtasks,
      deadline: deadline ?? this.deadline,
    );
  }
}
