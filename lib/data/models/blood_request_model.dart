enum BloodUrgency {
  standard,
  urgent,
  critical;

  String get label {
    switch (this) {
      case BloodUrgency.standard:
        return 'Standard';
      case BloodUrgency.urgent:
        return 'Urgent';
      case BloodUrgency.critical:
        return 'Critical';
    }
  }
}

enum BloodRequestStatus {
  active,
  fulfilled,
  expired;

  String get label {
    switch (this) {
      case BloodRequestStatus.active:
        return 'Needed';
      case BloodRequestStatus.fulfilled:
        return 'Fulfilled';
      case BloodRequestStatus.expired:
        return 'Expired';
    }
  }
}

class BloodRequestModel {
  final String id;
  final String requesterId;
  final String requesterName;
  final String requesterPhone;
  final String bloodGroup;
  final int units;
  final String hospital;
  final String location;
  final DateTime neededBy;
  final BloodUrgency urgency;
  final String? notes;
  final BloodRequestStatus status;
  final List<String> donorUserIds;
  final DateTime createdAt;

  const BloodRequestModel({
    required this.id,
    required this.requesterId,
    required this.requesterName,
    required this.requesterPhone,
    required this.bloodGroup,
    required this.units,
    required this.hospital,
    required this.location,
    required this.neededBy,
    required this.urgency,
    this.notes,
    required this.status,
    this.donorUserIds = const [],
    required this.createdAt,
  });

  BloodRequestModel copyWith({
    String? id,
    String? requesterId,
    String? requesterName,
    String? requesterPhone,
    String? bloodGroup,
    int? units,
    String? hospital,
    String? location,
    DateTime? neededBy,
    BloodUrgency? urgency,
    String? notes,
    BloodRequestStatus? status,
    List<String>? donorUserIds,
    DateTime? createdAt,
  }) {
    return BloodRequestModel(
      id: id ?? this.id,
      requesterId: requesterId ?? this.requesterId,
      requesterName: requesterName ?? this.requesterName,
      requesterPhone: requesterPhone ?? this.requesterPhone,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      units: units ?? this.units,
      hospital: hospital ?? this.hospital,
      location: location ?? this.location,
      neededBy: neededBy ?? this.neededBy,
      urgency: urgency ?? this.urgency,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      donorUserIds: donorUserIds ?? this.donorUserIds,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
