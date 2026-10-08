import 'package:flutter_test/flutter_test.dart';
import 'package:padma/ui/features/tracker/view_models/tracker_view_model.dart';

void main() {
  group('TrackerViewModel Unit Tests', () {
    test('Default route is Bus 1 Mirpur', () {
      final trackerVM = TrackerViewModel();
      expect(trackerVM.selectedRoute.id, 'bus-1');
      expect(trackerVM.routes.length, equals(2));
      trackerVM.dispose();
    });

    test('Selecting route changes active route', () {
      final trackerVM = TrackerViewModel();
      trackerVM.selectRoute('bus-2');
      expect(trackerVM.selectedRoute.id, 'bus-2');
      expect(trackerVM.selectedRoute.title, contains('Uttara'));
      trackerVM.dispose();
    });
  });
}
