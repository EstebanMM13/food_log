import 'package:drift/drift.dart';

import 'restaurantes_table.dart';

/// Dishes tried at a restaurant. `tipo` is deliberately a free TEXT column
/// (no CHECK constraint / enum at the DB level): imported data from the
/// Obsidian vault can contain values that don't map cleanly to
/// [TipoPlato] (see lib/domain/tipo_plato.dart), and we never want a
/// stored value to make a row unreadable.
class Platos extends Table {
  TextColumn get id => text()();
  TextColumn get restauranteId => text().references(Restaurantes, #id)();
  TextColumn get tipo => text()();
  TextColumn get nombre => text()();
  RealColumn get puntuacion => real()();
  TextColumn get comentario => text().nullable()();

  /// Absolute path to a photo of this dish, copied into the app's own
  /// documents directory (see lib/core/photo_storage.dart). Null if no
  /// photo was ever set.
  TextColumn get fotoPath => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
