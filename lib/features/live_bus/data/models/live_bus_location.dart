import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/utils/geo_utils.dart';

/// Immutable domain model representing real-time bus location telemetry.
/// Structured for effortless serialization to and from PostgreSQL / Supabase Realtime payloads.
@immutable
class LiveBusLocation {
  final String busId;
  final double latitude;
  final double longitude;
  final double speed; // in km/h
  final double heading; // in degrees: 0.0 to 360.0
  final DateTime timestamp;
  final String sharingSessionId;
  final bool isSharing;

  const LiveBusLocation({
    required this.busId,
    required this.latitude,
    required this.longitude,
    required this.speed,
    required this.heading,
    required this.timestamp,
    required this.sharingSessionId,
    this.isSharing = true,
  });

  /// Factory constructor that validates and sanitizes incoming coordinate parameters.
  /// Throws [ArgumentError] if coordinates or speed are mathematically invalid.
  factory LiveBusLocation.validated({
    required String busId,
    required double latitude,
    required double longitude,
    required double speed,
    required double heading,
    required DateTime timestamp,
    required String sharingSessionId,
    bool isSharing = true,
  }) {
    if (!GeoUtils.isValidLatitude(latitude)) {
      throw ArgumentError.value(latitude, 'latitude', 'Must be between -90.0 and 90.0');
    }
    if (!GeoUtils.isValidLongitude(longitude)) {
      throw ArgumentError.value(longitude, 'longitude', 'Must be between -180.0 and 180.0');
    }
    if (!GeoUtils.isValidSpeed(speed)) {
      throw ArgumentError.value(speed, 'speed', 'Must be non-negative and finite');
    }

    return LiveBusLocation(
      busId: busId,
      latitude: latitude,
      longitude: longitude,
      speed: speed,
      heading: GeoUtils.normalizeHeading(heading),
      timestamp: timestamp,
      sharingSessionId: sharingSessionId,
      isSharing: isSharing,
    );
  }

  /// Checks if this location payload has valid geographic bounds
  bool get isValid =>
      GeoUtils.isValidCoordinate(latitude, longitude) &&
      GeoUtils.isValidSpeed(speed);

  /// Converts coordinates to a [LatLng] instance
  LatLng get latLng => LatLng(latitude, longitude);

  /// Standard JSON serialization matching future PostgreSQL / Supabase schema:
  /// `live_bus_locations` (bus_id, latitude, longitude, speed, heading, timestamp, sharing_session_id, is_sharing)
  Map<String, dynamic> toJson() {
    return {
      'bus_id': busId,
      'latitude': latitude,
      'longitude': longitude,
      'speed': speed,
      'heading': heading,
      'timestamp': timestamp.toUtc().toIso8601String(),
      'sharing_session_id': sharingSessionId,
      'is_sharing': isSharing,
    };
  }

  /// Deserializes JSON payload from REST or Supabase Realtime broadcast/CDC event.
  /// Handles both camelCase and snake_case keys resiliently.
  factory LiveBusLocation.fromJson(Map<String, dynamic> json) {
    final rawBusId = json['bus_id']?.toString() ?? json['busId']?.toString() ?? 'bus_1';
    final rawLat = (json['latitude'] as num?)?.toDouble() ?? 0.0;
    final rawLng = (json['longitude'] as num?)?.toDouble() ?? 0.0;
    final rawSpeed = (json['speed'] as num?)?.toDouble() ?? 0.0;
    final rawHeading = (json['heading'] as num?)?.toDouble() ?? 0.0;
    final rawSessionId = json['sharing_session_id']?.toString() ??
        json['sharingSessionId']?.toString() ??
        '';
    final rawIsSharing = json['is_sharing'] as bool? ?? json['isSharing'] as bool? ?? true;

    final rawTimestamp = json['timestamp'];
    DateTime parsedTimestamp;
    if (rawTimestamp is String) {
      parsedTimestamp = DateTime.tryParse(rawTimestamp) ?? DateTime.now();
    } else if (rawTimestamp is int) {
      parsedTimestamp = DateTime.fromMillisecondsSinceEpoch(rawTimestamp);
    } else {
      parsedTimestamp = DateTime.now();
    }

    return LiveBusLocation(
      busId: rawBusId,
      latitude: rawLat,
      longitude: rawLng,
      speed: rawSpeed >= 0 ? rawSpeed : 0.0,
      heading: GeoUtils.normalizeHeading(rawHeading),
      timestamp: parsedTimestamp,
      sharingSessionId: rawSessionId,
      isSharing: rawIsSharing,
    );
  }

  LiveBusLocation copyWith({
    String? busId,
    double? latitude,
    double? longitude,
    double? speed,
    double? heading,
    DateTime? timestamp,
    String? sharingSessionId,
    bool? isSharing,
  }) {
    return LiveBusLocation(
      busId: busId ?? this.busId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      speed: speed ?? this.speed,
      heading: heading != null ? GeoUtils.normalizeHeading(heading) : this.heading,
      timestamp: timestamp ?? this.timestamp,
      sharingSessionId: sharingSessionId ?? this.sharingSessionId,
      isSharing: isSharing ?? this.isSharing,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LiveBusLocation &&
          runtimeType == other.runtimeType &&
          busId == other.busId &&
          latitude == other.latitude &&
          longitude == other.longitude &&
          speed == other.speed &&
          heading == other.heading &&
          timestamp == other.timestamp &&
          sharingSessionId == other.sharingSessionId &&
          isSharing == other.isSharing;

  @override
  int get hashCode => Object.hash(
        busId,
        latitude,
        longitude,
        speed,
        heading,
        timestamp,
        sharingSessionId,
        isSharing,
      );

  @override
  String toString() {
    return 'LiveBusLocation(busId: $busId, lat: $latitude, lng: $longitude, speed: ${speed.toStringAsFixed(1)} km/h, heading: ${heading.toStringAsFixed(1)}°, active: $isSharing)';
  }
}
