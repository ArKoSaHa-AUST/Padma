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
}
