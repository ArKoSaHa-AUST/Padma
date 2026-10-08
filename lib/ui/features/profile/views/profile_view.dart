import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme.dart';
import '../../admin/views/admin_portal_view.dart';
import '../../auth/view_models/auth_view_model.dart';
import '../../../../data/services/mock_data_service.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();
    final user = authVM.currentUser ?? MockDataService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AUST Student Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: PadmaTheme.urgentRed),
            onPressed: () {
              authVM.signOut();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            // Profile Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: PadmaTheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: PadmaTheme.borderLine),
              ),
              child: Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: PadmaTheme.primaryTeal,
                      shape: BoxShape.circle,
                      border: Border.all(color: PadmaTheme.primaryTeal.withValues(alpha: 0.5), width: 3),
                    ),
                    child: const Center(
                      child: Text(
                        'RH',
                        style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: PadmaTheme.onPrimary),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        user.name,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: PadmaTheme.textPrimary),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.verified_rounded, color: PadmaTheme.primaryTeal, size: 18),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${user.department} • ${user.session}',
                    style: const TextStyle(fontSize: 12.5, color: PadmaTheme.textSecondary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Student ID: ${user.studentId}',
                    style: const TextStyle(fontSize: 12, color: PadmaTheme.textMuted),
                  ),
                  const SizedBox(height: 16),

                  // Stats Row
                  Row(
                    children: [
                      _buildStatBox('Trips Taken', '${user.tripsTaken}', PadmaTheme.primaryTeal),
                      const SizedBox(width: 10),
                      _buildStatBox('Blood Group', user.bloodGroup, PadmaTheme.urgentRed),
                      const SizedBox(width: 10),
                      _buildStatBox('Pings Sent', '${user.contributions}', PadmaTheme.busAmber),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Emergency Donor Status Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: PadmaTheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: PadmaTheme.borderLine),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: PadmaTheme.urgentRedContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.bloodtype_rounded, color: PadmaTheme.urgentRed, size: 24),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Blood Donor Roster', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                        Text('Listed as active emergency donor for AUST students', style: TextStyle(fontSize: 11, color: PadmaTheme.textMuted)),
                      ],
                    ),
                  ),
                  Switch(
                    value: user.isDonor,
                    activeThumbColor: PadmaTheme.urgentRed,
                    onChanged: (val) {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Quick App Settings list
            Container(
              decoration: BoxDecoration(
                color: PadmaTheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: PadmaTheme.borderLine),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.admin_panel_settings_rounded, color: Color(0xFF8B5CF6), size: 22),
                    title: const Text('Admin Command Center', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: Color(0xFF8B5CF6))),
                    subtitle: const Text('Fleet GPS, AI broadcast studio & moderation', style: TextStyle(fontSize: 11, color: PadmaTheme.textMuted)),
                    trailing: const Icon(Icons.chevron_right, size: 18, color: Color(0xFF8B5CF6)),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AdminPortalView()),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  _buildSettingTile(Icons.notifications_outlined, 'Transit Push Alerts', 'Enabled'),
                  const Divider(height: 1),
                  _buildSettingTile(Icons.alt_route_rounded, 'Primary Commute Route', 'Bus 1 (Mirpur)'),
                  const Divider(height: 1),
                  _buildSettingTile(Icons.security_rounded, 'AUST Webmail Verification', 'Verified'),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.logout_rounded, color: PadmaTheme.urgentRed, size: 20),
                    title: const Text('Sign Out', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: PadmaTheme.urgentRed)),
                    onTap: () {
                      context.read<AuthViewModel>().signOut();
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

  Widget _buildStatBox(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: PadmaTheme.surfaceElevated,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: PadmaTheme.borderLine),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: color)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 10, color: PadmaTheme.textMuted)),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingTile(IconData icon, String title, String subtitle) {
    return ListTile(
      leading: Icon(icon, color: PadmaTheme.textSecondary, size: 20),
      title: Text(title, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(subtitle, style: const TextStyle(fontSize: 12, color: PadmaTheme.primaryTeal)),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right, size: 18, color: PadmaTheme.textMuted),
        ],
      ),
    );
  }
}
