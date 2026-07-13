import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:proyecto_food_log/data/local/app_database.dart';
import 'package:proyecto_food_log/data/local/sample_data.dart';
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

  test('loading twice does not duplicate the sample restaurants', () async {
    await cargarRestaurantesDeMuestra(restaurantes: restaurantes, platos: platos);
    final primeraCarga = await restaurantes.watchAll().first;

    await cargarRestaurantesDeMuestra(restaurantes: restaurantes, platos: platos);
    final segundaCarga = await restaurantes.watchAll().first;

    expect(segundaCarga, hasLength(primeraCarga.length));
  });

  test('reloading after deleting some only reinserts the missing ones', () async {
    await cargarRestaurantesDeMuestra(restaurantes: restaurantes, platos: platos);
    final cargados = await restaurantes.watchAll().first;
    final total = cargados.length;

    await restaurantes.delete(cargados.first.id);
    expect(await restaurantes.watchAll().first, hasLength(total - 1));

    await cargarRestaurantesDeMuestra(restaurantes: restaurantes, platos: platos);
    final restaurado = await restaurantes.watchAll().first;

    expect(restaurado, hasLength(total));
    expect(restaurado.map((r) => r.nombre).toSet().length, total);
  });
}
