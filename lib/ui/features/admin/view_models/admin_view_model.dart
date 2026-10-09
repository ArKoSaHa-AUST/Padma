import 'package:flutter/material.dart';
import '../../../../data/services/supabase_service.dart';

enum AdminBusStatus {
  onTime,
  delayed,
  waiting,
  breakdown,
  tripEnded;

  String get displayName {
    switch (this) {
      case AdminBusStatus.onTime:
        return 'On Time';
      case AdminBusStatus.delayed:
        return 'Delayed';
      case AdminBusStatus.waiting:
        return 'Waiting at Campus';
      case AdminBusStatus.breakdown:
        return 'Breakdown';
      case AdminBusStatus.tripEnded:
        return 'Trip Ended';
    }
  }

  Color get color {
    switch (this) {
      case AdminBusStatus.onTime:
        return const Color(0xFF10B981);
      case AdminBusStatus.delayed:
        return const Color(0xFFF59E0B);
      case AdminBusStatus.waiting:
        return const Color(0xFF38BDF8);
      case AdminBusStatus.breakdown:
        return const Color(0xFFEF4444);
      case AdminBusStatus.tripEnded:
        return const Color(0xFF64748B);
    }
  }
}

class AdminStoppageWaitNotice {
  final String busId;
  final String stoppageName;
  final String untilTime;
  final String message;
  final DateTime timestamp;

  const AdminStoppageWaitNotice({
    required this.busId,
    required this.stoppageName,
    required this.untilTime,
    required this.message,
    required this.timestamp,
  });
}

class AdminBusStoppage {
  final String name;
  final double lat;
  final double lng;
  final String eta;

  const AdminBusStoppage({
    required this.name,
    required this.lat,
    required this.lng,
    required this.eta,
  });
}

class AdminBusItem {
  final String id;
  String title;
  final String busNumber;
  final String driverName;
  final String driverPhone;
  String currentStop;
  String nextStop;
  int currentStopIndex;
  AdminBusStatus status;
  bool isBroadcastingGps;
  int currentSpeed;
  int passengerCount;
  int etaMinutes;
  double latitude;
  double longitude;
  final List<AdminBusStoppage> stoppages;
  AdminStoppageWaitNotice? activeWaitNotice;
  String? activatedByAdmin;

  AdminBusItem({
    required this.id,
    required this.title,
    required this.busNumber,
    required this.driverName,
    required this.driverPhone,
    required this.currentStop,
    required this.nextStop,
    this.currentStopIndex = 0,
    this.status = AdminBusStatus.tripEnded, // Always starts as Trip Ended
    this.isBroadcastingGps = false,
    this.currentSpeed = 0,
    this.passengerCount = 0,
    this.etaMinutes = 0,
    required this.latitude,
    required this.longitude,
    required this.stoppages,
    this.activeWaitNotice,
    this.activatedByAdmin,
  });

  bool get isTripEnded => status == AdminBusStatus.tripEnded;
}

class AdminAnnouncementItem {
  final String id;
  final String title;
  final String body;
  final String priority; // 'Urgent', 'High', 'Standard'
  final String targetRoute; // 'All Routes', 'Mirpur Route', etc.
  final DateTime timestamp;
  final bool isPinned;

  AdminAnnouncementItem({
    required this.id,
    required this.title,
    required this.body,
    required this.priority,
    required this.targetRoute,
    required this.timestamp,
    this.isPinned = false,
  });
}

class AdminReportedMessage {
  final String id;
  final String studentName;
  final String studentId;
  final String messageContent;
  final String channelName;
  final String reason;
  final DateTime reportedAt;
  bool isResolved;

  AdminReportedMessage({
    required this.id,
    required this.studentName,
    required this.studentId,
    required this.messageContent,
    required this.channelName,
    required this.reason,
    required this.reportedAt,
    this.isResolved = false,
  });
}

class AdminLostFoundItem {
  final String id;
  final String itemName;
  final String busNumber;
  final String foundLocation;
  final String dateFound;
  String status; // 'In Transport Office', 'Claimed', 'Under Review'

  AdminLostFoundItem({
    required this.id,
    required this.itemName,
    required this.busNumber,
    required this.foundLocation,
    required this.dateFound,
    this.status = 'In Transport Office',
  });
}

class AdminViewModel extends ChangeNotifier {
  int _selectedTabIndex = 0;
  int get selectedTabIndex => _selectedTabIndex;

  void setSelectedTab(int index) {
    _selectedTabIndex = index;
    notifyListeners();
  }

  // Admin Names List for Trip Activation
  static const List<String> availableAdminPersons = [
    'Person 1',
    'Person 2',
    'Person 3',
    'Person 4',
    'Person 5',
    'Person 6',
  ];

