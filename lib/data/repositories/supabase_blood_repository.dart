import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/blood_request_model.dart';
import '../mock/mock_blood_requests.dart';
import 'blood_repository.dart';
import '../services/supabase_service.dart';

/// Dynamic Supabase-backed implementation of [BloodRepository].
/// Real-time stream of campus blood requests and active volunteer donor registrations.
class SupabaseBloodRepository implements BloodRepository {
  final SupabaseClient _client;

  List<BloodRequestModel> _requests = List.from(MockBloodRequests.initialRequests);
  final _controller = StreamController<List<BloodRequestModel>>.broadcast();
  StreamSubscription<List<Map<String, dynamic>>>? _subscription;

  SupabaseBloodRepository({SupabaseClient? client})
      : _client = client ?? SupabaseService.instance.client {
    _initRealtimeStream();
  }

  void _initRealtimeStream() {
    try {
      _subscription = _client
          .from('blood_requests')
          .stream(primaryKey: ['id'])
          .order('created_at', ascending: false)
          .listen((records) {
        final List<BloodRequestModel> list = records.map((r) {
          final urgencyStr = r['urgency']?.toString() ?? 'standard';
          BloodUrgency urgency = BloodUrgency.standard;
          if (urgencyStr == 'urgent') urgency = BloodUrgency.urgent;
          if (urgencyStr == 'critical') urgency = BloodUrgency.critical;

          final statusStr = r['status']?.toString() ?? 'active';
          BloodRequestStatus status = BloodRequestStatus.active;
          if (statusStr == 'fulfilled') status = BloodRequestStatus.fulfilled;
          if (statusStr == 'expired' || statusStr == 'cancelled') status = BloodRequestStatus.expired;

          final rawDonors = r['donor_user_ids'];
          List<String> donors = [];
          if (rawDonors is List) {
            donors = rawDonors.map((e) => e.toString()).toList();
          }

          return BloodRequestModel(
            id: r['id']?.toString() ?? '',
            requesterId: r['requester_id']?.toString() ?? '',
            requesterName: r['requester_name']?.toString() ?? '',
            requesterPhone: r['requester_phone']?.toString() ?? '',
            bloodGroup: r['blood_group']?.toString() ?? 'A+',
            units: (r['units'] as num?)?.toInt() ?? 1,
            hospital: r['hospital']?.toString() ?? '',
            location: r['location']?.toString() ?? '',
            neededBy: r['needed_by'] != null
                ? DateTime.tryParse(r['needed_by'].toString()) ?? DateTime.now()
                : DateTime.now(),
            urgency: urgency,
            notes: r['notes']?.toString(),
            status: status,
            donorUserIds: donors,
            createdAt: r['created_at'] != null
                ? DateTime.tryParse(r['created_at'].toString()) ?? DateTime.now()
                : DateTime.now(),
          );
        }).toList();

        if (list.isNotEmpty) {
          _requests = list;
        }

        _emit();
      }, onError: (err) {
        debugPrint('[SupabaseBloodRepository] Stream error: $err');
      });
    } catch (e) {
      debugPrint('[SupabaseBloodRepository] Init stream exception: $e');
    }
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
    final reqId = 'br_${DateTime.now().millisecondsSinceEpoch}';
    final newReq = BloodRequestModel(
      id: reqId,
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

    try {
      await _client.from('blood_requests').insert({
        'id': reqId,
        'requester_id': requesterId,
        'requester_name': requesterName,
        'requester_phone': requesterPhone,
        'blood_group': bloodGroup,
        'units': units,
        'hospital': hospital,
        'location': location,
        'needed_by': neededBy.toIso8601String(),
        'urgency': urgency.name,
        'status': 'active',
        'notes': notes,
        'donor_user_ids': [],
        'created_at': DateTime.now().toIso8601String(),
      });

      // Post notification to emergency channel & notifications table
      await _client.from('messages').insert({
        'id': 'msg_$reqId',
        'channel_id': 'emergency-blood',
        'sender_id': requesterId,
        'sender_name': requesterName,
        'sender_role': 'student',
        'badge_text': 'URGENT $bloodGroup',
        'text': '🔴 **URGENT**: Need $units Bag(s) of $bloodGroup Blood at $hospital ($location). Contact: $requesterPhone.',
        'is_urgent': true,
        'is_pinned': true,
        'reactions': {'🩸': 1},
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('[SupabaseBloodRepository] Error inserting blood request: $e');
    }
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

      try {
        await _client.from('blood_requests').update({
          'donor_user_ids': donors,
        }).eq('id', requestId);
      } catch (e) {
        debugPrint('[SupabaseBloodRepository] Error updating donors: $e');
      }
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _controller.close();
  }
}
