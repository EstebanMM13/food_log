import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:proyecto_food_log/core/theme/app_theme.dart';
import 'package:proyecto_food_log/data/local/app_database.dart';
import 'package:proyecto_food_log/data/repositories/plato_repository_impl.dart';
import 'package:proyecto_food_log/data/repositories/restaurante_repository_impl.dart';
import 'package:proyecto_food_log/presentation/providers/database_provider.dart';
import 'package:proyecto_food_log/presentation/screens/restaurante_detail_screen.dart';

void main() {
  testWidgets('RestauranteDetailScreen renders name, tags and dish sections', (
    tester,
  ) async {
    // The screen body is a plain (non-lazy) ListView; the cover photo alone
    // pushes the tags/dish sections out of a normal 600pt test surface's
    // build+cache window. Growing the surface avoids scrolling just to
    // assert on content further down.
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final db = AppDatabase.forTesting(NativeDatabase.memory());
    final restaurantes = RestauranteRepositoryImpl(db);
    final platos = PlatoRepositoryImpl(db);

    final id = await restaurantes.insert(
      nombre: 'Camelot',
      ubicacion: 'Castellón',
      tags: ['Español'],
    );
    await platos.insert(restauranteId: id, tipo: 'Entrante', nombre: 'Patatas', puntuacion: 9);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          theme: AppTheme.light,
          home: RestauranteDetailScreen(restauranteId: id),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Camelot'), findsOneWidget);
    expect(find.text('Español'), findsOneWidget);
    // The section heading reads "Platos"; the "principales" category card
    // underneath it renders its label as an uppercase kicker ("PLATOS").
    expect(find.text('Platos'), findsOneWidget);
    expect(find.text('PLATOS'), findsOneWidget);
    expect(find.text('ENTRANTES'), findsOneWidget);

    await db.close();
  });

  testWidgets(
    'tapping the edit-visits button opens the "Corregir visitas" dialog to correct the count',
    (tester) async {
      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final db = AppDatabase.forTesting(NativeDatabase.memory());
      final restaurantes = RestauranteRepositoryImpl(db);

      final id = await restaurantes.insert(nombre: 'Camelot', visitas: 3);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [databaseProvider.overrideWithValue(db)],
          child: MaterialApp(
            theme: AppTheme.light,
            home: RestauranteDetailScreen(restauranteId: id),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('3'), findsOneWidget);

      // The Notas section also renders an `edit_outlined` icon (its empty
      // "Añadir una nota…" prompt row), so a plain `find.byIcon` is now
      // ambiguous. Disambiguate via the button's own key.
      await tester.tap(find.byKey(const Key('editar-visitas-button')));
      await tester.pumpAndSettle();

      expect(find.text('Corregir visitas'), findsOneWidget);

      await tester.enterText(find.byType(TextField), '4');
      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();

      expect(find.text('4'), findsOneWidget);
      expect(find.text('3'), findsNothing);

      final actualizado = await restaurantes.getById(id);
      expect(actualizado!.visitas, 4);

      await db.close();
    },
  );
}
