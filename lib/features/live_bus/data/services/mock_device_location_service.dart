import 'dart:async';
import 'package:latlong2/latlong.dart';
import '../../../../core/utils/geo_utils.dart';
import '../../domain/services/device_location_service.dart';
import '../models/device_location.dart';

/// Simulated GPS hardware provider for local demonstration and development.
/// Emits location fixes along an authentic Dhaka transit corridor:
/// [AUST Tejgaon -> Mohakhali Flyover -> Banani -> Kakoli -> Airport -> Uttara].
///
/// NOTE: This data is explicitly marked for DEMO purposes and simulates real device GPS.
class MockDeviceLocationService implements DeviceLocationService {
  /// Realistic Dhaka transit corridor coordinates (AUST to Uttara route)
  static const List<LatLng> demoWaypoints = [
    // 1. AUST Campus, Tejgaon I/A
    LatLng(23.7639, 90.4070),
    // 2. Tejgaon Link Road
    LatLng(23.7682, 90.4055),
    // 3. Nabikettan Junction
    LatLng(23.7735, 90.4038),
    // 4. Mohakhali Bus Terminal
    LatLng(23.7778, 90.4020),
    // 5. Mohakhali Flyover North
    LatLng(23.7842, 90.4035),
    // 6. Jahangir Gate / Amtoli
    LatLng(23.7895, 90.4048),
    // 7. Banani Chairman Bari
    LatLng(23.7940, 90.4042),
    // 8. Banani 11 Intersection
    LatLng(23.7988, 90.4036),
    // 9. Kakoli Crossing
    LatLng(23.8035, 90.4028),
    // 10. Army Stadium
    LatLng(23.8115, 90.4050),
    // 11. Kuril Flyover Entry
    LatLng(23.8210, 90.4120),
    // 12. Radisson Blu / Khilkhet
    LatLng(23.8315, 90.4175),
    // 13. Kawla / Hajj Camp
    LatLng(23.8440, 90.4120),
    // 14. Hazrat Shahjalal International Airport
    LatLng(23.8512, 90.4080),
    // 15. Jashimuddin Avenue, Uttara
    LatLng(23.8625, 90.3980),
    // 16. Azampur / Rajlakshmi, Uttara
    LatLng(23.8690, 90.3965),
    // 17. House Building, Uttara Sector 7
    LatLng(23.8760, 90.3950),
  ];

  final _controller = StreamController<DeviceLocation>.broadcast();
  Timer? _timer;
  int _currentIndex = 0;
  double _fraction = 0.0;
  int _speedMultiplier = 1;
  bool _isRunning = false;

  /// Default interval between emitted GPS fixes (~5 seconds)
  Duration _baseInterval = const Duration(seconds: 5);

  MockDeviceLocationService({Duration? interval}) {
    if (interval != null) {
      _baseInterval = interval;
    }
  }

  @override
  Stream<DeviceLocation> get locationStream => _controller.stream;

  /// Starts or resumes simulated GPS emission.
  void start() {
    if (_isRunning) return;
    _isRunning = true;
    _emitCurrentPosition();
    _scheduleNextEmission();
  }

  /// Pauses simulated GPS emission.
  void stop() {
    _isRunning = false;
    _timer?.cancel();
  }

  /// Resets position back to starting coordinate (AUST Campus).
  void reset() {
    _currentIndex = 0;
    _fraction = 0.0;
    if (_isRunning) {
      _emitCurrentPosition();
    }
  }

  /// Sets demo speed multiplier (1x, 2x, 5x) to accelerate demonstration.
  void setSpeedMultiplier(int multiplier) {
    _speedMultiplier = multiplier.clamp(1, 10);
    if (_isRunning) {
      _timer?.cancel();
      _scheduleNextEmission();
    }
  }

  int get speedMultiplier => _speedMultiplier;

  void _scheduleNextEmission() {
    if (!_isRunning) return;
    final intervalMs = (_baseInterval.inMilliseconds / _speedMultiplier).round();
    _timer = Timer.periodic(Duration(milliseconds: intervalMs.clamp(500, 10000)), (_) {
      _advancePosition();
    });
  }

  void _advancePosition() {
    if (demoWaypoints.length < 2) return;

    // Sub-segment step fraction for continuous fine-grained trajectory
    _fraction += 0.25;
    if (_fraction >= 1.0) {
      _fraction = 0.0;
      _currentIndex++;
      if (_currentIndex >= demoWaypoints.length - 1) {
        // Loop route back smoothly
        _currentIndex = 0;
      }
    }

    _emitCurrentPosition();
  }

  void _emitCurrentPosition() {
    if (_controller.isClosed) return;

    final currentWaypoint = demoWaypoints[_currentIndex];
    final nextWaypoint = demoWaypoints[(_currentIndex + 1) % demoWaypoints.length];

    final interpolated = GeoUtils.interpolateCoordinate(
      currentWaypoint,
      nextWaypoint,
      _fraction,
    );

    final heading = GeoUtils.calculateBearing(currentWaypoint, nextWaypoint);

    // Realistic simulated speed in km/h with subtle natural traffic variation
    final baseSpeed = 32.0 + (_currentIndex % 4) * 4.0;
    final variation = ((DateTime.now().second % 6) - 3) * 1.5;
    final simulatedSpeed = (baseSpeed + variation).clamp(12.0, 58.0);

    final location = DeviceLocation(
      latitude: interpolated.latitude,
      longitude: interpolated.longitude,
      speed: simulatedSpeed,
      heading: heading,
      accuracy: 4.5,
      altitude: 14.0,
      timestamp: DateTime.now(),
    );

    _controller.add(location);
  }

  @override
  Future<DeviceLocation?> getCurrentLocation() async {
    final wp = demoWaypoints[_currentIndex];
    return DeviceLocation(
      latitude: wp.latitude,
      longitude: wp.longitude,
      speed: 30.0,
      heading: 45.0,
      accuracy: 5.0,
      timestamp: DateTime.now(),
    );
  }

  @override
  Future<bool> requestPermission() async {
    // Simulated mock always grants permission instantly
    return true;
  }

  @override
  Future<bool> isLocationServiceEnabled() async {
    return true;
  }

  @override
  void dispose() {
    stop();
    _controller.close();
  }
}
