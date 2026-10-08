import 'package:flutter_test/flutter_test.dart';
import 'package:padma/ui/features/auth/view_models/auth_view_model.dart';

void main() {
  group('AuthViewModel Unit Tests', () {
    test('Initial auth state is not authenticated', () {
      final authVM = AuthViewModel();
      expect(authVM.isAuthenticated, false);
      expect(authVM.isGuest, false);
    });

    test('Continue as guest sets guest status', () {
      final authVM = AuthViewModel();
      authVM.continueAsGuest();
      expect(authVM.isGuest, true);
      expect(authVM.isAuthenticated, true);
    });

    test('Sign in authenticates with student profile', () async {
      final authVM = AuthViewModel();
      final success = await authVM.signIn('20210104052', 'password123');
      expect(success, true);
      expect(authVM.isAuthenticated, true);
      expect(authVM.currentUser?.studentId, '20210104052');
    });

    test('Sign out clears authenticated state', () async {
      final authVM = AuthViewModel();
      await authVM.signIn('20210104052', 'password123');
      expect(authVM.isAuthenticated, true);

      authVM.signOut();
      expect(authVM.isAuthenticated, false);
    });
  });
}
