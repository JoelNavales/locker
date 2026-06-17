import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';
class NeuButton extends StatefulWidget {
  const NeuButton({
    super.key,
    required this.label,
    required this.onTap,
    this.color = AppColors.priorityMedium,
    this.foreground = AppColors.ink,
  });

  final String label;
  final VoidCallback onTap;
  final Color color;
  final Color foreground;

  @override
  State<NeuButton> createState() => _NeuButtonState();
}

class _NeuButtonState extends State<NeuButton> {
  bool _pressed = false;

  void _setPressed(bool value) => setState(() => _pressed = value);

  @override
  Widget build(BuildContext context) {
    final Offset shift = _pressed ? const Offset(4, 4) : Offset.zero;

    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        transform: Matrix4.translationValues(shift.dx, shift.dy, 0),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 15),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: widget.color,
            border: AppTheme.border,
            borderRadius: BorderRadius.circular(AppTheme.radius),
            boxShadow:
                _pressed ? const [] : AppTheme.hardShadowSmall,
          ),
          child: Text(
            widget.label,
            style: AppTextStyles.label(widget.foreground),
          ),
        ),
      ),
    );
  }
}
