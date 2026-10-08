import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/theme.dart';
import '../view_models/channels_view_model.dart';

class GeneralChatView extends StatefulWidget {
  final VoidCallback onOpenDrawer;

  const GeneralChatView({super.key, required this.onOpenDrawer});

  @override
  State<GeneralChatView> createState() => _GeneralChatViewState();
}

class _GeneralChatViewState extends State<GeneralChatView> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final channelsVM = context.read<ChannelsViewModel>();
    channelsVM.sendGeneralMessage(_textController.text);
    _textController.clear();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final channelsVM = context.watch<ChannelsViewModel>();
    final messages = channelsVM.generalMessages;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded),
          onPressed: widget.onOpenDrawer,
        ),
        titleSpacing: 0,
        title: const Row(
          children: [
            Icon(Icons.tag_rounded, size: 20, color: PadmaTheme.textMuted),
            SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('general', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                Text('AUST Campus transit discussions', style: TextStyle(fontSize: 10, color: PadmaTheme.textMuted)),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Chat Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final timeFormatted = DateFormat('hh:mm a').format(msg.timestamp);
                final isAdminMsg = msg.isTelemetry || msg.senderRole.toLowerCase().contains('admin');

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: isAdminMsg ? const EdgeInsets.all(12) : EdgeInsets.zero,
                  decoration: isAdminMsg
                      ? BoxDecoration(
                          color: PadmaTheme.surfaceElevated,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: PadmaTheme.primaryTeal.withValues(alpha: 0.5)),
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
                            msg.avatarInitials ?? (isAdminMsg ? 'ADM' : 'AU'),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: isAdminMsg ? PadmaTheme.primaryTeal : PadmaTheme.primaryTeal,
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
                                      color: isAdminMsg ? PadmaTheme.primaryTealContainer : PadmaTheme.primaryTealContainer,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      msg.badgeText ?? 'OFFICIAL ALERT',
                                      style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: PadmaTheme.primaryTeal),
                                    ),
                                  ),
                                const Spacer(),
                                Text(
                                  timeFormatted,
                                  style: const TextStyle(fontSize: 10, color: PadmaTheme.textMuted),
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
                                fontWeight: isAdminMsg ? FontWeight.w600 : FontWeight.normal,
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

          // Message Input Field
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
                      border: Border.all(color: PadmaTheme.borderLine),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _textController,
                            onSubmitted: (_) => _sendMessage(),
                            style: const TextStyle(fontSize: 13.5, color: PadmaTheme.textPrimary),
                            decoration: const InputDecoration(
                              hintText: 'Message #general...',
                              hintStyle: TextStyle(fontSize: 13, color: PadmaTheme.textMuted),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(vertical: 10),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline_rounded, size: 20, color: PadmaTheme.textMuted),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send_rounded, color: PadmaTheme.primaryTeal),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
