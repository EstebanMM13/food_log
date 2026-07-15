import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// A hand-stamped-looking ink circle around a numeric score, used wherever
/// a dish/restaurant score is the headline figure of a card (as opposed to
/// an aggregate stat, which is rendered as plain text instead — see
/// `_InfoCard` in restaurante_detail_screen.dart).
///
/// The circle and its optional [verdict] label are each rotated by a small,
/// slightly different angle so the pair reads as two independent hand
/// marks rather than one mechanically-aligned badge.
class ScoreStamp extends StatelessWidget {
  const ScoreStamp(this.value, {super.key, this.verdict, required this.accent});

  /// The display string for the score, e.g. `'8.5'`.
  final String value;

  /// Optional short handwriting-style annotation, e.g. `'volvería'`.
  final String? verdict;

  final BrandAccentColors accent;

  static const double _diameter = 40;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Transform.rotate(
          angle: -6 * 3.1415926535 / 180,
          child: Container(
            width: _diameter,
            height: _diameter,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: accent.rating, width: 2),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontFamily: 'Newsreader',
                fontWeight: FontWeight.w700,
                fontSize: 16,
                // The stamp reads as "ink" over "text": using the rating
                // color for the digits (rather than strongText) keeps the
                // whole mark a single color, like a real rubber stamp.
                color: accent.rating,
              ),
            ),
          ),
        ),
        if (verdict != null) ...[
          const SizedBox(height: 2),
          Transform.rotate(
            angle: 3 * 3.1415926535 / 180,
            child: Text(
              verdict!,
              style: TextStyle(
                fontFamily: 'Caveat',
                fontSize: 15,
                color: accent.secondary,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
