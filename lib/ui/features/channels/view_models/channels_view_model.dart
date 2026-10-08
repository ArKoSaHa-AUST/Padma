import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../../data/models/chat_message.dart';
import '../../../../data/models/emergency_request.dart';
import '../../../../data/services/mock_data_service.dart';
import '../../../../data/services/supabase_service.dart';

class ChannelsViewModel extends ChangeNotifier {
  final List<ChatMessage> _generalMessages = MockDataService.getGeneralChatMessages();
  final List<ChatMessage> _bus1Messages = MockDataService.getBus1TelemetryMessages();
  final List<ChatMessage> _bus2Messages = MockDataService.getBus2TelemetryMessages();
  final List<ChatMessage> _announcementsMessages = [
    ChatMessage(
      id: 'ann_chat_1',
      senderName: 'Padma Transport Office',
      senderRole: 'Transport Admin',
      avatarInitials: 'ADM',
      badgeText: 'OFFICIAL NOTICE',
      text: '📢 **Campus Departure Advisory**: Afternoon trips for all routes will depart strictly from Main Gate at 01:45 PM.',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      isTelemetry: true,
      reactions: [
        ChatReaction(emoji: '👍', count: 32, isUserReacted: true),
        ChatReaction(emoji: '🚌', count: 18),
      ],
    ),
    ChatMessage(
      id: 'ann_chat_2',
      senderName: 'Padma Dispatch Control',
      senderRole: 'Transport Admin',
      avatarInitials: 'ADM',
      badgeText: 'WEATHER ALERT',
      text: '🌧️ **Weather Alert**: Pre-monsoon showers expected along Mirpur Corridor. Drivers advised to maintain 35km/h safety limit.',
      timestamp: DateTime.now().subtract(const Duration(hours: 4)),
      isTelemetry: true,
      reactions: [
        ChatReaction(emoji: '☔', count: 14),
      ],
    ),
  ];
  final List<ChatMessage> _emergencyBloodMessages = [
    ChatMessage(
      id: 'bld_1',
      senderName: 'Siam Chowdhury (CSE 3.1)',
      senderRole: 'Verified Student',
      avatarInitials: 'SC',
      badgeText: 'URGENT O+',
      text: '🔴 **URGENT**: Need 2 Bags of O+ Blood for emergency surgery at Dhaka Medical College Hospital. Contact: 01711-889900.',
      timestamp: DateTime.now().subtract(const Duration(minutes: 35)),
      reactions: [
        ChatReaction(emoji: '🩸', count: 19, isUserReacted: true),
        ChatReaction(emoji: '🙏', count: 8),
      ],
    ),
  ];
  final List<ChatMessage> _rideShareMessages = [
    ChatMessage(
      id: 'rs_1',
      senderName: 'Nabil Hasan (EEE 4.2)',
      senderRole: 'Student Rider',
      avatarInitials: 'NH',
      badgeText: 'CARPOOL',
      text: '🚗 Leaving Mirpur DOHS towards AUST Campus at 7:30 AM tomorrow. 2 seats available in private sedan. DM to join.',
      timestamp: DateTime.now().subtract(const Duration(minutes: 50)),
      reactions: [
        ChatReaction(emoji: '🚗', count: 6),
      ],
    ),
  ];
  final List<EmergencyRequest> _requests = MockDataService.getEmergencyRequests();
  String _selectedRequestFilter = 'all';

  StreamSubscription<List<Map<String, dynamic>>>? _messagesSub;
  StreamSubscription<List<Map<String, dynamic>>>? _requestsSub;

  List<ChatMessage> get generalMessages => _generalMessages;
  List<ChatMessage> get bus1Messages => _bus1Messages;
  List<ChatMessage> get bus2Messages => _bus2Messages;
  List<ChatMessage> get announcementsMessages => _announcementsMessages;
  List<ChatMessage> get emergencyBloodMessages => _emergencyBloodMessages;
  List<ChatMessage> get rideShareMessages => _rideShareMessages;

  ChannelsViewModel() {
    _initSupabaseRealtimeStreams();
  }

