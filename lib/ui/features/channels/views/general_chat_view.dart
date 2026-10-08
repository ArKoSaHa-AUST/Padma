import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme.dart';
import '../../auth/view_models/auth_view_model.dart';
import '../view_models/channels_view_model.dart';

class GeneralChatView extends StatefulWidget {
  final VoidCallback onOpenDrawer;
  final String activeChannel;

  const GeneralChatView({
    super.key,
    required this.onOpenDrawer,
    this.activeChannel = 'rules-and-regulation',
  });

  @override
  State<GeneralChatView> createState() => _GeneralChatViewState();
}

class _GeneralChatViewState extends State<GeneralChatView> {
  final TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _sendMessage(BuildContext context) {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    final authVM = context.read<AuthViewModel>();
    final channelsVM = context.read<ChannelsViewModel>();
    final user = authVM.currentUser;
    final isAdmin = authVM.isAdmin;

    if (widget.activeChannel == 'announcements') {
      if (isAdmin) {
        channelsVM.sendAnnouncementMessage(
          text,
          senderName: user?.name ?? 'Transport Admin',
          senderTag: user?.chatTag ?? 'Admin_Transport_Staff_Campus',
          isAdmin: true,
        );
      }
    } else {
      if (isAdmin) {
        channelsVM.sendRulesMessage(
          text,
          senderName: user?.name ?? 'Transport Admin',
          senderTag: user?.chatTag ?? 'Admin_Transport_Staff_Campus',
          isAdmin: true,
        );
      }
    }
    _textController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();
    final channelsVM = context.watch<ChannelsViewModel>();
    final isAnnouncements = widget.activeChannel == 'announcements';
    final messages = isAnnouncements ? channelsVM.announcementsMessages : channelsVM.rulesMessages;
    final isAdmin = authVM.isAdmin;
    final currentUserTag = authVM.currentUser?.chatTag ?? '';

    final channelTitle = isAnnouncements ? 'announcements' : 'Rules and Regulation';
    final channelSubtitle = isAnnouncements
        ? 'Official Transport Announcements'
        : 'Official Campus Transit Rules & Code of Conduct';

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded),
          onPressed: widget.onOpenDrawer,
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            Icon(
              isAnnouncements ? Icons.campaign_rounded : Icons.gavel_rounded,
              size: 20,
              color: isAnnouncements ? const Color(0xFF8B5CF6) : PadmaTheme.primaryTeal,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    channelTitle,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    channelSubtitle,
                    style: const TextStyle(fontSize: 10, color: PadmaTheme.textMuted),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Role notice banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            color: PadmaTheme.surfaceElevated,
            child: Row(
              children: [
                Icon(
                  Icons.verified_user_rounded,
                  size: 16,
                  color: isAnnouncements ? const Color(0xFF8B5CF6) : PadmaTheme.primaryTeal,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isAnnouncements
                        ? '📢 Announcements: Only Transport Admin can broadcast. Students can react.'
                        : '📜 Rules & Regulations: Transport Administration directives. Students can react.',
                    style: const TextStyle(fontSize: 11, color: PadmaTheme.textSecondary, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),

          // Messages stream
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final isMentioned = currentUserTag.isNotEmpty && msg.mentionsTag(currentUserTag);

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isMentioned ? PadmaTheme.primaryTealContainer.withValues(alpha: 0.25) : PadmaTheme.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isMentioned ? PadmaTheme.primaryTeal : PadmaTheme.borderLine,
                      width: isMentioned ? 1.5 : 0.8,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: isAnnouncements ? const Color(0xFF8B5CF6) : PadmaTheme.primaryTeal,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                msg.avatarInitials ?? 'AD',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white),
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
                                      msg.senderName,
                                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: PadmaTheme.textPrimary),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        msg.badgeText ?? 'ADMIN',
                                        style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.w800, color: Color(0xFF8B5CF6)),
                                      ),
                                    ),
                                  ],
                                ),
                                if (msg.senderTag != null)
                                  Text(
                                    '@${msg.senderTag}',
                                    style: const TextStyle(fontSize: 10, color: PadmaTheme.primaryTeal, fontFamily: 'monospace'),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        msg.text,
                        style: const TextStyle(fontSize: 13.5, color: PadmaTheme.textPrimary, height: 1.4),
                      ),
                      const SizedBox(height: 10),

                      // Reactions Row
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          ...msg.reactions.map((r) => InkWell(
                                onTap: () => channelsVM.toggleReaction(msg, r.emoji),
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: r.isUserReacted ? PadmaTheme.primaryTealContainer.withValues(alpha: 0.3) : PadmaTheme.surfaceElevated,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: r.isUserReacted ? PadmaTheme.primaryTeal : PadmaTheme.borderLine,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(r.emoji, style: const TextStyle(fontSize: 13)),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${r.count}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: r.isUserReacted ? PadmaTheme.primaryTeal : PadmaTheme.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )),
                          // Quick React Buttons
                          PopupMenuButton<String>(
                            tooltip: 'Add reaction',
                            icon: const Icon(Icons.add_reaction_outlined, size: 16, color: PadmaTheme.textMuted),
                            padding: EdgeInsets.zero,
                            itemBuilder: (_) => ['👍', '❤️', '🚌', '👏', '🔥', '✅']
                                .map((emoji) => PopupMenuItem(
                                      value: emoji,
                                      child: Text(emoji, style: const TextStyle(fontSize: 18)),
                                    ))
                                .toList(),
                            onSelected: (emoji) => channelsVM.toggleReaction(msg, emoji),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Message Composer (Enabled for Admin, informative notice for students)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: const BoxDecoration(
              color: PadmaTheme.surface,
              border: Border(top: BorderSide(color: PadmaTheme.borderLine)),
            ),
            child: isAdmin
                ? Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _textController,
                          style: const TextStyle(fontSize: 13.5, color: PadmaTheme.textPrimary),
                          decoration: InputDecoration(
                            hintText: isAnnouncements
                                ? 'Broadcast official announcement...'
                                : 'Publish new Rule or Regulation...',
                            hintStyle: const TextStyle(fontSize: 12.5, color: PadmaTheme.textMuted),
                            filled: true,
                            fillColor: PadmaTheme.surfaceElevated,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: PadmaTheme.borderLine)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: PadmaTheme.borderLine)),
                          ),
                          onSubmitted: (_) => _sendMessage(context),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        style: IconButton.styleFrom(
                          backgroundColor: PadmaTheme.primaryTeal,
                          foregroundColor: PadmaTheme.onPrimary,
                        ),
                        icon: const Icon(Icons.send_rounded, size: 18),
                        onPressed: () => _sendMessage(context),
                      ),
                    ],
                  )
                : Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Center(
                      child: Text(
                        isAnnouncements
                            ? '🔒 Only Transport Admin can post announcements. Tap emoji to react!'
                            : '🔒 Only Transport Administration can post Rules and Regulations.',
                        style: const TextStyle(fontSize: 11.5, color: PadmaTheme.textMuted, fontStyle: FontStyle.italic),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
