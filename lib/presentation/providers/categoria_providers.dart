import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local/app_database.dart';
import 'repository_providers.dart';

/// Custom dish categories (beyond Entrantes/Platos/Postres) for one restaurant.
final categoriasDeRestauranteProvider =
    StreamProvider.family<List<Categoria>, String>((ref, restauranteId) {
      return ref
          .watch(categoriaRepositoryProvider)
          .watchByRestaurante(restauranteId);
    });
