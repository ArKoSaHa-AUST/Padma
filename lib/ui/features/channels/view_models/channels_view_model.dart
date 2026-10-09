import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../../data/models/blood_request_model.dart';
import '../../../../data/models/chat_message.dart';
import '../../../../data/models/complaint_model.dart';
import '../../../../data/models/lost_found_model.dart';
import '../../../../data/models/post_response_model.dart';
import '../../../../data/models/post_comment_model.dart';
import '../../../../data/models/notification_item.dart';
import '../../../../data/services/mock_data_service.dart';
import '../../../../data/services/supabase_service.dart';

class ChannelsViewModel extends ChangeNotifier {
  final List<ChatMessage> _rulesMessages = MockDataService.getRulesAndRegulationsMessages();
  final List<ChatMessage> _announcementsMessages = MockDataService.getAnnouncementsMessages();
  final List<ChatMessage> _padma1Messages = MockDataService.getBus1TelemetryMessages();
  final List<ChatMessage> _padma2Messages = MockDataService.getBus2TelemetryMessages();

  // Contact Admin 1-on-1 Messages (Keyed by conversation or stored with recipientId)
  final List<ChatMessage> _contactAdminMessages = [
    ChatMessage(
      id: 'dm_1',
      senderName: 'Engr. Rafiqul Islam (Admin 1)',
      senderRole: 'Transport Admin',
      senderTag: 'Rafiq_Transport_Staff_Campus',
      avatarInitials: 'RI',
      badgeText: 'ADMIN 1',
      text: 'Hello! I am Engr. Rafiqul Islam, Transport & Fleet Officer. How can I assist you with bus routes or transit issues today?',
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      recipientId: 'user_student_padma',
    ),
  ];

