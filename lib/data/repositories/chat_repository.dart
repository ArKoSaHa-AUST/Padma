// ignore_for_file: close_sinks
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/channel_model.dart';
import '../models/message_model.dart';
import '../models/user_model.dart';
import '../mock/mock_channels.dart';
import '../mock/mock_messages.dart';
import 'supabase_chat_repository.dart';


abstract class ChatRepository {
  List<ChannelModel> getChannels();
  ChannelModel getChannelById(String channelId);
  Stream<List<MessageModel>> getMessagesStream(String channelId);
  Future<void> sendMessage({
    required String channelId,
    required String text,
    required UserModel sender,
    String? replyToSenderName,
    String? replyToText,
    String? imageUrl,
  });
  Future<void> sendAnnouncement({
    required String text,
    required UserModel sender,
    bool isUrgent = false,
    bool isPinned = false,
  });
  Future<void> toggleReaction({
    required String channelId,
    required String messageId,
    required String emoji,
    required String userId,
  });
  void dispose();
}

class InMemoryChatRepository implements ChatRepository {
  final List<ChannelModel> _channels = List.from(MockChannels.allChannels);
  final Map<String, List<MessageModel>> _messages = {
    'announcements': List.from(MockMessages.initialAnnouncements),
    'general': List.from(MockMessages.initialGeneralMessages),
    'bus-1-mirpur': List.from(MockMessages.initialBus1Messages),
  };

  final Map<String, StreamController<List<MessageModel>>> _controllers = {};

  StreamController<List<MessageModel>> _getController(String channelId) {
    if (!_controllers.containsKey(channelId) || _controllers[channelId]!.isClosed) {
      _controllers[channelId] = StreamController<List<MessageModel>>.broadcast();
    }
    return _controllers[channelId]!;
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
    final initialList = _messages[channelId] ?? [];
    // Emit initial
    Future.microtask(() {
      if (!controller.isClosed) {
        controller.add(List.unmodifiable(initialList));
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
    final list = _messages.putIfAbsent(channelId, () => []);
    final newMessage = MessageModel(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
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
    list.add(newMessage);
    final controller = _getController(channelId);
    if (!controller.isClosed) {
      controller.add(List.unmodifiable(list));
    }
  }

  @override
  Future<void> sendAnnouncement({
    required String text,
    required UserModel sender,
    bool isUrgent = false,
    bool isPinned = false,
  }) async {
    final list = _messages.putIfAbsent('announcements', () => []);
    final newMessage = MessageModel(
      id: 'ann_${DateTime.now().millisecondsSinceEpoch}',
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
    list.insert(0, newMessage);
    final controller = _getController('announcements');
    if (!controller.isClosed) {
      controller.add(List.unmodifiable(list));
    }
  }

  @override
  Future<void> toggleReaction({
    required String channelId,
    required String messageId,
    required String emoji,
    required String userId,
  }) async {
    final list = _messages[channelId];
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

    final controller = _getController(channelId);
    if (!controller.isClosed) {
      controller.add(List.unmodifiable(list));
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.close();
    }
    _controllers.clear();
  }
}

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  final repo = SupabaseChatRepository();
  ref.onDispose(repo.dispose);
  return repo;
});


final channelListProvider = Provider<List<ChannelModel>>((ref) {
  final repo = ref.watch(chatRepositoryProvider);
  return repo.getChannels();
});

final channelMessagesProvider =
    StreamProvider.family<List<MessageModel>, String>((ref, channelId) {
  final repo = ref.watch(chatRepositoryProvider);
  return repo.getMessagesStream(channelId);
});
