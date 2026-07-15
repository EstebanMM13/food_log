import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../data/local/app_database.dart';
import '../../domain/tipo_plato.dart';
import '../screens/plato_form_screen.dart';
import 'dashed_painter.dart';
import 'plato_detail_modal.dart';

/// Collapsible category card shown in the restaurant detail screen
/// (e.g. "Entrantes", "Platos", "Postres"). Collapsed, it shows the
/// category's average score; expanded, it lists every dish with quick
/// actions to open its read-only detail, edit it or delete it, plus an
/// "Añadir" row to log a new dish preselected to this category.
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
    return widget.platos.map((p) => p.puntuacion).reduce((a, b) => a + b) /
        widget.platos.length;
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
    final accent = Theme.of(context).extension<BrandAccentColors>()!;
    final media = _media;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: accent.paperCard,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => setState(() => _expandido = !_expandido),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.label.toUpperCase(),
                      style: AppTheme.kicker(accent),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: accent.amberTint,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star, size: 14, color: accent.rating),
                        const SizedBox(width: 4),
                        Text(
                          media == null ? '—' : media.toStringAsFixed(1),
                          style: TextStyle(
                            fontFamily: 'Newsreader',
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: accent.strongText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (widget.onEliminarCategoria != null)
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20),
                      tooltip: 'Eliminar categoría',
                      visualDensity: VisualDensity.compact,
                      onPressed: () => _confirmarEliminarCategoria(context),
                    ),
                  const SizedBox(width: 4),
                  AnimatedRotation(
                    turns: _expandido ? 0.5 : 0,
                    duration: const Duration(milliseconds: 180),
                    child: Icon(Icons.expand_more, color: accent.inkSoft),
                  ),
                ],
              ),
            ),
          ),
          if (_expandido) ...[
            Divider(height: 1, color: accent.ruleLine),
            for (final plato in widget.platos)
              _PlatoRow(plato: plato, section: this),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
              child: _FilaAnadirPlato(
                accent: accent,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => PlatoFormScreen(
                      restauranteId: widget.restauranteId,
                      tipoInicial: widget.tipoParaAnadir,
                      tipoLibreInicial: widget.tipoLibreParaAnadir,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _FilaAnadirPlato extends StatelessWidget {
  final BrandAccentColors accent;
  final VoidCallback onTap;

  const _FilaAnadirPlato({required this.accent, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: CustomPaint(
        painter: DashedPathPainter.roundedRect(color: accent.border),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add, size: 18, color: accent.accentInk),
              const SizedBox(width: 6),
              Text(
                'Añadir plato',
                style: TextStyle(
                  fontFamily: 'Work Sans',
                  fontWeight: FontWeight.w600,
                  fontSize: 13.5,
                  color: accent.accentInk,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlatoRow extends StatelessWidget {
  final Plato plato;
  final _CategoriaPlatosSectionState section;

  const _PlatoRow({required this.plato, required this.section});

  bool get _tieneComentario =>
      plato.comentario != null && plato.comentario!.isNotEmpty;

  bool get _tieneFoto => plato.fotoPath != null && plato.fotoPath!.isNotEmpty;

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
    final accent = Theme.of(context).extension<BrandAccentColors>()!;
    return InkWell(
      onTap: () => mostrarDetallePlato(
        context,
        plato: plato,
        categoria: section.widget.label,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            // Placeholder icon only — the real photo (if any) is reserved
            // for the detail modal, per the redesign spec.
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: _tieneFoto ? accent.terracottaTint : accent.paperCardAlt,
                borderRadius: BorderRadius.circular(7),
              ),
              child: Icon(
                _tieneFoto ? Icons.restaurant : Icons.restaurant_outlined,
                size: 14,
                color: _tieneFoto ? accent.accentInk : accent.inkSoft,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                plato.nombre,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Work Sans',
                  fontSize: 14,
                  color: accent.strongText,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Icon(Icons.star, size: 14, color: accent.rating),
            const SizedBox(width: 3),
            Text(
              plato.puntuacion.toStringAsFixed(1),
              style: TextStyle(
                fontFamily: 'Work Sans',
                fontSize: 13,
                color: accent.inkSoft,
              ),
            ),
            IconButton(
              icon: Icon(
                _tieneComentario
                    ? Icons.chat_bubble
                    : Icons.chat_bubble_outline,
                size: 17,
                color: _tieneComentario ? accent.accentInk : accent.inkSoft,
              ),
              tooltip: _tieneComentario ? 'Ver comentario' : 'Sin comentario',
              visualDensity: VisualDensity.compact,
              onPressed: () => mostrarDetallePlato(
                context,
                plato: plato,
                categoria: section.widget.label,
              ),
            ),
            PopupMenuButton<String>(
              icon: Icon(Icons.edit, size: 18, color: accent.accentInk),
              tooltip: 'Opciones',
              padding: EdgeInsets.zero,
              onSelected: (value) {
                if (value == 'editar') {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => PlatoFormScreen(
                        restauranteId: section.widget.restauranteId,
                        plato: plato,
                      ),
                    ),
                  );
                } else if (value == 'eliminar') {
                  _confirmarEliminar(context);
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'editar', child: Text('Editar')),
                PopupMenuItem(value: 'eliminar', child: Text('Eliminar')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
