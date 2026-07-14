import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:proyecto_food_log/core/theme/app_theme.dart';
import 'package:proyecto_food_log/data/local/app_database.dart';
import 'package:proyecto_food_log/presentation/providers/database_provider.dart';
import 'package:proyecto_food_log/presentation/screens/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

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
    await tester.tap(find.text('No volver a mostrar'));
    await tester.pumpAndSettle();

    expect(find.text('La Pepica'), findsOneWidget);

    final prefs = await SharedPreferences.getInstance();
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
