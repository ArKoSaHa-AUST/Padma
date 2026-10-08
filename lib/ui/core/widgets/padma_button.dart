import 'package:flutter/material.dart';
import '../theme.dart';

class PadmaButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isSecondary;
  final double height;

  const PadmaButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isSecondary = false,
    this.height = 48,
  });

  @override
  Widget build(BuildContext context) {
    if (isSecondary) {
      return SizedBox(
        height: height,
        child: OutlinedButton.icon(
          onPressed: isLoading ? null : onPressed,
          icon: icon != null ? Icon(icon, size: 18) : const SizedBox.shrink(),
          label: Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          style: OutlinedButton.styleFrom(
            foregroundColor: PadmaTheme.textPrimary,
            side: const BorderSide(color: PadmaTheme.borderLine),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      );
    }

    return SizedBox(
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: PadmaTheme.primaryTeal,
          foregroundColor: PadmaTheme.onPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: PadmaTheme.onPrimary),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                  if (icon != null) ...[
                    const SizedBox(width: 8),
                    Icon(icon, size: 18),
                  ],
                ],
              ),
      ),
    );
  }
}
