import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/bus_model.dart';
import '../models/route_model.dart';
import '../models/stop_model.dart';
import '../models/admin_update_model.dart';
import '../mock/mock_routes.dart';
import '../mock/mock_buses.dart';
import '../mock/mock_admin_updates.dart';
import 'bus_repository.dart';
import '../services/supabase_service.dart';

/// Dynamic Supabase-backed implementation of [BusRepository].
/// Reads routes, stops, and fleet info from Supabase PostgreSQL tables and
/// subscribes to Supabase Realtime for live bus telemetry updates.
class SupabaseBusRepository implements BusRepository {
  final SupabaseClient _client;

  List<RouteModel> _routes = List.from(MockRoutes.allRoutes);
  List<BusModel> _buses = List.from(MockBuses.allBuses);
  List<AdminUpdateModel> _adminUpdates = List.from(MockAdminUpdates.initialUpdates);

  final _busStreamController = StreamController<List<BusModel>>.broadcast();
  final _adminUpdatesController = StreamController<List<AdminUpdateModel>>.broadcast();

  StreamSubscription<List<Map<String, dynamic>>>? _busLocationsSub;
  StreamSubscription<List<Map<String, dynamic>>>? _announcementsSub;

  SupabaseBusRepository({SupabaseClient? client})
      : _client = client ?? SupabaseService.instance.client {
    _initDataAndSubscriptions();
  }

  Future<void> _initDataAndSubscriptions() async {
    // 1. Initial Load from Supabase Database
    await _fetchRoutesAndStops();
    await _fetchBuses();
    await _fetchAdminUpdates();

    // 2. Realtime Subscription on Live Bus Locations
    try {
      _busLocationsSub = _client
          .from('live_bus_locations')
          .stream(primaryKey: ['bus_id'])
          .listen((records) {
        for (final r in records) {
          final busId = r['bus_id']?.toString();
          if (busId == null) continue;

          final idx = _buses.indexWhere((b) => b.id == busId);
          final lat = (r['latitude'] as num?)?.toDouble() ?? 23.7639;
          final lng = (r['longitude'] as num?)?.toDouble() ?? 90.4070;
          final speed = (r['speed_kmh'] as num?)?.toInt() ?? 0;
          final nextStop = r['next_stop_name']?.toString() ?? 'AUST Campus';
          final nextStopBn = r['next_stop_name_bn']?.toString() ?? 'আহছানউল্লা ক্যাম্পাস';
          final eta = (r['eta_minutes'] as num?)?.toInt() ?? 0;
          final progress = (r['distance_progress'] as num?)?.toDouble() ?? 0.0;
          final statusStr = r['status']?.toString() ?? 'onTime';
          final updatedAt = r['updated_at'] != null
              ? DateTime.tryParse(r['updated_at'].toString()) ?? DateTime.now()
              : DateTime.now();

          BusStatus status = BusStatus.onTime;
          if (statusStr == 'delayed') status = BusStatus.delayed;
          if (statusStr == 'waiting') status = BusStatus.waiting;
          if (statusStr == 'breakdown') status = BusStatus.breakdown;
          if (statusStr == 'tripEnded') status = BusStatus.tripEnded;

          if (idx != -1) {
            _buses[idx] = _buses[idx].copyWith(
              currentLat: lat,
              currentLng: lng,
              speedKmH: speed,
              nextStopName: nextStop,
              nextStopNameBn: nextStopBn,
              etaMinutes: eta,
              distanceProgress: progress,
              status: status,
              updatedAt: updatedAt,
            );
          }
        }
        if (!_busStreamController.isClosed) {
          _busStreamController.add(List.unmodifiable(_buses));
        }
      }, onError: (err) {
        debugPrint('[SupabaseBusRepository] Telemetry sub error: $err');
      });

      // 3. Realtime Subscription on Admin Announcements
      _announcementsSub = _client
          .from('admin_announcements')
          .stream(primaryKey: ['id'])
          .listen((records) {
        final List<AdminUpdateModel> updates = records.map((r) {
          final isUrgent = (r['priority']?.toString().toLowerCase() == 'urgent') || r['is_urgent'] == true;

          return AdminUpdateModel(
            id: r['id']?.toString() ?? '',
            authorName: r['author_name']?.toString() ?? 'Transport Admin',
            text: r['body']?.toString() ?? r['text']?.toString() ?? '',
            busId: r['bus_id']?.toString(),
            busName: r['target_route']?.toString(),
            isPinned: r['is_pinned'] == true,
            isUrgent: isUrgent,
            createdAt: r['created_at'] != null
                ? DateTime.tryParse(r['created_at'].toString()) ?? DateTime.now()
                : DateTime.now(),
          );
        }).toList();

        if (updates.isNotEmpty) {
          _adminUpdates = updates;
          if (!_adminUpdatesController.isClosed) {
            _adminUpdatesController.add(List.unmodifiable(_adminUpdates));
          }
        }
      }, onError: (err) {
        debugPrint('[SupabaseBusRepository] Announcements sub error: $err');
      });
    } catch (e) {
      debugPrint('[SupabaseBusRepository] Realtime init exception: $e');
    }
  }

