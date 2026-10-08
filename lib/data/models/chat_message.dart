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
  final String? senderTag;
  final String? avatarInitials;
  final String text;
  final DateTime timestamp;
  final bool isTelemetry;
  final String? badgeText;
  final List<ChatReaction> reactions;
  final String? recipientId; // For private 1-on-1 contact admin chat

  ChatMessage({
    required this.id,
    required this.senderName,
    required this.senderRole,
    this.senderTag,
    this.avatarInitials,
    required this.text,
    required this.timestamp,
    this.isTelemetry = false,
    this.badgeText,
    List<ChatReaction>? reactions,
    this.recipientId,
  }) : reactions = reactions ?? [];

  /// Checks if this message mentions the given tag
  bool mentionsTag(String tag) {
    if (tag.isEmpty) return false;
    return text.toLowerCase().contains('@${tag.toLowerCase()}');
  }
}
