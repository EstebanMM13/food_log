import 'package:drift/drift.dart';

import 'restaurantes_table.dart';

/// "Order this next time" reminders tied to a restaurant.
class Recordatorios extends Table {
  TextColumn get id => text()();
  TextColumn get restauranteId =>
      text().references(Restaurantes, #id)();
  TextColumn get texto => text()();
  BoolColumn get hecho => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
