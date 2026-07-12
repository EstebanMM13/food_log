import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:proyecto_food_log/data/local/app_database.dart';
import 'package:proyecto_food_log/data/repositories/plato_repository_impl.dart';
import 'package:proyecto_food_log/data/repositories/restaurante_repository_impl.dart';

void main() {
  late AppDatabase db;
  late RestauranteRepositoryImpl restaurantes;
  late PlatoRepositoryImpl platos;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    restaurantes = RestauranteRepositoryImpl(db);
    platos = PlatoRepositoryImpl(db);
  });

  tearDown(() => db.close());

  test('insert + watchAll returns the new restaurant', () async {
    final id = await restaurantes.insert(
      nombre: 'Camelot',
      ubicacion: 'Castellón de la Plana',
      tags: ['Español'],
      visitas: 7,
    );

    final lista = await restaurantes.watchAll().first;

    expect(lista, hasLength(1));
    expect(lista.single.id, id);
    expect(lista.single.nombre, 'Camelot');
    expect(lista.single.visitas, 7);
  });

  test('a dish inserted for a restaurant shows up on query', () async {
    final id = await restaurantes.insert(nombre: 'Camelot');

    await platos.insert(
      restauranteId: id,
      tipo: 'Entrante',
      nombre: 'Patatas con queso y bacon',
      puntuacion: 9,
    );

    final platosDelRestaurante = await platos.watchByRestaurante(id).first;

    expect(platosDelRestaurante, hasLength(1));
    expect(platosDelRestaurante.single.nombre, 'Patatas con queso y bacon');
    expect(platosDelRestaurante.single.puntuacion, 9.0);
  });

  test('update replaces the restaurant tag set', () async {
    final id = await restaurantes.insert(nombre: 'Capri', tags: ['Italiano']);

    await restaurantes.update(id: id, nombre: 'Capri', tags: ['Italiano', 'Pizzeria']);

    final tags = await restaurantes.watchTagsFor(id).first;
    expect(tags.map((t) => t.nombre).toSet(), {'Italiano', 'Pizzeria'});
  });

  test('delete removes the restaurant and its dishes', () async {
    final id = await restaurantes.insert(nombre: 'Pekín');
    await platos.insert(restauranteId: id, tipo: 'Principal', nombre: 'Pollo frito', puntuacion: 9);

    await restaurantes.delete(id);

    expect(await restaurantes.watchAll().first, isEmpty);
    expect(await platos.watchByRestaurante(id).first, isEmpty);
  });
}
