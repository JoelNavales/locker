enum Priority { high, medium, low }

extension PriorityLabel on Priority {
  /// Short uppercase label shown on the priority pill.
  String get label => switch (this) {
    Priority.high => 'HIGH',
    Priority.medium => 'MED',
    Priority.low => 'LOW',
  };
}

/// A subject represented as a locker on the wall. Plain immutable data — no
/// Flutter imports.
class LockerModel {
  const LockerModel({
    required this.id,
    required this.subjectName,
    required this.priority,
    required this.taskCount,
  });

  final String id;
  final String subjectName;
  final Priority priority;
  final int taskCount;

  factory LockerModel.fromMap(String id, Map<String, dynamic> map) {
    return LockerModel(
      id: id,
      subjectName: (map['subjectName'] as String?) ?? '',
      priority: Priority.values.firstWhere(
        (p) => p.name == map['priority'],
        orElse: () => Priority.medium,
      ),
      taskCount: (map['taskCount'] as int?) ?? 0,
    );
  }

  LockerModel copyWith({
    String? id,
    String? subjectName,
    Priority? priority,
    int? taskCount,
  }) {
    return LockerModel(
      id: id ?? this.id,
      subjectName: subjectName ?? this.subjectName,
      priority: priority ?? this.priority,
      taskCount: taskCount ?? this.taskCount,
    );
  }
}
