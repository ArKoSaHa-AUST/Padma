import 'dart:async';
import '../../data/models/device_location.dart';
import '../../data/models/live_bus_location.dart';
import '../../data/models/location_sharing_session.dart';
import '../../domain/models/sharing_status.dart';
import '../../domain/repositories/live_location_repository.dart';
import '../../domain/services/device_location_service.dart';
import '../services/mock_device_location_service.dart';

/// Mock in-memory implementation of [LiveLocationRepository].
/// Simulates live bus GPS broadcast streams and 2-hour sharing sessions locally.
///
/// Designed as a direct drop-in precursor to `SupabaseLiveLocationRepository`.
class MockLiveLocationRepository implements LiveLocationRepository {
  final DeviceLocationService _deviceLocationService;

  // Active state per busId
  final Map<String, LiveBusLocation> _lastLocations = {};
  final Map<String, LocationSharingSession> _activeSessions = {};
  final Map<String, SharingStatus> _sharingStatuses = {};

  // Broadcast stream controllers
  final _locationStreamController = StreamController<Map<String, LiveBusLocation?>>.broadcast();
  final _sessionStreamController = StreamController<Map<String, LocationSharingSession?>>.broadcast();
  final _statusStreamController = StreamController<Map<String, SharingStatus>>.broadcast();

  StreamSubscription<DeviceLocation>? _gpsSubscription;
  Timer? _sessionExpiryTimer;
  String _activeBusId = 'bus_1';

  MockLiveLocationRepository({
    DeviceLocationService? deviceLocationService,
    bool autoStartDemo = false,
  }) : _deviceLocationService = deviceLocationService ?? MockDeviceLocationService() {
    // Initialize default bus state
    _sharingStatuses[_activeBusId] = SharingStatus.idle;

    if (autoStartDemo) {
      unawaited(startSharing(_activeBusId));
    }
  }

  @override
  Stream<LiveBusLocation?> watchBusLocation(String busId) {
    return _locationStreamController.stream
        .map((map) => map[busId])
        .distinct();
  }

  @override
  Stream<LocationSharingSession?> watchSharingSession(String busId) {
    return _sessionStreamController.stream
        .map((map) => map[busId])
        .distinct();
  }

  @override
  Stream<SharingStatus> watchSharingStatus(String busId) {
    return _statusStreamController.stream
        .map((map) => map[busId] ?? SharingStatus.idle)
        .distinct();
  }

  @override
  Future<LiveBusLocation?> getLastKnownLocation(String busId) async {
    return _lastLocations[busId];
  }

  @override
  Future<LocationSharingSession?> getActiveSession(String busId) async {
    final session = _activeSessions[busId];
    if (session != null && !session.isExpired()) {
      return session;
    }
    return null;
  }

  @override
  Future<bool> isSharing(String busId) async {
    final status = _sharingStatuses[busId];
    return status == SharingStatus.sharing;
  }

  @override
  Future<void> startSharing(
    String busId, {
    Duration maxDuration = const Duration(hours: 2),
  }) async {
    _activeBusId = busId;

    // Transition to starting state
    _updateStatus(busId, SharingStatus.starting);

    // Create 2-hour sharing session
    final session = LocationSharingSession.startNew(
      busId: busId,
      duration: maxDuration,
    );
    _activeSessions[busId] = session;
    _emitSessionUpdate(busId, session);

    // Cancel any previous subscriptions and timers
    _sessionExpiryTimer?.cancel();
    await _gpsSubscription?.cancel();

    // Schedule automatic 2-hour session expiration
    _sessionExpiryTimer = Timer(maxDuration, () {
      _handleSessionExpired(busId);
    });

    // Start GPS stream from device location service
    if (_deviceLocationService is MockDeviceLocationService) {
      (_deviceLocationService as MockDeviceLocationService).start();
    }

    _gpsSubscription = _deviceLocationService.locationStream.listen(
      (DeviceLocation devLoc) {
        final currentSession = _activeSessions[busId];
        if (currentSession == null || currentSession.isExpired()) {
          _handleSessionExpired(busId);
          return;
        }

        final liveLoc = LiveBusLocation(
          busId: busId,
          latitude: devLoc.latitude,
          longitude: devLoc.longitude,
          speed: devLoc.speed,
          heading: devLoc.heading,
          timestamp: devLoc.timestamp,
          sharingSessionId: currentSession.sessionId,
          isSharing: true,
        );

        _lastLocations[busId] = liveLoc;
        _emitLocationUpdate(busId, liveLoc);

        if (_sharingStatuses[busId] != SharingStatus.sharing) {
          _updateStatus(busId, SharingStatus.sharing);
        }
      },
      onError: (Object error) {
        _updateStatus(busId, SharingStatus.error);
      },
    );

    _updateStatus(busId, SharingStatus.sharing);
  }

