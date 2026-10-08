import '../models/user_model.dart';

class MockUsers {
  static const UserModel studentUser = UserModel(
    id: 'user_student_padma',
    name: 'Padma Student',
    studentId: '2023202420252026',
    email: 'padmaStudent@aust.edu',
    department: 'CSE',
    semester: '4-1',
    pickupDestination: 'Mirpur 10',
    role: UserRole.student,
    bloodGroup: 'O+',
    defaultRouteId: 'bus-1',
    defaultStopName: 'Mirpur 10',
    avatarUrl: null,
    isDonorAvailable: true,
  );

  static const UserModel adminUser = UserModel(
    id: 'user_admin_rafiq',
    name: 'Engr. Rafiqul Islam',
    studentId: 'ADMIN-AUST-01',
    email: 'admin@aust.edu',
    department: 'Transport Directorate',
    semester: 'Staff',
    pickupDestination: 'AUST Campus',
    role: UserRole.admin,
    bloodGroup: 'O+',
    defaultRouteId: 'bus-1',
    defaultStopName: 'AUST Campus',
    avatarUrl: null,
    isDonorAvailable: false,
  );

  static const UserModel adminUser2 = UserModel(
    id: 'user_admin_shahed',
    name: 'Dr. Shahed Rahman',
    studentId: 'ADMIN-AUST-02',
    email: 'shahed.admin@aust.edu',
    department: 'Student Affairs',
    semester: 'Staff',
    pickupDestination: 'AUST Campus',
    role: UserRole.admin,
    bloodGroup: 'A+',
    defaultRouteId: 'bus-2',
    defaultStopName: 'AUST Campus',
    avatarUrl: null,
    isDonorAvailable: false,
  );

  static const UserModel driverUser = UserModel(
    id: 'user_driver_1',
    name: 'Md. Rafiqul Islam (Driver)',
    studentId: 'DRV-08',
    email: 'rafiq.driver@aust.edu',
    department: 'Motor Pool',
    semester: 'Staff',
    pickupDestination: 'Mirpur 12',
    role: UserRole.driver,
    bloodGroup: 'A+',
    defaultRouteId: 'bus-1',
    defaultStopName: 'Mirpur 12',
    avatarUrl: null,
    isDonorAvailable: true,
  );
}
