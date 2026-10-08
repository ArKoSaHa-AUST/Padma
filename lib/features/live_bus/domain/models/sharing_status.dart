/// Represents the lifecycle states of live bus location sharing.
enum SharingStatus {
  /// No active sharing session, bus is offline
  idle,

  /// Admin requested sharing, acquiring GPS beacon / connecting
  starting,

  /// Live GPS telemetry is actively streaming
  sharing,

  /// Sharing was cleanly terminated by the admin
  stopped,

  /// Sharing session reached its 2-hour maximum lifetime
  expired,

  /// An error occurred during telemetry streaming or GPS acquisition
  error;

  /// User-friendly display label
  String get label {
    switch (this) {
      case SharingStatus.idle:
        return 'Not Sharing';
      case SharingStatus.starting:
        return 'Starting...';
      case SharingStatus.sharing:
        return 'LIVE';
      case SharingStatus.stopped:
        return 'Sharing Ended';
      case SharingStatus.expired:
        return 'Session Expired';
      case SharingStatus.error:
        return 'Connection Error';
    }
  }

  /// Bengali localized label matching Padma's bilingual design
  String get labelBn {
    switch (this) {
      case SharingStatus.idle:
        return 'শেয়ারিং বন্ধ';
      case SharingStatus.starting:
        return 'শুরু হচ্ছে...';
      case SharingStatus.sharing:
        return 'লাইভ';
      case SharingStatus.stopped:
        return 'শেয়ারিং সমাপ্ত';
      case SharingStatus.expired:
        return 'সময় শেষ';
      case SharingStatus.error:
        return 'ত্রুটি';
    }
  }

  /// Whether the bus is in an active live broadcasting state
  bool get isLive => this == SharingStatus.sharing;

  /// Whether location is currently available to show on map
  bool get hasActiveBroadcast => this == SharingStatus.sharing || this == SharingStatus.starting;
}
