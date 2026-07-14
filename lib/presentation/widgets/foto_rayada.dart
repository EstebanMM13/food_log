import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Large photo surface (restaurant cover, dish cover, home list card) that
/// falls back to a diagonal-striped "sin foto" placeholder instead of
/// [FotoThumbnail]'s icon-only placeholder — this is the "no real photo yet"
/// treatment described in the redesign handoff for the few large photo
/// slots that aren't a small in-row thumbnail.
///
/// Unlike `FotoThumbnail`, this widget does not clip or round itself — the
/// caller wraps it (in a `ClipRRect`, `Transform.rotate`, etc.) since every
/// screen composes it a little differently.
class FotoRayada extends StatelessWidget {
  final String? fotoPath;
  final double? width;
  final double? height;
  final BoxFit fit;

  const FotoRayada({
    super.key,
    required this.fotoPath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    final path = fotoPath;
    if (path == null || path.isEmpty) {
      return _placeholder(context);
    }
    return Image.file(
      File(path),
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) => _placeholder(context),
    );
  }

  Widget _placeholder(BuildContext context) {
    final accent = Theme.of(context).extension<BrandAccentColors>()!;
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: _RayasDiagonalesPainter(
          stripeColor: accent.border,
          background: accent.paperCardAlt,
        ),
        child: Center(
          child: Text(
            'sin foto',
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
              letterSpacing: 0.5,
              color: accent.inkSoft,
            ),
          ),
        ),
      ),
    );
  }
}

/// A [FotoRayada] with the "notebook photo" decorative treatment used for
/// the restaurant cover and the dish detail modal: slight rotation, a
/// drop shadow, and a small "washi tape" rectangle overlapping the top edge.
class FotoDecorada extends StatelessWidget {
  final String? fotoPath;
  final double width;
  final double aspectRatio;
  final double borderRadius;
  final double rotationDegrees;

  const FotoDecorada({
    super.key,
    required this.fotoPath,
    required this.width,
    this.aspectRatio = 1,
    this.borderRadius = 18,
    this.rotationDegrees = -1.5,
  });

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).extension<BrandAccentColors>()!;
    return Transform.rotate(
      angle: rotationDegrees * math.pi / 180,
      child: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          Container(
            width: width,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              boxShadow: [
                BoxShadow(
                  color: accent.shadow,
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(borderRadius),
              child: AspectRatio(
                aspectRatio: aspectRatio,
                child: FotoRayada(fotoPath: fotoPath, fit: BoxFit.cover),
              ),
            ),
          ),
          Transform.translate(
            offset: const Offset(0, -11),
            child: Transform.rotate(
              angle: -3 * math.pi / 180,
              child: Container(
                width: 64,
                height: 22,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.45),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Paints an evenly-spaced diagonal stripe pattern, emulating the mock's CSS
/// `repeating-linear-gradient` placeholder texture.
class _RayasDiagonalesPainter extends CustomPainter {
  final Color stripeColor;
  final Color background;

  const _RayasDiagonalesPainter({
    required this.stripeColor,
    required this.background,
  });

  static const double _spacing = 12;
  static const double _strokeWidth = 6;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = background);

    final paint = Paint()
      ..color = stripeColor
      ..strokeWidth = _strokeWidth;

    // Diagonal lines at 45°, spaced along the combined width+height so the
    // pattern covers the whole rect regardless of aspect ratio.
    final diagonal = size.width + size.height;
    for (double x = -size.height; x < diagonal; x += _spacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x + size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RayasDiagonalesPainter oldDelegate) =>
      oldDelegate.stripeColor != stripeColor ||
      oldDelegate.background != background;
}
