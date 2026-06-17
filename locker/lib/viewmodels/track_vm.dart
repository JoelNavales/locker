import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_model.dart';
import '../services/auth_repository.dart';
import '../services/user_repository.dart';

class TrackState {
  const TrackState({
    this.level = EducationLevel.shs,
    this.strand,
    this.course = '',
    this.isSubmitting = false,
    this.errorMessage,
  });

  final EducationLevel level;

  /// The selected SHS strand (used when [level] is shs).
  final String? strand;

  /// The typed college course (used when [level] is college).
  final String course;

  final bool isSubmitting;
  final String? errorMessage;

  /// The resolved track string for the current level.
  String? get track =>
      level == EducationLevel.shs ? strand : course.trim();

  bool get canSubmit =>
      !isSubmitting && (track?.trim().isNotEmpty ?? false);

  TrackState copyWith({
    EducationLevel? level,
    String? strand,
    String? course,
    bool? isSubmitting,
    String? errorMessage,
    bool clearError = false,
  }) {
    return TrackState(
      level: level ?? this.level,
      strand: strand ?? this.strand,
      course: course ?? this.course,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class TrackViewModel extends Notifier<TrackState> {
  /// The standard Senior High School strands.
  static const List<String> shsStrands = [
    'STEM',
    'ABM',
    'HUMSS',
    'GAS',
    'TVL',
    'Arts & Design',
    'Sports',
  ];

  @override
  TrackState build() => const TrackState();

  void setLevel(EducationLevel level) =>
      state = state.copyWith(level: level, clearError: true);

  void selectStrand(String strand) =>
      state = state.copyWith(strand: strand, clearError: true);

  void setCourse(String course) =>
      state = state.copyWith(course: course, clearError: true);

  /// Persists the chosen level + track to the user's profile.
  /// Returns true on success; routing then advances automatically.
  Future<bool> submit() async {
    final String? uid = ref.read(authRepositoryProvider).currentUser?.uid;
    if (uid == null || !state.canSubmit) return false;
    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      await ref
          .read(userRepositoryProvider)
          .setTrack(uid, state.level, state.track!);
      state = state.copyWith(isSubmitting: false);
      return true;
    } catch (_) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Could not save. Check your connection and try again.',
      );
      return false;
    }
  }
}

final trackViewModelProvider =
    NotifierProvider<TrackViewModel, TrackState>(TrackViewModel.new);
