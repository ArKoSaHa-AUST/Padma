class AdminUpdateModel {
  final String id;
  final String authorName;
  final String text;
  final String? busId;
  final String? busName;
  final bool isPinned;
  final bool isUrgent;
  final DateTime createdAt;

  const AdminUpdateModel({
    required this.id,
    required this.authorName,
    required this.text,
    this.busId,
    this.busName,
    this.isPinned = false,
    this.isUrgent = false,
    required this.createdAt,
  });
}
