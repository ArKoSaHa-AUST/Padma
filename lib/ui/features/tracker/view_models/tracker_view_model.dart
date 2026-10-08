import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../data/models/bus_model.dart';
import '../../../../data/models/bus_route.dart';
import '../../../../data/services/mock_data_service.dart';
import '../../../../data/services/supabase_service.dart';
import '../../admin/view_models/admin_view_model.dart';

class TrackerViewModel extends ChangeNotifier {
  final List<BusRouteInfo> _routes = List.from(MockDataService.availableRoutes);
  late BusRouteInfo _selectedRoute;
  int _currentSpeed = 0;
  int _currentEtaMinutes = 0;
  Timer? _telemetryTimer;
  StreamSubscription<List<Map<String, dynamic>>>? _supabaseLiveSub;

  TrackerViewModel() {
    _selectedRoute = _routes.first;
    _currentSpeed = _selectedRoute.speedKmh;
    _currentEtaMinutes = _selectedRoute.etaMinutes;
    _initSupabaseRealtime();
    _startTelemetrySimulation();
  }

  List<BusRouteInfo> get routes => _routes;
  BusRouteInfo get selectedRoute => _selectedRoute;
  int get currentSpeed => _currentSpeed;
  int get currentEtaMinutes => _currentEtaMinutes;

  void _initSupabaseRealtime() {
    try {
      final client = SupabaseService.instance.client;
      _supabaseLiveSub = client
          .from('live_bus_locations')
          .stream(primaryKey: ['bus_id'])
          .listen((records) {
        for (final r in records) {
          final busId = r['bus_id']?.toString();
          if (busId == null) continue;

          final routeId = (busId == 'bus_1' || busId == 'bus-1') ? 'bus-1' : 'bus-2';
          final idx = _routes.indexWhere((x) => x.id == routeId);
          if (idx != -1) {
            final oldRoute = _routes[idx];
            final lat = (r['latitude'] as num?)?.toDouble() ?? oldRoute.latitude;
            final lng = (r['longitude'] as num?)?.toDouble() ?? oldRoute.longitude;
            final speed = (r['speed_kmh'] as num?)?.toInt() ?? 0;
            final eta = (r['eta_minutes'] as num?)?.toInt() ?? 0;
            final currentStop = r['current_stop_name']?.toString() ?? oldRoute.currentStop;
            final nextStop = r['next_stop_name']?.toString() ?? oldRoute.nextStop;
            final isBroadcasting = r['is_broadcasting'] == true;
            final statusStr = r['status']?.toString() ?? 'onTime';

            BusStatus status = BusStatus.onTime;
            if (statusStr == 'delayed') status = BusStatus.delayed;
            if (statusStr == 'waiting') status = BusStatus.waiting;
            if (statusStr == 'breakdown') status = BusStatus.breakdown;
            if (statusStr == 'tripEnded') status = BusStatus.tripEnded;

            final currentStopIdx = (r['current_stop_index'] as num?)?.toInt() ?? 0;
            final updatedCheckpoints = oldRoute.checkpoints.asMap().entries.map((entry) {
              final i = entry.key;
              final cp = entry.value;
              return cp.copyWith(
                isCompleted: i < currentStopIdx,
                isCurrent: i == currentStopIdx,
              );
            }).toList();

            final updatedRoute = oldRoute.copyWith(
              currentStop: currentStop,
              nextStop: nextStop,
              speedKmh: speed,
              etaMinutes: eta,
              latitude: lat,
              longitude: lng,
              status: status,
              isBroadcastingGps: isBroadcasting,
              checkpoints: updatedCheckpoints,
            );

            _routes[idx] = updatedRoute;
            if (_selectedRoute.id == routeId) {
              _selectedRoute = updatedRoute;
              _currentSpeed = speed;
              _currentEtaMinutes = eta;
            }
          }
        }
        notifyListeners();
      }, onError: (err) {
        debugPrint('[TrackerViewModel] Supabase telemetry sub error: $err');
      });
    } catch (e) {
      debugPrint('[TrackerViewModel] Realtime sub error: $e');
    }
  }

  void selectRoute(String routeId) {
    final route = _routes.firstWhere(
      (r) => r.id == routeId || r.id == routeId.replaceAll('_', '-'),
      orElse: () => _routes.first,
    );
    _selectedRoute = route;
    _currentSpeed = route.speedKmh;
    _currentEtaMinutes = route.etaMinutes;
    notifyListeners();
  }

  void syncWithAdminBus(AdminBusItem adminBus) {
    final routeId = (adminBus.id == 'bus_1' || adminBus.id == 'bus-1') ? 'bus-1' : 'bus-2';
    final index = _routes.indexWhere((r) => r.id == routeId);
    if (index != -1) {
      final oldRoute = _routes[index];
      final busStatus = _mapAdminStatus(adminBus.status);

      final updatedCheckpoints = oldRoute.checkpoints.asMap().entries.map((entry) {
        final idx = entry.key;
        final cp = entry.value;
        return cp.copyWith(
          isCompleted: idx < adminBus.currentStopIndex,
          isCurrent: idx == adminBus.currentStopIndex,
        );
      }).toList();

      final updatedRoute = oldRoute.copyWith(
        currentStop: adminBus.currentStop,
        nextStop: adminBus.nextStop,
        speedKmh: adminBus.currentSpeed,
        etaMinutes: adminBus.etaMinutes,
        latitude: adminBus.latitude,
        longitude: adminBus.longitude,
        status: busStatus,
        isBroadcastingGps: adminBus.isBroadcastingGps,
        checkpoints: updatedCheckpoints,
      );

      _routes[index] = updatedRoute;
      if (_selectedRoute.id == routeId) {
        _selectedRoute = updatedRoute;
        _currentSpeed = adminBus.currentSpeed;
        _currentEtaMinutes = adminBus.etaMinutes;
      }
      notifyListeners();
    }
  }

  BusStatus _mapAdminStatus(AdminBusStatus status) {
    switch (status) {
      case AdminBusStatus.onTime:
        return BusStatus.onTime;
      case AdminBusStatus.delayed:
        return BusStatus.delayed;
      case AdminBusStatus.waiting:
        return BusStatus.waiting;
      case AdminBusStatus.breakdown:
        return BusStatus.breakdown;
      case AdminBusStatus.tripEnded:
        return BusStatus.tripEnded;
    }
  }

  void _startTelemetrySimulation() {
    _telemetryTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_selectedRoute.isTripEnded || _selectedRoute.speedKmh == 0) {
        _currentSpeed = 0;
        notifyListeners();
        return;
      }
      // If active broadcast, maintain speed
      final variation = (timer.tick % 5) - 2;
      _currentSpeed = (_selectedRoute.speedKmh + variation).clamp(15, 65);
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _telemetryTimer?.cancel();
    _supabaseLiveSub?.cancel();
    super.dispose();
  }
}
