import 'package:flutter/services.dart' show rootBundle;

import '../../core/photo_storage.dart';
import '../../domain/repositories/plato_repository.dart';
import '../../domain/repositories/restaurante_repository.dart';

/// A handful of fictional restaurants from around the Comunidad Valenciana,
/// offered as an opt-in checkbox on the intro dialog so first-time users
/// have something to look at before they start logging their own visits.
/// Never loaded automatically.
///
/// Skips any sample restaurant whose name already exists, so checking the
/// box again (or reopening the dialog from the menu) doesn't create
/// duplicates — and if the user deleted a couple of them, only those
/// missing ones get reinserted.
Future<void> cargarRestaurantesDeMuestra({
  required RestauranteRepository restaurantes,
  required PlatoRepository platos,
}) async {
  final existentes = await restaurantes.getAll();
  final nombresExistentes = existentes
      .map((r) => r.nombre.trim().toLowerCase())
      .toSet();

  for (final r in _restaurantesDeMuestra) {
    if (nombresExistentes.contains(r.nombre.trim().toLowerCase())) continue;

    final fotoPath = await _copiarFotoDeMuestra(r.fotoAsset);
    final id = await restaurantes.insert(
      nombre: r.nombre,
      ubicacion: r.ubicacion,
      tags: r.tags,
      visitas: r.visitas,
      fotoPath: fotoPath,
    );
    for (final p in r.platos) {
      final fotoPlato = p.fotoAsset == null
          ? null
          : await _copiarFotoDeMuestra(p.fotoAsset!);
      await platos.insert(
        restauranteId: id,
        tipo: p.tipo,
        nombre: p.nombre,
        puntuacion: p.puntuacion,
        comentario: p.comentario,
        fotoPath: fotoPlato,
      );
    }
  }
}

/// Copies a bundled placeholder photo (packaged in the APK under
/// assets/sample_photos/) into the app's own photo storage, the same place
/// a real gallery/camera pick would end up — so sample restaurants/dishes
/// get a [fotoPath] that works with the normal photo widgets without those
/// needing to know the file came from an asset.
Future<String> _copiarFotoDeMuestra(String assetPath) async {
  final bytes = await rootBundle.load(assetPath);
  return PhotoStorage.guardarBytes(
    bytes.buffer.asUint8List(),
    assetPath,
  );
}

class _RestauranteMuestra {
  final String nombre;
  final String ubicacion;
  final int visitas;
  final List<String> tags;
  final List<_PlatoMuestra> platos;
  final String fotoAsset;

  const _RestauranteMuestra({
    required this.nombre,
    required this.ubicacion,
    required this.visitas,
    required this.tags,
    required this.platos,
    required this.fotoAsset,
  });
}

class _PlatoMuestra {
  final String nombre;
  final String tipo;
  final double puntuacion;
  final String? comentario;

  /// Path to a bundled dish photo, when one was provided for this sample
  /// dish. Null for dishes with no matching photo — they fall back to the
  /// app's normal "sin foto" placeholder, same as a user-created dish.
  final String? fotoAsset;

  const _PlatoMuestra(
    this.nombre,
    this.tipo,
    this.puntuacion, [
    this.comentario,
    this.fotoAsset,
  ]);
}