  // Official Fall 25 Stoppage Lists
  static const List<AdminBusStoppage> fall25FirstBusStoppages = [
    AdminBusStoppage(name: 'মিরপুর ১২ (বিআরটি পাম্প)', lat: 23.8272, lng: 90.3644, eta: '৬.৪৫'),
    AdminBusStoppage(name: 'মিরপুর ১১.৫ (রংধনু শপিং সেন্টার)', lat: 23.8228, lng: 90.3655, eta: '৬.৪৮'),
    AdminBusStoppage(name: 'পুরবী (বনলতা)', lat: 23.8185, lng: 90.3668, eta: '৬.৫০'),
    AdminBusStoppage(name: 'মিরপুর ১১ (ইস্টার্ন ব্যাংক)', lat: 23.8142, lng: 90.3680, eta: '৬.৫৩'),
    AdminBusStoppage(name: 'মিরপুর বাংলা স্কুল', lat: 23.8105, lng: 90.3695, eta: '৬.৫৫'),
    AdminBusStoppage(name: 'মিরপুর অরিজিনাল ১০ (পপুলারের বিপরীতে)', lat: 23.8070, lng: 90.3705, eta: '৬.৫৭'),
    AdminBusStoppage(name: 'মিরপুর ১০ (ফলপট্টির বিপরীতে)', lat: 23.8035, lng: 90.3718, eta: '৭.০৫'),
    AdminBusStoppage(name: 'সেনপাড়া (আল হেলাল হাসপাতালের সামনে)', lat: 23.7995, lng: 90.3732, eta: '৭.০৮'),
    AdminBusStoppage(name: 'কাজীপাডা (স্বপ্নের সামনে)', lat: 23.7950, lng: 90.3745, eta: '৭.১১'),
    AdminBusStoppage(name: 'মনিপুর স্কুল', lat: 23.7915, lng: 90.3758, eta: '৭.১৫'),
    AdminBusStoppage(name: 'শেওড়াপাড়া (ডি এস এস এর বিপরীতে)', lat: 23.7875, lng: 90.3770, eta: '৭.২৩'),
    AdminBusStoppage(name: 'তালতলা (ডাম্পিং স্টেশনের পাশে)', lat: 23.7820, lng: 90.3785, eta: '৭.২৫'),
    AdminBusStoppage(name: 'আগারগাঁও (আইডিবি ভবনের বিপরীত পাশে)', lat: 23.7770, lng: 90.3800, eta: '৭.২৮'),
    AdminBusStoppage(name: 'ভার্সিটি (আহছানউল্লা ক্যাম্পাস)', lat: 23.7685, lng: 90.4075, eta: '৭.৪৫'),
  ];

  static const List<AdminBusStoppage> fall25SecondBusStoppages = [
    AdminBusStoppage(name: 'মিরপুর ১২ (বিআরটি পাম্প)', lat: 23.8272, lng: 90.3644, eta: '৮.৩০'),
    AdminBusStoppage(name: 'মিরপুর ১১.৫ (রংধনু শপিং সেন্টার)', lat: 23.8228, lng: 90.3655, eta: '৮.৩৩'),
    AdminBusStoppage(name: 'পুরবী (বনলতা)', lat: 23.8185, lng: 90.3668, eta: '৮.৩৬'),
    AdminBusStoppage(name: 'মিরপুর ১১ (ইস্টার্ন ব্যাংক)', lat: 23.8142, lng: 90.3680, eta: '৮.৩৯'),
    AdminBusStoppage(name: 'মিরপুর বাংলা স্কুল', lat: 23.8105, lng: 90.3695, eta: '৮.৪২'),
    AdminBusStoppage(name: 'মিরপুর অরিজিনাল ১০ (পপুলারের বিপরীতে)', lat: 23.8070, lng: 90.3705, eta: '৮.৪৪'),
    AdminBusStoppage(name: 'মিরপুর ১০ (ফলপট্টির বিপরীতে)', lat: 23.8035, lng: 90.3718, eta: '৮.৫৮'),
    AdminBusStoppage(name: 'সেনপাড়া (আল হেলাল হাসপাতালের সামনে)', lat: 23.7995, lng: 90.3732, eta: '৯.০১'),
    AdminBusStoppage(name: 'কাজীপাডা (স্বপ্নের সামনে)', lat: 23.7950, lng: 90.3745, eta: '৯.০৪'),
    AdminBusStoppage(name: 'মনিপুর স্কুল', lat: 23.7915, lng: 90.3758, eta: '৯.০৭'),
    AdminBusStoppage(name: 'শেওড়াপাড়া (ডি এস এস এর বিপরীতে)', lat: 23.7875, lng: 90.3770, eta: '৯.১৫'),
    AdminBusStoppage(name: 'তালতলা (ডাম্পিং স্টেশনের পাশে)', lat: 23.7820, lng: 90.3785, eta: '৯.২০'),
    AdminBusStoppage(name: 'আগারগাঁও (আইডিবি ভবনের বিপরীত পাশে)', lat: 23.7770, lng: 90.3800, eta: '৯.২৪'),
    AdminBusStoppage(name: 'ভার্সিটি (আহছানউল্লা ক্যাম্পাস)', lat: 23.7685, lng: 90.4075, eta: '৯.৪৫'),
  ];

  // Dynamic Stoppage Lists for Editing
  static final List<AdminBusStoppage> _editableFirstBusStoppages = List.from(fall25FirstBusStoppages);
  static final List<AdminBusStoppage> _editableSecondBusStoppages = List.from(fall25SecondBusStoppages);
  static List<AdminBusStoppage> get currentFirstBusStoppages => _editableFirstBusStoppages;
  static List<AdminBusStoppage> get currentSecondBusStoppages => _editableSecondBusStoppages;

  String _firstBusDepartureTime = '06:45 AM';
  String _secondBusDepartureTime = '08:30 AM';
  String _returnTripTimes = 'দুপুর ৩.৪৫ & সন্ধ্যা ৬.১৫';

  String get firstBusDepartureTime => _firstBusDepartureTime;
  String get secondBusDepartureTime => _secondBusDepartureTime;
  String get returnTripTimes => _returnTripTimes;

  // Channel Lock & Moderation State
  final Set<String> _lockedChannels = {};
  Set<String> get lockedChannels => Set.unmodifiable(_lockedChannels);
  bool isChannelLocked(String channelId) => _lockedChannels.contains(channelId);

  // User Suspension State
  final Set<String> _suspendedUserIds = {};
  Set<String> get suspendedUserIds => Set.unmodifiable(_suspendedUserIds);
  bool isUserSuspended(String userId) => _suspendedUserIds.contains(userId);

