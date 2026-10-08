import 'package:flutter/material.dart';

enum NotificationType {
  transit,
  blood,
  info,
  warning,
}

class NotificationItem {
  final String id;
  final String title;
  final String description;
  final DateTime timestamp;
  final NotificationType type;
  final IconData icon;
  final Color color;
  final bool isRead;

  const NotificationItem({
    required this.id,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.type,
    required this.icon,
    required this.color,
    this.isRead = false,
  });
}
