import 'package:drift/drift.dart';

import '../../core/ids.dart';
import '../../core/photo_storage.dart';
import '../../domain/repositories/restaurante_repository.dart';
import '../local/app_database.dart';

class RestauranteRepositoryImpl implements RestauranteRepository {
  final AppDatabase _db;

  RestauranteRepositoryImpl(this._db);

  @override
  Stream<List<Restaurante>> watchAll() {
    return (_db.select(_db.restaurantes)
          ..orderBy([(t) => OrderingTerm(expression: t.nombre)]))
        .watch();
  }

  @override
  Future<List<Restaurante>> getAll() {
    return (_db.select(_db.restaurantes)
          ..orderBy([(t) => OrderingTerm(expression: t.nombre)]))
        .get();
  }

  @override
  Future<Restaurante?> getById(String id) {
    return (_db.select(_db.restaurantes)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  @override
  Stream<List<Tag>> watchTagsFor(String restauranteId) {
    final query = _db.select(_db.restauranteTags).join([
      innerJoin(_db.tags, _db.tags.id.equalsExp(_db.restauranteTags.tagId)),
    ])
      ..where(_db.restauranteTags.restauranteId.equals(restauranteId));
    return query.watch().map(
          (rows) => rows.map((row) => row.readTable(_db.tags)).toList(),
        );
  }

  @override
  Stream<Map<String, List<Tag>>> watchTagsByRestaurante() {
    final query = _db.select(_db.restauranteTags).join([
      innerJoin(_db.tags, _db.tags.id.equalsExp(_db.restauranteTags.tagId)),
    ]);
    return query.watch().map((rows) {
      final map = <String, List<Tag>>{};
      for (final row in rows) {
        final link = row.readTable(_db.restauranteTags);
        final tag = row.readTable(_db.tags);
        map.putIfAbsent(link.restauranteId, () => []).add(tag);
      }
      return map;
    });
  }

  @override
  Future<String> insert({
    required String nombre,
    String? ubicacion,
    String? notas,
    List<String> tags = const [],
    int visitas = 0,
    String? fotoPath,
  }) async {
    final id = newId();
    final now = DateTime.now();
    await _db.into(_db.restaurantes).insert(
          RestaurantesCompanion.insert(
            id: id,
            nombre: nombre,
            ubicacion: Value(ubicacion),
            notas: Value(notas),
            visitas: Value(visitas),
            fotoPath: Value(fotoPath),
            createdAt: now,
            updatedAt: now,
          ),
        );
    await _replaceTags(id, tags);
    return id;
  }

  @override
  Future<void> update({
    required String id,
    required String nombre,
    String? ubicacion,
    String? notas,
    List<String> tags = const [],
    required String? fotoPath,
  }) async {
    final anterior = await getById(id);
    await (_db.update(_db.restaurantes)..where((t) => t.id.equals(id))).write(
      RestaurantesCompanion(
        nombre: Value(nombre),
        ubicacion: Value(ubicacion),
        notas: Value(notas),
        fotoPath: Value(fotoPath),
        updatedAt: Value(DateTime.now()),
      ),
    );
    // Database writes (row + tag set) happen unconditionally; the old photo
    // file cleanup below is best-effort and must never block or fail this.
    await _replaceTags(id, tags);
    if (anterior != null && anterior.fotoPath != fotoPath) {
      await PhotoStorage.borrarSiExiste(anterior.fotoPath);
    }
  }

  @override
  Future<void> delete(String id) async {
    final restaurante = await getById(id);
    final platosDelRestaurante = await (_db.select(_db.platos)
          ..where((t) => t.restauranteId.equals(id)))
        .get();

    await (_db.delete(_db.recordatorios)
          ..where((t) => t.restauranteId.equals(id)))
        .go();
    await (_db.delete(_db.platos)..where((t) => t.restauranteId.equals(id)))
        .go();
    await (_db.delete(_db.restauranteTags)
          ..where((t) => t.restauranteId.equals(id)))
        .go();
    await (_db.delete(_db.categorias)..where((t) => t.restauranteId.equals(id)))
        .go();
    await (_db.delete(_db.restaurantes)..where((t) => t.id.equals(id))).go();

    for (final plato in platosDelRestaurante) {
      await PhotoStorage.borrarSiExiste(plato.fotoPath);
    }
    if (restaurante != null) {
      await PhotoStorage.borrarSiExiste(restaurante.fotoPath);
    }
  }

  @override
  Future<void> registrarVisita(String id) async {
    final restaurante = await getById(id);
    if (restaurante == null) return;
    await setVisitas(id, restaurante.visitas + 1);
  }

  @override
  Future<void> setVisitas(String id, int visitas) async {
    await (_db.update(_db.restaurantes)..where((t) => t.id.equals(id))).write(
      RestaurantesCompanion(
        visitas: Value(visitas),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Ensures every tag name exists in `tags` (creating missing ones), then
  /// replaces the restaurant's tag links with exactly this set.
  Future<void> _replaceTags(String restauranteId, List<String> tagNames) async {
    final normalized = tagNames.map((t) => t.trim()).where((t) => t.isNotEmpty).toSet();

    final tagIds = <String>[];
    for (final name in normalized) {
      final existing = await (_db.select(_db.tags)
            ..where((t) => t.nombre.equals(name)))
          .getSingleOrNull();
      if (existing != null) {
        tagIds.add(existing.id);
      } else {
        final id = newId();
        await _db.into(_db.tags).insert(
              TagsCompanion.insert(id: id, nombre: name),
            );
        tagIds.add(id);
      }
    }

    await (_db.delete(_db.restauranteTags)
          ..where((t) => t.restauranteId.equals(restauranteId)))
        .go();
    for (final tagId in tagIds) {
      await _db.into(_db.restauranteTags).insert(
            RestauranteTagsCompanion.insert(
              restauranteId: restauranteId,
              tagId: tagId,
            ),
          );
    }
  }
}
