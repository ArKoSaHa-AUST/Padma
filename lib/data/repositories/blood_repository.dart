import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/blood_request_model.dart';
import '../mock/mock_blood_requests.dart';

abstract class BloodRepository {
  Stream<List<BloodRequestModel>> getRequestsStream();
  Future<void> createRequest({
    required String requesterId,
    required String requesterName,
    required String requesterPhone,
    required String bloodGroup,
    required int units,
    required String hospital,
    required String location,
    required DateTime neededBy,
    required BloodUrgency urgency,
    String? notes,
  });
  Future<void> volunteerAsDonor(String requestId, String donorUserId);
  void dispose();
}

class InMemoryBloodRepository implements BloodRepository {
  final List<BloodRequestModel> _requests = List.from(MockBloodRequests.initialRequests);
  final _controller = StreamController<List<BloodRequestModel>>.broadcast();

  InMemoryBloodRepository() {
    _emit();
  }

  void _emit() {
    if (!_controller.isClosed) {
      _controller.add(List.unmodifiable(_requests));
    }
  }

  @override
  Stream<List<BloodRequestModel>> getRequestsStream() {
    Future.microtask(_emit);
    return _controller.stream;
  }

  @override
  Future<void> createRequest({
    required String requesterId,
    required String requesterName,
    required String requesterPhone,
    required String bloodGroup,
    required int units,
    required String hospital,
    required String location,
    required DateTime neededBy,
    required BloodUrgency urgency,
    String? notes,
  }) async {
    final newReq = BloodRequestModel(
      id: 'br_${DateTime.now().millisecondsSinceEpoch}',
      requesterId: requesterId,
      requesterName: requesterName,
      requesterPhone: requesterPhone,
      bloodGroup: bloodGroup,
      units: units,
      hospital: hospital,
      location: location,
      neededBy: neededBy,
      urgency: urgency,
      notes: notes,
      status: BloodRequestStatus.active,
      createdAt: DateTime.now(),
    );
    _requests.insert(0, newReq);
    _emit();
  }

  @override
  Future<void> volunteerAsDonor(String requestId, String donorUserId) async {
    final idx = _requests.indexWhere((r) => r.id == requestId);
    if (idx == -1) return;
    final req = _requests[idx];
    final donors = List<String>.from(req.donorUserIds);
    if (!donors.contains(donorUserId)) {
      donors.add(donorUserId);
      _requests[idx] = req.copyWith(donorUserIds: donors);
      _emit();
    }
  }

  @override
  void dispose() {
    _controller.close();
  }
}

final bloodRepositoryProvider = Provider<BloodRepository>((ref) {
  final repo = InMemoryBloodRepository();
  ref.onDispose(repo.dispose);
  return repo;
});

final selectedBloodGroupFilterProvider = StateProvider<String?>((ref) => null);

final bloodRequestsProvider = StreamProvider<List<BloodRequestModel>>((ref) {
  final repo = ref.watch(bloodRepositoryProvider);
  final filter = ref.watch(selectedBloodGroupFilterProvider);
  return repo.getRequestsStream().map((list) {
    if (filter == null || filter.isEmpty || filter == 'All') {
      return list;
    }
    return list.where((r) => r.bloodGroup == filter).toList();
  });
});