  // Registered Users Directory for Messenger Autocomplete & Contact
  final List<AdminUserDirectoryItem> _registeredUsers = [
    AdminUserDirectoryItem(id: 'user_1', name: 'User 1', email: 'user1@aust.edu', studentId: '20230104001', department: 'CSE', semester: '4-1'),
    AdminUserDirectoryItem(id: 'user_2', name: 'User 2', email: 'user2@aust.edu', studentId: '20230104002', department: 'EEE', semester: '3-2'),
    AdminUserDirectoryItem(id: 'user_3', name: 'User 3', email: 'user3@aust.edu', studentId: '20230104003', department: 'CE', semester: '2-1'),
    AdminUserDirectoryItem(id: 'user_4', name: 'User 4', email: 'user4@aust.edu', studentId: '20230104004', department: 'ME', semester: '4-2'),
    AdminUserDirectoryItem(id: 'user_5', name: 'User 5', email: 'user5@aust.edu', studentId: '20230104005', department: 'TE', semester: '3-1'),
    AdminUserDirectoryItem(id: 'user_6', name: 'User 6', email: 'user6@aust.edu', studentId: '20230104006', department: 'IPE', semester: '1-2'),
    AdminUserDirectoryItem(id: 'user_11', name: 'User 11', email: 'user11@aust.edu', studentId: '20230104011', department: 'CSE', semester: '2-2'),
    AdminUserDirectoryItem(id: 'user_12', name: 'User 12', email: 'user12@aust.edu', studentId: '20230104012', department: 'Arch', semester: '5-1'),
    AdminUserDirectoryItem(id: 'user_13', name: 'User 13', email: 'user13@aust.edu', studentId: '20230104013', department: 'BBA', semester: '3-1'),
    AdminUserDirectoryItem(id: 'user_padma', name: 'Padma Student', email: 'padmaStudent@aust.edu', studentId: '2023202420252026', department: 'CSE', semester: '4-1'),
    AdminUserDirectoryItem(id: 'user_tanvir', name: 'Tanvir Ahmed', email: 'tanvir.cse@aust.edu', studentId: '20210104089', department: 'CSE', semester: '4-2'),
    AdminUserDirectoryItem(id: 'user_siam', name: 'Siam Chowdhury', email: 'siam.cse@aust.edu', studentId: '20220104055', department: 'CSE', semester: '3-1'),
  ];
  List<AdminUserDirectoryItem> get registeredUsers => List.unmodifiable(_registeredUsers);

  // User Direct Message Conversations
  final List<AdminUserConversation> _userConversations = [
    AdminUserConversation(
      userId: 'user_1',
      userName: 'User 1',
      userEmail: 'user1@aust.edu',
      studentId: '20230104001',
      lastMessage: 'Sir, what time will Padma 1 reach Mirpur 10 today?',
      lastMessageTime: DateTime.now().subtract(const Duration(minutes: 10)),
      unreadCount: 1,
      messages: [
        AdminDirectMessage(id: 'm1_1', senderId: 'user_1', senderName: 'User 1', text: 'Hello Transport Admin!', timestamp: DateTime.now().subtract(const Duration(minutes: 25)), isAdmin: false),
        AdminDirectMessage(id: 'm1_2', senderId: 'admin_1', senderName: 'Transport Admin (Person 1)', text: 'Hello User 1! How can I help you?', timestamp: DateTime.now().subtract(const Duration(minutes: 20)), isAdmin: true),
        AdminDirectMessage(id: 'm1_3', senderId: 'user_1', senderName: 'User 1', text: 'Sir, what time will Padma 1 reach Mirpur 10 today?', timestamp: DateTime.now().subtract(const Duration(minutes: 10)), isAdmin: false),
      ],
    ),
    AdminUserConversation(
      userId: 'user_2',
      userName: 'User 2',
      userEmail: 'user2@aust.edu',
      studentId: '20230104002',
      lastMessage: 'Thank you for updating the bus departure schedule.',
      lastMessageTime: DateTime.now().subtract(const Duration(minutes: 45)),
      unreadCount: 0,
      messages: [
        AdminDirectMessage(id: 'm2_1', senderId: 'user_2', senderName: 'User 2', text: 'Is the return bus at 3:45 PM on schedule?', timestamp: DateTime.now().subtract(const Duration(hours: 1)), isAdmin: false),
        AdminDirectMessage(id: 'm2_2', senderId: 'admin_1', senderName: 'Transport Admin', text: 'Yes, both return trips (3:45 PM and 6:15 PM) are running on time.', timestamp: DateTime.now().subtract(const Duration(minutes: 50)), isAdmin: true),
        AdminDirectMessage(id: 'm2_3', senderId: 'user_2', senderName: 'User 2', text: 'Thank you for updating the bus departure schedule.', timestamp: DateTime.now().subtract(const Duration(minutes: 45)), isAdmin: false),
      ],
    ),
    AdminUserConversation(
      userId: 'user_3',
      userName: 'User 3',
      userEmail: 'user3@aust.edu',
      studentId: '20230104003',
      lastMessage: 'I submitted a query about the Tejgaon gate stoppage.',
      lastMessageTime: DateTime.now().subtract(const Duration(hours: 2)),
      unreadCount: 0,
      messages: [
        AdminDirectMessage(id: 'm3_1', senderId: 'user_3', senderName: 'User 3', text: 'I submitted a query about the Tejgaon gate stoppage.', timestamp: DateTime.now().subtract(const Duration(hours: 2)), isAdmin: false),
      ],
    ),
    AdminUserConversation(
      userId: 'user_padma',
      userName: 'Padma Student',
      userEmail: 'padmaStudent@aust.edu',
      studentId: '2023202420252026',
      lastMessage: 'Verified student pass is active for Fall 25.',
      lastMessageTime: DateTime.now().subtract(const Duration(hours: 3)),
      unreadCount: 0,
      messages: [
        AdminDirectMessage(id: 'mp_1', senderId: 'user_padma', senderName: 'Padma Student', text: 'Verified student pass is active for Fall 25.', timestamp: DateTime.now().subtract(const Duration(hours: 3)), isAdmin: false),
      ],
    ),
  ];
  List<AdminUserConversation> get userConversations => List.unmodifiable(_userConversations);

  String? _activeConversationUserId;
  String? get activeConversationUserId => _activeConversationUserId;

  void selectConversationUser(String userId) {
    _activeConversationUserId = userId;
    final conv = _userConversations.where((c) => c.userId == userId).firstOrNull;
    if (conv != null) {
      conv.unreadCount = 0;
    }
    notifyListeners();
  }

