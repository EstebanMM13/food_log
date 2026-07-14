import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:proyecto_food_log/core/theme/app_theme.dart';
import 'package:proyecto_food_log/data/local/app_database.dart';
import 'package:proyecto_food_log/data/repositories/plato_repository_impl.dart';
import 'package:proyecto_food_log/data/repositories/restaurante_repository_impl.dart';
import 'package:proyecto_food_log/presentation/providers/database_provider.dart';
import 'package:proyecto_food_log/presentation/screens/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('HomeScreen renders seeded restaurants', (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    final restaurantes = RestauranteRepositoryImpl(db);
    final platos = PlatoRepositoryImpl(db);

    final camelotId = await restaurantes.insert(
      nombre: 'Camelot',
      ubicacion: 'Castellón de la Plana',
      tags: ['Español'],
      visitas: 7,
    );
    await platos.insert(
      restauranteId: camelotId,
      tipo: 'Entrante',
      nombre: 'Patatas con queso y bacon',
      puntuacion: 9,
    );
    await restaurantes.insert(
      nombre: 'Pekín',
      ubicacion: 'Castellón de la Plana',
      tags: ['Chino'],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: MaterialApp(theme: AppTheme.light, home: const HomeScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Camelot'), findsOneWidget);
    expect(find.text('Pekín'), findsOneWidget);

    // drift schedules an internal Timer to close its query stream cache a
    // moment after the last listener unsubscribes. Awaiting close() here
    // (before the test body returns) lets that timer fire in time; closing
    // only in addTearDown runs too late and trips flutter_test's pending
    // timer assertion.
    await db.close();
  });

  testWidgets('theme toggle button flips explicit light/dark mode', (
    tester,
  ) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());

    tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: MaterialApp(theme: AppTheme.light, home: const HomeScreen()),
      ),
    );
    await tester.pumpAndSettle();

    // First launch shows the intro dialog on top of everything else; dismiss
    // it before interacting with the AppBar underneath.
    await tester.tap(find.text('Entendido'));
    await tester.pumpAndSettle();

    // Follows the system, which is currently light -> shows the "moon" icon
    // (tapping it switches to explicit dark).
    expect(find.byIcon(Icons.dark_mode), findsOneWidget);
    expect(find.byIcon(Icons.light_mode), findsNothing);

    await tester.tap(find.byIcon(Icons.dark_mode));
    await tester.pumpAndSettle();

    // Now explicitly dark -> shows the "sun" icon (tapping it switches back
    // to explicit light).
    expect(find.byIcon(Icons.light_mode), findsOneWidget);
    expect(find.byIcon(Icons.dark_mode), findsNothing);

    await db.close();
  });

  testWidgets('sort menu reorders restaurants by visit count', (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    final restaurantes = RestauranteRepositoryImpl(db);

    // "Bistro" sorts first alphabetically but has the fewest visits;
    // "Zafiro" sorts last alphabetically but has the most visits. Picking
    // "Más visitados" must flip their relative order.
    await restaurantes.insert(nombre: 'Bistro', visitas: 1);
    await restaurantes.insert(nombre: 'Zafiro', visitas: 9);

    tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: MaterialApp(theme: AppTheme.light, home: const HomeScreen()),
      ),
    );
    await tester.pumpAndSettle();

    // First launch shows the intro dialog; dismiss it before interacting
    // with the header underneath.
    await tester.tap(find.text('Entendido'));
    await tester.pumpAndSettle();

    // Default order is alphabetical: "Bistro" above "Zafiro".
    final yBistroAntes = tester.getCenter(find.text('Bistro')).dy;
    final yZafiroAntes = tester.getCenter(find.text('Zafiro')).dy;
    expect(yBistroAntes, lessThan(yZafiroAntes));

    await tester.tap(find.byIcon(Icons.sort));
    await tester.pumpAndSettle();
    // CheckedPopupMenuItem's Text is not itself the hit-test target (its
    // ancestor InkWell/_RenderMenuItem is) — warnIfMissed: false silences
    // Flutter's benign warning about that without masking real failures.
    await tester.tap(find.text('Más visitados'), warnIfMissed: false);
    await tester.pumpAndSettle();

    // "Zafiro" has more visits than "Bistro", so it must now come first.
    final yBistroDespues = tester.getCenter(find.text('Bistro')).dy;
    final yZafiroDespues = tester.getCenter(find.text('Zafiro')).dy;
    expect(yZafiroDespues, lessThan(yBistroDespues));

    await db.close();
  });
}
