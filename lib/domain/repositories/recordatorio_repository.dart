import '../../data/local/app_database.dart' show Recordatorio;

/// Repository for "order this next time" reminders. Returns the
/// drift-generated `Recordatorio` class directly — see the note in
/// [RestauranteRepository] for why.
abstract class RecordatorioRepository {
  Stream<List<Recordatorio>> watchByRestaurante(String restauranteId);

  Future<String> insert({required String restauranteId, required String texto});

  Future<void> setHecho(String id, bool hecho);

  Future<void> delete(String id);
}
