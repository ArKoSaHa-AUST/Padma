import 'dart:async';
import 'package:flutter/material.dart';
import '../../data/models/live_bus_location.dart';
import '../../data/models/location_sharing_session.dart';
import '../../data/repositories/mock_live_location_repository.dart';
import '../../domain/models/sharing_status.dart';
import '../../domain/repositories/live_location_repository.dart';
import 'location_sharing_controller.dart';

/// ViewModel managing real-time passenger map state and bus telemetry.
/// Provides reactive updates for UI components while keeping transport layers decoupled.
class LiveBusViewModel extends ChangeNotifier {
  final LiveLocationRepository _repository;
  final LocationSharingController _adminController;

  String _busId = 'bus_1';
  LiveBusLocation? _currentLocation;
  LocationSharingSession? _currentSession;
  SharingStatus _status = SharingStatus.idle;
  String? _errorMessage;
  int _speedMultiplier = 1;

  StreamSubscription<LiveBusLocation?>? _locationSubscription;
  StreamSubscription<LocationSharingSession?>? _sessionSubscription;
  StreamSubscription<SharingStatus>? _statusSubscription;
  Timer? _clockTicker;

  LiveBusViewModel({
    required LiveLocationRepository repository,
    String initialBusId = 'bus_1',
    bool autoStartSharing = true,
  })  : _repository = repository,
        _adminController = LocationSharingController(repository: repository),
        _busId = initialBusId {
    _subscribeToStreams();
    _startClockTicker();

    if (autoStartSharing) {
      startSharing();
    }
  }

  // Getters
  String get busId => _busId;
  LiveBusLocation? get currentLocation => _currentLocation;
  LocationSharingSession? get currentSession => _currentSession;
  SharingStatus get status => _status;
  String? get errorMessage => _errorMessage;
  int get speedMultiplier => _speedMultiplier;

  bool get isLive =>
      _status == SharingStatus.sharing &&
      (_currentLocation == null || _currentLocation!.isSharing);
  bool get isStarting => _status == SharingStatus.starting;
  bool get isStopped => _status == SharingStatus.stopped;
  bool get isExpired => _status == SharingStatus.expired || (_currentSession?.isExpired() ?? false);
  bool get isIdle => _status == SharingStatus.idle;
  bool get hasLocation => _currentLocation != null;

  /// Time in seconds since last location fix was received
  int get secondsSinceLastUpdate {
    if (_currentLocation == null) return -1;
    final now = DateTime.now();
    return now.difference(_currentLocation!.timestamp).inSeconds.clamp(0, 86400);
  }

  /// Formatted last updated string (e.g. "Just now", "5s ago", "2m ago")
  String get lastUpdatedFormatted {
    final secs = secondsSinceLastUpdate;
    if (secs < 0) return 'No signal';
    if (secs < 3) return 'Just now';
    if (secs < 60) return '${secs}s ago';
    final mins = secs ~/ 60;
    return '${mins}m ago';
  }

  /// Formatted countdown for the 2-hour sharing session
  String get remainingSessionFormatted {
    if (_currentSession == null || _status != SharingStatus.sharing) {
      return '00:00:00';
    }
    return _currentSession!.formattedRemainingTime();
  }

  /// Compact remaining time string
  String get remainingSessionCompact {
    if (_currentSession == null || _status != SharingStatus.sharing) {
      return 'Inactive';
    }
    return _currentSession!.compactRemainingTime();
  }

  void _subscribeToStreams() {
    _cancelSubscriptions();

    _locationSubscription = _repository.watchBusLocation(_busId).listen(
      (location) {
        _currentLocation = location;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (Object error) {
        _errorMessage = error.toString();
        notifyListeners();
      },
    );

    _sessionSubscription = _repository.watchSharingSession(_busId).listen(
      (session) {
        _currentSession = session;
        notifyListeners();
      },
    );

    _statusSubscription = _repository.watchSharingStatus(_busId).listen(
      (newStatus) {
        _status = newStatus;
        notifyListeners();
      },
      onError: (Object error) {
        _status = SharingStatus.error;
        _errorMessage = error.toString();
        notifyListeners();
      },
    );
  }

  void _startClockTicker() {
    _clockTicker?.cancel();
    // Ticks every second to keep countdown and 'seconds ago' smooth
    _clockTicker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_status == SharingStatus.sharing || _currentLocation != null) {
        notifyListeners();
      }
    });
  }

  /// Admin Action: Starts broadcasting live bus GPS location
  Future<void> startSharing({
    Duration maxDuration = const Duration(hours: 2),
  }) async {
    _errorMessage = null;
    _status = SharingStatus.sharing;
    await _adminController.startSharing(_busId, maxDuration: maxDuration);
    _currentSession = await _adminController.getActiveSession(_busId);
    _currentLocation = await _repository.getLastKnownLocation(_busId);
    notifyListeners();
  }

  /// Admin Action: Stops broadcasting live bus location
  Future<void> stopSharing() async {
    await _adminController.stopSharing(_busId);
    _status = SharingStatus.stopped;
    if (_currentLocation != null) {
      _currentLocation = _currentLocation!.copyWith(isSharing: false);
    }
    notifyListeners();
  }

  /// Demo Action: Simulates 2-hour session expiration immediately
  void simulateExpiry() {
    if (_repository is MockLiveLocationRepository) {
      (_repository as MockLiveLocationRepository).simulateExpiry(_busId);
    }
  }

  /// Demo Action: Accelerates simulated GPS playback (1x, 2x, 5x)
  void setDemoSpeedMultiplier(int multiplier) {
    _speedMultiplier = multiplier;
    if (_repository is MockLiveLocationRepository) {
      (_repository as MockLiveLocationRepository).setDemoSpeedMultiplier(multiplier);
    }
    notifyListeners();
  }

  /// Demo Action: Resets bus position to start of route
  void resetDemoRoute() {
    if (_repository is MockLiveLocationRepository) {
      (_repository as MockLiveLocationRepository).resetDemoRoute();
    }
  }

  /// Switch active monitored bus
  void selectBus(String newBusId) {
    if (_busId == newBusId) return;
    _busId = newBusId;
    _currentLocation = null;
    _currentSession = null;
    _status = SharingStatus.idle;
    _subscribeToStreams();
    notifyListeners();
  }

  void _cancelSubscriptions() {
    _locationSubscription?.cancel();
    _sessionSubscription?.cancel();
    _statusSubscription?.cancel();
  }

  @override
  void dispose() {
    _clockTicker?.cancel();
    _cancelSubscriptions();
    super.dispose();
  }
}
