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
import '../widgets/empty_note.dart';
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

    return Stack(
      children: [
        Scaffold(
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
                              style: AppTheme.titleScreen.copyWith(
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
                          style: AppTheme.titleSection.copyWith(
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
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, stack) =>
                        Center(child: Text('Error: $error')),
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

                      if (resumen.isEmpty) {
                        return const Center(
                          child: EmptyNote(
                            text:
                                'Tu cuaderno está en blanco. '
                                'Añade el primer sitio.',
                          ),
                        );
                      }

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
        ),
        // Deliberately outside the Scaffold's floatingActionButton slot (which
        // insets safely above the bottom edge) — Positioned here lets the tab
        // poke out past the SafeArea-wrapped body, like a page-marker
        // sticking out of a notebook. Offset by the system's bottom inset
        // (not a fixed negative value) so it never lands under a 3-button
        // nav bar or a gesture-navigation exclusion zone, where it could be
        // unreachable or invisible — this is the app's only "add
        // restaurant" entry point.
        Positioned(
          bottom: MediaQuery.paddingOf(context).bottom,
          right: 20,
          child: _NuevoTab(
            accent: accent,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const RestauranteFormScreen()),
            ),
          ),
        ),
      ],
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

/// Search field styled as an underlined writing line — no fill or full
/// border, just a single ruled underline (`accent.border`), like handwriting
/// on notebook paper. Hint and typed input both use the same legible Work
/// Sans style — a cursive hint read poorly at this size.
class _BuscadorPill extends StatelessWidget {
  final BrandAccentColors accent;
  final ValueChanged<String> onChanged;

  const _BuscadorPill({required this.accent, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: accent.border, width: 1.5)),
      ),
      child: TextField(
        onChanged: onChanged,
        style: TextStyle(
          fontFamily: 'Work Sans',
          fontSize: 13,
          color: accent.strongText,
        ),
        decoration: InputDecoration(
          hintText: 'buscar un sitio, un plato…',
          hintStyle: TextStyle(
            fontFamily: 'Work Sans',
            fontSize: 13,
            color: accent.inkSoft,
          ),
          prefixIcon: Icon(Icons.search, size: 15, color: accent.inkSoft),
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

/// Bookmark-tab "add restaurant" trigger. Deliberately positioned outside
/// the [Scaffold]'s safe content area (see the [Positioned] wrapper in
/// [_HomeScreenState.build]) so it visually pokes out past the bottom-right
/// edge of the screen, like a page-marker tab sticking out of a notebook.
class _NuevoTab extends StatelessWidget {
  final BrandAccentColors accent;
  final VoidCallback onPressed;

  static const double _width = 54;
  static const double _height = 70;

  const _NuevoTab({required this.accent, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _width,
      height: _height,
      child: Tooltip(
        message: 'Añadir restaurante',
        child: ClipPath(
          clipper: const _BookmarkTabClipper(),
          child: Material(
            color: accent.accent,
            child: InkWell(
              onTap: onPressed,
              // Ink (not white) on the terracotta fill, same AA-contrast fix
              // as `elevatedButtonTheme` in app_theme.dart — white-on-terracotta
              // falls below WCAG AA (~2.57:1) in dark mode.
              child: const Align(
                alignment: Alignment(0, -0.3),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, size: 17, color: AppTheme.brandNavy),
                    SizedBox(height: 2),
                    Text(
                      'nuevo',
                      style: TextStyle(
                        fontFamily: 'Caveat',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.brandNavy,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Clips a "bookmark tab" shape for [_NuevoTab] — a rounded-top rectangle
/// with a curved notch cut into the bottom-center, forming two rounded
/// "legs" flanking the notch, like a ribbon-tail page marker.
class _BookmarkTabClipper extends CustomClipper<Path> {
  const _BookmarkTabClipper();

  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;
    const topRadius = 16.0;
    final notchDepth = h * 0.32;
    final notchHalfWidth = w * 0.24;
    final midX = w / 2;

    return Path()
      ..moveTo(0, topRadius)
      ..quadraticBezierTo(0, 0, topRadius, 0)
      ..lineTo(w - topRadius, 0)
      ..quadraticBezierTo(w, 0, w, topRadius)
      ..lineTo(w, h)
      ..lineTo(midX + notchHalfWidth, h)
      ..quadraticBezierTo(midX, h - notchDepth, midX - notchHalfWidth, h)
      ..lineTo(0, h)
      ..close();
  }

  @override
  bool shouldReclip(covariant _BookmarkTabClipper oldClipper) => false;
}
