import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme.dart';
import '../../../channels/view_models/channels_view_model.dart';
import '../../view_models/admin_view_model.dart';
import '../widgets/short_message_modal.dart';
import '../widgets/admin_3d_card.dart';

class AdminChannelsTab extends StatefulWidget {
  const AdminChannelsTab({super.key});

  @override
  State<AdminChannelsTab> createState() => _AdminChannelsTabState();
}

class _AdminChannelsTabState extends State<AdminChannelsTab> {
  String _selectedChannel = 'padma-1';
  final TextEditingController _msgController = TextEditingController();
  final TextEditingController _searchUserController = TextEditingController();
  final TextEditingController _dmReplyController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ScrollController _dmScrollController = ScrollController();

  final List<Map<String, dynamic>> _channels = [
    {
      'id': 'padma-1',
      'title': 'Padma 1',
      'category': 'Bus Telemetry',
      'icon': Icons.directions_bus_rounded,
      'color': PadmaTheme.busAmber,
      'description': 'Padma 1 (Mirpur 12 ➔ AUST Campus)',
      'members': '142 Commuters',
    },
    {
      'id': 'padma-2',
      'title': 'Padma 2',
      'category': 'Bus Telemetry',
      'icon': Icons.directions_bus_rounded,
      'color': PadmaTheme.busAmber,
      'description': 'Padma 2 (Uttara House Building ➔ AUST Campus)',
      'members': '98 Commuters',
    },
    {
      'id': 'announcements',
      'title': 'Announcements',
      'category': 'Official Broadcast',
      'icon': Icons.campaign_rounded,
      'color': const Color(0xFF8B5CF6),
      'description': 'Official university transport announcements (Admin only posting)',
      'members': 'All Students',
    },
    {
      'id': 'rules-and-regulation',
      'title': 'Rules & Regulations',
      'category': 'Campus Policy',
      'icon': Icons.gavel_rounded,
      'color': const Color(0xFF3B82F6),
      'description': 'Official transit rules & bus guidelines (Admin only posting)',
      'members': 'All Students',
    },
    {
      'id': 'blood-requests',
      'title': 'Blood Requests',
      'category': 'Emergency',
      'icon': Icons.water_drop_rounded,
      'color': PadmaTheme.urgentRed,
      'description': 'Student blood donor network & requests',
      'members': '34 Donors',
    },
    {
      'id': 'lost-found',
      'title': 'Lost & Found',
      'category': 'Assistance',
      'icon': Icons.inventory_2_rounded,
      'color': PadmaTheme.primaryTeal,
      'description': 'Student lost and found notices & claims',
      'members': '68 Items',
    },
    {
      'id': 'contact-user',
      'title': 'Contact User',
      'category': 'Direct Messenger',
      'icon': Icons.question_answer_rounded,
      'color': const Color(0xFF10B981),
      'description': '1-on-1 Admin to student inbox & search',
      'members': 'Direct Inbox',
    },
    {
      'id': 'student-complaints',
      'title': 'Submit Complain',
      'category': 'Grievances',
      'icon': Icons.feedback_rounded,
      'color': const Color(0xFFF59E0B),
      'description': 'Student submitted complaints & feedback triage',
      'members': 'Grievance Desk',
    },
  ];

  @override
  void dispose() {
    _msgController.dispose();
    _searchUserController.dispose();
    _dmReplyController.dispose();
    _scrollController.dispose();
    _dmScrollController.dispose();
    super.dispose();
  }

