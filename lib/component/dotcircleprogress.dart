import 'dart:math';

import 'package:flutter/material.dart';

class DottedCircularProgressIndicator extends StatelessWidget {
  final double size;
  final double dotRadius;
  final Color color;
  final double progress;

  const DottedCircularProgressIndicator({
    Key? key,
    required this.size,
    this.dotRadius = 3.0,
    this.color = Colors.blue,
    this.progress = 1.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _DottedCircularProgressPainter(
        dotRadius: dotRadius,
        color: color,
        progress: progress,
      ),
    );
  }
}

class _DottedCircularProgressPainter extends CustomPainter {
  final double dotRadius;
  final Color color;
  final double progress;

  _DottedCircularProgressPainter({
    required this.dotRadius,
    required this.color,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double radius = size.width / 2;
    final Offset center = Offset(size.width / 2, size.height / 2);
    final int numDots = 30; // Number of dots in the circle
    final double angleStep = 2 * pi / numDots;

    for (int i = 0; i < numDots; i++) {
      final double angle = i * angleStep;
      final double dx = center.dx + radius * cos(angle);
      final double dy = center.dy + radius * sin(angle);

      // Draw dots only up to the progress
      if (i < numDots * progress) {
        canvas.drawCircle(Offset(dx, dy), dotRadius, Paint()..color = color);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
