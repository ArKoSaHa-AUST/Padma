import 'package:flutter/material.dart';
import '../../data/models/bus_model.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'status_chip.dart';

class NextStopCard extends StatelessWidget {
  final BusModel bus;
  final bool isBangla;
  final VoidCallback? onMessage;

  const NextStopCard({
    super.key,
    required this.bus,
    this.isBangla = false,
    this.onMessage,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface1 : AppColors.lightSurface1;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textMuted = isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted;

    final stopName = isBangla ? bus.nextStopNameBn : bus.nextStopName;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Bus icon, Name, Stop, Big ETA Box
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.darkPrimary.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.directions_bus_filled_rounded,
                  color: AppColors.darkPrimary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            isBangla ? bus.nameBn : bus.name,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        StatusChip(status: bus.status, isBangla: isBangla, isCompact: true),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(Icons.location_on_rounded, size: 14, color: AppColors.darkSecondary),
                        const SizedBox(width: 3),
                        Flexible(
                          child: Text(
                            'Next: $stopName',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.darkSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${bus.plateNumber} • ${bus.driverName}',
                      style: TextStyle(fontSize: 11, color: textMuted),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Big ETA display
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface2 : AppColors.lightSurface2,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.darkSecondary.withValues(alpha: 0.4),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      '${bus.etaMinutes}',
                      key: const Key('next_stop_eta_value'),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkSecondary,
                        height: 1.1,
                      ),
                    ),
                    Text(
                      isBangla ? 'মিনিট' : 'MIN ETA',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: textMuted,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Distance Progression Bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Corridor Progress',
                    style: TextStyle(fontSize: 11, color: textMuted, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    '${(bus.distanceProgress * 100).toInt()}%',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.darkSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: bus.distanceProgress.clamp(0.05, 1.0),
                  backgroundColor: isDark ? AppColors.darkSurface2 : AppColors.lightSurface2,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.darkSecondary),
                  minHeight: 6,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 10),

          // Action Button: Message
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onMessage,
              icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16),
              label: Text(
                isBangla ? 'মেসেজ' : 'Message',
                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.darkSecondary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
