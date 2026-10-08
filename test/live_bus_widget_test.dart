import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:padma/features/live_bus/data/models/live_bus_location.dart';
import 'package:padma/features/live_bus/data/repositories/mock_live_location_repository.dart';
import 'package:padma/features/live_bus/domain/models/sharing_status.dart';
import 'package:padma/features/live_bus/domain/repositories/live_location_repository.dart';
import 'package:padma/features/live_bus/presentation/controllers/live_bus_view_model.dart';
import 'package:padma/features/live_bus/presentation/screens/live_bus_map_screen.dart';
import 'package:padma/features/live_bus/presentation/widgets/animated_bus_marker.dart';
import 'package:padma/features/live_bus/presentation/widgets/bus_marker_view.dart';
import 'package:padma/features/live_bus/presentation/widgets/live_status_badge.dart';

void main() {
  group('Live Bus Widget Tests', () {
    testWidgets('BusMarkerView renders speed and heading without errors', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: BusMarkerView(
                heading: 120.0,
                speed: 42.0,
                isLive: true,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(BusMarkerView), findsOneWidget);
      expect(find.byIcon(Icons.directions_bus_rounded), findsOneWidget);
      expect(find.text('42 km/h'), findsOneWidget);
    });

    testWidgets('LiveStatusBadge displays LIVE and remaining countdown', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: LiveStatusBadge(
                status: SharingStatus.sharing,
                remainingTime: '01:58:32',
                lastUpdatedText: '5s ago',
              ),
            ),
          ),
        ),
      );

      expect(find.text('LIVE'), findsOneWidget);
      expect(find.text('01:58:32'), findsOneWidget);
      expect(find.byIcon(Icons.timer_outlined), findsOneWidget);
    });

    testWidgets('AnimatedBusMarker smoothly updates on new coordinate input', (tester) async {
      final loc1 = LiveBusLocation(
        busId: 'bus_1',
        latitude: 23.7639,
        longitude: 90.4070,
        speed: 30.0,
        heading: 90.0,
        timestamp: DateTime.now(),
        sharingSessionId: 'sess_1',
      );

      final loc2 = LiveBusLocation(
        busId: 'bus_1',
        latitude: 23.7700,
        longitude: 90.4100,
        speed: 45.0,
        heading: 180.0,
        timestamp: DateTime.now(),
        sharingSessionId: 'sess_1',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: AnimatedBusMarker(
                targetLocation: loc1,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(AnimatedBusMarker), findsOneWidget);
      expect(find.text('30 km/h'), findsOneWidget);

      // Push updated coordinate
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: AnimatedBusMarker(
                targetLocation: loc2,
              ),
            ),
          ),
        ),
      );

      // Advance animation
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('45 km/h'), findsOneWidget);
    });

    testWidgets('LiveBusMapScreen renders map and controls cleanly', (tester) async {
      final repo = MockLiveLocationRepository(autoStartDemo: false);
      final vm = LiveBusViewModel(
        repository: repo,
        autoStartSharing: false,
      );

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<LiveLocationRepository>.value(value: repo),
            ChangeNotifierProvider<LiveBusViewModel>.value(value: vm),
          ],
          child: const MaterialApp(
            home: LiveBusMapScreen(
              busName: 'Bus 01 Mirpur',
            ),
          ),
        ),
      );

      expect(find.byType(LiveBusMapScreen), findsOneWidget);
      expect(find.byType(LiveStatusBadge), findsOneWidget);
      expect(find.text('Bus is Not Currently Live'), findsOneWidget);

      vm.dispose();
      repo.dispose();
    });
  });
}
