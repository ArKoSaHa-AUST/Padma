import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/bus_model.dart';
import '../models/route_model.dart';
import '../models/admin_update_model.dart';
import '../mock/mock_buses.dart';
import '../mock/mock_routes.dart';
import '../mock/mock_admin_updates.dart';

abstract class BusRepository {
  List<RouteModel> getRoutes();
  RouteModel getRouteById(String id);
  List<BusModel> getBuses();
  BusModel getBusById(String id);
  Stream<BusModel> getBusStream(String busId);
  Stream<List<BusModel>> getAllBusesStream();
  Stream<List<AdminUpdateModel>> getAdminUpdatesStream();
  Future<void> toggleFavoriteStop(String routeId, String stopId);
  Future<void> setArrivalAlert(String routeId, String stopId, int leadMinutes);
  void dispose();
}

class InMemoryBusRepository implements BusRepository {
  final List<RouteModel> _routes = List.from(MockRoutes.allRoutes);
  final List<BusModel> _buses = List.from(MockBuses.allBuses);
  final List<AdminUpdateModel> _adminUpdates = List.from(MockAdminUpdates.initialUpdates);

  final _busStreamController = StreamController<List<BusModel>>.broadcast();
  final _adminUpdatesController = StreamController<List<AdminUpdateModel>>.broadcast();
  Timer? _telemetryTimer;
  int _stepIndex = 0;

  InMemoryBusRepository() {
    _adminUpdatesController.add(List.unmodifiable(_adminUpdates));
    _startSimulation();
  }

  void _startSimulation() {
    _telemetryTimer?.cancel();
    _telemetryTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _stepIndex++;
      // Simulate slight movement for Bus 1 (Mirpur Route)
      final bus1 = _buses.firstWhere((b) => b.id == 'bus_1');
      final stops = MockRoutes.mirpurRoute.stops;

      final targetStopIndex = (_stepIndex ~/ 8) % (stops.length - 1);
      final nextStop = stops[targetStopIndex + 1];
      final prevStop = stops[targetStopIndex];

      final fraction = (_stepIndex % 8) / 8.0;
      final currentLat = prevStop.lat + (nextStop.lat - prevStop.lat) * fraction;
      final currentLng = prevStop.lng + (nextStop.lng - prevStop.lng) * fraction;
      final eta = (3 - (fraction * 3).toInt()).clamp(1, 15);

      final updatedBus1 = bus1.copyWith(
        currentLat: currentLat,
        currentLng: currentLng,
        nextStopName: nextStop.name,
        nextStopNameBn: nextStop.nameBn,
        etaMinutes: eta,
        distanceProgress: fraction,
        speedKmH: 28 + (_stepIndex % 10),
        updatedAt: DateTime.now(),
      );

      final idx = _buses.indexWhere((b) => b.id == 'bus_1');
      if (idx != -1) {
        _buses[idx] = updatedBus1;
      }

      if (!_busStreamController.isClosed) {
        _busStreamController.add(List.unmodifiable(_buses));
      }
    });
  }

  @override
  List<RouteModel> getRoutes() => List.unmodifiable(_routes);

  @override
  RouteModel getRouteById(String id) {
    return _routes.firstWhere((r) => r.id == id, orElse: () => _routes.first);
  }

  @override
  List<BusModel> getBuses() => List.unmodifiable(_buses);

  @override
  BusModel getBusById(String id) {
    return _buses.firstWhere((b) => b.id == id, orElse: () => _buses.first);
  }

  @override
  Stream<BusModel> getBusStream(String busId) {
    return _busStreamController.stream.map((buses) {
      return buses.firstWhere((b) => b.id == busId, orElse: () => _buses.first);
    });
  }

  @override
  Stream<List<BusModel>> getAllBusesStream() {
    return _busStreamController.stream;
  }

  @override
  Stream<List<AdminUpdateModel>> getAdminUpdatesStream() {
    return _adminUpdatesController.stream;
  }

  @override
  Future<void> toggleFavoriteStop(String routeId, String stopId) async {
    final routeIdx = _routes.indexWhere((r) => r.id == routeId);
    if (routeIdx == -1) return;
    final route = _routes[routeIdx];
    final updatedStops = route.stops.map((s) {
      if (s.id == stopId) {
        return s.copyWith(isFavorite: !s.isFavorite);
      }
      return s;
    }).toList();
    _routes[routeIdx] = RouteModel(
      id: route.id,
      name: route.name,
      nameBn: route.nameBn,
      origin: route.origin,
      destination: route.destination,
      stops: updatedStops,
    );
  }

  @override
  Future<void> setArrivalAlert(String routeId, String stopId, int leadMinutes) async {
    await Future.delayed(const Duration(milliseconds: 300));
  }

  @override
  void dispose() {
    _telemetryTimer?.cancel();
    _busStreamController.close();
    _adminUpdatesController.close();
  }
}

final busRepositoryProvider = Provider<BusRepository>((ref) {
  final repo = InMemoryBusRepository();
  ref.onDispose(repo.dispose);
  return repo;
});

final selectedRouteIdProvider = StateProvider<String>((ref) => 'route_mirpur');

final allBusesProvider = StreamProvider<List<BusModel>>((ref) {
  final repo = ref.watch(busRepositoryProvider);
  return repo.getAllBusesStream();
});

final currentBusProvider = StreamProvider<BusModel>((ref) {
  final repo = ref.watch(busRepositoryProvider);
  return repo.getBusStream('bus_1');
});

final adminUpdatesProvider = Provider<List<AdminUpdateModel>>((ref) {
  return MockAdminUpdates.initialUpdates;
});
