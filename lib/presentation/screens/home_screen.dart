import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/restaurantes_provider.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Log'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            tooltip: 'Estadísticas',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const EstadisticasScreen()),
            ),
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
}
