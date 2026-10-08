import 'package:flutter_test/flutter_test.dart';
import 'package:padma/ui/features/auth/view_models/auth_view_model.dart';

void main() {
  group('AuthViewModel Unit Tests', () {
    test('Initial auth state is not authenticated', () {
      final authVM = AuthViewModel();
      expect(authVM.isAuthenticated, false);
      expect(authVM.currentUser, isNull);
    });

    test('Sign in with seeded student credentials works', () async {
      final authVM = AuthViewModel();
      final success = await authVM.signIn('padmaStudent@aust.edu', 'Padma@123');
      expect(success, true);
      expect(authVM.isAuthenticated, true);
      expect(authVM.currentUser?.email, 'padmaStudent@aust.edu');
      expect(authVM.currentUser?.studentId, '2023202420252026');
      expect(authVM.currentUser?.chatTag, 'Padma_CSE_4-1_Mirpur10');
      expect(authVM.currentUser?.pickupDestination, 'Mirpur 10');
    });

    test('Sign in with seeded student ID works', () async {
      final authVM = AuthViewModel();
      final success = await authVM.signIn('2023202420252026', 'Padma@123');
      expect(success, true);
      expect(authVM.isAuthenticated, true);
      expect(authVM.currentUser?.email, 'padmaStudent@aust.edu');
    });

    test('Non @aust.edu email registration fails validation', () async {
      final authVM = AuthViewModel();
      final success = await authVM.signUp(
        email: 'user@gmail.com',
        studentId: '20230104999',
        password: 'Password@123',
        name: 'Test Student',
        department: 'CSE',
        semester: '3-2',
        bloodGroup: 'B+',
        pickupDestination: 'Uttara',
      );
      expect(success, false);
      expect(authVM.errorMessage, contains('@aust.edu'));
      expect(authVM.isAuthenticated, false);
    });

    test('Valid @aust.edu registration succeeds with pickup destination', () async {
      final authVM = AuthViewModel();
      final success = await authVM.signUp(
        email: 'rakib.cse@aust.edu',
        studentId: '20230104111',
        password: 'Password@123',
        name: 'Rakib Hasan',
        department: 'CSE',
        semester: '3-1',
        bloodGroup: 'A+',
        pickupDestination: 'Farmgate',
      );
      expect(success, true);
      expect(authVM.isAuthenticated, true);
      expect(authVM.currentUser?.email, 'rakib.cse@aust.edu');
      expect(authVM.currentUser?.pickupDestination, 'Farmgate');
      expect(authVM.currentUser?.chatTag, 'Rakib_CSE_3-1_Farmgate');
    });

    test('Session automatically expires after 2 hours (120 minutes)', () async {
      final authVM = AuthViewModel();
      await authVM.signIn('padmaStudent@aust.edu', 'Padma@123');
      expect(authVM.isAuthenticated, true);

      // Advance time by 2 hours + 1 minute (121 minutes)
      authVM.simulateTimeAdvance(const Duration(minutes: 121));
      expect(authVM.isSessionExpired, true);

      // Check session validity triggers auto logout
      authVM.checkSessionValidity();
      expect(authVM.isAuthenticated, false);
      expect(authVM.sessionExpiredMessage, isNotEmpty);
    });

    test('Sign out clears authenticated state completely', () async {
      final authVM = AuthViewModel();
      await authVM.signIn('padmaStudent@aust.edu', 'Padma@123');
      expect(authVM.isAuthenticated, true);

      authVM.signOut();
      expect(authVM.isAuthenticated, false);
      expect(authVM.currentUser, isNull);
    });

    test('Edit user profile information updates details and chatTag', () async {
      final authVM = AuthViewModel();
      await authVM.signIn('padmaStudent@aust.edu', 'Padma@123');

      authVM.updateUserProfile(
        name: 'Padma Alumnus',
        department: 'EEE',
        semester: '4-2',
        bloodGroup: 'AB+',
        pickupDestination: 'Dhanmondi 27',
      );

      expect(authVM.currentUser?.name, 'Padma Alumnus');
      expect(authVM.currentUser?.department, 'EEE');
      expect(authVM.currentUser?.semester, '4-2');
      expect(authVM.currentUser?.bloodGroup, 'AB+');
      expect(authVM.currentUser?.pickupDestination, 'Dhanmondi 27');
      expect(authVM.currentUser?.chatTag, 'Padma_EEE_4-2_Dhanmondi27');
    });
  });
}
