import 'package:drift/drift.dart';

import '../../core/ids.dart';
import '../../domain/repositories/categoria_repository.dart';
import '../local/app_database.dart';

class CategoriaRepositoryImpl implements CategoriaRepository {
  final AppDatabase _db;

  CategoriaRepositoryImpl(this._db);

  @override
  Stream<List<Categoria>> watchByRestaurante(String restauranteId) {
    return (_db.select(_db.categorias)
          ..where((t) => t.restauranteId.equals(restauranteId))
          ..orderBy([(t) => OrderingTerm.asc(t.orden)]))
        .watch();
  }

  @override
  Future<String> insert({
    required String restauranteId,
    required String nombre,
  }) async {
    final id = newId();
    final nombreNormalizado = nombre.trim().toLowerCase();

    return _db.transaction(() async {
      final existentes = await (_db.select(
        _db.categorias,
      )..where((t) => t.restauranteId.equals(restauranteId))).get();

      final duplicada = existentes.any(
        (c) => c.nombre.trim().toLowerCase() == nombreNormalizado,
      );
      if (duplicada) {
        throw CategoriaDuplicadaException(nombre.trim());
      }

      await _db
          .into(_db.categorias)
          .insert(
            CategoriasCompanion.insert(
              id: id,
              restauranteId: restauranteId,
              nombre: nombre,
              orden: Value(existentes.length),
            ),
          );
      return id;
    });
  }

  @override
  Future<void> delete(String id) async {
    await (_db.delete(_db.categorias)..where((t) => t.id.equals(id))).go();
  }
}
