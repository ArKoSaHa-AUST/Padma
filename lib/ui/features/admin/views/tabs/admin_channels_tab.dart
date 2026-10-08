import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme.dart';
import '../../../channels/view_models/channels_view_model.dart';
import '../../view_models/admin_view_model.dart';
import '../widgets/short_message_modal.dart';

class AdminChannelsTab extends StatefulWidget {
  const AdminChannelsTab({super.key});

  @override
  State<AdminChannelsTab> createState() => _AdminChannelsTabState();
}

class _AdminChannelsTabState extends State<AdminChannelsTab> {
  String _selectedChannel = 'general';
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, dynamic>> _channels = [
    {
      'id': 'general',
      'name': 'general',
      'title': '#general',
      'category': 'Campus Community',
      'icon': Icons.tag_rounded,
      'color': PadmaTheme.primaryTeal,
      'description': 'Main public student transit channel',
      'members': '248 Online',
    },
    {
      'id': 'announcements',
      'name': 'announcements',
      'title': '#announcements',
      'category': 'Campus Community',
      'icon': Icons.campaign_rounded,
      'color': const Color(0xFF8B5CF6),
      'description': 'Official university announcements & transport alerts',
      'members': 'All Students',
    },
    {
      'id': 'bus-1-mirpur',
      'name': 'bus-1-mirpur',
      'title': '#bus-1-mirpur',
      'category': 'Bus Telemetry',
      'icon': Icons.alt_route_rounded,
      'color': PadmaTheme.busAmber,
      'description': 'Padma 1 (Mirpur 12 ➔ AUST Campus)',
      'members': '142 Commuters',
    },
    {
      'id': 'bus-2-uttara',
      'name': 'bus-2-uttara',
      'title': '#bus-2-uttara',
      'category': 'Bus Telemetry',
      'icon': Icons.alt_route_rounded,
      'color': PadmaTheme.busAmber,
      'description': 'Padma 2 (Uttara House Building ➔ AUST Campus)',
      'members': '98 Commuters',
    },
    {
      'id': 'emergency-blood',
      'name': 'emergency-blood',
      'title': '#emergency-blood',
      'category': 'Student Assistance',
      'icon': Icons.bloodtype_rounded,
      'color': PadmaTheme.urgentRed,
      'description': 'Urgent blood donor dispatch & medical emergency',
      'members': '34 Donors',
    },
    {
      'id': 'ride-share',
      'name': 'ride-share',
      'title': '#ride-share',
      'category': 'Student Assistance',
      'icon': Icons.two_wheeler_rounded,
      'color': PadmaTheme.primaryTeal,
      'description': 'Student carpool & route matching',
      'members': '56 Active',
    },
  ];

