import 'user_model.dart';

class MessageModel {
  final String id;
  final String channelId;
  final String senderId;
  final String senderName;
  final UserRole senderRole;
  final String? senderAvatar;
  final String text;
  final String? imageUrl;
  final bool isUrgent;
  final bool isPinned;
  final DateTime createdAt;
  final Map<String, int> reactions; // emoji -> count
  final List<String> userReactions; // emojis reacted by current user
  final String? replyToSenderName;
  final String? replyToText;

  const MessageModel({
    required this.id,
    required this.channelId,
    required this.senderId,
    required this.senderName,
    required this.senderRole,
    this.senderAvatar,
    required this.text,
    this.imageUrl,
    this.isUrgent = false,
    this.isPinned = false,
    required this.createdAt,
    this.reactions = const {},
    this.userReactions = const [],
    this.replyToSenderName,
    this.replyToText,
  });

  MessageModel copyWith({
    String? id,
    String? channelId,
    String? senderId,
    String? senderName,
    UserRole? senderRole,
    String? senderAvatar,
    String? text,
    String? imageUrl,
    bool? isUrgent,
    bool? isPinned,
    DateTime? createdAt,
    Map<String, int>? reactions,
    List<String>? userReactions,
    String? replyToSenderName,
    String? replyToText,
  }) {
    return MessageModel(
      id: id ?? this.id,
      channelId: channelId ?? this.channelId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderRole: senderRole ?? this.senderRole,
      senderAvatar: senderAvatar ?? this.senderAvatar,
      text: text ?? this.text,
      imageUrl: imageUrl ?? this.imageUrl,
      isUrgent: isUrgent ?? this.isUrgent,
      isPinned: isPinned ?? this.isPinned,
      createdAt: createdAt ?? this.createdAt,
      reactions: reactions ?? this.reactions,
      userReactions: userReactions ?? this.userReactions,
      replyToSenderName: replyToSenderName ?? this.replyToSenderName,
      replyToText: replyToText ?? this.replyToText,
    );
  }
}
