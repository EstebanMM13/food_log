import 'package:flutter/material.dart';

/// App-wide Material theme. The seed color matches the warm, paper-like
/// palette used by the original prototype `main.dart`.
class AppTheme {
  AppTheme._();

  static const Color brandOrange = Color(0xffff7b4b);
  static const Color creamBackground = Color(0xfff5ede2);
  static const Color brandNavy = Color(0xff2a3647);

  /// Darker tint of [brandOrange], same hue — for TEXT/icons drawn directly
  /// on [creamBackground] or other light surfaces. [brandOrange] itself is
  /// ~2.25:1 against cream (fails WCAG AA); this is ~5.1:1. Use for the
  /// AppBar title, links, and any orange label text. Keep [brandOrange]
  /// itself for solid fills (buttons, badges, icon strokes).
  static const Color brandOrangeInk = Color(0xffa8451f);

  /// Rating/star color. Same warm family as [brandOrange] but distinct, so
  /// ratings don't compete visually with brand accents.
  static const Color ratingAmber = Color(0xffe8a23d);

  /// [brandNavy], lightened to the same hue family, for use as "strong"
  /// text/icon color on the dark theme's dark surfaces — brandNavy itself
  /// is near-invisible on a dark background. Derived from
  /// `ColorScheme.fromSeed(seedColor: brandNavy, brightness: dark).secondary`.
  static const Color _brandNavyOnDark = Color(0xffbcc7db);

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
        // Buttons filled with brandOrange should use navy (not white) text —
        // navy-on-orange is ~4.7:1, white-on-orange is ~2.6:1 (fails AA).
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
          ),
        ],
      );

  /// Dark counterpart of [light]. Keeps the same warm, paper-like brand
  /// feel instead of a generic Material grey: the seed stays
  /// [creamBackground] (so surfaces/accents share the light theme's warm
  /// hue, just inverted in brightness), while the AppBar uses the brand's
  /// own dark color ([brandNavy]) as background — mirroring how [light]
  /// uses [creamBackground] literally for its AppBar — with [brandOrange]
  /// as foreground, same as in [light].
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
          ),
        ],
      );
}

/// Brand accent colors that don't map cleanly onto Material 3's generated
/// [ColorScheme] roles (see [AppTheme.dark] doc for why: seeding the scheme
/// with [AppTheme.creamBackground] does not reproduce [AppTheme.brandOrange]
/// or [AppTheme.brandNavy] as `primary`/`onSurface` — those come out as a
/// muddy brown-gold instead). Widgets that want the brand's orange accent or
/// navy "ink" color — and want it to adapt automatically between [AppTheme.light]
/// and [AppTheme.dark] — should read this extension via
/// `Theme.of(context).extension<BrandAccentColors>()` instead of referencing
/// `AppTheme.brandOrange` / `AppTheme.brandNavy` directly.
@immutable
class BrandAccentColors extends ThemeExtension<BrandAccentColors> {
  const BrandAccentColors({
    required this.accent,
    required this.accentInk,
    required this.strongText,
    required this.rating,
  });

  /// The brand's orange accent for solid FILLS (buttons, badges, icon
  /// strokes) — not for text on a light surface, see [accentInk].
  /// Identical value in light and dark — it has strong contrast against
  /// both the cream background and the dark theme's dark surfaces.
  final Color accent;

  /// Darker tint of [accent] for TEXT/icons drawn directly on a light
  /// surface (AppBar title, labels, links). In dark mode this equals
  /// [accent] again — the dark surface already gives it enough contrast.
  final Color accentInk;

  /// The brand's "ink" color for emphasized text/icons on a regular
  /// surface (not the AppBar, which already gets its own explicit color).
  /// Navy in light mode; a lightened tint of the same hue in dark mode.
  final Color strongText;

  /// Star / rating color — same warm family as [accent], kept distinct so
  /// ratings don't read as a brand-accent element.
  final Color rating;

  @override
  BrandAccentColors copyWith({
    Color? accent,
    Color? accentInk,
    Color? strongText,
    Color? rating,
  }) {
    return BrandAccentColors(
      accent: accent ?? this.accent,
      accentInk: accentInk ?? this.accentInk,
      strongText: strongText ?? this.strongText,
      rating: rating ?? this.rating,
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
    );
  }
}
