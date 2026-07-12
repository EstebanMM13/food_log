import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local/app_database.dart';
import '../../domain/models/restaurante_resumen.dart';
import 'plato_providers.dart';
import 'repository_providers.dart';

/// Raw restaurant rows, ordered by name. Used directly by forms/detail
/// screens that just need the base entity.
final restaurantesProvider = StreamProvider<List<Restaurante>>((ref) {
  return ref.watch(restauranteRepositoryProvider).watchAll();
});

/// Tags for every restaurant, keyed by restaurante id.
final tagsPorRestauranteProvider = StreamProvider<Map<String, List<Tag>>>((ref) {
  return ref.watch(restauranteRepositoryProvider).watchTagsByRestaurante();
});

/// Combines restaurants + their tags + their average dish score into the
/// view-model consumed by the home list and search box.
final restaurantesResumenProvider = Provider<AsyncValue<List<RestauranteResumen>>>((ref) {
  final restaurantesAsync = ref.watch(restaurantesProvider);
  final tagsAsync = ref.watch(tagsPorRestauranteProvider);
  final platosAsync = ref.watch(platosTodosProvider);

  if (restaurantesAsync.isLoading || tagsAsync.isLoading || platosAsync.isLoading) {
    return const AsyncValue.loading();
  }
  final error = restaurantesAsync.error ?? tagsAsync.error ?? platosAsync.error;
  if (error != null) {
    return AsyncValue.error(error, StackTrace.current);
  }

  final restaurantes = restaurantesAsync.value ?? const [];
  final tagsPorRestaurante = tagsAsync.value ?? const {};
  final platos = platosAsync.value ?? const [];

  final platosPorRestaurante = <String, List<Plato>>{};
  for (final plato in platos) {
    platosPorRestaurante.putIfAbsent(plato.restauranteId, () => []).add(plato);
  }

  final resumen = restaurantes.map((restaurante) {
    final platosDelRestaurante = platosPorRestaurante[restaurante.id] ?? const [];
    final media = platosDelRestaurante.isEmpty
        ? null
        : platosDelRestaurante.map((p) => p.puntuacion).reduce((a, b) => a + b) /
            platosDelRestaurante.length;
    return RestauranteResumen(
      restaurante: restaurante,
      puntuacionMedia: media,
      tags: tagsPorRestaurante[restaurante.id] ?? const [],
    );
  }).toList();

  return AsyncValue.data(resumen);
});
