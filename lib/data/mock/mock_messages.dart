import '../models/message_model.dart';
import '../models/user_model.dart';

class MockMessages {
  static List<MessageModel> get initialAnnouncements => [
        MessageModel(
          id: 'ann_1',
          channelId: 'announcements',
          senderId: 'admin_1',
          senderName: 'Transport Office',
          senderRole: UserRole.admin,
          text:
              '⚠️ [URGENT NOTICE] Due to flyover maintenance near Mohakhali, Bus 2 (Uttara) is rerouted via Jahangir Gate. Expect 10-15 min delay for the 8:00 AM shift.',
          isUrgent: true,
          isPinned: true,
          createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
          reactions: {'👍': 42, '🙏': 18, '❤️': 8},
        ),
        MessageModel(
          id: 'ann_2',
          channelId: 'announcements',
          senderId: 'admin_1',
          senderName: 'Transport Officer (Engr. Kamal)',
          senderRole: UserRole.admin,
          text:
              '📢 All campus buses will depart sharp at 5:15 PM today from Tejgaon Campus gate. Please arrive at the bus bays by 5:05 PM.',
          isUrgent: false,
          isPinned: true,
          createdAt: DateTime.now().subtract(const Duration(hours: 3)),
          reactions: {'👍': 89, '🚌': 54},
        ),
        MessageModel(
          id: 'ann_3',
          channelId: 'announcements',
          senderId: 'admin_1',
          senderName: 'Transport Office',
          senderRole: UserRole.admin,
          text:
              'Notice for Final Exam Week: Bus routes will operate on Saturday & Sunday shifts according to special semester schedule.',
          isUrgent: false,
          isPinned: false,
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          reactions: {'❤️': 31, '🙌': 12},
        ),
      ];

  static List<MessageModel> get initialGeneralMessages => [
        MessageModel(
          id: 'gen_1',
          channelId: 'general',
          senderId: 'u_101',
          senderName: 'Tahsin Ahmed',
          senderRole: UserRole.student,
          text: 'Shewrapara theke kotojon uthben ajke? Bus e ki seat ache?',
          createdAt: DateTime.now().subtract(const Duration(minutes: 25)),
          reactions: {'👋': 4},
        ),
        MessageModel(
          id: 'gen_2',
          channelId: 'general',
          senderId: 'u_102',
          senderName: 'Nusrat Jahan',
          senderRole: UserRole.student,
          text: 'Ha, Bus 1 e ekhono standard seats available. Kazipara cross korche matro.',
          createdAt: DateTime.now().subtract(const Duration(minutes: 20)),
          replyToSenderName: 'Tahsin Ahmed',
          replyToText: 'Shewrapara theke kotojon uthben ajke? Bus e ki seat ache?',
          reactions: {'👍': 6, '❤️': 2},
        ),
        MessageModel(
          id: 'gen_3',
          channelId: 'general',
          senderId: 'drv_1',
          senderName: 'Md. Rafiqul Islam (Driver)',
          senderRole: UserRole.driver,
          text:
              'Agargaon crossing e ektu jam ache. Shobai 2 minute extra somoy niye stop e ashun.',
          createdAt: DateTime.now().subtract(const Duration(minutes: 12)),
          reactions: {'🙏': 19, '🚌': 7},
        ),
        MessageModel(
          id: 'gen_4',
          channelId: 'general',
          senderId: 'u_103',
          senderName: 'Siam Chowdhury',
          senderRole: UserRole.student,
          text: 'Thanks chacha for the update! We are waiting at Bijoy Sarani.',
          createdAt: DateTime.now().subtract(const Duration(minutes: 8)),
          reactions: {'❤️': 3},
        ),
      ];

  static List<MessageModel> get initialBus1Messages => [
        MessageModel(
          id: 'b1_1',
          channelId: 'bus-1-mirpur',
          senderId: 'drv_1',
          senderName: 'Md. Rafiqul Islam (Driver)',
          senderRole: UserRole.driver,
          text: 'Mirpur 12 theke bus start hoyeche 7:15 AM e. Next stop Mirpur 11.',
          createdAt: DateTime.now().subtract(const Duration(minutes: 35)),
          reactions: {'👍': 12},
        ),
        MessageModel(
          id: 'b1_2',
          channelId: 'bus-1-mirpur',
          senderId: 'u_104',
          senderName: 'Farhan Kabir',
          senderRole: UserRole.student,
          text: 'Mirpur 10 e bus koto khon thakbe?',
          createdAt: DateTime.now().subtract(const Duration(minutes: 18)),
        ),
        MessageModel(
          id: 'b1_3',
          channelId: 'bus-1-mirpur',
          senderId: 'drv_1',
          senderName: 'Md. Rafiqul Islam (Driver)',
          senderRole: UserRole.driver,
          text: 'Mirpur 10 e 2 minute stoppage dibo, traffic police signal charlei chere dibo.',
          createdAt: DateTime.now().subtract(const Duration(minutes: 14)),
          replyToSenderName: 'Farhan Kabir',
          replyToText: 'Mirpur 10 e bus koto khon thakbe?',
          reactions: {'👌': 9},
        ),
      ];
}