  @override
  void dispose() {
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage({String? customText}) {
    final text = customText ?? _msgController.text;
    if (text.trim().isEmpty) return;

    final channelsVM = context.read<ChannelsViewModel>();
    channelsVM.broadcastDispatchMessage(
      _selectedChannel,
      text.trim(),
      senderName: 'Padma Dispatch Control (Admin)',
      senderRole: 'Transport Admin',
      badgeText: 'OFFICIAL ADMIN',
    );

    _msgController.clear();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Official message dispatched to #$_selectedChannel'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _openShortMessageDialog(AdminViewModel adminVM) {
    final defaultBus = (_selectedChannel == 'bus-2-uttara') ? adminVM.fleet.last : adminVM.fleet.first;
    ShortMessageModal.show(context, bus: defaultBus);
  }

  @override
  Widget build(BuildContext context) {
    final channelsVM = context.watch<ChannelsViewModel>();
    final adminVM = context.watch<AdminViewModel>();

    final currentChannelInfo = _channels.firstWhere(
      (c) => c['id'] == _selectedChannel,
      orElse: () => _channels.first,
    );

    final messages = channelsVM.getMessagesForChannel(_selectedChannel);

    return Column(
      children: [
        // 1. All Channels Carousel / Selector
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: const BoxDecoration(
            color: PadmaTheme.surface,
            border: Border(bottom: BorderSide(color: PadmaTheme.borderLine)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'ALL CLIENT CHANNELS (ADMIN PORTAL)',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: PadmaTheme.textMuted, letterSpacing: 0.5),
                    ),
                    Text(
                      '6 Active Feeds',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: PadmaTheme.primaryTeal),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: _channels.map((channel) {
                    final isSelected = _selectedChannel == channel['id'];
                    final Color color = channel['color'];
                    final msgCount = channelsVM.getMessagesForChannel(channel['id']).length;

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: InkWell(
                        onTap: () => setState(() => _selectedChannel = channel['id']),
                        borderRadius: BorderRadius.circular(12),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? color.withValues(alpha: 0.18) : PadmaTheme.surfaceElevated,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? color : PadmaTheme.borderLine,
                              width: isSelected ? 1.6 : 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(channel['icon'], size: 16, color: isSelected ? color : PadmaTheme.textMuted),
                              const SizedBox(width: 6),
                              Text(
                                channel['title'],
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                  color: isSelected ? color : PadmaTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                decoration: BoxDecoration(
                                  color: isSelected ? color.withValues(alpha: 0.3) : PadmaTheme.surface,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '$msgCount',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: isSelected ? color : PadmaTheme.textMuted,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),

        // 2. Active Channel Control Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: const BoxDecoration(
            color: PadmaTheme.surfaceElevated,
            border: Border(bottom: BorderSide(color: PadmaTheme.borderLine)),
          ),
          child: Row(
            children: [
              Icon(currentChannelInfo['icon'], size: 18, color: currentChannelInfo['color']),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          currentChannelInfo['title'],
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: PadmaTheme.textPrimary),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: currentChannelInfo['color'].withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            currentChannelInfo['category'],
                            style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: currentChannelInfo['color']),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${currentChannelInfo['description']} • ${currentChannelInfo['members']}',
                      style: const TextStyle(fontSize: 11, color: PadmaTheme.textMuted),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Action buttons
              IconButton(
                icon: const Icon(Icons.quickreply_rounded, color: PadmaTheme.primaryTeal, size: 20),
                tooltip: 'Dispatch Short Wait Message',
                onPressed: () => _openShortMessageDialog(adminVM),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert_rounded, color: PadmaTheme.textMuted, size: 20),
                color: PadmaTheme.surface,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: PadmaTheme.borderLine)),
                onSelected: (val) {
                  if (val == 'clear') {
                    channelsVM.clearChannel(_selectedChannel);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Cleared all messages in #$_selectedChannel')),
                    );
                  } else if (val == 'lock') {
                    adminVM.toggleGeneralLock();
                  } else if (val == 'slow') {
                    adminVM.toggleSlowMode();
                  }
                },
                itemBuilder: (ctx) => [
                  const PopupMenuItem(
                    value: 'slow',
                    child: Row(
                      children: [
                        Icon(Icons.speed_rounded, size: 16, color: PadmaTheme.busAmber),
                        SizedBox(width: 8),
                        Text('Toggle Slow Mode (15s)', style: TextStyle(fontSize: 12.5)),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'lock',
                    child: Row(
                      children: [
                        Icon(Icons.lock_outline_rounded, size: 16, color: PadmaTheme.urgentRed),
                        SizedBox(width: 8),
                        Text('Toggle Channel Lock', style: TextStyle(fontSize: 12.5)),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'clear',
                    child: Row(
                      children: [
                        Icon(Icons.delete_sweep_rounded, size: 16, color: PadmaTheme.urgentRed),
                        SizedBox(width: 8),
                        Text('Purge Channel History', style: TextStyle(fontSize: 12.5, color: PadmaTheme.urgentRed)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // 3. Live Message Feed Stream
        Expanded(
          child: messages.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.chat_bubble_outline_rounded, size: 48, color: PadmaTheme.textMuted.withValues(alpha: 0.4)),
                      const SizedBox(height: 12),
                      Text(
                        'No messages in #$_selectedChannel yet',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: PadmaTheme.textMuted),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Broadcast the first official notice below',
                        style: TextStyle(fontSize: 12, color: PadmaTheme.textMuted),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final timeFormatted = DateFormat('hh:mm a').format(msg.timestamp);
                    final isAdminMsg = msg.isTelemetry || msg.senderRole.toLowerCase().contains('admin');

                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: isAdminMsg ? const EdgeInsets.all(12) : EdgeInsets.zero,
                      decoration: isAdminMsg
                          ? BoxDecoration(
                              color: PadmaTheme.surfaceElevated,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: PadmaTheme.primaryTeal.withValues(alpha: 0.4)),
                            )
                          : null,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: isAdminMsg
                                  ? PadmaTheme.primaryTeal.withValues(alpha: 0.2)
                                  : PadmaTheme.surfaceElevated,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isAdminMsg ? PadmaTheme.primaryTeal : PadmaTheme.borderLine,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                msg.avatarInitials ?? (isAdminMsg ? 'ADM' : 'ST'),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: isAdminMsg ? PadmaTheme.primaryTeal : PadmaTheme.textSecondary,
                                ),
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
                                    Text(
                                      msg.senderName,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: isAdminMsg ? PadmaTheme.primaryTeal : PadmaTheme.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    if (msg.badgeText != null || isAdminMsg)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                        decoration: BoxDecoration(
                                          color: isAdminMsg ? PadmaTheme.primaryTealContainer : PadmaTheme.surfaceElevated,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          msg.badgeText ?? 'OFFICIAL',
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w800,
                                            color: isAdminMsg ? PadmaTheme.primaryTeal : PadmaTheme.textMuted,
                                          ),
                                        ),
                                      ),
                                    const Spacer(),
                                    Text(
                                      timeFormatted,
                                      style: const TextStyle(fontSize: 10, color: PadmaTheme.textMuted),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline_rounded, size: 14, color: PadmaTheme.textMuted),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      onPressed: () {
                                        channelsVM.deleteMessage(_selectedChannel, msg.id);
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  msg.text,
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    color: isAdminMsg ? PadmaTheme.textPrimary : PadmaTheme.textSecondary,
                                    height: 1.35,
                                    fontWeight: isAdminMsg ? FontWeight.w500 : FontWeight.normal,
                                  ),
                                ),
                                if (msg.reactions.isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 4,
                                    children: msg.reactions.map((r) {
                                      return InkWell(
                                        onTap: () => channelsVM.toggleReaction(msg, r.emoji),
                                        borderRadius: BorderRadius.circular(8),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: r.isUserReacted ? PadmaTheme.primaryTealContainer : PadmaTheme.surfaceElevated,
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(
                                              color: r.isUserReacted ? PadmaTheme.primaryTeal : PadmaTheme.borderLine,
                                              width: 0.8,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(r.emoji, style: const TextStyle(fontSize: 12)),
                                              const SizedBox(width: 4),
                                              Text(
                                                '${r.count}',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                  color: r.isUserReacted ? PadmaTheme.primaryTeal : PadmaTheme.textSecondary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),

        // 4. Quick Snippets Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          color: PadmaTheme.surface,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildSnippetChip(
                  label: '⏱️ The bus will wait at mirpur 10 untill 12:30',
                  onTap: () => _sendMessage(customText: 'The bus will wait at mirpur 10 untill 12:30'),
                ),
                const SizedBox(width: 6),
                _buildSnippetChip(
                  label: '⏱️ The bus will wait at DSS untill 01:15',
                  onTap: () => _sendMessage(customText: 'The bus will wait at DSS untill 01:15'),
                ),
                const SizedBox(width: 6),
                _buildSnippetChip(
                  label: '🚦 Heavy traffic near Agargaon (+10m)',
                  onTap: () => _sendMessage(customText: '⚠️ Heavy traffic congestion reported near Agargaon. Bus 1 delayed by ~10 minutes.'),
                ),
                const SizedBox(width: 6),
                _buildSnippetChip(
                  label: '📍 Reached AUST Campus',
                  onTap: () => _sendMessage(customText: '📍 Bus has safely reached AUST Campus (Tejgaon). Trip completed.'),
                ),
              ],
            ),
          ),
        ),

        // 5. Admin Official Message Input Composer
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: const BoxDecoration(
            color: PadmaTheme.surface,
            border: Border(top: BorderSide(color: PadmaTheme.borderLine)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: PadmaTheme.surfaceElevated,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: PadmaTheme.primaryTeal.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _msgController,
                          onSubmitted: (_) => _sendMessage(),
                          style: const TextStyle(fontSize: 13.5, color: PadmaTheme.textPrimary),
                          decoration: InputDecoration(
                            hintText: 'Dispatch official admin message to #$_selectedChannel...',
                            hintStyle: const TextStyle(fontSize: 12.5, color: PadmaTheme.textMuted),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.flash_on_rounded, size: 18, color: PadmaTheme.busAmber),
                        tooltip: 'Fast Wait Message Modal',
                        onPressed: () => _openShortMessageDialog(adminVM),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.send_rounded, color: PadmaTheme.primaryTeal),
                tooltip: 'Send as Admin',
                onPressed: () => _sendMessage(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSnippetChip({required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: PadmaTheme.surfaceElevated,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: PadmaTheme.borderLine),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: PadmaTheme.textSecondary),
        ),
      ),
    );
  }
}
