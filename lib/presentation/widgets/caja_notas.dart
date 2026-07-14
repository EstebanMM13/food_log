import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// "Ruled paper" box used for the restaurant notes section and the dish
/// comment in the detail modal: a `paperCardAlt` surface with faint
/// horizontal rules every 25px, regardless of how little text sits on top.
class CajaNotas extends StatelessWidget {
  final Widget child;
  final double minHeight;

  const CajaNotas({super.key, required this.child, this.minHeight = 90});

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).extension<BrandAccentColors>()!;
    return Container(
      constraints: BoxConstraints(minHeight: minHeight),
      width: double.infinity,
      decoration: BoxDecoration(
        color: accent.paperCardAlt,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _LineasCuadernoPainter(color: accent.ruleLine),
            ),
          ),
          Padding(padding: const EdgeInsets.all(14), child: child),
        ],
      ),
    );
  }
}

class _LineasCuadernoPainter extends CustomPainter {
  final Color color;

  const _LineasCuadernoPainter({required this.color});

  static const double _spacing = 25;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    for (double y = _spacing; y < size.height; y += _spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _LineasCuadernoPainter oldDelegate) =>
      oldDelegate.color != color;
}
