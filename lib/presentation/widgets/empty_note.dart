import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import 'dashed_painter.dart';

/// A "handwritten sticky note" empty-state: a dashed rounded-rect border
/// around a slightly-rotated Caveat message, optionally paired with an
/// illustration above/alongside the text. Used wherever a list/section has
/// nothing in it yet (restaurant list, notes, dishes).
class EmptyNote extends StatelessWidget {
  const EmptyNote({super.key, required this.text, this.illo});

  final String text;
  final Widget? illo;

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).extension<BrandAccentColors>()!;

    return CustomPaint(
      painter: DashedPathPainter.roundedRect(color: accent.border, radius: 16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (illo != null) ...[illo!, const SizedBox(height: 12)],
            Transform.rotate(
              angle: -2 * math.pi / 180,
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Caveat',
                  fontSize: 19,
                  fontWeight: FontWeight.w600,
                  color: accent.paperInkSoft,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
