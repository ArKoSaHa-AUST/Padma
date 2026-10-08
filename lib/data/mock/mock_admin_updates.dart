import '../models/admin_update_model.dart';

class MockAdminUpdates {
  static List<AdminUpdateModel> get initialUpdates => [
        AdminUpdateModel(
          id: 'adm_up_1',
          authorName: 'Transport Officer',
          text: 'Bus 1 will wait at Mirpur 10 until 10:30 AM due to scheduled lab batch delay.',
          busId: 'bus_1',
          busName: 'Bus 1 • Mirpur',
          isPinned: true,
          isUrgent: false,
          createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
        ),
        AdminUpdateModel(
          id: 'adm_up_2',
          authorName: 'Transport Office',
          text: 'Evening return buses will start boarding at 05:05 PM at AUST Campus Main Gate.',
          isPinned: false,
          isUrgent: false,
          createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        ),
        AdminUpdateModel(
          id: 'adm_up_3',
          authorName: 'Admin Control',
          text: 'Rain forecast in Tejgaon area. Drivers are advised to maintain 30 km/h corridor speed.',
          isPinned: false,
          isUrgent: true,
          createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        ),
      ];
}