  // Blood Requests List
  final List<BloodRequestModel> _bloodRequests = [
    BloodRequestModel(
      id: 'bld_1',
      title: 'Urgent O+ Blood Needed for Open Heart Surgery',
      bloodGroup: 'O+',
      hospitalName: 'National Heart Foundation, Mirpur-2',
      patientDetails: 'Father of AUST CSE student, scheduled for bypass surgery tomorrow morning.',
      messageBody: '2 units of fresh whole blood required. Attendant available at hospital cabin 402.',
      requiredDate: 'Tomorrow 08:00 AM',
      contactNumber: '+880 1711-223344',
      emailAddress: 'padmaStudent@aust.edu',
      extraInformation: 'Donor will be picked up and dropped off if needed.',
      requesterName: 'Padma Student',
      requesterTag: 'Padma_CSE_4-1_Mirpur10',
      createdAt: DateTime.now().subtract(const Duration(minutes: 40)),
    ),
    BloodRequestModel(
      id: 'bld_2',
      title: 'Emergency B+ Blood for Accident Emergency',
      bloodGroup: 'B+',
      hospitalName: 'Dhaka Medical College Hospital (DMCH)',
      patientDetails: 'Emergency Ward 14, Bed 8',
      messageBody: '1 unit required immediately for blood transfusion.',
      requiredDate: 'Today ASAP',
      contactNumber: '+880 1822-998877',
      emailAddress: 'tanvir.cse@aust.edu',
      extraInformation: 'Patient relative at hospital reception.',
      requesterName: 'Tanvir Ahmed',
      requesterTag: 'Tanvir_CSE_4-1_Mirpur10',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
  ];

  // Lost & Found Items List
  final List<LostFoundModel> _lostFoundItems = [
    LostFoundModel(
      id: 'lf_1',
      title: 'Lost Black Leather Wallet in Padma 1',
      description: 'Contains AUST Student ID card and blue umbrella. Left on upper deck 3rd row.',
      type: LostFoundType.lost,
      location: 'Padma 1 (Mirpur Route)',
      contact: '+880 1711-000000',
      authorName: 'Padma Student',
      authorTag: 'Padma_CSE_4-1_Mirpur10',
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    LostFoundModel(
      id: 'lf_2',
      title: 'Found Casio Scientific Calculator (fx-991EX)',
      description: 'Found on seat 5B of Padma 2. Handed over to driver Md. Al-Amin.',
      type: LostFoundType.found,
      location: 'Padma 2 (Uttara Route)',
      contact: '+880 1812-345678',
      authorName: 'Dr. Shahed Rahman',
      authorTag: 'Shahed_StudentAffairs_Official_Campus',
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
  ];

  // Post Responses List (Blood Donations and Lost & Found Claims)
  final List<PostResponseModel> _postResponses = [
    PostResponseModel(
      id: 'resp_bld_1',
      postId: 'bld_1',
      postType: 'blood',
      postTitle: 'Urgent O+ Blood Needed for Open Heart Surgery',
      postSummary: 'O+ at National Heart Foundation',
      requesterId: 'user_student_padma',
      requesterName: 'Padma Student',
      requesterTag: 'Padma_CSE_4-1_Mirpur10',
      responderId: 'user_2',
      responderName: 'Siam Chowdhury',
      responderTag: 'Siam_CSE_3-1_Mirpur10',
      department: 'CSE',
      semester: '3-1',
      contactNumber: '+880 1711-889900',
      fbLink: 'https://facebook.com/siam.aust',
      availability: 'Available today afternoon after 2 PM',
      notes: 'Eligible donor, O+ verified, donated 5 months ago.',
      status: 'pending',
      createdAt: DateTime.now().subtract(const Duration(minutes: 25)),
    ),
    PostResponseModel(
      id: 'resp_lf_1',
      postId: 'lf_1',
      postType: 'lost_found',
      postTitle: 'Lost Black Leather Wallet in Padma 1',
      postSummary: 'Padma 1 (Mirpur Route)',
      requesterId: 'user_student_padma',
      requesterName: 'Padma Student',
      requesterTag: 'Padma_CSE_4-1_Mirpur10',
      responderId: 'user_3',
      responderName: 'Sadia Afrin',
      responderTag: 'Sadia_CSE_2-2_Campus',
      department: 'CSE',
      semester: '2-2',
      contactNumber: '+880 1700-112233',
      fbLink: 'https://facebook.com/sadia.aust',
      availability: 'Available at AUST Library 3rd Floor',
      notes: 'I saw this wallet on the upper deck seat 3 and handed it to the bus helper.',
      status: 'contacted',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
  ];

  // Lost & Found Post Comments
  final List<PostCommentModel> _postComments = [
    PostCommentModel(
      id: 'comm_1',
      postId: 'lf_1',
      userId: 'user_2',
      userName: 'Siam Chowdhury',
      userTag: 'Siam_CSE_3-1_Mirpur10',
      content: 'Is this wallet still at the security gate or with the bus conductor?',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    PostCommentModel(
      id: 'comm_2',
      postId: 'lf_1',
      userId: 'user_student_padma',
      userName: 'Padma Student',
      userTag: 'Padma_CSE_4-1_Mirpur10',
      content: 'It was handed over to the conductor uncle of Padma 1 on Mirpur route.',
      createdAt: DateTime.now().subtract(const Duration(minutes: 50)),
    ),
    PostCommentModel(
      id: 'comm_3',
      postId: 'lf_2',
      userId: 'user_3',
      userName: 'Sadia Afrin',
      userTag: 'Sadia_CSE_2-2_Campus',
      content: 'Does the calculator have a red sticker on the slide cover? I lost mine yesterday.',
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
  ];

  // Complaints List (Only visible to Admin)
  final List<ComplaintModel> _complaints = [
    ComplaintModel(
      id: 'cmp_1',
      title: 'AC cooling issue in Padma 1 upper deck',
      body: 'The air conditioning vents on the upper deck row 4 were not functioning during afternoon trip.',
      studentName: 'Padma Student',
      studentId: '2023202420252026',
      department: 'CSE',
      semester: '4-1',
      email: 'padmaStudent@aust.edu',
      pickupDestination: 'Mirpur 10',
      submittedAt: DateTime.now().subtract(const Duration(hours: 4)),
      status: 'Under Review',
    ),
  ];

  // Dynamic Notifications List
  final List<NotificationItem> _notifications = [
    NotificationItem(
      id: 'notif_bus1_start',
      title: 'Padma 1 Journey Started',
      description: 'Bus 1 (Mirpur Route) has started its morning journey from Mirpur 12 Bus Stand.',
      timestamp: DateTime.now().subtract(const Duration(minutes: 18)),
      type: NotificationType.transit,
      icon: Icons.directions_bus_rounded,
      color: const Color(0xFF14B8A6),
      relatedChannel: 'padma-1',
    ),
    NotificationItem(
      id: 'notif_bus1_near',
      title: 'Bus Almost Reached Your Destination',
      description: 'Padma 1 is almost reached to your destination (Mirpur 10 - arriving in ~2 mins!).',
      timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
      type: NotificationType.transit,
      icon: Icons.near_me_rounded,
      color: const Color(0xFFF59E0B),
      relatedChannel: 'padma-1',
    ),
    NotificationItem(
      id: 'notif_bus2_start',
      title: 'Padma 2 Journey Started',
      description: 'Bus 2 (Uttara Route) has started the journey from Uttara House Building.',
      timestamp: DateTime.now().subtract(const Duration(minutes: 25)),
      type: NotificationType.transit,
      icon: Icons.directions_bus_rounded,
      color: const Color(0xFF14B8A6),
      relatedChannel: 'padma-2',
    ),
    NotificationItem(
      id: 'notif_ann_1',
      title: 'Campus Midterm Transport Schedule',
      description: 'Transport Admin announced: Morning trips will operate 15 mins earlier starting Sunday.',
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      type: NotificationType.announcement,
      icon: Icons.campaign_rounded,
      color: const Color(0xFF8B5CF6),
      relatedChannel: 'announcements',
    ),
    NotificationItem(
      id: 'notif_rules_1',
      title: 'Rules & Regulations Updated',
      description: 'Admin published: Physical or digital Padma Verified pass mandatory upon boarding.',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      type: NotificationType.rules,
      icon: Icons.gavel_rounded,
      color: const Color(0xFF3B82F6),
      relatedChannel: 'rules-and-regulation',
    ),
    NotificationItem(
      id: 'notif_mention_1',
      title: 'You were mentioned in Padma 1',
      description: 'Tanvir_CSE_4-1_Mirpur10: "@Padma_CSE_4-1_Mirpur10 you can board smoothly!"',
      timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
      type: NotificationType.mention,
      icon: Icons.alternate_email_rounded,
      color: const Color(0xFFEF4444),
      relatedChannel: 'padma-1',
    ),
  ];

  String _selectedContactAdminId = 'admin_1'; // 'admin_1' or 'admin_2'

  StreamSubscription<List<Map<String, dynamic>>>? _messagesSub;

  List<ChatMessage> get rulesMessages => _rulesMessages;
  List<ChatMessage> get generalMessages => _rulesMessages; // For backwards compatibility
  List<ChatMessage> get announcementsMessages => _announcementsMessages;
  List<ChatMessage> get announcementMessages => _announcementsMessages;
  List<ChatMessage> get padma1Messages => _padma1Messages;
  List<ChatMessage> get bus1Messages => _padma1Messages;
  List<ChatMessage> get padma2Messages => _padma2Messages;
  List<ChatMessage> get bus2Messages => _padma2Messages;
  List<BloodRequestModel> get bloodRequests => _bloodRequests;
  List<LostFoundModel> get lostFoundItems => _lostFoundItems;
  List<PostResponseModel> get postResponses => _postResponses;
  List<PostCommentModel> get postComments => List.unmodifiable(_postComments);
  List<PostCommentModel> getCommentsForPost(String postId) => _postComments.where((c) => c.postId == postId).toList();
  List<ComplaintModel> get complaints => _complaints;
  List<NotificationItem> get notifications => _notifications;
  String get selectedContactAdminId => _selectedContactAdminId;

  List<({String id, String name, String role, String designation, String tag})> get admins => const [
    (id: 'admin_1', name: 'Engr. Rafiqul Islam', role: 'Chief Transport Officer', designation: 'Admin 1 (Transport & Fleet Operations)', tag: 'Rafiq_Transport_Staff_Campus'),
    (id: 'admin_2', name: 'Dr. Shahed Rahman', role: 'Student Affairs Admin', designation: 'Admin 2 (Student Welfare & Grievances)', tag: 'Shahed_StudentAffairs_Official_Campus'),
  ];

  // Backwards compatibility getter for requests
  List<dynamic> get requests => _bloodRequests;
  String get selectedRequestFilter => 'all';

  void setRequestFilter(String f) {
    notifyListeners();
  }

  void setSelectedContactAdmin(String adminId) {
    _selectedContactAdminId = adminId;
    notifyListeners();
  }

  List<ChatMessage> getContactAdminMessagesForUser(String userId, String adminId) {
    return _contactAdminMessages.where((m) {
      if (adminId == 'admin_1') {
        return m.senderTag?.contains('Rafiq') == true || m.recipientId == userId || m.senderName.contains('Admin 1');
      } else {
        return m.senderTag?.contains('Shahed') == true || m.recipientId == userId || m.senderName.contains('Admin 2');
      }
    }).toList();
  }

  List<ChatMessage> getAdminConversation({required String studentId, required String adminId}) {
    return _contactAdminMessages.where((m) {
      if (m.recipientId == adminId && m.senderRole == 'Student') return true;
      if (m.recipientId == studentId && (adminId == 'admin_1' ? (m.senderName.contains('Rafiq') || m.senderTag?.contains('Rafiq') == true) : (m.senderName.contains('Shahed') || m.senderTag?.contains('Shahed') == true))) return true;
      return false;
    }).toList();
  }

  List<ChatMessage> getMessagesForChannel(String channelKey) {
    switch (channelKey) {
      case 'rules-and-regulation':
      case 'general':
        return _rulesMessages;
      case 'announcements':
        return _announcementsMessages;
      case 'padma-1':
      case 'bus-1-mirpur':
        return _padma1Messages;
      case 'padma-2':
      case 'bus-2-uttara':
        return _padma2Messages;
      default:
        return _rulesMessages;
    }
  }

  // Post in Rules and Regulation (Admin only)
  void sendRulesMessage(String text, {String senderName = 'Engr. Rafiqul Islam', String senderTag = 'Rafiq_Transport_Staff_Campus', bool isAdmin = true}) {
    if (!isAdmin) return;
    final msg = ChatMessage(
      id: 'rule_${DateTime.now().millisecondsSinceEpoch}',
      senderName: senderName,
      senderRole: 'Transport Admin',
      senderTag: senderTag,
      avatarInitials: 'ADM',
      badgeText: 'POLICY DIRECTIVE',
      text: text,
      timestamp: DateTime.now(),
    );
    _rulesMessages.add(msg);
    _notifications.insert(
      0,
      NotificationItem(
        id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
        title: 'New Rule Published',
        description: text.replaceAll('*', ''),
        timestamp: DateTime.now(),
        type: NotificationType.rules,
        icon: Icons.gavel_rounded,
        color: const Color(0xFF3B82F6),
        relatedChannel: 'rules-and-regulation',
      ),
    );
    notifyListeners();
  }

  // Post in Announcements (Admin only)
  void sendAnnouncementMessage(String text, {String senderName = 'Engr. Rafiqul Islam', String senderTag = 'Rafiq_Transport_Staff_Campus', bool isAdmin = true}) {
    if (!isAdmin) return;
    final msg = ChatMessage(
      id: 'ann_${DateTime.now().millisecondsSinceEpoch}',
      senderName: senderName,
      senderRole: 'Transport Admin',
      senderTag: senderTag,
      avatarInitials: 'ADM',
      badgeText: 'ANNOUNCEMENT',
      text: text,
      timestamp: DateTime.now(),
    );
    _announcementsMessages.add(msg);
    _notifications.insert(
      0,
      NotificationItem(
        id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
        title: 'New Announcement',
        description: text.replaceAll('*', ''),
        timestamp: DateTime.now(),
        type: NotificationType.announcement,
        icon: Icons.campaign_rounded,
        color: const Color(0xFF8B5CF6),
        relatedChannel: 'announcements',
      ),
    );
    notifyListeners();
  }

  // Send message in Padma 1 (User and Admin both)
  void sendPadma1Message(String text, {required String senderName, required String senderTag, String senderRole = 'Student'}) {
    final msg = ChatMessage(
      id: 'p1_${DateTime.now().millisecondsSinceEpoch}',
      senderName: senderName,
      senderRole: senderRole,
      senderTag: senderTag,
      avatarInitials: senderName.isNotEmpty ? senderName.substring(0, 2).toUpperCase() : 'AU',
      text: text,
      timestamp: DateTime.now(),
    );
    _padma1Messages.add(msg);
    _checkForMentionsAndNotify(text, senderTag, 'Padma 1', 'padma-1');
    notifyListeners();
  }

  // Send message in Padma 2 (User and Admin both)
  void sendPadma2Message(String text, {required String senderName, required String senderTag, String senderRole = 'Student'}) {
    final msg = ChatMessage(
      id: 'p2_${DateTime.now().millisecondsSinceEpoch}',
      senderName: senderName,
      senderRole: senderRole,
      senderTag: senderTag,
      avatarInitials: senderName.isNotEmpty ? senderName.substring(0, 2).toUpperCase() : 'AU',
      text: text,
      timestamp: DateTime.now(),
    );
    _padma2Messages.add(msg);
    _checkForMentionsAndNotify(text, senderTag, 'Padma 2', 'padma-2');
    notifyListeners();
  }

  // Send Private Contact Admin message
  void sendContactAdminMessage({
    required String text,
    required String senderName,
    required String senderTag,
    required String adminId,
    required String studentId,
  }) {
    final msg = ChatMessage(
      id: 'dm_${DateTime.now().millisecondsSinceEpoch}',
      senderName: senderName,
      senderRole: 'Student',
      senderTag: senderTag,
      avatarInitials: senderName.isNotEmpty ? senderName.substring(0, 2).toUpperCase() : 'ST',
      text: text,
      timestamp: DateTime.now(),
      recipientId: adminId,
    );
    _contactAdminMessages.add(msg);
    notifyListeners();

    // Auto admin acknowledgment simulation
    Future.delayed(const Duration(seconds: 1), () {
      final adminReply = ChatMessage(
        id: 'dm_reply_${DateTime.now().millisecondsSinceEpoch}',
        senderName: adminId == 'admin_1' ? 'Engr. Rafiqul Islam (Admin 1)' : 'Dr. Shahed Rahman (Admin 2)',
        senderRole: 'Transport Admin',
        senderTag: adminId == 'admin_1' ? 'Rafiq_Transport_Staff_Campus' : 'Shahed_StudentAffairs_Official_Campus',
        avatarInitials: adminId == 'admin_1' ? 'RI' : 'SR',
        badgeText: adminId == 'admin_1' ? 'ADMIN 1' : 'ADMIN 2',
        text: 'Thank you for reaching out. We have logged your request and will address it promptly.',
        timestamp: DateTime.now(),
        recipientId: studentId,
      );
      _contactAdminMessages.add(adminReply);
      notifyListeners();
    });
  }

  // Add Blood Request (Both user and admin)
  void addBloodRequest({
    required String title,
    required String bloodGroup,
    required String hospitalName,
    String? patientDetails,
    String? messageBody,
    String? requiredDate,
    required String contactNumber,
    required String emailAddress,
    String? extraInformation,
    required String requesterName,
    required String requesterTag,
  }) {
    final req = BloodRequestModel(
      id: 'bld_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      bloodGroup: bloodGroup,
      hospitalName: hospitalName,
      patientDetails: patientDetails,
      messageBody: messageBody,
      requiredDate: requiredDate,
      contactNumber: contactNumber,
      emailAddress: emailAddress,
      extraInformation: extraInformation,
      requesterName: requesterName,
      requesterTag: requesterTag,
      createdAt: DateTime.now(),
    );
    _bloodRequests.insert(0, req);
    _notifications.insert(
      0,
      NotificationItem(
        id: 'notif_bld_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Emergency $bloodGroup Blood Needed',
        description: '$title at $hospitalName. Contact: $contactNumber',
        timestamp: DateTime.now(),
        type: NotificationType.blood,
        icon: Icons.bloodtype_rounded,
        color: const Color(0xFFEF4444),
        relatedChannel: 'blood-request',
      ),
    );
    notifyListeners();
  }

  void postBloodRequest({
    required String title,
    required String bloodGroup,
    required String hospitalName,
    String? patientDetails,
    String? messageBody,
    String? requiredDate,
    required String contactNumber,
    required String email,
    String? extraInfo,
    required String authorName,
    required String authorTag,
  }) {
    addBloodRequest(
      title: title,
      bloodGroup: bloodGroup,
      hospitalName: hospitalName,
      patientDetails: patientDetails,
      messageBody: messageBody,
      requiredDate: requiredDate,
      contactNumber: contactNumber,
      emailAddress: email,
      extraInformation: extraInfo,
      requesterName: authorName,
      requesterTag: authorTag,
    );
  }

  // Add Lost and Found Item (Both user and admin)
  void addLostFoundItem({
    required String title,
    required String description,
    LostFoundType type = LostFoundType.lost,
    String? location,
    String? contact,
    String? imageUrl,
    required String authorName,
    required String authorTag,
  }) {
    final item = LostFoundModel(
      id: 'lf_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      description: description,
      type: type,
      location: location,
      contact: contact,
      imageUrl: imageUrl,
      authorName: authorName,
      authorTag: authorTag,
      createdAt: DateTime.now(),
    );
    _lostFoundItems.insert(0, item);
    notifyListeners();
  }

  void postLostFoundItem({
    required String title,
    required String description,
    String type = 'lost',
    String? location,
    String? contactNumber,
    String? imageUrl,
    required String authorName,
    required String authorTag,
  }) {
    addLostFoundItem(
      title: title,
      description: description,
      type: type == 'found' ? LostFoundType.found : LostFoundType.lost,
      location: location,
      contact: contactNumber,
      imageUrl: imageUrl,
      authorName: authorName,
      authorTag: authorTag,
    );
  }

  // Edit / Delete Blood Request
  void updateBloodRequest(BloodRequestModel updated) {
    final idx = _bloodRequests.indexWhere((r) => r.id == updated.id);
    if (idx != -1) {
      _bloodRequests[idx] = updated;
      notifyListeners();
    }
  }

  void deleteBloodRequest(String id) {
    _bloodRequests.removeWhere((r) => r.id == id);
    _postResponses.removeWhere((r) => r.postId == id);
    notifyListeners();
  }

  // Edit / Delete Lost & Found Item
  void updateLostFoundItem(LostFoundModel updated) {
    final idx = _lostFoundItems.indexWhere((i) => i.id == updated.id);
    if (idx != -1) {
      _lostFoundItems[idx] = updated;
      notifyListeners();
    }
  }

  void deleteLostFoundItem(String id) {
    _lostFoundItems.removeWhere((i) => i.id == id);
    _postResponses.removeWhere((r) => r.postId == id);
    notifyListeners();
  }

  // Add / Edit / Delete / Status Update for Post Responses
  void addPostResponse({
    required String postId,
    required String postType,
    required String postTitle,
    String postSummary = '',
    String? requesterId,
    required String requesterName,
    required String requesterTag,
    required String responderId,
    required String responderName,
    required String responderTag,
    String department = 'CSE',
    String semester = '4-1',
    required String contactNumber,
    String? fbLink,
    String? availability,
    String? notes,
  }) {
    final response = PostResponseModel(
      id: 'resp_${DateTime.now().millisecondsSinceEpoch}',
      postId: postId,
      postType: postType,
      postTitle: postTitle,
      postSummary: postSummary,
      requesterId: requesterId,
      requesterName: requesterName,
      requesterTag: requesterTag,
      responderId: responderId,
      responderName: responderName,
      responderTag: responderTag,
      department: department,
      semester: semester,
      contactNumber: contactNumber,
      fbLink: fbLink,
      availability: availability,
      notes: notes,
      status: 'pending',
      createdAt: DateTime.now(),
    );
    _postResponses.insert(0, response);
    _notifications.insert(
      0,
      NotificationItem(
        id: 'notif_resp_${DateTime.now().millisecondsSinceEpoch}',
        title: postType == 'blood' ? 'New Blood Donation Offer' : 'New Lost & Found Response',
        description: '$responderName responded to "$postTitle"',
        timestamp: DateTime.now(),
        type: postType == 'blood' ? NotificationType.blood : NotificationType.transit,
        icon: postType == 'blood' ? Icons.volunteer_activism_rounded : Icons.mark_chat_read_rounded,
        color: postType == 'blood' ? const Color(0xFFEF4444) : const Color(0xFFF59E0B),
        relatedChannel: 'post-responses',
      ),
    );
    notifyListeners();
  }

  void updatePostResponse(PostResponseModel updated) {
    final idx = _postResponses.indexWhere((r) => r.id == updated.id);
    if (idx != -1) {
      _postResponses[idx] = updated;
      notifyListeners();
    }
  }

  void deletePostResponse(String responseId) {
    _postResponses.removeWhere((r) => r.id == responseId);
    notifyListeners();
  }

  void updateResponseStatus(String responseId, String newStatus) {
    final idx = _postResponses.indexWhere((r) => r.id == responseId);
    if (idx != -1) {
      _postResponses[idx] = _postResponses[idx].copyWith(status: newStatus);
      notifyListeners();
    }
  }

  // -------------------------------------------------------------
  // Post Comments Methods (Lost & Found)
  // -------------------------------------------------------------
  void addPostComment({
    required String postId,
    required String userId,
    required String userName,
    required String userTag,
    required String content,
  }) {
    if (content.trim().isEmpty) return;

    final comment = PostCommentModel(
      id: 'comm_${DateTime.now().millisecondsSinceEpoch}',
      postId: postId,
      userId: userId,
      userName: userName,
      userTag: userTag,
      content: content.trim(),
      createdAt: DateTime.now(),
    );
    _postComments.add(comment);

    // Notify author if different user
    final postIndex = _lostFoundItems.indexWhere((i) => i.id == postId);
    if (postIndex != -1) {
      final post = _lostFoundItems[postIndex];
      if (post.authorTag != userTag) {
        _notifications.insert(
          0,
          NotificationItem(
            id: 'notif_comm_${DateTime.now().millisecondsSinceEpoch}',
            title: 'New comment on your notice',
            description: '$userTag commented: "$content"',
            timestamp: DateTime.now(),
            type: NotificationType.transit,
            icon: Icons.chat_bubble_outline_rounded,
            color: const Color(0xFFF59E0B),
            relatedChannel: 'lost-and-found',
          ),
        );
      }
    }

    notifyListeners();

    try {
      SupabaseService.instance.client.from('post_comments').insert(comment.toJson()).then((_) {}, onError: (e) {
        debugPrint('[ChannelsViewModel] Supabase insert comment error: $e');
      });
    } catch (e) {
      debugPrint('[ChannelsViewModel] Insert comment exception: $e');
    }
  }

  void updatePostComment(String commentId, String newContent) {
    final idx = _postComments.indexWhere((c) => c.id == commentId);
    if (idx != -1) {
      _postComments[idx] = _postComments[idx].copyWith(
        content: newContent.trim(),
        updatedAt: DateTime.now(),
      );
      notifyListeners();

      try {
        SupabaseService.instance.client.from('post_comments').update({
          'content': newContent.trim(),
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', commentId).then((_) {}, onError: (e) {
          debugPrint('[ChannelsViewModel] Supabase update comment error: $e');
        });
      } catch (e) {
        debugPrint('[ChannelsViewModel] Update comment exception: $e');
      }
    }
  }

  void deletePostComment(String commentId) {
    _postComments.removeWhere((c) => c.id == commentId);
    notifyListeners();

    try {
      SupabaseService.instance.client.from('post_comments').delete().eq('id', commentId).then((_) {}, onError: (e) {
        debugPrint('[ChannelsViewModel] Supabase delete comment error: $e');
      });
    } catch (e) {
      debugPrint('[ChannelsViewModel] Delete comment exception: $e');
    }
  }

  void sendPrivateAdminMessage({
    required String studentId,
    required String adminId,
    required String text,
    required String senderName,
    required String senderTag,
    required String senderRole,
  }) {
    final msg = ChatMessage(
      id: 'dm_${DateTime.now().millisecondsSinceEpoch}',
      senderName: senderName,
      senderRole: senderRole,
      senderTag: senderTag,
      avatarInitials: senderName.isNotEmpty ? senderName.substring(0, 2).toUpperCase() : 'AU',
      text: text,
      timestamp: DateTime.now(),
      recipientId: senderRole == 'Student' ? adminId : studentId,
    );
    _contactAdminMessages.add(msg);
    notifyListeners();
  }

  void markAllNotificationsRead() {
    for (var n in _notifications) {
      n.isRead = true;
    }
    notifyListeners();
  }

  void triggerBusJourneyStartNotification({required String busName, required String route}) {
    _notifications.insert(
      0,
      NotificationItem(
        id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
        title: '$busName Journey Started',
        description: '$busName has started its journey on $route.',
        timestamp: DateTime.now(),
        type: NotificationType.journeyStart,
        icon: Icons.directions_bus_rounded,
        color: const Color(0xFFF59E0B),
        relatedChannel: busName.contains('1') ? 'padma-1' : 'padma-2',
      ),
    );
    notifyListeners();
  }

  void triggerDestinationApproachNotification({required String busName, required String destination, required int etaMinutes}) {
    _notifications.insert(
      0,
      NotificationItem(
        id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
        title: '$busName Approaching $destination',
        description: '$busName is almost reached to your destination ($destination). ETA ~$etaMinutes mins.',
        timestamp: DateTime.now(),
        type: NotificationType.destinationArrival,
        icon: Icons.pin_drop_rounded,
        color: const Color(0xFF10B981),
        relatedChannel: busName.contains('1') ? 'padma-1' : 'padma-2',
      ),
    );
    notifyListeners();
  }

  // Submit Complaint (Student info auto-populated, only admin can view list)
  void submitComplaint({
    required String title,
    required String body,
    String? imageUrl,
    required String studentName,
    required String studentId,
    required String department,
    required String semester,
    required String email,
    required String pickupDestination,
  }) {
    final complaint = ComplaintModel(
      id: 'cmp_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      body: body,
      imageUrl: imageUrl,
      studentName: studentName,
      studentId: studentId,
      department: department,
      semester: semester,
      email: email,
      pickupDestination: pickupDestination,
      submittedAt: DateTime.now(),
      status: 'Submitted',
    );
    _complaints.insert(0, complaint);
    notifyListeners();
  }

  void toggleReaction(ChatMessage message, String emoji) {
    final reactionIndex = message.reactions.indexWhere((r) => r.emoji == emoji);
    if (reactionIndex != -1) {
      final r = message.reactions[reactionIndex];
      if (r.isUserReacted) {
        r.count--;
        r.isUserReacted = false;
        if (r.count <= 0) {
          message.reactions.removeAt(reactionIndex);
        }
      } else {
        r.count++;
        r.isUserReacted = true;
      }
    } else {
      message.reactions.add(ChatReaction(emoji: emoji, count: 1, isUserReacted: true));
    }
    notifyListeners();
  }

  void _checkForMentionsAndNotify(String text, String senderTag, String channelName, String channelKey) {
    if (text.contains('@')) {
      final mentionMatch = RegExp(r'@([a-zA-Z0-9_-]+)').firstMatch(text);
      if (mentionMatch != null) {
        final mentioned = mentionMatch.group(1) ?? '';
        _notifications.insert(
          0,
          NotificationItem(
            id: 'notif_mention_${DateTime.now().millisecondsSinceEpoch}',
            title: 'You were mentioned in $channelName',
            description: '$senderTag: "$text"',
            timestamp: DateTime.now(),
            type: NotificationType.mention,
            icon: Icons.alternate_email_rounded,
            color: const Color(0xFFEF4444),
            relatedChannel: channelKey,
          ),
        );
      }
    }
  }

  // Backwards compatibility methods
  void sendGeneralMessage(String text) {
    sendPadma1Message(
      text,
      senderName: 'Padma Student',
      senderTag: 'Padma_CSE_4-1_Mirpur10',
      senderRole: 'Student',
    );
  }

  void clearChannel(String channelId) {
    if (channelId == 'rules-and-regulation' || channelId == 'general') {
      _rulesMessages.clear();
    } else if (channelId == 'announcements') {
      _announcementsMessages.clear();
    } else if (channelId == 'padma-1' || channelId == 'bus-1-mirpur') {
      _padma1Messages.clear();
    } else if (channelId == 'padma-2' || channelId == 'bus-2-uttara') {
      _padma2Messages.clear();
    }
    notifyListeners();
  }

  void deleteMessage(String channelId, String messageId) {
    if (channelId == 'rules-and-regulation' || channelId == 'general') {
      _rulesMessages.removeWhere((m) => m.id == messageId);
    } else if (channelId == 'announcements') {
      _announcementsMessages.removeWhere((m) => m.id == messageId);
    } else if (channelId == 'padma-1' || channelId == 'bus-1-mirpur') {
      _padma1Messages.removeWhere((m) => m.id == messageId);
    } else if (channelId == 'padma-2' || channelId == 'bus-2-uttara') {
      _padma2Messages.removeWhere((m) => m.id == messageId);
    }
    notifyListeners();
  }

  void broadcastDispatchMessage(String channelId, String text, {String? senderName, String? senderRole, String? badgeText}) {
    if (channelId == 'rules-and-regulation' || channelId == 'general') {
      sendRulesMessage(text, senderName: senderName ?? 'Transport Admin', senderTag: 'Rafiq_Transport_Staff_Campus', isAdmin: true);
    } else if (channelId == 'announcements') {
      sendAnnouncementMessage(text, senderName: senderName ?? 'Transport Admin', senderTag: 'Rafiq_Transport_Staff_Campus', isAdmin: true);
    } else if (channelId == 'bus-1-mirpur' || channelId == 'padma-1') {
      sendPadma1Message(text, senderName: senderName ?? 'Transport Admin', senderTag: 'Rafiq_Transport_Staff_Campus', senderRole: 'Transport Admin');
    } else {
      sendPadma2Message(text, senderName: senderName ?? 'Transport Admin', senderTag: 'Rafiq_Transport_Staff_Campus', senderRole: 'Transport Admin');
    }
  }

  @override
  void dispose() {
    _messagesSub?.cancel();
    super.dispose();
  }
}
