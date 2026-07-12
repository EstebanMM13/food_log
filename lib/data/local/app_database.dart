import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../core/ids.dart';
import 'tables/categorias_table.dart';
import 'tables/platos_table.dart';
import 'tables/recordatorios_table.dart';
import 'tables/restaurante_tags_table.dart';
import 'tables/restaurantes_table.dart';
import 'tables/tags_table.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [Restaurantes, Tags, RestauranteTags, Platos, Recordatorios, Categorias],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// Constructor used by tests to run entirely in memory.
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.addColumn(platos, platos.comentario);
          }
          if (from < 3) {
            await m.createTable(categorias);
          }
          if (from < 4) {
            // TipoPlato.cafe was removed from the fixed enum in favor of the
            // generic user-defined categories system. Any dish that was
            // stored with tipo "café" now falls back to TipoPlato.otro, so
            // create a "Café" category per restaurant that had at least one
            // such dish, keeping those dishes grouped together instead of
            // dumping them into "Otros".
            final todosLosPlatos = await select(platos).get();
            final restaurantesConCafe = <String>{};
            for (final plato in todosLosPlatos) {
              if (plato.tipo.trim().toLowerCase() == 'café') {
                restaurantesConCafe.add(plato.restauranteId);
              }
            }
            for (final restauranteId in restaurantesConCafe) {
              final categoriasExistentes = await (select(categorias)
                    ..where((t) => t.restauranteId.equals(restauranteId)))
                  .get();
              final yaExiste = categoriasExistentes
                  .any((c) => c.nombre.trim().toLowerCase() == 'café');
              if (!yaExiste) {
                await into(categorias).insert(
                  CategoriasCompanion.insert(
                    id: newId(),
                    restauranteId: restauranteId,
                    nombre: 'Café',
                    orden: Value(categoriasExistentes.length),
                  ),
                );
              }
            }
          }
        },
      );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'food_log.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
