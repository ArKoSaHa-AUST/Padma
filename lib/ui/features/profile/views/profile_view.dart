import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme.dart';
import '../../auth/view_models/auth_view_model.dart';
import '../../../../data/services/mock_data_service.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  void _showEditProfileDialog(BuildContext context) {
    final authVM = context.read<AuthViewModel>();
    final user = authVM.currentUser ?? MockDataService.currentUser;

    final nameCtrl = TextEditingController(text: user.name);
    final deptCtrl = TextEditingController(text: user.department);
    final semCtrl = TextEditingController(text: user.semester);
    final destCtrl = TextEditingController(text: user.pickupDestination);
    final phoneCtrl = TextEditingController(text: user.contactNumber);
    String selectedBlood = user.bloodGroup;

    final bloodGroups = ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'];

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: PadmaTheme.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: PadmaTheme.borderLine)),
            title: const Row(
              children: [
                Icon(Icons.edit_note_rounded, color: PadmaTheme.primaryTeal, size: 24),
                SizedBox(width: 8),
                Text('Edit Profile Information', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Full Name', style: TextStyle(fontSize: 11, color: PadmaTheme.textSecondary, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  TextField(
                    controller: nameCtrl,
                    style: const TextStyle(fontSize: 13.5),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: PadmaTheme.surfaceElevated,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: PadmaTheme.borderLine)),
                    ),
                  ),
                  const SizedBox(height: 12),

                  const Text('Department', style: TextStyle(fontSize: 11, color: PadmaTheme.textSecondary, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  TextField(
                    controller: deptCtrl,
                    style: const TextStyle(fontSize: 13.5),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: PadmaTheme.surfaceElevated,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: PadmaTheme.borderLine)),
                    ),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Semester', style: TextStyle(fontSize: 11, color: PadmaTheme.textSecondary, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 4),
                            TextField(
                              controller: semCtrl,
                              style: const TextStyle(fontSize: 13.5),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: PadmaTheme.surfaceElevated,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: PadmaTheme.borderLine)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Blood Group', style: TextStyle(fontSize: 11, color: PadmaTheme.textSecondary, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 4),
                            DropdownButtonFormField<String>(
                              value: bloodGroups.contains(selectedBlood) ? selectedBlood : 'O+',
                              items: bloodGroups.map((bg) => DropdownMenuItem(value: bg, child: Text(bg, style: const TextStyle(fontSize: 13)))).toList(),
                              onChanged: (v) {
                                if (v != null) setDialogState(() => selectedBlood = v);
                              },
                              dropdownColor: PadmaTheme.surfaceElevated,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: PadmaTheme.surfaceElevated,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: PadmaTheme.borderLine)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  const Text('Pickup Destination / Stoppage', style: TextStyle(fontSize: 11, color: PadmaTheme.textSecondary, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  TextField(
                    controller: destCtrl,
                    style: const TextStyle(fontSize: 13.5),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: PadmaTheme.surfaceElevated,
                      hintText: 'e.g. Mirpur 10, Farmgate, Uttara',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: PadmaTheme.borderLine)),
                    ),
                  ),
                  const SizedBox(height: 12),

                  const Text('Contact Phone Number', style: TextStyle(fontSize: 11, color: PadmaTheme.textSecondary, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  TextField(
                    controller: phoneCtrl,
                    style: const TextStyle(fontSize: 13.5),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: PadmaTheme.surfaceElevated,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: PadmaTheme.borderLine)),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogCtx),
                child: const Text('Cancel', style: TextStyle(color: PadmaTheme.textMuted)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: PadmaTheme.primaryTeal,
                  foregroundColor: PadmaTheme.onPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  authVM.updateUserProfile(
                    name: nameCtrl.text,
                    department: deptCtrl.text,
                    semester: semCtrl.text,
                    bloodGroup: selectedBlood,
                    pickupDestination: destCtrl.text,
                    contactNumber: phoneCtrl.text,
                  );
                  Navigator.pop(dialogCtx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Profile information updated successfully!')),
                  );
                },
                child: const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();
    final user = authVM.currentUser ?? MockDataService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AUST Student Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: PadmaTheme.primaryTeal),
            tooltip: 'Edit Information',
            onPressed: () => _showEditProfileDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: PadmaTheme.urgentRed),
            tooltip: 'Sign Out',
            onPressed: () {
              authVM.signOut();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Profile Header Card
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
                    child: Center(
                      child: Text(
                        user.name.isNotEmpty ? user.name.substring(0, 1).toUpperCase() : 'P',
                        style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: PadmaTheme.onPrimary),
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
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: PadmaTheme.surfaceElevated,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: PadmaTheme.borderLine),
                    ),
                    child: Text(
                      '@${user.chatTag}',
                      style: const TextStyle(fontSize: 11.5, color: PadmaTheme.primaryTeal, fontFamily: 'monospace', fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    user.email,
                    style: const TextStyle(fontSize: 12, color: PadmaTheme.textMuted),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Profile Information List (Only showing requested details)
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: PadmaTheme.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: PadmaTheme.borderLine),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'STUDENT INFORMATION',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: PadmaTheme.textMuted, letterSpacing: 0.8),
                      ),
                      TextButton.icon(
                        style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(40, 24)),
                        icon: const Icon(Icons.edit_rounded, size: 14, color: PadmaTheme.primaryTeal),
                        label: const Text('Edit', style: TextStyle(fontSize: 12, color: PadmaTheme.primaryTeal, fontWeight: FontWeight.w700)),
                        onPressed: () => _showEditProfileDialog(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(Icons.badge_outlined, 'Student ID', user.studentId),
                  const Divider(height: 20, color: PadmaTheme.borderLine),
                  _buildInfoRow(Icons.domain_rounded, 'Department', user.department),
                  const Divider(height: 20, color: PadmaTheme.borderLine),
                  _buildInfoRow(Icons.school_outlined, 'Semester', user.semester),
                  const Divider(height: 20, color: PadmaTheme.borderLine),
                  _buildInfoRow(Icons.pin_drop_outlined, 'Pickup Destination', user.pickupDestination),
                  const Divider(height: 20, color: PadmaTheme.borderLine),
                  _buildInfoRow(Icons.bloodtype_outlined, 'Blood Group', user.bloodGroup, isBlood: true),
                  const Divider(height: 20, color: PadmaTheme.borderLine),
                  _buildInfoRow(Icons.email_outlined, 'Institutional Email', user.email),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Sign Out Button
            Container(
              decoration: BoxDecoration(
                color: PadmaTheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: PadmaTheme.borderLine),
              ),
              child: ListTile(
                leading: const Icon(Icons.logout_rounded, color: PadmaTheme.urgentRed, size: 22),
                title: const Text('Sign Out', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: PadmaTheme.urgentRed)),
                subtitle: const Text('End your session on this device', style: TextStyle(fontSize: 11, color: PadmaTheme.textMuted)),
                trailing: const Icon(Icons.chevron_right_rounded, color: PadmaTheme.urgentRed, size: 20),
                onTap: () {
                  context.read<AuthViewModel>().signOut();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {bool isBlood = false}) {
    return Row(
      children: [
        Icon(icon, size: 18, color: isBlood ? PadmaTheme.urgentRed : PadmaTheme.textSecondary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 10.5, color: PadmaTheme.textMuted, fontWeight: FontWeight.w500)),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: isBlood ? PadmaTheme.urgentRed : PadmaTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
