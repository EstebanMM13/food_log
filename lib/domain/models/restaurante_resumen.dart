import '../../data/local/app_database.dart' show Restaurante, Tag;

/// Read-only projection of a restaurant plus data that lives in other
/// tables (average dish score, tags). This is a view-model for the list
/// screen, not a CRUD entity — that's why it's hand-written instead of
/// reusing a single drift-generated class: no single table maps to
/// "restaurant + its average score + its tags".
class RestauranteResumen {
  final Restaurante restaurante;
  final double? puntuacionMedia;
  final List<Tag> tags;

  const RestauranteResumen({
    required this.restaurante,
    required this.puntuacionMedia,
    required this.tags,
  });
}
