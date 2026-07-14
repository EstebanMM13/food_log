import 'dart:math' as math;
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../data/local/backup_service.dart';
import '../../domain/models/restaurante_resumen.dart';
import '../providers/database_provider.dart';
import '../providers/plato_providers.dart';
import '../providers/repository_providers.dart';
import '../providers/restaurantes_provider.dart';
import '../providers/theme_mode_provider.dart';
import '../widgets/intro_dialog.dart';
import '../widgets/restaurante_card.dart';
import 'estadisticas_screen.dart';
import 'restaurante_detail_screen.dart';
import 'restaurante_form_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _busqueda = '';
  _OrdenRestaurantes _orden = _OrdenRestaurantes.alfabetico;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _mostrarIntroSiCorresponde(),
    );
  }

  Future<void> _mostrarIntroSiCorresponde() async {
    if (await introYaVista()) return;
    if (!mounted) return;
    await mostrarDialogoIntro(context, ref);
  }

  @override
  Widget build(BuildContext context) {
    final resumenAsync = ref.watch(restaurantesResumenProvider);
    final platosAsync = ref.watch(platosTodosProvider);
    final accent = Theme.of(context).extension<BrandAccentColors>()!;
    final themeMode = ref.watch(themeModeProvider).value ?? ThemeMode.system;
    // When themeMode is ThemeMode.system, the actually-visible brightness
    // comes from the platform, not from themeMode itself.
    final brilloEfectivo = switch (themeMode) {
      ThemeMode.light => Brightness.light,
      ThemeMode.dark => Brightness.dark,
      ThemeMode.system => MediaQuery.platformBrightnessOf(context),
    };
    final esOscuroActualmente = brilloEfectivo == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Food Log',
                          style: TextStyle(
                            fontFamily: 'Newsreader',
                            fontWeight: FontWeight.w700,
                            fontSize: 26,
                            color: accent.accentInk,
                          ),
                        ),
                        Text(
                          'tu cuaderno de sabores',
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
                  _BotonCircular(
                    tooltip: esOscuroActualmente
                        ? 'Cambiar a modo claro'
                        : 'Cambiar a modo oscuro',
                    icon: esOscuroActualmente
                        ? Icons.light_mode
                        : Icons.dark_mode,
                    accent: accent,
                    onPressed: () => ref
                        .read(themeModeProvider.notifier)
                        .toggle(brilloEfectivo),
                  ),
                  const SizedBox(width: 8),
                  _BotonCircular(
                    tooltip: 'Estadísticas',
                    icon: Icons.bar_chart,
                    accent: accent,
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const EstadisticasScreen(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _MenuOpciones(
                    accent: accent,
                    onSelected: (accion) {
                      switch (accion) {
                        case _DatosAction.exportar:
                          _exportarDatos();
                        case _DatosAction.importar:
                          _importarDatos();
                        case _DatosAction.informacion:
                          mostrarDialogoIntro(context, ref);
                      }
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: _BuscadorPill(
                      accent: accent,
                      onChanged: (value) => setState(
                        () => _busqueda = value.trim().toLowerCase(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _MenuOrden(
                    accent: accent,
                    ordenActual: _orden,
                    onSelected: (orden) => setState(() => _orden = orden),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      'Restaurantes',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Newsreader',
                        fontWeight: FontWeight.w700,
                        fontSize: 21,
                        color: accent.strongText,
                      ),
                    ),
                  ),
                  if (resumenAsync.value != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Transform.rotate(
                        angle: -2 * math.pi / 180,
                        child: Text(
                          '${resumenAsync.value!.length} guardados',
                          style: TextStyle(
                            fontFamily: 'Caveat',
                            fontSize: 21,
                            fontWeight: FontWeight.w600,
                            color: accent.inkSoft,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: resumenAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(child: Text('Error: $error')),
                data: (resumen) {
                  final platosPorRestaurante = <String, List<String>>{};
                  for (final plato in platosAsync.value ?? const []) {
                    platosPorRestaurante
                        .putIfAbsent(plato.restauranteId, () => [])
                        .add(plato.nombre.toLowerCase());
                  }

                  final filtrados = _busqueda.isEmpty
                      ? resumen
                      : resumen.where((r) {
                          final nombre = r.restaurante.nombre.toLowerCase();
                          final ubicacion =
                              r.restaurante.ubicacion?.toLowerCase() ?? '';
                          final tags = r.tags.map(
                            (t) => t.nombre.toLowerCase(),
                          );
                          final platos =
                              platosPorRestaurante[r.restaurante.id] ??
                              const [];
                          return nombre.contains(_busqueda) ||
                              ubicacion.contains(_busqueda) ||
                              tags.any((t) => t.contains(_busqueda)) ||
                              platos.any((p) => p.contains(_busqueda));
                        }).toList();

                  filtrados.sort((a, b) {
                    switch (_orden) {
                      case _OrdenRestaurantes.alfabetico:
                        return a.restaurante.nombre.toLowerCase().compareTo(
                          b.restaurante.nombre.toLowerCase(),
                        );
                      case _OrdenRestaurantes.alfabeticoInverso:
                        return b.restaurante.nombre.toLowerCase().compareTo(
                          a.restaurante.nombre.toLowerCase(),
                        );
                      case _OrdenRestaurantes.mejorValorados:
                        return _compararPorNota(a, b, descendente: true);
                      case _OrdenRestaurantes.peorValorados:
                        return _compararPorNota(a, b, descendente: false);
                      case _OrdenRestaurantes.masVisitados:
                        return b.restaurante.visitas.compareTo(
                          a.restaurante.visitas,
                        );
                      case _OrdenRestaurantes.menosVisitados:
                        return a.restaurante.visitas.compareTo(
                          b.restaurante.visitas,
                        );
                    }
                  });

                  if (filtrados.isEmpty) {
                    return Center(
                      child: Text(
                        'No hay restaurantes que coincidan.',
                        style: TextStyle(
                          fontFamily: 'Work Sans',
                          color: accent.inkSoft,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.only(top: 4, bottom: 88),
                    itemCount: filtrados.length,
                    itemBuilder: (context, index) {
                      final item = filtrados[index];
                      return RestauranteCard(
                        resumen: item,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => RestauranteDetailScreen(
                              restauranteId: item.restaurante.id,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Añadir restaurante',
        backgroundColor: accent.accent,
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const RestauranteFormScreen()),
        ),
        // Ink (not white) on the terracotta fill, same AA-contrast fix as
        // `elevatedButtonTheme` in app_theme.dart — white-on-terracotta
        // falls below WCAG AA (~2.57:1) in dark mode.
        child: const _SpoonForkIcon(color: AppTheme.brandNavy),
      ),
    );
  }

  Future<void> _exportarDatos() async {
    try {
      final zipBytes = await exportarComoZip(
        restaurantes: ref.read(restauranteRepositoryProvider),
        platos: ref.read(platoRepositoryProvider),
        recordatorios: ref.read(recordatorioRepositoryProvider),
        categorias: ref.read(categoriaRepositoryProvider),
      );

      final fecha = DateTime.now().toIso8601String().split('T').first;
      final path = await FilePicker.saveFile(
        dialogTitle: 'Guardar copia de seguridad',
        fileName: 'foodlog_backup_$fecha.zip',
        type: FileType.custom,
        allowedExtensions: ['zip'],
        bytes: Uint8List.fromList(zipBytes),
      );

      if (!mounted) return;
      if (path == null) return; // Cancelado por el usuario.

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Datos exportados correctamente.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al exportar los datos: $e')),
      );
    }
  }

  Future<void> _importarDatos() async {
    try {
      final resultado = await FilePicker.pickFiles(
        dialogTitle: 'Seleccionar copia de seguridad',
        type: FileType.custom,
        allowedExtensions: ['zip', 'json'],
        withData: true,
      );
      if (resultado == null || resultado.files.isEmpty) return; // Cancelado.

      final bytes = resultado.files.single.bytes;
      if (bytes == null) {
        throw Exception('No se pudo leer el archivo seleccionado.');
      }

      final resumen = await importarDesdeZip(
        bytes,
        db: ref.read(databaseProvider),
        restaurantes: ref.read(restauranteRepositoryProvider),
        platos: ref.read(platoRepositoryProvider),
        recordatorios: ref.read(recordatorioRepositoryProvider),
        categorias: ref.read(categoriaRepositoryProvider),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Importados ${resumen.restaurantes} restaurantes, '
            '${resumen.platos} platos, ${resumen.recordatorios} recordatorios '
            'y ${resumen.categorias} categorías.',
          ),
        ),
      );
    } on BackupInvalidoException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al importar los datos: $e')),
      );
    }
  }
}

/// Shared 38px circular VISUAL chrome for the header buttons (`paperCard`
/// fill, `border` outline) — purely decorative, not itself the tappable
/// surface. Callers center this inside their own ≥44dp interactive area
/// (see [_BotonCircular] and [_MenuOpciones]), since 38px alone sits below
/// the recommended minimum touch target.
class _ChromeCircular extends StatelessWidget {
  final BrandAccentColors accent;
  final Widget child;

  static const double visualSize = 38;

  const _ChromeCircular({required this.accent, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: visualSize,
      height: visualSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: accent.paperCard,
        border: Border.all(color: accent.border),
      ),
      child: child,
    );
  }
}

/// Circular icon button used for the header actions — theme toggle and
/// stats shortcut. The [InkWell] fills a 44dp hit area; [_ChromeCircular]
/// centered inside it stays the original 38px visible circle.
class _BotonCircular extends StatelessWidget {
  final String tooltip;
  final IconData icon;
  final BrandAccentColors accent;
  final VoidCallback onPressed;

  static const double _minTapSize = 44;

  const _BotonCircular({
    required this.tooltip,
    required this.icon,
    required this.accent,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: SizedBox(
            width: _minTapSize,
            height: _minTapSize,
            child: Center(
              child: _ChromeCircular(
                accent: accent,
                child: Icon(icon, size: 18, color: accent.accentInk),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Same circular chrome as [_BotonCircular], wrapping the overflow
/// [PopupMenuButton] (exportar/importar/acerca de) inside the same 44dp
/// hit area.
class _MenuOpciones extends StatelessWidget {
  final BrandAccentColors accent;
  final ValueChanged<_DatosAction> onSelected;

  static const double _minTapSize = 44;

  const _MenuOpciones({required this.accent, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _minTapSize,
      height: _minTapSize,
      child: PopupMenuButton<_DatosAction>(
        tooltip: 'Más opciones',
        padding: EdgeInsets.zero,
        icon: _ChromeCircular(
          accent: accent,
          child: Icon(Icons.more_horiz, size: 18, color: accent.accentInk),
        ),
        onSelected: onSelected,
        itemBuilder: (context) => const [
          PopupMenuItem(
            value: _DatosAction.exportar,
            child: Text('Exportar datos'),
          ),
          PopupMenuItem(
            value: _DatosAction.importar,
            child: Text('Importar datos'),
          ),
          PopupMenuDivider(),
          PopupMenuItem(
            value: _DatosAction.informacion,
            child: Text('Acerca de Food Log'),
          ),
        ],
      ),
    );
  }
}

/// Same circular chrome as [_BotonCircular], wrapping the sort-order
/// [PopupMenuButton] inside the same 44dp hit area.
class _MenuOrden extends StatelessWidget {
  final BrandAccentColors accent;
  final _OrdenRestaurantes ordenActual;
  final ValueChanged<_OrdenRestaurantes> onSelected;

  static const double _minTapSize = 44;

  const _MenuOrden({
    required this.accent,
    required this.ordenActual,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _minTapSize,
      height: _minTapSize,
      child: PopupMenuButton<_OrdenRestaurantes>(
        tooltip: 'Ordenar',
        padding: EdgeInsets.zero,
        icon: _ChromeCircular(
          accent: accent,
          child: Icon(Icons.sort, size: 18, color: accent.accentInk),
        ),
        onSelected: onSelected,
        itemBuilder: (context) => [
          CheckedPopupMenuItem(
            value: _OrdenRestaurantes.alfabetico,
            checked: ordenActual == _OrdenRestaurantes.alfabetico,
            child: const Text('Alfabético (A-Z)'),
          ),
          CheckedPopupMenuItem(
            value: _OrdenRestaurantes.alfabeticoInverso,
            checked: ordenActual == _OrdenRestaurantes.alfabeticoInverso,
            child: const Text('Alfabético (Z-A)'),
          ),
          CheckedPopupMenuItem(
            value: _OrdenRestaurantes.mejorValorados,
            checked: ordenActual == _OrdenRestaurantes.mejorValorados,
            child: const Text('Mejor valorados'),
          ),
          CheckedPopupMenuItem(
            value: _OrdenRestaurantes.peorValorados,
            checked: ordenActual == _OrdenRestaurantes.peorValorados,
            child: const Text('Peor valorados'),
          ),
          CheckedPopupMenuItem(
            value: _OrdenRestaurantes.masVisitados,
            checked: ordenActual == _OrdenRestaurantes.masVisitados,
            child: const Text('Más visitados'),
          ),
          CheckedPopupMenuItem(
            value: _OrdenRestaurantes.menosVisitados,
            checked: ordenActual == _OrdenRestaurantes.menosVisitados,
            child: const Text('Menos visitados'),
          ),
        ],
      ),
    );
  }
}

/// Search pill: 48px tall, radius 24, `paperCard` fill and `border` outline.
class _BuscadorPill extends StatelessWidget {
  final BrandAccentColors accent;
  final ValueChanged<String> onChanged;

  const _BuscadorPill({required this.accent, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: accent.paperCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: accent.border),
      ),
      child: TextField(
        onChanged: onChanged,
        style: TextStyle(
          fontFamily: 'Work Sans',
          fontSize: 14.5,
          color: accent.strongText,
        ),
        decoration: InputDecoration(
          hintText: 'Buscar restaurante, plato o zona',
          hintStyle: TextStyle(
            fontFamily: 'Work Sans',
            fontSize: 14.5,
            color: accent.inkSoft,
          ),
          prefixIcon: Icon(Icons.search, size: 20, color: accent.inkSoft),
          border: InputBorder.none,
          isCollapsed: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}

enum _DatosAction { exportar, importar, informacion }

enum _OrdenRestaurantes {
  alfabetico,
  alfabeticoInverso,
  mejorValorados,
  peorValorados,
  masVisitados,
  menosVisitados,
}

/// Comparator for score-based ordering: restaurants without a score yet
/// (`puntuacionMedia == null`, i.e. no dishes rated) always sort to the end,
/// regardless of ascending/descending direction — they have no data, so they
/// are neither "best" nor "worst".
int _compararPorNota(
  RestauranteResumen a,
  RestauranteResumen b, {
  required bool descendente,
}) {
  final notaA = a.puntuacionMedia;
  final notaB = b.puntuacionMedia;
  if (notaA == null && notaB == null) return 0;
  if (notaA == null) return 1;
  if (notaB == null) return -1;
  return descendente ? notaB.compareTo(notaA) : notaA.compareTo(notaB);
}

/// Spoon+fork glyph from the app logo's circular badge, echoing the brand
/// mark on the "add restaurant" FAB instead of a generic "+".
class _SpoonForkIcon extends StatelessWidget {
  final Color color;

  const _SpoonForkIcon({required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 22,
      height: 22,
      child: CustomPaint(painter: _SpoonForkPainter(color)),
    );
  }
}

class _SpoonForkPainter extends CustomPainter {
  final Color color;

  const _SpoonForkPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.09
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;

    // Spoon: an oval bowl with a stem down to the fork's stem baseline.
    final bowl = Rect.fromCenter(
      center: Offset(w * 0.28, h * 0.28),
      width: w * 0.26,
      height: h * 0.34,
    );
    canvas.drawOval(bowl, paint);
    canvas.drawLine(
      Offset(w * 0.28, h * 0.45),
      Offset(w * 0.28, h * 0.88),
      paint,
    );

    // Fork: three tines merging into a single stem.
    for (final tx in [0.62, 0.72, 0.82]) {
      canvas.drawLine(Offset(w * tx, h * 0.12), Offset(w * tx, h * 0.42), paint);
    }
    canvas.drawLine(
      Offset(w * 0.62, h * 0.42),
      Offset(w * 0.82, h * 0.42),
      paint,
    );
    canvas.drawLine(
      Offset(w * 0.72, h * 0.42),
      Offset(w * 0.72, h * 0.88),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _SpoonForkPainter oldDelegate) =>
      oldDelegate.color != color;
}
