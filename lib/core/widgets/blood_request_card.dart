import 'package:flutter/material.dart';
import '../../data/models/blood_request_model.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../utils/formatters.dart';

class BloodRequestCard extends StatelessWidget {
  final BloodRequestModel request;
  final bool isCurrentUserDonor;
  final VoidCallback? onDonatePressed;
  final VoidCallback? onCallPressed;

  const BloodRequestCard({
    super.key,
    required this.request,
    this.isCurrentUserDonor = false,
    this.onDonatePressed,
    this.onCallPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface1 : AppColors.lightSurface1;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textMuted = isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted;

    final isFulfilled = request.status == BloodRequestStatus.fulfilled;
    final isCritical = request.urgency == BloodUrgency.critical;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: isFulfilled
            ? (isDark ? AppColors.darkSurface1.withValues(alpha: 0.6) : AppColors.lightSurface2)
            : surfaceColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        border: Border.all(
          color: isFulfilled
              ? AppColors.success.withValues(alpha: 0.4)
              : (isCritical ? AppColors.danger.withValues(alpha: 0.8) : borderColor),
          width: isCritical ? 1.5 : 1.0,
        ),
        boxShadow: isCritical
            ? [
                BoxShadow(
                  color: AppColors.danger.withValues(alpha: 0.15),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Blood badge, Urgency, Status, Time ago
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isFulfilled
                      ? AppColors.success.withValues(alpha: 0.18)
                      : AppColors.danger.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isFulfilled ? AppColors.success : AppColors.danger,
                    width: 1.5,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  request.bloodGroup,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: isFulfilled ? AppColors.success : AppColors.danger,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: isFulfilled
                                ? AppColors.success.withValues(alpha: 0.15)
                                : (isCritical
                                    ? AppColors.danger.withValues(alpha: 0.18)
                                    : AppColors.warning.withValues(alpha: 0.18)),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isFulfilled ? 'Fulfilled' : request.urgency.label,
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: isFulfilled
                                  ? AppColors.success
                                  : (isCritical ? AppColors.danger : AppColors.warning),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${request.units} ${request.units > 1 ? "Bags" : "Bag"} Needed',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textPrimary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Posted by ${request.requesterName}',
                      style: TextStyle(fontSize: 11.5, color: textMuted),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Text(
                AppFormatters.timeAgo(request.createdAt),
                style: TextStyle(fontSize: 10.5, color: textMuted),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Hospital & Location
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.local_hospital_rounded, size: 16, color: AppColors.danger),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  request.hospital,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.location_on_rounded, size: 15, color: textMuted),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  request.location,
                  style: TextStyle(fontSize: 12, color: textMuted),
                ),
              ),
            ],
          ),

          if (request.notes != null && request.notes!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (isDark ? Colors.black : Colors.white).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                request.notes!,
                style: TextStyle(fontSize: 12, color: textPrimary, fontStyle: FontStyle.italic),
              ),
            ),
          ],

          const SizedBox(height: 14),

          // Actions: I can donate / Call
          Row(
            children: [
              if (!isFulfilled) ...[
                Expanded(
                  flex: 3,
                  child: ElevatedButton.icon(
                    onPressed: isCurrentUserDonor ? null : onDonatePressed,
                    icon: Icon(
                      isCurrentUserDonor ? Icons.check_circle_rounded : Icons.volunteer_activism_rounded,
                      size: 16,
                    ),
                    label: Text(
                      isCurrentUserDonor ? 'Volunteered' : 'I Can Donate',
                      style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isCurrentUserDonor ? AppColors.success : AppColors.danger,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                flex: 2,
                child: OutlinedButton.icon(
                  onPressed: onCallPressed,
                  icon: const Icon(Icons.phone_outlined, size: 16),
                  label: const Text('Call', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: textPrimary,
                    side: BorderSide(color: borderColor),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
