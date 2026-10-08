import 'dart:async';
import '../../data/models/location_sharing_session.dart';
import '../../domain/models/sharing_status.dart';
import '../../domain/repositories/live_location_repository.dart';

/// Controller interface prepared for the future Admin Panel.
///
/// Usage in future Admin Panel:
/// ```dart
/// final controller = LocationSharingController(repository: liveLocationRepository);
/// await controller.startSharing('bus_1');
/// // ...
/// await controller.stopSharing('bus_1');
/// ```
///
/// Flow:
/// [Admin Panel UI] → [LocationSharingController] → [LiveLocationRepository] → [Supabase / Mock]
class LocationSharingController {
  final LiveLocationRepository _repository;

  LocationSharingController({
    required LiveLocationRepository repository,
  }) : _repository = repository;

  /// Starts broadcasting live GPS location for [busId] up to [maxDuration] (2 hours max).
  Future<void> startSharing(
    String busId, {
    Duration maxDuration = const Duration(hours: 2),
  }) async {
    await _repository.startSharing(busId, maxDuration: maxDuration);
  }

  /// Stops broadcasting live GPS location for [busId].
  Future<void> stopSharing(String busId) async {
    await _repository.stopSharing(busId);
  }

  /// Checks if [busId] is actively broadcasting live location.
  Future<bool> isSharingActive(String busId) async {
    return _repository.isSharing(busId);
  }

  /// Retrieves the active sharing session for [busId].
  Future<LocationSharingSession?> getActiveSession(String busId) async {
    return _repository.getActiveSession(busId);
  }

  /// Observes real-time sharing status stream.
  Stream<SharingStatus> watchStatus(String busId) {
    return _repository.watchSharingStatus(busId);
  }

  /// Observes active session stream.
  Stream<LocationSharingSession?> watchSession(String busId) {
    return _repository.watchSharingSession(busId);
  }
}
