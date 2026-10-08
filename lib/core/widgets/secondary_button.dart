import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class SecondaryButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double? width;
  final double height;
  final Color? borderColor;
  final Color? textColor;

  const SecondaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.width = double.infinity,
    this.height = 52.0,
    this.borderColor,
    this.textColor,
  });

  @override
  State<SecondaryButton> createState() => _SecondaryButtonState();
}

class _SecondaryButtonState extends State<SecondaryButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEnabled = widget.onPressed != null;
    final borderCol = widget.borderColor ?? (isDark ? AppColors.darkBorder : AppColors.lightBorder);
    final textCol = widget.textColor ?? (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary);

    return GestureDetector(
      onTapDown: isEnabled ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: isEnabled ? (_) => setState(() => _isPressed = false) : null,
      onTapCancel: isEnabled ? () => setState(() => _isPressed = false) : null,
      onTap: isEnabled ? widget.onPressed : null,
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: widget.width,
          height: widget.height,
          constraints: AppSpacing.touchTargetConstraints,
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface1.withValues(alpha: 0.6) : AppColors.lightSurface1,
            borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
            border: Border.all(color: borderCol),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, size: 20, color: textCol),
                const SizedBox(width: 8),
              ],
              Text(
                widget.text,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isEnabled ? textCol : textCol.withValues(alpha: 0.4),
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
