import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Inline dish/category score shown as a plain number in `rating` color,
/// baseline-aligned with a smaller " /10" suffix — no star icon. Used in the
/// dish detail sheet, the accordion dish row and the accordion category
/// header, so scores read consistently everywhere in the ficha.
class DishScore extends StatelessWidget {
  const DishScore(this.value, {super.key, required this.accent});

  final String value;
  final BrandAccentColors accent;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Newsreader',
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: accent.rating,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        Text(
          ' /10',
          style: TextStyle(
            fontFamily: 'Newsreader',
            fontWeight: FontWeight.w600,
            fontSize: 10,
            color: accent.rating.withValues(alpha: 0.55),
          ),
        ),
      ],
    );
  }
}
