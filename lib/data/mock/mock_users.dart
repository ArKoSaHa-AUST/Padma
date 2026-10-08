import '../models/user_model.dart';

class MockUsers {
  static const UserModel studentUser = UserModel(
    id: 'user_student_1',
    name: 'Rakib Hasan',
    studentId: '20-01234-1',
    email: 'rakib.hasan@aust.edu',
    department: 'CSE',
    role: UserRole.student,
    bloodGroup: 'B+',
    defaultRouteId: 'route_mirpur',
    defaultStopName: 'Mirpur 10',
    avatarUrl: null,
    isDonorAvailable: true,
  );

  static const UserModel adminUser = UserModel(
    id: 'user_admin_1',
    name: 'Transport Office (Engr. Kamal)',
    studentId: 'ADM-102',
    email: 'transport@aust.edu',
    department: 'Transport Division',
    role: UserRole.admin,
    bloodGroup: 'O+',
    defaultRouteId: 'route_mirpur',
    defaultStopName: 'AUST Campus',
    avatarUrl: null,
    isDonorAvailable: false,
  );

  static const UserModel driverUser = UserModel(
    id: 'user_driver_1',
    name: 'Md. Rafiqul Islam',
    studentId: 'DRV-08',
    email: 'rafiq.driver@aust.edu',
    department: 'Motor Pool',
    role: UserRole.driver,
    bloodGroup: 'A+',
    defaultRouteId: 'route_mirpur',
    defaultStopName: 'Mirpur 12',
    avatarUrl: null,
    isDonorAvailable: true,
  );
}
