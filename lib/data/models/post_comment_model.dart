class PostCommentModel {
  final String id;
  final String postId;
  final String userId;
  final String userName;
  final String userTag;
  final String content;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const PostCommentModel({
    required this.id,
    required this.postId,
    required this.userId,
    required this.userName,
    required this.userTag,
    required this.content,
    required this.createdAt,
    this.updatedAt,
  });

  factory PostCommentModel.fromJson(Map<String, dynamic> json) {
    return PostCommentModel(
      id: json['id']?.toString() ?? '',
      postId: json['post_id']?.toString() ?? json['postId']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? json['userId']?.toString() ?? '',
      userName: json['user_name']?.toString() ?? json['userName']?.toString() ?? 'Student',
      userTag: json['user_tag']?.toString() ?? json['userTag']?.toString() ?? 'AUST_Student',
      content: json['content']?.toString() ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : (json['createdAt'] is int
              ? DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int)
              : DateTime.now()),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : (json['updatedAt'] is int
              ? DateTime.fromMillisecondsSinceEpoch(json['updatedAt'] as int)
              : null),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'post_id': postId,
      'user_id': userId,
      'user_name': userName,
      'user_tag': userTag,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  PostCommentModel copyWith({
    String? id,
    String? postId,
    String? userId,
    String? userName,
    String? userTag,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PostCommentModel(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userTag: userTag ?? this.userTag,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
