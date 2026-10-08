import 'package:flutter/material.dart';
import '../../../../data/models/user_profile.dart';
import '../../../../data/services/mock_data_service.dart';

import '../../../../data/models/user_model.dart';

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

    await Future.delayed(const Duration(milliseconds: 600));

    final normalizedInput = studentIdOrEmail.trim().toLowerCase();
    final normalizedPass = password.trim();

    // Check for Admin credentials (admin@padma.com / Padma@123)
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

    await Future.delayed(const Duration(milliseconds: 700));
    _currentUser = UserProfile(
      id: studentId,
      name: name,
      email: '$studentId@aust.edu',
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
    _currentUser = null;
    _isGuest = false;
    notifyListeners();
  }
}
