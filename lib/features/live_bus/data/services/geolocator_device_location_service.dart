import 'dart:async';
import 'package:geolocator/geolocator.dart';
import '../../../../core/utils/geo_utils.dart';
import '../../domain/services/device_location_service.dart';
import '../models/device_location.dart';

/// Real device hardware GPS implementation using `geolocator`.
/// Used by the Admin / Bus Driver device in production to stream raw GPS fixes.
class GeolocatorDeviceLocationService implements DeviceLocationService {
  StreamSubscription<Position>? _positionSubscription;
  final _controller = StreamController<DeviceLocation>.broadcast();

  final LocationSettings _locationSettings;

  GeolocatorDeviceLocationService({
    LocationSettings? locationSettings,
  }) : _locationSettings = locationSettings ??
            const LocationSettings(
              accuracy: LocationAccuracy.high,
              distanceFilter: 5, // meters
            );

  @override
  Stream<DeviceLocation> get locationStream {
    _startListening();
    return _controller.stream;
  }

  void _startListening() {
    if (_positionSubscription != null) return;

    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: _locationSettings,
    ).listen(
      (Position pos) {
        // Convert speed from m/s to km/h
        final speedKmH = (pos.speed * 3.6).clamp(0.0, 300.0);
        final heading = GeoUtils.normalizeHeading(pos.heading);

        final deviceLoc = DeviceLocation(
          latitude: pos.latitude,
          longitude: pos.longitude,
          speed: speedKmH,
          heading: heading,
          accuracy: pos.accuracy,
          altitude: pos.altitude,
          timestamp: pos.timestamp,
        );

        if (!_controller.isClosed) {
          _controller.add(deviceLoc);
        }
      },
      onError: (Object error) {
        if (!_controller.isClosed) {
          _controller.addError(error);
        }
      },
    );
  }

  @override
  Future<DeviceLocation?> getCurrentLocation() async {
    final hasPermission = await requestPermission();
    if (!hasPermission) return null;

    final pos = await Geolocator.getCurrentPosition();
    return DeviceLocation(
      latitude: pos.latitude,
      longitude: pos.longitude,
      speed: (pos.speed * 3.6).clamp(0.0, 300.0),
      heading: GeoUtils.normalizeHeading(pos.heading),
      accuracy: pos.accuracy,
      altitude: pos.altitude,
      timestamp: pos.timestamp,
    );
  }

  @override
  Future<bool> requestPermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  @override
  Future<bool> isLocationServiceEnabled() async {
    return Geolocator.isLocationServiceEnabled();
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _controller.close();
  }
}
