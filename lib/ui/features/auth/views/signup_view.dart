import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme.dart';
import '../view_models/auth_view_model.dart';

class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  final _nameController = TextEditingController();
  final _studentIdController = TextEditingController();
  final _passwordController = TextEditingController();

  final List<String> _bloodGroups = ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'];
  final List<String> _departments = ['CSE', 'EEE', 'Civil (CE)', 'Mechanical (ME)', 'IPE', 'TE', 'Architecture', 'BBA'];
  final List<String> _sessions = ['Fall 2024', 'Spring 2024', 'Fall 2023', 'Spring 2023', 'Fall 2022', 'Spring 2022', 'Fall 2021'];

  @override
  void dispose() {
    _nameController.dispose();
    _studentIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Register Student Account'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: PadmaTheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: PadmaTheme.borderLine, width: 0.8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Full Name',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: PadmaTheme.textSecondary),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: PadmaTheme.surfaceElevated,
                            hintText: 'e.g. Rashedul Hasan',
                            hintStyle: const TextStyle(color: PadmaTheme.textMuted, fontSize: 13),
                            prefixIcon: const Icon(Icons.person_outline, size: 20, color: PadmaTheme.textMuted),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: PadmaTheme.borderLine),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: PadmaTheme.borderLine),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        const Text(
                          'Student ID Number',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: PadmaTheme.textSecondary),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _studentIdController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: PadmaTheme.surfaceElevated,
                            hintText: 'e.g. 20210104052',
                            hintStyle: const TextStyle(color: PadmaTheme.textMuted, fontSize: 13),
                            prefixIcon: const Icon(Icons.badge_outlined, size: 20, color: PadmaTheme.textMuted),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: PadmaTheme.borderLine),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: PadmaTheme.borderLine),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Department & Session dropdowns
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Department', style: TextStyle(fontSize: 12, color: PadmaTheme.textSecondary)),
                                  const SizedBox(height: 6),
                                  DropdownButtonFormField<String>(
                                    initialValue: authVM.selectedDepartment,
                                    items: _departments.map((d) => DropdownMenuItem(value: d, child: Text(d, style: const TextStyle(fontSize: 13)))).toList(),
                                    onChanged: (v) => authVM.setDepartment(v ?? 'CSE'),
                                    dropdownColor: PadmaTheme.surfaceElevated,
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: PadmaTheme.surfaceElevated,
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: PadmaTheme.borderLine)),
                                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: PadmaTheme.borderLine)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Session', style: TextStyle(fontSize: 12, color: PadmaTheme.textSecondary)),
                                  const SizedBox(height: 6),
                                  DropdownButtonFormField<String>(
                                    initialValue: authVM.selectedSession,
                                    items: _sessions.map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 13)))).toList(),
                                    onChanged: (v) => authVM.setSession(v ?? 'Fall 2021'),
                                    dropdownColor: PadmaTheme.surfaceElevated,
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: PadmaTheme.surfaceElevated,
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: PadmaTheme.borderLine)),
                                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: PadmaTheme.borderLine)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Blood Donor Chip Selection
                        const Text(
                          'Blood Group (For Emergency Blood Roster)',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: PadmaTheme.textSecondary),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _bloodGroups.map((group) {
                            final isSelected = authVM.selectedBloodGroup == group;
                            return ChoiceChip(
                              label: Text(
                                group,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected ? PadmaTheme.onPrimary : PadmaTheme.textSecondary,
                                ),
                              ),
                              selected: isSelected,
                              selectedColor: PadmaTheme.primaryTeal,
                              backgroundColor: PadmaTheme.surfaceElevated,
                              side: BorderSide(
                                color: isSelected ? PadmaTheme.primaryTeal : PadmaTheme.borderLine,
                              ),
                              onSelected: (_) => authVM.setBloodGroup(group),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),

                        const Text(
                          'Password',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: PadmaTheme.textSecondary),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: PadmaTheme.surfaceElevated,
                            hintText: 'Create secure password',
                            hintStyle: const TextStyle(color: PadmaTheme.textMuted, fontSize: 13),
                            prefixIcon: const Icon(Icons.lock_outline, size: 20, color: PadmaTheme.textMuted),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: PadmaTheme.borderLine),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: PadmaTheme.borderLine),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: authVM.isLoading
                                ? null
                                : () async {
                                    final success = await authVM.signUp(
                                      name: _nameController.text.isNotEmpty ? _nameController.text : 'AUST Student',
                                      studentId: _studentIdController.text.isNotEmpty ? _studentIdController.text : '20210104052',
                                      department: authVM.selectedDepartment,
                                      session: authVM.selectedSession,
                                      bloodGroup: authVM.selectedBloodGroup,
                                      password: _passwordController.text,
                                    );
                                    if (success && context.mounted) {
                                      Navigator.of(context).pop();
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: PadmaTheme.primaryTeal,
                              foregroundColor: PadmaTheme.onPrimary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Complete Registration & Join', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
