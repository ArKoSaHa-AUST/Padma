import '../models/bus_model.dart';
import '../models/bus_route.dart';
import '../models/chat_message.dart';
import '../models/emergency_request.dart';
import '../models/user_profile.dart';

class MockDataService {
  static const List<BusRouteInfo> availableRoutes = [
    BusRouteInfo(
      id: 'bus-1',
      title: 'Padma 1 (Mirpur Route)',
      startLocation: 'Mirpur 12 Bus Stand',
      destination: 'AUST Campus (Tejgaon)',
      currentStop: 'Mirpur 12',
      nextStop: 'Mirpur 11',
      etaMinutes: 0,
      speedKmh: 0,
      latitude: 23.8272,
      longitude: 90.3644,
      driverName: 'Md. Rafiqul Islam',
      driverPhone: '+880 1711-234567',
      busNumber: 'Dhaka Metro-Cha 11-4589',
      status: BusStatus.tripEnded,
      isBroadcastingGps: false,
      checkpoints: [
        BusRouteCheckpoint(name: 'Mirpur 12', lat: 23.8272, lng: 90.3644, eta: '07:15 AM', isCurrent: true),
        BusRouteCheckpoint(name: 'Mirpur 11', lat: 23.8173, lng: 90.3653, eta: '07:22 AM'),
        BusRouteCheckpoint(name: 'Mirpur 10', lat: 23.8070, lng: 90.3686, eta: '07:30 AM'),
        BusRouteCheckpoint(name: 'Kazipara', lat: 23.7963, lng: 90.3725, eta: '07:38 AM'),
        BusRouteCheckpoint(name: 'Shewrapara', lat: 23.7876, lng: 90.3751, eta: '07:45 AM'),
        BusRouteCheckpoint(name: 'Agargaon Metro', lat: 23.7785, lng: 90.3794, eta: '07:55 AM'),
        BusRouteCheckpoint(name: 'Bijoy Sarani', lat: 23.7663, lng: 90.3872, eta: '08:05 AM'),
        BusRouteCheckpoint(name: 'AUST Campus (Tejgaon)', lat: 23.7695, lng: 90.4074, eta: '08:20 AM'),
      ],
    ),
    BusRouteInfo(
      id: 'bus-2',
      title: 'Padma 2 (Uttara Route)',
      startLocation: 'Uttara House Building',
      destination: 'AUST Campus (Tejgaon)',
      currentStop: 'Uttara House Building',
      nextStop: 'Azampur',
      etaMinutes: 0,
      speedKmh: 0,
      latitude: 23.8748,
      longitude: 90.3986,
      driverName: 'Al-Amin Hossain',
      driverPhone: '+880 1812-345678',
      busNumber: 'Dhaka Metro-Cha 11-8920',
      status: BusStatus.tripEnded,
      isBroadcastingGps: false,
      checkpoints: [
        BusRouteCheckpoint(name: 'Uttara House Building', lat: 23.8748, lng: 90.3986, eta: '07:00 AM', isCurrent: true),
        BusRouteCheckpoint(name: 'Azampur', lat: 23.8682, lng: 90.4005, eta: '07:12 AM'),
        BusRouteCheckpoint(name: 'Airport Road Crossing', lat: 23.8515, lng: 90.4078, eta: '07:25 AM'),
        BusRouteCheckpoint(name: 'Khilkhet', lat: 23.8315, lng: 90.4175, eta: '07:38 AM'),
        BusRouteCheckpoint(name: 'Radisson / Army Golf', lat: 23.8210, lng: 90.4120, eta: '07:48 AM'),
        BusRouteCheckpoint(name: 'Kakoli / Banani', lat: 23.7940, lng: 90.4042, eta: '08:00 AM'),
        BusRouteCheckpoint(name: 'Mohakhali', lat: 23.7778, lng: 90.4020, eta: '08:12 AM'),
        BusRouteCheckpoint(name: 'Nabisco / Tejgaon', lat: 23.7682, lng: 90.4055, eta: '08:22 AM'),
        BusRouteCheckpoint(name: 'AUST Campus (Tejgaon)', lat: 23.7695, lng: 90.4074, eta: '08:30 AM'),
      ],
    ),
  ];

