import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme.dart';
import '../view_models/auth_view_model.dart';
import 'signup_view.dart';

class SignInView extends StatefulWidget {
  const SignInView({super.key});

  @override
  State<SignInView> createState() => _SignInViewState();
}

class _SignInViewState extends State<SignInView> {
  final _studentIdController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _studentIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // App Logo & Header
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 68,
                          height: 68,
                          decoration: BoxDecoration(
                            color: PadmaTheme.surfaceElevated,
                            shape: BoxShape.circle,
                            border: Border.all(color: PadmaTheme.primaryTeal.withValues(alpha: 0.4), width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: PadmaTheme.primaryTeal.withValues(alpha: 0.2),
                                blurRadius: 16,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.directions_bus_rounded,
                            size: 34,
                            color: PadmaTheme.primaryTeal,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'PADMA',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: PadmaTheme.primaryTealContainer,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'AUST',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: PadmaTheme.primaryTeal,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Ahsanullah University of Science & Technology',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: PadmaTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Session Expired Banner if any
                  if (authVM.sessionExpiredMessage != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: PadmaTheme.urgentRedContainer.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: PadmaTheme.urgentRed.withValues(alpha: 0.5)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.timer_off_rounded, color: PadmaTheme.urgentRed, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              authVM.sessionExpiredMessage!,
                              style: const TextStyle(fontSize: 12, color: PadmaTheme.urgentRed, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Auth Card
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: PadmaTheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: PadmaTheme.borderLine, width: 0.8),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Tab selector
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: PadmaTheme.surfaceLowest,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    decoration: BoxDecoration(
                                      color: PadmaTheme.surfaceElevated,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Center(
                                      child: Text(
                                        'Student Sign In',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: PadmaTheme.primaryTeal,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(builder: (_) => const SignUpView()),
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      child: const Center(
                                        child: Text(
                                          'Register',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            color: PadmaTheme.textMuted,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Student ID / Email field
                          const Text(
                            'Institutional Email or Student ID',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: PadmaTheme.textSecondary),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _studentIdController,
                            style: const TextStyle(fontSize: 14, color: PadmaTheme.textPrimary),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: PadmaTheme.surfaceElevated,
                              hintText: 'e.g. padmaStudent@aust.edu or ID',
                              hintStyle: const TextStyle(color: PadmaTheme.textMuted, fontSize: 13),
                              prefixIcon: const Icon(Icons.school_outlined, size: 20, color: PadmaTheme.textMuted),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: PadmaTheme.borderLine),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: PadmaTheme.borderLine),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: PadmaTheme.primaryTeal),
                              ),
                              contentPadding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter your email or student ID' : null,
                          ),
                          const SizedBox(height: 16),

                          // Password field with fixed Show Password toggle
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
                              hintText: 'Enter your password',
                              hintStyle: const TextStyle(color: PadmaTheme.textMuted, fontSize: 13),
                              prefixIcon: const Icon(Icons.lock_outline, size: 20, color: PadmaTheme.textMuted),
                              suffixIcon: IconButton(
                                tooltip: authVM.isPasswordVisible ? 'Hide password' : 'Show password',
                                icon: Icon(
                                  authVM.isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                                  size: 20,
                                  color: authVM.isPasswordVisible ? PadmaTheme.primaryTeal : PadmaTheme.textMuted,
                                ),
                                onPressed: () {
                                  authVM.togglePasswordVisibility();
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: PadmaTheme.borderLine),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: PadmaTheme.borderLine),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: PadmaTheme.primaryTeal),
                              ),
                              contentPadding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            validator: (v) => (v == null || v.isEmpty) ? 'Please enter your password' : null,
                          ),
                          const SizedBox(height: 12),

                          // Remember & Forgot Password
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.check_circle_rounded, size: 16, color: PadmaTheme.primaryTeal),
                                  SizedBox(width: 6),
                                  Text('2-Hour Session', style: TextStyle(fontSize: 12, color: PadmaTheme.textSecondary)),
                                ],
                              ),
                              Flexible(
                                child: TextButton(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Password reset instructions sent to AUST institutional webmail.')),
                                    );
                                  },
                                  style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(50, 30)),
                                  child: const Text(
                                    'Forgot password?',
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(fontSize: 12, color: PadmaTheme.primaryTeal),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Submit Button
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: authVM.isLoading
                                  ? null
                                  : () async {
                                      if (_formKey.currentState?.validate() ?? false) {
                                        final success = await authVM.signIn(_studentIdController.text, _passwordController.text);
                                        if (!success && mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Invalid credentials. For testing use padmaStudent@aust.edu or 2023202420252026 / Padma@123'),
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
                                elevation: 0,
                              ),
                              child: authVM.isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: PadmaTheme.onPrimary),
                                    )
                                  : const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text('Sign In', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                                        SizedBox(width: 8),
                                        Icon(Icons.arrow_forward_rounded, size: 18),
                                      ],
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  const Center(
                    child: Text(
                      'AUST institutional email required for transit alerts and chat.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 11, color: PadmaTheme.textMuted),
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
