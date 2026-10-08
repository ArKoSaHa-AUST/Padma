import 'package:flutter/material.dart';

enum NotificationType {
  transit,
  journeyStart,
  destinationArrival,
  announcement,
  rules,
  mention,
  blood,
  lostFound,
  complain,
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
  bool isRead;
  final String? relatedChannel;

  NotificationItem({
    required this.id,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.type,
    required this.icon,
    required this.color,
    this.isRead = false,
    this.relatedChannel,
  });

  String get body => description;
  String? get targetChannel => relatedChannel;

  NotificationItem copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? timestamp,
    NotificationType? type,
    IconData? icon,
    Color? color,
    bool? isRead,
    String? relatedChannel,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      isRead: isRead ?? this.isRead,
      relatedChannel: relatedChannel ?? this.relatedChannel,
    );
  }
}
