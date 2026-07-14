import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:proyecto_food_log/core/photo_storage.dart';
import 'package:proyecto_food_log/data/local/app_database.dart';
import 'package:proyecto_food_log/data/repositories/plato_repository_impl.dart';
import 'package:proyecto_food_log/data/repositories/restaurante_repository_impl.dart';

import '../support/fake_path_provider.dart';

void main() {
  late AppDatabase db;
  late RestauranteRepositoryImpl restaurantes;
  late PlatoRepositoryImpl platos;
  late Directory tempDir;
  late String restauranteId;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    restaurantes = RestauranteRepositoryImpl(db);
    platos = PlatoRepositoryImpl(db);

    tempDir = await Directory.systemTemp.createTemp('food_log_test_');
    PathProviderPlatform.instance = FakePathProviderPlatform(tempDir.path);

    restauranteId = await restaurantes.insert(nombre: 'Camelot');
  });

  tearDown(() async {
    await db.close();
    await tempDir.delete(recursive: true);
  });

  /// Creates a small fake "picked" image file in [tempDir] and copies it into
  /// [PhotoStorage]'s managed folder, the same way `PhotoPickerField` does.
  Future<String> crearFoto(String nombreArchivo) async {
    final origen = File(p.join(tempDir.path, nombreArchivo));
    await origen.writeAsString('contenido falso de imagen: $nombreArchivo');
    return PhotoStorage.guardar(origen);
  }

  test('a dish photo persists after insert and read back', () async {
    final fotoPath = await crearFoto('patatas.jpg');

    final id = await platos.insert(
      restauranteId: restauranteId,
      tipo: 'Entrante',
      nombre: 'Patatas con queso y bacon',
      puntuacion: 9,
      fotoPath: fotoPath,
    );

    final lista = await platos.watchByRestaurante(restauranteId).first;
    final leido = lista.firstWhere((d) => d.id == id);

    expect(leido.fotoPath, fotoPath);
    expect(File(fotoPath).existsSync(), isTrue);
  });

  test('update deletes the old dish photo file when replaced', () async {
    final fotoAntigua = await crearFoto('antigua.jpg');
    final fotoNueva = await crearFoto('nueva.jpg');

    final id = await platos.insert(
      restauranteId: restauranteId,
      tipo: 'Entrante',
      nombre: 'Patatas con queso y bacon',
      puntuacion: 9,
      fotoPath: fotoAntigua,
    );
    final actual = (await platos.watchByRestaurante(restauranteId).first)
        .firstWhere((d) => d.id == id);

    await platos.update(actual.copyWith(fotoPath: Value(fotoNueva)));

    expect(File(fotoAntigua).existsSync(), isFalse);
    expect(File(fotoNueva).existsSync(), isTrue);
    final actualizado = (await platos.watchByRestaurante(restauranteId).first)
        .firstWhere((d) => d.id == id);
    expect(actualizado.fotoPath, fotoNueva);
  });

  test(
    'update keeps the photo file when fotoPath is passed unchanged',
    () async {
      final foto = await crearFoto('igual.jpg');

      final id = await platos.insert(
        restauranteId: restauranteId,
        tipo: 'Entrante',
        nombre: 'Patatas con queso y bacon',
        puntuacion: 9,
        fotoPath: foto,
      );
      final actual = (await platos.watchByRestaurante(restauranteId).first)
          .firstWhere((d) => d.id == id);

      await platos.update(actual.copyWith(nombre: 'Patatas bravas'));

      expect(File(foto).existsSync(), isTrue);
    },
  );

  test('delete removes the dish photo file', () async {
    final fotoPath = await crearFoto('pollo.jpg');

    final id = await platos.insert(
      restauranteId: restauranteId,
      tipo: 'Principal',
      nombre: 'Pollo frito',
      puntuacion: 9,
      fotoPath: fotoPath,
    );

    await platos.delete(id);

    expect(File(fotoPath).existsSync(), isFalse);
    expect(await platos.watchByRestaurante(restauranteId).first, isEmpty);
  });
}
