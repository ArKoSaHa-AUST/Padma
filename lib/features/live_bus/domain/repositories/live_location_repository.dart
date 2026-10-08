import 'dart:async';
import '../../data/models/live_bus_location.dart';
import '../../data/models/location_sharing_session.dart';
import '../models/sharing_status.dart';

/// Abstract repository contract for bus live location tracking.
/// Decouples UI presentation from backend transport (Mock vs. Supabase Realtime).
///
/// Flow:
/// UI (Passenger) → [LiveLocationRepository] → [watchBusLocation]
/// UI (Admin)     → [LiveLocationRepository] → [startSharing] / [stopSharing]
abstract class LiveLocationRepository {
  /// Real-time stream of live location fixes for [busId].
  /// Emits `null` when location sharing is inactive or stopped.
  Stream<LiveBusLocation?> watchBusLocation(String busId);

  /// Real-time stream of the active sharing session metadata for [busId].
  Stream<LocationSharingSession?> watchSharingSession(String busId);

  /// Real-time stream of the sharing lifecycle status for [busId].
  Stream<SharingStatus> watchSharingStatus(String busId);

  /// Retrieves the latest known cached location fix for [busId].
  Future<LiveBusLocation?> getLastKnownLocation(String busId);

  /// Retrieves the active sharing session for [busId] if any.
  Future<LocationSharingSession?> getActiveSession(String busId);

  /// Starts a live location sharing session for [busId] lasting up to [maxDuration] (default 2 hours).
  Future<void> startSharing(
    String busId, {
    Duration maxDuration = const Duration(hours: 2),
  });

  /// Terminates the active sharing session for [busId].
  Future<void> stopSharing(String busId);

  /// Checks if [busId] is currently broadcasting live GPS telemetry.
  Future<bool> isSharing(String busId);

  /// Disposes internal streams and timers cleanly.
  void dispose();
}
