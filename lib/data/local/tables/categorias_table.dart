import 'package:drift/drift.dart';

import 'restaurantes_table.dart';

/// User-defined extra dish categories for a restaurant, beyond the fixed
/// Entrantes/Platos/Postres sections (e.g. "Bebidas", "Tapas").
class Categorias extends Table {
  TextColumn get id => text()();
  TextColumn get restauranteId =>
      text().references(Restaurantes, #id)();
  TextColumn get nombre => text()();
  IntColumn get orden => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}
