enum BusStatus {
  onTime,
  waiting,
  delayed,
  breakdown,
  tripEnded;

  String get label {
    switch (this) {
      case BusStatus.onTime:
        return 'On time';
      case BusStatus.waiting:
        return 'Waiting';
      case BusStatus.delayed:
        return 'Delayed';
      case BusStatus.breakdown:
        return 'Breakdown';
      case BusStatus.tripEnded:
        return 'Trip ended';
    }
  }

  String get labelBn {
    switch (this) {
      case BusStatus.onTime:
        return 'সময়মতো';
      case BusStatus.waiting:
        return 'অপেক্ষমাণ';
      case BusStatus.delayed:
        return 'বিলম্বিত';
      case BusStatus.breakdown:
        return 'যান্ত্রিক ত্রুটি';
      case BusStatus.tripEnded:
        return 'যাত্রা সমাপ্ত';
    }
  }
}

enum BusOccupancy {
  low,
  medium,
  crowded;

  String get label {
    switch (this) {
      case BusOccupancy.low:
        return 'Seats Available';
      case BusOccupancy.medium:
        return 'Moderate';
      case BusOccupancy.crowded:
        return 'Standing Only';
    }
  }
}

class BusModel {
  final String id;
  final String name;
  final String nameBn;
  final String plateNumber;
  final String routeId;
  final String routeName;
  final String driverName;
  final String driverPhone;
  final BusStatus status;
  final BusOccupancy occupancy;
  final double currentLat;
  final double currentLng;
  final int speedKmH;
  final String nextStopName;
  final String nextStopNameBn;
  final int etaMinutes;
  final double distanceProgress; // 0.0 to 1.0
  final DateTime updatedAt;

  const BusModel({
    required this.id,
    required this.name,
    required this.nameBn,
    required this.plateNumber,
    required this.routeId,
    required this.routeName,
    required this.driverName,
    required this.driverPhone,
    required this.status,
    required this.occupancy,
    required this.currentLat,
    required this.currentLng,
    required this.speedKmH,
    required this.nextStopName,
    required this.nextStopNameBn,
    required this.etaMinutes,
    required this.distanceProgress,
    required this.updatedAt,
  });

  BusModel copyWith({
    String? id,
    String? name,
    String? nameBn,
    String? plateNumber,
    String? routeId,
    String? routeName,
    String? driverName,
    String? driverPhone,
    BusStatus? status,
    BusOccupancy? occupancy,
    double? currentLat,
    double? currentLng,
    int? speedKmH,
    String? nextStopName,
    String? nextStopNameBn,
    int? etaMinutes,
    double? distanceProgress,
    DateTime? updatedAt,
  }) {
    return BusModel(
      id: id ?? this.id,
      name: name ?? this.name,
      nameBn: nameBn ?? this.nameBn,
      plateNumber: plateNumber ?? this.plateNumber,
      routeId: routeId ?? this.routeId,
      routeName: routeName ?? this.routeName,
      driverName: driverName ?? this.driverName,
      driverPhone: driverPhone ?? this.driverPhone,
      status: status ?? this.status,
      occupancy: occupancy ?? this.occupancy,
      currentLat: currentLat ?? this.currentLat,
      currentLng: currentLng ?? this.currentLng,
      speedKmH: speedKmH ?? this.speedKmH,
      nextStopName: nextStopName ?? this.nextStopName,
      nextStopNameBn: nextStopNameBn ?? this.nextStopNameBn,
      etaMinutes: etaMinutes ?? this.etaMinutes,
      distanceProgress: distanceProgress ?? this.distanceProgress,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
