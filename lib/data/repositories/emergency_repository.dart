import '../models/emergency_request.dart';
import '../services/mock_data_service.dart';

class EmergencyRepository {
  List<EmergencyRequest> getAllRequests() => MockDataService.getEmergencyRequests();
}
