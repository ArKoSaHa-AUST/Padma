import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../data/models/bus_model.dart';
import '../../../../data/models/bus_route.dart';
import '../../../../data/services/mock_data_service.dart';
import '../../admin/view_models/admin_view_model.dart';

class TrackerViewModel extends ChangeNotifier {
  final List<BusRouteInfo> _routes = List.from(MockDataService.availableRoutes);
  late BusRouteInfo _selectedRoute;
  int _currentSpeed = 0;
  int _currentEtaMinutes = 0;
  Timer? _telemetryTimer;

  TrackerViewModel() {
    _selectedRoute = _routes.first;
    _currentSpeed = _selectedRoute.speedKmh;
    _currentEtaMinutes = _selectedRoute.etaMinutes;
    _startTelemetrySimulation();
  }

  List<BusRouteInfo> get routes => _routes;
  BusRouteInfo get selectedRoute => _selectedRoute;
  int get currentSpeed => _currentSpeed;
  int get currentEtaMinutes => _currentEtaMinutes;

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
      // Simulate minor speed variations when active
      final variation = (timer.tick % 5) - 2;
      _currentSpeed = (_selectedRoute.speedKmh + variation).clamp(15, 65);
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _telemetryTimer?.cancel();
    super.dispose();
  }
}
