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

  // --- Official Fall 25 Route Stoppages ---
  static const List<AdminBusStoppage> fall25FirstBusStoppages = [
    AdminBusStoppage(name: 'Mirpur 12 (BRT Pump)', lat: 23.8272, lng: 90.3644, eta: '06:45 AM'),
    AdminBusStoppage(name: 'Mirpur 11.5 (Rongdhonu)', lat: 23.8210, lng: 90.3660, eta: '06:48 AM'),
    AdminBusStoppage(name: 'Purobi (Bonolota)', lat: 23.8160, lng: 90.3665, eta: '06:50 AM'),
    AdminBusStoppage(name: 'Mirpur 11 (Eastern Bank)', lat: 23.8120, lng: 90.3670, eta: '06:53 AM'),
    AdminBusStoppage(name: 'Mirpur Bangla School', lat: 23.8090, lng: 90.3678, eta: '06:55 AM'),
    AdminBusStoppage(name: 'Mirpur Original 10 (Opp. Popular)', lat: 23.8078, lng: 90.3682, eta: '06:57 AM'),
    AdminBusStoppage(name: 'Mirpur 10 (Opp. Folpotti)', lat: 23.8068, lng: 90.3687, eta: '07:05 AM'),
    AdminBusStoppage(name: 'Senpara (Al Helal Hospital)', lat: 23.8015, lng: 90.3710, eta: '07:08 AM'),
    AdminBusStoppage(name: 'Kazipara (Shwapno)', lat: 23.7963, lng: 90.3728, eta: '07:11 AM'),
    AdminBusStoppage(name: 'Monipur School', lat: 23.7920, lng: 90.3745, eta: '07:15 AM'),
    AdminBusStoppage(name: 'Shewrapara (Opp. DSS)', lat: 23.7876, lng: 90.3755, eta: '07:23 AM'),
    AdminBusStoppage(name: 'Taltola (Dumping Station)', lat: 23.7812, lng: 90.3775, eta: '07:25 AM'),
    AdminBusStoppage(name: 'Agargaon (Opp. IDB Bhaban)', lat: 23.7775, lng: 90.3805, eta: '07:28 AM'),
    AdminBusStoppage(name: 'Varsity (AUST Campus)', lat: 23.7695, lng: 90.4074, eta: '07:45 AM'),
  ];

  static const List<AdminBusStoppage> fall25SecondBusStoppages = [
    AdminBusStoppage(name: 'Mirpur 12 (BRT Pump)', lat: 23.8272, lng: 90.3644, eta: '08:30 AM'),
    AdminBusStoppage(name: 'Mirpur 11.5 (Rongdhonu)', lat: 23.8210, lng: 90.3660, eta: '08:33 AM'),
    AdminBusStoppage(name: 'Purobi (Bonolota)', lat: 23.8160, lng: 90.3665, eta: '08:36 AM'),
    AdminBusStoppage(name: 'Mirpur 11 (Eastern Bank)', lat: 23.8120, lng: 90.3670, eta: '08:39 AM'),
    AdminBusStoppage(name: 'Mirpur Bangla School', lat: 23.8090, lng: 90.3678, eta: '08:42 AM'),
    AdminBusStoppage(name: 'Mirpur Original 10 (Opp. Popular)', lat: 23.8078, lng: 90.3682, eta: '08:44 AM'),
    AdminBusStoppage(name: 'Mirpur 10 (Opp. Folpotti)', lat: 23.8068, lng: 90.3687, eta: '08:58 AM'),
    AdminBusStoppage(name: 'Senpara (Al Helal Hospital)', lat: 23.8015, lng: 90.3710, eta: '09:01 AM'),
    AdminBusStoppage(name: 'Kazipara (Shwapno)', lat: 23.7963, lng: 90.3728, eta: '09:04 AM'),
    AdminBusStoppage(name: 'Monipur School', lat: 23.7920, lng: 90.3745, eta: '09:07 AM'),
    AdminBusStoppage(name: 'Shewrapara (Opp. DSS)', lat: 23.7876, lng: 90.3755, eta: '09:15 AM'),
    AdminBusStoppage(name: 'Taltola (Dumping Station)', lat: 23.7812, lng: 90.3775, eta: '09:20 AM'),
    AdminBusStoppage(name: 'Agargaon (Opp. IDB Bhaban)', lat: 23.7775, lng: 90.3805, eta: '09:24 AM'),
    AdminBusStoppage(name: 'Varsity (AUST Campus)', lat: 23.7695, lng: 90.4074, eta: '09:45 AM'),
  ];

  // Dynamic 1st Bus Assignment (Padma 1 vs Padma 2)
  String _firstBusId = 'bus_1';
  String get firstBusId => _firstBusId;
  bool get isBus1First => _firstBusId == 'bus_1';
  String get firstBusName => _firstBusId == 'bus_1' ? 'Padma 1' : 'Padma 2';
  String get secondBusName => _firstBusId == 'bus_1' ? 'Padma 2' : 'Padma 1';

  // --- Fleet State: 2 Buses only (Padma 1 and Padma 2) ---
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
      stoppages: fall25FirstBusStoppages,
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
      stoppages: fall25SecondBusStoppages,
    ),
  ];

  List<AdminBusItem> get fleet => _fleet;

  int get activeFleetCount => _fleet.where((b) => b.status != AdminBusStatus.tripEnded).length;

  void setFirstBus(String busId, {bool broadcast = true}) {
    _firstBusId = busId;
    if (_firstBusId == 'bus_1') {
      _fleet[0].title = 'Padma 1 (1st Bus • 06:45 AM)';
      _fleet[0].stoppages.clear();
      _fleet[0].stoppages.addAll(fall25FirstBusStoppages);

      _fleet[1].title = 'Padma 2 (2nd Bus • 08:30 AM)';
      _fleet[1].stoppages.clear();
      _fleet[1].stoppages.addAll(fall25SecondBusStoppages);
    } else {
      _fleet[0].title = 'Padma 1 (2nd Bus • 08:30 AM)';
      _fleet[0].stoppages.clear();
      _fleet[0].stoppages.addAll(fall25SecondBusStoppages);

      _fleet[1].title = 'Padma 2 (1st Bus • 06:45 AM)';
      _fleet[1].stoppages.clear();
      _fleet[1].stoppages.addAll(fall25FirstBusStoppages);
    }

    if (broadcast) {
      addAnnouncement(
        title: 'Daily Bus Order Confirmed',
        body: '$firstBusName is assigned as today\'s 1st Bus (06:45 AM departure) and $secondBusName as 2nd Bus (08:30 AM departure). Return trips at 3:45 PM & 6:15 PM.',
        priority: 'High',
        targetRoute: 'Mirpur Route',
      );
    }
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

  // --- Community & Moderation State ---
  bool _isGeneralLocked = false;
  bool get isGeneralLocked => _isGeneralLocked;

  bool _isSlowModeEnabled = false;
  bool get isSlowModeEnabled => _isSlowModeEnabled;

  void toggleGeneralLock() {
    _isGeneralLocked = !_isGeneralLocked;
    notifyListeners();
  }

  void toggleSlowMode() {
    _isSlowModeEnabled = !_isSlowModeEnabled;
    notifyListeners();
  }

  final List<AdminReportedMessage> _reportedMessages = [
    AdminReportedMessage(
      id: 'rep_1',
      studentName: 'Tanzim Ahmed',
      studentId: '20210104089',
      messageContent: 'Selling football tickets here DM me fast!',
      channelName: '#general',
      reason: 'Spam / Commercial Ads',
      reportedAt: DateTime.now().subtract(const Duration(minutes: 45)),
    ),
    AdminReportedMessage(
      id: 'rep_2',
      studentName: 'Unknown Commuter',
      studentId: '20220205012',
      messageContent: 'Bus 2 driver is not stopping at designated stop!',
      channelName: '#bus-2-uttara',
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

  // --- AI Copilot Insights ---
  final List<String> _aiInsights = [
    '⚠️ Anomaly Detected: Mohakhali Flyover slow-down (+12 min delay probability on Bus 1 Mirpur).',
    '💡 Fleet Recommendation: 340 students currently tracking Agargaon Metro; recommend queuing backup bus.',
    '🌧️ Weather Alert: Pre-monsoon shower predicted at 4:00 PM; advise early engine pre-checks.',
  ];

  List<String> get aiInsights => _aiInsights;

  void dismissInsight(int index) {
    if (index >= 0 && index < _aiInsights.length) {
      _aiInsights.removeAt(index);
      notifyListeners();
    }
  }
}
