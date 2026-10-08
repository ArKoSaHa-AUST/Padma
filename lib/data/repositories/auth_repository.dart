import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../mock/mock_users.dart';
import 'supabase_auth_repository.dart';


abstract class AuthRepository {
  UserModel? get currentUser;
  Stream<UserModel?> get authStateChanges;
  Future<UserModel> signIn({required String emailOrStudentId, required String password});
  Future<UserModel> signUp({
    required String name,
    required String studentId,
    required String email,
    required String department,
    required String password,
  });
  Future<void> sendOtp(String email);
  Future<bool> verifyOtp(String email, String otp);
  Future<void> resetPassword(String email, String newPassword);
  Future<void> updateProfile({
    String? name,
    String? department,
    String? bloodGroup,
    String? defaultRouteId,
    String? defaultStopName,
  });
  Future<void> toggleDonorAvailability(bool isAvailable);
  Future<void> switchRole(UserRole role);
  Future<void> logout();
}

class InMemoryAuthRepository implements AuthRepository {
  UserModel? _currentUser = MockUsers.studentUser;
  final _controller = StreamController<UserModel?>.broadcast();

  InMemoryAuthRepository() {
    _controller.add(_currentUser);
  }

  @override
  UserModel? get currentUser => _currentUser;

  @override
  Stream<UserModel?> get authStateChanges => _controller.stream;

  @override
  Future<UserModel> signIn({required String emailOrStudentId, required String password}) async {
    await Future.delayed(const Duration(milliseconds: 600));
    _currentUser = MockUsers.studentUser.copyWith(
      email: emailOrStudentId.contains('@') ? emailOrStudentId : MockUsers.studentUser.email,
      studentId: !emailOrStudentId.contains('@') ? emailOrStudentId : MockUsers.studentUser.studentId,
    );
    _controller.add(_currentUser);
    return _currentUser!;
  }

  @override
  Future<UserModel> signUp({
    required String name,
    required String studentId,
    required String email,
    required String department,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));
    _currentUser = UserModel(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      studentId: studentId,
      email: email,
      department: department,
      role: UserRole.student,
      bloodGroup: 'A+',
      defaultRouteId: 'route_mirpur',
      defaultStopName: 'Mirpur 10',
      isDonorAvailable: true,
    );
    _controller.add(_currentUser);
    return _currentUser!;
  }

  @override
  Future<void> sendOtp(String email) async {
    await Future.delayed(const Duration(milliseconds: 400));
  }

  @override
  Future<bool> verifyOtp(String email, String otp) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return otp.length == 6;
  }

  @override
  Future<void> resetPassword(String email, String newPassword) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<void> updateProfile({
    String? name,
    String? department,
    String? bloodGroup,
    String? defaultRouteId,
    String? defaultStopName,
  }) async {
    if (_currentUser == null) return;
    _currentUser = _currentUser!.copyWith(
      name: name,
      department: department,
      bloodGroup: bloodGroup,
      defaultRouteId: defaultRouteId,
      defaultStopName: defaultStopName,
    );
    _controller.add(_currentUser);
  }

  @override
  Future<void> toggleDonorAvailability(bool isAvailable) async {
    if (_currentUser == null) return;
    _currentUser = _currentUser!.copyWith(isDonorAvailable: isAvailable);
    _controller.add(_currentUser);
  }

  @override
  Future<void> switchRole(UserRole role) async {
    if (_currentUser == null) return;
    _currentUser = _currentUser!.copyWith(role: role);
    _controller.add(_currentUser);
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _currentUser = null;
    _controller.add(null);
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return SupabaseAuthRepository();
});

final authStateProvider = StreamProvider<UserModel?>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return repo.authStateChanges;
});


