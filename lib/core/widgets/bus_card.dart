import 'package:flutter/material.dart';
import '../../data/models/bus_model.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../constants/asset_paths.dart';
import 'status_chip.dart';

class BusCard extends StatelessWidget {
  final BusModel bus;
  final VoidCallback? onTap;

  const BusCard({
    super.key,
    required this.bus,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface1 : AppColors.lightSurface1;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textMuted = isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            // Bus photo / thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                AssetPaths.austBus,
                width: 64,
                height: 64,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 64,
                  height: 64,
                  color: AppColors.darkPrimary.withValues(alpha: 0.2),
                  child: const Icon(Icons.directions_bus_filled_rounded, color: AppColors.darkPrimary, size: 30),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          bus.name,
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            color: textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      StatusChip(status: bus.status, isCompact: true),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    bus.routeName,
                    style: TextStyle(fontSize: 12, color: textMuted),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.person_outline_rounded, size: 13, color: AppColors.darkSecondary),
                      const SizedBox(width: 4),
                      Text(
                        bus.driverName,
                        style: const TextStyle(fontSize: 11.5, color: AppColors.darkSecondary, fontWeight: FontWeight.w600),
                      ),
                      const Spacer(),
                      Text(
                        'ETA ${bus.etaMinutes} min',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
