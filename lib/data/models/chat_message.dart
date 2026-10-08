class ChatReaction {
  final String emoji;
  int count;
  bool isUserReacted;

  ChatReaction({
    required this.emoji,
    required this.count,
    this.isUserReacted = false,
  });
}

class ChatMessage {
  final String id;
  final String senderName;
  final String senderRole;
  final String? avatarInitials;
  final String text;
  final DateTime timestamp;
  final bool isTelemetry;
  final String? badgeText;
  final List<ChatReaction> reactions;

  ChatMessage({
    required this.id,
    required this.senderName,
    required this.senderRole,
    this.avatarInitials,
    required this.text,
    required this.timestamp,
    this.isTelemetry = false,
    this.badgeText,
    List<ChatReaction>? reactions,
  }) : reactions = reactions ?? [];
}
