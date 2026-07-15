import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// A "torn from a notebook" card: a slightly rotated parchment rectangle
/// with one or two washi-tape strips pinned across its top edge. Used in
/// the Estadísticas screen for the average-score "index card" hero and as
/// a decorative wrapper around the ranking sections.
class TapedCard extends StatelessWidget {
  final BrandAccentColors accent;
  final Widget child;

  /// Color of the (always present) first tape strip. Callers pass a
  /// semi-transparent color — e.g. `accent.accent.withValues(alpha: 0.55)`
  /// — so the paper underneath still shows through, like real tape.
  final Color colorCinta;

  /// Optional second tape strip, on the opposite corner. Omit for a
  /// single-strip look.
  final Color? colorCintaSecundaria;

  /// Whether to paint the card's own parchment background/border. Set to
  /// `false` when wrapping a child (e.g. `_TarjetaSeccion`) that already
  /// paints its own card surface, so the tape sits on top of it instead of
  /// nesting one card inside another.
  final bool fondoPergamino;

  final EdgeInsetsGeometry padding;

  const TapedCard({
    super.key,
    required this.accent,
    required this.child,
    required this.colorCinta,
    this.colorCintaSecundaria,
    this.fondoPergamino = true,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Room for the tape strips to overhang the card's top edge without
      // getting clipped by a sibling widget above.
      padding: const EdgeInsets.only(top: 10),
      child: Transform.rotate(
        angle: -0.01,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: double.infinity,
              padding: padding,
              decoration: fondoPergamino
                  ? BoxDecoration(
                      color: accent.parchment,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: accent.border),
                    )
                  : null,
              child: child,
            ),
            Positioned(
              top: -10,
              left: 22,
              child: _CintaWashi(color: colorCinta, angle: -0.14),
            ),
            if (colorCintaSecundaria != null)
              Positioned(
                top: -10,
                right: 26,
                child: _CintaWashi(color: colorCintaSecundaria!, angle: 0.12),
              ),
          ],
        ),
      ),
    );
  }
}

/// A single washi-tape strip: a small semi-transparent rounded rectangle,
/// rotated a few degrees off-axis so it reads as hand-stuck rather than
/// perfectly placed.
class _CintaWashi extends StatelessWidget {
  final Color color;
  final double angle;

  const _CintaWashi({required this.color, required this.angle});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angle,
      child: Container(
        width: 52,
        height: 20,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}
