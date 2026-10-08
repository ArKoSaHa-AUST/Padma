class StopModel {
  final String id;
  final String name;
  final String nameBn;
  final double lat;
  final double lng;
  final int order;
  final String scheduledTime;
  final bool isFavorite;

  const StopModel({
    required this.id,
    required this.name,
    required this.nameBn,
    required this.lat,
    required this.lng,
    required this.order,
    required this.scheduledTime,
    this.isFavorite = false,
  });

  StopModel copyWith({
    String? id,
    String? name,
    String? nameBn,
    double? lat,
    double? lng,
    int? order,
    String? scheduledTime,
    bool? isFavorite,
  }) {
    return StopModel(
      id: id ?? this.id,
      name: name ?? this.name,
      nameBn: nameBn ?? this.nameBn,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      order: order ?? this.order,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
