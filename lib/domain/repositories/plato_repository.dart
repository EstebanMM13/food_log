import '../../data/local/app_database.dart' show Plato;

/// Repository for dishes. Returns the drift-generated `Plato` class
/// directly — see the note in [RestauranteRepository] for why.
abstract class PlatoRepository {
  /// Dishes for a single restaurant.
  Stream<List<Plato>> watchByRestaurante(String restauranteId);

  /// Every dish across every restaurant. Used by the stats screen to
  /// compute global averages / most-repeated dishes without one query
  /// per restaurant.
  Stream<List<Plato>> watchAll();

  Future<String> insert({
    required String restauranteId,
    required String tipo,
    required String nombre,
    required double puntuacion,
    String? comentario,
  });

  Future<void> update(Plato plato);

  Future<void> delete(String id);
}
