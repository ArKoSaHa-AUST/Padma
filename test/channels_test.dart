import 'package:flutter_test/flutter_test.dart';
import 'package:padma/ui/features/channels/view_models/channels_view_model.dart';
import 'package:padma/data/models/notification_item.dart';
import 'package:padma/data/models/lost_found_model.dart';

void main() {
  group('ChannelsViewModel Complete Workflow Tests', () {
    test('Rules & Regulations channel: Admin posts, users can react', () {
      final channelsVM = ChannelsViewModel();
      final initialCount = channelsVM.rulesMessages.length;

      // Admin posts official rule
      channelsVM.sendRulesMessage('Only students with valid ID cards may board during peak morning hours.');
      expect(channelsVM.rulesMessages.length, initialCount + 1);
      expect(channelsVM.rulesMessages.last.text, contains('ID cards'));
      expect(channelsVM.rulesMessages.last.senderRole, 'Transport Admin');

      // User adds reaction
      final msg = channelsVM.rulesMessages.last;
      channelsVM.toggleReaction(msg, '👍');
      expect(msg.reactions.any((r) => r.emoji == '👍' && r.count > 0), true);
    });

    test('Announcements channel: Admin posts, users can react', () {
      final channelsVM = ChannelsViewModel();
      final initialCount = channelsVM.announcementMessages.length;

      channelsVM.sendAnnouncementMessage('Mid-term examination special bus schedule published.');
      expect(channelsVM.announcementMessages.length, initialCount + 1);
      expect(channelsVM.announcementMessages.last.senderRole, 'Transport Admin');

      // Check notification triggered
      expect(channelsVM.notifications.any((n) => n.type == NotificationType.announcement), true);
    });

    test('Padma 1 & Padma 2 channels: Both user and admin can post with senderTag and mentions', () {
      final channelsVM = ChannelsViewModel();
      final initialCount1 = channelsVM.padma1Messages.length;
      final initialCount2 = channelsVM.padma2Messages.length;

      // Student posts on Padma 1 with chatTag
      channelsVM.sendPadma1Message(
        'Padma 1 reached Mirpur 10 stop. 10 seats free.',
        senderName: 'Padma Student',
        senderTag: 'Padma_CSE_4-1_Mirpur10',
      );
      expect(channelsVM.padma1Messages.length, initialCount1 + 1);
      expect(channelsVM.padma1Messages.last.senderTag, 'Padma_CSE_4-1_Mirpur10');

      // Admin posts on Padma 2
      channelsVM.sendPadma2Message(
        'Padma 2 started from Uttara Sector 7.',
        senderName: 'Engr. Rafiqul Islam',
        senderTag: 'Rafiqul_Admin_Staff_Uttara',
        senderRole: 'Transport Admin',
      );
      expect(channelsVM.padma2Messages.length, initialCount2 + 1);
      expect(channelsVM.padma2Messages.last.senderRole, 'Transport Admin');

      // Student mentions another student on Padma 1
      channelsVM.sendPadma1Message(
        'Hey @Rafi_CSE_3-2_Uttara is the bus crowded?',
        senderName: 'Padma Student',
        senderTag: 'Padma_CSE_4-1_Mirpur10',
      );
      expect(channelsVM.notifications.any((n) => n.type == NotificationType.mention), true);
    });

    test('Blood Request channel: Post with all required and optional fields', () {
      final channelsVM = ChannelsViewModel();
      final initialCount = channelsVM.bloodRequests.length;

      channelsVM.postBloodRequest(
        title: 'Urgent O+ Blood Needed at DMCH',
        bloodGroup: 'O+',
        hospitalName: 'Dhaka Medical College Hospital',
        patientDetails: 'Post-surgery recovery patient',
        messageBody: 'Required urgently before 4 PM today.',
        requiredDate: '2026-10-09',
        contactNumber: '+880 1711-998877',
        email: 'padmaStudent@aust.edu',
        extraInfo: 'Attendant will receive donor at emergency ward.',
        authorName: 'Padma Student',
        authorTag: 'Padma_CSE_4-1_Mirpur10',
      );

      expect(channelsVM.bloodRequests.length, initialCount + 1);
      final newReq = channelsVM.bloodRequests.first;
      expect(newReq.bloodGroup, 'O+');
      expect(newReq.hospitalName, 'Dhaka Medical College Hospital');
      expect(newReq.contactNumber, '+880 1711-998877');
      expect(newReq.authorTag, 'Padma_CSE_4-1_Mirpur10');
    });

    test('Lost and Found channel: Post item with title, body, and image', () {
      final channelsVM = ChannelsViewModel();
      final initialCount = channelsVM.lostFoundItems.length;

      channelsVM.postLostFoundItem(
        title: 'Found AUST ID Card & Blue Calculator',
        description: 'Left on Seat #14 in Padma 1 bus this morning.',
        type: 'found',
        imageUrl: 'https://images.unsplash.com/photo-1584438784894-089d6a62b8fa',
        location: 'Padma 1 Bus',
        contactNumber: '+880 1812-334455',
        authorName: 'Padma Student',
        authorTag: 'Padma_CSE_4-1_Mirpur10',
      );

      expect(channelsVM.lostFoundItems.length, initialCount + 1);
      final newItem = channelsVM.lostFoundItems.first;
      expect(newItem.title, 'Found AUST ID Card & Blue Calculator');
      expect(newItem.type, LostFoundType.found);
      expect(newItem.authorTag, 'Padma_CSE_4-1_Mirpur10');
    });

    test('Contact Admin channel: 1-on-1 private messaging with selected Admin', () {
      final channelsVM = ChannelsViewModel();
      final studentId = '2023202420252026';
      final admin1 = channelsVM.admins[0]; // Engr. Rafiqul Islam

      // Student sends private message to Admin 1
      channelsVM.sendPrivateAdminMessage(
        studentId: studentId,
        adminId: admin1.id,
        text: 'Hello Sir, will Padma 1 stop at Kazipara today?',
        senderName: 'Padma Student',
        senderTag: 'Padma_CSE_4-1_Mirpur10',
        senderRole: 'Student',
      );

      final convoWithAdmin1 = channelsVM.getAdminConversation(studentId: studentId, adminId: admin1.id);
      expect(convoWithAdmin1.length, 1);
      expect(convoWithAdmin1.first.text, contains('stop at Kazipara'));

      // Conversation with Admin 2 is empty/separate
      final admin2 = channelsVM.admins[1]; // Dr. Shahed Rahman
      final convoWithAdmin2 = channelsVM.getAdminConversation(studentId: studentId, adminId: admin2.id);
      expect(convoWithAdmin2.isEmpty, true);

      // Admin 1 replies to Student
      channelsVM.sendPrivateAdminMessage(
        studentId: studentId,
        adminId: admin1.id,
        text: 'Yes, Padma 1 will make a 2-minute halt at Kazipara.',
        senderName: admin1.name,
        senderTag: 'Rafiqul_Admin_Staff_Uttara',
        senderRole: 'Transport Admin',
      );

      final updatedConvo = channelsVM.getAdminConversation(studentId: studentId, adminId: admin1.id);
      expect(updatedConvo.length, 2);
      expect(updatedConvo.last.senderRole, 'Transport Admin');
    });

    test('Submit Complain channel: Student submits grievance, visible only to Admin triage', () {
      final channelsVM = ChannelsViewModel();
      final initialCount = channelsVM.complaints.length;

      channelsVM.submitComplaint(
        title: 'AC cooling issue in Padma 1 rear section',
        body: 'The air conditioning unit in the back 4 rows was not cooling during the 8:00 AM trip.',
        imageUrl: 'https://images.unsplash.com/photo-1544620347-c4fd4a3d5957',
        studentName: 'Padma Student',
        studentId: '2023202420252026',
        department: 'CSE',
        semester: '4-1',
        email: 'padmaStudent@aust.edu',
        pickupDestination: 'Mirpur 10',
      );

      expect(channelsVM.complaints.length, initialCount + 1);
      final complaint = channelsVM.complaints.first;
      expect(complaint.title, 'AC cooling issue in Padma 1 rear section');
      expect(complaint.studentId, '2023202420252026');
      expect(complaint.department, 'CSE');
      expect(complaint.semester, '4-1');
      expect(complaint.pickupDestination, 'Mirpur 10');
      expect(complaint.email, 'padmaStudent@aust.edu');
    });

    test('Bus departure and destination arrival trigger live notifications', () {
      final channelsVM = ChannelsViewModel();

      // Trigger bus journey start
      channelsVM.triggerBusJourneyStartNotification(
        busName: 'Padma 1 (Mirpur Route)',
        route: 'Mirpur 10 to AUST Campus',
      );

      expect(channelsVM.notifications.any((n) => n.type == NotificationType.journeyStart), true);

      // Trigger destination approach
      channelsVM.triggerDestinationApproachNotification(
        busName: 'Padma 1',
        destination: 'Mirpur 10',
        etaMinutes: 2,
      );

      expect(channelsVM.notifications.any((n) => n.type == NotificationType.destinationArrival), true);
    });

    test('Lost and Found comments: Add, edit, delete and mention notifications', () {
      final channelsVM = ChannelsViewModel();
      final postId = 'lf_1';

      // 1. Check initial seed comment
      final initialComments = channelsVM.getCommentsForPost(postId);
      expect(initialComments.isNotEmpty, true);

      // 2. Add a new comment
      channelsVM.addPostComment(
        postId: postId,
        content: 'I saw someone handing it to the 4th floor security desk @Siam_CSE_3-1_Mirpur10',
        userId: 'test-user-123',
        userName: 'Sadia Afrin',
        userTag: 'Sadia_CSE_2-2_Campus',
      );

      final updatedComments = channelsVM.getCommentsForPost(postId);
      expect(updatedComments.length, initialComments.length + 1);
      final newComment = updatedComments.last;
      expect(newComment.content, contains('4th floor security desk'));
      expect(newComment.userName, 'Sadia Afrin');

      // Check that mention notification was generated
      expect(channelsVM.notifications.any((n) => n.type == NotificationType.mention), true);

      // 3. Edit comment
      channelsVM.updatePostComment(
        newComment.id,
        'Updated: Actually handed to Room 4A03 lab attendant Mr. Harun.',
      );

      final editedComment = channelsVM.getCommentsForPost(postId).firstWhere((c) => c.id == newComment.id);
      expect(editedComment.content, 'Updated: Actually handed to Room 4A03 lab attendant Mr. Harun.');
      expect(editedComment.updatedAt != null, true);

      // 4. Delete comment
      channelsVM.deletePostComment(newComment.id);
      final finalComments = channelsVM.getCommentsForPost(postId);
      expect(finalComments.any((c) => c.id == newComment.id), false);
    });
  });
}
