import 'package:flutter_test/flutter_test.dart';
import 'package:padma/ui/features/admin/view_models/admin_view_model.dart';
import 'package:padma/ui/features/auth/view_models/auth_view_model.dart';
import 'package:padma/data/models/user_profile.dart';

void main() {
  group('Admin Authentication Tests', () {
    test('Sign in with admin credentials authenticates with admin role', () async {
      final authVM = AuthViewModel();
      final success = await authVM.signIn('admin@padma.com', 'Padma@123');
      expect(success, true);
      expect(authVM.isAuthenticated, true);
      expect(authVM.isAdmin, true);
      expect(authVM.currentUser?.role, UserRole.admin);
      expect(authVM.currentUser?.name, 'Engr. Rafiqul Islam');
    });

    test('Direct signInAsAdmin triggers admin session', () async {
      final authVM = AuthViewModel();
      await authVM.signInAsAdmin();
      expect(authVM.isAuthenticated, true);
      expect(authVM.isAdmin, true);
    });
  });

  group('AdminViewModel Unit Tests', () {
    test('Initializes with default fleet, broadcast and moderation data', () {
      final adminVM = AdminViewModel();
      expect(adminVM.fleet.isNotEmpty, true);
      expect(adminVM.fleet.length, greaterThan(0));
      expect(adminVM.isGeneralLocked, false);
      expect(adminVM.isSlowModeEnabled, false);
      expect(adminVM.reportedMessages.isNotEmpty, true);
      expect(adminVM.lostFoundItems.isNotEmpty, true);
      expect(adminVM.announcements.isNotEmpty, true);
    });

    test('Can toggle general channel lock and slow mode', () {
      final adminVM = AdminViewModel();
      expect(adminVM.isGeneralLocked, false);
      adminVM.toggleGeneralLock();
      expect(adminVM.isGeneralLocked, true);

      expect(adminVM.isSlowModeEnabled, false);
      adminVM.toggleSlowMode();
      expect(adminVM.isSlowModeEnabled, true);
    });

    test('Can override bus speed and status', () {
      final adminVM = AdminViewModel();
      final firstBusId = adminVM.fleet.first.id;
      adminVM.updateBusSpeed(firstBusId, 65);
      expect(adminVM.fleet.firstWhere((b) => b.id == firstBusId).currentSpeed, 65);

      adminVM.updateBusStatus(firstBusId, AdminBusStatus.delayed);
      expect(adminVM.fleet.firstWhere((b) => b.id == firstBusId).status, AdminBusStatus.delayed);
    });

    test('Can publish priority announcement', () {
      final adminVM = AdminViewModel();
      final initialCount = adminVM.announcements.length;
      adminVM.addAnnouncement(
        title: 'Severe Weather Warning',
        body: 'Heavy downpour near Mohakhali flyover.',
        priority: 'Urgent',
        targetRoute: 'All Routes',
      );
      expect(adminVM.announcements.length, initialCount + 1);
      expect(adminVM.announcements.first.title, 'Severe Weather Warning');
      expect(adminVM.announcements.first.priority, 'Urgent');
    });

    test('Can moderate reported messages', () {
      final adminVM = AdminViewModel();
      final initialCount = adminVM.reportedMessages.length;
      final reportId = adminVM.reportedMessages.first.id;

      adminVM.resolveReport(reportId, deleteMessage: true);
      expect(adminVM.reportedMessages.length, initialCount - 1);
    });

    test('Can set and clear stoppage wait notice for short messages', () {
      final adminVM = AdminViewModel();
      const busId = 'bus_1';
      final bus = adminVM.fleet.firstWhere((b) => b.id == busId);

      expect(bus.activeWaitNotice, isNull);

      bool broadcastCalled = false;
      adminVM.setStoppageWaitNotice(
        busId: busId,
        stoppageName: 'Mirpur 10',
        untilTime: '12:30 PM',
        message: 'The bus will wait at mirpur 10 untill 12:30',
        onBroadcastMessage: (channel, msg) {
          broadcastCalled = true;
        },
      );

      expect(bus.activeWaitNotice, isNotNull);
      expect(bus.activeWaitNotice!.stoppageName, 'Mirpur 10');
      expect(bus.activeWaitNotice!.untilTime, '12:30 PM');
      expect(bus.activeWaitNotice!.message, 'The bus will wait at mirpur 10 untill 12:30');
      expect(broadcastCalled, isTrue);

      adminVM.clearStoppageWaitNotice(busId);
      expect(bus.activeWaitNotice, isNull);
    });

    test('Can start trip with Admin Person 1-6 and activate GPS broadcasting', () {
      final adminVM = AdminViewModel();
      const busId = 'bus_1';
      final bus = adminVM.fleet.firstWhere((b) => b.id == busId);

      expect(bus.status, AdminBusStatus.tripEnded);
      expect(bus.isBroadcastingGps, false);

      adminVM.startTripWithAdminAndGps(busId: busId, adminPersonName: 'Person 2');
      expect(bus.status, AdminBusStatus.onTime);
      expect(bus.isBroadcastingGps, true);
      expect(bus.activatedByAdmin, 'Person 2');

      adminVM.endTrip(busId);
      expect(bus.status, AdminBusStatus.tripEnded);
      expect(bus.isBroadcastingGps, false);
    });

    test('Can search users with autocomplete and send direct message', () {
      final adminVM = AdminViewModel();
      final results1 = adminVM.searchUsers('User 1');
      expect(results1.any((u) => u.name == 'User 1'), isTrue);
      expect(results1.any((u) => u.name == 'User 11'), isTrue);
      expect(results1.any((u) => u.name == 'User 12'), isTrue);

      final resultsPadma = adminVM.searchUsers('padmaStudent@aust.edu');
      expect(resultsPadma.length, 1);
      expect(resultsPadma.first.email, 'padmaStudent@aust.edu');

      adminVM.sendDirectMessageToUser(
        targetUserId: 'user_1',
        text: 'Bus schedule confirmed for today.',
        senderAdminName: 'Transport Admin (Person 1)',
      );
      final conv = adminVM.userConversations.firstWhere((c) => c.userId == 'user_1');
      expect(conv.lastMessage, 'Bus schedule confirmed for today.');
    });

    test('Can lock/unlock any channel and suspend/unblock any user', () {
      final adminVM = AdminViewModel();
      expect(adminVM.isChannelLocked('padma-1'), false);
      adminVM.toggleChannelLock('padma-1');
      expect(adminVM.isChannelLocked('padma-1'), true);
      adminVM.toggleChannelLock('padma-1');
      expect(adminVM.isChannelLocked('padma-1'), false);

      expect(adminVM.isUserSuspended('user_1'), false);
      adminVM.toggleUserSuspension('user_1');
      expect(adminVM.isUserSuspended('user_1'), true);
      adminVM.unblockUser('user_1');
      expect(adminVM.isUserSuspended('user_1'), false);
    });

    test('Can update bus schedules and stoppage ETAs', () {
      final adminVM = AdminViewModel();
      adminVM.updateDepartureTimes(firstBusTime: '07:00 AM', secondBusTime: '08:45 AM', returnTimes: '৪.০০ PM');
      expect(adminVM.firstBusDepartureTime, '07:00 AM');
      expect(adminVM.secondBusDepartureTime, '08:45 AM');
      expect(adminVM.returnTripTimes, '৪.০০ PM');

      adminVM.updateStoppageEta(isFirstBus: true, index: 0, newEta: '০৭:০০');
      expect(AdminViewModel.currentFirstBusStoppages[0].eta, '০৭:০০');
    });
  });
}
