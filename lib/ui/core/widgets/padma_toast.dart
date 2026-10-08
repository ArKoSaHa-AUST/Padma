import 'package:flutter/material.dart';
import '../theme.dart';

class PadmaToast {
  static void show(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded,
              color: isError ? PadmaTheme.urgentRed : PadmaTheme.primaryTeal,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: PadmaTheme.textPrimary),
              ),
            ),
          ],
        ),
        backgroundColor: PadmaTheme.surfaceElevated,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: PadmaTheme.borderLine),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
