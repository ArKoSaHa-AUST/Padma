import 'package:flutter/material.dart';
import '../../data/models/channel_model.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class ChannelDrawer extends StatelessWidget {
  final String activeChannelId;
  final List<ChannelModel> channels;
  final void Function(ChannelModel channel) onSelectChannel;
  final VoidCallback? onClose;

  const ChannelDrawer({
    super.key,
    required this.activeChannelId,
    required this.channels,
    required this.onSelectChannel,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final drawerBg = isDark ? AppColors.darkSurface2 : AppColors.lightSurface2;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textMuted = isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted;

    final infoChannels = channels.where((c) => c.category == ChannelCategory.info).toList();
    final communityChannels =
        channels.where((c) => c.category == ChannelCategory.community).toList();
    final busChannels = channels.where((c) => c.category == ChannelCategory.buses).toList();

    return Container(
      width: 280,
      color: drawerBg,
      child: SafeArea(
        child: Column(
          children: [
            // Server Header
            Container(
              height: 64,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface1 : AppColors.lightSurface1,
                border: Border(bottom: BorderSide(color: borderColor)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFF003731),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.darkSecondary, width: 1.5),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'AUST',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: AppColors.darkSecondary,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Padma — AUST',
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w700,
                                color: textPrimary,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'Campus Bus & Community',
                          style: TextStyle(fontSize: 11, color: textMuted),
                        ),
                      ],
                    ),
                  ),
                  if (onClose != null)
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20),
                      color: textMuted,
                      onPressed: onClose,
                      tooltip: 'Close Drawer',
                    ),
                ],
              ),
            ),

            // Channel Sections
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 12),
                children: [
                  // Live Map Home Shortcut
                  _ChannelTile(
                    icon: Icons.map_rounded,
                    name: 'Home (Live Map)',
                    isActive: activeChannelId == 'home',
                    onTap: () => onSelectChannel(
                      const ChannelModel(
                        id: 'home',
                        name: 'Home',
                        category: ChannelCategory.info,
                        type: ChannelType.home,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Category: INFO
                  const _CategoryHeader(title: 'INFO'),
                  ...infoChannels.map((c) => _ChannelTile(
                        icon: c.type == ChannelType.announcement
                            ? Icons.campaign_rounded
                            : Icons.schedule_rounded,
                        name: c.name,
                        isActive: activeChannelId == c.id,
                        isReadOnly: c.isReadOnlyForStudents,
                        unreadCount: c.unreadCount,
                        onTap: () => onSelectChannel(c),
                      )),
                  const SizedBox(height: 16),

                  // Category: COMMUNITY
                  const _CategoryHeader(title: 'COMMUNITY'),
                  ...communityChannels.map((c) {
                    final icon = switch (c.type) {
                      ChannelType.request => Icons.water_drop_rounded,
                      ChannelType.general => Icons.tag_rounded,
                      ChannelType.lostFound => Icons.search_rounded,
                      ChannelType.feedback => Icons.build_circle_rounded,
                      _ => Icons.tag_rounded,
                    };
                    return _ChannelTile(
                      icon: icon,
                      name: c.name,
                      iconColor: c.type == ChannelType.request ? AppColors.danger : null,
                      isActive: activeChannelId == c.id,
                      unreadCount: c.unreadCount,
                      onTap: () => onSelectChannel(c),
                    );
                  }),
                  const SizedBox(height: 16),

                  // Category: BUSES
                  const _CategoryHeader(title: 'BUSES'),
                  ...busChannels.map((c) => _ChannelTile(
                        icon: Icons.directions_bus_rounded,
                        name: c.name,
                        isActive: activeChannelId == c.id,
                        unreadCount: c.unreadCount,
                        onTap: () => onSelectChannel(c),
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryHeader extends StatelessWidget {
  final String title;

  const _CategoryHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: AppColors.darkTextMuted,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}

class _ChannelTile extends StatelessWidget {
  final IconData icon;
  final String name;
  final bool isActive;
  final bool isReadOnly;
  final int unreadCount;
  final Color? iconColor;
  final VoidCallback onTap;

  const _ChannelTile({
    required this.icon,
    required this.name,
    required this.isActive,
    this.isReadOnly = false,
    this.unreadCount = 0,
    this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textMuted = isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: isActive
                ? (isDark
                    ? AppColors.darkSecondary.withValues(alpha: 0.18)
                    : AppColors.lightSecondary.withValues(alpha: 0.15))
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: isActive
                ? Border(
                    left: BorderSide(
                      color: isDark ? AppColors.darkSecondary : AppColors.lightSecondary,
                      width: 3.5,
                    ),
                  )
                : null,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: isActive
                    ? (isDark ? AppColors.darkSecondary : AppColors.lightSecondary)
                    : (iconColor ?? textMuted),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  name,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                    color: isActive ? textPrimary : textMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isReadOnly)
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Icon(Icons.lock_rounded, size: 13, color: textMuted.withValues(alpha: 0.7)),
                ),
              if (unreadCount > 0) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                  decoration: BoxDecoration(
                    color: AppColors.danger,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusChip),
                  ),
                  child: Text(
                    '$unreadCount',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