  void closeActiveConversation() {
    _activeConversationUserId = null;
    notifyListeners();
  }

  // Search users for autocomplete
  List<AdminUserDirectoryItem> searchUsers(String query) {
    if (query.trim().isEmpty) return _registeredUsers;
    final q = query.trim().toLowerCase();
    return _registeredUsers.where((u) {
      return u.name.toLowerCase().contains(q) ||
          u.email.toLowerCase().contains(q) ||
          u.studentId.toLowerCase().contains(q) ||
          u.department.toLowerCase().contains(q);
    }).toList();
  }

  // Send Direct Message to User
  void sendDirectMessageToUser({
    required String targetUserId,
    required String text,
    String senderAdminName = 'Transport Admin (Person 1)',
  }) {
    if (text.trim().isEmpty) return;
    final now = DateTime.now();
    final newMsg = AdminDirectMessage(
      id: 'dm_${now.millisecondsSinceEpoch}',
      senderId: 'admin_1',
      senderName: senderAdminName,
      text: text.trim(),
      timestamp: now,
      isAdmin: true,
    );

    var convIndex = _userConversations.indexWhere((c) => c.userId == targetUserId);
    if (convIndex != -1) {
      _userConversations[convIndex].messages.add(newMsg);
      _userConversations[convIndex].lastMessage = text.trim();
      _userConversations[convIndex].lastMessageTime = now;
    } else {
      // Create new conversation
      final user = _registeredUsers.firstWhere(
        (u) => u.id == targetUserId,
        orElse: () => AdminUserDirectoryItem(id: targetUserId, name: 'User $targetUserId', email: '$targetUserId@aust.edu', studentId: targetUserId),
      );
      final newConv = AdminUserConversation(
        userId: user.id,
        userName: user.name,
        userEmail: user.email,
        studentId: user.studentId,
        lastMessage: text.trim(),
        lastMessageTime: now,
        unreadCount: 0,
        messages: [newMsg],
      );
      _userConversations.insert(0, newConv);
    }

    _activeConversationUserId = targetUserId;

    // Sync to Supabase
    try {
      SupabaseService.instance.client.from('direct_messages').insert({
        'id': newMsg.id,
        'sender_id': 'admin_1',
        'recipient_id': targetUserId,
        'sender_name': senderAdminName,
        'sender_role': 'admin',
        'text': text.trim(),
        'created_at': now.toIso8601String(),
      }).then((_) {}, onError: (e) {
        debugPrint('[AdminViewModel] Direct message Supabase sync error: $e');
      });
    } catch (e) {
      debugPrint('[AdminViewModel] Send direct message error: $e');
    }

    notifyListeners();
  }

