class BloodRequestModel {
  final String id;
  final String title;
  final String bloodGroup;
  final String hospitalName;
  final String? patientDetails;
  final String? messageBody;
  final String? requiredDate;
  final String contactNumber;
  final String emailAddress;
  final String? extraInformation;
  final String requesterName;
  final String requesterTag;
  final DateTime createdAt;

  const BloodRequestModel({
    required this.id,
    required this.title,
    required this.bloodGroup,
    required this.hospitalName,
    this.patientDetails,
    this.messageBody,
    this.requiredDate,
    required this.contactNumber,
    required this.emailAddress,
    this.extraInformation,
    required this.requesterName,
    required this.requesterTag,
    required this.createdAt,
  });

  BloodRequestModel copyWith({
    String? id,
    String? title,
    String? bloodGroup,
    String? hospitalName,
    String? patientDetails,
    String? messageBody,
    String? requiredDate,
    String? contactNumber,
    String? emailAddress,
    String? extraInformation,
    String? requesterName,
    String? requesterTag,
    DateTime? createdAt,
  }) {
    return BloodRequestModel(
      id: id ?? this.id,
      title: title ?? this.title,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      hospitalName: hospitalName ?? this.hospitalName,
      patientDetails: patientDetails ?? this.patientDetails,
      messageBody: messageBody ?? this.messageBody,
      requiredDate: requiredDate ?? this.requiredDate,
      contactNumber: contactNumber ?? this.contactNumber,
      emailAddress: emailAddress ?? this.emailAddress,
      extraInformation: extraInformation ?? this.extraInformation,
      requesterName: requesterName ?? this.requesterName,
      requesterTag: requesterTag ?? this.requesterTag,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  String get authorTag => requesterTag;
  String get authorName => requesterName;
}
