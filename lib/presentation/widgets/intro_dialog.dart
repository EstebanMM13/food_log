import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/local/sample_data.dart';
import '../providers/repository_providers.dart';

const _prefKeyIntroVista = 'intro_dismissed';

/// Whether the user already dismissed the intro dialog with "No volver a
/// mostrar". Checked once on [HomeScreen] launch to decide whether to show
/// it automatically; the dialog stays reachable afterwards from the
/// overflow menu regardless of this flag.
Future<bool> introYaVista() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool(_prefKeyIntroVista) ?? false;
}

/// Explains what FoodLog is for, with an opt-in checkbox to seed a handful
/// of fictional restaurants. Shown automatically the first time the app
/// launches, and reachable afterwards from the overflow menu.
Future<void> mostrarDialogoIntro(BuildContext context, WidgetRef ref) async {
  var cargarMuestra = false;

  final noVolverAMostrar = await showDialog<bool>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: const Text('¡Bienvenido a FoodLog!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'FoodLog es tu cuaderno de restaurantes: anota los bares y '
              'restaurantes que visitas, puntúa cada plato que pruebes y '
              'consulta estadísticas sobre tus valoraciones.',
            ),
            const SizedBox(height: 12),
            CheckboxListTile(
              value: cargarMuestra,
              onChanged: (value) => setState(() => cargarMuestra = value ?? false),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              title: const Text('Cargar restaurantes de prueba'),
              subtitle: const Text('Para que veas cómo funciona antes de añadir los tuyos'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Entendido'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('No volver a mostrar'),
          ),
        ],
      ),
    ),
  );

  if (cargarMuestra) {
    await cargarRestaurantesDeMuestra(
      restaurantes: ref.read(restauranteRepositoryProvider),
      platos: ref.read(platoRepositoryProvider),
    );
  }

  if (noVolverAMostrar == true) {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKeyIntroVista, true);
  }
}
