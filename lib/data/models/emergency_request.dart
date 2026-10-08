enum RequestUrgency {
  critical,
  medium,
  low,
}

enum RequestCategory {
  blood,
  ride,
  notes,
  other,
}

class EmergencyRequest {
  final String id;
  final String title;
  final String description;
  final String patientLocation;
  final String bloodGroup;
  final RequestCategory category;
  final RequestUrgency urgency;
  final String contactNumber;
  final String postedBy;
  final DateTime postedAt;

  const EmergencyRequest({
    required this.id,
    required this.title,
    required this.description,
    required this.patientLocation,
    required this.bloodGroup,
    required this.category,
    required this.urgency,
    required this.contactNumber,
    required this.postedBy,
    required this.postedAt,
  });
}
