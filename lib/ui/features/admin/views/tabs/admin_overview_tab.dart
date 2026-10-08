import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme.dart';
import '../../view_models/admin_view_model.dart';
import '../widgets/admin_3d_card.dart';
import '../widgets/ai_copilot_sheet.dart';

class AdminOverviewTab extends StatelessWidget {
  final Function(int tabIndex) onNavigateTab;

  const AdminOverviewTab({super.key, required this.onNavigateTab});

  @override
  Widget build(BuildContext context) {
    final adminVM = context.watch<AdminViewModel>();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting & Status Strip
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: PadmaTheme.successGreen,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: PadmaTheme.successGreen, blurRadius: 8, spreadRadius: 1),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'AUST Transport Command Center // Live',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: PadmaTheme.primaryTeal, letterSpacing: 0.5),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () {
                  AiCopilotSheet.show(
                    context,
                    onApply: (title, body, priority) {
                      adminVM.addAnnouncement(
                        title: title,
                        body: body,
                        priority: priority,
                        targetRoute: 'All Routes',
                        isPinned: true,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('✨ AI Announcement published successfully!')),
                      );
                    },
                  );
                },
                icon: const Icon(Icons.auto_awesome_rounded, size: 14),
                label: const Text('AI Copilot', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: PadmaTheme.primaryTealContainer,
                  foregroundColor: PadmaTheme.primaryTeal,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 3D Floating Bento Grid Stats
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 500;
              final crossAxisCount = isWide ? 4 : 2;

              return GridView.count(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: isWide ? 1.3 : 1.1,
                children: [
                  Admin3dCard(
                    onTap: () => onNavigateTab(1), // Fleet tab
                    borderColor: PadmaTheme.busAmber.withValues(alpha: 0.4),
                    glowColor: PadmaTheme.busAmber.withValues(alpha: 0.15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(color: PadmaTheme.busAmberContainer, borderRadius: BorderRadius.circular(8)),
                              child: const Icon(Icons.directions_bus_filled_rounded, color: PadmaTheme.busAmber, size: 18),
                            ),
                            const Text('3 / 3', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: PadmaTheme.textPrimary)),
                          ],
                        ),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Active Fleet', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: PadmaTheme.textPrimary)),
                            Text('All GPS Live', style: TextStyle(fontSize: 10, color: PadmaTheme.successGreen, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Admin3dCard(
                    onTap: () => onNavigateTab(2), // Client Channels tab
                    borderColor: PadmaTheme.primaryTeal.withValues(alpha: 0.4),
                    glowColor: PadmaTheme.primaryTeal.withValues(alpha: 0.15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(color: PadmaTheme.primaryTealContainer, borderRadius: BorderRadius.circular(8)),
                              child: const Icon(Icons.forum_rounded, color: PadmaTheme.primaryTeal, size: 18),
                            ),
                            const Text('6 Feeds', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: PadmaTheme.textPrimary)),
                          ],
                        ),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Client Channels', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: PadmaTheme.textPrimary)),
                            Text('248 Students online', style: TextStyle(fontSize: 10, color: PadmaTheme.textMuted)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Admin3dCard(
                    onTap: () => onNavigateTab(4), // Blood Hub
                    borderColor: PadmaTheme.urgentRed.withValues(alpha: 0.4),
                    glowColor: PadmaTheme.urgentRed.withValues(alpha: 0.15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(color: PadmaTheme.urgentRed.withValues(alpha: 0.18), borderRadius: BorderRadius.circular(8)),
                              child: const Icon(Icons.water_drop_rounded, color: PadmaTheme.urgentRed, size: 18),
                            ),
                            const Text('2', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: PadmaTheme.urgentRed)),
                          ],
                        ),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Blood Requests', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: PadmaTheme.textPrimary)),
                            Text('2 Pending match', style: TextStyle(fontSize: 10, color: PadmaTheme.urgentRed, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Admin3dCard(
                    onTap: () => onNavigateTab(5), // Moderation
                    borderColor: const Color(0xFF8B5CF6).withValues(alpha: 0.4),
                    glowColor: const Color(0xFF8B5CF6).withValues(alpha: 0.15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(color: const Color(0xFF8B5CF6).withValues(alpha: 0.18), borderRadius: BorderRadius.circular(8)),
                              child: const Icon(Icons.shield_rounded, color: Color(0xFF8B5CF6), size: 18),
                            ),
                            Text('${adminVM.reportedMessages.length}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: PadmaTheme.textPrimary)),
                          ],
                        ),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Mod Queue', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: PadmaTheme.textPrimary)),
                            Text('Reported posts', style: TextStyle(fontSize: 10, color: PadmaTheme.textMuted)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 20),

          // AI Transit Intelligence & Anomaly Ticker
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: PadmaTheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: PadmaTheme.primaryTeal.withValues(alpha: 0.4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.psychology_rounded, color: PadmaTheme.primaryTeal, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'AI Fleet Intelligence & Road Anomalies',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: PadmaTheme.textPrimary),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ...adminVM.aiInsights.asMap().entries.map((entry) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: PadmaTheme.surfaceElevated,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: PadmaTheme.borderLine),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            entry.value,
                            style: const TextStyle(fontSize: 12, color: PadmaTheme.textSecondary, height: 1.3),
                          ),
                        ),
                        const SizedBox(width: 6),
                        InkWell(
                          onTap: () => adminVM.dismissInsight(entry.key),
                          child: const Icon(Icons.close_rounded, size: 16, color: PadmaTheme.textMuted),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Quick Fleet Status Overview
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Active Fleet Telemetry', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: PadmaTheme.textPrimary)),
              TextButton(
                onPressed: () => onNavigateTab(1),
                child: const Text('Manage Fleet →', style: TextStyle(fontSize: 12, color: PadmaTheme.primaryTeal, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...adminVM.fleet.map((bus) {
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: PadmaTheme.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: PadmaTheme.borderLine),
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: PadmaTheme.busAmberContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.directions_bus_filled_rounded, color: PadmaTheme.busAmber, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(bus.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: PadmaTheme.textPrimary)),
                        const SizedBox(height: 2),
                        Text('Next: ${bus.nextStop}', style: const TextStyle(fontSize: 11, color: PadmaTheme.textSecondary)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: bus.status.color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: bus.status.color.withValues(alpha: 0.5)),
                    ),
                    child: Text(
                      bus.status.displayName,
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: bus.status.color),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
