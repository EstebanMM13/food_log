import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../data/local/app_database.dart';
import '../../domain/tipo_plato.dart';
import '../screens/plato_form_screen.dart';

/// Collapsible category section shown in the restaurant detail screen
/// (e.g. "Entrantes", "Platos", "Postres"). Collapsed, it shows the
/// category's average score; expanded, it lists every dish with quick
/// actions to view its comment, edit it or delete it, plus an "Añadir"
/// button to log a new dish preselected to this category.
class CategoriaPlatosSection extends StatefulWidget {
  final String label;
  final List<Plato> platos;

  /// Exactly one of [tipoParaAnadir] (fixed section) or
  /// [tipoLibreParaAnadir] (custom, user-defined category) must be set.
  final TipoPlato? tipoParaAnadir;
  final String? tipoLibreParaAnadir;

  final String restauranteId;
  final Future<void> Function(String platoId) onEliminar;

  /// Present only for custom categories, showing a delete icon in the
  /// header. Deleting a category does not delete its dishes — they become
  /// orphaned and reappear under "Otros" until reassigned a type.
  final Future<void> Function()? onEliminarCategoria;

  const CategoriaPlatosSection({
    super.key,
    required this.label,
    required this.platos,
    this.tipoParaAnadir,
    this.tipoLibreParaAnadir,
    required this.restauranteId,
    required this.onEliminar,
    this.onEliminarCategoria,
  }) : assert(
          (tipoParaAnadir == null) != (tipoLibreParaAnadir == null),
          'Exactly one of tipoParaAnadir or tipoLibreParaAnadir must be provided.',
        );

  @override
  State<CategoriaPlatosSection> createState() => _CategoriaPlatosSectionState();
}

class _CategoriaPlatosSectionState extends State<CategoriaPlatosSection> {
  bool _expandido = false;

  double? get _media {
    if (widget.platos.isEmpty) return null;
    return widget.platos.map((p) => p.puntuacion).reduce((a, b) => a + b) / widget.platos.length;
  }

  Future<void> _confirmarEliminarCategoria(BuildContext context) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('¿Eliminar categoría "${widget.label}"?'),
        content: const Text(
          'Los platos que contiene no se eliminarán: pasarán a la sección "Otros".',
        ),
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
      await widget.onEliminarCategoria!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = _media;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => setState(() => _expandido = !_expandido),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.label,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const Icon(Icons.star, size: 18, color: Colors.amber),
                  const SizedBox(width: 4),
                  Text(media == null ? '—' : '${media.toStringAsFixed(1)}/10'),
                  if (widget.onEliminarCategoria != null)
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20),
                      tooltip: 'Eliminar categoría',
                      visualDensity: VisualDensity.compact,
                      onPressed: () => _confirmarEliminarCategoria(context),
                    ),
                  Icon(_expandido ? Icons.expand_less : Icons.expand_more),
                ],
              ),
            ),
          ),
          if (_expandido) ...[
            const Divider(height: 1),
            for (final plato in widget.platos) _PlatoRow(plato: plato, section: this),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => PlatoFormScreen(
                      restauranteId: widget.restauranteId,
                      tipoInicial: widget.tipoParaAnadir,
                      tipoLibreInicial: widget.tipoLibreParaAnadir,
                    ),
                  )),
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('Añadir'),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PlatoRow extends StatelessWidget {
  final Plato plato;
  final _CategoriaPlatosSectionState section;

  const _PlatoRow({required this.plato, required this.section});

  bool get _tieneComentario => plato.comentario != null && plato.comentario!.isNotEmpty;

  void _verComentario(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(plato.nombre),
        content: Text(plato.comentario!),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmarEliminar(BuildContext context) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('¿Eliminar ${plato.nombre}?'),
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
      await section.widget.onEliminar(plato.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(plato.nombre),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, size: 16, color: Colors.amber),
          const SizedBox(width: 4),
          Text('${plato.puntuacion.toStringAsFixed(1)}/10'),
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline),
            tooltip: _tieneComentario ? 'Ver comentario' : 'Sin comentario',
            onPressed: _tieneComentario ? () => _verComentario(context) : null,
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Editar',
            color: Theme.of(context).extension<BrandAccentColors>()?.accent,
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => PlatoFormScreen(
                restauranteId: section.widget.restauranteId,
                plato: plato,
              ),
            )),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            tooltip: 'Eliminar',
            onPressed: () => _confirmarEliminar(context),
          ),
        ],
      ),
    );
  }
}
