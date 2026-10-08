import 'package:flutter/material.dart';
import '../../../../core/theme.dart';

/// Interactive 3D Perspective Card with spatial elevation and glowing borders.
class Admin3dCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? borderColor;
  final Color? glowColor;
  final VoidCallback? onTap;

  const Admin3dCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderColor,
    this.glowColor,
    this.onTap,
  });

  @override
  State<Admin3dCard> createState() => _Admin3dCardState();
}

class _Admin3dCardState extends State<Admin3dCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  double _tiltX = 0.0;
  double _tiltY = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPanUpdate(DragUpdateDetails details, Size size) {
    setState(() {
      _tiltX = (details.localPosition.dy / size.height - 0.5) * 0.12;
      _tiltY = -(details.localPosition.dx / size.width - 0.5) * 0.12;
    });
  }

  void _onPanEnd() {
    setState(() {
      _tiltX = 0.0;
      _tiltY = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final effectiveBorderColor = widget.borderColor ?? PadmaTheme.borderLine;
    final effectiveGlowColor = widget.glowColor ?? PadmaTheme.primaryTeal.withValues(alpha: 0.12);

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        return GestureDetector(
          onTapDown: (_) => _controller.forward(),
          onTapUp: (_) => _controller.reverse(),
          onTapCancel: () => _controller.reverse(),
          onTap: widget.onTap,
          onPanUpdate: (d) => _onPanUpdate(d, size),
          onPanEnd: (_) => _onPanEnd(),
          child: AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform(
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001) // Perspective depth
                  ..rotateX(_tiltX)
                  ..rotateY(_tiltY)
                  ..scaleByDouble(_scaleAnimation.value, _scaleAnimation.value, 1.0, 1.0),
                alignment: FractionalOffset.center,
                child: Container(
                  padding: widget.padding,
                  decoration: BoxDecoration(
                    color: PadmaTheme.surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: effectiveBorderColor, width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: effectiveGlowColor,
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                        spreadRadius: 1,
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: widget.child,
                ),
              );
            },
          ),
        );
      },
    );
  }
}
