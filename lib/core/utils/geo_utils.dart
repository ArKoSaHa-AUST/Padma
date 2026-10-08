import 'dart:math' as math;
import 'package:latlong2/latlong.dart';

/// Utilities for geographic validation, distance, bearing, and interpolation calculations.
class GeoUtils {
  GeoUtils._();

  /// Validates that [latitude] is within standard WGS84 range: -90.0 to 90.0
  static bool isValidLatitude(double? latitude) {
    if (latitude == null || latitude.isNaN || latitude.isInfinite) return false;
    return latitude >= -90.0 && latitude <= 90.0;
  }

  /// Validates that [longitude] is within standard WGS84 range: -180.0 to 180.0
  static bool isValidLongitude(double? longitude) {
    if (longitude == null || longitude.isNaN || longitude.isInfinite) return false;
    return longitude >= -180.0 && longitude <= 180.0;
  }

  /// Validates that [speed] is non-negative and finite
  static bool isValidSpeed(double? speed) {
    if (speed == null || speed.isNaN || speed.isInfinite) return false;
    return speed >= 0.0;
  }

  /// Validates coordinate pair
  static bool isValidCoordinate(double? latitude, double? longitude) {
    return isValidLatitude(latitude) && isValidLongitude(longitude);
  }

  /// Normalizes a heading / bearing in degrees to the [0.0, 360.0) range.
  /// If heading is invalid (null, NaN, infinite), returns 0.0.
  static double normalizeHeading(double? heading) {
    if (heading == null || heading.isNaN || heading.isInfinite) {
      return 0.0;
    }
    var normalized = heading % 360.0;
    if (normalized < 0) {
      normalized += 360.0;
    }
    return normalized;
  }

  /// Linear interpolation between two coordinates [start] and [end] by [fraction] (0.0 to 1.0).
  static LatLng interpolateCoordinate(LatLng start, LatLng end, double fraction) {
    final clampedFraction = fraction.clamp(0.0, 1.0);
    final lat = start.latitude + (end.latitude - start.latitude) * clampedFraction;
    final lng = start.longitude + (end.longitude - start.longitude) * clampedFraction;
    return LatLng(lat, lng);
  }

  /// Interpolates bearing between [startAngle] and [endAngle] in degrees along the shortest angular arc.
  /// Handles wrapping around 0° / 360° correctly so the bus marker does not make a 350° spin when crossing north.
  static double interpolateBearing(double startAngle, double endAngle, double fraction) {
    final clampedFraction = fraction.clamp(0.0, 1.0);
    final normStart = normalizeHeading(startAngle);
    final normEnd = normalizeHeading(endAngle);

    var diff = normEnd - normStart;
    if (diff > 180) {
      diff -= 360;
    } else if (diff < -180) {
      diff += 360;
    }

    final interpolated = normStart + diff * clampedFraction;
    return normalizeHeading(interpolated);
  }

  /// Calculates initial bearing in degrees from [start] to [end] coordinate.
  static double calculateBearing(LatLng start, LatLng end) {
    final lat1 = start.latitude * (math.pi / 180.0);
    final lon1 = start.longitude * (math.pi / 180.0);
    final lat2 = end.latitude * (math.pi / 180.0);
    final lon2 = end.longitude * (math.pi / 180.0);

    final dLon = lon2 - lon1;

    final y = math.sin(dLon) * math.cos(lat2);
    final x = math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLon);

    final radians = math.atan2(y, x);
    final degrees = radians * (180.0 / math.pi);

    return normalizeHeading(degrees);
  }

  /// Calculates distance in meters between two coordinates using Haversine formula.
  static double calculateDistanceMeters(LatLng start, LatLng end) {
    const earthRadius = 6371000.0; // meters
    final dLat = (end.latitude - start.latitude) * (math.pi / 180.0);
    final dLon = (end.longitude - start.longitude) * (math.pi / 180.0);

    final lat1 = start.latitude * (math.pi / 180.0);
    final lat2 = end.latitude * (math.pi / 180.0);

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.sin(dLon / 2) * math.sin(dLon / 2) * math.cos(lat1) * math.cos(lat2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c;
  }
}
