import 'package:flutter/material.dart';
import '../models/locker_model.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';
import 'neu_card.dart';

class LockerTile extends StatelessWidget {
  const LockerTile({
    super.key,
    required this.locker,
    required this.onTap,
  });

  final LockerModel locker;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color fill = AppColors.forPriority(locker.priority);
    final Color fg = AppColors.onPriority(locker.priority);

    return GestureDetector(
      onTap: onTap,
      child: NeuCard(
        color: fill,
        radius: AppTheme.radiusTile,
        shadowOffset: const Offset(4, 4),
        padding: const EdgeInsets.all(AppTheme.spaceSm),
        child: SizedBox(
          height: 96,
          child: Stack(
            children: [
              // Latch on the right edge.
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 11,
                  height: 30,
                  decoration: BoxDecoration(
                    color: AppColors.ink,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _VentRibs(),
                  const SizedBox(height: AppTheme.spaceSm),
                  Text(
                    locker.subjectName.toUpperCase(),
                    style: AppTextStyles.title(fg),
                  ),
                  const Spacer(),
                  _TaskMeta(taskCount: locker.taskCount, color: fg),
                  const SizedBox(height: AppTheme.spaceXs),
                  _PriorityPill(priority: locker.priority),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VentRibs extends StatelessWidget {
  const _VentRibs();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(
        3,
        (_) => Container(
          width: 46,
          height: 3,
          margin: const EdgeInsets.symmetric(vertical: 1),
          color: AppColors.ink,
        ),
      ),
    );
  }
}

class _TaskMeta extends StatelessWidget {
  const _TaskMeta({required this.taskCount, required this.color});

  final int taskCount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final String text =
        taskCount == 0 ? '0 tasks' : '$taskCount tasks due';
    return Text(text, style: AppTextStyles.body(color));
  }
}

class _PriorityPill extends StatelessWidget {
  const _PriorityPill({required this.priority});

  final Priority priority;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        priority.label,
        style: AppTextStyles.caption(AppColors.onInk),
      ),
    );
  }
}
