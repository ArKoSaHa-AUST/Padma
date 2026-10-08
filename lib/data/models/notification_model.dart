enum NotificationType {
  announcement,
  bloodRequest,
  arrivalAlert,
  delay;

  String get label {
    switch (this) {
      case NotificationType.announcement:
        return 'Announcement';
      case NotificationType.bloodRequest:
        return 'Blood Needed';
      case NotificationType.arrivalAlert:
        return 'Arrival Alert';
      case NotificationType.delay:
        return 'Route Delay';
    }
  }
}

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final DateTime createdAt;
  final bool isRead;
  final String? routeOrChannelId;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.createdAt,
    this.isRead = false,
    this.routeOrChannelId,
  });

  NotificationModel copyWith({
    String? id,
    String? title,
    String? body,
    NotificationType? type,
    DateTime? createdAt,
    bool? isRead,
    String? routeOrChannelId,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      routeOrChannelId: routeOrChannelId ?? this.routeOrChannelId,
    );
  }
}
