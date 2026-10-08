import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme.dart';
import '../../auth/view_models/auth_view_model.dart';

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
    final authVM = context.watch<AuthViewModel>();
    final user = authVM.currentUser;

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
                          'Padma — AUST',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: PadmaTheme.textPrimary),
                        ),
                        Text(
                          'Ahsanullah University Bus Hub',
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
                    name: 'Rules and Regulation',
                    channelKey: 'rules-and-regulation',
                    icon: Icons.gavel_rounded,
                    isActive: activeChannel == 'rules-and-regulation' || activeChannel == 'general',
                    badge: 'ADMIN ONLY',
                    badgeColor: PadmaTheme.primaryTeal,
                    onTap: () {
                      Navigator.pop(context);
                      onSelectChannel(1, 'rules-and-regulation');
                    },
                  ),
                  _buildChannelTile(
                    context,
                    name: 'announcements',
                    channelKey: 'announcements',
                    icon: Icons.campaign_rounded,
                    isActive: activeChannel == 'announcements',
                    badge: 'ADMIN ONLY',
                    badgeColor: const Color(0xFF8B5CF6),
                    onTap: () {
                      Navigator.pop(context);
                      onSelectChannel(1, 'announcements');
                    },
                  ),
                  const SizedBox(height: 16),

                  _buildSectionHeader('BUS LIVE TELEMETRY'),
                  _buildChannelTile(
                    context,
                    name: 'Padma 1 (Mirpur Route)',
                    channelKey: 'padma-1',
                    icon: Icons.directions_bus_rounded,
                    isActive: activeChannel == 'padma-1' || activeChannel == 'bus-1-mirpur',
                    badge: 'LIVE',
                    badgeColor: PadmaTheme.successGreen,
                    onTap: () {
                      Navigator.pop(context);
                      onSelectChannel(1, 'padma-1');
                    },
                  ),
                  _buildChannelTile(
                    context,
                    name: 'Padma 2 (Uttara Route)',
                    channelKey: 'padma-2',
                    icon: Icons.directions_bus_rounded,
                    isActive: activeChannel == 'padma-2' || activeChannel == 'bus-2-uttara',
                    badge: 'LIVE',
                    badgeColor: PadmaTheme.successGreen,
                    onTap: () {
                      Navigator.pop(context);
                      onSelectChannel(1, 'padma-2');
                    },
                  ),
                  const SizedBox(height: 16),

                  _buildSectionHeader('STUDENT ASSISTANCE'),
                  _buildChannelTile(
                    context,
                    name: 'Blood Request',
                    channelKey: 'blood-request',
                    icon: Icons.bloodtype_rounded,
                    iconColor: PadmaTheme.urgentRed,
                    isActive: activeChannel == 'blood-request' || activeChannel == 'emergency-blood',
                    badge: 'POST / DONATE',
                    badgeColor: PadmaTheme.urgentRed,
                    onTap: () {
                      Navigator.pop(context);
                      onSelectChannel(2, 'blood-request');
                    },
                  ),
                  _buildChannelTile(
                    context,
                    name: 'Lost and found',
                    channelKey: 'lost-found',
                    icon: Icons.search_rounded,
                    iconColor: PadmaTheme.busAmber,
                    isActive: activeChannel == 'lost-found',
                    onTap: () {
                      Navigator.pop(context);
                      onSelectChannel(2, 'lost-found');
                    },
                  ),
                  _buildChannelTile(
                    context,
                    name: 'Contact Admin (1-on-1)',
                    channelKey: 'contact-admin',
                    icon: Icons.support_agent_rounded,
                    iconColor: const Color(0xFF8B5CF6),
                    isActive: activeChannel == 'contact-admin',
                    badge: 'PRIVATE',
                    badgeColor: const Color(0xFF8B5CF6),
                    onTap: () {
                      Navigator.pop(context);
                      onSelectChannel(2, 'contact-admin');
                    },
                  ),
                  const SizedBox(height: 16),

                  _buildSectionHeader('GRIEVANCE & FEEDBACK'),
                  _buildChannelTile(
                    context,
                    name: 'Submit Complain',
                    channelKey: 'submit-complain',
                    icon: Icons.description_outlined,
                    iconColor: PadmaTheme.primaryTeal,
                    isActive: activeChannel == 'submit-complain',
                    badge: 'DOCS FORM',
                    badgeColor: PadmaTheme.primaryTeal,
                    onTap: () {
                      Navigator.pop(context);
                      onSelectChannel(2, 'submit-complain');
                    },
                  ),
                ],
              ),
            ),

            // User Info Footer
            if (user != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: PadmaTheme.surface,
                  border: Border(top: BorderSide(color: PadmaTheme.borderLine)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: PadmaTheme.primaryTeal,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          user.name.isNotEmpty ? user.name.substring(0, 1).toUpperCase() : 'U',
                          style: const TextStyle(fontWeight: FontWeight.w800, color: PadmaTheme.onPrimary, fontSize: 13),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name,
                            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: PadmaTheme.textPrimary),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '@${user.chatTag}',
                            style: const TextStyle(fontSize: 10, color: PadmaTheme.primaryTeal, fontFamily: 'monospace'),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
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
      padding: const EdgeInsets.only(left: 8, bottom: 6, top: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: PadmaTheme.textMuted,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildChannelTile(
    BuildContext context, {
    required String name,
    required String channelKey,
    required IconData icon,
    Color? iconColor,
    required bool isActive,
    String? badge,
    Color? badgeColor,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 3),
      decoration: BoxDecoration(
        color: isActive ? PadmaTheme.surfaceElevated : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
        leading: Icon(icon, size: 18, color: iconColor ?? (isActive ? PadmaTheme.primaryTeal : PadmaTheme.textMuted)),
        title: Text(
          name,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            color: isActive ? PadmaTheme.textPrimary : PadmaTheme.textSecondary,
          ),
        ),
        trailing: badge != null
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: (badgeColor ?? PadmaTheme.primaryTeal).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: badgeColor ?? PadmaTheme.primaryTeal,
                  ),
                ),
              )
            : null,
        onTap: onTap,
      ),
    );
  }
}
