class PostResponseModel {
  final String id;
  final String postId;
  final String postType; // 'blood' or 'lost_found'
  final String postTitle;
  final String postSummary;
  final String? requesterId;
  final String requesterName;
  final String requesterTag;
  final String responderId;
  final String responderName;
  final String responderTag;
  final String department;
  final String semester;
  final String contactNumber;
  final String? fbLink;
  final String? availability;
  final String? notes;
  final String status; // 'pending', 'contacted', 'accepted', 'completed'
  final DateTime createdAt;

  const PostResponseModel({
    required this.id,
    required this.postId,
    required this.postType,
    required this.postTitle,
    this.postSummary = '',
    this.requesterId,
    required this.requesterName,
    required this.requesterTag,
    required this.responderId,
    required this.responderName,
    required this.responderTag,
    this.department = 'CSE',
    this.semester = '4-1',
    required this.contactNumber,
    this.fbLink,
    this.availability,
    this.notes,
    this.status = 'pending',
    required this.createdAt,
  });

  PostResponseModel copyWith({
    String? id,
    String? postId,
    String? postType,
    String? postTitle,
    String? postSummary,
    String? requesterId,
    String? requesterName,
    String? requesterTag,
    String? responderId,
    String? responderName,
    String? responderTag,
    String? department,
    String? semester,
    String? contactNumber,
    String? fbLink,
    String? availability,
    String? notes,
    String? status,
    DateTime? createdAt,
  }) {
    return PostResponseModel(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      postType: postType ?? this.postType,
      postTitle: postTitle ?? this.postTitle,
      postSummary: postSummary ?? this.postSummary,
      requesterId: requesterId ?? this.requesterId,
      requesterName: requesterName ?? this.requesterName,
      requesterTag: requesterTag ?? this.requesterTag,
      responderId: responderId ?? this.responderId,
      responderName: responderName ?? this.responderName,
      responderTag: responderTag ?? this.responderTag,
      department: department ?? this.department,
      semester: semester ?? this.semester,
      contactNumber: contactNumber ?? this.contactNumber,
      fbLink: fbLink ?? this.fbLink,
      availability: availability ?? this.availability,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory PostResponseModel.fromJson(Map<String, dynamic> json) {
    return PostResponseModel(
      id: json['id'] as String,
      postId: (json['post_id'] ?? json['postId'] ?? '') as String,
      postType: (json['post_type'] ?? json['postType'] ?? 'blood') as String,
      postTitle: (json['post_title'] ?? json['postTitle'] ?? 'Campus Post') as String,
      postSummary: (json['post_summary'] ?? json['postSummary'] ?? '') as String,
      requesterId: json['requester_id'] ?? json['requesterId'] as String?,
      requesterName: (json['requester_name'] ?? json['requesterName'] ?? 'Requester') as String,
      requesterTag: (json['requester_tag'] ?? json['requesterTag'] ?? 'Author') as String,
      responderId: (json['responder_id'] ?? json['responderId'] ?? '') as String,
      responderName: (json['responder_name'] ?? json['responderName'] ?? 'Student') as String,
      responderTag: (json['responder_tag'] ?? json['responderTag'] ?? 'Student') as String,
      department: (json['department'] ?? 'CSE') as String,
      semester: (json['semester'] ?? '4-1') as String,
      contactNumber: (json['contact_number'] ?? json['contactNumber'] ?? '') as String,
      fbLink: json['fb_link'] ?? json['fbLink'] as String?,
      availability: json['availability'] as String?,
      notes: json['notes'] as String?,
      status: (json['status'] ?? 'pending') as String,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'post_id': postId,
      'post_type': postType,
      'post_title': postTitle,
      'post_summary': postSummary,
      'requester_id': requesterId,
      'requester_name': requesterName,
      'requester_tag': requesterTag,
      'responder_id': responderId,
      'responder_name': responderName,
      'responder_tag': responderTag,
      'department': department,
      'semester': semester,
      'contact_number': contactNumber,
      'fb_link': fbLink,
      'availability': availability,
      'notes': notes,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
