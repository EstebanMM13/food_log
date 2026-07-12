import 'package:drift/drift.dart';

/// Free-form tags (e.g. "Español", "Italiano") that restaurants can be
/// labeled with. Kept in their own table (instead of a comma-separated
/// column) so the same tag can be reused/renamed across restaurants.
class Tags extends Table {
  TextColumn get id => text()();
  TextColumn get nombre => text().unique()();

  @override
  Set<Column> get primaryKey => {id};
}
