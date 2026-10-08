import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../data/models/emergency_request.dart';
import '../../../../core/theme.dart';
import '../../../channels/view_models/channels_view_model.dart';
import '../widgets/admin_3d_card.dart';

class AdminBloodHubTab extends StatelessWidget {
  const AdminBloodHubTab({super.key});

  @override
  Widget build(BuildContext context) {
    final channelsVM = context.watch<ChannelsViewModel>();
    final requests = channelsVM.requests.where((r) => r.category == RequestCategory.blood).toList();

    if (requests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline_rounded, size: 48, color: PadmaTheme.successGreen.withValues(alpha: 0.6)),
            const SizedBox(height: 12),
            const Text(
              'No Active Blood Requests',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: PadmaTheme.textPrimary),
            ),
            const SizedBox(height: 4),
            const Text(
              'All campus medical needs are currently resolved.',
              style: TextStyle(fontSize: 12, color: PadmaTheme.textMuted),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: requests.length,
      itemBuilder: (context, index) {
        final req = requests[index];
        final isUrgent = req.urgency == RequestUrgency.critical;

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          child: Admin3dCard(
            borderColor: isUrgent ? PadmaTheme.urgentRed.withValues(alpha: 0.5) : PadmaTheme.borderLine,
            glowColor: isUrgent ? PadmaTheme.urgentRed.withValues(alpha: 0.12) : Colors.transparent,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Blood Badge, Request Title, Hospital/Location
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: PadmaTheme.urgentRed.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: PadmaTheme.urgentRed.withValues(alpha: 0.6)),
                      ),
                      child: Center(
                        child: Text(
                          req.bloodGroup,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: PadmaTheme.urgentRed),
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
                              Expanded(
                                child: Text(
                                  req.title,
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: PadmaTheme.textPrimary),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              if (isUrgent)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: PadmaTheme.urgentRed.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text('CRITICAL', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: PadmaTheme.urgentRed)),
                                ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text('📍 ${req.patientLocation}', style: const TextStyle(fontSize: 12, color: PadmaTheme.textSecondary)),
                          const SizedBox(height: 2),
                          Text('Posted by: ${req.postedBy}', style: const TextStyle(fontSize: 11, color: PadmaTheme.textMuted)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Description
                Text(
                  req.description,
                  style: const TextStyle(fontSize: 12, color: PadmaTheme.textSecondary, height: 1.3),
                ),
                const SizedBox(height: 12),

                // Attendant contact row
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: PadmaTheme.surfaceElevated,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.verified_user_rounded, size: 16, color: PadmaTheme.primaryTeal),
                      const SizedBox(width: 6),
                      const Text('Campus Verified Request', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: PadmaTheme.textPrimary)),
                      const Spacer(),
                      InkWell(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Calling attendant at ${req.contactNumber}')),
                          );
                        },
                        child: Row(
                          children: [
                            const Icon(Icons.phone, size: 12, color: PadmaTheme.primaryTeal),
                            const SizedBox(width: 4),
                            Text(req.contactNumber, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: PadmaTheme.primaryTeal)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Admin Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('📢 Push broadcast sent to all ${req.bloodGroup} registered donors!')),
                          );
                        },
                        icon: const Icon(Icons.notifications_active_rounded, size: 14),
                        label: const Text('Boost Alert', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: PadmaTheme.urgentRed,
                          side: BorderSide(color: PadmaTheme.urgentRed.withValues(alpha: 0.5)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Request "${req.title}" marked as FULFILLED!')),
                          );
                        },
                        icon: const Icon(Icons.check_circle_rounded, size: 14),
                        label: const Text('Mark Fulfilled', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: PadmaTheme.successGreen,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(vertical: 8),
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
