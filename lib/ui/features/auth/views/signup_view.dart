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
  final _emailController = TextEditingController();
  final _pickupDestinationController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final List<String> _bloodGroups = ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'];
  final List<String> _departments = ['CSE', 'EEE', 'Civil (CE)', 'Mechanical (ME)', 'IPE', 'TE', 'Architecture', 'BBA'];
  final List<String> _semesters = ['1-1', '1-2', '2-1', '2-2', '3-1', '3-2', '4-1', '4-2'];

  @override
  void dispose() {
    _nameController.dispose();
    _studentIdController.dispose();
    _emailController.dispose();
    _pickupDestinationController.dispose();
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
              child: Form(
                key: _formKey,
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
                          TextFormField(
                            controller: _nameController,
                            style: const TextStyle(fontSize: 14, color: PadmaTheme.textPrimary),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: PadmaTheme.surfaceElevated,
                              hintText: 'e.g. Padma Student',
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
                            validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter your full name' : null,
                          ),
                          const SizedBox(height: 14),

                          const Text(
                            'Student ID Number',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: PadmaTheme.textSecondary),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _studentIdController,
                            style: const TextStyle(fontSize: 14, color: PadmaTheme.textPrimary),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: PadmaTheme.surfaceElevated,
                              hintText: 'e.g. 2023202420252026',
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
                            validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter your student ID' : null,
                          ),
                          const SizedBox(height: 14),

                          // Institutional Email (@aust.edu)
                          const Text(
                            'Institutional Email Address (Must end with @aust.edu)',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: PadmaTheme.textSecondary),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: const TextStyle(fontSize: 14, color: PadmaTheme.textPrimary),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: PadmaTheme.surfaceElevated,
                              hintText: 'e.g. padmaStudent@aust.edu',
                              hintStyle: const TextStyle(color: PadmaTheme.textMuted, fontSize: 13),
                              prefixIcon: const Icon(Icons.alternate_email, size: 20, color: PadmaTheme.textMuted),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: PadmaTheme.borderLine),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: PadmaTheme.borderLine),
                              ),
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Please enter your email';
                              }
                              if (!v.trim().toLowerCase().endsWith('@aust.edu')) {
                                return 'Email must end with @aust.edu';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),

                          // Department & Semester dropdowns
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Department', style: TextStyle(fontSize: 12, color: PadmaTheme.textSecondary)),
                                    const SizedBox(height: 6),
                                    DropdownButtonFormField<String>(
                                      value: authVM.selectedDepartment,
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
                                    const Text('Semester', style: TextStyle(fontSize: 12, color: PadmaTheme.textSecondary)),
                                    const SizedBox(height: 6),
                                    DropdownButtonFormField<String>(
                                      value: authVM.selectedSemester,
                                      items: _semesters.map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 13)))).toList(),
                                      onChanged: (v) => authVM.setSemester(v ?? '4-1'),
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
                          const SizedBox(height: 14),

                          // Pickup Destination
                          const Text(
                            'Pickup Destination / Stoppage',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: PadmaTheme.textSecondary),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _pickupDestinationController,
                            style: const TextStyle(fontSize: 14, color: PadmaTheme.textPrimary),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: PadmaTheme.surfaceElevated,
                              hintText: 'e.g. Mirpur 10, Farmgate, Uttara, Mohakhali',
                              hintStyle: const TextStyle(color: PadmaTheme.textMuted, fontSize: 13),
                              prefixIcon: const Icon(Icons.location_on_outlined, size: 20, color: PadmaTheme.textMuted),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: PadmaTheme.borderLine),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: PadmaTheme.borderLine),
                              ),
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter your pickup destination' : null,
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
                          TextFormField(
                            controller: _passwordController,
                            obscureText: !authVM.isPasswordVisible,
                            style: const TextStyle(fontSize: 14, color: PadmaTheme.textPrimary),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: PadmaTheme.surfaceElevated,
                              hintText: 'Create a strong password (min 6 chars)',
                              hintStyle: const TextStyle(color: PadmaTheme.textMuted, fontSize: 13),
                              prefixIcon: const Icon(Icons.lock_outline, size: 20, color: PadmaTheme.textMuted),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  authVM.isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                                  size: 20,
                                  color: authVM.isPasswordVisible ? PadmaTheme.primaryTeal : PadmaTheme.textMuted,
                                ),
                                onPressed: authVM.togglePasswordVisibility,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: PadmaTheme.borderLine),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: PadmaTheme.borderLine),
                              ),
                            ),
                            validator: (v) => (v == null || v.length < 6) ? 'Password must be at least 6 characters' : null,
                          ),
                          const SizedBox(height: 24),

                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: authVM.isLoading
                                  ? null
                                  : () async {
                                      if (_formKey.currentState?.validate() ?? false) {
                                        final success = await authVM.signUp(
                                          name: _nameController.text,
                                          studentId: _studentIdController.text,
                                          email: _emailController.text,
                                          department: authVM.selectedDepartment,
                                          semester: authVM.selectedSemester,
                                          pickupDestination: _pickupDestinationController.text,
                                          bloodGroup: authVM.selectedBloodGroup,
                                          password: _passwordController.text,
                                        );
                                        if (success && mounted) {
                                          Navigator.of(context).pop();
                                        } else if (mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Registration failed. Ensure email ends with @aust.edu'),
                                              backgroundColor: PadmaTheme.urgentRed,
                                            ),
                                          );
                                        }
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: PadmaTheme.primaryTeal,
                                foregroundColor: PadmaTheme.onPrimary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: authVM.isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: PadmaTheme.onPrimary),
                                    )
                                  : const Text('Complete Registration', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
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
      ),
    );
  }
}
