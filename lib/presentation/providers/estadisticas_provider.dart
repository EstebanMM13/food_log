import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local/app_database.dart' show Restaurante;
import '../../domain/models/estadisticas.dart';
import 'plato_providers.dart';
import 'restaurantes_provider.dart';

/// How many entries to keep in each "top N" ranking shown on the stats
/// screen (most-visited, best-rated, most-repeated dishes, most-used tags).
const _topN = 5;

/// Computes the dashboard metrics shown on the stats screen from the
/// already-loaded restaurant/dish/tag streams. Everything here is plain
/// Dart aggregation over data that's already in memory — no extra SQL
/// queries needed since the source streams are small (a handful of
/// restaurants and dishes).
final estadisticasProvider = Provider<AsyncValue<Estadisticas>>((ref) {
  final resumenAsync = ref.watch(restaurantesResumenProvider);
  final platosAsync = ref.watch(platosTodosProvider);

  if (resumenAsync.isLoading || platosAsync.isLoading) {
    return const AsyncValue.loading();
  }
  final error = resumenAsync.hasError
      ? resumenAsync.error
      : (platosAsync.hasError ? platosAsync.error : null);
  if (error != null) {
    return AsyncValue.error(error, StackTrace.current);
  }

  final resumen = resumenAsync.value ?? const [];
  final platos = platosAsync.value ?? const [];

  // Global average: mean of every dish's score across every restaurant.
  final puntuacionGlobalMedia = platos.isEmpty
      ? null
      : platos.map((p) => p.puntuacion).reduce((a, b) => a + b) / platos.length;

  // Most visited: ranked by `visitas` desc, tie-broken by name so the
  // order is deterministic.
  final masVisitados = [...resumen]
    ..sort((a, b) {
      final cmp = b.restaurante.visitas.compareTo(a.restaurante.visitas);
      return cmp != 0
          ? cmp
          : a.restaurante.nombre.compareTo(b.restaurante.nombre);
    });
  final masVisitadosTop = masVisitados
      .take(_topN)
      .map(
        (r) => RestauranteRanking(
          restaurante: r.restaurante,
          valor: r.restaurante.visitas.toDouble(),
        ),
      )
      .toList();

  // Best rated: only restaurants with at least one dish can be ranked —
  // a restaurant with no dishes has no average, not a zero.
  final conPuntuacion = resumen.where((r) => r.puntuacionMedia != null).toList()
    ..sort((a, b) {
      final cmp = b.puntuacionMedia!.compareTo(a.puntuacionMedia!);
      return cmp != 0
          ? cmp
          : a.restaurante.nombre.compareTo(b.restaurante.nombre);
    });
  final mejorValoradosTop = conPuntuacion
      .take(_topN)
      .map(
        (r) => RestauranteRanking(
          restaurante: r.restaurante,
          valor: r.puntuacionMedia!,
        ),
      )
      .toList();

  // Most repeated dishes: group by (case/space-insensitive) name.
  final porNombre = <String, List<double>>{};
  final nombreOriginal = <String, String>{};
  for (final plato in platos) {
    final clave = plato.nombre.trim().toLowerCase();
    porNombre.putIfAbsent(clave, () => []).add(plato.puntuacion);
    nombreOriginal.putIfAbsent(clave, () => plato.nombre.trim());
  }
  final platosRepetidos =
      porNombre.entries
          .where((e) => e.value.length > 1)
          .map(
            (e) => PlatoRepetido(
              nombre: nombreOriginal[e.key]!,
              veces: e.value.length,
              puntuacionMedia: e.value.reduce((a, b) => a + b) / e.value.length,
            ),
          )
          .toList()
        ..sort((a, b) {
          final cmp = b.veces.compareTo(a.veces);
          return cmp != 0 ? cmp : a.nombre.compareTo(b.nombre);
        });
  final platosRepetidosTop = platosRepetidos.take(_topN).toList();

  // Grouped by location — restaurants without a location fall under a
  // dedicated bucket rather than being silently dropped.
  const sinUbicacion = 'Sin ubicación';
  final porUbicacion = <String, List<Restaurante>>{};
  for (final r in resumen) {
    final clave = (r.restaurante.ubicacion?.trim().isNotEmpty ?? false)
        ? r.restaurante.ubicacion!.trim()
        : sinUbicacion;
    porUbicacion.putIfAbsent(clave, () => []).add(r.restaurante);
  }

  // Most used tags.
  final conteoTags = <String, int>{};
  for (final r in resumen) {
    for (final tag in r.tags) {
      conteoTags.update(tag.nombre, (v) => v + 1, ifAbsent: () => 1);
    }
  }
  final tagsMasUsados =
      conteoTags.entries
          .map((e) => TagConteo(nombre: e.key, cantidad: e.value))
          .toList()
        ..sort((a, b) {
          final cmp = b.cantidad.compareTo(a.cantidad);
          return cmp != 0 ? cmp : a.nombre.compareTo(b.nombre);
        });
  final tagsMasUsadosTop = tagsMasUsados.take(_topN).toList();

  return AsyncValue.data(
    Estadisticas(
      puntuacionGlobalMedia: puntuacionGlobalMedia,
      masVisitados: masVisitadosTop,
      mejorValorados: mejorValoradosTop,
      platosMasRepetidos: platosRepetidosTop,
      porUbicacion: porUbicacion,
      tagsMasUsados: tagsMasUsadosTop,
    ),
  );
});
