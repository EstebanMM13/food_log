import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:proyecto_food_log/core/photo_storage.dart';
import 'package:proyecto_food_log/data/local/app_database.dart';
import 'package:proyecto_food_log/data/local/backup_service.dart';
import 'package:proyecto_food_log/data/repositories/categoria_repository_impl.dart';
import 'package:proyecto_food_log/data/repositories/plato_repository_impl.dart';
import 'package:proyecto_food_log/data/repositories/recordatorio_repository_impl.dart';
import 'package:proyecto_food_log/data/repositories/restaurante_repository_impl.dart';

import '../support/fake_path_provider.dart';

void main() {
  late AppDatabase db;
  late RestauranteRepositoryImpl restaurantes;
  late PlatoRepositoryImpl platos;
  late RecordatorioRepositoryImpl recordatorios;
  late CategoriaRepositoryImpl categorias;
  late Directory tempDir;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    restaurantes = RestauranteRepositoryImpl(db);
    platos = PlatoRepositoryImpl(db);
    recordatorios = RecordatorioRepositoryImpl(db);
    categorias = CategoriaRepositoryImpl(db);

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

  test('export produces a JSON payload with every related entity', () async {
    final id = await restaurantes.insert(
      nombre: 'Camelot',
      ubicacion: 'Castellón de la Plana',
      notas: 'Sitio genial',
      tags: ['Español'],
      visitas: 3,
    );
    await platos.insert(
      restauranteId: id,
      tipo: 'Entrante',
      nombre: 'Patatas con queso y bacon',
      puntuacion: 9,
      comentario: 'Repetible',
    );
    await recordatorios.insert(restauranteId: id, texto: 'Pedir postre');
    await categorias.insert(restauranteId: id, nombre: 'Bebidas');

    final json = await exportDatabaseToJson(
      restaurantes: restaurantes,
      platos: platos,
      recordatorios: recordatorios,
      categorias: categorias,
    );

    final data = jsonDecode(json) as Map<String, dynamic>;
    expect(data['version'], backupFormatVersion);
    final lista = data['restaurantes'] as List;
    expect(lista, hasLength(1));

    final restaurante = lista.single as Map<String, dynamic>;
    expect(restaurante['nombre'], 'Camelot');
    expect(restaurante['tags'], ['Español']);
    expect(restaurante['fotoPath'], isNull);
    expect((restaurante['platos'] as List), hasLength(1));
    expect((restaurante['recordatorios'] as List), hasLength(1));
    expect((restaurante['categorias'] as List), hasLength(1));
  });

  test(
    'export stores only the photo file name, never the absolute path',
    () async {
      final fotoRestaurante = await crearFoto('camelot.jpg');
      final fotoPlato = await crearFoto('patatas.jpg');

      final id = await restaurantes.insert(
        nombre: 'Camelot',
        fotoPath: fotoRestaurante,
      );
      await platos.insert(
        restauranteId: id,
        tipo: 'Entrante',
        nombre: 'Patatas con queso y bacon',
        puntuacion: 9,
        fotoPath: fotoPlato,
      );

      final json = await exportDatabaseToJson(
        restaurantes: restaurantes,
        platos: platos,
        recordatorios: recordatorios,
        categorias: categorias,
      );

      final data = jsonDecode(json) as Map<String, dynamic>;
      final restaurante =
          (data['restaurantes'] as List).single as Map<String, dynamic>;
      // PhotoStorage.guardar() renames the file to a fresh UUID (keeping the
      // extension) when copying it into app storage, so the exported name is
      // that UUID-based name, not the original picked file name.
      expect(restaurante['fotoPath'], p.basename(fotoRestaurante));
      final plato =
          (restaurante['platos'] as List).single as Map<String, dynamic>;
      expect(plato['fotoPath'], p.basename(fotoPlato));
    },
  );

  test(
    'import inserts new restaurants with fresh ids from a JSON payload',
    () async {
      const raw = '''
    {
      "version": 1,
      "restaurantes": [
        {
          "nombre": "Pekín",
          "ubicacion": "Madrid",
          "visitas": 5,
          "tags": ["Chino", "Pekin"],
          "platos": [
            {"tipo": "Principal", "nombre": "Pollo frito", "puntuacion": 8.5, "comentario": null}
          ],
          "recordatorios": [
            {"texto": "Pedir arroz tres delicias", "hecho": true}
          ],
          "categorias": [
            {"nombre": "Entrantes fríos", "orden": 0}
          ]
        }
      ]
    }
    ''';

      final resumen = await importDatabaseFromJson(
        raw,
        db: db,
        restaurantes: restaurantes,
        platos: platos,
        recordatorios: recordatorios,
        categorias: categorias,
      );

      expect(resumen.restaurantes, 1);
      expect(resumen.platos, 1);
      expect(resumen.recordatorios, 1);
      expect(resumen.categorias, 1);

      final lista = await restaurantes.watchAll().first;
      expect(lista, hasLength(1));
      final restaurante = lista.single;
      expect(restaurante.nombre, 'Pekín');
      expect(restaurante.visitas, 5);

      final tags = await restaurantes.watchTagsFor(restaurante.id).first;
      expect(tags.map((t) => t.nombre).toSet(), {'Chino', 'Pekin'});

      final platosImportados = await platos
          .watchByRestaurante(restaurante.id)
          .first;
      expect(platosImportados, hasLength(1));
      expect(platosImportados.single.nombre, 'Pollo frito');

      final recordatoriosImportados = await recordatorios
          .watchByRestaurante(restaurante.id)
          .first;
      expect(recordatoriosImportados, hasLength(1));
      expect(recordatoriosImportados.single.hecho, isTrue);

      final categoriasImportadas = await categorias
          .watchByRestaurante(restaurante.id)
          .first;
      expect(categoriasImportadas, hasLength(1));
      expect(categoriasImportadas.single.nombre, 'Entrantes fríos');
    },
  );

  test(
    'importing an exported payload roundtrips as a duplicate, not a merge',
    () async {
      final id = await restaurantes.insert(nombre: 'Capri', tags: ['Italiano']);
      await platos.insert(
        restauranteId: id,
        tipo: 'Entrante',
        nombre: 'Bruschetta',
        puntuacion: 7,
      );

      final json = await exportDatabaseToJson(
        restaurantes: restaurantes,
        platos: platos,
        recordatorios: recordatorios,
        categorias: categorias,
      );

      await importDatabaseFromJson(
        json,
        db: db,
        restaurantes: restaurantes,
        platos: platos,
        recordatorios: recordatorios,
        categorias: categorias,
      );

      final lista = await restaurantes.watchAll().first;
      expect(lista, hasLength(2));
      expect(lista.map((r) => r.id).toSet(), hasLength(2));
      expect(lista.every((r) => r.nombre == 'Capri'), isTrue);
    },
  );

  test(
    'exportarComoZip bundles backup.json plus every referenced photo',
    () async {
      final fotoRestaurante = await crearFoto('camelot.jpg');
      final fotoPlato = await crearFoto('patatas.jpg');

      final id = await restaurantes.insert(
        nombre: 'Camelot',
        fotoPath: fotoRestaurante,
      );
      await platos.insert(
        restauranteId: id,
        tipo: 'Entrante',
        nombre: 'Patatas con queso y bacon',
        puntuacion: 9,
        fotoPath: fotoPlato,
      );

      final zipBytes = await exportarComoZip(
        restaurantes: restaurantes,
        platos: platos,
        recordatorios: recordatorios,
        categorias: categorias,
      );

      final archive = ZipDecoder().decodeBytes(zipBytes);
      final backupJson = archive.findFile('backup.json');
      expect(backupJson, isNotNull);

      final data =
          jsonDecode(utf8.decode(backupJson!.content)) as Map<String, dynamic>;
      expect(data['version'], backupFormatVersion);

      final fotoRestauranteEntrada = archive.findFile(
        'fotos/${p.basename(fotoRestaurante)}',
      );
      final fotoPlatoEntrada = archive.findFile(
        'fotos/${p.basename(fotoPlato)}',
      );
      expect(fotoRestauranteEntrada, isNotNull);
      expect(fotoPlatoEntrada, isNotNull);
      expect(
        utf8.decode(fotoRestauranteEntrada!.content),
        'contenido falso de imagen: camelot.jpg',
      );
      expect(
        utf8.decode(fotoPlatoEntrada!.content),
        'contenido falso de imagen: patatas.jpg',
      );
    },
  );

  test(
    'exportarComoZip skips a fotoPath whose file was deleted by hand',
    () async {
      final fotoRestaurante = await crearFoto('borrada.jpg');
      await File(fotoRestaurante).delete();

      await restaurantes.insert(nombre: 'Camelot', fotoPath: fotoRestaurante);

      final zipBytes = await exportarComoZip(
        restaurantes: restaurantes,
        platos: platos,
        recordatorios: recordatorios,
        categorias: categorias,
      );

      final archive = ZipDecoder().decodeBytes(zipBytes);
      expect(archive.findFile('fotos/${p.basename(fotoRestaurante)}'), isNull);
      expect(archive.files.where((f) => f.name.startsWith('fotos/')), isEmpty);
    },
  );

  test(
    'importarDesdeZip copies photos into app storage and points fotoPath at the copies',
    () async {
      final fotoRestaurante = await crearFoto('camelot.jpg');
      final fotoPlato = await crearFoto('patatas.jpg');

      final id = await restaurantes.insert(
        nombre: 'Camelot',
        fotoPath: fotoRestaurante,
      );
      await platos.insert(
        restauranteId: id,
        tipo: 'Entrante',
        nombre: 'Patatas con queso y bacon',
        puntuacion: 9,
        fotoPath: fotoPlato,
      );

      final zipBytes = await exportarComoZip(
        restaurantes: restaurantes,
        platos: platos,
        recordatorios: recordatorios,
        categorias: categorias,
      );

      final resumen = await importarDesdeZip(
        zipBytes,
        db: db,
        restaurantes: restaurantes,
        platos: platos,
        recordatorios: recordatorios,
        categorias: categorias,
      );

      expect(resumen.restaurantes, 1);
      expect(resumen.platos, 1);

      final lista = await restaurantes.watchAll().first;
      // The original plus the just-imported duplicate.
      expect(lista, hasLength(2));
      final importado = lista.firstWhere((r) => r.id != id);

      // guardarBytes always writes the imported photo under a fresh,
      // independent name — it never reuses the zip's literal file name (nor
      // any other file already in storage). The imported row's fotoPath must
      // therefore point at a *different* file than the original's, even
      // though both hold the same bytes.
      expect(importado.fotoPath, isNotNull);
      expect(importado.fotoPath, isNot(fotoRestaurante));
      expect(File(importado.fotoPath!).existsSync(), isTrue);
      expect(
        await File(importado.fotoPath!).readAsString(),
        'contenido falso de imagen: camelot.jpg',
      );

      final platosImportados = await platos
          .watchByRestaurante(importado.id)
          .first;
      expect(platosImportados, hasLength(1));
      final platoImportado = platosImportados.single;
      expect(platoImportado.fotoPath, isNotNull);
      expect(platoImportado.fotoPath, isNot(fotoPlato));
      expect(File(platoImportado.fotoPath!).existsSync(), isTrue);
    },
  );

  test(
    'importing the same zip twice keeps each duplicate\'s photo independent',
    () async {
      final fotoRestaurante = await crearFoto('camelot.jpg');

      final idOriginal = await restaurantes.insert(
        nombre: 'Camelot',
        fotoPath: fotoRestaurante,
      );

      final zipBytes = await exportarComoZip(
        restaurantes: restaurantes,
        platos: platos,
        recordatorios: recordatorios,
        categorias: categorias,
      );

      // Import the very same zip twice: with "duplicate, never merge" as the
      // import philosophy, this must produce two brand new restaurant rows
      // (plus the original), each backed by its own photo file.
      await importarDesdeZip(
        zipBytes,
        db: db,
        restaurantes: restaurantes,
        platos: platos,
        recordatorios: recordatorios,
        categorias: categorias,
      );
      await importarDesdeZip(
        zipBytes,
        db: db,
        restaurantes: restaurantes,
        platos: platos,
        recordatorios: recordatorios,
        categorias: categorias,
      );

      final lista = await restaurantes.watchAll().first;
      expect(lista, hasLength(3));

      final fotoPaths = lista.map((r) => r.fotoPath).toSet();
      // Every row has a photo, and every photo path is unique — no two rows
      // (original or either duplicate) share the same underlying file.
      expect(fotoPaths, hasLength(3));
      expect(fotoPaths.every((path) => path != null), isTrue);

      final duplicados = lista.where((r) => r.id != idOriginal).toList();
      expect(duplicados, hasLength(2));

      // Deleting one duplicate must not touch the surviving rows' photos.
      final superviviente = duplicados.first;
      final borrado = duplicados.last;
      await restaurantes.delete(borrado.id);

      expect(File(superviviente.fotoPath!).existsSync(), isTrue);
      final original = lista.firstWhere((r) => r.id == idOriginal);
      expect(File(original.fotoPath!).existsSync(), isTrue);
    },
  );

  test(
    'a mid-import failure rolls back every row from that same import',
    () async {
      // Two well-formed restaurants followed by a malformed one (missing the
      // required "nombre" field, which the repository requires as a String)
      // — the cast inside _insertarDesdeMapa throws partway through the
      // third entry.
      const rawConFilaMalformada = '''
      {
        "version": 1,
        "restaurantes": [
          {"nombre": "Uno", "visitas": 0, "tags": [], "platos": [], "recordatorios": [], "categorias": []},
          {"nombre": "Dos", "visitas": 0, "tags": [], "platos": [], "recordatorios": [], "categorias": []},
          {"ubicacion": "Sin nombre", "visitas": 0, "tags": [], "platos": [], "recordatorios": [], "categorias": []}
        ]
      }
      ''';

      await expectLater(
        importDatabaseFromJson(
          rawConFilaMalformada,
          db: db,
          restaurantes: restaurantes,
          platos: platos,
          recordatorios: recordatorios,
          categorias: categorias,
        ),
        throwsA(anything),
      );

      // Nothing from this failed import — not even the two rows that were
      // individually well-formed and inserted before the failure — should be
      // left behind: the whole import is one transaction.
      final lista = await restaurantes.watchAll().first;
      expect(lista, isEmpty);
    },
  );

  test(
    'importarDesdeZip reports a clear error for a file that is neither zip nor JSON',
    () async {
      final bytesBasura = utf8.encode(
        'esto no es ni un zip ni un JSON válido {{{',
      );

      await expectLater(
        importarDesdeZip(
          bytesBasura,
          db: db,
          restaurantes: restaurantes,
          platos: platos,
          recordatorios: recordatorios,
          categorias: categorias,
        ),
        throwsA(isA<BackupInvalidoException>()),
      );
    },
  );

  test(
    'importarDesdeZip still accepts a plain v1 JSON backup, without photos',
    () async {
      const rawV1 = '''
    {
      "version": 1,
      "restaurantes": [
        {
          "nombre": "Pekín",
          "ubicacion": "Madrid",
          "visitas": 5,
          "tags": ["Chino"],
          "platos": [
            {"tipo": "Principal", "nombre": "Pollo frito", "puntuacion": 8.5, "comentario": null}
          ],
          "recordatorios": [],
          "categorias": []
        }
      ]
    }
    ''';

      final resumen = await importarDesdeZip(
        utf8.encode(rawV1),
        db: db,
        restaurantes: restaurantes,
        platos: platos,
        recordatorios: recordatorios,
        categorias: categorias,
      );

      expect(resumen.restaurantes, 1);
      expect(resumen.platos, 1);

      final lista = await restaurantes.watchAll().first;
      expect(lista, hasLength(1));
      expect(lista.single.nombre, 'Pekín');
      expect(lista.single.fotoPath, isNull);

      final platosImportados = await platos
          .watchByRestaurante(lista.single.id)
          .first;
      expect(platosImportados.single.fotoPath, isNull);
    },
  );
}
