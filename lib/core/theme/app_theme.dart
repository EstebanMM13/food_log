import 'package:flutter/material.dart';

/// App-wide Material theme. "Cuaderno" palette — warm parchment, terracotta,
/// sepia ink — replacing the earlier cream/orange/navy trio. Field names are
/// kept the same as before on purpose, so nothing else in the app needs to
/// change beyond this file: only the hex VALUES moved.
class AppTheme {
  AppTheme._();

  /// Terracotta — was `#FF7B4B`. For solid FILLS (buttons, badges, icon
  /// accents), not for text on a light surface — see [brandOrangeInk].
  static const Color brandOrange = Color(0xffd96b3a);

  /// Warm parchment — was the flatter `#F5EDE2` cream.
  static const Color creamBackground = Color(0xffefe0c9);

  /// Sepia ink — was navy `#2A3647`. Primary "ink" color for text/structure.
  static const Color brandNavy = Color(0xff33261c);

  /// Darker terracotta for TEXT/icons directly on [creamBackground] or other
  /// light surfaces — ~4.6:1 against the new parchment (still passes AA;
  /// [brandOrange] itself is ~2.7:1 and fails). Unchanged from before — this
  /// exact hue already worked against both the old cream and new parchment.
  static const Color brandOrangeInk = Color(0xffa8451f);

  /// New secondary accent — muted moss, same warm-earthy family as the rest
  /// of the palette. For tags/labels/success states that shouldn't compete
  /// with the terracotta brand accent.
  static const Color mossAccent = Color(0xff8a8256);

  /// Rating/star color. Unchanged — still reads well against white cards;
  /// only use as an icon fill, not as flat text on parchment.
  static const Color ratingAmber = Color(0xffe8a23d);

  /// [brandNavy], lightened to the same hue family, for use as "strong"
  /// text/icon color on the dark theme's dark surfaces — brandNavy itself
  /// is near-invisible on a dark background.
  static const Color _brandNavyOnDark = Color(0xffcdbfae);

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: creamBackground),
        appBarTheme: const AppBarTheme(
          backgroundColor: creamBackground,
          foregroundColor: brandOrangeInk,
          titleTextStyle: TextStyle(
            color: brandOrangeInk,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        // Buttons filled with brandOrange should use ink (not white) text —
        // ink-on-terracotta clears AA, white-on-terracotta does not.
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: brandOrange,
            foregroundColor: brandNavy,
          ),
        ),
        extensions: const [
          BrandAccentColors(
            accent: brandOrange,
            accentInk: brandOrangeInk,
            strongText: brandNavy,
            rating: ratingAmber,
            secondary: mossAccent,
          ),
        ],
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: creamBackground,
          brightness: Brightness.dark,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: brandNavy,
          foregroundColor: brandOrange,
          titleTextStyle: TextStyle(
            color: brandOrange,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: brandOrange,
            foregroundColor: brandNavy,
          ),
        ),
        extensions: const [
          BrandAccentColors(
            accent: brandOrange,
            accentInk: brandOrange,
            strongText: _brandNavyOnDark,
            rating: ratingAmber,
            secondary: mossAccent,
          ),
        ],
      );
}

@immutable
class BrandAccentColors extends ThemeExtension<BrandAccentColors> {
  const BrandAccentColors({
    required this.accent,
    required this.accentInk,
    required this.strongText,
    required this.rating,
    required this.secondary,
  });

  /// Terracotta, for solid fills (buttons, badges, icon strokes).
  final Color accent;

  /// Darker terracotta, for text/icons on a light surface.
  final Color accentInk;

  /// Ink color for emphasized text/icons on a regular surface.
  final Color strongText;

  /// Star / rating color.
  final Color rating;

  /// Moss — secondary accent for tags/labels.
  final Color secondary;

  @override
  BrandAccentColors copyWith({
    Color? accent,
    Color? accentInk,
    Color? strongText,
    Color? rating,
    Color? secondary,
  }) {
    return BrandAccentColors(
      accent: accent ?? this.accent,
      accentInk: accentInk ?? this.accentInk,
      strongText: strongText ?? this.strongText,
      rating: rating ?? this.rating,
      secondary: secondary ?? this.secondary,
    );
  }

  @override
  BrandAccentColors lerp(ThemeExtension<BrandAccentColors>? other, double t) {
    if (other is! BrandAccentColors) return this;
    return BrandAccentColors(
      accent: Color.lerp(accent, other.accent, t) ?? accent,
      accentInk: Color.lerp(accentInk, other.accentInk, t) ?? accentInk,
      strongText: Color.lerp(strongText, other.strongText, t) ?? strongText,
      rating: Color.lerp(rating, other.rating, t) ?? rating,
      secondary: Color.lerp(secondary, other.secondary, t) ?? secondary,
    );
  }
}