  @override
  Future<void> stopSharing(String busId) async {
    _sessionExpiryTimer?.cancel();
    await _gpsSubscription?.cancel();

    if (_deviceLocationService is MockDeviceLocationService) {
      (_deviceLocationService as MockDeviceLocationService).stop();
    }

    final existingSession = _activeSessions[busId];
    if (existingSession != null) {
      final terminatedSession = existingSession.copyWith(isActive: false);
      _activeSessions[busId] = terminatedSession;
      _emitSessionUpdate(busId, terminatedSession);
    }

    final lastLoc = _lastLocations[busId];
    if (lastLoc != null) {
      final stoppedLoc = lastLoc.copyWith(isSharing: false);
      _lastLocations[busId] = stoppedLoc;
      _emitLocationUpdate(busId, stoppedLoc);
    }

    _updateStatus(busId, SharingStatus.stopped);
  }

  /// Manually simulates immediate 2-hour expiration for demonstration and testing.
  void simulateExpiry(String busId) {
    _handleSessionExpired(busId);
  }

  /// Sets demo speed multiplier (1x, 2x, 5x) if using [MockDeviceLocationService].
  void setDemoSpeedMultiplier(int multiplier) {
    if (_deviceLocationService is MockDeviceLocationService) {
      (_deviceLocationService as MockDeviceLocationService).setSpeedMultiplier(multiplier);
    }
  }

  /// Resets route back to starting point if using [MockDeviceLocationService].
  void resetDemoRoute() {
    if (_deviceLocationService is MockDeviceLocationService) {
      (_deviceLocationService as MockDeviceLocationService).reset();
    }
  }

  void _handleSessionExpired(String busId) {
    _sessionExpiryTimer?.cancel();
    _gpsSubscription?.cancel();

    if (_deviceLocationService is MockDeviceLocationService) {
      (_deviceLocationService as MockDeviceLocationService).stop();
    }

    final session = _activeSessions[busId];
    if (session != null) {
      final expiredSession = session.copyWith(isActive: false);
      _activeSessions[busId] = expiredSession;
      _emitSessionUpdate(busId, expiredSession);
    }

    final lastLoc = _lastLocations[busId];
    if (lastLoc != null) {
      final expiredLoc = lastLoc.copyWith(isSharing: false);
      _lastLocations[busId] = expiredLoc;
      _emitLocationUpdate(busId, expiredLoc);
    }

    _updateStatus(busId, SharingStatus.expired);
  }

  void _updateStatus(String busId, SharingStatus status) {
    _sharingStatuses[busId] = status;
    if (!_statusStreamController.isClosed) {
      _statusStreamController.add(Map.unmodifiable(_sharingStatuses));
    }
  }

  void _emitLocationUpdate(String busId, LiveBusLocation? location) {
    if (!_locationStreamController.isClosed) {
      _locationStreamController.add({busId: location});
    }
  }

  void _emitSessionUpdate(String busId, LocationSharingSession? session) {
    if (!_sessionStreamController.isClosed) {
      _sessionStreamController.add({busId: session});
    }
  }

  @override
  void dispose() {
    _sessionExpiryTimer?.cancel();
    _gpsSubscription?.cancel();
    _deviceLocationService.dispose();
    _locationStreamController.close();
    _sessionStreamController.close();
    _statusStreamController.close();
  }
}
