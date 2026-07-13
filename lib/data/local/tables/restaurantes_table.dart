import 'package:drift/drift.dart';

/// Restaurants table. Uses a TEXT UUID primary key (no autoincrement) so
/// rows never collide if this database is ever synced across devices.
class Restaurantes extends Table {
  TextColumn get id => text()();
  TextColumn get nombre => text()();
  TextColumn get ubicacion => text().nullable()();
  IntColumn get visitas => integer().withDefault(const Constant(0))();
  TextColumn get notas => text().nullable()();

  /// Absolute path to a photo of this restaurant, copied into the app's own
  /// documents directory (see lib/core/photo_storage.dart). Null if no
  /// photo was ever set.
  TextColumn get fotoPath => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
