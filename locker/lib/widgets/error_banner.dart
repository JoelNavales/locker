import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';

/// A neo-brutalist banner for surfacing auth / form errors.
class ErrorBanner extends StatelessWidget {
  const ErrorBanner({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spaceMd,
        vertical: AppTheme.spaceSm,
      ),
      decoration: BoxDecoration(
        color: AppColors.priorityHigh,
        border: AppTheme.border,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        boxShadow: AppTheme.hardShadowSmall,
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: AppColors.onInk, size: 18),
          const SizedBox(width: AppTheme.spaceSm),
          Expanded(
            child: Text(message, style: AppTextStyles.body(AppColors.onInk)),
          ),
        ],
      ),
    );
  }
}
