import '../models/bus_route.dart';
import '../services/mock_data_service.dart';

class TransitRepository {
  List<BusRouteInfo> getAvailableRoutes() {
    return MockDataService.availableRoutes;
  }

  BusRouteInfo? getRouteById(String id) {
    try {
      return MockDataService.availableRoutes.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }
}
