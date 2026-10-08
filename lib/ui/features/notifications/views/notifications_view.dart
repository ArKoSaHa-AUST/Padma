import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme.dart';
import '../../channels/view_models/channels_view_model.dart';
import '../../../../data/models/notification_item.dart';

class NotificationsView extends StatelessWidget {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    final channelsVM = context.watch<ChannelsViewModel>();
    final notifications = channelsVM.notifications;

    return Scaffold(
      backgroundColor: PadmaTheme.background,
      appBar: AppBar(
        backgroundColor: PadmaTheme.surface,
        title: const Text('Live Notifications & Alerts', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all_rounded, size: 20, color: PadmaTheme.textMuted),
            tooltip: 'Mark all as read',
            onPressed: () {
              channelsVM.markAllNotificationsRead();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All notifications marked as read.'),
                  backgroundColor: PadmaTheme.primary,
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
      body: notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off_outlined, size: 54, color: PadmaTheme.textMuted.withOpacity(0.5)),
                  const SizedBox(height: 12),
                  const Text(
                    'No notifications right now',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: PadmaTheme.textSecondary),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Bus departure alerts, arrival pings, and announcements will appear here.',
                    style: TextStyle(fontSize: 12, color: PadmaTheme.textMuted),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              itemCount: notifications.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = notifications[index];
                return _buildNotificationCard(context, item);
              },
            ),
    );
  }

  Widget _buildNotificationCard(BuildContext context, NotificationItem item) {
    IconData iconData;
    Color color;

    switch (item.type) {
      case NotificationType.transit:
        iconData = Icons.directions_bus_rounded;
        color = PadmaTheme.primaryTeal;
        break;
      case NotificationType.warning:
        iconData = Icons.warning_amber_rounded;
        color = PadmaTheme.urgentRed;
        break;
      case NotificationType.journeyStart:
        iconData = Icons.directions_bus_rounded;
        color = PadmaTheme.busAmber;
        break;
      case NotificationType.destinationArrival:
        iconData = Icons.pin_drop_rounded;
        color = PadmaTheme.successGreen;
        break;
      case NotificationType.announcement:
        iconData = Icons.campaign_rounded;
        color = PadmaTheme.primaryTeal;
        break;
      case NotificationType.rules:
        iconData = Icons.gavel_rounded;
        color = Colors.deepOrangeAccent;
        break;
      case NotificationType.mention:
        iconData = Icons.alternate_email_rounded;
        color = Colors.purpleAccent;
        break;
      case NotificationType.blood:
        iconData = Icons.bloodtype_rounded;
        color = PadmaTheme.urgentRed;
        break;
      case NotificationType.lostFound:
        iconData = Icons.search_rounded;
        color = Colors.cyan;
        break;
      case NotificationType.complain:
        iconData = Icons.description_outlined;
        color = Colors.amber;
        break;
    }

    final timeAgo = _formatTimestamp(item.timestamp);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: item.isRead ? PadmaTheme.surface : PadmaTheme.surfaceLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: item.isRead ? PadmaTheme.borderLine : color.withOpacity(0.4),
          width: item.isRead ? 1 : 1.5,
        ),
        boxShadow: item.isRead
            ? []
            : [
                BoxShadow(
                  color: color.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(iconData, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: item.isRead ? FontWeight.w600 : FontWeight.w700,
                          color: PadmaTheme.textPrimary,
                        ),
                      ),
                    ),
                    if (!item.isRead)
                      Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(left: 6),
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.body,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: PadmaTheme.textSecondary,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      timeAgo,
                      style: const TextStyle(fontSize: 10.5, color: PadmaTheme.textMuted),
                    ),
                    if (item.targetChannel != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        '• #${item.targetChannel}',
                        style: const TextStyle(fontSize: 10.5, color: PadmaTheme.primaryTeal, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
