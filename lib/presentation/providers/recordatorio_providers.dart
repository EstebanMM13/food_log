import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local/app_database.dart';
import 'repository_providers.dart';

/// Reminders ("order this next time") for one restaurant.
final recordatoriosDeRestauranteProvider =
    StreamProvider.family<List<Recordatorio>, String>((ref, restauranteId) {
  return ref
      .watch(recordatorioRepositoryProvider)
      .watchByRestaurante(restauranteId);
});
