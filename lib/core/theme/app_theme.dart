import 'package:flutter/material.dart';

/// App-wide Material theme. "Cuaderno" palette — warm parchment, terracotta,
/// sepia ink — replacing the earlier cream/orange/navy trio. Field names are
/// kept the same as before on purpose, so nothing else in the app needs to
/// change beyond this file: only the hex VALUES moved.
class AppTheme {
  AppTheme._();

  /// Terracotta — was `#FF7B4B`. For solid FILLS (buttons, badges, icon
  /// accents), not for text on a light surface — see [brandOrangeInk].
  static const Color brandOrange = Color(0xffc9673a);

  /// Warm parchment — was the flatter `#F5EDE2` cream.
  static const Color creamBackground = Color(0xfff6efe3);

  /// Sepia ink — was navy `#2A3647`. Primary "ink" color for text/structure.
  static const Color brandNavy = Color(0xff2a2118);

  /// Darker terracotta for TEXT/icons directly on [creamBackground] or other
  /// light surfaces.
  static const Color brandOrangeInk = Color(0xff9c4522);

  /// New secondary accent — muted moss, same warm-earthy family as the rest
  /// of the palette. For tags/labels/success states that shouldn't compete
  /// with the terracotta brand accent.
  static const Color mossAccent = Color(0xff7d8256);

  /// Rating/star color. Only use as an icon fill, not as flat text on
  /// parchment.
  static const Color ratingAmber = Color(0xffd99a34);

  /// [brandNavy], lightened to the same hue family, for use as "strong"
  /// text/icon color on the dark theme's dark surfaces — brandNavy itself
  /// is near-invisible on a dark background.
  static const Color _brandNavyOnDark = Color(0xffede7dc);

  /// Dark-theme paper background. Distinct from [creamBackground] (which
  /// only applies to the light theme) — the dark "Cuaderno" mock uses a
  /// near-black neutral graphite, not a darkened parchment.
  static const Color _paperDark = Color(0xff1c1b19);

  /// Dark-theme variants of the accent/rating/secondary hues — brighter and
  /// more saturated than their light counterparts so they still read
  /// clearly against [_paperDark], per the redesign handoff.
  static const Color _brandOrangeDark = Color(0xffe8895a);
  static const Color _brandOrangeInkDark = Color(0xfff0a97c);
  static const Color _mossAccentDark = Color(0xffb4ac80);
  static const Color _ratingAmberDark = Color(0xfff0b65a);

  /// Third brand accent — "ink blue", metaphor of pen ink on the notebook
  /// paper. Light/dark variants, same pattern as the other accent pairs
  /// above.
  static const Color _inkBlueLight = Color(0xff3d6478);
  static const Color _inkBlueDark = Color(0xff7faec2);

