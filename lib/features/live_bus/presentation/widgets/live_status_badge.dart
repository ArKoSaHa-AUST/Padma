import 'package:flutter/material.dart';
import '../../../../ui/core/theme.dart';
import '../../domain/models/sharing_status.dart';

/// Compact animated badge displaying current live sharing status and session timer.
class LiveStatusBadge extends StatefulWidget {
  final SharingStatus status;
  final String? remainingTime;
  final String? lastUpdatedText;
  final VoidCallback? onTap;

  const LiveStatusBadge({
    super.key,
    required this.status,
    this.remainingTime,
    this.lastUpdatedText,
    this.onTap,
  });

  @override
  State<LiveStatusBadge> createState() => _LiveStatusBadgeState();
}

class _LiveStatusBadgeState extends State<LiveStatusBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Color get _statusColor {
    switch (widget.status) {
      case SharingStatus.sharing:
        return PadmaTheme.successGreen;
      case SharingStatus.starting:
        return PadmaTheme.busAmber;
      case SharingStatus.stopped:
        return PadmaTheme.textMuted;
      case SharingStatus.expired:
        return PadmaTheme.urgentRed;
      case SharingStatus.idle:
        return PadmaTheme.borderLine;
      case SharingStatus.error:
        return PadmaTheme.urgentRed;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLive = widget.status == SharingStatus.sharing;
    final isStarting = widget.status == SharingStatus.starting;

    return InkWell(
      onTap: widget.onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: PadmaTheme.surface.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isLive
                ? PadmaTheme.successGreen.withValues(alpha: 0.5)
                : PadmaTheme.borderLine,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Status Dot
            if (isLive || isStarting)
              FadeTransition(
                opacity: _pulseController,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _statusColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: _statusColor.withValues(alpha: 0.6),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              )
            else
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _statusColor,
                  shape: BoxShape.circle,
                ),
              ),

            const SizedBox(width: 7),

            // Status Label
            Text(
              widget.status.label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isLive ? PadmaTheme.textPrimary : PadmaTheme.textSecondary,
                letterSpacing: 0.3,
              ),
            ),

            // Optional 2-hour countdown display
            if (isLive && widget.remainingTime != null) ...[
              const SizedBox(width: 8),
              Container(
                width: 1,
                height: 12,
                color: PadmaTheme.borderLine,
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.timer_outlined,
                size: 12,
                color: PadmaTheme.primaryTeal,
              ),
              const SizedBox(width: 4),
              Text(
                widget.remainingTime!,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: PadmaTheme.primaryTeal,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
