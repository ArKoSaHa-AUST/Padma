import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:provider/provider.dart';
import '../../../../core/config/map_config.dart';
import '../../../../ui/core/theme.dart';
import '../../data/services/mock_device_location_service.dart';
import '../../domain/models/sharing_status.dart';
import '../controllers/live_bus_view_model.dart';
import '../widgets/demo_control_panel.dart';
import '../widgets/live_status_badge.dart';
import '../widgets/map_controls.dart';
import '../widgets/padma_live_map_widget.dart';

/// Dedicated Live Bus Map Screen for passengers and campus commuters.
///
/// Handles all states:
/// - Active Live Sharing (moving marker, route line, live speedometer, session timer)
/// - Starting / Beacon acquiring
/// - Location Unavailable / Waiting for signal
/// - Sharing Stopped (admin turned off)
/// - Sharing Expired (2-hour limit reached)
/// - Connection Error
class LiveBusMapScreen extends StatefulWidget {
  final VoidCallback? onOpenDrawer;
  final VoidCallback? onChangeBus;
  final String busName;
  final String busPlateNumber;

  const LiveBusMapScreen({
    super.key,
    this.onOpenDrawer,
    this.onChangeBus,
    this.busName = 'Bus 01 • Mirpur Route',
    this.busPlateNumber = 'Dhaka Metro Cha 11-4029',
  });

  @override
  State<LiveBusMapScreen> createState() => _LiveBusMapScreenState();
}

class _LiveBusMapScreenState extends State<LiveBusMapScreen> {
  final MapController _mapController = MapController();

  void _recenterOnBus(LiveBusViewModel vm) {
    final loc = vm.currentLocation;
    if (loc != null && loc.isValid) {
      _mapController.move(loc.latLng, MapConfig.busFocusZoom);
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Centered on ${widget.busName} GPS beacon.'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      _mapController.move(MapConfig.austCampusLocation, MapConfig.defaultZoom);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No active bus coordinate. Centered on AUST campus.'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _zoomIn() {
    final currentZoom = _mapController.camera.zoom;
    _mapController.move(_mapController.camera.center, (currentZoom + 1).clamp(MapConfig.minZoom, MapConfig.maxZoom));
  }

  void _zoomOut() {
    final currentZoom = _mapController.camera.zoom;
    _mapController.move(_mapController.camera.center, (currentZoom - 1).clamp(MapConfig.minZoom, MapConfig.maxZoom));
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LiveBusViewModel>();
    final isLive = vm.isLive;
    final loc = vm.currentLocation;

    return Scaffold(
      backgroundColor: PadmaTheme.background,
      body: Stack(
        children: [
          // 1. Base Map Layer with Isolated Tiles
          PadmaLiveMapWidget(
            liveLocation: loc,
            routePolyline: MockDeviceLocationService.demoWaypoints,
            mapController: _mapController,
            isLive: isLive,
          ),

          // 2. Top HUD: Speedometer & Live Status Bar
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 14,
            right: 14,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Live Status Badge with 2-hour countdown
                LiveStatusBadge(
                  status: vm.status,
                  remainingTime: vm.isLive ? vm.remainingSessionFormatted : null,
                  lastUpdatedText: vm.lastUpdatedFormatted,
                  onTap: () => DemoControlPanel.show(context, vm),
                ),

                // Speedometer Pill
                if (isLive && loc != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: PadmaTheme.surface.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: PadmaTheme.borderLine),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.speed_rounded,
                          size: 15,
                          color: PadmaTheme.busAmber,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${loc.speed.round()} KM/H',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: PadmaTheme.textPrimary,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // 3. Floating Map Controls (Recenter, Zoom, Demo Tools)
          Positioned(
            right: 14,
            bottom: 24,
            child: MapControls(
              hasActiveBus: loc != null,
              onRecenter: () => _recenterOnBus(vm),
              onZoomIn: _zoomIn,
              onZoomOut: _zoomOut,
              onToggleDemoPanel: () => DemoControlPanel.show(context, vm),
            ),
          ),

          // 4. Inactive / Stopped / Expired State Overlay Notification
          if (!isLive)
            Positioned(
              left: 14,
              right: 14,
              bottom: 24,
              child: _buildStateBanner(context, vm),
            ),
        ],
      ),
    );
  }

  Widget _buildStateBanner(BuildContext context, LiveBusViewModel vm) {
    String title;
    String description;
    IconData icon;
    Color color;

    switch (vm.status) {
      case SharingStatus.starting:
        title = 'Connecting to Bus GPS...';
        description = 'Acquiring satellite lock for ${widget.busName}.';
        icon = Icons.satellite_alt_rounded;
        color = PadmaTheme.busAmber;
        break;
      case SharingStatus.stopped:
        title = 'Location Sharing Ended';
        description = 'Driver has stopped live broadcasting for this route.';
        icon = Icons.location_off_rounded;
        color = PadmaTheme.textMuted;
        break;
      case SharingStatus.expired:
        title = 'Live Session Expired';
        description = 'The 2-hour maximum broadcast duration has ended.';
        icon = Icons.timer_off_outlined;
        color = PadmaTheme.urgentRed;
        break;
      case SharingStatus.error:
        title = 'Signal Interrupted';
        description = vm.errorMessage ?? 'Unable to stream bus telemetry.';
        icon = Icons.warning_amber_rounded;
        color = PadmaTheme.urgentRed;
        break;
      case SharingStatus.idle:
      default:
        title = 'Bus is Not Currently Live';
        description = 'Live location sharing is currently inactive.';
        icon = Icons.directions_bus_filled_rounded;
        color = PadmaTheme.primaryTeal;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: PadmaTheme.surface.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: PadmaTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 11,
                    color: PadmaTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: () => DemoControlPanel.show(context, vm),
            style: TextButton.styleFrom(
              foregroundColor: PadmaTheme.primaryTeal,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            ),
            child: const Text('Start Demo', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
