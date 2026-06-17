import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Holds transient home-screen UI state. Lockers themselves live in
/// [lockersProvider] (backed by Firestore).
class HomeState {
  const HomeState({this.selectedNavIndex = 0});

  final int selectedNavIndex;

  HomeState copyWith({int? selectedNavIndex}) {
    return HomeState(
      selectedNavIndex: selectedNavIndex ?? this.selectedNavIndex,
    );
  }
}

class HomeViewModel extends Notifier<HomeState> {
  @override
  HomeState build() => const HomeState();

  void selectNav(int index) {
    if (index == state.selectedNavIndex) return;
    state = state.copyWith(selectedNavIndex: index);
  }
}

final homeViewModelProvider =
    NotifierProvider<HomeViewModel, HomeState>(HomeViewModel.new);
