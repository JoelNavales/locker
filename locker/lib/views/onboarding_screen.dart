import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';
import '../viewmodels/onboarding_vm.dart';
import '../widgets/neu_button.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _controller = PageController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPrimaryTap(OnboardingState state) {
    if (state.isLastPage) {
      Navigator.of(context).pushNamed('/login');
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final OnboardingState state = ref.watch(onboardingViewModelProvider);
    final OnboardingViewModel vm = ref.read(
      onboardingViewModelProvider.notifier,
    );

    return Scaffold(
      backgroundColor: AppColors.blue,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppTheme.spaceLg,
            AppTheme.spaceXl,
            AppTheme.spaceLg,
            AppTheme.spaceMd,
          ),
          child: Column(
            children: [
              Text('LOCKER', textAlign: TextAlign.center, style: _wordmark),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  onPageChanged: vm.setPage,
                  itemCount: state.pages.length,
                  itemBuilder: (context, index) =>
                      _OnboardingPageView(page: state.pages[index]),
                ),
              ),
              _Dots(count: state.pages.length, activeIndex: state.currentPage),
              const SizedBox(height: AppTheme.spaceMd),
              NeuButton(
                label: 'GET STARTED →',
                onTap: () => _onPrimaryTap(state),
              ),
              const SizedBox(height: AppTheme.spaceSm),
              TextButton(
                onPressed: () => Navigator.of(context).pushNamed('/login'),
                child: Text(
                  'I already have a key 🔑',
                  style: AppTextStyles.label(AppColors.onInk).copyWith(
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.onInk,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static final TextStyle _wordmark =
      AppTextStyles.display(AppColors.priorityMedium).copyWith(
        shadows: const [Shadow(color: AppColors.ink, offset: Offset(3, 3))],
      );
}

/// The per-page content: the locker hero graphic and the tagline bar.
class _OnboardingPageView extends StatelessWidget {
  const _OnboardingPageView({required this.page});

  final OnboardingPage page;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _LockerHero(number: page.lockerNumber),
        const SizedBox(height: AppTheme.spaceLg),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          color: AppColors.ink,
          child: Text(
            page.tagline,
            style: AppTextStyles.label(AppColors.onInk),
          ),
        ),
      ],
    );
  }
}

class _LockerHero extends StatelessWidget {
  const _LockerHero({required this.number});

  final String number;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 128,
      height: 170,
      decoration: BoxDecoration(
        color: AppColors.priorityHigh,
        border: AppTheme.border,
        borderRadius: BorderRadius.circular(4),
        boxShadow: AppTheme.hardShadow(),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Vent bars near the top.
          Positioned(
            top: 18,
            child: Column(
              children: List.generate(
                3,
                (_) => Container(
                  width: 60,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 3),
                  color: AppColors.ink,
                ),
              ),
            ),
          ),
          // Number.
          Text(
            number,
            style: AppTextStyles.heading(AppColors.onInk).copyWith(
              fontSize: 34,
              shadows: const [
                Shadow(color: AppColors.ink, offset: Offset(2, 2)),
              ],
            ),
          ),
          // Latch on the right.
          Positioned(
            right: 12,
            child: Container(
              width: 16,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.priorityMedium,
                border: AppTheme.border,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.activeIndex});

  final int count;
  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final bool active = index == activeIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: active ? 26 : 11,
          height: 11,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: active ? AppColors.priorityMedium : AppColors.surface,
            border: Border.all(color: AppColors.ink, width: 2),
            borderRadius: BorderRadius.circular(active ? 6 : 50),
          ),
        );
      }),
    );
  }
}
