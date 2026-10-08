import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/config/map_config.dart';
import '../../../../ui/core/theme.dart';
import '../../data/models/live_bus_location.dart';
import '../widgets/animated_bus_marker.dart';
import '../widgets/bus_marker_view.dart';

/// Real geographic map widget configured via [MapConfig].
/// Keeps map tiles and controller isolated from live location stream rebuilds.
///
/// Ensures:
/// - Controller is never recreated on GPS updates
/// - Tiles are not reloaded on position changes
/// - Only the bus marker position and rotation interpolate smoothly
class PadmaLiveMapWidget extends StatefulWidget {
  final LiveBusLocation? liveLocation;
  final List<LatLng>? routePolyline;
  final MapController? mapController;
  final bool isLive;

  const PadmaLiveMapWidget({
    super.key,
    required this.liveLocation,
    this.routePolyline,
    this.mapController,
    this.isLive = true,
  });

  @override
  State<PadmaLiveMapWidget> createState() => _PadmaLiveMapWidgetState();
}

class _PadmaLiveMapWidgetState extends State<PadmaLiveMapWidget> {
  late final MapController _mapController;
  bool _internalController = false;

  @override
  void initState() {
    super.initState();
    if (widget.mapController != null) {
      _mapController = widget.mapController!;
    } else {
      _mapController = MapController();
      _internalController = true;
    }
  }

  @override
  void dispose() {
    if (_internalController) {
      _mapController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tileProvider = MapConfig.defaultTileProvider;
    const fallbackUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
    final urlTemplate = tileProvider.rasterTileUrl ?? fallbackUrl;

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: widget.liveLocation?.latLng ?? MapConfig.austCampusLocation,
        initialZoom: MapConfig.defaultZoom,
        minZoom: MapConfig.minZoom,
        maxZoom: MapConfig.maxZoom,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all,
        ),
      ),
      children: [
        // 1. Isolated Tile Layer from MapConfig
        TileLayer(
          urlTemplate: urlTemplate,
          userAgentPackageName: 'com.padma.transit',
          tileBuilder: (context, tileWidget, tile) {
            // Dark mode color grading filter for map tiles
            return ColorFiltered(
              colorFilter: const ColorFilter.matrix(<double>[
                0.85, 0,    0,    0, -25,
                0,    0.85, 0,    0, -25,
                0,    0,    0.85, 0, -25,
                0,    0,    0,    1,   0,
              ]),
              child: tileWidget,
            );
          },
        ),

        // 2. Transit Corridor Route Polyline (if provided)
        if (widget.routePolyline != null && widget.routePolyline!.isNotEmpty)
          PolylineLayer(
            polylines: [
              // Outer route glow
              Polyline(
                points: widget.routePolyline!,
                color: PadmaTheme.primaryTeal.withValues(alpha: 0.35),
                strokeWidth: 6.0,
                strokeCap: StrokeCap.round,
                strokeJoin: StrokeJoin.round,
              ),
              // Inner sharp route line
              Polyline(
                points: widget.routePolyline!,
                color: PadmaTheme.primaryTeal,
                strokeWidth: 3.2,
                strokeCap: StrokeCap.round,
                strokeJoin: StrokeJoin.round,
              ),
            ],
          ),

        // 3. Smooth Animated Live Bus Marker
        if (widget.liveLocation != null)
          AnimatedBusMarker(
            targetLocation: widget.liveLocation,
            builder: (context, currentPos, currentHeading, currentSpeed, isLive) {
              return MarkerLayer(
                markers: [
                  Marker(
                    point: currentPos,
                    width: 72,
                    height: 72,
                    alignment: Alignment.center,
                    child: BusMarkerView(
                      heading: currentHeading,
                      speed: currentSpeed,
                      isLive: isLive && widget.isLive,
                    ),
                  ),
                ],
              );
            },
          ),
      ],
    );
  }
}
