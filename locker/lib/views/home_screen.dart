import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/locker_model.dart';
import '../services/auth_repository.dart';
import '../services/locker_repository.dart';
import '../services/user_repository.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';
import '../viewmodels/home_vm.dart';
import '../widgets/locker_tile.dart';
import '../widgets/neu_bottom_nav.dart';
import 'calendar_screen.dart';
import 'locker_detail_screen.dart';
import 'locker_tasks_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const List<NeuNavItem> _navItems = [
    NeuNavItem(icon: Icons.lock, label: 'Lockers'),
    NeuNavItem(icon: Icons.calendar_today, label: 'Calendar'),
    NeuNavItem(icon: Icons.timer, label: 'Focus'),
    NeuNavItem(icon: Icons.people, label: 'Friends'),
  ];

  /// Tapping a locker opens its task list; the dashed add-tile (locker == null)
  /// jumps straight to creating a new locker.
  void _openLocker(BuildContext context, [LockerModel? locker]) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => locker == null
            ? const LockerDetailScreen()
            : LockerTasksScreen(locker: locker),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final HomeState state = ref.watch(homeViewModelProvider);
    final HomeViewModel vm = ref.read(homeViewModelProvider.notifier);
    final int index = state.selectedNavIndex;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: AppTheme.dotGridPainter)),
          SafeArea(
            child: Column(
              children: [
                _Header(
                  title: _navItems[index].label,
                  showTrack: index == 0,
                  showProfile: index == 0,
                ),
                Expanded(child: _bodyFor(context, ref, index)),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: NeuBottomNav(
        items: _navItems,
        currentIndex: index,
        onTap: vm.selectNav,
      ),
    );
  }

  /// Each bottom-nav tab routes to its own section. Only Lockers is built out;
  /// the rest show a placeholder so no tab is a dead button.
  Widget _bodyFor(BuildContext context, WidgetRef ref, int index) {
    return switch (index) {
      0 => _LockerGrid(onOpen: _openLocker),
      1 => const CalendarView(),
      2 => const _ComingSoon(icon: Icons.timer, label: 'Focus'),
      _ => const _ComingSoon(icon: Icons.people, label: 'Friends'),
    };
  }
}

class _LockerGrid extends ConsumerWidget {
  const _LockerGrid({required this.onOpen});

  final void Function(BuildContext context, [LockerModel? locker]) onOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lockers = ref.watch(lockersProvider);
    return lockers.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text(
          'Could not load your lockers.',
          style: AppTextStyles.body(AppColors.ink),
        ),
      ),
      data: (items) => GridView.count(
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
          for (final locker in items)
            LockerTile(locker: locker, onTap: () => onOpen(context, locker)),
          _AddLockerTile(onTap: () => onOpen(context)),
        ],
      ),
    );
  }
}

class _ComingSoon extends StatelessWidget {
  const _ComingSoon({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: AppColors.ink),
          const SizedBox(height: AppTheme.spaceMd),
          Text(
            label.toUpperCase(),
            style: AppTextStyles.heading(AppColors.ink),
          ),
          const SizedBox(height: AppTheme.spaceXs),
          Text('COMING SOON', style: AppTextStyles.body(AppColors.ink)),
        ],
      ),
    );
  }
}

class _Header extends ConsumerWidget {
  const _Header({
    required this.title,
    this.showTrack = true,
    this.showProfile = true,
  });

  final String title;

  /// Whether to show the user's track under the title. Hidden on tabs other
  /// than Lockers to keep them uncluttered.
  final bool showTrack;

  /// Whether to show the profile/sign-out avatar. Hidden on tabs other than
  /// Lockers.
  final bool showProfile;

  Future<void> _confirmSignOut(BuildContext context, WidgetRef ref) async {
    final bool? out = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Sign out?', style: AppTextStyles.heading(AppColors.ink)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('CANCEL', style: AppTextStyles.label(AppColors.ink)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'SIGN OUT',
              style: AppTextStyles.label(AppColors.priorityHigh),
            ),
          ),
        ],
      ),
    );
    if (out ?? false) {
      await ref.read(authRepositoryProvider).signOut();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider).value;
    final String name = profile?.name ?? '';
    final String initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    final String track = profile?.track ?? '';

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.spaceMd,
        AppTheme.spaceSm,
        AppTheme.spaceMd,
        AppTheme.spaceMd,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title.toUpperCase(),
                style: AppTextStyles.heading(AppColors.ink),
              ),
              if (showTrack && track.isNotEmpty)
                Text(
                  track.toUpperCase(),
                  style: AppTextStyles.body(AppColors.ink),
                ),
            ],
          ),
          if (showProfile)
            GestureDetector(
              onTap: () => _confirmSignOut(context, ref),
              child: Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.violet,
                  shape: BoxShape.circle,
                  border: AppTheme.border,
                  boxShadow: AppTheme.hardShadowSmall,
                ),
                child:
                    Text(initial, style: AppTextStyles.label(AppColors.onInk)),
              ),
            ),
        ],
      ),
    );
  }
}

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
              Text(
                '+',
                style: AppTextStyles.display(
                  AppColors.ink,
                ).copyWith(fontSize: 28, height: 1),
              ),
              Text('NEW LOCKER', style: AppTextStyles.body(AppColors.ink)),
            ],
          ),
        ),
      ),
    );
  }
}

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
        canvas.drawPath(metric.extractPath(distance, distance + _dash), paint);
        distance += _dash + _gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) => false;
}
