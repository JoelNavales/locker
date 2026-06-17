import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// A square neo-brutalist back button. Provide [onTap] (usually
/// `Navigator.of(context).pop()`) so navigation stays in-app rather than
/// relying on the device's system back gesture.
class NeuBackButton extends StatelessWidget {
  const NeuBackButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: AppTheme.border,
          borderRadius: BorderRadius.circular(AppTheme.radius),
          boxShadow: AppTheme.hardShadowSmall,
        ),
        child: const Icon(Icons.arrow_back, color: AppColors.ink),
      ),
    );
  }
}
