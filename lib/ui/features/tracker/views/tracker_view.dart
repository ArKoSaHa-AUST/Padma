import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../../../core/config/map_config.dart';
import '../../../../features/live_bus/data/models/live_bus_location.dart';
import '../../../../features/live_bus/presentation/screens/live_bus_map_screen.dart';
import '../../../../features/live_bus/presentation/widgets/padma_live_map_widget.dart';
import '../../../core/theme.dart';
import '../../admin/view_models/admin_view_model.dart';
import '../../channels/views/bus_telemetry_chat_view.dart';
import '../view_models/tracker_view_model.dart';
import 'route_switcher_modal.dart';

class TrackerView extends StatefulWidget {
  final VoidCallback? onOpenGeneralChat;

  const TrackerView({super.key, this.onOpenGeneralChat});

  @override
  State<TrackerView> createState() => _TrackerViewState();
}

class _TrackerViewState extends State<TrackerView> {
  final MapController _mapController = MapController();

  void _recenterOnBus(double lat, double lng) {
    _mapController.move(LatLng(lat, lng), MapConfig.busFocusZoom);
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Map centered on active bus GPS beacon.'),
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final trackerVM = context.watch<TrackerViewModel>();
    final adminVM = context.watch<AdminViewModel>();

    final selectedRouteId = trackerVM.selectedRoute.id;
    final targetBusId = (selectedRouteId == 'bus-2' || selectedRouteId == 'bus_2') ? 'bus_2' : 'bus_1';

    final adminBus = adminVM.fleet.firstWhere(
      (b) => b.id == targetBusId,
      orElse: () => adminVM.fleet.first,
    );

    final isTripEnded = adminBus.isTripEnded;
    final isLive = !isTripEnded && adminBus.isBroadcastingGps;

    final displaySpeed = isTripEnded ? 0 : adminBus.currentSpeed;
    final displayEta = isTripEnded ? '--' : '${adminBus.etaMinutes}';

    final busLocation = LiveBusLocation(
      busId: adminBus.id,
      latitude: adminBus.latitude,
      longitude: adminBus.longitude,
      speed: displaySpeed.toDouble(),
      heading: 0,
      timestamp: DateTime.now(),
      sharingSessionId: 'session_${adminBus.id}',
      isSharing: isLive,
    );

    final routePolyline = adminBus.stoppages.map((s) => LatLng(s.lat, s.lng)).toList();

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Live Geographic Map Viewport
            Container(
              height: 340,
              width: double.infinity,
              color: PadmaTheme.surfaceLowest,
              child: Stack(
                children: [
                  PadmaLiveMapWidget(
                    liveLocation: busLocation,
                    routePolyline: routePolyline,
                    mapController: _mapController,
                    isLive: isLive,
                  ),

                  // Floating Top HUD Speedometer & Route Pill
                  Positioned(
                    top: 16,
                    left: 16,
                    right: 16,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Live Status Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                          decoration: BoxDecoration(
                            color: PadmaTheme.surface.withValues(alpha: 0.94),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: adminBus.status.color.withValues(alpha: 0.6)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.circle, size: 8, color: adminBus.status.color),
                              const SizedBox(width: 6),
                              Text(
                                adminBus.status.displayName.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: adminBus.status.color,
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Right side: Speed Pill & Route Switcher Pill
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!isTripEnded) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
                                decoration: BoxDecoration(
                                  color: PadmaTheme.surface.withValues(alpha: 0.92),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: PadmaTheme.borderLine),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.speed_rounded, size: 14, color: PadmaTheme.busAmber),
                                    const SizedBox(width: 4),
                                    Text(
                                      '$displaySpeed KM/H',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: PadmaTheme.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                            InkWell(
                              onTap: () {
                                showModalBottomSheet(
                                  context: context,
                                  backgroundColor: Colors.transparent,
                                  builder: (_) => const RouteSwitcherModal(),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                                decoration: BoxDecoration(
                                  color: PadmaTheme.surface.withValues(alpha: 0.92),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: PadmaTheme.primaryTeal.withValues(alpha: 0.6)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.alt_route_rounded, size: 15, color: PadmaTheme.primaryTeal),
                                    const SizedBox(width: 5),
                                    Text(
                                      adminBus.title,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: PadmaTheme.primaryTeal,
                                      ),
                                    ),
                                    const SizedBox(width: 3),
                                    const Icon(Icons.keyboard_arrow_down_rounded, size: 15, color: PadmaTheme.primaryTeal),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Floating Controls: Fullscreen & Recenter
                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FloatingActionButton.small(
                          heroTag: 'client_fullscreen_map_fab',
                          backgroundColor: PadmaTheme.surface,
                          foregroundColor: PadmaTheme.textPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: const BorderSide(color: PadmaTheme.borderLine),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => LiveBusMapScreen(
                                  busName: adminBus.title,
                                  busPlateNumber: adminBus.busNumber,
                                ),
                              ),
                            );
                          },
                          child: const Icon(Icons.fullscreen_rounded, size: 20),
                        ),
                        const SizedBox(width: 8),
                        FloatingActionButton.small(
                          heroTag: 'client_recenter_fab',
                          backgroundColor: PadmaTheme.surface,
                          foregroundColor: PadmaTheme.busAmber,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: const BorderSide(color: PadmaTheme.borderLine),
                          ),
                          onPressed: () => _recenterOnBus(adminBus.latitude, adminBus.longitude),
                          child: const Icon(Icons.my_location_rounded, size: 20),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 2. TRIP ENDED BANNER (WHEN TRIP IS ENDED)
            if (isTripEnded)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: PadmaTheme.surfaceElevated,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: PadmaTheme.borderLine),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF64748B).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.nightlight_round, color: Color(0xFF94A3B8), size: 24),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Trip Ended • Service Offline',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: PadmaTheme.textPrimary),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'This bus is currently at the depot. Service will resume when transport admin dispatches the next trip.',
                              style: TextStyle(fontSize: 11, color: PadmaTheme.textMuted, height: 1.3),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // 2.1 ACTIVE STOPPAGE WAIT ALERT BANNER (IF DISPATCHED BY ADMIN)
            if (adminBus.activeWaitNotice != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: PadmaTheme.busAmber.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: PadmaTheme.busAmber.withValues(alpha: 0.6), width: 1.2),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: PadmaTheme.busAmber.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.hourglass_top_rounded, color: PadmaTheme.busAmber, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'SCHEDULED STOPPAGE WAIT',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: PadmaTheme.busAmber, letterSpacing: 0.4),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: PadmaTheme.busAmberContainer,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'Until ${adminBus.activeWaitNotice!.untilTime}',
                                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: PadmaTheme.busAmber),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              adminBus.activeWaitNotice!.message,
                              style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: PadmaTheme.textPrimary, height: 1.3),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '📍 Extra 5-6 min wait at ${adminBus.activeWaitNotice!.stoppageName} broadcasted by Transport Admin',
                              style: const TextStyle(fontSize: 10.5, color: PadmaTheme.textMuted),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // 3. Live Bus Info Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: PadmaTheme.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: PadmaTheme.borderLine),
                ),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: isTripEnded ? PadmaTheme.surfaceElevated : PadmaTheme.busAmberContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.directions_bus_filled_rounded,
                            color: isTripEnded ? PadmaTheme.textMuted : PadmaTheme.busAmber,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                adminBus.title,
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: PadmaTheme.textPrimary),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                isTripEnded ? 'Status: Trip Ended / Offline' : 'At ${adminBus.currentStop}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isTripEnded ? PadmaTheme.textMuted : PadmaTheme.primaryTeal,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                isTripEnded
                                    ? 'Plate: ${adminBus.busNumber}'
                                    : 'Heading towards: ${adminBus.nextStop}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isTripEnded ? PadmaTheme.textMuted : PadmaTheme.busAmber,
                                  fontWeight: isTripEnded ? FontWeight.normal : FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: PadmaTheme.surfaceElevated,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isTripEnded ? PadmaTheme.borderLine : PadmaTheme.primaryTeal.withValues(alpha: 0.4),
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                displayEta,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: isTripEnded ? PadmaTheme.textMuted : PadmaTheme.primaryTeal,
                                ),
                              ),
                              const Text('MIN ETA', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: PadmaTheme.textMuted)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),

                    // Quick Action: Message Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          final channelId = (adminBus.id == 'bus_1' || adminBus.id == 'bus-1') ? 'bus-1-mirpur' : 'bus-2-uttara';
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BusTelemetryChatView(
                                onOpenDrawer: () => Navigator.pop(context),
                                channelId: channelId,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16),
                        label: Text(
                          'Open #${(adminBus.id == 'bus_1' || adminBus.id == 'bus-1') ? 'bus-1-mirpur' : 'bus-2-uttara'} Messages',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: PadmaTheme.primaryTeal,
                          foregroundColor: PadmaTheme.onPrimary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 4. Route Checkpoints Timeline
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: PadmaTheme.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: PadmaTheme.borderLine),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.timeline_rounded, color: PadmaTheme.primaryTeal, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'Route Progression & Stops',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: PadmaTheme.textPrimary),
                            ),
                          ],
                        ),
                        if (!isTripEnded)
                          Text(
                            '${adminBus.currentStopIndex + 1} / ${adminBus.stoppages.length}',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: PadmaTheme.textMuted),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Stoppages checkpoints list
                    ...adminBus.stoppages.map((stop) {
                      final stopIdx = adminBus.stoppages.indexOf(stop);
                      final isPassed = !isTripEnded && stopIdx < adminBus.currentStopIndex;
                      final isCurrent = !isTripEnded && stopIdx == adminBus.currentStopIndex;
                      final isLast = stopIdx == adminBus.stoppages.length - 1;
                      final isWaitActiveOnThisStop = adminBus.activeWaitNotice != null &&
                          (adminBus.activeWaitNotice!.stoppageName.toLowerCase().trim() == stop.name.toLowerCase().trim() ||
                              (adminBus.activeWaitNotice!.stoppageName.toLowerCase().contains('mirpur 10') &&
                                  stop.name.toLowerCase().contains('mirpur 10')) ||
                              (adminBus.activeWaitNotice!.stoppageName.toLowerCase().contains('dss') &&
                                  stop.name.toLowerCase().contains('dss')));

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            children: [
                              Container(
                                width: isWaitActiveOnThisStop ? 20 : 16,
                                height: isWaitActiveOnThisStop ? 20 : 16,
                                decoration: BoxDecoration(
                                  color: isWaitActiveOnThisStop
                                      ? PadmaTheme.busAmber
                                      : (isPassed
                                          ? PadmaTheme.successGreen
                                          : (isCurrent ? PadmaTheme.primaryTeal : PadmaTheme.surfaceElevated)),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isWaitActiveOnThisStop
                                        ? PadmaTheme.busAmber
                                        : (isCurrent
                                            ? PadmaTheme.primaryTeal
                                            : (isPassed ? PadmaTheme.successGreen : PadmaTheme.borderLine)),
                                    width: (isCurrent || isWaitActiveOnThisStop) ? 2 : 1,
                                  ),
                                ),
                                child: isWaitActiveOnThisStop
                                    ? const Center(child: Icon(Icons.hourglass_top_rounded, size: 11, color: Colors.black))
                                    : (isPassed
                                        ? const Icon(Icons.check, size: 11, color: Colors.black)
                                        : (isCurrent
                                            ? const Center(
                                                child: Icon(Icons.directions_bus, size: 9, color: PadmaTheme.onPrimary),
                                              )
                                            : null)),
                              ),
                              if (!isLast)
                                Container(
                                  width: 2,
                                  height: isWaitActiveOnThisStop ? 48 : 28,
                                  color: isPassed ? PadmaTheme.successGreen : PadmaTheme.borderLine,
                                ),
                            ],
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            stop.name,
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: (isCurrent || isWaitActiveOnThisStop) ? FontWeight.w800 : FontWeight.w500,
                                              color: isWaitActiveOnThisStop
                                                  ? PadmaTheme.busAmber
                                                  : (isCurrent
                                                      ? PadmaTheme.primaryTeal
                                                      : (isPassed ? PadmaTheme.textPrimary : PadmaTheme.textSecondary)),
                                            ),
                                          ),
                                          if (stop.name.toLowerCase().contains('mirpur 10') || stop.name.toLowerCase().contains('dss')) ...[
                                            const SizedBox(width: 6),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                              decoration: BoxDecoration(
                                                color: PadmaTheme.surfaceElevated,
                                                borderRadius: BorderRadius.circular(4),
                                                border: Border.all(color: PadmaTheme.borderLine),
                                              ),
                                              child: const Text(
                                                '~5-6m Stop',
                                                style: TextStyle(fontSize: 8.5, color: PadmaTheme.textMuted, fontWeight: FontWeight.w600),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      Text(
                                        isWaitActiveOnThisStop ? adminBus.activeWaitNotice!.untilTime : stop.eta,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: isWaitActiveOnThisStop
                                              ? PadmaTheme.busAmber
                                              : (isPassed ? PadmaTheme.successGreen : PadmaTheme.textMuted),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (isCurrent)
                                    const Padding(
                                      padding: EdgeInsets.only(top: 2),
                                      child: Text(
                                        '● Current stop (Broadcasting live)',
                                        style: TextStyle(fontSize: 10, color: PadmaTheme.primaryTeal, fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  if (isWaitActiveOnThisStop) ...[
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: PadmaTheme.busAmber.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: PadmaTheme.busAmber.withValues(alpha: 0.4)),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.timer_rounded, size: 12, color: PadmaTheme.busAmber),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              '⏱️ Waiting until ${adminBus.activeWaitNotice!.untilTime} (Extra wait)',
                                              style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: PadmaTheme.busAmber),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
