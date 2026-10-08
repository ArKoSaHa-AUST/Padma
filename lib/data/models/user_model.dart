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
  final String semester;
  final String pickupDestination;
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
    this.semester = '4-1',
    this.pickupDestination = 'Mirpur 10',
    required this.role,
    this.bloodGroup,
    required this.defaultRouteId,
    required this.defaultStopName,
    this.avatarUrl,
    this.isDonorAvailable = true,
  });

  String get firstName {
    final parts = name.trim().split(RegExp(r'\s+'));
    return parts.isNotEmpty ? parts.first : 'User';
  }

  /// Formatted chat tag: firstname_departmentName_semester_pickupDestination
  String get chatTag {
    String clean(String s) => s.replaceAll(RegExp(r'[^a-zA-Z0-9-]'), '');
    final fName = clean(firstName.isEmpty ? 'Student' : firstName);
    final dept = clean(department.isEmpty ? 'CSE' : department);
    final sem = clean(semester.isEmpty ? '4-1' : semester);
    final dest = clean(pickupDestination.isEmpty ? 'Campus' : pickupDestination);
    return '${fName}_${dept}_${sem}_$dest';
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? studentId,
    String? email,
    String? department,
    String? semester,
    String? pickupDestination,
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
      semester: semester ?? this.semester,
      pickupDestination: pickupDestination ?? this.pickupDestination,
      role: role ?? this.role,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      defaultRouteId: defaultRouteId ?? this.defaultRouteId,
      defaultStopName: defaultStopName ?? this.defaultStopName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isDonorAvailable: isDonorAvailable ?? this.isDonorAvailable,
    );
  }
}

