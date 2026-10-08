import 'user_model.dart';
export 'user_model.dart' show UserRole;

class UserProfile {
  final String id;
  final String name;
  final String email;
  final String studentId;
  final String department;
  final String session;
  final String bloodGroup;
  final bool isVerified;
  final bool isDonor;
  final int tripsTaken;
  final int contributions;
  final UserRole role;

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.studentId,
    required this.department,
    required this.session,
    required this.bloodGroup,
    this.isVerified = true,
    this.isDonor = true,
    this.tripsTaken = 42,
    this.contributions = 18,
    this.role = UserRole.student,
  });

  bool get isAdmin => role == UserRole.admin;
}
