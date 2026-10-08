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
      expect(authVM.currentUser?.name, 'AUST Transport Admin');
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
      final busId = 'bus_1';
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
  });
}
