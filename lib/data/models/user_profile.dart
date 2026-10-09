import 'user_model.dart';
export 'user_model.dart' show UserRole;

class UserProfile {
  final String id;
  final String name;
  final String email;
  final String studentId;
  final String department;
  final String semester;
  final String session;
  final String bloodGroup;
  final String pickupDestination;
  final String contactNumber;
  final bool isVerified;
  final bool isDonor;
  final UserRole role;

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.studentId,
    required this.department,
    this.semester = '4-1',
    required this.session,
    required this.bloodGroup,
    this.pickupDestination = 'Mirpur 10',
    this.contactNumber = '+880 1711-000000',
    this.isVerified = true,
    this.isDonor = true,
    this.role = UserRole.student,
  });

  bool get isAdmin => role == UserRole.admin;
  String? get phone => contactNumber;

  String get firstName {
    final parts = name.trim().split(RegExp(r'\s+'));
    return parts.isNotEmpty ? parts.first : 'User';
  }

  /// Formatted identifier for chat: firstname_departmentName_semester_pickupDestination
  String get chatTag {
    String clean(String s) => s.replaceAll(RegExp(r'[^a-zA-Z0-9-]'), '');
    final fName = clean(firstName.isEmpty ? 'Student' : firstName);
    final dept = clean(department.isEmpty ? 'CSE' : department);
    final sem = clean(semester.isEmpty ? '4-1' : semester);
    final dest = clean(pickupDestination.isEmpty ? 'Campus' : pickupDestination);
    return '${fName}_${dept}_${sem}_$dest';
  }

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? studentId,
    String? department,
    String? semester,
    String? session,
    String? bloodGroup,
    String? pickupDestination,
    String? contactNumber,
    bool? isVerified,
    bool? isDonor,
    UserRole? role,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      studentId: studentId ?? this.studentId,
      department: department ?? this.department,
      semester: semester ?? this.semester,
      session: session ?? this.session,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      pickupDestination: pickupDestination ?? this.pickupDestination,
      contactNumber: contactNumber ?? this.contactNumber,
      isVerified: isVerified ?? this.isVerified,
      isDonor: isDonor ?? this.isDonor,
      role: role ?? this.role,
    );
  }
}
