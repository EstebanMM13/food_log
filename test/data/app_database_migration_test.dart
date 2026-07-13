import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:proyecto_food_log/data/local/app_database.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite3_lib;

void main() {
  test(
    'upgrading from schema version 3 to 4 adds fotoPath without touching existing rows',
    () async {
      // Hand-build the schema exactly as it looked at version 3 (i.e.
      // before the `foto_path` columns existed on restaurantes/platos),
      // then seed it with data — mirroring what a real user's on-disk
      // database would contain right before this migration ships.
      final rawDb = sqlite3_lib.sqlite3.openInMemory();
      rawDb.execute('''
        CREATE TABLE restaurantes (
          id TEXT NOT NULL PRIMARY KEY,
          nombre TEXT NOT NULL,
          ubicacion TEXT,
          visitas INTEGER NOT NULL DEFAULT 0,
          notas TEXT,
          created_at INTEGER NOT NULL,
          updated_at INTEGER NOT NULL
        );

        CREATE TABLE tags (
          id TEXT NOT NULL PRIMARY KEY,
          nombre TEXT NOT NULL UNIQUE
        );

        CREATE TABLE restaurante_tags (
          restaurante_id TEXT NOT NULL REFERENCES restaurantes(id),
          tag_id TEXT NOT NULL REFERENCES tags(id),
          PRIMARY KEY (restaurante_id, tag_id)
        );

        CREATE TABLE platos (
          id TEXT NOT NULL PRIMARY KEY,
          restaurante_id TEXT NOT NULL REFERENCES restaurantes(id),
          tipo TEXT NOT NULL,
          nombre TEXT NOT NULL,
          puntuacion REAL NOT NULL,
          comentario TEXT,
          created_at INTEGER NOT NULL
        );

        CREATE TABLE recordatorios (
          id TEXT NOT NULL PRIMARY KEY,
          restaurante_id TEXT NOT NULL REFERENCES restaurantes(id),
          texto TEXT NOT NULL,
          hecho INTEGER NOT NULL DEFAULT 0
        );

        CREATE TABLE categorias (
          id TEXT NOT NULL PRIMARY KEY,
          restaurante_id TEXT NOT NULL REFERENCES restaurantes(id),
          nombre TEXT NOT NULL,
          orden INTEGER NOT NULL DEFAULT 0
        );
      ''');
      rawDb.execute('''
        INSERT INTO restaurantes (id, nombre, ubicacion, visitas, notas, created_at, updated_at)
        VALUES ('r1', 'Camelot', 'Castellón', 3, 'buen sitio', 1700000000, 1700000000);
      ''');
      rawDb.execute('''
        INSERT INTO platos (id, restaurante_id, tipo, nombre, puntuacion, comentario, created_at)
        VALUES ('p1', 'r1', 'Entrante', 'Patatas con queso y bacon', 9.0, 'genial', 1700000000);
      ''');
      rawDb.execute('PRAGMA user_version = 3;');

      final db = AppDatabase.forTesting(NativeDatabase.opened(rawDb));
      addTearDown(db.close);

      // Triggers the lazy connection to open, which runs the real
      // MigrationStrategy.onUpgrade(from: 3, to: 4) since the stored
      // user_version (3) is behind schemaVersion (4). Must not throw.
      final restaurantesRow = await (db.select(
        db.restaurantes,
      )..where((t) => t.id.equals('r1'))).getSingle();
      final platoRow = await (db.select(
        db.platos,
      )..where((t) => t.id.equals('p1'))).getSingle();

      expect(restaurantesRow.nombre, 'Camelot');
      expect(restaurantesRow.visitas, 3);
      expect(restaurantesRow.fotoPath, isNull);

      expect(platoRow.nombre, 'Patatas con queso y bacon');
      expect(platoRow.puntuacion, 9.0);
      expect(platoRow.fotoPath, isNull);
    },
  );
}
