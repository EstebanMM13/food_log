import 'dart:io';

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

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    restaurantes = RestauranteRepositoryImpl(db);
    platos = PlatoRepositoryImpl(db);

    // PhotoStorage copies files under the app's documents directory, which
    // it resolves via path_provider. Point that at a disposable temp folder
    // so photo tests touch a real (but throwaway) directory.
    tempDir = await Directory.systemTemp.createTemp('food_log_test_');
    PathProviderPlatform.instance = FakePathProviderPlatform(tempDir.path);
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

    await restaurantes.update(
      id: id,
      nombre: 'Capri',
      tags: ['Italiano', 'Pizzeria'],
      fotoPath: null,
    );

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

  test('a restaurant photo persists after insert and read back', () async {
    final fotoPath = await crearFoto('camelot.jpg');

    final id = await restaurantes.insert(nombre: 'Camelot', fotoPath: fotoPath);
    final leido = await restaurantes.getById(id);

    expect(leido, isNotNull);
    expect(leido!.fotoPath, fotoPath);
    expect(File(fotoPath).existsSync(), isTrue);
  });

  test('update deletes the old restaurant photo file when replaced', () async {
    final fotoAntigua = await crearFoto('antigua.jpg');
    final fotoNueva = await crearFoto('nueva.jpg');
    final id = await restaurantes.insert(nombre: 'Camelot', fotoPath: fotoAntigua);

    await restaurantes.update(id: id, nombre: 'Camelot', fotoPath: fotoNueva);

    expect(File(fotoAntigua).existsSync(), isFalse);
    expect(File(fotoNueva).existsSync(), isTrue);
    final leido = await restaurantes.getById(id);
    expect(leido!.fotoPath, fotoNueva);
  });

  test('update keeps the photo file when fotoPath is passed unchanged', () async {
    final foto = await crearFoto('igual.jpg');
    final id = await restaurantes.insert(nombre: 'Camelot', fotoPath: foto);

    await restaurantes.update(id: id, nombre: 'Camelot renombrado', fotoPath: foto);

    expect(File(foto).existsSync(), isTrue);
  });

  test(
    'delete removes the restaurant photo and every dish photo underneath it',
    () async {
      final fotoRestaurante = await crearFoto('restaurante.jpg');
      final fotoPlatoUno = await crearFoto('plato1.jpg');
      final fotoPlatoDos = await crearFoto('plato2.jpg');

      final id = await restaurantes.insert(nombre: 'Pekín', fotoPath: fotoRestaurante);
      await platos.insert(
        restauranteId: id,
        tipo: 'Principal',
        nombre: 'Pollo frito',
        puntuacion: 9,
        fotoPath: fotoPlatoUno,
      );
      await platos.insert(
        restauranteId: id,
        tipo: 'Postre',
        nombre: 'Helado frito',
        puntuacion: 8,
        fotoPath: fotoPlatoDos,
      );

      await restaurantes.delete(id);

      expect(File(fotoRestaurante).existsSync(), isFalse);
      expect(File(fotoPlatoUno).existsSync(), isFalse);
      expect(File(fotoPlatoDos).existsSync(), isFalse);
    },
  );
}
