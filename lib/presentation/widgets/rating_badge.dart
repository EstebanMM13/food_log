import 'package:flutter/material.dart';

/// Small colored pill showing a 0-10 score. Shows a dash when there's no
/// score yet (e.g. a restaurant with no dishes logged).
class RatingBadge extends StatelessWidget {
  final double? puntuacion;

  const RatingBadge({super.key, required this.puntuacion});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final valor = puntuacion;
    final color = valor == null
        ? scheme.surfaceContainerHighest
        : Color.lerp(Colors.redAccent, Colors.green, (valor / 10).clamp(0, 1))!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        valor == null ? '—' : valor.toStringAsFixed(1),
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }
}
