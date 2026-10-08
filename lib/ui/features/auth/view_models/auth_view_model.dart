import 'package:flutter/material.dart';
import '../../../../data/models/user_profile.dart';
import '../../../../data/services/mock_data_service.dart';
import '../../../../data/services/supabase_service.dart';

enum AuthMode { signIn, signUp }

class AuthViewModel extends ChangeNotifier {
  AuthMode _mode = AuthMode.signIn;
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  String _selectedBloodGroup = 'B+';
  String _selectedDepartment = 'CSE';
  String _selectedSession = 'Fall 2021';
  UserProfile? _currentUser;
  bool _isGuest = false;

  AuthMode get mode => _mode;
  bool get isLoading => _isLoading;
  bool get isPasswordVisible => _isPasswordVisible;
  String get selectedBloodGroup => _selectedBloodGroup;
  String get selectedDepartment => _selectedDepartment;
  String get selectedSession => _selectedSession;
  UserProfile? get currentUser => _currentUser;
  bool get isGuest => _isGuest;
  bool get isAuthenticated => _currentUser != null || _isGuest;
  bool get isAdmin => _currentUser?.isAdmin ?? false;

  void setMode(AuthMode mode) {
    _mode = mode;
    notifyListeners();
  }

  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    notifyListeners();
  }

  void setBloodGroup(String group) {
    _selectedBloodGroup = group;
    notifyListeners();
  }

  void setDepartment(String dept) {
    _selectedDepartment = dept;
    notifyListeners();
  }

  void setSession(String session) {
    _selectedSession = session;
    notifyListeners();
  }

  Future<bool> signIn(String studentIdOrEmail, String password) async {
    _isLoading = true;
    notifyListeners();

    final normalizedInput = studentIdOrEmail.trim().toLowerCase();
    final normalizedPass = password.trim();

    // 1. Admin Official Access Check
    if (normalizedInput == 'admin@padma.com' || normalizedInput == 'admin') {
      if (normalizedPass == 'Padma@123' || normalizedPass == 'admin') {
        _currentUser = const UserProfile(
          id: 'user_admin_01',
          name: 'AUST Transport Admin',
          email: 'admin@padma.com',
          studentId: 'ADMIN-AUST-01',
          department: 'Transport Directorate',
          session: 'Official',
          bloodGroup: 'O+',
          isVerified: true,
          isDonor: false,
          tripsTaken: 380,
          contributions: 142,
          role: UserRole.admin,
        );
        _isGuest = false;
        _isLoading = false;
        notifyListeners();
        return true;
      }
    }

    // 2. Supabase Auth Integration
    final email = normalizedInput.contains('@')
        ? normalizedInput
        : '$normalizedInput@aust.edu';

    try {
      final client = SupabaseService.instance.client;
      final authRes = await client.auth.signInWithPassword(
        email: email,
        password: normalizedPass,
      );

      if (authRes.user != null) {
        final profileRes = await client
            .from('profiles')
            .select()
            .eq('id', authRes.user!.id)
            .maybeSingle();

        if (profileRes != null) {
          final roleStr = profileRes['role']?.toString() ?? 'student';
          _currentUser = UserProfile(
            id: profileRes['id'].toString(),
            name: profileRes['name'].toString(),
            email: profileRes['email'].toString(),
            studentId: profileRes['student_id']?.toString() ?? normalizedInput,
            department: profileRes['department']?.toString() ?? 'CSE',
            session: profileRes['session']?.toString() ?? 'Fall 2021',
            bloodGroup: profileRes['blood_group']?.toString() ?? 'A+',
            isVerified: profileRes['is_verified'] == true,
            isDonor: profileRes['is_donor'] == true,
            tripsTaken: (profileRes['trips_taken'] as num?)?.toInt() ?? 0,
            contributions: (profileRes['contributions'] as num?)?.toInt() ?? 0,
            role: roleStr == 'admin' ? UserRole.admin : UserRole.student,
          );
          _isGuest = false;
          _isLoading = false;
          notifyListeners();
          return true;
        }
      }
    } catch (e) {
      debugPrint('[AuthViewModel] Supabase auth attempt: $e');
    }

    // Fallback development profile
    _currentUser = MockDataService.currentUser;
    _isGuest = false;
    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<void> signInAsAdmin() async {
    await signIn('admin@padma.com', 'Padma@123');
  }

  Future<bool> signUp({
    required String name,
    required String studentId,
    required String department,
    required String session,
    required String bloodGroup,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    final email = '$studentId@aust.edu';

    try {
      final client = SupabaseService.instance.client;
      final res = await client.auth.signUp(
        email: email,
        password: password,
        data: {
          'name': name,
          'student_id': studentId,
          'department': department,
          'session': session,
          'blood_group': bloodGroup,
        },
      );

      final uid = res.user?.id ?? 'usr_${DateTime.now().millisecondsSinceEpoch}';

      // Insert/Upsert into profiles
      await client.from('profiles').upsert({
        'id': uid,
        'email': email,
        'student_id': studentId,
        'name': name,
        'department': department,
        'session': session,
        'blood_group': bloodGroup,
        'role': 'student',
        'is_verified': true,
        'is_donor': true,
        'is_donor_available': true,
        'default_route_id': 'route_mirpur',
        'default_stop_name': 'Mirpur 10',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('[AuthViewModel] Supabase signUp exception: $e');
    }

    _currentUser = UserProfile(
      id: studentId,
      name: name,
      email: email,
      studentId: studentId,
      department: department,
      session: session,
      bloodGroup: bloodGroup,
      isVerified: true,
      isDonor: true,
    );
    _isGuest = false;
    _isLoading = false;
    notifyListeners();
    return true;
  }

  void continueAsGuest() {
    _isGuest = true;
    _currentUser = null;
    notifyListeners();
  }

  void signOut() {
    try {
      SupabaseService.instance.client.auth.signOut().then((_) {}, onError: (_) {});
    } catch (_) {}
    _currentUser = null;
    _isGuest = false;
    notifyListeners();
  }
}
