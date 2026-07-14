import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Small pill-shaped tag label used wherever a restaurant/dish tag is shown
/// — the restaurant detail header, the home list card, and the stats
/// "Tags más usados" list. Rotates between the terracotta, moss, and ink
/// blue tints (by [index]) so a run of tags doesn't read as one flat block
/// of color.
class TagChip extends StatelessWidget {
  final String nombre;
  final int index;
  final BrandAccentColors accent;

  const TagChip({
    super.key,
    required this.nombre,
    required this.index,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final ciclo = index % 3;
    final (background, foreground) = switch (ciclo) {
      0 => (accent.terracottaTint, accent.accentInk),
      1 => (accent.mossTint, accent.secondary),
      _ => (accent.tertiaryTint, accent.tertiary),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        nombre,
        style: TextStyle(
          fontFamily: 'Work Sans',
          fontSize: 11.5,
          fontWeight: FontWeight.w500,
          color: foreground,
        ),
      ),
    );
  }
}
