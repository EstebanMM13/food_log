import 'package:drift/drift.dart';

import 'restaurantes_table.dart';
import 'tags_table.dart';

/// Join table for the many-to-many relationship between restaurants and
/// tags. Composite primary key (restauranteId, tagId) — no surrogate id
/// needed since the pair itself is already unique.
class RestauranteTags extends Table {
  TextColumn get restauranteId =>
      text().references(Restaurantes, #id)();
  TextColumn get tagId => text().references(Tags, #id)();

  @override
  Set<Column> get primaryKey => {restauranteId, tagId};
}
