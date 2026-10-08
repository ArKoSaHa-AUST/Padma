import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme.dart';
import '../../view_models/admin_view_model.dart';
import '../admin_bus_tracker_view.dart';
import '../widgets/admin_3d_card.dart';

class AdminFleetTab extends StatelessWidget {
  const AdminFleetTab({super.key});

  void _navigateToLiveTracker(BuildContext context, String busId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdminBusTrackerView(busId: busId),
      ),
    );
  }

  void _showStatusDialog(BuildContext context, AdminViewModel adminVM, AdminBusItem bus) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: PadmaTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: PadmaTheme.borderLine)),
        title: Text('Change Status: ${bus.title}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: PadmaTheme.textPrimary)),
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
                title: Text(status.displayName, style: TextStyle(fontSize: 13, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500, color: PadmaTheme.textPrimary)),
                trailing: isSelected ? Icon(Icons.check_rounded, color: status.color, size: 18) : null,
                onTap: () {
                  adminVM.updateBusStatus(bus.id, status);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${bus.title} status updated to ${status.displayName}')),
                  );
                  if (status == AdminBusStatus.onTime) {
                    _navigateToLiveTracker(context, bus.id);
                  }
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: PadmaTheme.borderLine)),
          title: const Text('Override Speed Telemetry', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: PadmaTheme.textPrimary)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('$currentSpeed KM/H', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: PadmaTheme.primaryTeal)),
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
              style: ElevatedButton.styleFrom(backgroundColor: PadmaTheme.primaryTeal, foregroundColor: PadmaTheme.onPrimary),
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

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: adminVM.fleet.length,
      itemBuilder: (context, index) {
        final bus = adminVM.fleet[index];

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: Admin3dCard(
            onTap: () => _navigateToLiveTracker(context, bus.id),
            borderColor: bus.isBroadcastingGps ? PadmaTheme.primaryTeal.withValues(alpha: 0.4) : PadmaTheme.borderLine,
            glowColor: bus.isBroadcastingGps ? PadmaTheme.primaryTeal.withValues(alpha: 0.1) : Colors.transparent,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Bus Name, Plate & Status Pill
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: PadmaTheme.busAmberContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.directions_bus_filled_rounded, color: PadmaTheme.busAmber, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(bus.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: PadmaTheme.textPrimary)),
                          const SizedBox(height: 2),
                          Text('Plate: ${bus.busNumber}', style: const TextStyle(fontSize: 11, color: PadmaTheme.textMuted)),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () => _showStatusDialog(context, adminVM, bus),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: bus.status.color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: bus.status.color.withValues(alpha: 0.5)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(bus.status.displayName, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: bus.status.color)),
                            const SizedBox(width: 4),
                            Icon(Icons.edit_rounded, size: 12, color: bus.status.color),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Telemetry Metrics Row
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: PadmaTheme.surfaceElevated,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: PadmaTheme.borderLine),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      InkWell(
                        onTap: () => _showSpeedDialog(context, adminVM, bus),
                        child: Column(
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('${bus.currentSpeed}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: PadmaTheme.primaryTeal)),
                                const SizedBox(width: 2),
                                const Icon(Icons.edit, size: 10, color: PadmaTheme.primaryTeal),
                              ],
                            ),
                            const Text('KM/H SPEED', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: PadmaTheme.textMuted)),
                          ],
                        ),
                      ),
                      Container(width: 1, height: 24, color: PadmaTheme.borderLine),
                      Column(
                        children: [
                          Text('${bus.etaMinutes}m', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: PadmaTheme.busAmber)),
                          const Text('EST. ARRIVAL', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: PadmaTheme.textMuted)),
                        ],
                      ),
                      Container(width: 1, height: 24, color: PadmaTheme.borderLine),
                      Column(
                        children: [
                          Text('${bus.passengerCount} / 52', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: PadmaTheme.textPrimary)),
                          const Text('CAPACITY', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: PadmaTheme.textMuted)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Driver & Next Stop Info
                Row(
                  children: [
                    const Icon(Icons.person_outline_rounded, size: 16, color: PadmaTheme.textSecondary),
                    const SizedBox(width: 6),
                    Text(bus.driverName, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: PadmaTheme.textPrimary)),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Calling driver at ${bus.driverPhone}')),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: PadmaTheme.primaryTealContainer,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.phone, size: 10, color: PadmaTheme.primaryTeal),
                            const SizedBox(width: 4),
                            Text(bus.driverPhone, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: PadmaTheme.primaryTeal)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 16, color: PadmaTheme.primaryTeal),
                    const SizedBox(width: 6),
                    const Text('Next Stop: ', style: TextStyle(fontSize: 12, color: PadmaTheme.textMuted)),
                    Text(bus.nextStop, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: PadmaTheme.textPrimary)),
                  ],
                ),
                const SizedBox(height: 14),

                // Action Bar: GPS Beacon Toggle & Live Tracker Action
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          adminVM.toggleBusGps(bus.id);
                          _navigateToLiveTracker(context, bus.id);
                        },
                        icon: Icon(
                          bus.isBroadcastingGps ? Icons.sensors_rounded : Icons.sensors_off_rounded,
                          size: 16,
                        ),
                        label: Text(
                          bus.isBroadcastingGps ? 'GPS Beacon: Broadcasting' : 'GPS Beacon: Disabled',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: bus.isBroadcastingGps ? PadmaTheme.primaryTeal : PadmaTheme.surfaceElevated,
                          foregroundColor: bus.isBroadcastingGps ? PadmaTheme.onPrimary : PadmaTheme.urgentRed,
                          side: BorderSide(color: bus.isBroadcastingGps ? PadmaTheme.primaryTeal : PadmaTheme.urgentRed.withValues(alpha: 0.5)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filledTonal(
                      tooltip: 'Open Live Tracker & Stoppage Controls',
                      onPressed: () => _navigateToLiveTracker(context, bus.id),
                      icon: const Icon(Icons.map_rounded, size: 18, color: PadmaTheme.primaryTeal),
                      style: IconButton.styleFrom(
                        backgroundColor: PadmaTheme.surfaceElevated,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: const BorderSide(color: PadmaTheme.borderLine),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

