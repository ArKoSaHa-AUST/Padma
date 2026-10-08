// ignore_for_file: close_sinks
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/channel_model.dart';
import '../models/message_model.dart';
import '../models/user_model.dart';
import '../mock/mock_channels.dart';
import '../mock/mock_messages.dart';
import 'chat_repository.dart';
import '../services/supabase_service.dart';

/// Dynamic Supabase-backed implementation of [ChatRepository].
/// Handles real-time messaging, announcements, and reactions via Supabase Realtime.
class SupabaseChatRepository implements ChatRepository {
  final SupabaseClient _client;

  List<ChannelModel> _channels = List.from(MockChannels.allChannels);
  final Map<String, List<MessageModel>> _messagesCache = {
    'announcements': List.from(MockMessages.initialAnnouncements),
    'general': List.from(MockMessages.initialGeneralMessages),
    'bus-1-mirpur': List.from(MockMessages.initialBus1Messages),
  };

  final Map<String, StreamController<List<MessageModel>>> _controllers = {};
  final Map<String, StreamSubscription<List<Map<String, dynamic>>>> _subscriptions = {};

  SupabaseChatRepository({SupabaseClient? client})
      : _client = client ?? SupabaseService.instance.client {
    _initChannels();
  }

  Future<void> _initChannels() async {
    try {
      final res = await _client.from('channels').select().eq('is_active', true);
      if (res.isNotEmpty) {
        _channels = res.map((r) {
          final catStr = r['category']?.toString() ?? 'community';
          ChannelCategory category = ChannelCategory.community;
          if (catStr == 'info') category = ChannelCategory.info;
          if (catStr == 'buses') category = ChannelCategory.buses;

          final typeStr = r['type']?.toString() ?? 'general';
          ChannelType type = ChannelType.general;
          if (typeStr == 'announcement' || typeStr == 'announcements') type = ChannelType.announcement;
          if (typeStr == 'schedule') type = ChannelType.schedule;
          if (typeStr == 'request' || typeStr == 'requests' || typeStr == 'emergency') type = ChannelType.request;
          if (typeStr == 'lostFound' || typeStr == 'lost-and-found') type = ChannelType.lostFound;
          if (typeStr == 'feedback') type = ChannelType.feedback;
          if (typeStr == 'bus' || typeStr == 'buses') type = ChannelType.bus;

          return ChannelModel(
            id: r['id'].toString(),
            name: r['name'].toString(),
            subtitle: r['subtitle']?.toString() ?? r['description']?.toString(),
            category: category,
            type: type,
            isReadOnlyForStudents: r['is_read_only_for_students'] == true || type == ChannelType.announcement || type == ChannelType.schedule,
            unreadCount: (r['unread_count'] as num?)?.toInt() ?? 0,
            busId: r['bus_id']?.toString() ?? r['route_id']?.toString(),
          );
        }).toList();
      }
    } catch (e) {
      debugPrint('[SupabaseChatRepository] Error loading channels: $e');
    }
  }

  StreamController<List<MessageModel>> _getController(String channelId) {
    if (!_controllers.containsKey(channelId) || _controllers[channelId]!.isClosed) {
      _controllers[channelId] = StreamController<List<MessageModel>>.broadcast();
      _subscribeToChannelRealtime(channelId);
    }
    return _controllers[channelId]!;
  }

  void _subscribeToChannelRealtime(String channelId) {
    if (_subscriptions.containsKey(channelId)) return;

    try {
      _subscriptions[channelId] = _client
          .from('messages')
          .stream(primaryKey: ['id'])
          .eq('channel_id', channelId)
          .order('created_at', ascending: true)
          .listen((records) {
        final List<MessageModel> list = records.map((r) {
          final reactionsRaw = r['reactions'];
          final Map<String, int> reactionsMap = {};
          if (reactionsRaw is Map) {
            reactionsRaw.forEach((k, v) {
              reactionsMap[k.toString()] = (v as num).toInt();
            });
          }

          final senderRoleStr = r['sender_role']?.toString() ?? 'student';
          UserRole senderRole = UserRole.student;
          if (senderRoleStr == 'admin') senderRole = UserRole.admin;
          if (senderRoleStr == 'driver') senderRole = UserRole.driver;

          return MessageModel(
            id: r['id']?.toString() ?? '',
            channelId: r['channel_id']?.toString() ?? channelId,
            senderId: r['sender_id']?.toString() ?? '',
            senderName: r['sender_name']?.toString() ?? '',
            senderRole: senderRole,
            senderAvatar: r['sender_avatar']?.toString(),
            text: r['text']?.toString() ?? '',
            imageUrl: r['image_url']?.toString(),
            isUrgent: r['is_urgent'] == true,
            isPinned: r['is_pinned'] == true,
            createdAt: r['created_at'] != null
                ? DateTime.tryParse(r['created_at'].toString()) ?? DateTime.now()
                : DateTime.now(),
            reactions: reactionsMap,
            replyToSenderName: r['reply_to_sender_name']?.toString(),
            replyToText: r['reply_to_text']?.toString(),
          );
        }).toList();

        _messagesCache[channelId] = list;
        final controller = _controllers[channelId];
        if (controller != null && !controller.isClosed) {
          controller.add(List.unmodifiable(list));
        }
      }, onError: (err) {
        debugPrint('[SupabaseChatRepository] Stream error on $channelId: $err');
      });
    } catch (e) {
      debugPrint('[SupabaseChatRepository] Exception in _subscribeToChannelRealtime: $e');
    }
  }

