import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../../admin/views/admin_portal_view.dart';

class ChannelDrawer extends StatelessWidget {
  final Function(int tabIndex, String? channelName) onSelectChannel;
  final String activeChannel;

  const ChannelDrawer({
    super.key,
    required this.onSelectChannel,
    required this.activeChannel,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: PadmaTheme.surfaceLowest,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Server Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: const BoxDecoration(
                color: PadmaTheme.surface,
                border: Border(bottom: BorderSide(color: PadmaTheme.borderLine)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: PadmaTheme.primaryTealContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.directions_bus_rounded, color: PadmaTheme.primaryTeal, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AUST Community',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: PadmaTheme.textPrimary),
                        ),
                        Text(
                          '248 Students Online',
                          style: TextStyle(fontSize: 11, color: PadmaTheme.successGreen, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Channels List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                children: [
                  _buildSectionHeader('CAMPUS CHANNELS'),
                  _buildChannelTile(
                    context,
                    name: 'general',
                    icon: Icons.tag_rounded,
                    isActive: activeChannel == 'general',
                    onTap: () {
                      Navigator.pop(context);
                      onSelectChannel(1, 'general');
                    },
                  ),
                  _buildChannelTile(
                    context,
                    name: 'announcements',
                    icon: Icons.campaign_rounded,
                    isActive: activeChannel == 'announcements',
                    onTap: () {
                      Navigator.pop(context);
                      onSelectChannel(1, 'announcements');
                    },
                  ),
                  const SizedBox(height: 16),

                  _buildSectionHeader('BUS LIVE TELEMETRY'),
                  _buildChannelTile(
                    context,
                    name: 'bus-1-mirpur',
                    icon: Icons.alt_route_rounded,
                    isActive: activeChannel == 'bus-1-mirpur',
                    badge: 'LIVE',
                    badgeColor: PadmaTheme.successGreen,
                    onTap: () {
                      Navigator.pop(context);
                      onSelectChannel(1, 'bus-1-mirpur');
                    },
                  ),
                  _buildChannelTile(
                    context,
                    name: 'bus-2-uttara',
                    icon: Icons.alt_route_rounded,
                    isActive: activeChannel == 'bus-2-uttara',
                    onTap: () {
                      Navigator.pop(context);
                      onSelectChannel(1, 'bus-2-uttara');
                    },
                  ),
                  const SizedBox(height: 16),

                  _buildSectionHeader('STUDENT ASSISTANCE'),
                  _buildChannelTile(
                    context,
                    name: 'emergency-blood',
                    icon: Icons.bloodtype_rounded,
                    iconColor: PadmaTheme.urgentRed,
                    isActive: activeChannel == 'emergency-blood',
                    badge: '3 URGENT',
                    badgeColor: PadmaTheme.urgentRed,
                    onTap: () {
                      Navigator.pop(context);
                      onSelectChannel(2, 'requests');
                    },
                  ),
                  _buildChannelTile(
                    context,
                    name: 'ride-share',
                    icon: Icons.two_wheeler_rounded,
                    isActive: activeChannel == 'ride-share',
                    onTap: () {
                      Navigator.pop(context);
                      onSelectChannel(2, 'requests');
                    },
                  ),
                  const SizedBox(height: 16),

                  _buildSectionHeader('ADMINISTRATION'),
                  _buildChannelTile(
                    context,
                    name: 'admin-portal',
                    icon: Icons.admin_panel_settings_rounded,
                    iconColor: const Color(0xFF8B5CF6),
                    isActive: false,
                    badge: 'STAFF',
                    badgeColor: const Color(0xFF8B5CF6),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AdminPortalView()),
                      );
                    },
                  ),
                ],
              ),
            ),

            // User Bottom Pill in Drawer
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: const BoxDecoration(
                color: PadmaTheme.surface,
                border: Border(top: BorderSide(color: PadmaTheme.borderLine)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: PadmaTheme.primaryTeal,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text('RH', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: PadmaTheme.onPrimary)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Rashedul Hasan', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: PadmaTheme.textPrimary)),
                        Text('CSE • Fall 2021', style: TextStyle(fontSize: 11, color: PadmaTheme.textMuted)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings_outlined, size: 18, color: PadmaTheme.textSecondary),
                    onPressed: () {
                      Navigator.pop(context);
                      onSelectChannel(3, null);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Text(
        title,
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: PadmaTheme.textMuted, letterSpacing: 0.8),
      ),
    );
  }

  Widget _buildChannelTile(
    BuildContext context, {
    required String name,
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
    Color? iconColor,
    String? badge,
    Color? badgeColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        margin: const EdgeInsets.only(bottom: 2),
        decoration: BoxDecoration(
          color: isActive ? PadmaTheme.surfaceElevated : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: iconColor ?? (isActive ? PadmaTheme.textPrimary : PadmaTheme.textMuted)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                name,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  color: isActive ? PadmaTheme.textPrimary : PadmaTheme.textSecondary,
                ),
              ),
            ),
            if (badge != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: (badgeColor ?? PadmaTheme.primaryTeal).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: badgeColor ?? PadmaTheme.primaryTeal,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
