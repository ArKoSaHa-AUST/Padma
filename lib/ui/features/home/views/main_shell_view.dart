import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../../tracker/views/tracker_view.dart';
import '../../channels/views/general_chat_view.dart';
import '../../channels/views/bus_telemetry_chat_view.dart';
import '../../channels/views/requests_view.dart';
import '../../channels/views/channel_drawer.dart';
import '../../profile/views/profile_view.dart';
import '../../notifications/views/notifications_view.dart';

class MainShellView extends StatefulWidget {
  const MainShellView({super.key});

  @override
  State<MainShellView> createState() => _MainShellViewState();
}

class _MainShellViewState extends State<MainShellView> {
  int _currentIndex = 0;
  String _activeChannel = 'general';
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  void _onSelectChannel(int tabIndex, String? channelName) {
    setState(() {
      _currentIndex = tabIndex;
      if (channelName != null) {
        _activeChannel = channelName;
      }
    });
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return TrackerView(
          onOpenGeneralChat: () => _onSelectChannel(1, 'general'),
        );
      case 1:
        if (_activeChannel == 'bus-1-mirpur' || _activeChannel == 'bus-2-uttara') {
          return BusTelemetryChatView(onOpenDrawer: _openDrawer);
        }
        return GeneralChatView(onOpenDrawer: _openDrawer);
      case 2:
        return RequestsView(onOpenDrawer: _openDrawer);
      case 3:
        return const NotificationsView();
      case 4:
        return const ProfileView();
      default:
        return TrackerView(
          onOpenGeneralChat: () => _onSelectChannel(1, 'general'),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: ChannelDrawer(
        onSelectChannel: _onSelectChannel,
        activeChannel: _activeChannel,
      ),
      appBar: _currentIndex == 0
          ? AppBar(
              leading: IconButton(
                icon: const Icon(Icons.menu_rounded),
                onPressed: _openDrawer,
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: PadmaTheme.primaryTealContainer,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text('PADMA', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: PadmaTheme.primaryTeal)),
                  ),
                  const SizedBox(width: 8),
                  const Text('AUST Live Transit', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () {
                    setState(() => _currentIndex = 3);
                  },
                ),
                InkWell(
                  onTap: () {
                    setState(() => _currentIndex = 4);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 14),
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
                ),
              ],
            )
          : null,
      body: _buildBody(),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: PadmaTheme.surface,
          border: Border(top: BorderSide(color: PadmaTheme.borderLine, width: 0.8)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() => _currentIndex = index);
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: PadmaTheme.surface,
          selectedItemColor: PadmaTheme.primaryTeal,
          unselectedItemColor: PadmaTheme.textMuted,
          selectedFontSize: 11,
          unselectedFontSize: 11,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.directions_bus_rounded),
              label: 'Tracker',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline_rounded),
              activeIcon: Icon(Icons.chat_bubble_rounded),
              label: 'Channels',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.emergency_outlined),
              activeIcon: Icon(Icons.emergency_rounded),
              label: 'Requests',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications_outlined),
              activeIcon: Icon(Icons.notifications_rounded),
              label: 'Alerts',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              activeIcon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
