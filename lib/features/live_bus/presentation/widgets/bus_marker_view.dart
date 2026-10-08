import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../ui/core/theme.dart';
import '../../../../core/utils/geo_utils.dart';

/// Visually rich bus marker widget for MapLibre & FlutterMap.
/// Displays a stylized transit bus, directional rotation arrow, speed badge, and pulsing radar halo.
class BusMarkerView extends StatefulWidget {
  final double heading; // 0.0 to 360.0
  final double speed; // km/h
  final bool isLive;
  final String busLabel;

  const BusMarkerView({
    super.key,
    required this.heading,
    required this.speed,
    this.isLive = true,
    this.busLabel = 'BUS 01',
  });

  @override
  State<BusMarkerView> createState() => _BusMarkerViewState();
}

class _BusMarkerViewState extends State<BusMarkerView>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _pulseAnimation = Tween<double>(begin: 0.8, end: 2.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
    );

    if (widget.isLive) {
      _pulseController.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant BusMarkerView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLive != oldWidget.isLive) {
      if (widget.isLive) {
        _pulseController.repeat();
      } else {
        _pulseController.stop();
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final validHeading = GeoUtils.normalizeHeading(widget.heading);
    final headingRadians = validHeading * (math.pi / 180.0);

    return SizedBox(
      width: 72,
      height: 72,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // 1. Radar Pulse Halo (only when live)
          if (widget.isLive)
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                final scale = _pulseAnimation.value;
                final opacity = (1.0 - (scale - 0.8) / 1.4).clamp(0.0, 0.45);
                return Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: PadmaTheme.busAmber.withValues(alpha: opacity),
                    ),
                  ),
                );
              },
            ),

          // 2. Compass Directional Halo / Arrow
          Transform.rotate(
            angle: headingRadians,
            child: SizedBox(
              width: 50,
              height: 50,
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  // Direction Arrow Needle at top (pointing towards heading)
                  Positioned(
                    top: 0,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: PadmaTheme.busAmber,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. Central Bus Icon Container
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: widget.isLive ? PadmaTheme.surface : PadmaTheme.surfaceElevated,
              shape: BoxShape.circle,
              border: Border.all(
                color: widget.isLive ? PadmaTheme.busAmber : PadmaTheme.borderLine,
                width: 2.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.isLive
                      ? PadmaTheme.busAmber.withValues(alpha: 0.35)
                      : Colors.black.withValues(alpha: 0.4),
                  blurRadius: widget.isLive ? 10 : 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                Icons.directions_bus_rounded,
                size: 20,
                color: widget.isLive ? PadmaTheme.busAmber : PadmaTheme.textMuted,
              ),
            ),
          ),

          // 4. Floating Speed Chip
          Positioned(
            bottom: -2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
              decoration: BoxDecoration(
                color: PadmaTheme.surfaceLowest.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: widget.isLive ? PadmaTheme.primaryTeal : PadmaTheme.borderLine,
                  width: 0.8,
                ),
              ),
              child: Text(
                '${widget.speed.round()} km/h',
                style: TextStyle(
                  fontSize: 8.5,
                  fontWeight: FontWeight.w700,
                  color: widget.isLive ? PadmaTheme.textPrimary : PadmaTheme.textMuted,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
