class StopModel {
  final String id;
  final String name;
  final String nameBn;
  final double lat;
  final double lng;
  final int order;
  final String scheduledTime;
  final String firstBusTime;
  final String secondBusTime;
  final bool isFavorite;

  const StopModel({
    required this.id,
    required this.name,
    required this.nameBn,
    required this.lat,
    required this.lng,
    required this.order,
    required this.scheduledTime,
    this.firstBusTime = '',
    this.secondBusTime = '',
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
    String? firstBusTime,
    String? secondBusTime,
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
      firstBusTime: firstBusTime ?? this.firstBusTime,
      secondBusTime: secondBusTime ?? this.secondBusTime,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
