import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../data/local/app_database.dart';
import 'caja_notas.dart';
import 'dish_score.dart';
import 'foto_rayada.dart';

/// Read-only bottom sheet shown when tapping a dish row in the restaurant
/// detail screen. Purely presentational — editing still goes through
/// [PlatoFormScreen] via the row's own pencil icon, never from here.
Future<void> mostrarDetallePlato(
  BuildContext context, {
  required Plato plato,
  required String categoria,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: const Color(0x80000000),
    builder: (context) => _PlatoDetailSheet(plato: plato, categoria: categoria),
  );
}

class _PlatoDetailSheet extends StatelessWidget {
  final Plato plato;
  final String categoria;

  const _PlatoDetailSheet({required this.plato, required this.categoria});

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).extension<BrandAccentColors>()!;
    final tieneComentario =
        plato.comentario != null && plato.comentario!.isNotEmpty;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: ConstrainedBox(
          // `isScrollControlled: true` lets this sheet grow past the default
          // half-screen cap, but nothing here scrolled on its own — a long
          // comment or a short screen could overflow past the bottom edge.
          // Capping height and wrapping content in a SingleChildScrollView
          // keeps the sheet's own layout (photo + text) intact while still
          // scrolling as a whole when it doesn't fit.
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.85,
          ),
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: accent.paperCard,
              borderRadius: BorderRadius.circular(22),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plato.nombre,
                    style: TextStyle(
                      fontFamily: 'Newsreader',
                      fontWeight: FontWeight.w700,
                      fontSize: 23,
                      color: accent.strongText,
                    ),
                  ),
                  const SizedBox(height: 16),
                  LayoutBuilder(
                    builder: (context, constraints) => Center(
                      child: FotoDecorada(
                        fotoPath: plato.fotoPath,
                        width: constraints.maxWidth,
                        aspectRatio: 4 / 3,
                        borderRadius: 14,
                        rotationDegrees: 0.8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      DishScore(
                        plato.puntuacion.toStringAsFixed(1),
                        accent: accent,
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: accent.terracottaTint,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          categoria,
                          style: TextStyle(
                            fontFamily: 'Work Sans',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: accent.accentInk,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  CajaNotas(
                    minHeight: 70,
                    child: Text(
                      tieneComentario
                          ? plato.comentario!
                          : 'Sin comentario todavía.',
                      style: tieneComentario
                          ? TextStyle(
                              fontFamily: 'Work Sans',
                              fontSize: 14,
                              color: accent.strongText,
                            )
                          : TextStyle(
                              fontFamily: 'Caveat',
                              fontSize: 21,
                              fontWeight: FontWeight.w600,
                              color: accent.inkSoft,
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'Cerrar',
                        style: TextStyle(
                          fontFamily: 'Newsreader',
                          fontWeight: FontWeight.w700,
                          color: accent.accentInk,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
