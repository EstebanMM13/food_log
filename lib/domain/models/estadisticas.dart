import '../../data/local/app_database.dart' show Restaurante;

/// A dish name that appears at more than one restaurant/visit, with its
/// average score across every occurrence.
class PlatoRepetido {
  final String nombre;
  final int veces;
  final double puntuacionMedia;

  const PlatoRepetido({
    required this.nombre,
    required this.veces,
    required this.puntuacionMedia,
  });
}

/// A tag and how many restaurants use it.
class TagConteo {
  final String nombre;
  final int cantidad;

  const TagConteo({required this.nombre, required this.cantidad});
}

/// A restaurant ranked by some metric (visits or average score), carrying
/// the metric value along so the UI doesn't have to recompute it.
class RestauranteRanking {
  final Restaurante restaurante;
  final double valor;

  const RestauranteRanking({required this.restaurante, required this.valor});
}

/// Aggregate dashboard data — the Flutter equivalent of the "Restaurantes
/// General" dataviewjs dashboard in the Obsidian vault.
class Estadisticas {
  final double? puntuacionGlobalMedia;
  final List<RestauranteRanking> masVisitados;
  final List<RestauranteRanking> mejorValorados;
  final List<PlatoRepetido> platosMasRepetidos;
  final Map<String, List<Restaurante>> porUbicacion;
  final List<TagConteo> tagsMasUsados;

  const Estadisticas({
    required this.puntuacionGlobalMedia,
    required this.masVisitados,
    required this.mejorValorados,
    required this.platosMasRepetidos,
    required this.porUbicacion,
    required this.tagsMasUsados,
  });
}
