/// Whether the user is in Senior High (and picks a strand) or in College
/// (and types a course).
enum EducationLevel { shs, college }

extension EducationLevelLabel on EducationLevel {
  /// Human-readable label for the level toggle.
  String get label => switch (this) {
        EducationLevel.shs => 'Senior High',
        EducationLevel.college => 'College',
      };

  /// Label for the track the user belongs to under this level.
  String get trackLabel => switch (this) {
        EducationLevel.shs => 'Strand',
        EducationLevel.college => 'Course',
      };
}

class UserModel {
  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.level,
    this.track,
  });

  final String id;
  final String name;
  final String email;

  /// Null until the user completes the "where do you belong" step.
  final EducationLevel? level;

  /// The chosen strand (SHS) or course (College). Null until set.
  final String? track;

  /// Whether onboarding is complete — the user has a level and a track.
  bool get hasTrack => level != null && (track?.trim().isNotEmpty ?? false);

  factory UserModel.fromMap(String id, Map<String, dynamic> map) {
    return UserModel(
      id: id,
      name: (map['name'] as String?) ?? '',
      email: (map['email'] as String?) ?? '',
      level: switch (map['level']) {
        'shs' => EducationLevel.shs,
        'college' => EducationLevel.college,
        _ => null,
      },
      track: map['track'] as String?,
    );
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    EducationLevel? level,
    String? track,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      level: level ?? this.level,
      track: track ?? this.track,
    );
  }
}
