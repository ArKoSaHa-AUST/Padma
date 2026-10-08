import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/notification_model.dart';
import '../mock/mock_notifications.dart';
import 'notification_repository.dart';
import '../services/supabase_service.dart';

/// Dynamic Supabase-backed implementation of [NotificationRepository].
class SupabaseNotificationRepository implements NotificationRepository {
  final SupabaseClient _client;

  List<NotificationModel> _notifications =
      List.from(MockNotifications.initialNotifications);
  final _controller = StreamController<List<NotificationModel>>.broadcast();
  StreamSubscription<List<Map<String, dynamic>>>? _subscription;

  SupabaseNotificationRepository({SupabaseClient? client})
      : _client = client ?? SupabaseService.instance.client {
    _initStream();
  }

  void _initStream() {
    try {
      _subscription = _client
          .from('notifications')
          .stream(primaryKey: ['id'])
          .order('created_at', ascending: false)
          .listen((records) {
        final List<NotificationModel> list = records.map((r) {
          final typeStr = r['type']?.toString() ?? 'announcement';
          NotificationType type = NotificationType.announcement;
          if (typeStr == 'blood' || typeStr == 'bloodRequest') type = NotificationType.bloodRequest;
          if (typeStr == 'transit' || typeStr == 'arrivalAlert') type = NotificationType.arrivalAlert;
          if (typeStr == 'delay') type = NotificationType.delay;

          return NotificationModel(
            id: r['id']?.toString() ?? '',
            title: r['title']?.toString() ?? '',
            body: r['body']?.toString() ?? '',
            type: type,
            isRead: r['is_read'] == true,
            createdAt: r['created_at'] != null
                ? DateTime.tryParse(r['created_at'].toString()) ?? DateTime.now()
                : DateTime.now(),
            routeOrChannelId: r['route_or_channel_id']?.toString() ?? r['route_id']?.toString(),
          );
        }).toList();

        if (list.isNotEmpty) {
          _notifications = list;
        }

        _emit();
      }, onError: (err) {
        debugPrint('[SupabaseNotificationRepository] Stream error: $err');
      });
    } catch (e) {
      debugPrint('[SupabaseNotificationRepository] Exception in _initStream: $e');
    }
  }

  void _emit() {
    if (!_controller.isClosed) {
      _controller.add(List.unmodifiable(_notifications));
    }
  }

  @override
  Stream<List<NotificationModel>> getNotificationsStream() {
    Future.microtask(_emit);
    return _controller.stream;
  }

  @override
  Future<void> markAllAsRead() async {
    for (int i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
    _emit();

    try {
      await _client.from('notifications').update({'is_read': true}).neq('id', '');
    } catch (e) {
      debugPrint('[SupabaseNotificationRepository] markAllAsRead error: $e');
    }
  }

  @override
  Future<void> markAsRead(String id) async {
    final idx = _notifications.indexWhere((n) => n.id == id);
    if (idx != -1) {
      _notifications[idx] = _notifications[idx].copyWith(isRead: true);
      _emit();

      try {
        await _client.from('notifications').update({'is_read': true}).eq('id', id);
      } catch (e) {
        debugPrint('[SupabaseNotificationRepository] markAsRead error: $e');
      }
    }
  }

  @override
  Future<void> dismiss(String id) async {
    _notifications.removeWhere((n) => n.id == id);
    _emit();

    try {
      await _client.from('notifications').delete().eq('id', id);
    } catch (e) {
      debugPrint('[SupabaseNotificationRepository] dismiss error: $e');
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _controller.close();
  }
}
