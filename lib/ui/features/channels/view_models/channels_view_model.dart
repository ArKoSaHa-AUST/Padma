import 'package:flutter/material.dart';
import '../../../../data/models/chat_message.dart';
import '../../../../data/models/emergency_request.dart';
import '../../../../data/services/mock_data_service.dart';

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

  List<ChatMessage> get generalMessages => _generalMessages;
  List<ChatMessage> get bus1Messages => _bus1Messages;
  List<ChatMessage> get bus2Messages => _bus2Messages;
  List<ChatMessage> get announcementsMessages => _announcementsMessages;
  List<ChatMessage> get emergencyBloodMessages => _emergencyBloodMessages;
  List<ChatMessage> get rideShareMessages => _rideShareMessages;

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
    final list = getMessagesForChannel(channelId);
    list.add(
      ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
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
    final targetList = getMessagesForChannel(channelId);
    targetList.add(
      ChatMessage(
        id: 'dispatch_${DateTime.now().millisecondsSinceEpoch}_${channelId.hashCode}',
        senderName: senderName,
        senderRole: senderRole,
        avatarInitials: 'ADM',
        badgeText: badgeText,
        text: text,
        timestamp: DateTime.now(),
        isTelemetry: true,
        reactions: [
          ChatReaction(emoji: '👍', count: 4, isUserReacted: true),
          ChatReaction(emoji: '🚌', count: 6),
        ],
      ),
    );
    notifyListeners();
  }

  void deleteMessage(String channelId, String messageId) {
    final list = getMessagesForChannel(channelId);
    list.removeWhere((m) => m.id == messageId);
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
  }

  void addEmergencyRequest(EmergencyRequest request) {
    _requests.insert(0, request);
    notifyListeners();
  }
}

