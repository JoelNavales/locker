import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/locker_model.dart';
class HomeState {
  const HomeState({
    required this.lockers,
    required this.selectedNavIndex,
  });

  final List<LockerModel> lockers;
  final int selectedNavIndex;

  HomeState copyWith({
    List<LockerModel>? lockers,
    int? selectedNavIndex,
  }) {
    return HomeState(
      lockers: lockers ?? this.lockers,
      selectedNavIndex: selectedNavIndex ?? this.selectedNavIndex,
    );
  }
}

/// Holds the locker wall's sample data and bottom-nav selection.
class HomeViewModel extends Notifier<HomeState> {
  @override
  HomeState build() {
    return const HomeState(
      lockers: _sampleLockers,
      selectedNavIndex: 0,
    );
  }

  // Hardcoded sample data for the UI-only phase.
  // TODO: wire Firebase — load the user's lockers from Firestore.
  static const List<LockerModel> _sampleLockers = [
    LockerModel(
      id: '1',
      subjectName: 'Capstone',
      priority: Priority.high,
      taskCount: 4,
    ),
    LockerModel(
      id: '2',
      subjectName: 'Math 101',
      priority: Priority.medium,
      taskCount: 2,
    ),
    LockerModel(
      id: '3',
      subjectName: 'P.E.',
      priority: Priority.low,
      taskCount: 0,
    ),
    LockerModel(
      id: '4',
      subjectName: 'Electives',
      priority: Priority.medium,
      taskCount: 1,
    ),
  ];

  void selectNav(int index) {
    if (index == state.selectedNavIndex) return;
    state = state.copyWith(selectedNavIndex: index);
  }

  /// Create a new locker.
  void addLocker() {
    // TODO: wire Firebase — persist a new locker to Firestore.
  }
}

final homeViewModelProvider =
    NotifierProvider<HomeViewModel, HomeState>(HomeViewModel.new);
