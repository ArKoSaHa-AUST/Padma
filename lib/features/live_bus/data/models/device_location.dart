import '../../../../core/utils/geo_utils.dart';

/// Represents a raw or normalized GPS fix from a physical or simulated device.
class DeviceLocation {
  final double latitude;
  final double longitude;
  final double speed; // in km/h
  final double heading; // 0 to 360 degrees
  final double? accuracy; // in meters
  final double? altitude;
  final DateTime timestamp;

  const DeviceLocation({
    required this.latitude,
    required this.longitude,
    required this.speed,
    required this.heading,
    this.accuracy,
    this.altitude,
    required this.timestamp,
  });

  /// Validates that coordinate values are valid geographic numbers.
  bool get isValid =>
      GeoUtils.isValidCoordinate(latitude, longitude) &&
      GeoUtils.isValidSpeed(speed);

  DeviceLocation copyWith({
    double? latitude,
    double? longitude,
    double? speed,
    double? heading,
    double? accuracy,
    double? altitude,
    DateTime? timestamp,
  }) {
    return DeviceLocation(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      speed: speed ?? this.speed,
      heading: heading != null ? GeoUtils.normalizeHeading(heading) : this.heading,
      accuracy: accuracy ?? this.accuracy,
      altitude: altitude ?? this.altitude,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'speed': speed,
      'heading': heading,
      'accuracy': accuracy,
      'altitude': altitude,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory DeviceLocation.fromJson(Map<String, dynamic> json) {
    final rawLat = (json['latitude'] as num?)?.toDouble() ?? 0.0;
    final rawLng = (json['longitude'] as num?)?.toDouble() ?? 0.0;
    final rawSpeed = (json['speed'] as num?)?.toDouble() ?? 0.0;
    final rawHeading = (json['heading'] as num?)?.toDouble() ?? 0.0;

    return DeviceLocation(
      latitude: rawLat,
      longitude: rawLng,
      speed: rawSpeed.clamp(0.0, 300.0),
      heading: GeoUtils.normalizeHeading(rawHeading),
      accuracy: (json['accuracy'] as num?)?.toDouble(),
      altitude: (json['altitude'] as num?)?.toDouble(),
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  @override
  String toString() =>
      'DeviceLocation(lat: $latitude, lng: $longitude, speed: ${speed.toStringAsFixed(1)} km/h, heading: ${heading.toStringAsFixed(1)}°)';
}
