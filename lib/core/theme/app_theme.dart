import 'package:flutter/material.dart';

/// App-wide Material theme. The seed color matches the warm, paper-like
/// palette used by the original prototype `main.dart`.
class AppTheme {
  AppTheme._();

  static const Color brandOrange = Color(0xffff7b4b);
  static const Color creamBackground = Color(0xfff5ede2);
  static const Color brandNavy = Color(0xff2a3647);

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
          foregroundColor: brandOrange,
          titleTextStyle: TextStyle(
            color: brandOrange,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        extensions: const [
          BrandAccentColors(accent: brandOrange, strongText: brandNavy),
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
        extensions: const [
          BrandAccentColors(accent: brandOrange, strongText: _brandNavyOnDark),
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
  const BrandAccentColors({required this.accent, required this.strongText});

  /// The brand's orange accent (calls to action, highlighted icons/text).
  /// Identical value in light and dark — it has strong contrast against
  /// both the cream background and the dark theme's dark surfaces.
  final Color accent;

  /// The brand's "ink" color for emphasized text/icons on a regular
  /// surface (not the AppBar, which already gets its own explicit color).
  /// Navy in light mode; a lightened tint of the same hue in dark mode.
  final Color strongText;

  @override
  BrandAccentColors copyWith({Color? accent, Color? strongText}) {
    return BrandAccentColors(
      accent: accent ?? this.accent,
      strongText: strongText ?? this.strongText,
    );
  }

  @override
  BrandAccentColors lerp(ThemeExtension<BrandAccentColors>? other, double t) {
    if (other is! BrandAccentColors) return this;
    return BrandAccentColors(
      accent: Color.lerp(accent, other.accent, t) ?? accent,
      strongText: Color.lerp(strongText, other.strongText, t) ?? strongText,
    );
  }
}
