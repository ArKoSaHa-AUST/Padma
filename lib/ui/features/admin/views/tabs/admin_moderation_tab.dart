import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme.dart';
import '../../view_models/admin_view_model.dart';
import '../widgets/admin_3d_card.dart';

class AdminModerationTab extends StatefulWidget {
  const AdminModerationTab({super.key});

  @override
  State<AdminModerationTab> createState() => _AdminModerationTabState();
}

class _AdminModerationTabState extends State<AdminModerationTab> {
  String _userSearchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _channelsList = [
    {'id': 'bus-1-mirpur', 'name': 'Padma 1 (Mirpur Route)', 'icon': Icons.directions_bus_rounded, 'desc': 'Live telemetry & student bus coordination'},
    {'id': 'bus-2-uttara', 'name': 'Padma 2 (Uttara Route)', 'icon': Icons.directions_bus_filled_rounded, 'desc': 'Live telemetry & student bus coordination'},
    {'id': 'announcements', 'name': 'Announcements', 'icon': Icons.campaign_rounded, 'desc': 'Official transport notices (Admin broadcast only)'},
    {'id': 'rules-and-regulation', 'name': 'Rules & Regulations', 'icon': Icons.gavel_rounded, 'desc': 'AUST transit code of conduct'},
    {'id': 'blood-requests', 'name': 'Blood Requests', 'icon': Icons.bloodtype_rounded, 'desc': 'Emergency donor requests'},
    {'id': 'lost-and-found', 'name': 'Lost & Found', 'icon': Icons.inventory_2_rounded, 'desc': 'Lost item recovery desk'},
    {'id': 'feedback', 'name': 'Submit Complain / Feedback', 'icon': Icons.report_problem_rounded, 'desc': 'Student grievances triage'},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adminVM = context.watch<AdminViewModel>();
    final filteredUsers = adminVM.searchUsers(_userSearchQuery);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Channel Lock & Access Controls
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
                    Icon(Icons.lock_person_rounded, color: PadmaTheme.primaryTeal, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Channel Lock & Security Controls',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: PadmaTheme.textPrimary),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Locking a channel prevents students from posting messages while keeping read & reaction access.',
                  style: TextStyle(fontSize: 11, color: PadmaTheme.textMuted),
                ),
                const SizedBox(height: 14),

                // Slow Mode switch
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Slow Mode (15-Second Cooldown)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: PadmaTheme.textPrimary)),
                  subtitle: const Text('Limits users to 1 message every 15 seconds across all open channels', style: TextStyle(fontSize: 11, color: PadmaTheme.textMuted)),
                  value: adminVM.isSlowModeEnabled,
                  activeThumbColor: PadmaTheme.primaryTeal,
                  onChanged: (val) {
                    adminVM.toggleSlowMode();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(adminVM.isSlowModeEnabled ? '⏱️ Slow mode enabled (15s cooldown)' : '⏱️ Slow mode disabled')),
                    );
                  },
                ),
                const Divider(height: 20),

                // Channel lock items
                const Text(
                  'Individual Channel Locks',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: PadmaTheme.textSecondary),
                ),
                const SizedBox(height: 8),
                ..._channelsList.map((ch) {
                  final isLocked = adminVM.isChannelLocked(ch['id'] as String);
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isLocked ? PadmaTheme.urgentRed.withValues(alpha: 0.08) : PadmaTheme.surfaceElevated,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: isLocked ? PadmaTheme.urgentRed.withValues(alpha: 0.3) : PadmaTheme.borderLine),
                    ),
                    child: Row(
                      children: [
                        Icon(ch['icon'] as IconData, size: 18, color: isLocked ? PadmaTheme.urgentRed : PadmaTheme.primaryTeal),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ch['name'] as String,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: isLocked ? PadmaTheme.urgentRed : PadmaTheme.textPrimary,
                                ),
                              ),
                              Text(
                                isLocked ? '🔒 Locked by Admin' : (ch['desc'] as String),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isLocked ? PadmaTheme.urgentRed : PadmaTheme.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: isLocked,
                          activeColor: PadmaTheme.urgentRed,
                          onChanged: (val) {
                            adminVM.toggleChannelLock(ch['id'] as String);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  !isLocked ? '🔒 Locked #${ch['name']} for student messaging' : '🔓 Unlocked #${ch['name']}',
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 2. User Suspension & Blocking Directory
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
                Row(
                  children: [
                    const Icon(Icons.person_off_rounded, color: PadmaTheme.busAmber, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'User Suspension & Access Control',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: PadmaTheme.textPrimary),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: PadmaTheme.busAmber.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${adminVM.suspendedUserIds.length} Blocked',
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: PadmaTheme.busAmber),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Search any student by name or email to suspend/block or unblock transit privileges.',
                  style: TextStyle(fontSize: 11, color: PadmaTheme.textMuted),
                ),
                const SizedBox(height: 12),

                // Search field
                TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    setState(() {
                      _userSearchQuery = val;
                    });
                  },
                  style: const TextStyle(fontSize: 12, color: PadmaTheme.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Search user (e.g. User 1, User 12, padmaStudent@aust.edu)...',
                    hintStyle: const TextStyle(fontSize: 12, color: PadmaTheme.textMuted),
                    prefixIcon: const Icon(Icons.search_rounded, size: 18, color: PadmaTheme.textMuted),
                    suffixIcon: _userSearchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 16, color: PadmaTheme.textMuted),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _userSearchQuery = '';
                              });
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: PadmaTheme.surfaceElevated,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: PadmaTheme.borderLine),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: PadmaTheme.borderLine),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: PadmaTheme.primaryTeal),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // User list
                if (filteredUsers.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: Text('No users match search query', style: TextStyle(fontSize: 12, color: PadmaTheme.textMuted)),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredUsers.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, idx) {
                      final u = filteredUsers[idx];
                      final isSuspended = adminVM.isUserSuspended(u.id);

                      return Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isSuspended ? PadmaTheme.urgentRed.withValues(alpha: 0.08) : PadmaTheme.surfaceElevated,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSuspended ? PadmaTheme.urgentRed.withValues(alpha: 0.3) : PadmaTheme.borderLine,
                          ),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: isSuspended ? PadmaTheme.urgentRed.withValues(alpha: 0.2) : PadmaTheme.primaryTeal.withValues(alpha: 0.15),
                              child: Text(
                                u.name.isNotEmpty ? u.name[0].toUpperCase() : 'U',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: isSuspended ? PadmaTheme.urgentRed : PadmaTheme.primaryTeal,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        u.name,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: isSuspended ? PadmaTheme.urgentRed : PadmaTheme.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                        decoration: BoxDecoration(
                                          color: isSuspended ? PadmaTheme.urgentRed.withValues(alpha: 0.2) : PadmaTheme.successGreen.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          isSuspended ? 'SUSPENDED' : 'ACTIVE',
                                          style: TextStyle(
                                            fontSize: 8,
                                            fontWeight: FontWeight.w800,
                                            color: isSuspended ? PadmaTheme.urgentRed : PadmaTheme.successGreen,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${u.email} • ID: ${u.studentId}',
                                    style: const TextStyle(fontSize: 10, color: PadmaTheme.textMuted),
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                adminVM.toggleUserSuspension(u.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      !isSuspended ? '🚫 User ${u.name} suspended & blocked' : '✅ User ${u.name} unblocked',
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isSuspended ? PadmaTheme.successGreen : PadmaTheme.urgentRed,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                              ),
                              child: Text(
                                isSuspended ? 'Unblock' : 'Suspend',
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 3. Reported Content & Message Moderation
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
                                adminVM.deleteAnyMessage(rep.channelName, rep.id);
                                adminVM.resolveReport(rep.id, deleteMessage: true);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('🗑️ Message permanently deleted by Admin!')),
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
