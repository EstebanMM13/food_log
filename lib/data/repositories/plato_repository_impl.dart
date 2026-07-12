import 'package:drift/drift.dart';

import '../../core/ids.dart';
import '../../domain/repositories/plato_repository.dart';
import '../local/app_database.dart';

class PlatoRepositoryImpl implements PlatoRepository {
  final AppDatabase _db;

  PlatoRepositoryImpl(this._db);

  @override
  Stream<List<Plato>> watchByRestaurante(String restauranteId) {
    return (_db.select(_db.platos)
          ..where((t) => t.restauranteId.equals(restauranteId))
          ..orderBy([(t) => OrderingTerm(expression: t.createdAt)]))
        .watch();
  }

  @override
  Stream<List<Plato>> watchAll() {
    return _db.select(_db.platos).watch();
  }

  @override
  Future<String> insert({
    required String restauranteId,
    required String tipo,
    required String nombre,
    required double puntuacion,
    String? comentario,
  }) async {
    final id = newId();
    await _db.into(_db.platos).insert(
          PlatosCompanion.insert(
            id: id,
            restauranteId: restauranteId,
            tipo: tipo,
            nombre: nombre,
            puntuacion: puntuacion,
            comentario: Value.absentIfNull(comentario),
            createdAt: DateTime.now(),
          ),
        );
    return id;
  }

  @override
  Future<void> update(Plato plato) async {
    await _db.update(_db.platos).replace(plato);
  }

  @override
  Future<void> delete(String id) async {
    await (_db.delete(_db.platos)..where((t) => t.id.equals(id))).go();
  }
}
