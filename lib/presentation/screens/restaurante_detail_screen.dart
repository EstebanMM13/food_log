import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../data/local/app_database.dart';
import '../../domain/repositories/categoria_repository.dart';
import '../../domain/tipo_plato.dart';
import '../providers/categoria_providers.dart';
import '../providers/plato_providers.dart';
import '../providers/recordatorio_providers.dart';
import '../providers/repository_providers.dart';
import '../providers/restaurantes_provider.dart';
import '../widgets/categoria_platos_section.dart';
import 'restaurante_form_screen.dart';

class RestauranteDetailScreen extends ConsumerWidget {
  final String restauranteId;

  const RestauranteDetailScreen({super.key, required this.restauranteId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final restaurantesAsync = ref.watch(restaurantesProvider);
    final tagsAsync = ref.watch(tagsPorRestauranteProvider);
    final platosAsync = ref.watch(platosDeRestauranteProvider(restauranteId));
    final recordatoriosAsync = ref.watch(recordatoriosDeRestauranteProvider(restauranteId));
    final categoriasAsync = ref.watch(categoriasDeRestauranteProvider(restauranteId));

    Restaurante? restaurante;
    for (final r in restaurantesAsync.value ?? const <Restaurante>[]) {
      if (r.id == restauranteId) {
        restaurante = r;
        break;
      }
    }

    if (restaurantesAsync.isLoading || restaurante == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final tags = tagsAsync.value?[restauranteId] ?? const [];
    final platos = platosAsync.value ?? const [];
    final recordatorios = recordatoriosAsync.value ?? const [];
    final categorias = categoriasAsync.value ?? const [];
    final media = platos.isEmpty
        ? null
        : platos.map((p) => p.puntuacion).reduce((a, b) => a + b) / platos.length;

    // Group dishes by category for the accordion sections. Dishes whose type
    // doesn't match a fixed TipoPlato are matched against user-defined
    // categories by name; only if none match do they fall back to "Otros"
    // (covers orphaned dishes from a deleted category, or imported data that
    // doesn't fit any known type).
    final entrantes = <Plato>[];
    final principales = <Plato>[];
    final postres = <Plato>[];
    final otros = <Plato>[];
    final platosPorCategoria = <String, List<Plato>>{
      for (final categoria in categorias) categoria.id: <Plato>[],
    };
    for (final plato in platos) {
      switch (tipoPlatoFromString(plato.tipo)) {
        case TipoPlato.entrante:
          entrantes.add(plato);
        case TipoPlato.principal:
          principales.add(plato);
        case TipoPlato.postre:
          postres.add(plato);
        case TipoPlato.otro:
          Categoria? categoriaCoincidente;
          for (final categoria in categorias) {
            if (categoria.nombre.trim().toLowerCase() ==
                plato.tipo.trim().toLowerCase()) {
              categoriaCoincidente = categoria;
              break;
            }
          }
          if (categoriaCoincidente != null) {
            platosPorCategoria[categoriaCoincidente.id]!.add(plato);
          } else {
            otros.add(plato);
          }
      }
    }

    Future<void> eliminarPlato(String platoId) =>
        ref.read(platoRepositoryProvider).delete(platoId);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          restaurante.nombre,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).extension<BrandAccentColors>()?.strongText,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Editar restaurante',
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => RestauranteFormScreen(
                restaurante: restaurante,
                tagsIniciales: tags.map((t) => t.nombre).toList(),
              ),
            )),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Eliminar restaurante',
            onPressed: () => _confirmarEliminarRestaurante(context, ref, restaurante!.nombre),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (restaurante.ubicacion != null && restaurante.ubicacion!.isNotEmpty)
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  size: 18,
                  color: Theme.of(context).extension<BrandAccentColors>()?.accent,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      style: Theme.of(context).textTheme.bodyLarge,
                      children: [
                        const TextSpan(
                          text: 'Ubicación: ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: restaurante.ubicacion),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.star, size: 18, color: Colors.amber),
              const SizedBox(width: 4),
              Text.rich(
                TextSpan(
                  style: Theme.of(context).textTheme.bodyLarge,
                  children: [
                    const TextSpan(
                      text: 'Nota media: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: media == null ? '—' : '${media.toStringAsFixed(2)} / 10'),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.info_outline, size: 18),
                tooltip: 'Nota media de todos los platos registrados',
                visualDensity: VisualDensity.compact,
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Nota media'),
                    content: const Text(
                      'Es el promedio de las puntuaciones de todos los platos '
                      'registrados en este restaurante.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cerrar'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(
                Icons.repeat,
                size: 18,
                color: Theme.of(context).extension<BrandAccentColors>()?.strongText,
              ),
              const SizedBox(width: 4),
              Text.rich(
                TextSpan(
                  style: Theme.of(context).textTheme.bodyLarge,
                  children: [
                    const TextSpan(
                      text: 'Visitas: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: '${restaurante.visitas}'),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit, size: 16),
                tooltip: 'Corregir número de visitas',
                visualDensity: VisualDensity.compact,
                onPressed: () => _editarVisitas(context, ref, restaurante!.visitas),
              ),
            ],
          ),
          if (tags.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: tags.map((t) => Chip(label: Text(t.nombre))).toList(),
            ),
          ],
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => ref.read(restauranteRepositoryProvider).registrarVisita(restauranteId),
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('Registrar visita'),
          ),
          const Divider(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Notas', style: Theme.of(context).textTheme.titleMedium),
              TextButton.icon(
                onPressed: () => _editarNotas(context, ref, restaurante!, tags),
                icon: const Icon(Icons.edit),
                label: const Text('Editar'),
              ),
            ],
          ),
          Text(
            restaurante.notas != null && restaurante.notas!.isNotEmpty
                ? restaurante.notas!
                : 'Sin notas.',
          ),
          const Divider(height: 32),
          Text('Platos', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          CategoriaPlatosSection(
            label: 'Entrantes',
            platos: entrantes,
            tipoParaAnadir: TipoPlato.entrante,
            restauranteId: restauranteId,
            onEliminar: eliminarPlato,
          ),
          CategoriaPlatosSection(
            label: 'Platos',
            platos: principales,
            tipoParaAnadir: TipoPlato.principal,
            restauranteId: restauranteId,
            onEliminar: eliminarPlato,
          ),
          CategoriaPlatosSection(
            label: 'Postres',
            platos: postres,
            tipoParaAnadir: TipoPlato.postre,
            restauranteId: restauranteId,
            onEliminar: eliminarPlato,
          ),
          for (final categoria in categorias)
            CategoriaPlatosSection(
              label: categoria.nombre,
              platos: platosPorCategoria[categoria.id] ?? const [],
              tipoLibreParaAnadir: categoria.nombre,
              restauranteId: restauranteId,
              onEliminar: eliminarPlato,
              onEliminarCategoria: () =>
                  ref.read(categoriaRepositoryProvider).delete(categoria.id),
            ),
          CategoriaPlatosSection(
            label: 'Otros',
            platos: otros,
            tipoParaAnadir: TipoPlato.otro,
            restauranteId: restauranteId,
            onEliminar: eliminarPlato,
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => _mostrarDialogoNuevaCategoria(context, ref),
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Añadir más'),
            ),
          ),
          const Divider(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Próxima vez pedir', style: Theme.of(context).textTheme.titleMedium),
              TextButton.icon(
                onPressed: () => _mostrarDialogoNuevoRecordatorio(context, ref),
                icon: const Icon(Icons.add),
                label: const Text('Añadir'),
              ),
            ],
          ),
          if (recordatorios.isEmpty) const Text('Sin recordatorios pendientes.'),
          for (final recordatorio in recordatorios)
            CheckboxListTile(
              value: recordatorio.hecho,
              title: Text(
                recordatorio.texto,
                style: recordatorio.hecho
                    ? const TextStyle(decoration: TextDecoration.lineThrough)
                    : null,
              ),
              onChanged: (value) => ref
                  .read(recordatorioRepositoryProvider)
                  .setHecho(recordatorio.id, value ?? false),
              secondary: IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Eliminar recordatorio',
                onPressed: () => _confirmarEliminarRecordatorio(context, ref, recordatorio.id),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _confirmarEliminarRestaurante(
    BuildContext context,
    WidgetRef ref,
    String nombre,
  ) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('¿Eliminar $nombre?'),
        content: const Text('Se borrarán también sus platos y recordatorios.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmado == true && context.mounted) {
      await ref.read(restauranteRepositoryProvider).delete(restauranteId);
      if (context.mounted) Navigator.of(context).pop();
    }
  }

  Future<void> _editarVisitas(BuildContext context, WidgetRef ref, int visitasActuales) async {
    final controller = TextEditingController(text: '$visitasActuales');
    final nuevoValor = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Corregir visitas'),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: 'Número de visitas'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(int.tryParse(controller.text.trim())),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
    if (nuevoValor != null && nuevoValor >= 0) {
      await ref.read(restauranteRepositoryProvider).setVisitas(restauranteId, nuevoValor);
    }
  }

  Future<void> _editarNotas(
    BuildContext context,
    WidgetRef ref,
    Restaurante restaurante,
    List<Tag> tags,
  ) async {
    final controller = TextEditingController(text: restaurante.notas ?? '');
    final nuevoTexto = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar notas'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: 4,
          decoration: const InputDecoration(hintText: 'Notas sobre este restaurante'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
    if (nuevoTexto != null) {
      await ref.read(restauranteRepositoryProvider).update(
            id: restaurante.id,
            nombre: restaurante.nombre,
            ubicacion: restaurante.ubicacion,
            notas: nuevoTexto.isEmpty ? null : nuevoTexto,
            tags: tags.map((t) => t.nombre).toList(),
          );
    }
  }

  Future<void> _confirmarEliminarRecordatorio(
    BuildContext context,
    WidgetRef ref,
    String recordatorioId,
  ) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar recordatorio?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmado == true) {
      await ref.read(recordatorioRepositoryProvider).delete(recordatorioId);
    }
  }

  Future<void> _mostrarDialogoNuevoRecordatorio(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final texto = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nuevo recordatorio'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Qué pedir la próxima vez'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
    if (texto != null && texto.isNotEmpty) {
      await ref
          .read(recordatorioRepositoryProvider)
          .insert(restauranteId: restauranteId, texto: texto);
    }
  }

  Future<void> _mostrarDialogoNuevaCategoria(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final nombre = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nueva categoría'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Nombre de la categoría'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
    if (nombre != null && nombre.isNotEmpty) {
      try {
        await ref
            .read(categoriaRepositoryProvider)
            .insert(restauranteId: restauranteId, nombre: nombre);
      } catch (e) {
        if (!context.mounted) return;
        final mensaje = e is CategoriaDuplicadaException
            ? e.toString()
            : 'No se pudo crear la categoría.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(mensaje)),
        );
      }
    }
  }
}
