import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:proyecto_food_log/data/local/app_database.dart';
import 'package:proyecto_food_log/data/local/sample_data.dart';
import 'package:proyecto_food_log/data/repositories/plato_repository_impl.dart';
import 'package:proyecto_food_log/data/repositories/restaurante_repository_impl.dart';

import '../support/fake_path_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late RestauranteRepositoryImpl restaurantes;
  late PlatoRepositoryImpl platos;
  late Directory tempDir;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    restaurantes = RestauranteRepositoryImpl(db);
    platos = PlatoRepositoryImpl(db);

    // cargarRestaurantesDeMuestra() now copies bundled sample photos through
    // PhotoStorage, which resolves its folder via path_provider — point that
    // at a disposable temp folder, same as the repository tests do.
    tempDir = await Directory.systemTemp.createTemp('food_log_test_');
    PathProviderPlatform.instance = FakePathProviderPlatform(tempDir.path);
  });

  tearDown(() async {
    await db.close();
    await tempDir.delete(recursive: true);
  });

  test('loading twice does not duplicate the sample restaurants', () async {
    await cargarRestaurantesDeMuestra(
      restaurantes: restaurantes,
      platos: platos,
    );
    final primeraCarga = await restaurantes.watchAll().first;

    await cargarRestaurantesDeMuestra(
      restaurantes: restaurantes,
      platos: platos,
    );
    final segundaCarga = await restaurantes.watchAll().first;

    expect(segundaCarga, hasLength(primeraCarga.length));
  });

  test(
    'reloading after deleting some only reinserts the missing ones',
    () async {
      await cargarRestaurantesDeMuestra(
        restaurantes: restaurantes,
        platos: platos,
      );
      final cargados = await restaurantes.watchAll().first;
      final total = cargados.length;

      await restaurantes.delete(cargados.first.id);
      expect(await restaurantes.watchAll().first, hasLength(total - 1));

      await cargarRestaurantesDeMuestra(
        restaurantes: restaurantes,
        platos: platos,
      );
      final restaurado = await restaurantes.watchAll().first;

      expect(restaurado, hasLength(total));
      expect(restaurado.map((r) => r.nombre).toSet().length, total);
    },
  );
}
