import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:proyecto_food_log/presentation/providers/theme_mode_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('defaults to ThemeMode.system when nothing is saved', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final mode = await container.read(themeModeProvider.future);
    expect(mode, ThemeMode.system);
  });

  test('loads a previously saved explicit mode on start', () async {
    SharedPreferences.setMockInitialValues({'theme_mode': 'dark'});
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final mode = await container.read(themeModeProvider.future);
    expect(mode, ThemeMode.dark);
  });

  test('toggle from system picks the opposite of the visible brightness', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await container.read(themeModeProvider.future);

    await container.read(themeModeProvider.notifier).toggle(Brightness.dark);
    expect(container.read(themeModeProvider).value, ThemeMode.light);
  });

  test('toggle flips explicit light/dark and persists the change', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await container.read(themeModeProvider.future);

    await container.read(themeModeProvider.notifier).toggle(Brightness.light);
    expect(container.read(themeModeProvider).value, ThemeMode.dark);

    await container.read(themeModeProvider.notifier).toggle(Brightness.dark);
    expect(container.read(themeModeProvider).value, ThemeMode.light);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('theme_mode'), 'light');
  });
}
