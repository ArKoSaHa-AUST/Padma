import 'stop_model.dart';

class RouteModel {
  final String id;
  final String name;
  final String nameBn;
  final String origin;
  final String destination;
  final List<StopModel> stops;

  const RouteModel({
    required this.id,
    required this.name,
    required this.nameBn,
    required this.origin,
    required this.destination,
    required this.stops,
  });
}
