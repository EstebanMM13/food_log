import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:proyecto_food_log/data/local/app_database.dart';
import 'package:proyecto_food_log/data/local/backup_service.dart';
import 'package:proyecto_food_log/data/repositories/categoria_repository_impl.dart';
import 'package:proyecto_food_log/data/repositories/plato_repository_impl.dart';
import 'package:proyecto_food_log/data/repositories/recordatorio_repository_impl.dart';
import 'package:proyecto_food_log/data/repositories/restaurante_repository_impl.dart';

void main() {
  late AppDatabase db;
  late RestauranteRepositoryImpl restaurantes;
  late PlatoRepositoryImpl platos;
  late RecordatorioRepositoryImpl recordatorios;
  late CategoriaRepositoryImpl categorias;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    restaurantes = RestauranteRepositoryImpl(db);
    platos = PlatoRepositoryImpl(db);
    recordatorios = RecordatorioRepositoryImpl(db);
    categorias = CategoriaRepositoryImpl(db);
  });

  tearDown(() => db.close());

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
    expect((restaurante['platos'] as List), hasLength(1));
    expect((restaurante['recordatorios'] as List), hasLength(1));
    expect((restaurante['categorias'] as List), hasLength(1));
  });

  test('import inserts new restaurants with fresh ids from a JSON payload', () async {
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

    final platosImportados = await platos.watchByRestaurante(restaurante.id).first;
    expect(platosImportados, hasLength(1));
    expect(platosImportados.single.nombre, 'Pollo frito');

    final recordatoriosImportados =
        await recordatorios.watchByRestaurante(restaurante.id).first;
    expect(recordatoriosImportados, hasLength(1));
    expect(recordatoriosImportados.single.hecho, isTrue);

    final categoriasImportadas = await categorias.watchByRestaurante(restaurante.id).first;
    expect(categoriasImportadas, hasLength(1));
    expect(categoriasImportadas.single.nombre, 'Entrantes fríos');
  });

  test('importing an exported payload roundtrips as a duplicate, not a merge', () async {
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
      restaurantes: restaurantes,
      platos: platos,
      recordatorios: recordatorios,
      categorias: categorias,
    );

    final lista = await restaurantes.watchAll().first;
    expect(lista, hasLength(2));
    expect(lista.map((r) => r.id).toSet(), hasLength(2));
    expect(lista.every((r) => r.nombre == 'Capri'), isTrue);
  });
}
