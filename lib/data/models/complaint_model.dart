class ComplaintModel {
  final String id;
  final String title;
  final String body;
  final String? imageUrl;
  final String studentName;
  final String studentId;
  final String department;
  final String semester;
  final String email;
  final String pickupDestination;
  final DateTime submittedAt;
  final String status;

  const ComplaintModel({
    required this.id,
    required this.title,
    required this.body,
    this.imageUrl,
    required this.studentName,
    required this.studentId,
    required this.department,
    required this.semester,
    required this.email,
    required this.pickupDestination,
    required this.submittedAt,
    this.status = 'Submitted',
  });
}
