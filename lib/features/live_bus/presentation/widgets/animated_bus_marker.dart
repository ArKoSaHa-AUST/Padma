import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/utils/geo_utils.dart';
import '../../data/models/live_bus_location.dart';
import 'bus_marker_view.dart';

/// Reusable animated bus marker widget that smoothly transitions coordinates and heading.
///
/// Features:
/// - Smooth latitude / longitude linear interpolation with easeInOut curve
/// - Shortest-path angular heading interpolation (prevents 360° flip glitch)
/// - Gracefully cancels and redirects in-flight animations when new coordinates arrive
/// - Lifecycle and memory safe with auto-disposal
class AnimatedBusMarker extends StatefulWidget {
  final LiveBusLocation? targetLocation;
  final Duration animationDuration;
  final Widget Function(BuildContext context, LatLng position, double heading, double speed, bool isLive)? builder;

  const AnimatedBusMarker({
    super.key,
    required this.targetLocation,
    this.animationDuration = const Duration(milliseconds: 2500),
    this.builder,
  });

  @override
  State<AnimatedBusMarker> createState() => _AnimatedBusMarkerState();
}

class _AnimatedBusMarkerState extends State<AnimatedBusMarker>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _curveAnimation;

  LatLng _startPosition = const LatLng(23.7639, 90.4070);
  LatLng _targetPosition = const LatLng(23.7639, 90.4070);
  LatLng _currentAnimatedPosition = const LatLng(23.7639, 90.4070);

  double _startHeading = 0.0;
  double _targetHeading = 0.0;
  double _currentAnimatedHeading = 0.0;

  double _currentSpeed = 0.0;
  bool _isLive = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );

    _curveAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOutCubic,
    );

    _animController.addListener(_onAnimationTick);

    if (widget.targetLocation != null) {
      _applyInitialLocation(widget.targetLocation!);
    }
  }

  void _applyInitialLocation(LiveBusLocation loc) {
    if (!loc.isValid) return;
    final pos = loc.latLng;
    final heading = GeoUtils.normalizeHeading(loc.heading);

    _startPosition = pos;
    _targetPosition = pos;
    _currentAnimatedPosition = pos;

    _startHeading = heading;
    _targetHeading = heading;
    _currentAnimatedHeading = heading;

    _currentSpeed = loc.speed;
    _isLive = loc.isSharing;
  }

  @override
  void didUpdateWidget(covariant AnimatedBusMarker oldWidget) {
    super.didUpdateWidget(oldWidget);

    final newLoc = widget.targetLocation;
    if (newLoc == null || !newLoc.isValid) return;

    final newPos = newLoc.latLng;
    final newHeading = GeoUtils.normalizeHeading(newLoc.heading);

    _currentSpeed = newLoc.speed;
    _isLive = newLoc.isSharing;

    // Check if target position or heading changed
    if (newPos != _targetPosition || newHeading != _targetHeading) {
      // Gracefully capture current animated progress as new start point
      _startPosition = _currentAnimatedPosition;
      _targetPosition = newPos;

      _startHeading = _currentAnimatedHeading;
      _targetHeading = newHeading;

      // Restart animation towards newest target
      _animController.stop();
      _animController.reset();
      _animController.forward();
    }
  }

  void _onAnimationTick() {
    final t = _curveAnimation.value;
    setState(() {
      _currentAnimatedPosition = GeoUtils.interpolateCoordinate(
        _startPosition,
        _targetPosition,
        t,
      );

      _currentAnimatedHeading = GeoUtils.interpolateBearing(
        _startHeading,
        _targetHeading,
        t,
      );
    });
  }

  @override
  void dispose() {
    _animController.removeListener(_onAnimationTick);
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.builder != null) {
      return widget.builder!(
        context,
        _currentAnimatedPosition,
        _currentAnimatedHeading,
        _currentSpeed,
        _isLive,
      );
    }

    return BusMarkerView(
      heading: _currentAnimatedHeading,
      speed: _currentSpeed,
      isLive: _isLive,
    );
  }
}