const _restaurantesDeMuestra = [
  _RestauranteMuestra(
    nombre: 'La Pepica',
    ubicacion: 'Valencia',
    visitas: 4,
    tags: ['Arrocería', 'Playa'],
    platos: [
      _PlatoMuestra('Ensalada de pulpo', 'Entrante', 8.1),
      _PlatoMuestra(
        'Paella valenciana',
        'Principal',
        9.2,
        'Arroz suelto y sabor a leña. De lo mejor de la ciudad.',
        'assets/sample_photos/La Pepica/paella valenciana.webp',
      ),
      _PlatoMuestra('Paella de marisco', 'Principal', 8.8),
      _PlatoMuestra(
        'Horchata con fartons',
        'Postre',
        8.0,
        null,
        'assets/sample_photos/La Pepica/horchata con fartons.webp',
      ),
      _PlatoMuestra(
        'Sangría',
        'Otro',
        7.5,
        null,
        'assets/sample_photos/La Pepica/sangria.webp',
      ),
    ],
    fotoAsset: 'assets/sample_photos/plato_01.jpg',
  ),
  _RestauranteMuestra(
    nombre: 'Casa Montaña',
    ubicacion: 'El Cabanyal, Valencia',
    visitas: 2,
    tags: ['Tapas', 'Vinos'],
    platos: [
      _PlatoMuestra(
        'Clóchinas al vapor',
        'Entrante',
        8.7,
        null,
        'assets/sample_photos/Casa Montaña/clochinas al vapor.webp',
      ),
      _PlatoMuestra('Alcachofas con jamón', 'Entrante', 8.0),
      _PlatoMuestra(
        'Bacalao con tomate',
        'Principal',
        8.9,
        'Receta de toda la vida, muy bien de punto de sal.',
        'assets/sample_photos/Casa Montaña/bacalao con tomate.webp',
      ),
      _PlatoMuestra('Arroz al horno', 'Principal', 8.5),
      _PlatoMuestra(
        'Torrija',
        'Postre',
        7.8,
        null,
        'assets/sample_photos/Casa Montaña/torrija.webp',
      ),
    ],
    fotoAsset: 'assets/sample_photos/plato_02.jpg',
  ),
  _RestauranteMuestra(
    nombre: 'El Portal',
    ubicacion: 'Alicante',
    visitas: 3,
    tags: ['Marisco', 'Arrocería'],
    platos: [
      _PlatoMuestra(
        'Gambas rojas de Denia',
        'Entrante',
        9.5,
        'Caras, pero las valen.',
        'assets/sample_photos/El portal/gambas rojas de Denia.webp',
      ),
      _PlatoMuestra('Salpicón de marisco', 'Entrante', 8.9),
      _PlatoMuestra(
        'Arroz a banda',
        'Principal',
        9.0,
        null,
        'assets/sample_photos/El portal/arroz a banda.webp',
      ),
      _PlatoMuestra(
        'Nube de limón',
        'Postre',
        8.2,
        null,
        'assets/sample_photos/El portal/nube de limon.webp',
      ),
      _PlatoMuestra('Coca de llanda', 'Postre', 7.6),
    ],
    fotoAsset: 'assets/sample_photos/plato_03.jpg',
  ),
  _RestauranteMuestra(
    nombre: 'Restaurante Marítim',
    ubicacion: 'Grao de Castellón',
    visitas: 1,
    tags: ['Playa', 'Marisco'],
    platos: [
      _PlatoMuestra('Ensaladilla de gambas', 'Entrante', 8.0),
      _PlatoMuestra(
        'Fideuà',
        'Principal',
        8.4,
        null,
        'assets/sample_photos/Restaurante Maritim/fideua.webp',
      ),
      _PlatoMuestra(
        'Suquet de pescado',
        'Principal',
        8.6,
        null,
        'assets/sample_photos/Restaurante Maritim/suquet de pescado.webp',
      ),
      _PlatoMuestra(
        'Tarta de queso',
        'Postre',
        7.9,
        null,
        'assets/sample_photos/Restaurante Maritim/tarta de queso.webp',
      ),
      _PlatoMuestra('Flan de naranja', 'Postre', 7.7),
    ],
    fotoAsset: 'assets/sample_photos/plato_04.jpg',
  ),
  _RestauranteMuestra(
    nombre: "L'Estanc",
    ubicacion: 'Gandía',
    visitas: 5,
    tags: ['Tapas', 'Terraza'],
    platos: [
      _PlatoMuestra(
        'Patatas bravas',
        'Entrante',
        7.0,
        null,
        "assets/sample_photos/L'Estanc/patatas bravas.webp",
      ),
      _PlatoMuestra('Esgarraet', 'Entrante', 7.8),
      _PlatoMuestra(
        'All i pebre de anguila',
        'Principal',
        8.3,
        'Picante justo, muy sabroso.',
        "assets/sample_photos/L'Estanc/all i pebre de anguila.webp",
      ),
      _PlatoMuestra(
        'Café',
        'Otro',
        6.5,
        null,
        "assets/sample_photos/L'Estanc/cafe.webp",
      ),
      _PlatoMuestra('Vermut de grifo', 'Otro', 7.3),
    ],
    fotoAsset: 'assets/sample_photos/plato_05.jpg',
  ),
];
