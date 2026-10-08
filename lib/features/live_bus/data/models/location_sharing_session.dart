import 'package:flutter/foundation.dart';

/// Immutable domain model representing a live location sharing session.
/// Enforces the 2-hour maximum lifetime rule and provides real-time duration countdown helpers.
/// Ready to map directly to Supabase table `location_sharing_sessions`.
@immutable
class LocationSharingSession {
  final String sessionId;
  final String busId;
  final DateTime startedAt;
  final DateTime expiresAt;
  final bool isActive;

  const LocationSharingSession({
    required this.sessionId,
    required this.busId,
    required this.startedAt,
    required this.expiresAt,
    this.isActive = true,
  });

  /// Factory constructor to create a fresh 2-hour sharing session.
  factory LocationSharingSession.startNew({
    required String busId,
    String? sessionId,
    Duration duration = const Duration(hours: 2),
    DateTime? now,
  }) {
    final start = now ?? DateTime.now();
    final expire = start.add(duration);
    final id = sessionId ?? 'session_${busId}_${start.millisecondsSinceEpoch}';

    return LocationSharingSession(
      sessionId: id,
      busId: busId,
      startedAt: start,
      expiresAt: expire,
      isActive: true,
    );
  }

  /// Evaluates whether this session has expired according to the provided reference [now] time.
  bool isExpired([DateTime? now]) {
    if (!isActive) return true;
    final current = now ?? DateTime.now();
    return current.isAfter(expiresAt);
  }

  /// Calculates remaining duration until [expiresAt]. Returns [Duration.zero] if already expired.
  Duration remainingDuration([DateTime? now]) {
    if (!isActive) return Duration.zero;
    final current = now ?? DateTime.now();
    if (current.isAfter(expiresAt)) {
      return Duration.zero;
    }
    return expiresAt.difference(current);
  }

  /// Formatted remaining duration as HH:MM:SS (e.g. "01:45:12" or "00:04:30")
  String formattedRemainingTime([DateTime? now]) {
    final remaining = remainingDuration(now);
    if (remaining == Duration.zero) {
      return '00:00:00';
    }
    final hours = remaining.inHours.toString().padLeft(2, '0');
    final minutes = (remaining.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (remaining.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  /// Compact human readable remaining time (e.g. "1h 45m" or "12m remaining")
  String compactRemainingTime([DateTime? now]) {
    final remaining = remainingDuration(now);
    if (remaining == Duration.zero) {
      return 'Expired';
    }
    final hours = remaining.inHours;
    final minutes = remaining.inMinutes % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m remaining';
    }
    final seconds = remaining.inSeconds % 60;
    if (minutes > 0) {
      return '${minutes}m ${seconds}s remaining';
    }
    return '${seconds}s remaining';
  }

  /// Standard JSON serialization matching future PostgreSQL table:
  /// `location_sharing_sessions` (id / session_id, bus_id, started_at, expires_at, is_active)
  Map<String, dynamic> toJson() {
    return {
      'id': sessionId,
      'session_id': sessionId,
      'bus_id': busId,
      'started_at': startedAt.toUtc().toIso8601String(),
      'expires_at': expiresAt.toUtc().toIso8601String(),
      'is_active': isActive,
    };
  }

  /// Deserializes JSON payload supporting both Supabase snake_case and camelCase fields.
  factory LocationSharingSession.fromJson(Map<String, dynamic> json) {
    final rawId = json['id']?.toString() ??
        json['session_id']?.toString() ??
        json['sessionId']?.toString() ??
        '';
    final rawBusId = json['bus_id']?.toString() ?? json['busId']?.toString() ?? 'bus_1';

    final rawStarted = json['started_at'] ?? json['startedAt'];
    final rawExpires = json['expires_at'] ?? json['expiresAt'];

    final startedAt = rawStarted is String
        ? (DateTime.tryParse(rawStarted) ?? DateTime.now())
        : DateTime.now();

    final expiresAt = rawExpires is String
        ? (DateTime.tryParse(rawExpires) ?? startedAt.add(const Duration(hours: 2)))
        : startedAt.add(const Duration(hours: 2));

    final isActive = json['is_active'] as bool? ?? json['isActive'] as bool? ?? true;

    return LocationSharingSession(
      sessionId: rawId,
      busId: rawBusId,
      startedAt: startedAt,
      expiresAt: expiresAt,
      isActive: isActive,
    );
  }

  LocationSharingSession copyWith({
    String? sessionId,
    String? busId,
    DateTime? startedAt,
    DateTime? expiresAt,
    bool? isActive,
  }) {
    return LocationSharingSession(
      sessionId: sessionId ?? this.sessionId,
      busId: busId ?? this.busId,
      startedAt: startedAt ?? this.startedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocationSharingSession &&
          runtimeType == other.runtimeType &&
          sessionId == other.sessionId &&
          busId == other.busId &&
          startedAt == other.startedAt &&
          expiresAt == other.expiresAt &&
          isActive == other.isActive;

  @override
  int get hashCode => Object.hash(
        sessionId,
        busId,
        startedAt,
        expiresAt,
        isActive,
      );

  @override
  String toString() {
    return 'LocationSharingSession(id: $sessionId, busId: $busId, active: $isActive, expires: $expiresAt)';
  }
}
