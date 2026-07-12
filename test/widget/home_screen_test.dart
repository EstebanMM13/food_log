import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:proyecto_food_log/data/local/app_database.dart';
import 'package:proyecto_food_log/data/repositories/plato_repository_impl.dart';
import 'package:proyecto_food_log/data/repositories/restaurante_repository_impl.dart';
import 'package:proyecto_food_log/presentation/providers/database_provider.dart';
import 'package:proyecto_food_log/presentation/screens/home_screen.dart';

void main() {
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
    await restaurantes.insert(nombre: 'Pekín', ubicacion: 'Castellón de la Plana', tags: ['Chino']);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: const MaterialApp(home: HomeScreen()),
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
}