  static List<ChatMessage> getGeneralChatMessages() {
    return [
      ChatMessage(
        id: '1',
        senderName: 'Tanvir (CSE 4.1)',
        senderRole: 'Student Moderator',
        avatarInitials: 'TA',
        text: 'Anyone taking Mirpur Bus 1? Is traffic bad near Agargaon?',
        timestamp: DateTime.now().subtract(const Duration(minutes: 18)),
        reactions: [
          ChatReaction(emoji: '🚌', count: 7, isUserReacted: true),
          ChatReaction(emoji: '👍', count: 4),
        ],
      ),
      ChatMessage(
        id: '2',
        senderName: 'Nadia (EEE 3.2)',
        senderRole: 'Transit Marshal',
        avatarInitials: 'NA',
        text: 'Agargaon Flyover is moving smoothly. Should reach AUST in 15 mins!',
        timestamp: DateTime.now().subtract(const Duration(minutes: 14)),
        badgeText: 'Verified Marshal',
        reactions: [
          ChatReaction(emoji: '❤️', count: 12),
          ChatReaction(emoji: '🔥', count: 3),
        ],
      ),
      ChatMessage(
        id: '3',
        senderName: 'Siam (ME 2.2)',
        senderRole: 'Student',
        avatarInitials: 'SI',
        text: 'Uttara Bus is slightly delayed due to Airport road construction. Watch live GPS.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        reactions: [
          ChatReaction(emoji: '👀', count: 5),
        ],
      ),
    ];
  }

  static List<ChatMessage> getBus1TelemetryMessages() {
    return [
      ChatMessage(
        id: 't-1',
        senderName: 'Padma Telemetry Bot',
        senderRole: 'Automated Bot',
        avatarInitials: 'BOT',
        text: '📍 Checkpoint Reached: Mirpur 10 Crossing (07:42 AM). Bus on schedule.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 16)),
        isTelemetry: true,
      ),
      ChatMessage(
        id: 't-2',
        senderName: 'Driver Assistant (Rafiq)',
        senderRole: 'Driver Staff',
        avatarInitials: 'DR',
        text: 'Approx 12 seats available from Agargaon pickup point.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 11)),
        badgeText: 'Bus Staff',
        reactions: [
          ChatReaction(emoji: '💺', count: 9),
        ],
      ),
      ChatMessage(
        id: 't-3',
        senderName: 'Fahim (CSE 4.2)',
        senderRole: 'Student',
        avatarInitials: 'FA',
        text: 'Standing near Passport Office Agargaon, waving flag!',
        timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
      ),
    ];
  }

  static List<ChatMessage> getBus2TelemetryMessages() {
    return [
      ChatMessage(
        id: 't-u1',
        senderName: 'Padma Telemetry Bot',
        senderRole: 'Automated Bot',
        avatarInitials: 'BOT',
        text: '📍 Checkpoint Reached: Airport Road Crossing (07:25 AM). Traffic moving smoothly.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 20)),
        isTelemetry: true,
      ),
      ChatMessage(
        id: 't-u2',
        senderName: 'Driver Assistant (Al-Amin)',
        senderRole: 'Driver Staff',
        avatarInitials: 'DR',
        text: 'Boarding now at Khilkhet bus bay.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 8)),
        badgeText: 'Bus Staff',
        reactions: [
          ChatReaction(emoji: '👍', count: 6),
        ],
      ),
    ];
  }

  static List<EmergencyRequest> getEmergencyRequests() {
    return [
      EmergencyRequest(
        id: 'req-1',
        title: 'Urgent B+ Blood Needed (2 Bags)',
        description: 'Open heart surgery scheduled for AUST alumni father at National Heart Foundation, Mirpur.',
        patientLocation: 'National Heart Foundation, Mirpur-2',
        bloodGroup: 'B+',
        category: RequestCategory.blood,
        urgency: RequestUrgency.critical,
        contactNumber: '+880 1711-223344',
        postedBy: 'Sadman Sakib (CSE 4.2)',
        postedAt: DateTime.now().subtract(const Duration(minutes: 45)),
      ),
      EmergencyRequest(
        id: 'req-2',
        title: 'Emergency O- Donor for Emergency Delivery',
        description: 'Urgent requirement at Square Hospital Panthapath today before 12:00 PM.',
        patientLocation: 'Square Hospital, Panthapath',
        bloodGroup: 'O-',
        category: RequestCategory.blood,
        urgency: RequestUrgency.critical,
        contactNumber: '+880 1822-998877',
        postedBy: 'Tahsin Ara (Arch 3.1)',
        postedAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      EmergencyRequest(
        id: 'req-3',
        title: 'AUST Bus 2 Lost Wallet with ID Card',
        description: 'Black leather wallet left on seat 4B. Contains AUST Student ID and Metro Pass.',
        patientLocation: 'AUST Tejgaon Gate / Bus 2',
        bloodGroup: 'N/A',
        category: RequestCategory.other,
        urgency: RequestUrgency.medium,
        contactNumber: '+880 1912-334455',
        postedBy: 'Arman Khan (EEE 2.1)',
        postedAt: DateTime.now().subtract(const Duration(hours: 4)),
      ),
    ];
  }

  static const UserProfile currentUser = UserProfile(
    id: 'aust-20210104052',
    name: 'Rashedul Hasan',
    email: '20210104052@aust.edu',
    studentId: '20210104052',
    department: 'Computer Science & Engineering',
    session: 'Fall 2021 (4th Year)',
    bloodGroup: 'B+',
    isVerified: true,
    isDonor: true,
    tripsTaken: 56,
    contributions: 24,
  );
}
