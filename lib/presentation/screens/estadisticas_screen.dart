import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../data/local/app_database.dart' show Restaurante;
import '../../domain/models/estadisticas.dart';
import '../providers/estadisticas_provider.dart';
import '../providers/plato_providers.dart';
import '../providers/restaurantes_provider.dart';
import '../widgets/dashed_painter.dart';
import '../widgets/notebook_lines.dart';
import '../widgets/tag_chip.dart';
import '../widgets/taped_card.dart';

class EstadisticasScreen extends ConsumerWidget {
  const EstadisticasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estadisticasAsync = ref.watch(estadisticasProvider);
    final accent = Theme.of(context).extension<BrandAccentColors>()!;

    // Same providers `estadisticasProvider` already aggregates internally —
    // watched again here just to get the raw counts ("N sitios y M platos")
    // for the hero subtitle, which the aggregate `Estadisticas` model
    // doesn't expose directly (it only carries top-N rankings).
    final restaurantesResumenAsync = ref.watch(restaurantesResumenProvider);
    final platosTodosAsync = ref.watch(platosTodosProvider);
    final numSitios = restaurantesResumenAsync.value?.length ?? 0;
    final numPlatos = platosTodosAsync.value?.length ?? 0;

    return Scaffold(
      appBar: AppBar(title: const Text('Estadísticas')),
      body: NotebookLines(
        accent: accent,
        child: estadisticasAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('Error: $error')),
          data: (stats) => ListView(
            padding: const EdgeInsets.fromLTRB(56, 16, 16, 16),
            children: [
              TapedCard(
                accent: accent,
                colorCinta: accent.accent.withValues(alpha: 0.55),
                colorCintaSecundaria: accent.secondary.withValues(alpha: 0.5),
                child: Column(
                  children: [
                    _HeroPuntuacion(
                      accent: accent,
                      media: stats.puntuacionGlobalMedia,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'sobre $numSitios ${_pluralizar(numSitios, 'sitio', 'sitios')} '
                      'y $numPlatos ${_pluralizar(numPlatos, 'plato', 'platos')}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Caveat',
                        fontSize: 19,
                        fontWeight: FontWeight.w600,
                        color: accent.inkSoft,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              TapedCard(
                accent: accent,
                fondoPergamino: false,
                padding: EdgeInsets.zero,
                colorCinta: accent.accent.withValues(alpha: 0.5),
                child: _TarjetaSeccion(
                  accent: accent,
                  titulo: 'Más visitados',
                  child: _ListaMasVisitados(
                    accent: accent,
                    items: stats.masVisitados,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TapedCard(
                accent: accent,
                fondoPergamino: false,
                padding: EdgeInsets.zero,
                colorCinta: accent.secondary.withValues(alpha: 0.5),
                child: _TarjetaSeccion(
                  accent: accent,
                  titulo: 'Mejor valorados',
                  child: _ListaRanking(
                    accent: accent,
                    items: stats.mejorValorados,
                  ),
                ),
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
      ),
    );
  }
}

/// Spanish pluralizer for the hero subtitle counts — "1 sitio" vs "3 sitios".
String _pluralizar(int cantidad, String singular, String plural) =>
    cantidad == 1 ? singular : plural;

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
            style: AppTheme.titleSection.copyWith(color: accent.strongText),
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
                painter: DashedPathPainter.circle(
                  color: accent.border,
                  diameter: 56,
                ),
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
                const SizedBox(height: 8),
                _BarraVisita(
                  accent: accent,
                  fraccion: maximo == 0 ? 0 : item.valor / maximo,
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// A hand-sketched-looking bar: a thin baseline rule with a skewed,
/// asymmetrically-rounded fill on top of it, in place of a plain
/// [LinearProgressIndicator] — same proportional-width data logic
/// (`fraccion` = value / max), just a different visual treatment.
class _BarraVisita extends StatelessWidget {
  final BrandAccentColors accent;
  final double fraccion;

  const _BarraVisita({required this.accent, required this.fraccion});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 10,
      child: Stack(
        alignment: Alignment.bottomLeft,
        children: [
          Container(height: 1.2, color: accent.paperRule),
          FractionallySizedBox(
            widthFactor: fraccion.clamp(0.0, 1.0),
            alignment: Alignment.centerLeft,
            child: Transform(
              alignment: Alignment.centerLeft,
              transform: Matrix4.skewX(-8 * math.pi / 180),
              child: Container(
                height: 7,
                decoration: BoxDecoration(
                  color: accent.accent,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(2),
                    topRight: Radius.circular(6),
                    bottomLeft: Radius.circular(5),
                    bottomRight: Radius.circular(3),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: accent.shadow,
                      blurRadius: 2.5,
                      offset: const Offset(0, 1.5),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
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
        for (var i = 0; i < items.length; i++) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                SizedBox(
                  width: 28,
                  child: Text(
                    '${i + 1}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Caveat',
                      fontSize: 26,
                      fontWeight: FontWeight.w600,
                      color: accent.accent,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
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
          if (i != items.length - 1)
            CustomPaint(
              painter: DashedPathPainter(
                color: accent.paperRule,
                dashWidth: 4,
                dashGap: 3,
                strokeWidth: 1,
                pathBuilder: (size) => Path()
                  ..moveTo(0, size.height / 2)
                  ..lineTo(size.width, size.height / 2),
              ),
              child: const SizedBox(width: double.infinity, height: 1),
            ),
        ],
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
