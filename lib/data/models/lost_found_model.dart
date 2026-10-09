enum LostFoundType {
  lost,
  found;

  String get label => this == LostFoundType.lost ? 'Lost' : 'Found';
}

class LostFoundModel {
  final String id;
  final String title;
  final String description;
  final LostFoundType type;
  final String? location;
  final String? contact;
  final String? imageUrl;
  final String authorName;
  final String authorTag;
  final DateTime createdAt;

  const LostFoundModel({
    required this.id,
    required this.title,
    required this.description,
    this.type = LostFoundType.lost,
    this.location,
    this.contact,
    this.imageUrl,
    required this.authorName,
    required this.authorTag,
    required this.createdAt,
  });

  LostFoundModel copyWith({
    String? id,
    String? title,
    String? description,
    LostFoundType? type,
    String? location,
    String? contact,
    String? imageUrl,
    String? authorName,
    String? authorTag,
    DateTime? createdAt,
  }) {
    return LostFoundModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      location: location ?? this.location,
      contact: contact ?? this.contact,
      imageUrl: imageUrl ?? this.imageUrl,
      authorName: authorName ?? this.authorName,
      authorTag: authorTag ?? this.authorTag,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
