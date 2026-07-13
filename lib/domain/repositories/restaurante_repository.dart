import '../../data/local/app_database.dart' show Restaurante, Tag;

/// Repository for restaurants and their tags.
///
/// Note: this interface returns the drift-generated `Restaurante`/`Tag`
/// classes directly instead of hand-written domain entities. For CRUD this
/// simple (a straight row in/row out mapping) an extra mapper layer would
/// only add boilerplate without adding safety or flexibility.
abstract class RestauranteRepository {
  /// All restaurants, ordered by name.
  Stream<List<Restaurante>> watchAll();

  /// One-shot snapshot of every restaurant, for callers that just need a
  /// point-in-time read (e.g. a duplicate-name check) instead of a live
  /// subscription.
  Future<List<Restaurante>> getAll();

  Future<Restaurante?> getById(String id);

  /// Tags currently assigned to [restauranteId].
  Stream<List<Tag>> watchTagsFor(String restauranteId);

  /// Tags for every restaurant in one query, keyed by restaurante id.
  /// Used by the home list and the stats screen to avoid N+1 queries.
  Stream<Map<String, List<Tag>>> watchTagsByRestaurante();

  /// Creates a restaurant (and links/creates the given [tags] by name),
  /// returning the new id. [visitas] defaults to 0 for restaurants created
  /// through the UI; the Obsidian importer passes the real historical
  /// count so seeded data isn't reset back to zero visits.
  Future<String> insert({
    required String nombre,
    String? ubicacion,
    String? notas,
    List<String> tags = const [],
    int visitas = 0,
    String? fotoPath,
  });

  /// Updates a restaurant's fields and replaces its tag set with [tags]
  /// (by name — unknown names are created). [fotoPath] is required (though
  /// nullable) rather than optional-with-a-null-default: this is a
  /// "always pass the intended value" field like [ubicacion]/[notas], and a
  /// caller that forgot to pass it would otherwise silently clear the photo.
  /// Callers that don't touch the photo must pass the restaurant's current
  /// [fotoPath] back in. If it changes from what was stored before, the old
  /// file on disk is deleted.
  Future<void> update({
    required String id,
    required String nombre,
    String? ubicacion,
    String? notas,
    List<String> tags = const [],
    required String? fotoPath,
  });

  Future<void> delete(String id);

  /// Bumps the visit counter by one (e.g. "I ate here again" action).
  Future<void> registrarVisita(String id);

  /// Overwrites the visit counter with an exact value (correcting a mistake).
  Future<void> setVisitas(String id, int visitas);
}