  // Complaints state
  final List<AdminComplaintItem> _complaints = [
    AdminComplaintItem(
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
    AdminComplaintItem(
      id: 'cmp_2',
      title: 'Stoppage delay notification inquiry',
      body: 'Bus 2 left House Building 5 mins before scheduled departure time. Please ensure drivers wait until the official departure ETA.',
      studentName: 'User 2',
      studentId: '20230104002',
      department: 'EEE',
      semester: '3-2',
      email: 'user2@aust.edu',
      pickupDestination: 'House Building',
      submittedAt: DateTime.now().subtract(const Duration(hours: 8)),
      status: 'Submitted',
    ),
  ];
  List<AdminComplaintItem> get complaints => List.unmodifiable(_complaints);

  void updateComplaintStatus(String id, String newStatus) {
    final idx = _complaints.indexWhere((c) => c.id == id);
    if (idx != -1) {
      _complaints[idx].status = newStatus;
      try {
        SupabaseService.instance.client.from('feedback').update({
          'status': newStatus.toLowerCase(),
        }).eq('id', id).then((_) {}, onError: (_) {});
      } catch (e) {
        debugPrint('[AdminViewModel] updateComplaintStatus error: $e');
      }
      notifyListeners();
    }
  }

  // --- Dynamic 1st Bus Assignment (Padma 1 vs Padma 2) ---
  String _firstBusId = 'bus_1';
  String get firstBusId => _firstBusId;
  bool get isBus1First => _firstBusId == 'bus_1';
  String get firstBusName => _firstBusId == 'bus_1' ? 'Padma 1' : 'Padma 2';
  String get secondBusName => _firstBusId == 'bus_1' ? 'Padma 2' : 'Padma 1';

  // --- Fleet State: 2 Buses (Padma 1 and Padma 2) ---
  final List<AdminBusItem> _fleet = [
    AdminBusItem(
      id: 'bus_1',
      title: 'Padma 1 (1st Bus • 06:45 AM)',
      busNumber: 'Dhaka Metro-Cha 11-4589',
      driverName: 'Md. Rafiqul Islam',
      driverPhone: '+880 1711-234567',
      currentStop: 'Mirpur 12 (BRT Pump)',
      nextStop: 'Mirpur 11.5 (Rongdhonu)',
      currentStopIndex: 0,
      status: AdminBusStatus.tripEnded, // Default Trip Ended
      isBroadcastingGps: false,
      currentSpeed: 0,
      passengerCount: 0,
      etaMinutes: 0,
      latitude: 23.8272,
      longitude: 90.3644,
      stoppages: List.from(_editableFirstBusStoppages),
    ),
    AdminBusItem(
      id: 'bus_2',
      title: 'Padma 2 (2nd Bus • 08:30 AM)',
      busNumber: 'Dhaka Metro-Cha 11-8920',
      driverName: 'Al-Amin Hossain',
      driverPhone: '+880 1812-345678',
      currentStop: 'Mirpur 12 (BRT Pump)',
      nextStop: 'Mirpur 11.5 (Rongdhonu)',
      currentStopIndex: 0,
      status: AdminBusStatus.tripEnded, // Default Trip Ended
      isBroadcastingGps: false,
      currentSpeed: 0,
      passengerCount: 0,
      etaMinutes: 0,
      latitude: 23.8272,
      longitude: 90.3644,
      stoppages: List.from(_editableSecondBusStoppages),
    ),
  ];

  List<AdminBusItem> get fleet => _fleet;
  int get activeFleetCount => _fleet.where((b) => b.status != AdminBusStatus.tripEnded).length;

  void setFirstBus(String busId, {bool broadcast = true}) {
    _firstBusId = busId;
    if (_firstBusId == 'bus_1') {
      _fleet[0].title = 'Padma 1 (1st Bus • $_firstBusDepartureTime)';
      _fleet[0].stoppages.clear();
      _fleet[0].stoppages.addAll(List.from(_editableFirstBusStoppages));

      _fleet[1].title = 'Padma 2 (2nd Bus • $_secondBusDepartureTime)';
      _fleet[1].stoppages.clear();
      _fleet[1].stoppages.addAll(List.from(_editableSecondBusStoppages));
    } else {
      _fleet[0].title = 'Padma 1 (2nd Bus • $_secondBusDepartureTime)';
      _fleet[0].stoppages.clear();
      _fleet[0].stoppages.addAll(List.from(_editableSecondBusStoppages));

      _fleet[1].title = 'Padma 2 (1st Bus • $_firstBusDepartureTime)';
      _fleet[1].stoppages.clear();
      _fleet[1].stoppages.addAll(List.from(_editableFirstBusStoppages));
    }

    if (broadcast) {
      addAnnouncement(
        title: 'Daily Bus Order Confirmed',
        body: '$firstBusName is assigned as today\'s 1st Bus ($_firstBusDepartureTime departure) and $secondBusName as 2nd Bus ($_secondBusDepartureTime departure). Return trips at $_returnTripTimes.',
        priority: 'High',
        targetRoute: 'Mirpur Route',
      );
    }
    notifyListeners();
  }

  // --- Schedule Editing Methods ---
  void updateStoppageEta({required bool isFirstBus, required int index, required String newEta}) {
    final list = isFirstBus ? _editableFirstBusStoppages : _editableSecondBusStoppages;
    if (index >= 0 && index < list.length) {
      final old = list[index];
      list[index] = AdminBusStoppage(name: old.name, lat: old.lat, lng: old.lng, eta: newEta);

      // Refresh fleet references
      setFirstBus(_firstBusId, broadcast: false);

      // Sync to Supabase
      try {
        SupabaseService.instance.client.from('route_stops').update({
          'estimated_time': newEta,
        }).match({
          'route_id': isFirstBus ? 'route_mirpur' : 'route_uttara',
          'stop_order': index + 1,
        }).then((_) {}, onError: (_) {});
      } catch (e) {
        debugPrint('[AdminViewModel] Stoppage ETA DB sync error: $e');
      }

      notifyListeners();
    }
  }

  void updateDepartureTimes({required String firstBusTime, required String secondBusTime, required String returnTimes}) {
    _firstBusDepartureTime = firstBusTime;
    _secondBusDepartureTime = secondBusTime;
    _returnTripTimes = returnTimes;
    setFirstBus(_firstBusId, broadcast: false);
    notifyListeners();
  }

  AdminViewModel() {
    _initSupabaseSync();
  }

  void _initSupabaseSync() async {
    try {
      final client = SupabaseService.instance.client;
      // Fetch initial announcements
      final annRes = await client.from('admin_announcements').select().order('created_at', ascending: false);
      if (annRes.isNotEmpty) {
        _announcements.clear();
        for (final a in annRes) {
          _announcements.add(AdminAnnouncementItem(
            id: a['id'].toString(),
            title: a['title'].toString(),
            body: a['body'].toString(),
            priority: a['priority']?.toString() ?? 'Standard',
            targetRoute: a['target_route']?.toString() ?? 'All Routes',
            timestamp: a['created_at'] != null ? DateTime.parse(a['created_at'].toString()) : DateTime.now(),
            isPinned: a['is_pinned'] == true,
          ));
        }
        notifyListeners();
      }

      // Fetch feedback / complaints
      final feedbackRes = await client.from('feedback').select().order('created_at', ascending: false);
      if (feedbackRes.isNotEmpty) {
        _complaints.clear();
        for (final f in feedbackRes) {
          _complaints.add(AdminComplaintItem(
            id: f['id'].toString(),
            title: f['title']?.toString() ?? 'Student Feedback',
            body: f['body']?.toString() ?? f['message']?.toString() ?? '',
            studentName: f['student_name']?.toString() ?? 'Student',
            studentId: f['student_id']?.toString() ?? '',
            department: f['department']?.toString() ?? 'AUST',
            semester: f['semester']?.toString() ?? '',
            email: f['email']?.toString() ?? '',
            pickupDestination: f['pickup_destination']?.toString() ?? 'Mirpur',
            submittedAt: f['created_at'] != null ? DateTime.parse(f['created_at'].toString()) : DateTime.now(),
            status: (f['status']?.toString() ?? 'Submitted'),
          ));
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint('[AdminViewModel] Init Supabase sync error: $e');
    }
  }

  void _syncBusToSupabase(AdminBusItem bus) async {
    try {
      final client = SupabaseService.instance.client;
      await client.from('live_bus_locations').upsert({
        'bus_id': bus.id,
        'route_id': bus.id == 'bus_1' ? 'route_mirpur' : 'route_uttara',
        'latitude': bus.latitude,
        'longitude': bus.longitude,
        'speed_kmh': bus.currentSpeed.toDouble(),
        'heading': 0.0,
        'eta_minutes': bus.etaMinutes,
        'next_stop_name': bus.nextStop,
        'next_stop_name_bn': bus.nextStop,
        'current_stop_name': bus.currentStop,
        'current_stop_index': bus.currentStopIndex,
        'distance_progress': (bus.currentStopIndex / (bus.stoppages.length - 1)).clamp(0.0, 1.0),
        'is_broadcasting': bus.isBroadcastingGps,
        'passenger_count': bus.passengerCount,
        'status': bus.status.name,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('[AdminViewModel] _syncBusToSupabase error: $e');
    }
  }

  /// Start Trip with Admin Verification & GPS Broadcasting (Uber-like live tracking)
  void startTripWithAdminAndGps({
    required String busId,
    required String adminPersonName,
  }) {
    final index = _fleet.indexWhere((b) => b.id == busId || b.id == busId.replaceAll('-', '_'));
    if (index != -1) {
      final bus = _fleet[index];
      bus.status = AdminBusStatus.onTime;
      bus.isBroadcastingGps = true;
      bus.activatedByAdmin = adminPersonName;
      if (bus.currentSpeed == 0) bus.currentSpeed = 34;
      if (bus.passengerCount == 0) bus.passengerCount = 42;
      if (bus.etaMinutes == 0) bus.etaMinutes = 15;

      _syncBusToSupabase(bus);

      // Broadcast start trip notice
      final busChannel = (bus.id == 'bus_1' || bus.id == 'bus-1') ? 'bus-1-mirpur' : 'bus-2-uttara';
      try {
        SupabaseService.instance.client.from('messages').insert({
          'id': 'msg_start_${bus.id}_${DateTime.now().millisecondsSinceEpoch}',
          'channel_id': busChannel,
          'sender_id': 'admin_1',
          'sender_name': 'Padma Dispatch ($adminPersonName)',
          'sender_role': 'admin',
          'badge_text': 'TRIP STARTED',
          'text': '🟢 **Trip Started**: Live GPS broadcasting activated by $adminPersonName. You can now track ${bus.title} in real-time!',
          'is_telemetry': true,
          'created_at': DateTime.now().toIso8601String(),
        }).then((_) {}, onError: (_) {});
      } catch (e) {
        debugPrint('[AdminViewModel] Broadcast start message error: $e');
      }

      notifyListeners();
    }
  }

  /// End Trip & disable GPS Broadcasting
  void endTrip(String busId) {
    final index = _fleet.indexWhere((b) => b.id == busId || b.id == busId.replaceAll('-', '_'));
    if (index != -1) {
      final bus = _fleet[index];
      bus.status = AdminBusStatus.tripEnded;
      bus.isBroadcastingGps = false;
      bus.currentSpeed = 0;
      bus.etaMinutes = 0;

      _syncBusToSupabase(bus);
      notifyListeners();
    }
  }

  void toggleBusGps(String busId) {
    final index = _fleet.indexWhere((b) => b.id == busId || b.id == busId.replaceAll('-', '_'));
    if (index != -1) {
      _fleet[index].isBroadcastingGps = !_fleet[index].isBroadcastingGps;
      _syncBusToSupabase(_fleet[index]);
      notifyListeners();
    }
  }

  void updateBusStatus(String busId, AdminBusStatus status) {
    final index = _fleet.indexWhere((b) => b.id == busId || b.id == busId.replaceAll('-', '_'));
    if (index != -1) {
      final bus = _fleet[index];
      bus.status = status;
      if (status == AdminBusStatus.onTime || status == AdminBusStatus.delayed || status == AdminBusStatus.waiting) {
        bus.isBroadcastingGps = true;
        if (bus.currentSpeed == 0) bus.currentSpeed = (status == AdminBusStatus.onTime) ? 38 : 22;
        if (bus.passengerCount == 0) bus.passengerCount = 48;
        if (bus.etaMinutes == 0) bus.etaMinutes = 14;
      } else if (status == AdminBusStatus.tripEnded) {
        bus.isBroadcastingGps = false;
        bus.currentSpeed = 0;
        bus.etaMinutes = 0;
      }
      _syncBusToSupabase(bus);
      notifyListeners();
    }
  }

  void updateBusSpeed(String busId, int speed) {
    final index = _fleet.indexWhere((b) => b.id == busId || b.id == busId.replaceAll('-', '_'));
    if (index != -1) {
      _fleet[index].currentSpeed = speed;
      _syncBusToSupabase(_fleet[index]);
      notifyListeners();
    }
  }

  void updateBusStoppage(
    String busId,
    String stoppageName, {
    void Function(String channelId, String message)? onBroadcastMessage,
  }) {
    final index = _fleet.indexWhere((b) => b.id == busId || b.id == busId.replaceAll('-', '_'));
    if (index != -1) {
      final bus = _fleet[index];
      final stopIdx = bus.stoppages.indexWhere((s) => s.name == stoppageName);
      if (stopIdx != -1) {
        bus.currentStopIndex = stopIdx;
        bus.currentStop = stoppageName;
        bus.latitude = bus.stoppages[stopIdx].lat;
        bus.longitude = bus.stoppages[stopIdx].lng;

        if (stopIdx + 1 < bus.stoppages.length) {
          bus.nextStop = bus.stoppages[stopIdx + 1].name;
          bus.etaMinutes = ((bus.stoppages.length - 1 - stopIdx) * 4).clamp(2, 45);
        } else {
          bus.nextStop = 'AUST Campus (Destination Reached)';
          bus.etaMinutes = 0;
        }

        if (bus.status == AdminBusStatus.tripEnded) {
          bus.status = AdminBusStatus.onTime;
          bus.isBroadcastingGps = true;
          bus.currentSpeed = 34;
        }

        final channelId = (bus.id == 'bus_1' || bus.id == 'bus-1') ? 'bus-1-mirpur' : 'bus-2-uttara';
        final broadcastText = '📍 Bus reached **$stoppageName**. Heading towards next stoppage: **${bus.nextStop}**.';
        onBroadcastMessage?.call(channelId, broadcastText);

        _syncBusToSupabase(bus);
        notifyListeners();
      }
    }
  }

  void advanceToNextStoppage(
    String busId, {
    void Function(String channelId, String message)? onBroadcastMessage,
  }) {
    final index = _fleet.indexWhere((b) => b.id == busId || b.id == busId.replaceAll('-', '_'));
    if (index != -1) {
      final bus = _fleet[index];
      if (bus.currentStopIndex + 1 < bus.stoppages.length) {
        final nextStopName = bus.stoppages[bus.currentStopIndex + 1].name;
        updateBusStoppage(busId, nextStopName, onBroadcastMessage: onBroadcastMessage);
      }
    }
  }

  void setStoppageWaitNotice({
    required String busId,
    required String stoppageName,
    required String untilTime,
    required String message,
    bool broadcastToGeneral = true,
    bool broadcastToBusChannel = true,
    void Function(String channelId, String msg)? onBroadcastMessage,
  }) {
    final index = _fleet.indexWhere((b) => b.id == busId || b.id == busId.replaceAll('-', '_'));
    if (index != -1) {
      final bus = _fleet[index];
      bus.activeWaitNotice = AdminStoppageWaitNotice(
        busId: bus.id,
        stoppageName: stoppageName,
        untilTime: untilTime,
        message: message,
        timestamp: DateTime.now(),
      );

      if (bus.status == AdminBusStatus.tripEnded) {
        bus.status = AdminBusStatus.waiting;
        bus.isBroadcastingGps = true;
      }

      if (broadcastToGeneral) {
        onBroadcastMessage?.call('general', '⏱️ **STATION WAIT NOTICE**: $message');
      }

      if (broadcastToBusChannel) {
        final busChannel = (bus.id == 'bus_1' || bus.id == 'bus-1') ? 'bus-1-mirpur' : 'bus-2-uttara';
        onBroadcastMessage?.call(busChannel, '⏱️ **WAIT NOTICE**: $message');
      }

      try {
        SupabaseService.instance.client.from('admin_stoppage_wait_notices').insert({
          'id': 'wait_${DateTime.now().millisecondsSinceEpoch}',
          'bus_id': bus.id,
          'stoppage_name': stoppageName,
          'until_time': untilTime,
          'message': message,
          'created_at': DateTime.now().toIso8601String(),
        });
      } catch (e) {
        debugPrint('[AdminViewModel] setStoppageWaitNotice DB error: $e');
      }

      _syncBusToSupabase(bus);
      notifyListeners();
    }
  }

  void clearStoppageWaitNotice(String busId) {
    final index = _fleet.indexWhere((b) => b.id == busId || b.id == busId.replaceAll('-', '_'));
    if (index != -1) {
      _fleet[index].activeWaitNotice = null;
      notifyListeners();
    }
  }

  // --- Announcements State ---
  final List<AdminAnnouncementItem> _announcements = [
    AdminAnnouncementItem(
      id: 'ann_1',
      title: 'Campus Departure Delay (15 Mins)',
      body: 'Due to severe traffic near Tejgaon Nabisco junction, afternoon trips for all routes will depart at 1:45 PM instead of 1:30 PM.',
      priority: 'High',
      targetRoute: 'All Routes',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      isPinned: true,
    ),
    AdminAnnouncementItem(
      id: 'ann_2',
      title: 'Mirpur Route Weather Advisory',
      body: 'Heavy rainfall reported at Rokeya Sarani. Bus 1 will follow the elevated metro corridor route.',
      priority: 'Standard',
      targetRoute: 'Mirpur Route',
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      isPinned: false,
    ),
  ];

  List<AdminAnnouncementItem> get announcements => _announcements;

  void addAnnouncement({
    required String title,
    required String body,
    required String priority,
    required String targetRoute,
    bool isPinned = false,
  }) {
    final newId = 'ann_${DateTime.now().millisecondsSinceEpoch}';
    _announcements.insert(
      0,
      AdminAnnouncementItem(
        id: newId,
        title: title,
        body: body,
        priority: priority,
        targetRoute: targetRoute,
        timestamp: DateTime.now(),
        isPinned: isPinned,
      ),
    );

    // Save to Supabase
    try {
      final client = SupabaseService.instance.client;
      client.from('admin_announcements').insert({
        'id': newId,
        'title': title,
        'body': body,
        'priority': priority,
        'target_route': targetRoute,
        'is_pinned': isPinned,
        'created_at': DateTime.now().toIso8601String(),
      }).then((_) {}, onError: (_) {});

      // Broadcast to messages table
      client.from('messages').insert({
        'id': 'msg_$newId',
        'channel_id': 'announcements',
        'sender_id': 'admin_1',
        'sender_name': 'Padma Transport Office',
        'sender_role': 'admin',
        'badge_text': '$priority NOTICE',
        'text': '📢 **$title**: $body',
        'is_urgent': priority.toLowerCase() == 'urgent',
        'is_pinned': isPinned,
        'reactions': {'👍': 1},
        'created_at': DateTime.now().toIso8601String(),
      }).then((_) {}, onError: (_) {});
    } catch (e) {
      debugPrint('[AdminViewModel] Error inserting announcement: $e');
    }

    notifyListeners();
  }

  void deleteAnnouncement(String id) {
    _announcements.removeWhere((a) => a.id == id);
    try {
      SupabaseService.instance.client.from('admin_announcements').delete().eq('id', id).then((_) {}, onError: (_) {});
    } catch (e) {
      debugPrint('[AdminViewModel] deleteAnnouncement error: $e');
    }
    notifyListeners();
  }

  // --- Moderation Methods ---
  void toggleChannelLock(String channelId) {
    if (_lockedChannels.contains(channelId)) {
      _lockedChannels.remove(channelId);
    } else {
      _lockedChannels.add(channelId);
    }

    try {
      SupabaseService.instance.client.from('channels').update({
        'is_active': !_lockedChannels.contains(channelId),
      }).eq('id', channelId).then((_) {}, onError: (_) {});
    } catch (e) {
      debugPrint('[AdminViewModel] toggleChannelLock error: $e');
    }

    notifyListeners();
  }

  bool _isGeneralLocked = false;
  bool get isGeneralLocked => _isGeneralLocked || _lockedChannels.contains('general') || _lockedChannels.contains('rules-and-regulation');

  bool _isSlowModeEnabled = false;
  bool get isSlowModeEnabled => _isSlowModeEnabled;

  void toggleGeneralLock() {
    _isGeneralLocked = !_isGeneralLocked;
    toggleChannelLock('general');
  }

  void toggleSlowMode() {
    _isSlowModeEnabled = !_isSlowModeEnabled;
    notifyListeners();
  }

  void toggleUserSuspension(String userId) {
    if (_suspendedUserIds.contains(userId)) {
      _suspendedUserIds.remove(userId);
    } else {
      _suspendedUserIds.add(userId);
    }

    try {
      SupabaseService.instance.client.from('profiles').update({
        'is_verified': !_suspendedUserIds.contains(userId),
      }).eq('id', userId).then((_) {}, onError: (_) {});
    } catch (e) {
      debugPrint('[AdminViewModel] toggleUserSuspension error: $e');
    }

    notifyListeners();
  }

  void suspendUser(String userId) {
    _suspendedUserIds.add(userId);
    try {
      SupabaseService.instance.client.from('profiles').update({
        'is_verified': false,
      }).eq('id', userId).then((_) {}, onError: (_) {});
    } catch (e) {
      debugPrint('[AdminViewModel] suspendUser error: $e');
    }
    notifyListeners();
  }

  void unblockUser(String userId) {
    _suspendedUserIds.remove(userId);
    try {
      SupabaseService.instance.client.from('profiles').update({
        'is_verified': true,
      }).eq('id', userId).then((_) {}, onError: (_) {});
    } catch (e) {
      debugPrint('[AdminViewModel] unblockUser error: $e');
    }
    notifyListeners();
  }

  // Delete any message from any channel (Only Admin)
  void deleteAnyMessage(String channelId, String messageId) {
    try {
      SupabaseService.instance.client.from('messages').delete().eq('id', messageId).then((_) {}, onError: (_) {});
    } catch (e) {
      debugPrint('[AdminViewModel] deleteAnyMessage Supabase error: $e');
    }
    notifyListeners();
  }

  final List<AdminReportedMessage> _reportedMessages = [
    AdminReportedMessage(
      id: 'rep_1',
      studentName: 'Tanzim Ahmed',
      studentId: '20210104089',
      messageContent: 'Selling football tickets here DM me fast!',
      channelName: '#padma-1',
      reason: 'Spam / Commercial Ads',
      reportedAt: DateTime.now().subtract(const Duration(minutes: 45)),
    ),
    AdminReportedMessage(
      id: 'rep_2',
      studentName: 'Unknown Commuter',
      studentId: '20220205012',
      messageContent: 'Bus 2 driver is not stopping at designated stop!',
      channelName: '#padma-2',
      reason: 'Misinformation / Harassment',
      reportedAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
  ];

  List<AdminReportedMessage> get reportedMessages => _reportedMessages;

  void resolveReport(String id, {bool deleteMessage = false}) {
    final index = _reportedMessages.indexWhere((r) => r.id == id);
    if (index != -1) {
      _reportedMessages[index].isResolved = true;
      if (deleteMessage) {
        _reportedMessages.removeAt(index);
      }
      try {
        SupabaseService.instance.client.from('reported_messages').update({
          'is_resolved': true,
        }).eq('id', id).then((_) {}, onError: (_) {});
      } catch (e) {
        debugPrint('[AdminViewModel] resolveReport error: $e');
      }
      notifyListeners();
    }
  }

  // --- Lost & Found State ---
  final List<AdminLostFoundItem> _lostFoundItems = [
    AdminLostFoundItem(
      id: 'lf_1',
      itemName: 'Casio fx-991EX Scientific Calculator',
      busNumber: 'Bus 1 (Mirpur Route)',
      foundLocation: 'Seat Row 4 Window',
      dateFound: 'Today, 10:15 AM',
      status: 'In Transport Office',
    ),
    AdminLostFoundItem(
      id: 'lf_2',
      itemName: 'AUST Student ID Card (CSE Dept)',
      busNumber: 'Padma 2 (Uttara Route)',
      foundLocation: 'Conductor Front Desk',
      dateFound: 'Yesterday, 4:45 PM',
      status: 'Claimed',
    ),
  ];

  List<AdminLostFoundItem> get lostFoundItems => _lostFoundItems;

  void updateLostFoundStatus(String id, String status) {
    final index = _lostFoundItems.indexWhere((item) => item.id == id);
    if (index != -1) {
      _lostFoundItems[index].status = status;
      try {
        SupabaseService.instance.client.from('lost_found_items').update({
          'status': status == 'Claimed' ? 'resolved' : 'active',
        }).eq('id', id).then((_) {}, onError: (_) {});
      } catch (e) {
        debugPrint('[AdminViewModel] updateLostFoundStatus error: $e');
      }
      notifyListeners();
    }
  }
}

class AdminUserDirectoryItem {
  final String id;
  final String name;
  final String email;
  final String studentId;
  final String department;
  final String semester;

  const AdminUserDirectoryItem({
    required this.id,
    required this.name,
    required this.email,
    required this.studentId,
    this.department = 'CSE',
    this.semester = '4-1',
  });
}

class AdminDirectMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String text;
  final DateTime timestamp;
  final bool isAdmin;

  const AdminDirectMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.timestamp,
    required this.isAdmin,
  });
}

class AdminUserConversation {
  final String userId;
  final String userName;
  final String userEmail;
  final String studentId;
  String lastMessage;
  DateTime lastMessageTime;
  int unreadCount;
  final List<AdminDirectMessage> messages;

  AdminUserConversation({
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.studentId,
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = 0,
    required this.messages,
  });
}

class AdminComplaintItem {
  final String id;
  final String title;
  final String body;
  final String studentName;
  final String studentId;
  final String department;
  final String semester;
  final String email;
  final String pickupDestination;
  final DateTime submittedAt;
  String status;

  AdminComplaintItem({
    required this.id,
    required this.title,
    required this.body,
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
