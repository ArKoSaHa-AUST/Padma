import 'package:flutter/material.dart';
import '../../../../ui/core/theme.dart';

/// Floating map action controls for recentering, zooming, and triggering developer demo tools.
class MapControls extends StatelessWidget {
  final VoidCallback onRecenter;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onToggleDemoPanel;
  final bool hasActiveBus;

  const MapControls({
    super.key,
    required this.onRecenter,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onToggleDemoPanel,
    this.hasActiveBus = true,
  });

  Widget _buildButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
    Color? iconColor,
    bool highlight = false,
  }) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: highlight
            ? PadmaTheme.primaryTealContainer
            : PadmaTheme.surface.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: highlight
              ? PadmaTheme.primaryTeal
              : PadmaTheme.borderLine,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(
          icon,
          size: 19,
          color: iconColor ??
              (highlight ? PadmaTheme.primaryTeal : PadmaTheme.textPrimary),
        ),
        tooltip: tooltip,
        onPressed: onPressed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Demo Controls Drawer Toggle
        _buildButton(
          icon: Icons.tune_rounded,
          tooltip: 'Live Sharing Simulation Controls',
          highlight: true,
          onPressed: onToggleDemoPanel,
        ),

        const SizedBox(height: 8),

        // Zoom In
        _buildButton(
          icon: Icons.add_rounded,
          tooltip: 'Zoom In',
          onPressed: onZoomIn,
        ),

        const SizedBox(height: 6),

        // Zoom Out
        _buildButton(
          icon: Icons.remove_rounded,
          tooltip: 'Zoom Out',
          onPressed: onZoomOut,
        ),

        const SizedBox(height: 8),

        // Recenter on Bus
        _buildButton(
          icon: Icons.my_location_rounded,
          tooltip: 'Center on Bus',
          iconColor: hasActiveBus ? PadmaTheme.busAmber : PadmaTheme.textMuted,
          onPressed: onRecenter,
        ),
      ],
    );
  }
}
