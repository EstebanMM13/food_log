import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Key used to persist the user's explicit theme choice in
/// [SharedPreferences]. Stores [ThemeMode.name] ("light" or "dark"); absence
/// of the key means "follow the system", i.e. [ThemeMode.system].
const _themeModePrefsKey = 'theme_mode';

/// Holds the app's current [ThemeMode] and persists explicit user choices
/// across restarts via [SharedPreferences].
///
/// Modeled as an [AsyncNotifier] because loading the saved preference is
/// inherently async; callers should fall back to [ThemeMode.system] while
/// [build] is still loading (see `themeModeProvider`'s usage in `main.dart`),
/// which matches the "default to system if nothing saved yet" requirement.
class ThemeModeNotifier extends AsyncNotifier<ThemeMode> {
  @override
  Future<ThemeMode> build() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_themeModePrefsKey);
    if (saved == null) return ThemeMode.system;
    return ThemeMode.values.byName(saved);
  }

  /// Toggles between [ThemeMode.light] and [ThemeMode.dark] explicitly.
  ///
  /// If the current mode is [ThemeMode.system] (or still loading),
  /// [currentBrightness] (the brightness actually being shown, resolved from
  /// the platform) decides the target: the opposite of what's currently
  /// visible, so the first tap always changes what the user sees.
  Future<void> toggle(Brightness currentBrightness) async {
    final actual = state.value ?? ThemeMode.system;
    final ThemeMode nuevoModo;
    switch (actual) {
      case ThemeMode.system:
        nuevoModo = currentBrightness == Brightness.dark
            ? ThemeMode.light
            : ThemeMode.dark;
      case ThemeMode.light:
        nuevoModo = ThemeMode.dark;
      case ThemeMode.dark:
        nuevoModo = ThemeMode.light;
    }

    state = AsyncData(nuevoModo);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModePrefsKey, nuevoModo.name);
  }
}

final themeModeProvider = AsyncNotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);
