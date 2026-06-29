import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';

class NeuNavItem {
  const NeuNavItem({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

class NeuBottomNav extends StatelessWidget {
  const NeuBottomNav({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  final List<NeuNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.cream,
        border: Border(
          top: BorderSide(color: AppColors.ink, width: AppTheme.borderWidth),
        ),
      ),
      child: Row(
        children: [
          for (int i = 0; i < items.length; i++)
            Expanded(
              child: _NavCell(
                item: items[i],
                active: i == currentIndex,
                showDivider: i != items.length - 1,
                onTap: () => onTap(i),
              ),
            ),
        ],
      ),
    );
  }
}

class _NavCell extends StatelessWidget {
  const _NavCell({
    required this.item,
    required this.active,
    required this.showDivider,
    required this.onTap,
  });

  final NeuNavItem item;
  final bool active;
  final bool showDivider;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color fg = active ? AppColors.priorityMedium : AppColors.ink;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: active ? AppColors.ink : Colors.transparent,
          border: showDivider
              ? const Border(right: BorderSide(color: AppColors.ink, width: 2))
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(item.icon, color: fg, size: 18),
            const SizedBox(height: 2),
            Text(item.label.toUpperCase(), style: AppTextStyles.caption(fg)),
          ],
        ),
      ),
    );
  }
}
