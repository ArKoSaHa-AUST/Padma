import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class MessageComposer extends StatefulWidget {
  final bool isReadOnly;
  final String readOnlyText;
  final void Function(String text)? onSend;
  final VoidCallback? onAttachmentTap;
  final VoidCallback? onEmojiTap;
  final String? replyToSenderName;
  final String? replyToText;
  final VoidCallback? onCancelReply;

  const MessageComposer({
    super.key,
    this.isReadOnly = false,
    this.readOnlyText = 'Only admins can post here',
    this.onSend,
    this.onAttachmentTap,
    this.onEmojiTap,
    this.replyToSenderName,
    this.replyToText,
    this.onCancelReply,
  });

  @override
  State<MessageComposer> createState() => _MessageComposerState();
}

class _MessageComposerState extends State<MessageComposer> {
  final TextEditingController _controller = TextEditingController();
  bool _canSend = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final canSend = _controller.text.trim().isNotEmpty;
    if (canSend != _canSend) {
      setState(() => _canSend = canSend);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.onSend?.call(text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface2 : AppColors.lightSurface2;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textMuted = isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

    // Locked read-only state for students
    if (widget.isReadOnly) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurfaceRail : AppColors.lightSurface2,
          border: Border(top: BorderSide(color: borderColor)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline_rounded, size: 16, color: textMuted),
            const SizedBox(width: 8),
            Text(
              widget.readOnlyText,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: textMuted,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBgBase : AppColors.lightBgBase,
        border: Border(top: BorderSide(color: borderColor)),
      ),
      padding: EdgeInsets.only(
        left: 12,
        right: 12,
        top: 8,
        bottom: MediaQuery.of(context).viewInsets.bottom + 8,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Replying banner if set
          if (widget.replyToSenderName != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              margin: const EdgeInsets.only(bottom: 6),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(8),
                border: Border(
                  left: BorderSide(
                    color: isDark ? AppColors.darkSecondary : AppColors.lightSecondary,
                    width: 3,
                  ),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.reply_rounded, size: 14, color: AppColors.darkSecondary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Replying to ${widget.replyToSenderName}',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textPrimary),
                    ),
                  ),
                  GestureDetector(
                    onTap: widget.onCancelReply,
                    child: Icon(Icons.close_rounded, size: 16, color: textMuted),
                  ),
                ],
              ),
            ),
          ],

          // Input Row
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.add_circle_outline_rounded, size: 22),
                color: textMuted,
                onPressed: widget.onAttachmentTap,
                tooltip: 'Attach Photo',
              ),
              IconButton(
                icon: const Icon(Icons.sentiment_satisfied_alt_rounded, size: 22),
                color: textMuted,
                onPressed: widget.onEmojiTap,
                tooltip: 'Insert Emoji',
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: borderColor),
                  ),
                  child: TextField(
                    controller: _controller,
                    maxLines: 4,
                    minLines: 1,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _handleSend(),
                    style: TextStyle(fontSize: 14.5, color: textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      hintStyle: TextStyle(fontSize: 14, color: textMuted),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              CircleAvatar(
                radius: 20,
                backgroundColor: _canSend
                    ? AppColors.darkPrimary
                    : (isDark ? AppColors.darkSurface2 : AppColors.lightSurface2),
                child: IconButton(
                  icon: Icon(
                    Icons.send_rounded,
                    size: 18,
                    color: _canSend
                        ? AppColors.darkOnPrimary
                        : textMuted.withValues(alpha: 0.4),
                  ),
                  onPressed: _canSend ? _handleSend : null,
                  tooltip: 'Send',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
