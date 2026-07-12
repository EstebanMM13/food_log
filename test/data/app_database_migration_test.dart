import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:proyecto_food_log/data/local/app_database.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite3;

/// Builds a raw sqlite3 database that mirrors the schema drift would have
/// created at schemaVersion 3 (before TipoPlato.cafe was removed from the
/// fixed enum), pre-populated with data, and stamped with
/// `PRAGMA user_version = 3` so that opening it through [AppDatabase]
/// triggers the `from < 4` migration block under test.
sqlite3.Database _buildV3Database() {
  final db = sqlite3.sqlite3.openInMemory();
  db.execute('''
    CREATE TABLE restaurantes (
      id TEXT NOT NULL PRIMARY KEY,
      nombre TEXT NOT NULL,
      ubicacion TEXT NULL,
      visitas INTEGER NOT NULL DEFAULT 0,
      notas TEXT NULL,
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL
    );
    CREATE TABLE platos (
      id TEXT NOT NULL PRIMARY KEY,
      restaurante_id TEXT NOT NULL REFERENCES restaurantes(id),
      tipo TEXT NOT NULL,
      nombre TEXT NOT NULL,
      puntuacion REAL NOT NULL,
      comentario TEXT NULL,
      created_at INTEGER NOT NULL
    );
    CREATE TABLE categorias (
      id TEXT NOT NULL PRIMARY KEY,
      restaurante_id TEXT NOT NULL REFERENCES restaurantes(id),
      nombre TEXT NOT NULL,
      orden INTEGER NOT NULL DEFAULT 0
    );
  ''');

  final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

  void insertRestaurante(String id, String nombre) {
    db.execute(
      'INSERT INTO restaurantes (id, nombre, visitas, created_at, updated_at) '
      'VALUES (?, ?, 0, ?, ?)',
      [id, nombre, now, now],
    );
  }

  void insertPlato(String id, String restauranteId, String tipo) {
    db.execute(
      'INSERT INTO platos (id, restaurante_id, tipo, nombre, puntuacion, created_at) '
      'VALUES (?, ?, ?, ?, 8.0, ?)',
      [id, restauranteId, tipo, 'Plato $id', now],
    );
  }

  void insertCategoria(String id, String restauranteId, String nombre) {
    db.execute(
      'INSERT INTO categorias (id, restaurante_id, nombre, orden) VALUES (?, ?, ?, 0)',
      [id, restauranteId, nombre],
    );
  }

  // Restaurant A: has a dish stored with tipo "Café" (exact match) -> should
  // get a new "Café" category created for it.
  insertRestaurante('rest-a', 'Con Café');
  insertPlato('plato-a1', 'rest-a', 'Café');
  insertPlato('plato-a2', 'rest-a', 'Entrante');

  // Restaurant B: has a dish stored with tipo "  CAFÉ  " (different case and
  // padded with whitespace) -> the migration's case-insensitive, trimmed
  // comparison should still catch it.
  insertRestaurante('rest-b', 'Con Cafe Mayusculas');
  insertPlato('plato-b1', 'rest-b', '  CAFÉ  ');

  // Restaurant C: already has a user-defined "café" category (lowercase) ->
  // the migration must NOT create a duplicate.
  insertRestaurante('rest-c', 'Ya tenia categoria');
  insertPlato('plato-c1', 'rest-c', 'Café');
  insertCategoria('cat-c1', 'rest-c', 'café');

  // Restaurant D: no café dishes at all -> no category should be created.
  insertRestaurante('rest-d', 'Sin Cafe');
  insertPlato('plato-d1', 'rest-d', 'Postre');

  db.execute('PRAGMA user_version = 3');
  return db;
}

void main() {
  test('migrating from schemaVersion 3 to 4 backfills a "Café" category '
      'per restaurant that had a café dish, without duplicating existing ones', () async {
    final rawDb = _buildV3Database();
    final db = AppDatabase.forTesting(NativeDatabase.opened(rawDb));

    // Force the connection to open, which runs the pending migration.
    final categorias = await db.select(db.categorias).get();

    final categoriasPorRestaurante = <String, List<String>>{};
    for (final categoria in categorias) {
      categoriasPorRestaurante
          .putIfAbsent(categoria.restauranteId, () => [])
          .add(categoria.nombre);
    }

    expect(categoriasPorRestaurante['rest-a'], ['Café']);
    expect(categoriasPorRestaurante['rest-b'], ['Café']);
    // Restaurant C already had a "café" category (different case): the
    // migration must not add a second one.
    expect(categoriasPorRestaurante['rest-c'], ['café']);
    // Restaurant D never had a café dish: no category created for it.
    expect(categoriasPorRestaurante.containsKey('rest-d'), isFalse);

    await db.close();
  });
}
