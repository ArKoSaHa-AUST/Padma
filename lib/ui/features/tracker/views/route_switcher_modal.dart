import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme.dart';
import '../../admin/view_models/admin_view_model.dart';
import '../view_models/tracker_view_model.dart';

class RouteSwitcherModal extends StatelessWidget {
  const RouteSwitcherModal({super.key});

  @override
  Widget build(BuildContext context) {
    final trackerVM = context.watch<TrackerViewModel>();
    final adminVM = context.watch<AdminViewModel>();

    return Container(
      decoration: const BoxDecoration(
        color: PadmaTheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          const Row(
            children: [
              Icon(Icons.alt_route_rounded, color: PadmaTheme.busAmber, size: 22),
              SizedBox(width: 8),
              Text(
                'Select Active AUST Bus Route',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: PadmaTheme.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...trackerVM.routes.map((route) {
            final isSelected = route.id == trackerVM.selectedRoute.id;
            final targetBusId = (route.id == 'bus-2' || route.id == 'bus_2') ? 'bus_2' : 'bus_1';
            final adminBus = adminVM.fleet.firstWhere(
              (b) => b.id == targetBusId,
              orElse: () => adminVM.fleet.first,
            );

            return InkWell(
              onTap: () {
                trackerVM.selectRoute(route.id);
                Navigator.of(context).pop();
              },
              borderRadius: BorderRadius.circular(14),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isSelected ? PadmaTheme.surfaceElevated : PadmaTheme.surfaceLowest,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected ? PadmaTheme.primaryTeal : PadmaTheme.borderLine,
                    width: isSelected ? 1.5 : 0.8,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isSelected ? PadmaTheme.primaryTealContainer : PadmaTheme.surfaceHighest,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.directions_bus_filled_rounded,
                        color: isSelected ? PadmaTheme.primaryTeal : PadmaTheme.textMuted,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            adminBus.title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? PadmaTheme.textPrimary : PadmaTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${route.startLocation} ➔ ${route.destination}',
                            style: const TextStyle(fontSize: 12, color: PadmaTheme.textMuted),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: adminBus.status.color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: adminBus.status.color.withValues(alpha: 0.5)),
                      ),
                      child: Text(
                        adminBus.status.displayName,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: adminBus.status.color,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
