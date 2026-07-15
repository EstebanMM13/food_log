import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Paints a school-notebook-style background behind [child]: evenly spaced
/// horizontal rule lines in [BrandAccentColors.paperRule], plus a single
/// vertical margin line near the left edge in [BrandAccentColors.paperMargin]
/// — like a page torn from a lined notebook.
///
/// The background is a fixed decorative layer (it does not scroll with
/// [child]), so give the wrapped content enough left padding to clear
/// [marginOffset] — otherwise text will sit on top of the red margin line
/// instead of to its right, like real notebook writing.
class NotebookLines extends StatelessWidget {
  final BrandAccentColors accent;
  final Widget child;

  /// Vertical distance between horizontal rule lines.
  final double lineSpacing;

  /// Distance of the vertical margin line from the left edge.
  final double marginOffset;

  const NotebookLines({
    super.key,
    required this.accent,
    required this.child,
    this.lineSpacing = 28,
    this.marginOffset = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: _NotebookLinesPainter(
              ruleColor: accent.paperRule,
              marginColor: accent.paperMargin,
              lineSpacing: lineSpacing,
              marginOffset: marginOffset,
            ),
          ),
        ),
        child,
      ],
    );
  }
}

class _NotebookLinesPainter extends CustomPainter {
  final Color ruleColor;
  final Color marginColor;
  final double lineSpacing;
  final double marginOffset;

  const _NotebookLinesPainter({
    required this.ruleColor,
    required this.marginColor,
    required this.lineSpacing,
    required this.marginOffset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rulePaint = Paint()
      ..color = ruleColor
      ..strokeWidth = 1;
    for (var y = lineSpacing; y < size.height; y += lineSpacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), rulePaint);
    }

    final marginPaint = Paint()
      ..color = marginColor
      ..strokeWidth = 1.4;
    canvas.drawLine(
      Offset(marginOffset, 0),
      Offset(marginOffset, size.height),
      marginPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _NotebookLinesPainter oldDelegate) =>
      oldDelegate.ruleColor != ruleColor ||
      oldDelegate.marginColor != marginColor ||
      oldDelegate.lineSpacing != lineSpacing ||
      oldDelegate.marginOffset != marginOffset;
}
