import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme.dart';
import '../../auth/view_models/auth_view_model.dart';
import '../view_models/channels_view_model.dart';

class BusTelemetryChatView extends StatefulWidget {
  final VoidCallback onOpenDrawer;
  final String activeChannel;

  const BusTelemetryChatView({
    super.key,
    required this.onOpenDrawer,
    this.activeChannel = 'padma-1',
  });

  @override
  State<BusTelemetryChatView> createState() => _BusTelemetryChatViewState();
}

class _BusTelemetryChatViewState extends State<BusTelemetryChatView> {
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
    final isPadma2 = widget.activeChannel == 'padma-2' || widget.activeChannel == 'bus-2-uttara';

    final senderName = user?.name ?? 'Padma Student';
    final senderTag = user?.chatTag ?? 'Padma_CSE_4-1_Mirpur10';
    final senderRole = authVM.isAdmin ? 'Transport Admin' : 'Student';

    if (isPadma2) {
      channelsVM.sendPadma2Message(
        text,
        senderName: senderName,
        senderTag: senderTag,
        senderRole: senderRole,
      );
    } else {
      channelsVM.sendPadma1Message(
        text,
        senderName: senderName,
        senderTag: senderTag,
        senderRole: senderRole,
      );
    }
    _textController.clear();
  }

  void _insertMention(String tag) {
    final cur = _textController.text;
    _textController.text = '$cur@$tag ';
    _textController.selection = TextSelection.fromPosition(TextPosition(offset: _textController.text.length));
  }

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();
    final channelsVM = context.watch<ChannelsViewModel>();
    final isPadma2 = widget.activeChannel == 'padma-2' || widget.activeChannel == 'bus-2-uttara';
    final messages = isPadma2 ? channelsVM.padma2Messages : channelsVM.padma1Messages;
    final currentUserTag = authVM.currentUser?.chatTag ?? 'Padma_CSE_4-1_Mirpur10';

    final busTitle = isPadma2 ? 'Padma 2 (Uttara Route)' : 'Padma 1 (Mirpur Route)';
    final busSubtitle = isPadma2 ? 'Uttara • Airport • Banani • AUST' : 'Mirpur 12 • 10 • Agargaon • AUST';

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded),
          onPressed: widget.onOpenDrawer,
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            const Icon(Icons.directions_bus_rounded, size: 20, color: PadmaTheme.primaryTeal),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    busTitle,
                    style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    busSubtitle,
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
          // Live Telemetry GPS HUD
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            color: PadmaTheme.surfaceElevated,
            child: Row(
              children: [
                const Icon(Icons.satellite_alt_rounded, size: 16, color: PadmaTheme.successGreen),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isPadma2
                        ? 'Live GPS • Bus 2 at Airport Road Crossing (28 km/h)'
                        : 'Live GPS • Bus 1 at Mirpur 10 Stoppage (34 km/h)',
                    style: const TextStyle(fontSize: 11, color: PadmaTheme.textSecondary, fontWeight: FontWeight.w600),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: PadmaTheme.successGreen.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text('ON TIME', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: PadmaTheme.successGreen)),
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
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isMentioned
                        ? PadmaTheme.primaryTealContainer.withValues(alpha: 0.25)
                        : (msg.isTelemetry ? PadmaTheme.surfaceElevated : PadmaTheme.surface),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isMentioned
                          ? PadmaTheme.primaryTeal
                          : (msg.isTelemetry ? PadmaTheme.primaryTeal.withValues(alpha: 0.3) : PadmaTheme.borderLine),
                      width: isMentioned ? 1.5 : 0.8,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: msg.senderRole.contains('Admin')
                                  ? const Color(0xFF8B5CF6)
                                  : (msg.isTelemetry ? PadmaTheme.busAmber : PadmaTheme.primaryTeal),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                msg.avatarInitials ?? 'AU',
                                style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: Colors.white),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      msg.senderName,
                                      style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: PadmaTheme.textPrimary),
                                    ),
                                    const SizedBox(width: 6),
                                    if (msg.badgeText != null)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                        decoration: BoxDecoration(
                                          color: PadmaTheme.surfaceElevated,
                                          borderRadius: BorderRadius.circular(3),
                                        ),
                                        child: Text(
                                          msg.badgeText!,
                                          style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.w700, color: PadmaTheme.primaryTeal),
                                        ),
                                      ),
                                  ],
                                ),
                                if (msg.senderTag != null)
                                  Text(
                                    '@${msg.senderTag}',
                                    style: const TextStyle(fontSize: 10, color: PadmaTheme.primaryTeal, fontFamily: 'monospace', fontWeight: FontWeight.w600),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        msg.text,
                        style: const TextStyle(fontSize: 13, color: PadmaTheme.textPrimary, height: 1.35),
                      ),
                      const SizedBox(height: 8),

                      // Reactions
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          ...msg.reactions.map((r) => InkWell(
                                onTap: () => channelsVM.toggleReaction(msg, r.emoji),
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                                  decoration: BoxDecoration(
                                    color: r.isUserReacted ? PadmaTheme.primaryTealContainer.withValues(alpha: 0.3) : PadmaTheme.surfaceElevated,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: r.isUserReacted ? PadmaTheme.primaryTeal : PadmaTheme.borderLine,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(r.emoji, style: const TextStyle(fontSize: 12)),
                                      const SizedBox(width: 3),
                                      Text(
                                        '${r.count}',
                                        style: TextStyle(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w700,
                                          color: r.isUserReacted ? PadmaTheme.primaryTeal : PadmaTheme.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )),
                          PopupMenuButton<String>(
                            tooltip: 'Add reaction',
                            icon: const Icon(Icons.add_reaction_outlined, size: 15, color: PadmaTheme.textMuted),
                            padding: EdgeInsets.zero,
                            itemBuilder: (_) => ['👍', '❤️', '💺', '🚌', '🚦', '🔥']
                                .map((emoji) => PopupMenuItem(value: emoji, child: Text(emoji, style: const TextStyle(fontSize: 16))))
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

          // Mention suggestions bar
          Container(
            height: 34,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            color: PadmaTheme.surfaceElevated,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                const Center(child: Text('Mention: ', style: TextStyle(fontSize: 10, color: PadmaTheme.textMuted))),
                InkWell(
                  onTap: () => _insertMention('Padma_CSE_4-1_Mirpur10'),
                  child: const Chip(
                    label: Text('@Padma_CSE_4-1_Mirpur10', style: TextStyle(fontSize: 9.5, color: PadmaTheme.primaryTeal)),
                    padding: EdgeInsets.zero,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    backgroundColor: PadmaTheme.surface,
                  ),
                ),
                const SizedBox(width: 6),
                InkWell(
                  onTap: () => _insertMention('Tanvir_CSE_4-1_Mirpur10'),
                  child: const Chip(
                    label: Text('@Tanvir_CSE_4-1_Mirpur10', style: TextStyle(fontSize: 9.5, color: PadmaTheme.primaryTeal)),
                    padding: EdgeInsets.zero,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    backgroundColor: PadmaTheme.surface,
                  ),
                ),
                const SizedBox(width: 6),
                InkWell(
                  onTap: () => _insertMention('Rafiq_Transport_Staff_Mirpur12'),
                  child: const Chip(
                    label: Text('@Rafiq_Transport_Staff_Mirpur12', style: TextStyle(fontSize: 9.5, color: Color(0xFF8B5CF6))),
                    padding: EdgeInsets.zero,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    backgroundColor: PadmaTheme.surface,
                  ),
                ),
              ],
            ),
          ),

          // Message Composer (Both User & Admin can send)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: const BoxDecoration(
              color: PadmaTheme.surface,
              border: Border(top: BorderSide(color: PadmaTheme.borderLine)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    style: const TextStyle(fontSize: 13.5, color: PadmaTheme.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Message $busTitle...',
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
            ),
          ),
        ],
      ),
    );
  }
}
