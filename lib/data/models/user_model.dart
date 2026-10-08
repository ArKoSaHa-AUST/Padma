enum UserRole {
  student,
  admin,
  driver;

  String get displayName {
    switch (this) {
      case UserRole.admin:
        return 'Admin';
      case UserRole.driver:
        return 'Driver';
      case UserRole.student:
        return 'Student';
    }
  }
}

class UserModel {
  final String id;
  final String name;
  final String studentId;
  final String email;
  final String department;
  final UserRole role;
  final String? bloodGroup;
  final String defaultRouteId;
  final String defaultStopName;
  final String? avatarUrl;
  final bool isDonorAvailable;

  const UserModel({
    required this.id,
    required this.name,
    required this.studentId,
    required this.email,
    required this.department,
    required this.role,
    this.bloodGroup,
    required this.defaultRouteId,
    required this.defaultStopName,
    this.avatarUrl,
    this.isDonorAvailable = true,
  });

  UserModel copyWith({
    String? id,
    String? name,
    String? studentId,
    String? email,
    String? department,
    UserRole? role,
    String? bloodGroup,
    String? defaultRouteId,
    String? defaultStopName,
    String? avatarUrl,
    bool? isDonorAvailable,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      studentId: studentId ?? this.studentId,
      email: email ?? this.email,
      department: department ?? this.department,
      role: role ?? this.role,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      defaultRouteId: defaultRouteId ?? this.defaultRouteId,
      defaultStopName: defaultStopName ?? this.defaultStopName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isDonorAvailable: isDonorAvailable ?? this.isDonorAvailable,
    );
  }
}
