import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';
import '../viewmodels/home_vm.dart';
import '../widgets/locker_tile.dart';
import '../widgets/neu_bottom_nav.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const List<NeuNavItem> _navItems = [
    NeuNavItem(icon: Icons.lock, label: 'Lockers'),
    NeuNavItem(icon: Icons.calendar_today, label: 'Calendar'),
    NeuNavItem(icon: Icons.timer, label: 'Focus'),
    NeuNavItem(icon: Icons.people, label: 'Friends'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final HomeState state = ref.watch(homeViewModelProvider);
    final HomeViewModel vm = ref.read(homeViewModelProvider.notifier);

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(painter: AppTheme.dotGridPainter),
          ),
          SafeArea(
            child: Column(
              children: [
                const _Header(),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: AppTheme.spaceMd,
                    crossAxisSpacing: AppTheme.spaceMd,
                    childAspectRatio: 1,
                    padding: const EdgeInsets.fromLTRB(
                      AppTheme.spaceMd,
                      0,
                      AppTheme.spaceMd,
                      AppTheme.spaceMd,
                    ),
                    children: [
                      for (final locker in state.lockers)
                        LockerTile(locker: locker, onTap: () {}),
                      _AddLockerTile(onTap: vm.addLocker),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: NeuBottomNav(
        items: _navItems,
        currentIndex: state.selectedNavIndex,
        onTap: vm.selectNav,
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.spaceMd,
        AppTheme.spaceSm,
        AppTheme.spaceMd,
        AppTheme.spaceMd,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('MY LOCKERS', style: AppTextStyles.heading(AppColors.ink)),
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.violet,
              shape: BoxShape.circle,
              border: AppTheme.border,
              boxShadow: AppTheme.hardShadowSmall,
            ),
            child: Text('J', style: AppTextStyles.label(AppColors.onInk)),
          ),
        ],
      ),
    );
  }
}

/// The dashed "+ NEW LOCKER" tile at the end of the grid.
class _AddLockerTile extends StatelessWidget {
  const _AddLockerTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CustomPaint(
        painter: _DashedBorderPainter(),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('+',
                  style: AppTextStyles.display(AppColors.ink)
                      .copyWith(fontSize: 28, height: 1)),
              Text('NEW LOCKER', style: AppTextStyles.body(AppColors.ink)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Draws a dashed rounded-rect border for the add-locker tile.
class _DashedBorderPainter extends CustomPainter {
  static const double _dash = 6;
  static const double _gap = 4;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = AppColors.ink
      ..strokeWidth = AppTheme.borderWidth
      ..style = PaintingStyle.stroke;

    final RRect rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(AppTheme.radiusTile),
    );

    final Path source = Path()..addRRect(rrect);
    for (final metric in source.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        canvas.drawPath(
          metric.extractPath(distance, distance + _dash),
          paint,
        );
        distance += _dash + _gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) => false;
}
