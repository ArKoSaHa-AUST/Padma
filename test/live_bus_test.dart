import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:padma/core/utils/geo_utils.dart';
import 'package:padma/features/live_bus/data/models/device_location.dart';
import 'package:padma/features/live_bus/data/models/live_bus_location.dart';
import 'package:padma/features/live_bus/data/models/location_sharing_session.dart';
import 'package:padma/features/live_bus/data/repositories/mock_live_location_repository.dart';
import 'package:padma/features/live_bus/data/services/mock_device_location_service.dart';
import 'package:padma/features/live_bus/domain/models/sharing_status.dart';
import 'package:padma/features/live_bus/presentation/controllers/live_bus_view_model.dart';
import 'package:padma/features/live_bus/presentation/controllers/location_sharing_controller.dart';

void main() {
  group('GeoUtils Unit Tests', () {
    test('Coordinate validation accepts valid coordinates and rejects invalid ones', () {
      expect(GeoUtils.isValidLatitude(23.7639), isTrue);
      expect(GeoUtils.isValidLatitude(-90.0), isTrue);
      expect(GeoUtils.isValidLatitude(90.0), isTrue);
      expect(GeoUtils.isValidLatitude(91.0), isFalse);
      expect(GeoUtils.isValidLatitude(-95.0), isFalse);
      expect(GeoUtils.isValidLatitude(double.nan), isFalse);
      expect(GeoUtils.isValidLatitude(double.infinity), isFalse);

      expect(GeoUtils.isValidLongitude(90.4070), isTrue);
      expect(GeoUtils.isValidLongitude(-180.0), isTrue);
      expect(GeoUtils.isValidLongitude(180.0), isTrue);
      expect(GeoUtils.isValidLongitude(181.0), isFalse);
      expect(GeoUtils.isValidLongitude(-185.0), isFalse);

      expect(GeoUtils.isValidSpeed(0.0), isTrue);
      expect(GeoUtils.isValidSpeed(45.5), isTrue);
      expect(GeoUtils.isValidSpeed(-1.0), isFalse);
    });

    test('Heading normalization handles wrapping, negative numbers, and NaNs', () {
      expect(GeoUtils.normalizeHeading(0.0), 0.0);
      expect(GeoUtils.normalizeHeading(360.0), 0.0);
      expect(GeoUtils.normalizeHeading(450.0), 90.0);
      expect(GeoUtils.normalizeHeading(-90.0), 270.0);
      expect(GeoUtils.normalizeHeading(-360.0), 0.0);
      expect(GeoUtils.normalizeHeading(null), 0.0);
      expect(GeoUtils.normalizeHeading(double.nan), 0.0);
    });

    test('Interpolate coordinate calculates linear fraction accurately', () {
      const start = LatLng(20.0, 80.0);
      const end = LatLng(30.0, 90.0);

      final mid = GeoUtils.interpolateCoordinate(start, end, 0.5);
      expect(mid.latitude, closeTo(25.0, 0.0001));
      expect(mid.longitude, closeTo(85.0, 0.0001));

      final startPos = GeoUtils.interpolateCoordinate(start, end, 0.0);
      expect(startPos.latitude, closeTo(20.0, 0.0001));

      final endPos = GeoUtils.interpolateCoordinate(start, end, 1.0);
      expect(endPos.latitude, closeTo(30.0, 0.0001));
    });

    test('Interpolate bearing takes the shortest angular route across 0°/360° boundary', () {
      // 350° to 10° should interpolate through 0°, not spin 340° backwards
      final mid = GeoUtils.interpolateBearing(350.0, 10.0, 0.5);
      expect(mid, closeTo(0.0, 0.01));

      // 10° to 350° should also interpolate through 0°
      final midReverse = GeoUtils.interpolateBearing(10.0, 350.0, 0.5);
      expect(midReverse, closeTo(0.0, 0.01));

      // Standard interpolation
      final normal = GeoUtils.interpolateBearing(90.0, 180.0, 0.5);
      expect(normal, closeTo(135.0, 0.01));
    });
  });

  group('LiveBusLocation Model Tests', () {
    test('Validated factory accepts valid coordinates and rejects invalid ones', () {
      final valid = LiveBusLocation.validated(
        busId: 'bus_1',
        latitude: 23.8103,
        longitude: 90.4125,
        speed: 35.0,
        heading: 90.0,
        timestamp: DateTime(2026, 1, 1),
        sharingSessionId: 'session_123',
      );
      expect(valid.isValid, isTrue);
      expect(valid.latitude, 23.8103);
      expect(valid.speed, 35.0);

      expect(
        () => LiveBusLocation.validated(
          busId: 'bus_1',
          latitude: 95.0, // Invalid latitude
          longitude: 90.0,
          speed: 30.0,
          heading: 0.0,
          timestamp: DateTime.now(),
          sharingSessionId: 'sess_1',
        ),
        throwsA(isA<ArgumentError>()),
      );

      expect(
        () => LiveBusLocation.validated(
          busId: 'bus_1',
          latitude: 23.0,
          longitude: 195.0, // Invalid longitude
          speed: 30.0,
          heading: 0.0,
          timestamp: DateTime.now(),
          sharingSessionId: 'sess_1',
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('JSON serialization matches PostgreSQL / Supabase Realtime schema', () {
      final now = DateTime.utc(2026, 5, 10, 14, 30, 0);
      final loc = LiveBusLocation(
        busId: 'bus_1',
        latitude: 23.7639,
        longitude: 90.4070,
        speed: 28.5,
        heading: 180.0,
        timestamp: now,
        sharingSessionId: 'session_aust_01',
        isSharing: true,
      );

      final json = loc.toJson();
      expect(json['bus_id'], 'bus_1');
      expect(json['latitude'], 23.7639);
      expect(json['longitude'], 90.4070);
      expect(json['speed'], 28.5);
      expect(json['heading'], 180.0);
      expect(json['sharing_session_id'], 'session_aust_01');
      expect(json['is_sharing'], isTrue);

      // Deserialization from snake_case Supabase format
      final fromJson = LiveBusLocation.fromJson(json);
      expect(fromJson.busId, loc.busId);
      expect(fromJson.latitude, loc.latitude);
      expect(fromJson.longitude, loc.longitude);
      expect(fromJson.speed, loc.speed);
      expect(fromJson.sharingSessionId, loc.sharingSessionId);
      expect(fromJson.isSharing, isTrue);
    });

    test('DeviceLocation model parses correctly', () {
      final dev = DeviceLocation(
        latitude: 23.7639,
        longitude: 90.4070,
        speed: 40.0,
        heading: 90.0,
        timestamp: DateTime.now(),
      );
      expect(dev.isValid, isTrue);
      expect(dev.speed, 40.0);
    });
  });

  group('LocationSharingSession Tests (2-Hour Architecture)', () {
    test('Session calculates 2-hour duration and expiration correctly', () {
      final start = DateTime(2026, 6, 1, 10, 0, 0);
      final session = LocationSharingSession.startNew(
        busId: 'bus_1',
        now: start,
      );

      expect(session.startedAt, start);
      expect(session.expiresAt, start.add(const Duration(hours: 2)));
      expect(session.isActive, isTrue);

      // 1 hour after start -> not expired
      final timeAt1Hour = start.add(const Duration(hours: 1));
      expect(session.isExpired(timeAt1Hour), isFalse);
      expect(session.remainingDuration(timeAt1Hour), const Duration(hours: 1));
      expect(session.formattedRemainingTime(timeAt1Hour), '01:00:00');

      // 2 hours and 1 second after start -> expired
      final timeAtExpired = start.add(const Duration(hours: 2, seconds: 1));
      expect(session.isExpired(timeAtExpired), isTrue);
      expect(session.remainingDuration(timeAtExpired), Duration.zero);
      expect(session.formattedRemainingTime(timeAtExpired), '00:00:00');
    });

    test('Session JSON serialization & deserialization', () {
      final start = DateTime.utc(2026, 6, 1, 10, 0, 0);
      final session = LocationSharingSession.startNew(
        busId: 'bus_1',
        now: start,
      );

      final json = session.toJson();
      expect(json['bus_id'], 'bus_1');
      expect(json['is_active'], isTrue);

      final deserialized = LocationSharingSession.fromJson(json);
      expect(deserialized.sessionId, session.sessionId);
      expect(deserialized.busId, session.busId);
      expect(deserialized.isActive, isTrue);
    });
  });

  group('MockLiveLocationRepository & Controller Tests', () {
    test('Start and stop sharing lifecycle emits stream updates', () async {
      final mockDeviceService = MockDeviceLocationService(
        interval: const Duration(milliseconds: 50),
      );
      final repo = MockLiveLocationRepository(
        deviceLocationService: mockDeviceService,
        autoStartDemo: false,
      );
      final controller = LocationSharingController(repository: repo);

      expect(await controller.isSharingActive('bus_1'), isFalse);

      // Start Sharing
      await controller.startSharing('bus_1');
      expect(await controller.isSharingActive('bus_1'), isTrue);

      final activeSession = await controller.getActiveSession('bus_1');
      expect(activeSession, isNotNull);
      expect(activeSession!.busId, 'bus_1');
      expect(activeSession.isActive, isTrue);

      // Stop Sharing
      await controller.stopSharing('bus_1');
      expect(await controller.isSharingActive('bus_1'), isFalse);

      repo.dispose();
    });

    test('Simulate expiry transitions session to expired and stops location broadcasting', () async {
      final repo = MockLiveLocationRepository(autoStartDemo: false);
      await repo.startSharing('bus_1');

      expect(await repo.isSharing('bus_1'), isTrue);

      repo.simulateExpiry('bus_1');

      expect(await repo.isSharing('bus_1'), isFalse);

      repo.dispose();
    });

    test('LiveBusViewModel manages telemetry state and clock timer', () async {
      final repo = MockLiveLocationRepository(autoStartDemo: false);
      final vm = LiveBusViewModel(
        repository: repo,
        autoStartSharing: false,
      );

      expect(vm.isLive, isFalse);
      expect(vm.status, SharingStatus.idle);

      await vm.startSharing();
      expect(vm.isLive, isTrue);
      expect(vm.status, SharingStatus.sharing);
      expect(vm.remainingSessionFormatted, isNotEmpty);

      await vm.stopSharing();
      expect(vm.isLive, isFalse);
      expect(vm.status, SharingStatus.stopped);

      vm.dispose();
      repo.dispose();
    });
  });
}
