import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/notification_model.dart';
import '../mock/mock_notifications.dart';
import 'supabase_notification_repository.dart';


abstract class NotificationRepository {
  Stream<List<NotificationModel>> getNotificationsStream();
  Future<void> markAllAsRead();
  Future<void> markAsRead(String id);
  Future<void> dismiss(String id);
  void dispose();
}

class InMemoryNotificationRepository implements NotificationRepository {
  final List<NotificationModel> _notifications =
      List.from(MockNotifications.initialNotifications);
  final _controller = StreamController<List<NotificationModel>>.broadcast();

  InMemoryNotificationRepository() {
    _emit();
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
  }

  @override
  Future<void> markAsRead(String id) async {
    final idx = _notifications.indexWhere((n) => n.id == id);
    if (idx != -1) {
      _notifications[idx] = _notifications[idx].copyWith(isRead: true);
      _emit();
    }
  }

  @override
  Future<void> dismiss(String id) async {
    _notifications.removeWhere((n) => n.id == id);
    _emit();
  }

  @override
  void dispose() {
    _controller.close();
  }
}

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  final repo = SupabaseNotificationRepository();
  ref.onDispose(repo.dispose);
  return repo;
});


final notificationsListProvider = StreamProvider<List<NotificationModel>>((ref) {
  final repo = ref.watch(notificationRepositoryProvider);
  return repo.getNotificationsStream();
});
