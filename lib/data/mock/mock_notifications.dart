import '../models/notification_model.dart';

class MockNotifications {
  static List<NotificationModel> get initialNotifications => [
        NotificationModel(
          id: 'notif_1',
          title: 'Bus 1 Arrival Alert',
          body: 'Bus 1 (Mirpur) will reach your stop Mirpur 10 in approximately 5 minutes.',
          type: NotificationType.arrivalAlert,
          createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
          isRead: false,
          routeOrChannelId: 'route_mirpur',
        ),
        NotificationModel(
          id: 'notif_2',
          title: 'Urgent Blood Needed: B+',
          body: '2 units B+ blood needed at Dhaka Medical College Hospital for student family member.',
          type: NotificationType.bloodRequest,
          createdAt: DateTime.now().subtract(const Duration(minutes: 40)),
          isRead: false,
          routeOrChannelId: 'requests',
        ),
        NotificationModel(
          id: 'notif_3',
          title: 'Flyover Maintenance Route Change',
          body: 'Bus 2 (Uttara) is rerouted via Jahangir Gate due to maintenance.',
          type: NotificationType.announcement,
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
          isRead: false,
          routeOrChannelId: 'announcements',
        ),
        NotificationModel(
          id: 'notif_4',
          title: 'Traffic Delay Notice',
          body: 'Bus 3 (Mohammadpur) is experiencing slow traffic near Farmgate.',
          type: NotificationType.delay,
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          isRead: true,
          routeOrChannelId: 'route_mohammadpur',
        ),
      ];
}
