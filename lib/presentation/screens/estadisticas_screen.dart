import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/estadisticas_provider.dart';

class EstadisticasScreen extends ConsumerWidget {
  const EstadisticasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estadisticasAsync = ref.watch(estadisticasProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Estadísticas')),
      body: estadisticasAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (stats) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _CardMetrica(
              titulo: 'Puntuación media global',
              valor: stats.puntuacionGlobalMedia == null
                  ? '—'
                  : stats.puntuacionGlobalMedia!.toStringAsFixed(2),
            ),
            const SizedBox(height: 16),
            _CardLista(
              titulo: 'Más visitados',
              lineas: stats.masVisitados
                  .map((r) => '${r.restaurante.nombre} · ${r.valor.toInt()} visitas')
                  .toList(),
            ),
            const SizedBox(height: 16),
            _CardLista(
              titulo: 'Mejor valorados',
              lineas: stats.mejorValorados
                  .map((r) => '${r.restaurante.nombre} · ${r.valor.toStringAsFixed(2)}')
                  .toList(),
            ),
            const SizedBox(height: 16),
            _CardLista(
              titulo: 'Platos más repetidos',
              lineas: stats.platosMasRepetidos
                  .map((p) =>
                      '${p.nombre} · ${p.veces} veces · media ${p.puntuacionMedia.toStringAsFixed(2)}')
                  .toList(),
            ),
            const SizedBox(height: 16),
            _CardLista(
              titulo: 'Restaurantes por ubicación',
              lineas: stats.porUbicacion.entries
                  .map((e) => '${e.key} (${e.value.length})')
                  .toList(),
            ),
            const SizedBox(height: 16),
            _CardLista(
              titulo: 'Tags más usados',
              lineas: stats.tagsMasUsados
                  .map((t) => '${t.nombre} · ${t.cantidad}')
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardMetrica extends StatelessWidget {
  final String titulo;
  final String valor;

  const _CardMetrica({required this.titulo, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(titulo),
        trailing: Text(valor, style: Theme.of(context).textTheme.headlineSmall),
      ),
    );
  }
}

class _CardLista extends StatelessWidget {
  final String titulo;
  final List<String> lineas;

  const _CardLista({required this.titulo, required this.lineas});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(titulo, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (lineas.isEmpty) const Text('Sin datos todavía.'),
            for (final linea in lineas) Text(linea),
          ],
        ),
      ),
    );
  }
}
