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

  /// "Washi tape index card" surface used by [TapedCard] — a warmer/darker
  /// step than [creamBackground]/[paperCard] so a taped card reads as a
  /// distinct scrap of paper stuck onto the section, not just another
  /// [paperCard]. Dark variant follows the same lighten-and-warm pattern as
  /// the other light/dark pairs above.
  static const Color _parchmentLight = Color(0xfff2ead8);
  static const Color _parchmentDark = Color(0xff3a3628);

  /// Notebook rule-line color — solid warm tan for the horizontal lines
  /// painted over [BrandAccentColors.parchment] pages (see `NotebookLines`),
  /// distinct from [BrandAccentColors.ruleLine] (a translucent ink divider
  /// used on any surface, not specifically a paper-ruling color). Dark
  /// variant is a lightened step off [_parchmentDark] — lines need to read
  /// lighter than the dark parchment surface they sit on, not darker.
  static const Color _paperRuleLight = Color(0xffe4d7bd);
  static const Color _paperRuleDark = Color(0xff4a4433);

  /// Faded red margin line, notebook-style. Dark variant brighter/more
  /// saturated for contrast against [_parchmentDark], same pattern as
  /// [_brandOrangeDark]/[_mossAccentDark]/[_ratingAmberDark] above.
  static const Color _paperMarginLight = Color(0xffd69a86);
  static const Color _paperMarginDark = Color(0xffe3ac98);

  /// Named type-scale roles shared across `lib/presentation` — screen
  /// title, section title, item title (restaurant/category name) and the
  /// small-caps "kicker" micro-label. Colors are intentionally omitted here
  /// (callers apply `.copyWith(color: accent.something)`), matching how
  /// every other Newsreader/Work Sans usage in the app already picks its
  /// own color per surface.
  static const TextStyle titleScreen = TextStyle(
    fontFamily: 'Newsreader',
    fontWeight: FontWeight.w700,
    fontSize: 26,
  );

  static const TextStyle titleSection = TextStyle(
    fontFamily: 'Newsreader',
    fontWeight: FontWeight.w700,
    fontSize: 19,
  );

  /// Unlike the two styles above, the kicker's color is fixed
  /// ([BrandAccentColors.inkSoft]) rather than varying per call site, so it
  /// takes the theme's [BrandAccentColors] and returns a ready-to-use style
  /// instead of being a plain constant. Callers still need to apply
  /// `.toUpperCase()` to the label text themselves — this only supplies the
  /// style, not a text transform.
  static TextStyle kicker(BrandAccentColors accent) => TextStyle(
    fontFamily: 'Work Sans',
    fontWeight: FontWeight.w600,
    fontSize: 10.5,
    letterSpacing: 1.4,
    color: accent.inkSoft,
  );

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
      titleTextStyle: titleSection.copyWith(color: brandNavy),
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
        parchment: _parchmentLight,
        paperRule: _paperRuleLight,
        paperMargin: _paperMarginLight,
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
      titleTextStyle: titleSection.copyWith(color: _brandNavyOnDark),
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
        parchment: _parchmentDark,
        paperRule: _paperRuleDark,
        paperMargin: _paperMarginDark,
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
    required this.parchment,
    required this.paperRule,
    required this.paperMargin,
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

  /// "Index card" paper surface for [TapedCard] — warmer/darker than
  /// [paperCard] so a taped card reads as a distinct scrap of paper.
  final Color parchment;

  /// Notebook-page rule-line color, for [NotebookLines] and similar
  /// "cuaderno" backgrounds drawn over [parchment].
  final Color paperRule;

  /// Faded red notebook margin line, for [NotebookLines] and similar
  /// "cuaderno" backgrounds drawn over [parchment].
  final Color paperMargin;

  /// Alias for [parchment] — same color, named for call sites that think
  /// of it as "paper" (e.g. notebook-page backgrounds) rather than the
  /// [TapedCard] index-card surface. Do not add a second stored hex here;
  /// this only exists to make call-site code read more clearly.
  Color get paper => parchment;

  /// Alias for [inkSoft], named for "cuaderno" call sites that think in
  /// terms of "ink on paper" rather than the general-purpose soft-text role.
  Color get paperInkSoft => inkSoft;

  /// [secondary] (moss) at ~50% alpha, for washi-tape strips on
  /// [TapedCard]. Derived on the fly rather than stored: it's a single
  /// alpha tweak of an existing token, not an independent color that needs
  /// its own light/dark pair.
  Color get tapeMoss => secondary.withValues(alpha: 0.5);

  /// [accent] (terracotta) at ~50% alpha, for washi-tape strips on
  /// [TapedCard]. See [tapeMoss].
  Color get tapeTerracotta => accent.withValues(alpha: 0.5);

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
    Color? parchment,
    Color? paperRule,
    Color? paperMargin,
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
      parchment: parchment ?? this.parchment,
      paperRule: paperRule ?? this.paperRule,
      paperMargin: paperMargin ?? this.paperMargin,
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
      parchment: Color.lerp(parchment, other.parchment, t) ?? parchment,
      paperRule: Color.lerp(paperRule, other.paperRule, t) ?? paperRule,
      paperMargin:
          Color.lerp(paperMargin, other.paperMargin, t) ?? paperMargin,
    );
  }
}