  static TextTheme _textTheme(Brightness brightness) {
    final base = brightness == Brightness.light
        ? Typography.material2021().black
        : Typography.material2021().white;
    return base.apply(fontFamily: 'Work Sans');
  }

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: creamBackground),
    scaffoldBackgroundColor: creamBackground,
    textTheme: _textTheme(Brightness.light),
    appBarTheme: AppBarTheme(
      backgroundColor: creamBackground,
      foregroundColor: brandOrangeInk,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: const TextStyle(
        fontFamily: 'Newsreader',
        color: brandNavy,
        fontWeight: FontWeight.w700,
        fontSize: 19,
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
        tertiary: _inkBlueLight,
        tertiaryTint: Color.fromRGBO(61, 100, 120, 0.12),
        paperCard: Color(0xfffffcf5),
        paperCardAlt: Color(0xffefe6d4),
        inkSoft: Color(0xff8b7d68),
        terracottaTint: Color.fromRGBO(201, 103, 58, 0.14),
        mossTint: Color.fromRGBO(125, 130, 86, 0.14),
        amberTint: Color.fromRGBO(217, 154, 52, 0.18),
        ruleLine: Color.fromRGBO(42, 33, 24, 0.10),
        border: Color.fromRGBO(42, 33, 24, 0.10),
        shadow: Color.fromRGBO(42, 33, 24, 0.16),
      ),
    ],
  );

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: creamBackground,
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: _paperDark,
    textTheme: _textTheme(Brightness.dark),
    appBarTheme: AppBarTheme(
      backgroundColor: _paperDark,
      foregroundColor: _brandOrangeInkDark,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: const TextStyle(
        fontFamily: 'Newsreader',
        color: _brandNavyOnDark,
        fontWeight: FontWeight.w700,
        fontSize: 19,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _brandOrangeDark,
        foregroundColor: brandNavy,
      ),
    ),
    extensions: const [
      BrandAccentColors(
        accent: _brandOrangeDark,
        accentInk: _brandOrangeInkDark,
        strongText: _brandNavyOnDark,
        rating: _ratingAmberDark,
        secondary: _mossAccentDark,
        tertiary: _inkBlueDark,
        tertiaryTint: Color.fromRGBO(127, 174, 194, 0.18),
        paperCard: Color(0xff262420),
        paperCardAlt: Color(0xff302e28),
        inkSoft: Color(0xff9c9488),
        terracottaTint: Color.fromRGBO(232, 137, 90, 0.16),
        mossTint: Color.fromRGBO(180, 172, 128, 0.16),
        amberTint: Color.fromRGBO(240, 182, 90, 0.16),
        ruleLine: Color.fromRGBO(237, 231, 220, 0.08),
        border: Color.fromRGBO(237, 231, 220, 0.12),
        shadow: Color.fromRGBO(0, 0, 0, 0.5),
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
    required this.tertiary,
    required this.tertiaryTint,
    required this.paperCard,
    required this.paperCardAlt,
    required this.inkSoft,
    required this.terracottaTint,
    required this.mossTint,
    required this.amberTint,
    required this.ruleLine,
    required this.border,
    required this.shadow,
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

  /// Ink blue — third brand accent ("pen ink on paper"), for text/icons.
  final Color tertiary;

  /// Ink blue at low alpha, for tag chip backgrounds.
  final Color tertiaryTint;

  /// Card surface — lighter/darker than the page background, depending on
  /// theme. In the dark theme the step is deliberately pronounced (not just
  /// "slightly") so the two surfaces stay distinguishable.
  final Color paperCard;

  /// Track color for bars/rings/dashes (progress indicators, dashed
  /// placeholders) — a step further from [paperCard] than the page
  /// background.
  final Color paperCardAlt;

  /// Secondary/muted text color (subtitles, meta info).
  final Color inkSoft;

  /// Terracotta at low alpha, for tag chip backgrounds.
  final Color terracottaTint;

  /// Moss at low alpha, for tag chip backgrounds.
  final Color mossTint;

  /// Amber at low alpha, for rating pill backgrounds.
  final Color amberTint;

  /// Subtle divider/notebook-rule color, thinner than [border].
  final Color ruleLine;

  /// Card/pill outline color.
  final Color border;

  /// Drop-shadow color for elevated cards.
  final Color shadow;

  @override
  BrandAccentColors copyWith({
    Color? accent,
    Color? accentInk,
    Color? strongText,
    Color? rating,
    Color? secondary,
    Color? tertiary,
    Color? tertiaryTint,
    Color? paperCard,
    Color? paperCardAlt,
    Color? inkSoft,
    Color? terracottaTint,
    Color? mossTint,
    Color? amberTint,
    Color? ruleLine,
    Color? border,
    Color? shadow,
  }) {
    return BrandAccentColors(
      accent: accent ?? this.accent,
      accentInk: accentInk ?? this.accentInk,
      strongText: strongText ?? this.strongText,
      rating: rating ?? this.rating,
      secondary: secondary ?? this.secondary,
      tertiary: tertiary ?? this.tertiary,
      tertiaryTint: tertiaryTint ?? this.tertiaryTint,
      paperCard: paperCard ?? this.paperCard,
      paperCardAlt: paperCardAlt ?? this.paperCardAlt,
      inkSoft: inkSoft ?? this.inkSoft,
      terracottaTint: terracottaTint ?? this.terracottaTint,
      mossTint: mossTint ?? this.mossTint,
      amberTint: amberTint ?? this.amberTint,
      ruleLine: ruleLine ?? this.ruleLine,
      border: border ?? this.border,
      shadow: shadow ?? this.shadow,
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
      tertiary: Color.lerp(tertiary, other.tertiary, t) ?? tertiary,
      tertiaryTint:
          Color.lerp(tertiaryTint, other.tertiaryTint, t) ?? tertiaryTint,
      paperCard: Color.lerp(paperCard, other.paperCard, t) ?? paperCard,
      paperCardAlt:
          Color.lerp(paperCardAlt, other.paperCardAlt, t) ?? paperCardAlt,
      inkSoft: Color.lerp(inkSoft, other.inkSoft, t) ?? inkSoft,
      terracottaTint:
          Color.lerp(terracottaTint, other.terracottaTint, t) ?? terracottaTint,
      mossTint: Color.lerp(mossTint, other.mossTint, t) ?? mossTint,
      amberTint: Color.lerp(amberTint, other.amberTint, t) ?? amberTint,
      ruleLine: Color.lerp(ruleLine, other.ruleLine, t) ?? ruleLine,
      border: Color.lerp(border, other.border, t) ?? border,
      shadow: Color.lerp(shadow, other.shadow, t) ?? shadow,
    );
  }
}
