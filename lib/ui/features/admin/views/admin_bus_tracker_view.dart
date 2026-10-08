import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../../../core/config/map_config.dart';
import '../../../../features/live_bus/data/models/live_bus_location.dart';
import '../../../../features/live_bus/presentation/widgets/padma_live_map_widget.dart';
import '../../../core/theme.dart';
import '../../channels/view_models/channels_view_model.dart';
import '../../channels/views/bus_telemetry_chat_view.dart';
import '../view_models/admin_view_model.dart';
import 'widgets/admin_3d_card.dart';
import 'widgets/short_message_modal.dart';

class AdminBusTrackerView extends StatefulWidget {
  final String busId;

  const AdminBusTrackerView({super.key, required this.busId});

  @override
  State<AdminBusTrackerView> createState() => _AdminBusTrackerViewState();
}

class _AdminBusTrackerViewState extends State<AdminBusTrackerView> {
  final MapController _mapController = MapController();
  String? _selectedDropdownStoppage;

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _recenter(double lat, double lng) {
    _mapController.move(LatLng(lat, lng), 14.5);
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Map centered on bus dispatch location'),
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showStatusDialog(BuildContext context, AdminViewModel adminVM, AdminBusItem bus) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: PadmaTheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: PadmaTheme.borderLine),
        ),
        title: Text(
          'Change Status: ${bus.title}',
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: PadmaTheme.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: AdminBusStatus.values.map((status) {
            final isSelected = bus.status == status;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: isSelected ? status.color.withValues(alpha: 0.15) : PadmaTheme.surfaceElevated,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: isSelected ? status.color : PadmaTheme.borderLine),
              ),
              child: ListTile(
                dense: true,
                leading: Icon(Icons.circle, color: status.color, size: 12),
                title: Text(
                  status.displayName,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: PadmaTheme.textPrimary,
                  ),
                ),
                trailing: isSelected ? Icon(Icons.check_rounded, color: status.color, size: 18) : null,
                onTap: () {
                  adminVM.updateBusStatus(bus.id, status);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${bus.title} status updated to ${status.displayName}')),
                  );
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showSpeedDialog(BuildContext context, AdminViewModel adminVM, AdminBusItem bus) {
    int currentSpeed = bus.currentSpeed == 0 ? 36 : bus.currentSpeed;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: PadmaTheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: PadmaTheme.borderLine),
          ),
          title: const Text(
            'Override Speed Telemetry',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: PadmaTheme.textPrimary),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$currentSpeed KM/H',
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: PadmaTheme.primaryTeal),
              ),
              Slider(
                value: currentSpeed.toDouble(),
                min: 0,
                max: 80,
                divisions: 16,
                activeColor: PadmaTheme.primaryTeal,
                inactiveColor: PadmaTheme.borderLine,
                onChanged: (val) {
                  setDialogState(() => currentSpeed = val.round());
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: PadmaTheme.textMuted)),
            ),
            ElevatedButton(
              onPressed: () {
                adminVM.updateBusSpeed(bus.id, currentSpeed);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${bus.title} speed updated to $currentSpeed KM/H')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: PadmaTheme.primaryTeal,
                foregroundColor: PadmaTheme.onPrimary,
              ),
              child: const Text('Save Speed'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final adminVM = context.watch<AdminViewModel>();
    final channelsVM = context.watch<ChannelsViewModel>();

    final bus = adminVM.fleet.firstWhere(
      (b) => b.id == widget.busId || b.id == widget.busId.replaceAll('-', '_'),
      orElse: () => adminVM.fleet.first,
    );

    _selectedDropdownStoppage ??= bus.currentStop;

    final busLocation = LiveBusLocation(
      busId: bus.id,
      latitude: bus.latitude,
      longitude: bus.longitude,
      speed: bus.currentSpeed.toDouble(),
      heading: 0,
      timestamp: DateTime.now(),
      sharingSessionId: 'admin_session_${bus.id}',
      isSharing: bus.isBroadcastingGps && bus.status != AdminBusStatus.tripEnded,
    );

    final routePoints = bus.stoppages.map((s) => LatLng(s.lat, s.lng)).toList();

    return Scaffold(
      backgroundColor: PadmaTheme.surfaceLowest,
      appBar: AppBar(
        backgroundColor: PadmaTheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: PadmaTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              bus.title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: PadmaTheme.textPrimary),
            ),
            Text(
              'Plate: ${bus.busNumber}',
              style: const TextStyle(fontSize: 11, color: PadmaTheme.textMuted),
            ),
          ],
        ),
        actions: [
          // Status pill in AppBar
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: InkWell(
              onTap: () => _showStatusDialog(context, adminVM, bus),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: bus.status.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: bus.status.color.withValues(alpha: 0.5)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, size: 8, color: bus.status.color),
                    const SizedBox(width: 5),
                    Text(
                      bus.status.displayName,
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: bus.status.color),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.edit_rounded, size: 12, color: bus.status.color),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Interactive Live Map Section
            Container(
              height: 320,
              width: double.infinity,
              color: PadmaTheme.surfaceLowest,
              child: Stack(
                children: [
                  PadmaLiveMapWidget(
                    liveLocation: busLocation,
                    routePolyline: routePoints,
                    mapController: _mapController,
                    isLive: bus.isBroadcastingGps && bus.status != AdminBusStatus.tripEnded,
                  ),

                  // Top Floating HUD: Speedometer & Recenter
                  Positioned(
                    top: 14,
                    left: 14,
                    right: 14,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // GPS Status Pill
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: PadmaTheme.surface.withValues(alpha: 0.92),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: bus.isBroadcastingGps ? PadmaTheme.successGreen : PadmaTheme.urgentRed,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                bus.isBroadcastingGps ? Icons.sensors_rounded : Icons.sensors_off_rounded,
                                size: 14,
                                color: bus.isBroadcastingGps ? PadmaTheme.successGreen : PadmaTheme.urgentRed,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                bus.isBroadcastingGps ? 'GPS ACTIVE' : 'GPS OFFLINE',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: bus.isBroadcastingGps ? PadmaTheme.successGreen : PadmaTheme.urgentRed,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Speed Pill
                        InkWell(
                          onTap: () => _showSpeedDialog(context, adminVM, bus),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
                                  '${bus.currentSpeed} KM/H',
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: PadmaTheme.textPrimary),
                                ),
                                const SizedBox(width: 3),
                                const Icon(Icons.edit, size: 10, color: PadmaTheme.primaryTeal),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Floating Recenter FAB
                  Positioned(
                    bottom: 14,
                    right: 14,
                    child: FloatingActionButton.small(
                      heroTag: 'admin_recenter_fab',
                      backgroundColor: PadmaTheme.surface,
                      foregroundColor: PadmaTheme.busAmber,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: const BorderSide(color: PadmaTheme.borderLine),
                      ),
                      onPressed: () => _recenter(bus.latitude, bus.longitude),
                      child: const Icon(Icons.my_location_rounded, size: 18),
                    ),
                  ),
                ],
              ),
            ),

            // 2. STOPPAGE DISPATCH & LOCATION UPDATER (KEY FEATURE)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Admin3dCard(
                borderColor: PadmaTheme.primaryTeal.withValues(alpha: 0.5),
                glowColor: PadmaTheme.primaryTeal.withValues(alpha: 0.12),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: PadmaTheme.primaryTealContainer,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.alt_route_rounded, color: PadmaTheme.primaryTeal, size: 20),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Stoppage Dispatch Controller',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: PadmaTheme.textPrimary),
                              ),
                              Text(
                                'Select arrived stoppage & tap checkmark to broadcast update',
                                style: TextStyle(fontSize: 11, color: PadmaTheme.textMuted),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 22, color: PadmaTheme.borderLine),

                    // Current Stoppage Info Banner
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: PadmaTheme.surfaceElevated,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: PadmaTheme.borderLine),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.location_on, color: PadmaTheme.primaryTeal, size: 16),
                              const SizedBox(width: 6),
                              const Text('Current Stoppage: ', style: TextStyle(fontSize: 12, color: PadmaTheme.textMuted)),
                              Expanded(
                                child: Text(
                                  bus.currentStop,
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: PadmaTheme.primaryTeal),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.arrow_forward_rounded, color: PadmaTheme.busAmber, size: 16),
                              const SizedBox(width: 6),
                              const Text('Heading Towards: ', style: TextStyle(fontSize: 12, color: PadmaTheme.textMuted)),
                              Expanded(
                                child: Text(
                                  bus.nextStop,
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: PadmaTheme.busAmber),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (bus.etaMinutes > 0)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: PadmaTheme.busAmberContainer,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '${bus.etaMinutes}m ETA',
                                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: PadmaTheme.busAmber),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Dropdown and Green Tick Action Row
                    Row(
                      children: [
                        // Dropdown Selector for Stoppages
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: PadmaTheme.surfaceElevated,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: PadmaTheme.borderLine),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                isExpanded: true,
                                value: bus.stoppages.any((s) => s.name == _selectedDropdownStoppage)
                                    ? _selectedDropdownStoppage
                                    : bus.stoppages.first.name,
                                dropdownColor: PadmaTheme.surfaceElevated,
                                icon: const Icon(Icons.arrow_drop_down_rounded, color: PadmaTheme.primaryTeal),
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: PadmaTheme.textPrimary),
                                items: bus.stoppages.map((stoppage) {
                                  final idx = bus.stoppages.indexOf(stoppage) + 1;
                                  return DropdownMenuItem<String>(
                                    value: stoppage.name,
                                    child: Text(
                                      '$idx. ${stoppage.name}',
                                      style: const TextStyle(fontSize: 13, color: PadmaTheme.textPrimary),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      _selectedDropdownStoppage = value;
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),

                        // GREEN TICK CONFIRMATION BUTTON
                        ElevatedButton.icon(
                          onPressed: () {
                            final selectedStop = _selectedDropdownStoppage ?? bus.currentStop;
                            adminVM.updateBusStoppage(
                              bus.id,
                              selectedStop,
                              onBroadcastMessage: (channelId, msg) {
                                channelsVM.broadcastDispatchMessage(channelId, msg);
                              },
                            );

                            _recenter(bus.latitude, bus.longitude);

                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    const Icon(Icons.check_circle_rounded, color: PadmaTheme.successGreen, size: 20),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Bus reached $selectedStop. Heading towards ${bus.nextStop}',
                                        style: const TextStyle(fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  ],
                                ),
                                backgroundColor: PadmaTheme.surfaceElevated,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          icon: const Icon(Icons.check_circle_rounded, size: 18),
                          label: const Text('Confirm', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: PadmaTheme.successGreen,
                            foregroundColor: Colors.black,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Quick Next Stop Button
                    if (bus.currentStopIndex + 1 < bus.stoppages.length)
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            adminVM.advanceToNextStoppage(
                              bus.id,
                              onBroadcastMessage: (channelId, msg) {
                                channelsVM.broadcastDispatchMessage(channelId, msg);
                              },
                            );
                            setState(() {
                              _selectedDropdownStoppage = bus.nextStop;
                            });
                            _recenter(bus.latitude, bus.longitude);

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Advanced to next stoppage: ${bus.currentStop}'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          icon: const Icon(Icons.skip_next_rounded, size: 18, color: PadmaTheme.primaryTeal),
                          label: Text(
                            'Quick Advance to Next: ${bus.nextStop}',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: PadmaTheme.primaryTeal),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: PadmaTheme.primaryTeal),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // 3. Telemetry & Quick Action Shortcuts
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => adminVM.toggleBusGps(bus.id),
                      icon: Icon(
                        bus.isBroadcastingGps ? Icons.sensors_rounded : Icons.sensors_off_rounded,
                        size: 16,
                      ),
                      label: Text(
                        bus.isBroadcastingGps ? 'GPS: Broadcasting' : 'GPS: Disabled',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: bus.isBroadcastingGps ? PadmaTheme.primaryTeal : PadmaTheme.surfaceElevated,
                        foregroundColor: bus.isBroadcastingGps ? PadmaTheme.onPrimary : PadmaTheme.urgentRed,
                        side: BorderSide(
                          color: bus.isBroadcastingGps ? PadmaTheme.primaryTeal : PadmaTheme.urgentRed.withValues(alpha: 0.5),
                        ),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ShortMessageModal.show(context, bus: bus);
                      },
                      icon: const Icon(Icons.quickreply_rounded, size: 16),
                      label: const Text('Short Messages', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: bus.activeWaitNotice != null
                            ? PadmaTheme.busAmber.withValues(alpha: 0.2)
                            : PadmaTheme.surfaceElevated,
                        foregroundColor: bus.activeWaitNotice != null
                            ? PadmaTheme.busAmber
                            : PadmaTheme.textPrimary,
                        side: BorderSide(
                          color: bus.activeWaitNotice != null ? PadmaTheme.busAmber : PadmaTheme.borderLine,
                        ),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 4. Stoppages Progression Checkpoints List
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
                              'Stoppage Route Progression',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: PadmaTheme.textPrimary),
                            ),
                          ],
                        ),
                        Text(
                          '${bus.currentStopIndex + 1} of ${bus.stoppages.length}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: PadmaTheme.textMuted),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Stoppages list items
                    ...bus.stoppages.map((stop) {
                      final stopIdx = bus.stoppages.indexOf(stop);
                      final isPassed = stopIdx < bus.currentStopIndex;
                      final isCurrent = stopIdx == bus.currentStopIndex;
                      final isLast = stopIdx == bus.stoppages.length - 1;
                      final isWaitActiveOnThisStop = bus.activeWaitNotice != null &&
                          (bus.activeWaitNotice!.stoppageName.toLowerCase().trim() == stop.name.toLowerCase().trim() ||
                              (bus.activeWaitNotice!.stoppageName.toLowerCase().contains('mirpur 10') &&
                                  stop.name.toLowerCase().contains('mirpur 10')) ||
                              (bus.activeWaitNotice!.stoppageName.toLowerCase().contains('dss') &&
                                  stop.name.toLowerCase().contains('dss')));

                      return InkWell(
                        onTap: () {
                          setState(() {
                            _selectedDropdownStoppage = stop.name;
                          });
                          adminVM.updateBusStoppage(
                            bus.id,
                            stop.name,
                            onBroadcastMessage: (channelId, msg) {
                              channelsVM.broadcastDispatchMessage(channelId, msg);
                            },
                          );
                          _recenter(stop.lat, stop.lng);
                        },
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Left indicator line
                            Column(
                              children: [
                                Container(
                                  width: 22,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isWaitActiveOnThisStop
                                        ? PadmaTheme.busAmber
                                        : (isPassed
                                            ? PadmaTheme.successGreen
                                            : isCurrent
                                                ? PadmaTheme.primaryTeal
                                                : PadmaTheme.surfaceElevated),
                                    border: Border.all(
                                      color: isWaitActiveOnThisStop
                                          ? PadmaTheme.busAmber
                                          : (isCurrent
                                              ? PadmaTheme.primaryTeal
                                              : isPassed
                                                  ? PadmaTheme.successGreen
                                                  : PadmaTheme.borderLine),
                                      width: (isCurrent || isWaitActiveOnThisStop) ? 2 : 1,
                                    ),
                                  ),
                                  child: Center(
                                    child: isWaitActiveOnThisStop
                                        ? const Icon(Icons.hourglass_top_rounded, size: 12, color: Colors.black)
                                        : (isPassed
                                            ? const Icon(Icons.check, size: 14, color: Colors.black)
                                            : isCurrent
                                                ? const Icon(Icons.directions_bus, size: 12, color: PadmaTheme.onPrimary)
                                                : Text(
                                                    '${stopIdx + 1}',
                                                    style: const TextStyle(fontSize: 10, color: PadmaTheme.textMuted),
                                                  )),
                                  ),
                                ),
                                if (!isLast)
                                  Container(
                                    width: 2,
                                    height: isWaitActiveOnThisStop ? 48 : 26,
                                    color: isPassed ? PadmaTheme.successGreen : PadmaTheme.borderLine,
                                  ),
                              ],
                            ),
                            const SizedBox(width: 12),

                            // Stoppage details
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
                                                fontWeight: (isCurrent || isWaitActiveOnThisStop) ? FontWeight.w800 : FontWeight.w600,
                                                color: isWaitActiveOnThisStop
                                                    ? PadmaTheme.busAmber
                                                    : (isCurrent
                                                        ? PadmaTheme.primaryTeal
                                                        : isPassed
                                                            ? PadmaTheme.textPrimary
                                                            : PadmaTheme.textSecondary),
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
                                                  style: TextStyle(fontSize: 9, color: PadmaTheme.textMuted, fontWeight: FontWeight.w600),
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                        Text(
                                          stop.eta,
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: isWaitActiveOnThisStop
                                                ? PadmaTheme.busAmber
                                                : (isCurrent ? PadmaTheme.primaryTeal : PadmaTheme.textMuted),
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (isCurrent)
                                      const Padding(
                                        padding: EdgeInsets.only(top: 2),
                                        child: Text(
                                          '● Current Position (Broadcasting)',
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
                                                'Scheduled Wait until ${bus.activeWaitNotice!.untilTime}',
                                                style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: PadmaTheme.busAmber),
                                              ),
                                            ),
                                            InkWell(
                                              onTap: () {
                                                adminVM.clearStoppageWaitNotice(bus.id);
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(content: Text('Stoppage wait notice cleared.')),
                                                );
                                              },
                                              child: const Text('Clear', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: PadmaTheme.urgentRed)),
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
                        ),
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
