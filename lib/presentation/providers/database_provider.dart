import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local/app_database.dart';

/// Singleton [AppDatabase] instance for the whole app.
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});
