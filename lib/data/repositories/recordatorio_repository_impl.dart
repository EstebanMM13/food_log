import 'package:drift/drift.dart';

import '../../core/ids.dart';
import '../../domain/repositories/recordatorio_repository.dart';
import '../local/app_database.dart';

class RecordatorioRepositoryImpl implements RecordatorioRepository {
  final AppDatabase _db;

  RecordatorioRepositoryImpl(this._db);

  @override
  Stream<List<Recordatorio>> watchByRestaurante(String restauranteId) {
    return (_db.select(
      _db.recordatorios,
    )..where((t) => t.restauranteId.equals(restauranteId))).watch();
  }

  @override
  Future<String> insert({
    required String restauranteId,
    required String texto,
  }) async {
    final id = newId();
    await _db
        .into(_db.recordatorios)
        .insert(
          RecordatoriosCompanion.insert(
            id: id,
            restauranteId: restauranteId,
            texto: texto,
          ),
        );
    return id;
  }

  @override
  Future<void> setHecho(String id, bool hecho) async {
    await (_db.update(_db.recordatorios)..where((t) => t.id.equals(id))).write(
      RecordatoriosCompanion(hecho: Value(hecho)),
    );
  }

  @override
  Future<void> delete(String id) async {
    await (_db.delete(_db.recordatorios)..where((t) => t.id.equals(id))).go();
  }
}
