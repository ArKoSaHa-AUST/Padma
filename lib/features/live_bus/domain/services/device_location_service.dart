import 'dart:async';
import '../../data/models/device_location.dart';

/// Abstract contract for device GPS location retrieval.
/// Decouples admin tracking hardware from the location broadcast pipeline.
///
/// Implementations:
/// - [MockDeviceLocationService] (simulates Dhaka transit corridor coordinates for demo/dev)
/// - [GeolocatorDeviceLocationService] (connects to real phone GPS hardware)
abstract class DeviceLocationService {
  /// Continuous stream of hardware or simulated GPS fixes.
  Stream<DeviceLocation> get locationStream;

  /// Retrieves the single immediate position fix.
  Future<DeviceLocation?> getCurrentLocation();

  /// Requests location permissions from the OS.
  Future<bool> requestPermission();

  /// Checks whether device location hardware / services are enabled.
  Future<bool> isLocationServiceEnabled();

  /// Disposes stream controllers and timers.
  void dispose();
}
