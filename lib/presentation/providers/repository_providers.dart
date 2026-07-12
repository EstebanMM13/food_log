import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/categoria_repository_impl.dart';
import '../../data/repositories/plato_repository_impl.dart';
import '../../data/repositories/recordatorio_repository_impl.dart';
import '../../data/repositories/restaurante_repository_impl.dart';
import '../../domain/repositories/categoria_repository.dart';
import '../../domain/repositories/plato_repository.dart';
import '../../domain/repositories/recordatorio_repository.dart';
import '../../domain/repositories/restaurante_repository.dart';
import 'database_provider.dart';

final restauranteRepositoryProvider = Provider<RestauranteRepository>((ref) {
  return RestauranteRepositoryImpl(ref.watch(databaseProvider));
});

final platoRepositoryProvider = Provider<PlatoRepository>((ref) {
  return PlatoRepositoryImpl(ref.watch(databaseProvider));
});

final recordatorioRepositoryProvider = Provider<RecordatorioRepository>((ref) {
  return RecordatorioRepositoryImpl(ref.watch(databaseProvider));
});

final categoriaRepositoryProvider = Provider<CategoriaRepository>((ref) {
  return CategoriaRepositoryImpl(ref.watch(databaseProvider));
});
