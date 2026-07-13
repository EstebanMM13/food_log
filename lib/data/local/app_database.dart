import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

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
            await m.addColumn(restaurantes, restaurantes.fotoPath);
            await m.addColumn(platos, platos.fotoPath);
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
