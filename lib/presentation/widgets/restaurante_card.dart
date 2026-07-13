import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/models/restaurante_resumen.dart';

/// One row in the home list: name — location — score as the main line
/// (matching the mockup), with visit count and tags shown underneath as
/// secondary, more discreet information.
class RestauranteCard extends StatelessWidget {
  final RestauranteResumen resumen;
  final VoidCallback onTap;

  const RestauranteCard({super.key, required this.resumen, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final restaurante = resumen.restaurante;
    final media = resumen.puntuacionMedia;
    final subtitleStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        );

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        onTap: onTap,
        title: Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(
                restaurante.nombre,
                style: const TextStyle(fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (restaurante.ubicacion != null && restaurante.ubicacion!.isNotEmpty) ...[
              const SizedBox(width: 8),
              const Icon(Icons.location_on, size: 16),
              const SizedBox(width: 2),
              Expanded(
                flex: 2,
                child: Text(
                  restaurante.ubicacion!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
            const SizedBox(width: 8),
            Icon(
              Icons.star,
              size: 16,
              color: Theme.of(context).extension<BrandAccentColors>()?.rating,
            ),
            const SizedBox(width: 2),
            Text(media == null ? '—' : '${media.toStringAsFixed(1)}/10'),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('${restaurante.visitas} visitas', style: subtitleStyle),
            if (resumen.tags.isNotEmpty) ...[
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                children: resumen.tags
                    .map((t) => Chip(
                          label: Text(t.nombre),
                          visualDensity: VisualDensity.compact,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ))
                    .toList(),
              ),
            ],
          ],
        ),
        isThreeLine: resumen.tags.isNotEmpty,
      ),
    );
  }
}
