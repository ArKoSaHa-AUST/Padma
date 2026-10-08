import 'package:flutter/material.dart';
import '../../../../ui/core/theme.dart';
import '../controllers/live_bus_view_model.dart';

/// Modal bottom sheet providing simulation tools to test Admin actions and edge cases:
/// - Start Sharing / Stop Sharing (Admin simulation)
/// - Speed (1x, 2x, 5x)
/// - Reset Route
/// - Simulate 2-Hour Expiry
/// - Telemetry details
class DemoControlPanel extends StatelessWidget {
  final LiveBusViewModel viewModel;

  const DemoControlPanel({
    super.key,
    required this.viewModel,
  });

  static void show(BuildContext context, LiveBusViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => DemoControlPanel(viewModel: viewModel),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLive = viewModel.isLive;
    final loc = viewModel.currentLocation;
    final session = viewModel.currentSession;

    return Container(
      decoration: BoxDecoration(
        color: PadmaTheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: PadmaTheme.borderLine),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: PadmaTheme.borderLine,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: PadmaTheme.primaryTealContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.developer_mode_rounded,
                  color: PadmaTheme.primaryTeal,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Live Tracking Simulation Panel',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: PadmaTheme.textPrimary,
                      ),
                    ),
                    Text(
                      'Test Admin start/stop, GPS ticks & session expiry',
                      style: TextStyle(
                        fontSize: 11,
                        color: PadmaTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const Divider(height: 24),

          // 1. Primary Admin Actions: Start / Stop Sharing
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: isLive
                      ? null
                      : () {
                          viewModel.startSharing();
                          Navigator.pop(context);
                        },
                  icon: const Icon(Icons.play_arrow_rounded, size: 18),
                  label: const Text('Start Sharing', style: TextStyle(fontWeight: FontWeight.w700)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: PadmaTheme.successGreen,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    disabledBackgroundColor: PadmaTheme.surfaceElevated,
                    disabledForegroundColor: PadmaTheme.textMuted,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: !isLive
                      ? null
                      : () {
                          viewModel.stopSharing();
                          Navigator.pop(context);
                        },
                  icon: const Icon(Icons.stop_rounded, size: 18),
                  label: const Text('Stop Sharing', style: TextStyle(fontWeight: FontWeight.w700)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: PadmaTheme.urgentRed,
                    side: const BorderSide(color: PadmaTheme.urgentRed),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    disabledForegroundColor: PadmaTheme.textMuted,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 2. Simulation Controls: Speed Multiplier
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: PadmaTheme.surfaceElevated,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: PadmaTheme.borderLine),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Simulation Speed Multiplier',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: PadmaTheme.textSecondary),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [1, 2, 5].map((multiplier) {
                    final isSelected = viewModel.speedMultiplier == multiplier;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: InkWell(
                          onTap: () => viewModel.setDemoSpeedMultiplier(multiplier),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? PadmaTheme.primaryTeal
                                  : PadmaTheme.surface,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected
                                    ? PadmaTheme.primaryTeal
                                    : PadmaTheme.borderLine,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                '${multiplier}x Speed',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                  color: isSelected
                                      ? PadmaTheme.onPrimary
                                      : PadmaTheme.textPrimary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // 3. Edge Case Triggers
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    viewModel.resetDemoRoute();
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.restart_alt_rounded, size: 16),
                  label: const Text('Reset Route', style: TextStyle(fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: PadmaTheme.textPrimary,
                    side: const BorderSide(color: PadmaTheme.borderLine),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    viewModel.simulateExpiry();
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.timer_off_outlined, size: 16),
                  label: const Text('Simulate Expiry (2h)', style: TextStyle(fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: PadmaTheme.urgentRed,
                    side: BorderSide(color: PadmaTheme.urgentRed.withValues(alpha: 0.5)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // 4. Live Telemetry Data Box
          if (loc != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: PadmaTheme.surfaceLowest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: PadmaTheme.borderLine),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'TELEMETRY DEBUG STREAM',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: PadmaTheme.primaryTeal),
                      ),
                      Text(
                        'Session: ${session?.sessionId.substring(0, 16) ?? "none"}...',
                        style: const TextStyle(fontSize: 9, color: PadmaTheme.textMuted),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Lat: ${loc.latitude.toStringAsFixed(6)}  •  Lng: ${loc.longitude.toStringAsFixed(6)}',
                    style: const TextStyle(fontSize: 11, color: PadmaTheme.textSecondary, fontFamily: 'monospace'),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Speed: ${loc.speed.toStringAsFixed(1)} km/h  •  Heading: ${loc.heading.toStringAsFixed(1)}°  •  Updated: ${viewModel.lastUpdatedFormatted}',
                    style: const TextStyle(fontSize: 11, color: PadmaTheme.textSecondary, fontFamily: 'monospace'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
