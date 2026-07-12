import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local/app_database.dart';
import 'repository_providers.dart';

/// Dishes for one restaurant (detail screen).
final platosDeRestauranteProvider =
    StreamProvider.family<List<Plato>, String>((ref, restauranteId) {
  return ref.watch(platoRepositoryProvider).watchByRestaurante(restauranteId);
});

/// Every dish across every restaurant (home list averages + stats screen).
final platosTodosProvider = StreamProvider<List<Plato>>((ref) {
  return ref.watch(platoRepositoryProvider).watchAll();
});
