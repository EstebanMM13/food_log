import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local/backup_service.dart';
import '../providers/repository_providers.dart';
import '../providers/restaurantes_provider.dart';
import '../providers/theme_mode_provider.dart';
import '../widgets/restaurante_card.dart';
import 'estadisticas_screen.dart';
import 'restaurante_detail_screen.dart';
import 'restaurante_form_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _busqueda = '';

  @override
  Widget build(BuildContext context) {
    final resumenAsync = ref.watch(restaurantesResumenProvider);
    final themeMode = ref.watch(themeModeProvider).value ?? ThemeMode.system;
    // When themeMode is ThemeMode.system, the actually-visible brightness
    // comes from the platform, not from themeMode itself.
    final brilloEfectivo = switch (themeMode) {
      ThemeMode.light => Brightness.light,
      ThemeMode.dark => Brightness.dark,
      ThemeMode.system => MediaQuery.platformBrightnessOf(context),
    };
    final esOscuroActualmente = brilloEfectivo == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Log'),
        actions: [
          IconButton(
            icon: Icon(esOscuroActualmente ? Icons.light_mode : Icons.dark_mode),
            tooltip: esOscuroActualmente ? 'Cambiar a modo claro' : 'Cambiar a modo oscuro',
            onPressed: () => ref.read(themeModeProvider.notifier).toggle(brilloEfectivo),
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart),
            tooltip: 'Estadísticas',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const EstadisticasScreen()),
            ),
          ),
          PopupMenuButton<_DatosAction>(
            tooltip: 'Más opciones',
            onSelected: (accion) {
              switch (accion) {
                case _DatosAction.exportar:
                  _exportarDatos();
                case _DatosAction.importar:
                  _importarDatos();
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: _DatosAction.exportar,
                child: Text('Exportar datos'),
              ),
              PopupMenuItem(
                value: _DatosAction.importar,
                child: Text('Importar datos'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) => setState(() => _busqueda = value.trim().toLowerCase()),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Restaurantes', style: Theme.of(context).textTheme.headlineSmall),
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: resumenAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Error: $error')),
              data: (resumen) {
                final filtrados = _busqueda.isEmpty
                    ? resumen
                    : resumen.where((r) {
                        final nombre = r.restaurante.nombre.toLowerCase();
                        final ubicacion = r.restaurante.ubicacion?.toLowerCase() ?? '';
                        final tags = r.tags.map((t) => t.nombre.toLowerCase());
                        return nombre.contains(_busqueda) ||
                            ubicacion.contains(_busqueda) ||
                            tags.any((t) => t.contains(_busqueda));
                      }).toList();

                if (filtrados.isEmpty) {
                  return const Center(child: Text('No hay restaurantes que coincidan.'));
                }

                return ListView.builder(
                  itemCount: filtrados.length,
                  itemBuilder: (context, index) {
                    final item = filtrados[index];
                    return RestauranteCard(
                      resumen: item,
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => RestauranteDetailScreen(
                          restauranteId: item.restaurante.id,
                        ),
                      )),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Añadir restaurante',
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const RestauranteFormScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _exportarDatos() async {
    try {
      final json = await exportDatabaseToJson(
        restaurantes: ref.read(restauranteRepositoryProvider),
        platos: ref.read(platoRepositoryProvider),
        recordatorios: ref.read(recordatorioRepositoryProvider),
        categorias: ref.read(categoriaRepositoryProvider),
      );

      final fecha = DateTime.now().toIso8601String().split('T').first;
      final path = await FilePicker.saveFile(
        dialogTitle: 'Guardar copia de seguridad',
        fileName: 'foodlog_backup_$fecha.json',
        type: FileType.custom,
        allowedExtensions: ['json'],
        bytes: Uint8List.fromList(utf8.encode(json)),
      );

      if (!mounted) return;
      if (path == null) return; // Cancelado por el usuario.

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Datos exportados correctamente.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al exportar los datos: $e')),
      );
    }
  }

  Future<void> _importarDatos() async {
    try {
      final resultado = await FilePicker.pickFiles(
        dialogTitle: 'Seleccionar copia de seguridad',
        type: FileType.custom,
        allowedExtensions: ['json'],
        withData: true,
      );
      if (resultado == null || resultado.files.isEmpty) return; // Cancelado.

      final bytes = resultado.files.single.bytes;
      if (bytes == null) {
        throw Exception('No se pudo leer el archivo seleccionado.');
      }

      final resumen = await importDatabaseFromJson(
        utf8.decode(bytes),
        restaurantes: ref.read(restauranteRepositoryProvider),
        platos: ref.read(platoRepositoryProvider),
        recordatorios: ref.read(recordatorioRepositoryProvider),
        categorias: ref.read(categoriaRepositoryProvider),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Importados ${resumen.restaurantes} restaurantes, '
            '${resumen.platos} platos, ${resumen.recordatorios} recordatorios '
            'y ${resumen.categorias} categorías.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al importar los datos: $e')),
      );
    }
  }
}

enum _DatosAction { exportar, importar }
