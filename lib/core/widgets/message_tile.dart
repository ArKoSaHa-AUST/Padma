import 'package:flutter/material.dart';
import '../../data/models/message_model.dart';
import '../../data/models/user_model.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../utils/formatters.dart';
import 'role_badge.dart';

class MessageTile extends StatelessWidget {
  final MessageModel message;
  final String currentUserId;
  final void Function(String emoji)? onReactionTap;
  final VoidCallback? onReplyTap;

  const MessageTile({
    super.key,
    required this.message,
    required this.currentUserId,
    this.onReactionTap,
    this.onReplyTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textMuted = isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted;
    final surfaceColor = isDark ? AppColors.darkSurface1 : AppColors.lightSurface1;

    final isAdmin = message.senderRole == UserRole.admin;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: message.isUrgent
            ? AppColors.dangerSurface(isDark)
            : (isAdmin ? AppColors.adminSurface(isDark) : surfaceColor),
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: isAdmin
              ? const BorderSide(color: AppColors.adminBadge, width: 3.5)
              : BorderSide(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  width: 1,
                ),
          top: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
          right: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
          bottom: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pinned or Urgent Indicator Banner
          if (message.isPinned || message.isUrgent)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  if (message.isPinned) ...[
                    const Icon(Icons.push_pin_rounded, size: 13, color: AppColors.adminBadge),
                    const SizedBox(width: 4),
                    const Text(
                      'Pinned Announcement',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.adminBadge,
                      ),
                    ),
                  ],
                  if (message.isPinned && message.isUrgent)
                    const Text(' • ', style: TextStyle(color: AppColors.danger, fontSize: 11)),
                  if (message.isUrgent) ...[
                    const Icon(Icons.warning_amber_rounded, size: 13, color: AppColors.danger),
                    const SizedBox(width: 4),
                    const Text(
                      'Urgent Alert',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.danger,
                      ),
                    ),
                  ],
                ],
              ),
            ),

          // Reply snippet header if present
          if (message.replyToSenderName != null)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: (isDark ? Colors.black : Colors.white).withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(8),
                border: Border(
                  left: BorderSide(
                    color: isDark ? AppColors.darkSecondary : AppColors.lightSecondary,
                    width: 2.5,
                  ),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.reply_rounded, size: 14, color: AppColors.darkSecondary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${message.replyToSenderName}: ${message.replyToText ?? ""}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 11.5, color: textMuted),
                    ),
                  ),
                ],
              ),
            ),

          // Main Header: Avatar, Name, Role Badge, Time
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: isAdmin
                    ? AppColors.adminBadge.withValues(alpha: 0.25)
                    : (message.senderRole == UserRole.driver
                        ? AppColors.driverBadge.withValues(alpha: 0.25)
                        : AppColors.darkSecondary.withValues(alpha: 0.25)),
                child: Text(
                  message.senderName.isNotEmpty ? message.senderName[0].toUpperCase() : 'U',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isAdmin
                        ? AppColors.adminBadge
                        : (message.senderRole == UserRole.driver
                            ? AppColors.driverBadge
                            : AppColors.darkSecondary),
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
                        Flexible(
                          child: Text(
                            message.senderName,
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        RoleBadge(role: message.senderRole),
                      ],
                    ),
                    Text(
                      AppFormatters.timeAgo(message.createdAt),
                      style: TextStyle(fontSize: 11, color: textMuted),
                    ),
                  ],
                ),
              ),
              if (onReplyTap != null)
                IconButton(
                  icon: const Icon(Icons.reply_rounded, size: 18),
                  color: textMuted,
                  visualDensity: VisualDensity.compact,
                  onPressed: onReplyTap,
                  tooltip: 'Reply',
                ),
            ],
          ),

          const SizedBox(height: 8),

          // Message Content
          Text(
            message.text,
            style: TextStyle(
              fontSize: 14.5,
              height: 1.45,
              color: textPrimary,
            ),
          ),

          // Image preview mock if present
          if (message.imageUrl != null) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                height: 140,
                width: double.infinity,
                color: isDark ? AppColors.darkSurface2 : AppColors.lightSurface2,
                child: Center(
                  child: Icon(Icons.image_rounded, size: 36, color: textMuted),
                ),
              ),
            ),
          ],

          // Reactions Bar
          if (message.reactions.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: message.reactions.entries.map((entry) {
                final hasReacted = message.userReactions.contains(entry.key);
                return InkWell(
                  onTap: () => onReactionTap?.call(entry.key),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusChip),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: hasReacted
                          ? AppColors.darkPrimary.withValues(alpha: 0.2)
                          : (isDark ? AppColors.darkSurface2 : AppColors.lightSurface2),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusChip),
                      border: Border.all(
                        color: hasReacted
                            ? AppColors.darkPrimary
                            : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(entry.key, style: const TextStyle(fontSize: 12)),
                        const SizedBox(width: 4),
                        Text(
                          '${entry.value}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: hasReacted ? AppColors.darkPrimary : textMuted,
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
    );
  }
}
