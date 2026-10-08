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
      etaMinutes: 2,
      speedKmh: 34,
      latitude: 23.8272,
      longitude: 90.3644,
      driverName: 'Md. Rafiqul Islam',
      driverPhone: '+880 1711-234567',
      busNumber: 'Dhaka Metro-Cha 11-4589',
      status: BusStatus.onTime,
      isBroadcastingGps: true,
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
      etaMinutes: 12,
      speedKmh: 28,
      latitude: 23.8748,
      longitude: 90.3986,
      driverName: 'Al-Amin Hossain',
      driverPhone: '+880 1812-345678',
      busNumber: 'Dhaka Metro-Cha 11-8920',
      status: BusStatus.onTime,
      isBroadcastingGps: true,
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

  static List<ChatMessage> getRulesAndRegulationsMessages() {
    return [
      ChatMessage(
        id: 'rule-1',
        senderName: 'Engr. Rafiqul Islam',
        senderRole: 'Transport Admin',
        senderTag: 'Rafiq_Transport_Official_Campus',
        avatarInitials: 'ADM',
        badgeText: 'OFFICIAL POLICY',
        text: '📜 **Rule 1 — Institutional Bus Pass & ID**: Every student must display their physical AUST ID card or digital Padma Verified pass upon boarding.',
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
        reactions: [
          ChatReaction(emoji: '👍', count: 48, isUserReacted: true),
          ChatReaction(emoji: '✅', count: 32),
        ],
      ),
      ChatMessage(
        id: 'rule-2',
        senderName: 'Engr. Rafiqul Islam',
        senderRole: 'Transport Admin',
        senderTag: 'Rafiq_Transport_Official_Campus',
        avatarInitials: 'ADM',
        badgeText: 'OFFICIAL POLICY',
        text: '📜 **Rule 2 — Departure Timing**: Buses will leave strictly according to schedule. Drivers are prohibited from waiting at unscheduled stoppage points.',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        reactions: [
          ChatReaction(emoji: '⏰', count: 27),
          ChatReaction(emoji: '🚌', count: 19),
        ],
      ),
      ChatMessage(
        id: 'rule-3',
        senderName: 'Dr. Shahed Rahman',
        senderRole: 'Transport Admin',
        senderTag: 'Shahed_StudentAffairs_Official_Campus',
        avatarInitials: 'ADM',
        badgeText: 'SAFETY DIRECTIVE',
        text: '📜 **Rule 3 — Code of Conduct**: Maintain decorum inside all university vehicles. Priority seating on the lower deck is reserved for female students and differently-abled commuters.',
        timestamp: DateTime.now().subtract(const Duration(hours: 12)),
        reactions: [
          ChatReaction(emoji: '❤️', count: 45),
          ChatReaction(emoji: '👏', count: 31),
        ],
      ),
    ];
  }

  static List<ChatMessage> getAnnouncementsMessages() {
    return [
      ChatMessage(
        id: 'ann-1',
        senderName: 'Engr. Rafiqul Islam',
        senderRole: 'Transport Admin',
        senderTag: 'Rafiq_Transport_Official_Campus',
        avatarInitials: 'ADM',
        badgeText: 'ANNOUNCEMENT',
        text: '📢 **Campus Midterm Transport Schedule**: All morning trips for Padma 1 and Padma 2 will operate 15 minutes earlier starting Sunday.',
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
        reactions: [
          ChatReaction(emoji: '👍', count: 52, isUserReacted: true),
          ChatReaction(emoji: '🚌', count: 38),
          ChatReaction(emoji: '❤️', count: 24),
        ],
      ),
      ChatMessage(
        id: 'ann-2',
        senderName: 'Dr. Shahed Rahman',
        senderRole: 'Transport Admin',
        senderTag: 'Shahed_StudentAffairs_Official_Campus',
        avatarInitials: 'ADM',
        badgeText: 'WEATHER ALERT',
        text: '🌧️ **Weather Advisory**: Heavy rain forecasted in Mirpur corridor. Drivers instructed to proceed with extra safety. Please reach stoppage 5 mins early.',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        reactions: [
          ChatReaction(emoji: '☔', count: 41),
          ChatReaction(emoji: '🙏', count: 18),
        ],
      ),
    ];
  }

  static List<ChatMessage> getBus1TelemetryMessages() {
    return [
      ChatMessage(
        id: 't-1',
        senderName: 'Padma Telemetry Beacon',
        senderRole: 'Automated Beacon',
        senderTag: 'System_Telemetry_Auto_Mirpur12',
        avatarInitials: 'BOT',
        badgeText: 'BEACON',
        text: '📍 **Journey Started**: Padma 1 departed Mirpur 12 Bus Stand at 07:15 AM towards AUST Campus.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 18)),
        isTelemetry: true,
      ),
      ChatMessage(
        id: 't-2',
        senderName: 'Tanvir Ahmed',
        senderRole: 'Verified Student',
        senderTag: 'Tanvir_CSE_4-1_Mirpur10',
        avatarInitials: 'TA',
        text: 'Bus 1 just crossed Mirpur 10 roundabout! Plenty of seats on upper deck right now. @Padma_CSE_4-1_Mirpur10 you can board smoothly!',
        timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
        reactions: [
          ChatReaction(emoji: '💺', count: 8),
          ChatReaction(emoji: '👍', count: 6),
        ],
      ),
      ChatMessage(
        id: 't-3',
        senderName: 'Md. Rafiqul Islam (Driver)',
        senderRole: 'Transport Admin',
        senderTag: 'Rafiq_Transport_Staff_Mirpur12',
        avatarInitials: 'DR',
        badgeText: 'DRIVER',
        text: 'Crossing Shewrapara now. Expected arrival at Agargaon in 6 mins.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 4)),
      ),
    ];
  }

  static List<ChatMessage> getBus2TelemetryMessages() {
    return [
      ChatMessage(
        id: 't-u1',
        senderName: 'Padma Telemetry Beacon',
        senderRole: 'Automated Beacon',
        senderTag: 'System_Telemetry_Auto_Uttara',
        avatarInitials: 'BOT',
        badgeText: 'BEACON',
        text: '📍 **Journey Started**: Padma 2 departed Uttara House Building at 07:00 AM.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 25)),
        isTelemetry: true,
      ),
      ChatMessage(
        id: 't-u2',
        senderName: 'Nabil Hasan',
        senderRole: 'Verified Student',
        senderTag: 'Nabil_EEE_3-2_Uttara',
        avatarInitials: 'NH',
        text: 'Traffic moving well after Airport crossing. On schedule for 8:15 AM campus arrival!',
        timestamp: DateTime.now().subtract(const Duration(minutes: 12)),
        reactions: [
          ChatReaction(emoji: '🔥', count: 5),
        ],
      ),
    ];
  }

  static List<EmergencyRequest> getEmergencyRequests() {
    return [
      EmergencyRequest(
        id: 'req-1',
        title: 'Urgent O+ Blood Needed (2 Bags) for Surgery',
        description: 'Open heart surgery scheduled for AUST alumni patient at National Heart Foundation, Mirpur-2.',
        patientLocation: 'National Heart Foundation, Mirpur-2',
        bloodGroup: 'O+',
        category: RequestCategory.blood,
        urgency: RequestUrgency.critical,
        contactNumber: '+880 1711-223344',
        postedBy: 'Padma Student (CSE 4.1)',
        postedAt: DateTime.now().subtract(const Duration(minutes: 45)),
      ),
    ];
  }

  static const UserProfile currentUser = UserProfile(
    id: 'aust-2023202420252026',
    name: 'Padma Student',
    email: 'padmaStudent@aust.edu',
    studentId: '2023202420252026',
    department: 'CSE',
    semester: '4-1',
    session: 'Fall 2023',
    bloodGroup: 'O+',
    pickupDestination: 'Mirpur 10',
    contactNumber: '+880 1711-000000',
    isVerified: true,
    isDonor: true,
  );
}
