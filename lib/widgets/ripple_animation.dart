import 'package:flutter/material.dart';
import 'dart:math' as math;

class RippleAnimation extends StatefulWidget {
  final bool isRecording;
  final Widget child;
  final Color color;

  const RippleAnimation({
    super.key,
    required this.isRecording,
    required this.child,
    required this.color,
  });

  @override
  State<RippleAnimation> createState() => _RippleAnimationState();
}

class _RippleAnimationState extends State<RippleAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void didUpdateWidget(covariant RippleAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRecording && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.isRecording && _controller.isAnimating) {
      _controller.stop();
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: widget.isRecording
          ? RipplePainter(_controller, color: widget.color)
          : null,
      child: widget.child,
    );
  }
}

class RipplePainter extends CustomPainter {
  final Animation<double> animation;
  final Color color;

  RipplePainter(this.animation, {required this.color})
    : super(repaint: animation);

  void circle(Canvas canvas, Rect rect, double value) {
    double opacity = (1.0 - (value / 4.0)).clamp(0.0, 1.0);
    Color finalColor = color.withOpacity(opacity);
    double size = rect.width / 2;
    double area = size * size;
    double radius = math.sqrt(area * value / 4);

    final Paint paint = Paint()..color = finalColor;
    canvas.drawCircle(rect.center, radius, paint);
  }

  @override
  void paint(Canvas canvas, Size size) {
    Rect rect = Rect.fromLTRB(0.0, 0.0, size.width, size.height);

    // Draw 3 waves
    for (int wave = 3; wave >= 0; wave--) {
      circle(canvas, rect, wave + animation.value);
    }
  }

  @override
  bool shouldRepaint(RipplePainter oldDelegate) => true;
}
