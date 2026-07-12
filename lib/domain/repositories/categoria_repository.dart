import '../../data/local/app_database.dart' show Categoria;

/// Thrown by [CategoriaRepository.insert] when a category with the same
/// name (case-insensitive, trimmed) already exists for the restaurant.
class CategoriaDuplicadaException implements Exception {
  final String nombre;

  CategoriaDuplicadaException(this.nombre);

  @override
  String toString() => 'Ya existe una categoría llamada "$nombre" para este restaurante.';
}

/// Repository for user-defined extra dish categories (beyond the fixed
/// Entrantes/Platos/Postres sections). Returns the drift-generated
/// `Categoria` class directly — see the note in [RestauranteRepository]
/// for why.
abstract class CategoriaRepository {
  Stream<List<Categoria>> watchByRestaurante(String restauranteId);

  Future<String> insert({
    required String restauranteId,
    required String nombre,
  });

  Future<void> delete(String id);
}
