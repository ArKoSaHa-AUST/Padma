import 'package:flutter/material.dart';
import '../../data/models/admin_update_model.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../utils/formatters.dart';

class AdminUpdateCard extends StatelessWidget {
  final AdminUpdateModel update;
  final VoidCallback? onTap;

  const AdminUpdateCard({
    super.key,
    required this.update,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface1 : AppColors.lightSurface1;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textMuted = isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted;

    return Container(
      width: 290,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: update.isUrgent ? AppColors.dangerSurface(isDark) : surfaceColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        border: Border.all(
          color: update.isUrgent
              ? AppColors.danger.withValues(alpha: 0.5)
              : (update.isPinned ? AppColors.adminBadge.withValues(alpha: 0.5) : borderColor),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                decoration: BoxDecoration(
                  color: AppColors.adminBadge.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.shield_rounded, size: 12, color: AppColors.adminBadge),
                    SizedBox(width: 4),
                    Text(
                      'Admin',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.adminBadge,
                      ),
                    ),
                  ],
                ),
              ),
              if (update.isPinned)
                const Icon(Icons.push_pin_rounded, size: 14, color: AppColors.adminBadge),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Text(
              update.text,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                height: 1.4,
                color: textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (update.busName != null)
                Text(
                  update.busName!,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkSecondary,
                  ),
                )
              else
                const SizedBox.shrink(),
              Text(
                AppFormatters.timeAgo(update.createdAt),
                style: TextStyle(fontSize: 10.5, color: textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
