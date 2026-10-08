import '../models/bus_model.dart';

class MockBuses {
  static BusModel bus1Mirpur = BusModel(
    id: 'bus_1',
    name: 'Bus 1 • Mirpur',
    nameBn: 'বাস ১ • মিরপুর',
    plateNumber: 'Dhaka Metro-Cha 11-4092',
    routeId: 'route_mirpur',
    routeName: 'Mirpur 12 ⇄ AUST Campus',
    driverName: 'Md. Rafiqul Islam',
    driverPhone: '+880 1712-345678',
    status: BusStatus.onTime,
    occupancy: BusOccupancy.medium,
    currentLat: 23.8010,
    currentLng: 90.3705,
    speedKmH: 34,
    nextStopName: 'Kazipara',
    nextStopNameBn: 'কাজী Graphs',
    etaMinutes: 2,
    distanceProgress: 0.42,
    updatedAt: DateTime.now().subtract(const Duration(seconds: 4)),
  );

  static BusModel bus2Uttara = BusModel(
    id: 'bus_2',
    name: 'Bus 2 • Uttara',
    nameBn: 'বাস ২ • উত্তরা',
    plateNumber: 'Dhaka Metro-Cha 14-8831',
    routeId: 'route_uttara',
    routeName: 'Uttara House Building ⇄ AUST Campus',
    driverName: 'Anwar Hossain',
    driverPhone: '+880 1819-876543',
    status: BusStatus.waiting,
    occupancy: BusOccupancy.low,
    currentLat: 23.8515,
    currentLng: 90.4078,
    speedKmH: 0,
    nextStopName: 'Khilkhet',
    nextStopNameBn: 'খিলক্ষেত',
    etaMinutes: 10,
    distanceProgress: 0.35,
    updatedAt: DateTime.now().subtract(const Duration(seconds: 12)),
  );

  static BusModel bus3Mohammadpur = BusModel(
    id: 'bus_3',
    name: 'Bus 3 • Mohammadpur',
    nameBn: 'বাস ৩ • মোহাম্মদপুর',
    plateNumber: 'Dhaka Metro-Cha 15-2019',
    routeId: 'route_mohammadpur',
    routeName: 'Mohammadpur ⇄ AUST Campus',
    driverName: 'Mokhlesur Rahman',
    driverPhone: '+880 1911-554433',
    status: BusStatus.delayed,
    occupancy: BusOccupancy.crowded,
    currentLat: 23.7588,
    currentLng: 90.3892,
    speedKmH: 14,
    nextStopName: 'Karwan Bazar',
    nextStopNameBn: 'কারওয়ান বাজার',
    etaMinutes: 8,
    distanceProgress: 0.60,
    updatedAt: DateTime.now().subtract(const Duration(seconds: 8)),
  );

  static List<BusModel> get allBuses => [
        bus1Mirpur,
        bus2Uttara,
        bus3Mohammadpur,
      ];
}
