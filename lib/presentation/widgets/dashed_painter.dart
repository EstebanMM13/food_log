import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Generic dashed-outline painter: walks an arbitrary [Path]'s metrics and
/// strokes alternating dash/gap segments along it. Shared by every "hand
/// drawn" dashed outline in the app (rounded-rect "add" rows, circle empty
/// states, [EmptyNote]'s border, ...) so the dash-walking logic lives in one
/// place instead of being reimplemented per shape.
///
/// [pathBuilder] receives the canvas [Size] at paint time and returns the
/// path to stroke as dashes — build a rounded rect, a circle, or any other
/// shape from it. The two static helpers below cover the two shapes this
/// app currently needs.
class DashedPathPainter extends CustomPainter {
  final Color color;
  final Path Function(Size size) pathBuilder;
  final double dashWidth;
  final double dashGap;
  final double strokeWidth;

  const DashedPathPainter({
    required this.color,
    required this.pathBuilder,
    this.dashWidth = 5,
    this.dashGap = 4,
    this.strokeWidth = 1.2,
  });

  /// Rounded-rect dashed border filling the canvas — e.g. the "Añadir plato"
  /// row and [EmptyNote]'s border.
  static DashedPathPainter roundedRect({
    required Color color,
    double radius = 10,
    double dashWidth = 5,
    double dashGap = 4,
    double strokeWidth = 1.2,
  }) {
    return DashedPathPainter(
      color: color,
      dashWidth: dashWidth,
      dashGap: dashGap,
      strokeWidth: strokeWidth,
      pathBuilder: (size) => Path()
        ..addRRect(
          RRect.fromRectAndRadius(
            Offset.zero & size,
            Radius.circular(radius),
          ),
        ),
    );
  }

  /// Dashed circle outline inscribed in a square canvas of the given
  /// [diameter] — e.g. the stats "no data yet" empty states. [dashCount] and
  /// [gapFraction] describe the pattern the same way the previous
  /// angle-based painter did (evenly-spaced dashes around the circumference)
  /// but are converted to plain pixel [dashWidth]/[dashGap] so the shared
  /// distance-based dashing logic in [paint] can draw them.
  static DashedPathPainter circle({
    required Color color,
    required double diameter,
    int dashCount = 24,
    double gapFraction = 0.5,
    double strokeWidth = 1.4,
  }) {
    final radius = diameter / 2 - 1;
    final circumference = 2 * math.pi * radius;
    final segment = circumference / dashCount;
    return DashedPathPainter(
      color: color,
      dashWidth: segment * (1 - gapFraction),
      dashGap: segment * gapFraction,
      strokeWidth: strokeWidth,
      pathBuilder: (size) => Path()
        ..addOval(
          Rect.fromCircle(
            center: Offset(size.width / 2, size.height / 2),
            radius: size.width / 2 - 1,
          ),
        ),
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final path = pathBuilder(size);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final siguiente = distance + dashWidth;
        canvas.drawPath(
          metric.extractPath(distance, siguiente.clamp(0, metric.length)),
          paint,
        );
        distance = siguiente + dashGap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant DashedPathPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.dashWidth != dashWidth ||
      oldDelegate.dashGap != dashGap ||
      oldDelegate.strokeWidth != strokeWidth;
}