  void _initSupabaseRealtimeStreams() {
    try {
      final client = SupabaseService.instance.client;

      // 1. Messages Realtime Stream
      _messagesSub = client
          .from('messages')
          .stream(primaryKey: ['id'])
          .order('created_at', ascending: true)
          .listen((records) {
        for (final r in records) {
          final chId = r['channel_id']?.toString() ?? 'general';
          final targetList = getMessagesForChannel(chId);

          final msgId = r['id']?.toString() ?? '';
          final reactionsRaw = r['reactions'];
          final List<ChatReaction> reactions = [];
          if (reactionsRaw is Map) {
            reactionsRaw.forEach((k, v) {
              reactions.add(ChatReaction(emoji: k.toString(), count: (v as num).toInt()));
            });
          }

          final chatMsg = ChatMessage(
            id: msgId,
            senderName: r['sender_name']?.toString() ?? 'AUST Student',
            senderRole: r['sender_role']?.toString() == 'admin' ? 'Transport Admin' : 'Verified Student',
            avatarInitials: (r['sender_name']?.toString().isNotEmpty ?? false)
                ? r['sender_name'].toString().substring(0, 2).toUpperCase()
                : 'AU',
            badgeText: r['badge_text']?.toString(),
            text: r['text']?.toString() ?? '',
            timestamp: r['created_at'] != null ? DateTime.parse(r['created_at'].toString()) : DateTime.now(),
            isTelemetry: r['is_telemetry'] == true,
            reactions: reactions,
          );

          final existingIdx = targetList.indexWhere((m) => m.id == msgId);
          if (existingIdx != -1) {
            targetList[existingIdx] = chatMsg;
          } else {
            targetList.add(chatMsg);
          }
        }
        notifyListeners();
      }, onError: (err) {
        debugPrint('[ChannelsViewModel] Messages sub error: $err');
      });

      // 2. Emergency Requests Realtime Stream
      _requestsSub = client
          .from('emergency_requests')
          .stream(primaryKey: ['id'])
          .order('created_at', ascending: false)
          .listen((records) {
        for (final r in records) {
          final reqId = r['id']?.toString() ?? '';
          final typeStr = r['type']?.toString() ?? 'blood';
          RequestCategory cat = RequestCategory.blood;
          if (typeStr == 'ride') cat = RequestCategory.ride;
          if (typeStr == 'notes') cat = RequestCategory.notes;
          if (typeStr == 'other') cat = RequestCategory.other;

          final urgencyStr = r['urgency']?.toString() ?? 'medium';
          RequestUrgency urg = RequestUrgency.medium;
          if (urgencyStr == 'critical') urg = RequestUrgency.critical;
          if (urgencyStr == 'low') urg = RequestUrgency.low;

          final req = EmergencyRequest(
            id: reqId,
            title: r['title']?.toString() ?? '',
            description: r['description']?.toString() ?? '',
            patientLocation: r['location']?.toString() ?? 'Campus',
            bloodGroup: r['blood_group']?.toString() ?? 'A+',
            category: cat,
            urgency: urg,
            contactNumber: r['contact']?.toString() ?? '',
            postedBy: r['requester_name']?.toString() ?? 'Student',
            postedAt: r['created_at'] != null ? DateTime.parse(r['created_at'].toString()) : DateTime.now(),
          );

          final existingIdx = _requests.indexWhere((x) => x.id == reqId);
          if (existingIdx != -1) {
            _requests[existingIdx] = req;
          } else {
            _requests.insert(0, req);
          }
        }
        notifyListeners();
      }, onError: (err) {
        debugPrint('[ChannelsViewModel] Requests sub error: $err');
      });

    } catch (e) {
      debugPrint('[ChannelsViewModel] Init realtime error: $e');
    }
  }

  List<ChatMessage> getMessagesForChannel(String channelId) {
    switch (channelId.toLowerCase()) {
      case 'bus-1-mirpur':
      case 'bus_1':
      case 'bus-1':
        return _bus1Messages;
      case 'bus-2-uttara':
      case 'bus_2':
      case 'bus-2':
        return _bus2Messages;
      case 'announcements':
      case '#announcements':
        return _announcementsMessages;
      case 'emergency-blood':
      case 'blood':
      case '#emergency-blood':
        return _emergencyBloodMessages;
      case 'ride-share':
      case 'rideshare':
      case '#ride-share':
        return _rideShareMessages;
      case 'general':
      case '#general':
      default:
        return _generalMessages;
    }
  }

  List<EmergencyRequest> get requests {
    if (_selectedRequestFilter == 'blood') {
      return _requests.where((r) => r.category == RequestCategory.blood).toList();
    }
    if (_selectedRequestFilter == 'urgent') {
      return _requests.where((r) => r.urgency == RequestUrgency.critical).toList();
    }
    return _requests;
  }
  String get selectedRequestFilter => _selectedRequestFilter;

  void setRequestFilter(String filter) {
    _selectedRequestFilter = filter;
    notifyListeners();
  }

