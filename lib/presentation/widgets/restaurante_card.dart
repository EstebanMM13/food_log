import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/models/restaurante_resumen.dart';
import 'foto_rayada.dart';
import 'tag_chip.dart';

/// Home list card — thumbnail variant: a small square photo (or the
/// "sin foto" placeholder) next to the name, a rating pill and the
/// location, followed by a tag/visits footer.
class RestauranteCard extends StatelessWidget {
  final RestauranteResumen resumen;
  final VoidCallback onTap;

  const RestauranteCard({
    super.key,
    required this.resumen,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).extension<BrandAccentColors>()!;
    final restaurante = resumen.restaurante;
    final media = resumen.puntuacionMedia;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Material(
        color: accent.paperCard,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: accent.border),
              boxShadow: [
                BoxShadow(
                  color: accent.shadow,
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: FotoRayada(
                          fotoPath: restaurante.fotoPath,
                          width: 64,
                          height: 64,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    restaurante.nombre,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontFamily: 'Newsreader',
                                      fontWeight: FontWeight.w700,
                                      fontSize: 18,
                                      color: accent.strongText,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
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
                                      Icon(
                                        Icons.star,
                                        size: 14,
                                        color: accent.rating,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        media == null
                                            ? '—'
                                            : media.toStringAsFixed(1),
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
                              ],
                            ),
                            if (restaurante.ubicacion != null &&
                                restaurante.ubicacion!.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    size: 14,
                                    color: accent.inkSoft,
                                  ),
                                  const SizedBox(width: 3),
                                  Flexible(
                                    child: Text(
                                      restaurante.ubicacion!,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontFamily: 'Work Sans',
                                        fontSize: 12.5,
                                        color: accent.inkSoft,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (resumen.tags.isNotEmpty)
                        Expanded(
                          child: Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              for (var i = 0; i < resumen.tags.length; i++)
                                TagChip(
                                  nombre: resumen.tags[i].nombre,
                                  index: i,
                                  accent: accent,
                                ),
                            ],
                          ),
                        )
                      else
                        const Spacer(),
                      const SizedBox(width: 8),
                      Icon(Icons.repeat, size: 15, color: accent.inkSoft),
                      const SizedBox(width: 4),
                      Text(
                        '${restaurante.visitas} visitas',
                        style: TextStyle(
                          fontFamily: 'Work Sans',
                          fontSize: 12.5,
                          color: accent.inkSoft,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
