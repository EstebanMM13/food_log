import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../data/local/app_database.dart' show Restaurante;
import '../../domain/models/estadisticas.dart';
import '../providers/estadisticas_provider.dart';
import '../widgets/tag_chip.dart';

class EstadisticasScreen extends ConsumerWidget {
  const EstadisticasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estadisticasAsync = ref.watch(estadisticasProvider);
    final accent = Theme.of(context).extension<BrandAccentColors>()!;

    return Scaffold(
      appBar: AppBar(title: const Text('Estadísticas')),
      body: estadisticasAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (stats) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _HeroPuntuacion(accent: accent, media: stats.puntuacionGlobalMedia),
            const SizedBox(height: 20),
            _TarjetaSeccion(
              accent: accent,
              titulo: 'Más visitados',
              child: _ListaMasVisitados(
                accent: accent,
                items: stats.masVisitados,
              ),
            ),
            const SizedBox(height: 16),
            _TarjetaSeccion(
              accent: accent,
              titulo: 'Mejor valorados',
              child: _ListaRanking(accent: accent, items: stats.mejorValorados),
            ),
            const SizedBox(height: 16),
            _TarjetaSeccion(
              accent: accent,
              titulo: 'Platos más repetidos',
              child: _ListaPlatosRepetidos(
                accent: accent,
                items: stats.platosMasRepetidos,
              ),
            ),
            const SizedBox(height: 16),
            _TarjetaSeccion(
              accent: accent,
              titulo: 'Restaurantes por ubicación',
              child: _ListaPorUbicacion(
                accent: accent,
                porUbicacion: stats.porUbicacion,
              ),
            ),
            const SizedBox(height: 16),
            _TarjetaSeccion(
              accent: accent,
              titulo: 'Tags más usados',
              child: _ListaTags(accent: accent, items: stats.tagsMasUsados),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroPuntuacion extends StatelessWidget {
  final BrandAccentColors accent;
  final double? media;

  const _HeroPuntuacion({required this.accent, required this.media});

  @override
  Widget build(BuildContext context) {
    final progreso = media == null ? 0.0 : (media! / 10).clamp(0.0, 1.0);
    return Center(
      child: Column(
        children: [
          SizedBox(
            width: 128,
            height: 128,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox.expand(
                  child: CircularProgressIndicator(
                    value: 1,
                    strokeWidth: 10,
                    strokeCap: StrokeCap.round,
                    color: accent.paperCardAlt,
                  ),
                ),
                SizedBox.expand(
                  child: CircularProgressIndicator(
                    value: progreso,
                    strokeWidth: 10,
                    strokeCap: StrokeCap.round,
                    backgroundColor: Colors.transparent,
                    color: accent.accent,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      media == null ? '—' : media!.toStringAsFixed(1),
                      style: TextStyle(
                        fontFamily: 'Newsreader',
                        fontWeight: FontWeight.w700,
                        fontSize: 26,
                        color: accent.strongText,
                      ),
                    ),
                    Text(
                      '/10',
                      style: TextStyle(
                        fontFamily: 'Work Sans',
                        fontSize: 12,
                        color: accent.inkSoft,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Puntuación media global',
            style: TextStyle(
              fontFamily: 'Work Sans',
              fontSize: 13.5,
              color: accent.inkSoft,
            ),
          ),
        ],
      ),
    );
  }
}

class _TarjetaSeccion extends StatelessWidget {
  final BrandAccentColors accent;
  final String titulo;
  final Widget child;

  const _TarjetaSeccion({
    required this.accent,
    required this.titulo,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accent.paperCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: TextStyle(
              fontFamily: 'Newsreader',
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: accent.strongText,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _EstadoVacio extends StatelessWidget {
  final BrandAccentColors accent;
  final String texto;

  const _EstadoVacio({required this.accent, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          children: [
            SizedBox(
              width: 56,
              height: 56,
              child: CustomPaint(
                painter: _CirculoPunteadoPainter(color: accent.border),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              texto,
              style: TextStyle(
                fontFamily: 'Caveat',
                fontSize: 21,
                fontWeight: FontWeight.w600,
                color: accent.inkSoft,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ListaMasVisitados extends StatelessWidget {
  final BrandAccentColors accent;
  final List<RestauranteRanking> items;

  const _ListaMasVisitados({required this.accent, required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return _EstadoVacio(accent: accent, texto: 'Aún no hay datos.');
    }
    final maximo = items.map((r) => r.valor).reduce(math.max);
    return Column(
      children: [
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.restaurante.nombre,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Work Sans',
                          fontSize: 14,
                          color: accent.strongText,
                        ),
                      ),
                    ),
                    Text(
                      '${item.valor.toInt()} visitas',
                      style: TextStyle(
                        fontFamily: 'Work Sans',
                        fontSize: 12.5,
                        color: accent.inkSoft,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: LinearProgressIndicator(
                    value: maximo == 0 ? 0 : item.valor / maximo,
                    minHeight: 6,
                    backgroundColor: accent.paperCardAlt,
                    color: accent.accent,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _ListaRanking extends StatelessWidget {
  final BrandAccentColors accent;
  final List<RestauranteRanking> items;

  const _ListaRanking({required this.accent, required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return _EstadoVacio(accent: accent, texto: 'Aún no hay datos.');
    }
    return Column(
      children: [
        for (var i = 0; i < items.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accent.paperCardAlt,
                  ),
                  child: Text(
                    '${i + 1}',
                    style: TextStyle(
                      fontFamily: 'Work Sans',
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: accent.inkSoft,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    items[i].restaurante.nombre,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Work Sans',
                      fontSize: 14,
                      color: accent.strongText,
                    ),
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
                  child: Text(
                    items[i].valor.toStringAsFixed(1),
                    style: TextStyle(
                      fontFamily: 'Newsreader',
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: accent.strongText,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _ListaPlatosRepetidos extends StatelessWidget {
  final BrandAccentColors accent;
  final List<PlatoRepetido> items;

  const _ListaPlatosRepetidos({required this.accent, required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return _EstadoVacio(accent: accent, texto: 'Aún no hay datos.');
    }
    return Column(
      children: [
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${item.nombre} · ${item.veces} veces',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Work Sans',
                      fontSize: 14,
                      color: accent.strongText,
                    ),
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
                  child: Text(
                    item.puntuacionMedia.toStringAsFixed(1),
                    style: TextStyle(
                      fontFamily: 'Newsreader',
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: accent.strongText,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _ListaPorUbicacion extends StatelessWidget {
  final BrandAccentColors accent;
  final Map<String, List<Restaurante>> porUbicacion;

  const _ListaPorUbicacion({required this.accent, required this.porUbicacion});

  @override
  Widget build(BuildContext context) {
    if (porUbicacion.isEmpty) {
      return _EstadoVacio(accent: accent, texto: 'Aún no hay datos.');
    }
    final entradas = porUbicacion.entries.toList()
      ..sort((a, b) => b.value.length.compareTo(a.value.length));
    return Column(
      children: [
        for (final entrada in entradas)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Icon(Icons.location_on, size: 16, color: accent.accentInk),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    entrada.key,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Work Sans',
                      fontSize: 14,
                      color: accent.strongText,
                    ),
                  ),
                ),
                Text(
                  '${entrada.value.length}',
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
    );
  }
}

class _ListaTags extends StatelessWidget {
  final BrandAccentColors accent;
  final List<TagConteo> items;

  const _ListaTags({required this.accent, required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return _EstadoVacio(accent: accent, texto: 'Aún no hay datos.');
    }
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (var i = 0; i < items.length; i++)
          TagChip(
            nombre: '${items[i].nombre} · ${items[i].cantidad}',
            index: i,
            accent: accent,
          ),
      ],
    );
  }
}

/// Dashed-circle outline for the "no data yet" empty states.
class _CirculoPunteadoPainter extends CustomPainter {
  final Color color;

  const _CirculoPunteadoPainter({required this.color});

  static const int _dashCount = 24;
  static const double _gapFraction = 0.5;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    final rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: size.width / 2 - 1,
    );
    final anglePorTramo = 2 * math.pi / _dashCount;
    for (var i = 0; i < _dashCount; i++) {
      canvas.drawArc(
        rect,
        i * anglePorTramo,
        anglePorTramo * (1 - _gapFraction),
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CirculoPunteadoPainter oldDelegate) =>
      oldDelegate.color != color;
}
