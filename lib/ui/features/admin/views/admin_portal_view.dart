import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme.dart';
import '../../auth/view_models/auth_view_model.dart';
import '../view_models/admin_view_model.dart';
import 'tabs/admin_overview_tab.dart';
import 'tabs/admin_fleet_tab.dart';
import 'tabs/admin_channels_tab.dart';
import 'tabs/admin_broadcast_tab.dart';
import 'tabs/admin_blood_hub_tab.dart';
import 'tabs/admin_moderation_tab.dart';
import 'tabs/admin_schedules_tab.dart';
import 'tabs/admin_lost_found_tab.dart';
import 'widgets/ai_copilot_sheet.dart';

class AdminPortalView extends StatefulWidget {
  const AdminPortalView({super.key});

  @override
  State<AdminPortalView> createState() => _AdminPortalViewState();
}

class _AdminPortalViewState extends State<AdminPortalView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Map<String, dynamic>> _tabs = const [
    {'title': 'Command Center', 'icon': Icons.dashboard_customize_rounded},
    {'title': 'Fleet & GPS', 'icon': Icons.directions_bus_rounded},
    {'title': 'Client Channels', 'icon': Icons.forum_rounded},
    {'title': 'Broadcasts', 'icon': Icons.campaign_rounded},
    {'title': 'Blood Hub', 'icon': Icons.water_drop_rounded},
    {'title': 'Moderation', 'icon': Icons.shield_rounded},
    {'title': 'Schedules', 'icon': Icons.schedule_rounded},
    {'title': 'Lost & Found', 'icon': Icons.inventory_2_rounded},
  ];

  Widget _buildActiveTab(int index, AdminViewModel adminVM) {
    switch (index) {
      case 0:
        return AdminOverviewTab(onNavigateTab: (tabIdx) => adminVM.setSelectedTab(tabIdx));
      case 1:
        return const AdminFleetTab();
      case 2:
        return const AdminChannelsTab();
      case 3:
        return const AdminBroadcastTab();
      case 4:
        return const AdminBloodHubTab();
      case 5:
        return const AdminModerationTab();
      case 6:
        return const AdminSchedulesTab();
      case 7:
        return const AdminLostFoundTab();
      default:
        return AdminOverviewTab(onNavigateTab: (tabIdx) => adminVM.setSelectedTab(tabIdx));
    }
  }

  @override
  Widget build(BuildContext context) {
    final adminVM = context.watch<AdminViewModel>();
    final authVM = context.watch<AuthViewModel>();
    final currentIndex = adminVM.selectedTabIndex;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: PadmaTheme.surfaceLowest,
      appBar: AppBar(
        backgroundColor: PadmaTheme.surface,
        elevation: 0,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: PadmaTheme.textPrimary),
                onPressed: () => Navigator.pop(context),
              )
            : IconButton(
                icon: const Icon(Icons.menu_rounded, color: PadmaTheme.textPrimary),
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFF8B5CF6).withValues(alpha: 0.6)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.admin_panel_settings_rounded, size: 14, color: Color(0xFF8B5CF6)),
                  SizedBox(width: 4),
                  Text('ADMIN', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFF8B5CF6))),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              _tabs[currentIndex]['title'],
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: PadmaTheme.textPrimary),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'AI Transit Copilot',
            icon: const Icon(Icons.auto_awesome_rounded, color: PadmaTheme.primaryTeal),
            onPressed: () {
              AiCopilotSheet.show(
                context,
                onApply: (title, body, priority) {
                  adminVM.addAnnouncement(
                    title: title,
                    body: body,
                    priority: priority,
                    targetRoute: 'All Routes',
                    isPinned: true,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('✨ AI Announcement published!')),
                  );
                },
              );
            },
          ),
          IconButton(
            tooltip: 'Sign Out Admin',
            icon: const Icon(Icons.logout_rounded, color: PadmaTheme.textMuted),
            onPressed: () {
              authVM.signOut();
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: PadmaTheme.surface,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drawer Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: PadmaTheme.borderLine)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: Color(0xFF8B5CF6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.shield_rounded, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Transport Directorate', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: PadmaTheme.textPrimary)),
                          Text('admin@padma.com', style: TextStyle(fontSize: 11, color: PadmaTheme.textMuted)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Navigation Tabs List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: _tabs.length,
                  itemBuilder: (context, i) {
                    final tab = _tabs[i];
                    final isSelected = currentIndex == i;
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                      decoration: BoxDecoration(
                        color: isSelected ? PadmaTheme.primaryTeal.withValues(alpha: 0.15) : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: isSelected ? PadmaTheme.primaryTeal.withValues(alpha: 0.4) : Colors.transparent),
                      ),
                      child: ListTile(
                        leading: Icon(tab['icon'], color: isSelected ? PadmaTheme.primaryTeal : PadmaTheme.textMuted, size: 20),
                        title: Text(
                          tab['title'],
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected ? PadmaTheme.primaryTeal : PadmaTheme.textPrimary,
                          ),
                        ),
                        onTap: () {
                          adminVM.setSelectedTab(i);
                          Navigator.pop(context);
                        },
                      ),
                    );
                  },
                ),
              ),

              // Bottom App Info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: PadmaTheme.borderLine)),
                ),
                child: const Text('PADMA Fleet v1.0.0 • Admin Mode', style: TextStyle(fontSize: 11, color: PadmaTheme.textMuted)),
              ),
            ],
          ),
        ),
      ),
      body: _buildActiveTab(currentIndex, adminVM),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: PadmaTheme.surface,
          border: Border(top: BorderSide(color: PadmaTheme.borderLine, width: 0.8)),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _tabs.asMap().entries.map((entry) {
              final idx = entry.key;
              final tab = entry.value;
              final isSelected = currentIndex == idx;

              return InkWell(
                onTap: () => adminVM.setSelectedTab(idx),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: isSelected ? PadmaTheme.primaryTeal : Colors.transparent,
                        width: 2.5,
                      ),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        tab['icon'],
                        size: 20,
                        color: isSelected ? PadmaTheme.primaryTeal : PadmaTheme.textMuted,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        tab['title'],
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? PadmaTheme.primaryTeal : PadmaTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
