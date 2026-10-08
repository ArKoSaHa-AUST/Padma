enum ChannelCategory {
  info,
  community,
  buses;

  String get displayName {
    switch (this) {
      case ChannelCategory.info:
        return 'INFO';
      case ChannelCategory.community:
        return 'COMMUNITY';
      case ChannelCategory.buses:
        return 'BUSES';
    }
  }
}

enum ChannelType {
  home,
  announcement,
  request,
  general,
  bus,
  schedule,
  lostFound,
  feedback,
}

class ChannelModel {
  final String id;
  final String name;
  final String? subtitle;
  final ChannelCategory category;
  final ChannelType type;
  final bool isReadOnlyForStudents;
  final int unreadCount;
  final String? busId;

  const ChannelModel({
    required this.id,
    required this.name,
    this.subtitle,
    required this.category,
    required this.type,
    this.isReadOnlyForStudents = false,
    this.unreadCount = 0,
    this.busId,
  });

  ChannelModel copyWith({
    String? id,
    String? name,
    String? subtitle,
    ChannelCategory? category,
    ChannelType? type,
    bool? isReadOnlyForStudents,
    int? unreadCount,
    String? busId,
  }) {
    return ChannelModel(
      id: id ?? this.id,
      name: name ?? this.name,
      subtitle: subtitle ?? this.subtitle,
      category: category ?? this.category,
      type: type ?? this.type,
      isReadOnlyForStudents: isReadOnlyForStudents ?? this.isReadOnlyForStudents,
      unreadCount: unreadCount ?? this.unreadCount,
      busId: busId ?? this.busId,
    );
  }
}
