import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme.dart';
import '../../view_models/admin_view_model.dart';
import '../widgets/admin_3d_card.dart';

class AdminModerationTab extends StatelessWidget {
  const AdminModerationTab({super.key});

  @override
  Widget build(BuildContext context) {
    final adminVM = context.watch<AdminViewModel>();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Channel Security & Rate Limit Controls
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: PadmaTheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: PadmaTheme.borderLine),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.shield_outlined, color: PadmaTheme.primaryTeal, size: 20),
                    SizedBox(width: 8),
                    Text('Channel Security & Rate Limits', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: PadmaTheme.textPrimary)),
                  ],
                ),
                const SizedBox(height: 14),

                // Lock General Channel
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Lock #general (Announcement Mode)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: PadmaTheme.textPrimary)),
                  subtitle: const Text('Prevents student messages during major campus transit incidents', style: TextStyle(fontSize: 11, color: PadmaTheme.textMuted)),
                  value: adminVM.isGeneralLocked,
                  activeThumbColor: PadmaTheme.urgentRed,
                  onChanged: (val) {
                    adminVM.toggleGeneralLock();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(adminVM.isGeneralLocked ? '🔒 #general locked for student posting' : '🔓 #general unlocked')),
                    );
                  },
                ),
                const Divider(height: 16),

                // Slow Mode
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Slow Mode (15-Second Cooldown)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: PadmaTheme.textPrimary)),
                  subtitle: const Text('Limits users to 1 message every 15 seconds to prevent spam', style: TextStyle(fontSize: 11, color: PadmaTheme.textMuted)),
                  value: adminVM.isSlowModeEnabled,
                  activeThumbColor: PadmaTheme.primaryTeal,
                  onChanged: (val) {
                    adminVM.toggleSlowMode();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(adminVM.isSlowModeEnabled ? '⏱️ Slow mode enabled (15s)' : '⏱️ Slow mode disabled')),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Reported Messages Queue
          Row(
            children: [
              const Text('Reported Content Queue', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: PadmaTheme.textPrimary)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: PadmaTheme.urgentRed.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${adminVM.reportedMessages.length} Pending',
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: PadmaTheme.urgentRed),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          if (adminVM.reportedMessages.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              alignment: Alignment.center,
              child: const Column(
                children: [
                  Icon(Icons.check_circle_outline_rounded, size: 40, color: PadmaTheme.successGreen),
                  SizedBox(height: 8),
                  Text('Moderation Queue Clean', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: PadmaTheme.textPrimary)),
                  Text('No flagged student messages at this time.', style: TextStyle(fontSize: 12, color: PadmaTheme.textMuted)),
                ],
              ),
            )
          else
            ...adminVM.reportedMessages.map((rep) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: Admin3dCard(
                  borderColor: PadmaTheme.urgentRed.withValues(alpha: 0.4),
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: PadmaTheme.urgentRed.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              rep.reason.toUpperCase(),
                              style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: PadmaTheme.urgentRed),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(rep.channelName, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: PadmaTheme.primaryTeal)),
                          const Spacer(),
                          Text(
                            DateFormat('hh:mm a').format(rep.reportedAt),
                            style: const TextStyle(fontSize: 10, color: PadmaTheme.textMuted),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Student: ${rep.studentName} (${rep.studentId})',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: PadmaTheme.textPrimary),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: PadmaTheme.surfaceElevated,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '"${rep.messageContent}"',
                          style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: PadmaTheme.textSecondary),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                adminVM.resolveReport(rep.id, deleteMessage: false);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Report dismissed without action.')),
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: PadmaTheme.borderLine),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                padding: const EdgeInsets.symmetric(vertical: 6),
                              ),
                              child: const Text('Dismiss', style: TextStyle(fontSize: 11, color: PadmaTheme.textMuted)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                adminVM.resolveReport(rep.id, deleteMessage: true);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('🗑️ Message deleted from channel!')),
                                );
                              },
                              icon: const Icon(Icons.delete_forever_rounded, size: 14),
                              label: const Text('Delete Message', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: PadmaTheme.urgentRed,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                padding: const EdgeInsets.symmetric(vertical: 6),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}
