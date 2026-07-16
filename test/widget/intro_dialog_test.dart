import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:proyecto_food_log/core/theme/app_theme.dart';
import 'package:proyecto_food_log/data/local/app_database.dart';
import 'package:proyecto_food_log/presentation/providers/database_provider.dart';
import 'package:proyecto_food_log/presentation/screens/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/fake_path_provider.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});

    // The intro dialog's "cargar restaurantes de prueba" checkbox now copies
    // bundled sample photos through PhotoStorage, which resolves its folder
    // via path_provider — point that at a disposable temp folder, same as
    // the repository tests do.
    tempDir = await Directory.systemTemp.createTemp('food_log_test_');
    PathProviderPlatform.instance = FakePathProviderPlatform(tempDir.path);
  });

  tearDown(() => tempDir.delete(recursive: true));

  testWidgets('checking "cargar restaurantes de prueba" seeds sample data', (
    tester,
  ) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());

    // Cards are taller in the "Cuaderno" redesign (full-bleed cover photo),
    // so the default test viewport isn't tall enough to lazily build every
    // sample restaurant's card. A taller viewport keeps this test about
    // seeding data, not about scrolling a list.
    tester.view.physicalSize = const Size(400, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: MaterialApp(theme: AppTheme.light, home: const HomeScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('¡Bienvenido a Food Log!'), findsOneWidget);

    await tester.tap(find.text('Cargar restaurantes de prueba'));
    await tester.pump();
    await tester.tap(find.text('No volver a mostrar'));

    // Checking the box seeds data through real asset reads + file writes
    // (bundled sample photos), then marks the intro as dismissed. Two
    // things need to happen for that to be observable here: pending tap
    // gesture recognizers need a pump() to resolve (a widget test's clock
    // is fake, driven only by pump), and the real I/O needs actual
    // wall-clock time to finish (which pump() alone can't provide). Poll
    // the real state — DB rows plus the prefs write — while interleaving
    // both, instead of guessing a fixed wait.
    final prefs = await SharedPreferences.getInstance();
    for (var i = 0; i < 100; i++) {
      final seeded = await db.select(db.restaurantes).get();
      if (seeded.length >= 5 && prefs.getBool('intro_dismissed') == true) {
        break;
      }
      await tester.pump(const Duration(milliseconds: 50));
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
    }
    await tester.pumpAndSettle();

    expect(find.text('Casa Marina'), findsOneWidget);
    expect(prefs.getBool('intro_dismissed'), isTrue);

    await db.close();
  });

  testWidgets(
    'dialog does not reappear once dismissed, but stays reachable from the menu',
    (tester) async {
      SharedPreferences.setMockInitialValues({'intro_dismissed': true});
      final db = AppDatabase.forTesting(NativeDatabase.memory());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [databaseProvider.overrideWithValue(db)],
          child: MaterialApp(theme: AppTheme.light, home: const HomeScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('¡Bienvenido a Food Log!'), findsNothing);

      await tester.tap(find.byTooltip('Más opciones'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Acerca de Food Log'));
      await tester.pumpAndSettle();

      expect(find.text('¡Bienvenido a Food Log!'), findsOneWidget);

      await db.close();
    },
  );
}
