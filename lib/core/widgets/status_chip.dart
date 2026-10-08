import 'package:flutter/material.dart';
import '../../data/models/bus_model.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class StatusChip extends StatelessWidget {
  final BusStatus status;
  final bool isBangla;
  final bool isCompact;

  const StatusChip({
    super.key,
    required this.status,
    this.isBangla = false,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final (color, icon) = switch (status) {
      BusStatus.onTime => (AppColors.success, Icons.check_circle_rounded),
      BusStatus.waiting => (AppColors.warning, Icons.access_time_filled_rounded),
      BusStatus.delayed => (AppColors.warning, Icons.warning_rounded),
      BusStatus.breakdown => (AppColors.danger, Icons.error_rounded),
      BusStatus.tripEnded => (AppColors.darkTextMuted, Icons.flag_rounded),
    };

    final labelText = isBangla ? status.labelBn : status.label;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 8 : 10,
        vertical: isCompact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppSpacing.radiusChip),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: isCompact ? 12 : 14, color: color),
          SizedBox(width: isCompact ? 4 : 6),
          Text(
            labelText,
            style: TextStyle(
              fontSize: isCompact ? 11 : 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
