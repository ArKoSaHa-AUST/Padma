import 'package:flutter/material.dart';
import '../../data/models/user_model.dart';
import '../theme/app_colors.dart';

class RoleBadge extends StatelessWidget {
  final UserRole role;

  const RoleBadge({
    super.key,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    final (bgColor, fgColor, icon) = switch (role) {
      UserRole.admin => (
          AppColors.adminBadge.withValues(alpha: 0.2),
          AppColors.adminBadge,
          Icons.verified_user_rounded,
        ),
      UserRole.driver => (
          AppColors.driverBadge.withValues(alpha: 0.2),
          AppColors.driverBadge,
          Icons.directions_bus_rounded,
        ),
      UserRole.student => (
          AppColors.studentBadge.withValues(alpha: 0.15),
          AppColors.studentBadge,
          Icons.school_rounded,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: fgColor.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: fgColor),
          const SizedBox(width: 3.5),
          Text(
            role.displayName,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: fgColor,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