  @override
  List<ChannelModel> getChannels() => List.unmodifiable(_channels);

  @override
  ChannelModel getChannelById(String channelId) {
    return _channels.firstWhere(
      (c) => c.id == channelId,
      orElse: () => _channels.first,
    );
  }

  @override
  Stream<List<MessageModel>> getMessagesStream(String channelId) {
    final controller = _getController(channelId);
    final initial = _messagesCache[channelId] ?? [];
    Future.microtask(() {
      if (!controller.isClosed) {
        controller.add(List.unmodifiable(initial));
      }
    });
    return controller.stream;
  }

  @override
  Future<void> sendMessage({
    required String channelId,
    required String text,
    required UserModel sender,
    String? replyToSenderName,
    String? replyToText,
    String? imageUrl,
  }) async {
    final msgId = 'msg_${DateTime.now().millisecondsSinceEpoch}';
    final newMsg = MessageModel(
      id: msgId,
      channelId: channelId,
      senderId: sender.id,
      senderName: sender.name,
      senderRole: sender.role,
      senderAvatar: sender.avatarUrl,
      text: text,
      imageUrl: imageUrl,
      createdAt: DateTime.now(),
      replyToSenderName: replyToSenderName,
      replyToText: replyToText,
    );

    // Optimistic local cache update
    final list = _messagesCache.putIfAbsent(channelId, () => []);
    list.add(newMsg);
    final controller = _controllers[channelId];
    if (controller != null && !controller.isClosed) {
      controller.add(List.unmodifiable(list));
    }

    // Persist to Supabase
    try {
      await _client.from('messages').insert({
        'id': msgId,
        'channel_id': channelId,
        'sender_id': sender.id,
        'sender_name': sender.name,
        'sender_role': sender.role.name,
        'sender_avatar': sender.avatarUrl,
        'text': text,
        'image_url': imageUrl,
        'is_urgent': false,
        'is_pinned': false,
        'reply_to_sender_name': replyToSenderName,
        'reply_to_text': replyToText,
        'reactions': {},
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('[SupabaseChatRepository] Error inserting message: $e');
    }
  }

  @override
  Future<void> sendAnnouncement({
    required String text,
    required UserModel sender,
    bool isUrgent = false,
    bool isPinned = false,
  }) async {
    final annId = 'ann_${DateTime.now().millisecondsSinceEpoch}';
    final newMsg = MessageModel(
      id: annId,
      channelId: 'announcements',
      senderId: sender.id,
      senderName: sender.name,
      senderRole: UserRole.admin,
      text: text,
      isUrgent: isUrgent,
      isPinned: isPinned,
      createdAt: DateTime.now(),
      reactions: {'👍': 1},
    );

    final list = _messagesCache.putIfAbsent('announcements', () => []);
    list.insert(0, newMsg);
    final controller = _controllers['announcements'];
    if (controller != null && !controller.isClosed) {
      controller.add(List.unmodifiable(list));
    }

    // Persist to Supabase messages & admin_announcements
    try {
      await _client.from('messages').insert({
        'id': annId,
        'channel_id': 'announcements',
        'sender_id': sender.id,
        'sender_name': sender.name,
        'sender_role': 'admin',
        'text': text,
        'is_urgent': isUrgent,
        'is_pinned': isPinned,
        'badge_text': isUrgent ? 'URGENT NOTICE' : 'OFFICIAL NOTICE',
        'reactions': {'👍': 1},
        'created_at': DateTime.now().toIso8601String(),
      });

      await _client.from('admin_announcements').insert({
        'id': annId,
        'title': isUrgent ? 'Urgent Official Advisory' : 'Transport Notice',
        'body': text,
        'priority': isUrgent ? 'Urgent' : 'High',
        'target_route': 'All Routes',
        'is_pinned': isPinned,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('[SupabaseChatRepository] Error inserting announcement: $e');
    }
  }

  @override
  Future<void> toggleReaction({
    required String channelId,
    required String messageId,
    required String emoji,
    required String userId,
  }) async {
    final list = _messagesCache[channelId];
    if (list == null) return;
    final idx = list.indexWhere((m) => m.id == messageId);
    if (idx == -1) return;

    final msg = list[idx];
    final userReactions = List<String>.from(msg.userReactions);
    final currentReactions = Map<String, int>.from(msg.reactions);

    if (userReactions.contains(emoji)) {
      userReactions.remove(emoji);
      final count = (currentReactions[emoji] ?? 1) - 1;
      if (count <= 0) {
        currentReactions.remove(emoji);
      } else {
        currentReactions[emoji] = count;
      }
    } else {
      userReactions.add(emoji);
      currentReactions[emoji] = (currentReactions[emoji] ?? 0) + 1;
    }

    list[idx] = msg.copyWith(
      reactions: currentReactions,
      userReactions: userReactions,
    );

    final controller = _controllers[channelId];
    if (controller != null && !controller.isClosed) {
      controller.add(List.unmodifiable(list));
    }

    // Update in Supabase
    try {
      await _client.from('messages').update({
        'reactions': currentReactions,
      }).eq('id', messageId);
    } catch (e) {
      debugPrint('[SupabaseChatRepository] Error updating reaction in Supabase: $e');
    }
  }

  @override
  void dispose() {
    for (final sub in _subscriptions.values) {
      sub.cancel();
    }
    _subscriptions.clear();

    for (final controller in _controllers.values) {
      controller.close();
    }
    _controllers.clear();
  }
}
