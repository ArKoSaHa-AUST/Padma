import 'bus_model.dart';

class BusRouteCheckpoint {
  final String name;
  final double lat;
  final double lng;
  final String eta;
  final bool isCompleted;
  final bool isCurrent;

  const BusRouteCheckpoint({
    required this.name,
    required this.lat,
    required this.lng,
    required this.eta,
    this.isCompleted = false,
    this.isCurrent = false,
  });

  BusRouteCheckpoint copyWith({
    String? name,
    double? lat,
    double? lng,
    String? eta,
    bool? isCompleted,
    bool? isCurrent,
  }) {
    return BusRouteCheckpoint(
      name: name ?? this.name,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      eta: eta ?? this.eta,
      isCompleted: isCompleted ?? this.isCompleted,
      isCurrent: isCurrent ?? this.isCurrent,
    );
  }
}

class BusRouteInfo {
  final String id;
  final String title;
  final String startLocation;
  final String destination;
  final String currentStop;
  final String nextStop;
  final int etaMinutes;
  final int speedKmh;
  final double latitude;
  final double longitude;
  final String driverName;
  final String driverPhone;
  final String busNumber;
  final BusStatus status;
  final bool isBroadcastingGps;
  final List<BusRouteCheckpoint> checkpoints;

  const BusRouteInfo({
    required this.id,
    required this.title,
    required this.startLocation,
    required this.destination,
    required this.currentStop,
    required this.nextStop,
    required this.etaMinutes,
    required this.speedKmh,
    required this.latitude,
    required this.longitude,
    required this.driverName,
    this.driverPhone = '+880 1711-234567',
    required this.busNumber,
    this.status = BusStatus.tripEnded,
    this.isBroadcastingGps = false,
    required this.checkpoints,
  });

  bool get isTripEnded => status == BusStatus.tripEnded;

  BusRouteInfo copyWith({
    String? id,
    String? title,
    String? startLocation,
    String? destination,
    String? currentStop,
    String? nextStop,
    int? etaMinutes,
    int? speedKmh,
    double? latitude,
    double? longitude,
    String? driverName,
    String? driverPhone,
    String? busNumber,
    BusStatus? status,
    bool? isBroadcastingGps,
    List<BusRouteCheckpoint>? checkpoints,
  }) {
    return BusRouteInfo(
      id: id ?? this.id,
      title: title ?? this.title,
      startLocation: startLocation ?? this.startLocation,
      destination: destination ?? this.destination,
      currentStop: currentStop ?? this.currentStop,
      nextStop: nextStop ?? this.nextStop,
      etaMinutes: etaMinutes ?? this.etaMinutes,
      speedKmh: speedKmh ?? this.speedKmh,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      driverName: driverName ?? this.driverName,
      driverPhone: driverPhone ?? this.driverPhone,
      busNumber: busNumber ?? this.busNumber,
      status: status ?? this.status,
      isBroadcastingGps: isBroadcastingGps ?? this.isBroadcastingGps,
      checkpoints: checkpoints ?? this.checkpoints,
    );
  }
}