  Future<void> _fetchRoutesAndStops() async {
    try {
      final routesData = await _client.from('routes').select().eq('is_active', true);
      final stopsData = await _client.from('route_stops').select().order('stop_order', ascending: true);

      if (routesData.isNotEmpty) {
        final List<RouteModel> fetchedRoutes = [];
        for (final r in routesData) {
          final routeId = r['id'].toString();
          final routeStops = stopsData
              .where((s) => s['route_id'].toString() == routeId)
              .map((s) => StopModel(
                    id: s['id'].toString(),
                    name: s['name'].toString(),
                    nameBn: s['name_bn']?.toString() ?? s['name'].toString(),
                    lat: (s['lat'] as num).toDouble(),
                    lng: (s['lng'] as num).toDouble(),
                    order: (s['stop_order'] as num).toInt(),
                    scheduledTime: s['scheduled_time']?.toString() ?? s['estimated_time']?.toString() ?? '07:30 AM',
                    isFavorite: s['is_favorite'] == true,
                  ))
              .toList();

          fetchedRoutes.add(RouteModel(
            id: routeId,
            name: r['name'].toString(),
            nameBn: r['name_bn'].toString(),
            origin: r['origin'].toString(),
            destination: r['destination'].toString(),
            stops: routeStops,
          ));
        }
        _routes = fetchedRoutes;
      }
    } catch (e) {
      debugPrint('[SupabaseBusRepository] Error fetching routes: $e');
    }
  }

  Future<void> _fetchBuses() async {
    try {
      final busesData = await _client.from('buses').select();
      final liveData = await _client.from('live_bus_locations').select();

      if (busesData.isNotEmpty) {
        final List<BusModel> fetchedBuses = [];
        for (final b in busesData) {
          final busId = b['id'].toString();
          final live = liveData.firstWhere(
            (l) => l['bus_id'].toString() == busId,
            orElse: () => <String, dynamic>{},
          );

          final route = _routes.firstWhere(
            (r) => r.id == b['route_id']?.toString(),
            orElse: () => _routes.first,
          );

          final lat = (live['latitude'] as num?)?.toDouble() ?? 23.7639;
          final lng = (live['longitude'] as num?)?.toDouble() ?? 90.4070;
          final speed = (live['speed_kmh'] as num?)?.toInt() ?? 0;
          final nextStop = live['next_stop_name']?.toString() ?? 'AUST Campus';
          final nextStopBn = live['next_stop_name_bn']?.toString() ?? 'আহছানউল্লা ক্যাম্পাস';
          final eta = (live['eta_minutes'] as num?)?.toInt() ?? 0;
          final progress = (live['distance_progress'] as num?)?.toDouble() ?? 0.0;

          fetchedBuses.add(BusModel(
            id: busId,
            name: b['title'].toString(),
            nameBn: b['title'].toString(),
            plateNumber: b['bus_number'].toString(),
            routeId: b['route_id'].toString(),
            routeName: route.name,
            driverName: b['driver_name'].toString(),
            driverPhone: b['driver_phone'].toString(),
            status: BusStatus.onTime,
            occupancy: BusOccupancy.medium,
            currentLat: lat,
            currentLng: lng,
            speedKmH: speed,
            nextStopName: nextStop,
            nextStopNameBn: nextStopBn,
            etaMinutes: eta,
            distanceProgress: progress,
            updatedAt: DateTime.now(),
          ));
        }
        _buses = fetchedBuses;
        if (!_busStreamController.isClosed) {
          _busStreamController.add(List.unmodifiable(_buses));
        }
      }
    } catch (e) {
      debugPrint('[SupabaseBusRepository] Error fetching buses: $e');
    }
  }

  Future<void> _fetchAdminUpdates() async {
    try {
      final updates = await _client.from('admin_announcements').select().order('created_at', ascending: false);
      if (updates.isNotEmpty) {
        _adminUpdates = updates.map((r) {
          final isUrgent = (r['priority']?.toString().toLowerCase() == 'urgent') || r['is_urgent'] == true;

          return AdminUpdateModel(
            id: r['id']?.toString() ?? '',
            authorName: r['author_name']?.toString() ?? 'Transport Admin',
            text: r['body']?.toString() ?? r['text']?.toString() ?? '',
            busId: r['bus_id']?.toString(),
            busName: r['target_route']?.toString(),
            isPinned: r['is_pinned'] == true,
            isUrgent: isUrgent,
            createdAt: r['created_at'] != null
                ? DateTime.tryParse(r['created_at'].toString()) ?? DateTime.now()
                : DateTime.now(),
          );
        }).toList();

        if (!_adminUpdatesController.isClosed) {
          _adminUpdatesController.add(List.unmodifiable(_adminUpdates));
        }
      }
    } catch (e) {
      debugPrint('[SupabaseBusRepository] Error fetching admin updates: $e');
    }
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
        final newFav = !s.isFavorite;
        // Update in Supabase
        _client.from('route_stops').update({'is_favorite': newFav}).eq('id', stopId).then((_) {}, onError: (_) {});
        return s.copyWith(isFavorite: newFav);
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
    // Record alert preference
    try {
      await _client.from('notifications').insert({
        'id': 'alert_${DateTime.now().millisecondsSinceEpoch}',
        'title': 'Arrival Alert Configured',
        'title_bn': 'আগমন সতর্কতা সক্রিয়',
        'body': 'You will be alerted $leadMinutes minutes before bus arrives at stop $stopId.',
        'body_bn': 'স্টপেজে বাস পৌঁছানোর $leadMinutes মিনিট আগে সতর্কতা দেওয়া হবে।',
        'type': 'transit',
        'is_read': false,
        'data': {'route_id': routeId, 'stop_id': stopId, 'lead_minutes': leadMinutes},
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('[SupabaseBusRepository] setArrivalAlert error: $e');
    }
  }

  @override
  void dispose() {
    _busLocationsSub?.cancel();
    _announcementsSub?.cancel();
    _busStreamController.close();
    _adminUpdatesController.close();
  }
}