  void sendMessageToChannel(
    String channelId,
    String text, {
    String senderName = 'You (Student)',
    String senderRole = 'Verified Student',
    String avatarInitials = 'YOU',
    String? badgeText,
    bool isTelemetry = false,
  }) {
    if (text.trim().isEmpty) return;
    final msgId = 'msg_${DateTime.now().millisecondsSinceEpoch}';
    final list = getMessagesForChannel(channelId);
    list.add(
      ChatMessage(
        id: msgId,
        senderName: senderName,
        senderRole: senderRole,
        avatarInitials: avatarInitials,
        badgeText: badgeText,
        text: text.trim(),
        timestamp: DateTime.now(),
        isTelemetry: isTelemetry,
      ),
    );
    notifyListeners();

    // Persist to Supabase
    try {
      final role = senderRole.toLowerCase().contains('admin') ? 'admin' : 'student';
      SupabaseService.instance.client.from('messages').insert({
        'id': msgId,
        'channel_id': channelId,
        'sender_id': 'user_student_active',
        'sender_name': senderName,
        'sender_role': role,
        'badge_text': badgeText,
        'text': text.trim(),
        'is_telemetry': isTelemetry,
        'reactions': {},
        'created_at': DateTime.now().toIso8601String(),
      }).then((_) {}, onError: (e) {
        debugPrint('[ChannelsViewModel] Error sending to Supabase: $e');
      });
    } catch (e) {
      debugPrint('[ChannelsViewModel] Insert exception: $e');
    }
  }

  void sendGeneralMessage(String text, {String senderName = 'You (Student)'}) {
    sendMessageToChannel('general', text, senderName: senderName);
  }

  void sendBus1Message(String text, {String senderName = 'You (Mirpur Commuter)'}) {
    sendMessageToChannel(
      'bus-1-mirpur',
      text,
      senderName: senderName,
      senderRole: 'Student Commuter',
      avatarInitials: 'ME',
    );
  }

  void sendBus2Message(String text, {String senderName = 'You (Uttara Commuter)'}) {
    sendMessageToChannel(
      'bus-2-uttara',
      text,
      senderName: senderName,
      senderRole: 'Student Commuter',
      avatarInitials: 'ME',
    );
  }

  void broadcastDispatchMessage(
    String channelId,
    String text, {
    String senderName = 'Padma Dispatch Control (Admin)',
    String senderRole = 'Transport Admin',
    String badgeText = 'OFFICIAL ALERT',
  }) {
    sendMessageToChannel(
      channelId,
      text,
      senderName: senderName,
      senderRole: senderRole,
      badgeText: badgeText,
      isTelemetry: true,
    );
  }

  void deleteMessage(String channelId, String messageId) {
    final list = getMessagesForChannel(channelId);
    list.removeWhere((m) => m.id == messageId);
    try {
      SupabaseService.instance.client.from('messages').delete().eq('id', messageId).then((_) {}, onError: (_) {});
    } catch (e) {
      debugPrint('[ChannelsViewModel] deleteMessage error: $e');
    }
    notifyListeners();
  }

  void clearChannel(String channelId) {
    final list = getMessagesForChannel(channelId);
    list.clear();
    notifyListeners();
  }

  void toggleReaction(ChatMessage message, String emoji) {
    final existing = message.reactions.where((r) => r.emoji == emoji);
    if (existing.isNotEmpty) {
      final reaction = existing.first;
      if (reaction.isUserReacted) {
        reaction.count = (reaction.count - 1).clamp(0, 999);
        reaction.isUserReacted = false;
      } else {
        reaction.count += 1;
        reaction.isUserReacted = true;
      }
    } else {
      message.reactions.add(
        ChatReaction(emoji: emoji, count: 1, isUserReacted: true),
      );
    }
    notifyListeners();

    try {
      final Map<String, int> reactionsMap = {};
      for (final r in message.reactions) {
        reactionsMap[r.emoji] = r.count;
      }
      SupabaseService.instance.client.from('messages').update({
        'reactions': reactionsMap,
      }).eq('id', message.id).then((_) {}, onError: (_) {});
    } catch (e) {
      debugPrint('[ChannelsViewModel] toggleReaction Supabase error: $e');
    }
  }

  void addEmergencyRequest(EmergencyRequest request) {
    _requests.insert(0, request);
    notifyListeners();

    try {
      SupabaseService.instance.client.from('emergency_requests').insert({
        'id': request.id,
        'type': request.category.name,
        'title': request.title,
        'description': request.description,
        'location': request.patientLocation,
        'contact': request.contactNumber,
        'requester_name': request.postedBy,
        'status': 'active',
        'urgency': request.urgency.name,
        'created_at': request.postedAt.toIso8601String(),
      }).then((_) {}, onError: (_) {});
    } catch (e) {
      debugPrint('[ChannelsViewModel] addEmergencyRequest error: $e');
    }
  }


  @override
  void dispose() {
    _messagesSub?.cancel();
    _requestsSub?.cancel();
    super.dispose();
  }
}
