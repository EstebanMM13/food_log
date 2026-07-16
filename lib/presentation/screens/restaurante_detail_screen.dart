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
import '../widgets/foto_rayada.dart';
import '../widgets/foto_thumbnail.dart';
import '../widgets/hand_check_painter.dart';
import '../widgets/tag_chip.dart';
import 'restaurante_form_screen.dart';

class RestauranteDetailScreen extends ConsumerWidget {
  final String restauranteId;

  const RestauranteDetailScreen({super.key, required this.restauranteId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accent = Theme.of(context).extension<BrandAccentColors>()!;
    final restaurantesAsync = ref.watch(restaurantesProvider);
    final tagsAsync = ref.watch(tagsPorRestauranteProvider);
    final platosAsync = ref.watch(platosDeRestauranteProvider(restauranteId));
    final recordatoriosAsync = ref.watch(
      recordatoriosDeRestauranteProvider(restauranteId),
    );
    final categoriasAsync = ref.watch(
      categoriasDeRestauranteProvider(restauranteId),
    );

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
        : platos.map((p) => p.puntuacion).reduce((a, b) => a + b) /
              platos.length;

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
        title: GestureDetector(
          onTap: () => _verNombreCompleto(context, restaurante!.nombre),
          child: Text(
            restaurante.nombre,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: accent.accentInk),
            tooltip: 'Editar restaurante',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => RestauranteFormScreen(
                  restaurante: restaurante,
                  tagsIniciales: tags.map((t) => t.nombre).toList(),
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.delete_outline, color: accent.accentInk),
            tooltip: 'Eliminar restaurante',
            onPressed: () => _confirmarEliminarRestaurante(
              context,
              ref,
              restaurante!.nombre,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Center(
            child: GestureDetector(
              onTap: () => _verFotoGrande(
                context,
                restaurante!.nombre,
                restaurante.fotoPath,
              ),
              child: FotoDecorada(
                fotoPath: restaurante.fotoPath,
                width: MediaQuery.sizeOf(context).width * 0.78,
                aspectRatio: 1,
                borderRadius: 18,
                rotationDegrees: -1.5,
              ),
            ),
          ),
          const SizedBox(height: 22),
          _InfoCard(
            accent: accent,
            restaurante: restaurante,
            media: media,
            onVerNotaMedia: () => _explicarNotaMedia(context),
            onEditarVisitas: () =>
                _editarVisitas(context, ref, restaurante!.visitas),
          ),
          if (tags.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (var i = 0; i < tags.length; i++)
                  TagChip(nombre: tags[i].nombre, index: i, accent: accent),
              ],
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: accent.accentInk, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: () => ref
                  .read(restauranteRepositoryProvider)
                  .registrarVisita(restauranteId),
              icon: Icon(Icons.check_circle_outline, color: accent.accentInk),
              label: Text(
                'Registrar visita',
                style: TextStyle(
                  fontFamily: 'Newsreader',
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: accent.accentInk,
                ),
              ),
            ),
          ),
          const SizedBox(height: 28),
          _SeccionNotas(
            accent: accent,
            notas: restaurante.notas,
            onEditar: () => _editarNotas(context, ref, restaurante!, tags),
          ),
          const SizedBox(height: 28),
          Text(
            'Platos',
            style: AppTheme.titleSection.copyWith(color: accent.strongText),
          ),
          const SizedBox(height: 8),
          // Always render the category sections, even with zero dishes —
          // each one carries its own "Añadir plato" row, the only entry
          // point to log the first dish. Hiding them behind an empty-state
          // note here would leave a fresh restaurant with no way to add one.
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
              icon: Icon(Icons.add_circle_outline, color: accent.accentInk),
              label: Text(
                'Añadir más',
                style: TextStyle(
                  fontFamily: 'Work Sans',
                  fontWeight: FontWeight.w600,
                  color: accent.accentInk,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          _EncabezadoSeccion(
            accent: accent,
            titulo: 'Próxima vez pedir',
            accionTexto: 'Añadir',
            accionIcono: Icons.add,
            onAccion: () => _mostrarDialogoNuevoRecordatorio(context, ref),
          ),
          const SizedBox(height: 8),
          if (recordatorios.isEmpty)
            Text(
              'Sin recordatorios pendientes.',
              style: TextStyle(
                fontFamily: 'Caveat',
                fontSize: 21,
                fontWeight: FontWeight.w600,
                color: accent.inkSoft,
              ),
            ),
          for (final recordatorio in recordatorios)
            ListTile(
              contentPadding: EdgeInsets.zero,
              onTap: () => ref
                  .read(recordatorioRepositoryProvider)
                  .setHecho(recordatorio.id, !recordatorio.hecho),
              leading: _HandCheckBox(
                accent: accent,
                checked: recordatorio.hecho,
                onChanged: (value) => ref
                    .read(recordatorioRepositoryProvider)
                    .setHecho(recordatorio.id, value),
              ),
              title: Text(
                recordatorio.texto,
                style: TextStyle(
                  fontFamily: 'Work Sans',
                  fontSize: 14,
                  color: accent.strongText,
                  decoration: recordatorio.hecho
                      ? TextDecoration.lineThrough
                      : null,
                ),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Eliminar recordatorio',
                onPressed: () => _confirmarEliminarRecordatorio(
                  context,
                  ref,
                  recordatorio.id,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _verFotoGrande(BuildContext context, String nombre, String? fotoPath) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(nombre),
        content: FotoThumbnail(
          fotoPath: fotoPath,
          size: 280,
          borderRadius: const BorderRadius.all(Radius.circular(16)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _verNombreCompleto(BuildContext context, String nombre) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nombre completo'),
        content: Text(nombre),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _explicarNotaMedia(BuildContext context) {
    showDialog<void>(
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

  Future<void> _editarVisitas(
    BuildContext context,
    WidgetRef ref,
    int visitasActuales,
  ) async {
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
            onPressed: () =>
                Navigator.of(context).pop(int.tryParse(controller.text.trim())),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
    if (nuevoValor != null && nuevoValor >= 0) {
      await ref
          .read(restauranteRepositoryProvider)
          .setVisitas(restauranteId, nuevoValor);
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
          decoration: const InputDecoration(
            hintText: 'Notas sobre este restaurante',
          ),
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
      await ref
          .read(restauranteRepositoryProvider)
          .update(
            id: restaurante.id,
            nombre: restaurante.nombre,
            ubicacion: restaurante.ubicacion,
            notas: nuevoTexto.isEmpty ? null : nuevoTexto,
            tags: tags.map((t) => t.nombre).toList(),
            fotoPath: restaurante.fotoPath,
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

  Future<void> _mostrarDialogoNuevoRecordatorio(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final controller = TextEditingController();
    final texto = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nuevo recordatorio'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Qué pedir la próxima vez',
          ),
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

  Future<void> _mostrarDialogoNuevaCategoria(
    BuildContext context,
    WidgetRef ref,
  ) async {
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(mensaje)));
      }
    }
  }
}

/// Info card ("Ubicación", "Nota media", "Visitas") shown near the top of
/// the restaurant detail screen — a [_FilaInfo] per fact, the last one
/// carrying the visit counter plus the [_BotonEditarVisitas] shortcut.
class _InfoCard extends StatelessWidget {
  final BrandAccentColors accent;
  final Restaurante restaurante;
  final double? media;
  final VoidCallback onVerNotaMedia;
  final VoidCallback onEditarVisitas;

  const _InfoCard({
    required this.accent,
    required this.restaurante,
    required this.media,
    required this.onVerNotaMedia,
    required this.onEditarVisitas,
  });

  @override
  Widget build(BuildContext context) {
    final media = this.media;
    return Container(
      decoration: BoxDecoration(
        color: accent.paperCard,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          if (restaurante.ubicacion != null &&
              restaurante.ubicacion!.isNotEmpty)
            _FilaInfo(
              accent: accent,
              icon: Icons.location_on,
              label: 'Ubicación',
              child: Text(
                restaurante.ubicacion!,
                style: TextStyle(
                  fontFamily: 'Work Sans',
                  fontSize: 14,
                  color: accent.strongText,
                ),
              ),
            ),
          _FilaInfo(
            accent: accent,
            icon: Icons.star,
            label: 'Nota media',
            child: GestureDetector(
              onTap: onVerNotaMedia,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    media == null ? '—' : media.toStringAsFixed(2),
                    style: TextStyle(
                      fontFamily: 'Newsreader',
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                      color: accent.strongText,
                    ),
                  ),
                  if (media != null)
                    Text(
                      ' /10',
                      style: TextStyle(
                        fontFamily: 'Work Sans',
                        fontSize: 12,
                        color: accent.inkSoft,
                      ),
                    ),
                ],
              ),
            ),
          ),
          _FilaInfo(
            accent: accent,
            icon: Icons.repeat,
            label: 'Visitas',
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${restaurante.visitas}',
                  style: TextStyle(
                    fontFamily: 'Newsreader',
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: accent.strongText,
                  ),
                ),
                const SizedBox(width: 10),
                _BotonEditarVisitas(accent: accent, onPressed: onEditarVisitas),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// One row of the info card ("Ubicación", "Nota media", "Visitas"):
/// leading icon + label on the left, arbitrary trailing content on the
/// right, separated from the next row by a hairline `ruleLine`.
class _FilaInfo extends StatelessWidget {
  final BrandAccentColors accent;
  final IconData icon;
  final String label;
  final Widget child;

  const _FilaInfo({
    required this.accent,
    required this.icon,
    required this.label,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: accent.ruleLine)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 17, color: accent.accentInk),
          const SizedBox(width: 8),
          Text(label.toUpperCase(), style: AppTheme.kicker(accent)),
          const Spacer(),
          child,
        ],
      ),
    );
  }
}

/// Small circular "edit visits" button — opens the "Corregir visitas"
/// dialog (same as tapping the visit count used to do). The visible ring
/// stays 30px (the design), but the [InkWell] fills a 44dp hit area
/// centered on it.
class _BotonEditarVisitas extends StatelessWidget {
  final BrandAccentColors accent;
  final VoidCallback onPressed;

  static const double _visualSize = 30;
  static const double _minTapSize = 44;

  const _BotonEditarVisitas({required this.accent, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        key: const Key('editar-visitas-button'),
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: SizedBox(
          width: _minTapSize,
          height: _minTapSize,
          child: Center(
            child: Container(
              width: _visualSize,
              height: _visualSize,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: accent.accentInk, width: 1.2),
              ),
              child: Icon(
                Icons.edit_outlined,
                size: 15,
                color: accent.accentInk,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Tappable stand-in for the "done" checkbox on a reminder row: an empty
/// square outline that reveals a loose, hand-drawn tick (via
/// [HandCheckPainter]) once [checked] is true, instead of Material's stock
/// checkbox visual.
class _HandCheckBox extends StatelessWidget {
  final BrandAccentColors accent;
  final bool checked;
  final ValueChanged<bool> onChanged;

  static const double _size = 22;
  // Same ≥44dp minimum interactive area used elsewhere in this app (see
  // `_BotonCircular` in home_screen.dart) — the 22px visual box alone sits
  // below the recommended minimum touch target.
  static const double _minTapSize = 44;

  const _HandCheckBox({
    required this.accent,
    required this.checked,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      checked: checked,
      label: 'Marcar como hecho',
      child: GestureDetector(
        onTap: () => onChanged(!checked),
        child: SizedBox(
          width: _minTapSize,
          height: _minTapSize,
          child: Center(
            child: Container(
              width: _size,
              height: _size,
              decoration: BoxDecoration(
                border: Border.all(color: accent.inkSoft, width: 1.4),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Transform.rotate(
                angle: -6 * 3.1415926535 / 180,
                child: CustomPaint(
                  size: const Size(_size, _size),
                  painter: HandCheckPainter(
                    checked: checked,
                    color: accent.secondary,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Restaurant "Notas" section. Unlike other sections, it has no separate
/// header + card: when empty it collapses to a single tappable prompt row
/// (no card background), and when filled it shows a compact kicker + inline
/// edit button above the handwritten note text — no surrounding container.
class _SeccionNotas extends StatelessWidget {
  final BrandAccentColors accent;
  final String? notas;
  final VoidCallback onEditar;

  const _SeccionNotas({
    required this.accent,
    required this.notas,
    required this.onEditar,
  });

  @override
  Widget build(BuildContext context) {
    final notas = this.notas;
    if (notas == null || notas.isEmpty) {
      return DecoratedBox(
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: accent.border, width: 1.5)),
        ),
        child: InkWell(
          onTap: onEditar,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                Icon(Icons.edit_outlined, size: 15, color: accent.inkSoft),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Añadir una nota…',
                    style: TextStyle(
                      fontFamily: 'Caveat',
                      fontSize: 18,
                      color: accent.inkSoft,
                    ),
                  ),
                ),
                Icon(Icons.add, size: 18, color: accent.inkSoft),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text('NOTAS', style: AppTheme.kicker(accent))),
            IconButton(
              icon: Icon(Icons.edit, size: 17, color: accent.accentInk),
              visualDensity: VisualDensity.compact,
              onPressed: onEditar,
              tooltip: 'Editar',
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          notas,
          style: TextStyle(
            fontFamily: 'Work Sans',
            fontSize: 15,
            color: accent.strongText,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

class _EncabezadoSeccion extends StatelessWidget {
  final BrandAccentColors accent;
  final String titulo;
  final String accionTexto;
  final IconData accionIcono;
  final VoidCallback onAccion;

  const _EncabezadoSeccion({
    required this.accent,
    required this.titulo,
    required this.accionTexto,
    required this.accionIcono,
    required this.onAccion,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          titulo,
          style: AppTheme.titleSection.copyWith(color: accent.strongText),
        ),
        TextButton.icon(
          onPressed: onAccion,
          icon: Icon(accionIcono, size: 17, color: accent.accentInk),
          label: Text(
            accionTexto,
            style: TextStyle(
              fontFamily: 'Work Sans',
              fontWeight: FontWeight.w600,
              color: accent.accentInk,
            ),
          ),
        ),
      ],
    );
  }
}
