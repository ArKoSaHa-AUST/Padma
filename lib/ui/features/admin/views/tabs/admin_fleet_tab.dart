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

  /// Interactive Flow for Starting Trip:
  /// 1. Ask which admin is activating (Dropdown Person 1 to Person 6)
  /// 2. Ask for GPS broadcasting permission prompt
  /// 3. Update status to On Time and start Uber-like live GPS tracking
  void _showStartTripFlow(BuildContext context, AdminViewModel adminVM, AdminBusItem bus) {
    String selectedAdmin = AdminViewModel.availableAdminPersons.first;

    // Step 1: Admin Identity Selection Dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogCtx, setModalState) => AlertDialog(
          backgroundColor: PadmaTheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: PadmaTheme.borderLine),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: PadmaTheme.primaryTeal.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.badge_rounded, color: PadmaTheme.primaryTeal, size: 20),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Trip Activation Admin',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: PadmaTheme.textPrimary),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Please select which admin is activating the live journey for ${bus.title}:',
                style: const TextStyle(fontSize: 12.5, color: PadmaTheme.textSecondary, height: 1.4),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: PadmaTheme.surfaceElevated,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: PadmaTheme.primaryTeal.withValues(alpha: 0.5)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedAdmin,
                    isExpanded: true,
                    dropdownColor: PadmaTheme.surfaceElevated,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded, color: PadmaTheme.primaryTeal),
                    items: AdminViewModel.availableAdminPersons.map((name) {
                      return DropdownMenuItem<String>(
                        value: name,
                        child: Row(
                          children: [
                            const Icon(Icons.person_pin_rounded, size: 18, color: PadmaTheme.primaryTeal),
                            const SizedBox(width: 8),
                            Text(
                              name,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: PadmaTheme.textPrimary),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setModalState(() => selectedAdmin = val);
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: PadmaTheme.textMuted)),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                _showGpsPermissionPrompt(context, adminVM, bus, selectedAdmin);
              },
              icon: const Icon(Icons.arrow_forward_rounded, size: 16),
              label: const Text('Proceed to GPS Broadcast', style: TextStyle(fontWeight: FontWeight.w700)),
              style: ElevatedButton.styleFrom(
                backgroundColor: PadmaTheme.primaryTeal,
                foregroundColor: PadmaTheme.onPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Step 2: System-styled GPS Broadcasting Permission Request Modal
  void _showGpsPermissionPrompt(BuildContext context, AdminViewModel adminVM, AdminBusItem bus, String adminName) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: PadmaTheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: PadmaTheme.primaryTeal, width: 1.2),
        ),
        title: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: PadmaTheme.primaryTeal.withValues(alpha: 0.18),
                shape: BoxShape.circle,
                border: Border.all(color: PadmaTheme.primaryTeal.withValues(alpha: 0.5)),
              ),
              child: const Icon(Icons.location_on_rounded, color: PadmaTheme.primaryTeal, size: 30),
            ),
            const SizedBox(height: 12),
            const Text(
              'Allow "PADMA Admin" to access device location?',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: PadmaTheme.textPrimary),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'PADMA requires precise location permissions while broadcasting live bus telemetry so students can track the bus in real-time like Uber.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.5, color: PadmaTheme.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: PadmaTheme.surfaceElevated,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: PadmaTheme.borderLine),
              ),
              child: Row(
                children: [
                  const Icon(Icons.shield_outlined, size: 16, color: PadmaTheme.primaryTeal),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Activating Admin: $adminName\nStatus: Switching to "On Time" (Broadcasting)',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: PadmaTheme.textPrimary),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          OutlinedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('⚠️ GPS permission denied. Trip was not started.'),
                  backgroundColor: PadmaTheme.urgentRed,
                ),
              );
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: PadmaTheme.borderLine),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Don\'t Allow', style: TextStyle(color: PadmaTheme.textMuted)),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              adminVM.startTripWithAdminAndGps(
                busId: bus.id,
                adminPersonName: adminName,
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('🟢 Live GPS tracking activated by $adminName! Broadcasting to students.'),
                  backgroundColor: PadmaTheme.successGreen,
                ),
              );
              _navigateToLiveTracker(context, bus.id);
            },
            icon: const Icon(Icons.sensors_rounded, size: 16),
            label: const Text('Allow & Start Tracking', style: TextStyle(fontWeight: FontWeight.w800)),
            style: ElevatedButton.styleFrom(
              backgroundColor: PadmaTheme.primaryTeal,
              foregroundColor: PadmaTheme.onPrimary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
          ),
        ],
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
        final isTripEnded = bus.isTripEnded;

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: Admin3dCard(
            onTap: () => _navigateToLiveTracker(context, bus.id),
            borderColor: bus.isBroadcastingGps ? PadmaTheme.primaryTeal.withValues(alpha: 0.5) : PadmaTheme.borderLine,
            glowColor: bus.isBroadcastingGps ? PadmaTheme.primaryTeal.withValues(alpha: 0.12) : Colors.transparent,
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
                      onTap: () {
                        if (isTripEnded) {
                          _showStartTripFlow(context, adminVM, bus);
                        } else {
                          // Allow ending trip or changing status
                          _showActiveTripMenu(context, adminVM, bus);
                        }
                      },
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

                // Replaced area: Trip Activation & GPS Broadcasting Area
                if (isTripEnded) ...[
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: PadmaTheme.surfaceElevated,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: PadmaTheme.borderLine),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.pause_circle_filled_rounded, size: 16, color: PadmaTheme.textMuted),
                            SizedBox(width: 6),
                            Text(
                              'Trip Status: Trip Ended • Idle at Terminal',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: PadmaTheme.textSecondary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Tap below to verify admin identity, request GPS broadcast permission, and start live Uber-like tracking for students.',
                          style: TextStyle(fontSize: 11.5, color: PadmaTheme.textMuted, height: 1.3),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => _showStartTripFlow(context, adminVM, bus),
                            icon: const Icon(Icons.play_arrow_rounded, size: 18),
                            label: const Text('START TRIP & BROADCAST GPS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: PadmaTheme.primaryTeal,
                              foregroundColor: PadmaTheme.onPrimary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: PadmaTheme.primaryTeal.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: PadmaTheme.primaryTeal.withValues(alpha: 0.4)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                color: PadmaTheme.successGreen,
                                shape: BoxShape.circle,
                                boxShadow: [BoxShadow(color: PadmaTheme.successGreen, blurRadius: 6, spreadRadius: 1)],
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'LIVE GPS BROADCASTING ACTIVE',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: PadmaTheme.primaryTeal),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: PadmaTheme.surface,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: PadmaTheme.primaryTeal.withValues(alpha: 0.3)),
                              ),
                              child: Text(
                                'By ${bus.activatedByAdmin ?? 'Admin'}',
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: PadmaTheme.primaryTeal),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Current Stop: ${bus.currentStop}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: PadmaTheme.textPrimary),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  adminVM.endTrip(bus.id);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('🛑 Trip ended for ${bus.title}. GPS broadcast stopped.')),
                                  );
                                },
                                icon: const Icon(Icons.stop_rounded, size: 16, color: PadmaTheme.urgentRed),
                                label: const Text('END TRIP', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: PadmaTheme.urgentRed)),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: PadmaTheme.urgentRed.withValues(alpha: 0.5)),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _navigateToLiveTracker(context, bus.id),
                                icon: const Icon(Icons.map_rounded, size: 16),
                                label: const Text('Live Map Tracker', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: PadmaTheme.primaryTeal,
                                  foregroundColor: PadmaTheme.onPrimary,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 12),

                // Driver Contact Row
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
              ],
            ),
          ),
        );
      },
    );
  }

  void _showActiveTripMenu(BuildContext context, AdminViewModel adminVM, AdminBusItem bus) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: PadmaTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: PadmaTheme.borderLine)),
        title: Text('Trip Options: ${bus.title}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: PadmaTheme.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.stop_circle_rounded, color: PadmaTheme.urgentRed),
              title: const Text('End Current Trip', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: PadmaTheme.urgentRed)),
              subtitle: const Text('Turns off GPS beacon and sets status to Trip Ended', style: TextStyle(fontSize: 11, color: PadmaTheme.textMuted)),
              onTap: () {
                adminVM.endTrip(bus.id);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('🛑 Trip ended for ${bus.title}')),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.map_rounded, color: PadmaTheme.primaryTeal),
              title: const Text('Open Live Stoppage Controls', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: PadmaTheme.textPrimary)),
              onTap: () {
                Navigator.pop(ctx);
                _navigateToLiveTracker(context, bus.id);
              },
            ),
          ],
        ),
      ),
    );
  }
}