  void _sendMessage({String? customText}) {
    final text = customText ?? _msgController.text;
    if (text.trim().isEmpty) return;

    final channelsVM = context.read<ChannelsViewModel>();
    channelsVM.broadcastDispatchMessage(
      _selectedChannel,
      text.trim(),
      senderName: 'Padma Dispatch (Admin)',
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
    final defaultBus = (_selectedChannel == 'padma-2' || _selectedChannel == 'bus-2-uttara') ? adminVM.fleet.last : adminVM.fleet.first;
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

    final isLocked = adminVM.isChannelLocked(_selectedChannel);

    return Column(
      children: [
        // 1. Channels Top Navigation Ribbon
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: const BoxDecoration(
            color: PadmaTheme.surface,
            border: Border(bottom: BorderSide(color: PadmaTheme.borderLine)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'ADMIN CHANNELS & COMMUNICATIONS',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: PadmaTheme.textMuted, letterSpacing: 0.5),
                    ),
                    Text(
                      '${_channels.length} Channels',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: PadmaTheme.primaryTeal),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: _channels.map((channel) {
                    final isSelected = _selectedChannel == channel['id'];
                    final Color color = channel['color'];
                    final channelLocked = adminVM.isChannelLocked(channel['id']);

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: InkWell(
                        onTap: () => setState(() => _selectedChannel = channel['id']),
                        borderRadius: BorderRadius.circular(12),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
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
                              Icon(channel['icon'], size: 15, color: isSelected ? color : PadmaTheme.textMuted),
                              const SizedBox(width: 6),
                              Text(
                                channel['title'],
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                  color: isSelected ? color : PadmaTheme.textPrimary,
                                ),
                              ),
                              if (channelLocked) ...[
                                const SizedBox(width: 4),
                                const Icon(Icons.lock_rounded, size: 11, color: PadmaTheme.urgentRed),
                              ],
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
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
                          style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: PadmaTheme.textPrimary),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: currentChannelInfo['color'].withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            currentChannelInfo['category'],
                            style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: currentChannelInfo['color']),
                          ),
                        ),
                        if (isLocked) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: PadmaTheme.urgentRed.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text('LOCKED', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: PadmaTheme.urgentRed)),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      currentChannelInfo['description'],
                      style: const TextStyle(fontSize: 10.5, color: PadmaTheme.textMuted),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Action buttons
              if (_selectedChannel.startsWith('padma')) ...[
                IconButton(
                  icon: const Icon(Icons.quickreply_rounded, color: PadmaTheme.primaryTeal, size: 18),
                  tooltip: 'Dispatch Short Wait Message',
                  onPressed: () => _openShortMessageDialog(adminVM),
                ),
              ],
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert_rounded, color: PadmaTheme.textMuted, size: 18),
                color: PadmaTheme.surface,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: PadmaTheme.borderLine)),
                onSelected: (val) {
                  if (val == 'lock') {
                    adminVM.toggleChannelLock(_selectedChannel);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(adminVM.isChannelLocked(_selectedChannel) ? '🔒 Locked #${currentChannelInfo['title']}' : '🔓 Unlocked #${currentChannelInfo['title']}')),
                    );
                  } else if (val == 'clear') {
                    channelsVM.clearChannel(_selectedChannel);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Cleared all messages in #${currentChannelInfo['title']}')),
                    );
                  }
                },
                itemBuilder: (ctx) => [
                  PopupMenuItem(
                    value: 'lock',
                    child: Row(
                      children: [
                        Icon(isLocked ? Icons.lock_open_rounded : Icons.lock_outline_rounded, size: 16, color: isLocked ? PadmaTheme.successGreen : PadmaTheme.urgentRed),
                        const SizedBox(width: 8),
                        Text(isLocked ? 'Unlock Channel' : 'Lock Channel', style: const TextStyle(fontSize: 12.5)),
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

        // 3. Dynamic Channel Content Switcher
        Expanded(
          child: _buildChannelBody(context, adminVM, channelsVM),
        ),

        // 4. Bottom Composer (Only for chat channels: padma-1, padma-2, announcements, rules)
        if (_selectedChannel == 'padma-1' || _selectedChannel == 'padma-2' || _selectedChannel == 'announcements' || _selectedChannel == 'rules-and-regulation')
          _buildAdminComposer(context, adminVM),
      ],
    );
  }

  Widget _buildChannelBody(BuildContext context, AdminViewModel adminVM, ChannelsViewModel channelsVM) {
    if (_selectedChannel == 'contact-user') {
      return _buildContactUserView(context, adminVM);
    } else if (_selectedChannel == 'student-complaints') {
      return _buildComplaintsView(context, adminVM);
    } else if (_selectedChannel == 'blood-requests') {
      return _buildBloodRequestsView(context, channelsVM);
    } else if (_selectedChannel == 'lost-found') {
      return _buildLostFoundView(context, channelsVM);
    } else {
      return _buildMessageFeedView(context, adminVM, channelsVM);
    }
  }

  // --- 1-on-1 Contact User View with Messenger Autocomplete Search ---
  Widget _buildContactUserView(BuildContext context, AdminViewModel adminVM) {
    final activeUserId = adminVM.activeConversationUserId;
    final searchQuery = _searchUserController.text.trim();
    final matchingUsers = adminVM.searchUsers(searchQuery);

    if (activeUserId != null) {
      // Direct 1-on-1 Conversation View with Selected User
      final conversation = adminVM.userConversations.firstWhere(
        (c) => c.userId == activeUserId,
        orElse: () => AdminUserConversation(
          userId: activeUserId,
          userName: 'User $activeUserId',
          userEmail: '$activeUserId@aust.edu',
          studentId: activeUserId,
          lastMessage: '',
          lastMessageTime: DateTime.now(),
          messages: [],
        ),
      );

      return Column(
        children: [
          // Active User Top Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: const BoxDecoration(
              color: PadmaTheme.surface,
              border: Border(bottom: BorderSide(color: PadmaTheme.borderLine)),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_rounded, color: PadmaTheme.textPrimary, size: 20),
                  onPressed: () => adminVM.closeActiveConversation(),
                ),
                CircleAvatar(
                  radius: 18,
                  backgroundColor: PadmaTheme.primaryTeal.withValues(alpha: 0.2),
                  child: Text(
                    conversation.userName.substring(0, conversation.userName.length.clamp(1, 2)).toUpperCase(),
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: PadmaTheme.primaryTeal),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        conversation.userName,
                        style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: PadmaTheme.textPrimary),
                      ),
                      Text(
                        '${conversation.userEmail} • ID: ${conversation.studentId}',
                        style: const TextStyle(fontSize: 11, color: PadmaTheme.textMuted),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: PadmaTheme.successGreen.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.circle, size: 6, color: PadmaTheme.successGreen),
                      SizedBox(width: 4),
                      Text('Active', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: PadmaTheme.successGreen)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Message history
          Expanded(
            child: conversation.messages.isEmpty
                ? const Center(
                    child: Text('No direct messages yet. Send a message below.', style: TextStyle(color: PadmaTheme.textMuted)),
                  )
                : ListView.builder(
                    controller: _dmScrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    itemCount: conversation.messages.length,
                    itemBuilder: (context, index) {
                      final msg = conversation.messages[index];
                      final isMe = msg.isAdmin;

                      return Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                          decoration: BoxDecoration(
                            color: isMe ? PadmaTheme.primaryTeal : PadmaTheme.surfaceElevated,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: isMe ? PadmaTheme.primaryTeal : PadmaTheme.borderLine),
                          ),
                          child: Column(
                            crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                            children: [
                              Text(
                                msg.text,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isMe ? PadmaTheme.onPrimary : PadmaTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                DateFormat('hh:mm a').format(msg.timestamp),
                                style: TextStyle(
                                  fontSize: 9.5,
                                  color: isMe ? PadmaTheme.onPrimary.withValues(alpha: 0.7) : PadmaTheme.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // Admin Reply Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: const BoxDecoration(
              color: PadmaTheme.surface,
              border: Border(top: BorderSide(color: PadmaTheme.borderLine)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _dmReplyController,
                    onSubmitted: (_) {
                      adminVM.sendDirectMessageToUser(
                        targetUserId: activeUserId,
                        text: _dmReplyController.text,
                      );
                      _dmReplyController.clear();
                    },
                    style: const TextStyle(fontSize: 13, color: PadmaTheme.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Reply to ${conversation.userName}...',
                      hintStyle: const TextStyle(fontSize: 12, color: PadmaTheme.textMuted),
                      filled: true,
                      fillColor: PadmaTheme.surfaceElevated,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: PadmaTheme.borderLine)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: PadmaTheme.borderLine)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: PadmaTheme.primaryTeal)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: () {
                    adminVM.sendDirectMessageToUser(
                      targetUserId: activeUserId,
                      text: _dmReplyController.text,
                    );
                    _dmReplyController.clear();
                  },
                  icon: const Icon(Icons.send_rounded, size: 18),
                  style: IconButton.styleFrom(backgroundColor: PadmaTheme.primaryTeal, foregroundColor: PadmaTheme.onPrimary),
                ),
              ],
            ),
          ),
        ],
      );
    }

    // Default: Inbox List with Messenger Search & Autocomplete
    return Column(
      children: [
        // Messenger Search Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          color: PadmaTheme.surface,
          child: TextField(
            controller: _searchUserController,
            onChanged: (_) => setState(() {}),
            style: const TextStyle(fontSize: 13, color: PadmaTheme.textPrimary),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search_rounded, size: 20, color: PadmaTheme.primaryTeal),
              hintText: 'Search user by name (User 1, User 11, etc.) or email...',
              hintStyle: const TextStyle(fontSize: 12, color: PadmaTheme.textMuted),
              suffixIcon: searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close_rounded, size: 16),
                      onPressed: () {
                        _searchUserController.clear();
                        setState(() {});
                      },
                    )
                  : null,
              filled: true,
              fillColor: PadmaTheme.surfaceElevated,
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: PadmaTheme.borderLine)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: PadmaTheme.borderLine)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: PadmaTheme.primaryTeal)),
            ),
          ),
        ),

        // If searching, show Autocomplete suggestions
        if (searchQuery.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            alignment: Alignment.centerLeft,
            color: PadmaTheme.surfaceElevated,
            child: Text(
              'SEARCH RESULTS (${matchingUsers.length})',
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: PadmaTheme.primaryTeal),
            ),
          ),
          Expanded(
            child: matchingUsers.isEmpty
                ? const Center(
                    child: Text('No users match your search query', style: TextStyle(color: PadmaTheme.textMuted)),
                  )
                : ListView.builder(
                    itemCount: matchingUsers.length,
                    itemBuilder: (context, idx) {
                      final u = matchingUsers[idx];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: PadmaTheme.primaryTeal.withValues(alpha: 0.2),
                          child: Text(
                            u.name.substring(0, u.name.length.clamp(1, 2)).toUpperCase(),
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: PadmaTheme.primaryTeal),
                          ),
                        ),
                        title: Text(u.name, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: PadmaTheme.textPrimary)),
                        subtitle: Text('${u.email} • ID: ${u.studentId}', style: const TextStyle(fontSize: 11, color: PadmaTheme.textMuted)),
                        trailing: const Icon(Icons.chat_bubble_outline_rounded, size: 18, color: PadmaTheme.primaryTeal),
                        onTap: () {
                          _searchUserController.clear();
                          adminVM.selectConversationUser(u.id);
                        },
                      );
                    },
                  ),
          ),
        ] else ...[
          // Standard Inbox List of active conversations
          Expanded(
            child: adminVM.userConversations.isEmpty
                ? const Center(child: Text('No active student inboxes', style: TextStyle(color: PadmaTheme.textMuted)))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    itemCount: adminVM.userConversations.length,
                    itemBuilder: (context, index) {
                      final conv = adminVM.userConversations[index];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: PadmaTheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: PadmaTheme.borderLine),
                        ),
                        child: ListTile(
                          onTap: () => adminVM.selectConversationUser(conv.userId),
                          leading: CircleAvatar(
                            backgroundColor: PadmaTheme.primaryTeal.withValues(alpha: 0.2),
                            child: Text(
                              conv.userName.substring(0, conv.userName.length.clamp(1, 2)).toUpperCase(),
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: PadmaTheme.primaryTeal),
                            ),
                          ),
                          title: Row(
                            children: [
                              Text(conv.userName, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: PadmaTheme.textPrimary)),
                              const Spacer(),
                              Text(
                                DateFormat('hh:mm a').format(conv.lastMessageTime),
                                style: const TextStyle(fontSize: 10, color: PadmaTheme.textMuted),
                              ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 2),
                              Text(
                                conv.lastMessage,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 12, color: PadmaTheme.textSecondary),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${conv.userEmail} • ID: ${conv.studentId}',
                                style: const TextStyle(fontSize: 10, color: PadmaTheme.textMuted),
                              ),
                            ],
                          ),
                          trailing: conv.unreadCount > 0
                              ? Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(
                                    color: PadmaTheme.primaryTeal,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    '${conv.unreadCount}',
                                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: PadmaTheme.onPrimary),
                                  ),
                                )
                              : const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: PadmaTheme.textMuted),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ],
    );
  }

  // --- Student Complaints & Grievance Desk View ---
  Widget _buildComplaintsView(BuildContext context, AdminViewModel adminVM) {
    if (adminVM.complaints.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline_rounded, size: 48, color: PadmaTheme.successGreen.withValues(alpha: 0.6)),
            const SizedBox(height: 12),
            const Text('No Student Complaints', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: PadmaTheme.textPrimary)),
            const Text('No grievances have been submitted.', style: TextStyle(fontSize: 12, color: PadmaTheme.textMuted)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: adminVM.complaints.length,
      itemBuilder: (context, index) {
        final cmp = adminVM.complaints[index];

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: Admin3dCard(
            borderColor: cmp.status == 'Resolved' ? PadmaTheme.successGreen.withValues(alpha: 0.4) : PadmaTheme.borderLine,
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: cmp.status == 'Resolved'
                            ? PadmaTheme.successGreen.withValues(alpha: 0.15)
                            : (cmp.status == 'Under Review' ? PadmaTheme.busAmber.withValues(alpha: 0.15) : PadmaTheme.surfaceElevated),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: cmp.status == 'Resolved'
                              ? PadmaTheme.successGreen
                              : (cmp.status == 'Under Review' ? PadmaTheme.busAmber : PadmaTheme.borderLine),
                        ),
                      ),
                      child: Text(
                        cmp.status.toUpperCase(),
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: cmp.status == 'Resolved'
                              ? PadmaTheme.successGreen
                              : (cmp.status == 'Under Review' ? PadmaTheme.busAmber : PadmaTheme.textSecondary),
                        ),
                      ),
                    ),
                    Text(
                      DateFormat('MMM dd, hh:mm a').format(cmp.submittedAt),
                      style: const TextStyle(fontSize: 10, color: PadmaTheme.textMuted),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  cmp.title,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: PadmaTheme.textPrimary),
                ),
                const SizedBox(height: 4),
                Text(
                  cmp.body,
                  style: const TextStyle(fontSize: 12.5, color: PadmaTheme.textSecondary, height: 1.35),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: PadmaTheme.surfaceElevated,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.person_pin_rounded, size: 14, color: PadmaTheme.primaryTeal),
                      const SizedBox(width: 6),
                      Text(
                        '${cmp.studentName} (${cmp.studentId}) • ${cmp.department} • ${cmp.pickupDestination}',
                        style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: PadmaTheme.textPrimary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => adminVM.updateComplaintStatus(cmp.id, 'Under Review'),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: PadmaTheme.borderLine),
                          padding: const EdgeInsets.symmetric(vertical: 6),
                        ),
                        child: const Text('Mark Under Review', style: TextStyle(fontSize: 10.5)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => adminVM.updateComplaintStatus(cmp.id, 'Resolved'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: PadmaTheme.successGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 6),
                        ),
                        child: const Text('Resolve', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700)),
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

  // --- Blood Requests View ---
  Widget _buildBloodRequestsView(BuildContext context, ChannelsViewModel channelsVM) {
    if (channelsVM.bloodRequests.isEmpty) {
      return const Center(child: Text('No active blood requests', style: TextStyle(color: PadmaTheme.textMuted)));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: channelsVM.bloodRequests.length,
      itemBuilder: (context, idx) {
        final r = channelsVM.bloodRequests[idx];
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
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: PadmaTheme.urgentRed.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        r.bloodGroup,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: PadmaTheme.urgentRed),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(r.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: PadmaTheme.textPrimary)),
                          Text(r.hospitalName, style: const TextStyle(fontSize: 11, color: PadmaTheme.textSecondary)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Contact: ${r.contactNumber} • By ${r.requesterName}', style: const TextStyle(fontSize: 11, color: PadmaTheme.textMuted)),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- Lost & Found View ---
  Widget _buildLostFoundView(BuildContext context, ChannelsViewModel channelsVM) {
    if (channelsVM.lostFoundItems.isEmpty) {
      return const Center(child: Text('No lost & found notices', style: TextStyle(color: PadmaTheme.textMuted)));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: channelsVM.lostFoundItems.length,
      itemBuilder: (context, idx) {
        final lf = channelsVM.lostFoundItems[idx];
        final isLost = lf.type.name.toLowerCase().contains('lost');

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: Admin3dCard(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isLost ? PadmaTheme.urgentRed.withValues(alpha: 0.15) : PadmaTheme.successGreen.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        isLost ? 'LOST' : 'FOUND',
                        style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: isLost ? PadmaTheme.urgentRed : PadmaTheme.successGreen),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(lf.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: PadmaTheme.textPrimary)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(lf.description, style: const TextStyle(fontSize: 12, color: PadmaTheme.textSecondary)),
                const SizedBox(height: 6),
                Text('Location: ${lf.location ?? 'Campus'} • Posted by ${lf.authorName}', style: const TextStyle(fontSize: 10.5, color: PadmaTheme.textMuted)),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- Live Chat Feed for Padma 1, Padma 2, Announcements, Rules ---
  Widget _buildMessageFeedView(BuildContext context, AdminViewModel adminVM, ChannelsViewModel channelsVM) {
    final messages = channelsVM.getMessagesForChannel(_selectedChannel);

    if (messages.isEmpty) {
      return Center(
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
      );
    }

    return ListView.builder(
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
                  color: isAdminMsg ? PadmaTheme.primaryTeal.withValues(alpha: 0.2) : PadmaTheme.surfaceElevated,
                  shape: BoxShape.circle,
                  border: Border.all(color: isAdminMsg ? PadmaTheme.primaryTeal : PadmaTheme.borderLine),
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
                        Text(timeFormatted, style: const TextStyle(fontSize: 10, color: PadmaTheme.textMuted)),
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, size: 14, color: PadmaTheme.textMuted),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          tooltip: 'Delete Message (Admin)',
                          onPressed: () {
                            channelsVM.deleteMessage(_selectedChannel, msg.id);
                            adminVM.deleteAnyMessage(_selectedChannel, msg.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('🗑️ Message deleted from channel.')),
                            );
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
    );
  }

  // --- Admin Message Composer ---
  Widget _buildAdminComposer(BuildContext context, AdminViewModel adminVM) {
    return Container(
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
                  if (_selectedChannel.startsWith('padma'))
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
    );
  }
}
