import 'package:flutter/material.dart';
import '../theme.dart';

class PadmaBadge extends StatelessWidget {
  final String text;
  final Color? color;
  final Color? backgroundColor;
  final double fontSize;

  const PadmaBadge({
    super.key,
    required this.text,
    this.color,
    this.backgroundColor,
    this.fontSize = 10,
  });

  @override
  Widget build(BuildContext context) {
    final fgColor = color ?? PadmaTheme.primaryTeal;
    final bgColor = backgroundColor ?? fgColor.withValues(alpha: 0.15);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          color: fgColor,
        ),
      ),
    );
  }
}
