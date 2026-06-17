import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

class NeuCard extends StatelessWidget {
  const NeuCard({
    super.key,
    required this.child,
    this.color = AppColors.surface,
    this.padding = const EdgeInsets.all(AppTheme.spaceMd),
    this.radius = AppTheme.radius,
    this.shadowOffset = const Offset(6, 6),
    this.border,
  });

  final Widget child;
  final Color color;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Offset shadowOffset;

  /// Override the default solid 3px border (e.g. for a dashed add-tile look).
  final BoxBorder? border;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        border: border ?? AppTheme.border,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: AppTheme.hardShadow(offset: shadowOffset),
      ),
      child: child,
    );
  }
}
