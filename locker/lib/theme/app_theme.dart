import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';
abstract final class AppTheme {
  const AppTheme._();

  // Spacing scale.
  static const double spaceXs = 6;
  static const double spaceSm = 10;
  static const double spaceMd = 16;
  static const double spaceLg = 24;
  static const double spaceXl = 34;

  // Corner radii.
  static const double radius = 8;
  static const double radiusTile = 6;

  // Border width.
  static const double borderWidth = 3;

  /// The standard 3px ink border.
  static Border get border =>
      Border.all(color: AppColors.ink, width: borderWidth);

  /// Signature hard shadow (no blur). Offset is configurable; defaults to 6,6.
  static List<BoxShadow> hardShadow({Offset offset = const Offset(6, 6)}) => [
        BoxShadow(
          color: AppColors.ink,
          offset: offset,
          blurRadius: 0,
          spreadRadius: 0,
        ),
      ];

  /// Smaller 4,4 variant of the hard shadow.
  static List<BoxShadow> get hardShadowSmall =>
      hardShadow(offset: const Offset(4, 4));

  /// Spacing between dots in the background dot-grid pattern.
  static const double dotGridSpacing = 26;
  static const double dotGridRadius = 1.2;

  /// Painter for the subtle cream dot-grid that sits behind screen content.
  static CustomPainter get dotGridPainter => const _DotGridPainter();

  /// Light theme applied app-wide.
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.cream,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.blue,
        primary: AppColors.blue,
        surface: AppColors.surface,
      ),
      textTheme: TextTheme(
        bodyMedium: AppTextStyles.body(AppColors.ink),
      ),
    );
  }
}

/// Draws the evenly-spaced ink dots that form the background grid.
class _DotGridPainter extends CustomPainter {
  const _DotGridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = AppColors.ink.withValues(alpha: 0.12);
    for (double y = 0; y < size.height; y += AppTheme.dotGridSpacing) {
      for (double x = 0; x < size.width; x += AppTheme.dotGridSpacing) {
        canvas.drawCircle(Offset(x, y), AppTheme.dotGridRadius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DotGridPainter oldDelegate) => false;
}
