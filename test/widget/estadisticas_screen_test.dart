import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:proyecto_food_log/core/theme/app_theme.dart';
import 'package:proyecto_food_log/data/local/app_database.dart';
import 'package:proyecto_food_log/data/repositories/plato_repository_impl.dart';
import 'package:proyecto_food_log/data/repositories/restaurante_repository_impl.dart';
import 'package:proyecto_food_log/presentation/providers/database_provider.dart';
import 'package:proyecto_food_log/presentation/screens/estadisticas_screen.dart';

void main() {
  testWidgets('EstadisticasScreen renders every section, "Tags más usados" '
      'included, with an empty-state placeholder when there is no data '
      'yet (regression: it used to hide the whole card instead)', (
    tester,
  ) async {
    // The screen body is a plain (non-lazy) ListView, but Flutter still only
    // builds sliver children within the viewport + cache extent — a normal
    // 600pt-tall test surface cuts off the later cards. Growing the surface
    // to fit all five cards avoids scrolling gymnastics just to assert they
    // rendered.
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final db = AppDatabase.forTesting(NativeDatabase.memory());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: MaterialApp(theme: AppTheme.light, home: const EstadisticasScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Estadísticas'), findsOneWidget);
    expect(find.text('Más visitados'), findsOneWidget);
    expect(find.text('Mejor valorados'), findsOneWidget);
    expect(find.text('Platos más repetidos'), findsOneWidget);
    expect(find.text('Restaurantes por ubicación'), findsOneWidget);
    // The card itself must always render, same as its four siblings...
    expect(find.text('Tags más usados'), findsOneWidget);
    // ...and show the shared empty state, not disappear, when there's no data.
    expect(find.text('Aún no hay datos.'), findsNWidgets(5));

    await db.close();
  });

  testWidgets('EstadisticasScreen shows tag counts once restaurants have tags', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final db = AppDatabase.forTesting(NativeDatabase.memory());
    final restaurantes = RestauranteRepositoryImpl(db);
    final platos = PlatoRepositoryImpl(db);

    final id = await restaurantes.insert(nombre: 'Camelot', tags: ['Español']);
    await platos.insert(restauranteId: id, tipo: 'Entrante', nombre: 'Patatas', puntuacion: 9);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: MaterialApp(theme: AppTheme.light, home: const EstadisticasScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Tags más usados'), findsOneWidget);
    expect(find.textContaining('Español'), findsOneWidget);

    await db.close();
  });
}
