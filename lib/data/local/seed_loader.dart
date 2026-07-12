import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../../domain/repositories/plato_repository.dart';
import '../../domain/repositories/restaurante_repository.dart';

/// Loads `assets/seed_restaurantes.json` (produced by
/// `tool/import_obsidian.dart` from the Obsidian vault) into the database
/// on first run, only if the `restaurantes` table is still empty. This
/// replaces the hardcoded sample data that used to live in `main.dart`.
Future<void> seedDatabaseIfEmpty({
  required RestauranteRepository restaurantes,
  required PlatoRepository platos,
}) async {
  final existentes = await restaurantes.watchAll().first;
  if (existentes.isNotEmpty) return;

  final raw = await rootBundle.loadString('assets/seed_restaurantes.json');
  final data = jsonDecode(raw) as Map<String, dynamic>;
  final lista = (data['restaurantes'] as List).cast<Map<String, dynamic>>();

  for (final item in lista) {
    final id = await restaurantes.insert(
      nombre: item['nombre'] as String,
      ubicacion: item['ubicacion'] as String?,
      notas: item['notas'] as String?,
      tags: ((item['tags'] as List?) ?? const []).cast<String>(),
      visitas: (item['visitas'] as num?)?.toInt() ?? 0,
    );

    final platosDelRestaurante =
        ((item['platos'] as List?) ?? const []).cast<Map<String, dynamic>>();
    for (final plato in platosDelRestaurante) {
      await platos.insert(
        restauranteId: id,
        tipo: plato['tipo'] as String,
        nombre: plato['nombre'] as String,
        puntuacion: (plato['puntuacion'] as num).toDouble(),
      );
    }
  }
}
