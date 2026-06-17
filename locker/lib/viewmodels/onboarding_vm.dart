import 'package:flutter_riverpod/flutter_riverpod.dart';

class OnboardingPage {
  const OnboardingPage({
    required this.lockerNumber,
    required this.tagline,
  });

  final String lockerNumber;

  final String tagline;
}

class OnboardingState {
  const OnboardingState({
    required this.pages,
    required this.currentPage,
  });

  final List<OnboardingPage> pages;
  final int currentPage;

  bool get isLastPage => currentPage == pages.length - 1;

  OnboardingState copyWith({int? currentPage}) {
    return OnboardingState(
      pages: pages,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

class OnboardingViewModel extends Notifier<OnboardingState> {
  @override
  OnboardingState build() {
    return const OnboardingState(
      pages: [
        OnboardingPage(
          lockerNumber: '07',
          tagline: 'YOUR STUDY LIFE. LOCKED IN.',
        ),
        OnboardingPage(
          lockerNumber: '12',
          tagline: 'EVERY SUBJECT IS A LOCKER.',
        ),
        OnboardingPage(
          lockerNumber: '24',
          tagline: 'COLORS SCREAM YOUR PRIORITIES.',
        ),
      ],
      currentPage: 0,
    );
  }

  void setPage(int index) {
    if (index == state.currentPage) return;
    state = state.copyWith(currentPage: index);
  }
}

final onboardingViewModelProvider =
    NotifierProvider<OnboardingViewModel, OnboardingState>(
  OnboardingViewModel.new,
);
