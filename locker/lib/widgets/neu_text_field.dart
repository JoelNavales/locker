import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';

class NeuTextField extends StatelessWidget {
  const NeuTextField({
    super.key,
    required this.label,
    required this.onChanged,
    this.controller,
    this.hint,
    this.keyboardType,
    this.obscure = false,
    this.onToggleObscure,
  });

  final String label;
  final ValueChanged<String> onChanged;
  final TextEditingController? controller;
  final String? hint;
  final TextInputType? keyboardType;

  final bool obscure;
  final VoidCallback? onToggleObscure;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: AppTextStyles.label(AppColors.ink)),
        const SizedBox(height: AppTheme.spaceXs),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: AppTheme.border,
            borderRadius: BorderRadius.circular(AppTheme.radius),
            boxShadow: AppTheme.hardShadowSmall,
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  onChanged: onChanged,
                  obscureText: obscure,
                  keyboardType: keyboardType,
                  style: AppTextStyles.body(AppColors.ink),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: AppTextStyles.body(
                      AppColors.ink.withValues(alpha: 0.4),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spaceMd,
                      vertical: 14,
                    ),
                  ),
                ),
              ),
              if (onToggleObscure != null)
                IconButton(
                  onPressed: onToggleObscure,
                  icon: Icon(
                    obscure ? Icons.visibility_off : Icons.visibility,
                    color: AppColors.ink,
                    size: 20,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
