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
  final nombresExistentes = existentes.map((r) => r.nombre.trim().toLowerCase()).toSet();

  for (final r in _restaurantesDeMuestra) {
    if (nombresExistentes.contains(r.nombre.trim().toLowerCase())) continue;

    final id = await restaurantes.insert(
      nombre: r.nombre,
      ubicacion: r.ubicacion,
      tags: r.tags,
      visitas: r.visitas,
    );
    for (final p in r.platos) {
      await platos.insert(
        restauranteId: id,
        tipo: p.tipo,
        nombre: p.nombre,
        puntuacion: p.puntuacion,
        comentario: p.comentario,
      );
    }
  }
}

class _RestauranteMuestra {
  final String nombre;
  final String ubicacion;
  final int visitas;
  final List<String> tags;
  final List<_PlatoMuestra> platos;

  const _RestauranteMuestra({
    required this.nombre,
    required this.ubicacion,
    required this.visitas,
    required this.tags,
    required this.platos,
  });
}

class _PlatoMuestra {
  final String nombre;
  final String tipo;
  final double puntuacion;
  final String? comentario;

  const _PlatoMuestra(this.nombre, this.tipo, this.puntuacion, [this.comentario]);
}

const _restaurantesDeMuestra = [
  _RestauranteMuestra(
    nombre: 'La Pepica',
    ubicacion: 'Valencia',
    visitas: 4,
    tags: ['Arrocería', 'Playa'],
    platos: [
      _PlatoMuestra(
        'Paella valenciana',
        'Principal',
        9.2,
        'Arroz suelto y sabor a leña. De lo mejor de la ciudad.',
      ),
      _PlatoMuestra('Horchata con fartons', 'Postre', 8.0),
      _PlatoMuestra('Sangría', 'Otro', 7.5),
    ],
  ),
  _RestauranteMuestra(
    nombre: 'Casa Montaña',
    ubicacion: 'El Cabanyal, Valencia',
    visitas: 2,
    tags: ['Tapas', 'Vinos'],
    platos: [
      _PlatoMuestra('Clóchinas al vapor', 'Entrante', 8.7),
      _PlatoMuestra(
        'Bacalao con tomate',
        'Principal',
        8.9,
        'Receta de toda la vida, muy bien de punto de sal.',
      ),
      _PlatoMuestra('Torrija', 'Postre', 7.8),
    ],
  ),
  _RestauranteMuestra(
    nombre: 'El Portal',
    ubicacion: 'Alicante',
    visitas: 3,
    tags: ['Marisco', 'Arrocería'],
    platos: [
      _PlatoMuestra('Gambas rojas de Denia', 'Entrante', 9.5, 'Caras, pero las valen.'),
      _PlatoMuestra('Arroz a banda', 'Principal', 9.0),
      _PlatoMuestra('Nube de limón', 'Postre', 8.2),
    ],
  ),
  _RestauranteMuestra(
    nombre: 'Restaurante Marítim',
    ubicacion: 'Grao de Castellón',
    visitas: 1,
    tags: ['Playa', 'Marisco'],
    platos: [
      _PlatoMuestra('Fideuà', 'Principal', 8.4),
      _PlatoMuestra('Suquet de pescado', 'Principal', 8.6),
      _PlatoMuestra('Tarta de queso', 'Postre', 7.9),
    ],
  ),
  _RestauranteMuestra(
    nombre: "L'Estanc",
    ubicacion: 'Gandía',
    visitas: 5,
    tags: ['Tapas', 'Terraza'],
    platos: [
      _PlatoMuestra('Patatas bravas', 'Entrante', 7.0),
      _PlatoMuestra('All i pebre de anguila', 'Principal', 8.3, 'Picante justo, muy sabroso.'),
      _PlatoMuestra('Café', 'Otro', 6.5),
    ],
  ),
];
