import 'package:flutter/material.dart';

/// Paints a single loose, hand-drawn-looking check mark stroke — used as
/// the "done" visual for reminder rows instead of Material's stock
/// checkbox tick. Only paints when [checked] is true; an unchecked
/// reminder shows an empty box (painted by the container around this),
/// not an empty/greyed checkmark.
class HandCheckPainter extends CustomPainter {
  const HandCheckPainter({required this.checked, required this.color});

  final bool checked;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (!checked) return;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // A loose tick: short down-stroke into a longer, slightly overshooting
    // up-stroke, bowed with quadratic control points so it reads as drawn
    // by hand rather than two straight ruled lines.
    final path = Path()
      ..moveTo(size.width * 0.14, size.height * 0.52)
      ..quadraticBezierTo(
        size.width * 0.28,
        size.height * 0.68,
        size.width * 0.42,
        size.height * 0.78,
      )
      ..quadraticBezierTo(
        size.width * 0.58,
        size.height * 0.58,
        size.width * 0.88,
        size.height * 0.2,
      );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant HandCheckPainter oldDelegate) =>
      oldDelegate.checked != checked || oldDelegate.color != color;
}
