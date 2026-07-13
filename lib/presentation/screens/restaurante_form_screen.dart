import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/photo_storage.dart';
import '../../data/local/app_database.dart';
import '../providers/repository_providers.dart';
import '../providers/restaurantes_provider.dart';
import '../widgets/photo_picker_field.dart';

/// Add/edit form for a restaurant: name, location, tags (as editable
/// chips) and free-text notes. Pass [restaurante] and [tagsIniciales] to
/// edit an existing one; omit both to create a new one.
class RestauranteFormScreen extends ConsumerStatefulWidget {
  final Restaurante? restaurante;
  final List<String> tagsIniciales;

  const RestauranteFormScreen({
    super.key,
    this.restaurante,
    this.tagsIniciales = const [],
  });

  @override
  ConsumerState<RestauranteFormScreen> createState() => _RestauranteFormScreenState();
}

class _RestauranteFormScreenState extends ConsumerState<RestauranteFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombreController;
  late final TextEditingController _ubicacionController;
  late final TextEditingController _notasController;
  final _tagInputController = TextEditingController();
  late List<String> _tags;
  late final String? _fotoPathOriginal;
  String? _fotoPath;
  bool _guardando = false;
  bool _guardado = false;

  /// Every photo path that was ever assigned to [_fotoPath] during this
  /// form session (excluding [_fotoPathOriginal]), whether or not it ended
  /// up being the one actually saved. A user can pick photo A, then replace
  /// it with photo B before saving — A is already copied to disk by then,
  /// so without tracking it here it would never get cleaned up. On
  /// [dispose] everything in this set except the one truly persisted is
  /// deleted.
  final Set<String> _fotosTemporales = {};

  bool get _esEdicion => widget.restaurante != null;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.restaurante?.nombre ?? '');
    _ubicacionController = TextEditingController(text: widget.restaurante?.ubicacion ?? '');
    _notasController = TextEditingController(text: widget.restaurante?.notas ?? '');
    _tags = [...widget.tagsIniciales];
    _fotoPathOriginal = widget.restaurante?.fotoPath;
    _fotoPath = _fotoPathOriginal;
  }

  @override
  void dispose() {
    // Every intermediate/discarded photo picked during this session becomes
    // an orphaned file on disk unless nothing in the DB points to it. The
    // one that actually got saved (if any) must survive; every other one
    // gets cleaned up here.
    final fotoGuardada = _guardado ? _fotoPath : null;
    for (final foto in _fotosTemporales) {
      if (foto != fotoGuardada) {
        PhotoStorage.borrarSiExiste(foto);
      }
    }
    _nombreController.dispose();
    _ubicacionController.dispose();
    _notasController.dispose();
    _tagInputController.dispose();
    super.dispose();
  }

  void _agregarTag(String value) {
    final tag = value.trim();
    if (tag.isEmpty || _tags.contains(tag)) return;
    setState(() {
      _tags.add(tag);
      _tagInputController.clear();
    });
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _guardando = true);
    final repo = ref.read(restauranteRepositoryProvider);
    final nombre = _nombreController.text.trim();
    final ubicacion = _ubicacionController.text.trim();
    final notas = _notasController.text.trim();

    if (_esEdicion) {
      await repo.update(
        id: widget.restaurante!.id,
        nombre: nombre,
        ubicacion: ubicacion.isEmpty ? null : ubicacion,
        notas: notas.isEmpty ? null : notas,
        tags: _tags,
        fotoPath: _fotoPath,
      );
    } else {
      await repo.insert(
        nombre: nombre,
        ubicacion: ubicacion.isEmpty ? null : ubicacion,
        notas: notas.isEmpty ? null : notas,
        tags: _tags,
        fotoPath: _fotoPath,
      );
    }

    _guardado = true;
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final restaurantesExistentes = ref.watch(restaurantesProvider).value ?? const [];

    return Scaffold(
      appBar: AppBar(title: Text(_esEdicion ? 'Editar restaurante' : 'Nuevo restaurante')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            PhotoPickerField(
              fotoPath: _fotoPath,
              onFotoPathChanged: (nuevaRuta) => setState(() {
                if (nuevaRuta != null && nuevaRuta != _fotoPathOriginal) {
                  _fotosTemporales.add(nuevaRuta);
                }
                _fotoPath = nuevaRuta;
              }),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nombreController,
              decoration: const InputDecoration(labelText: 'Nombre'),
              validator: (value) {
                final nombre = value?.trim() ?? '';
                if (nombre.isEmpty) return 'El nombre es obligatorio';
                final duplicado = restaurantesExistentes.any((r) =>
                    r.id != widget.restaurante?.id &&
                    r.nombre.trim().toLowerCase() == nombre.toLowerCase());
                if (duplicado) return 'Ya existe un restaurante con ese nombre';
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _ubicacionController,
              decoration: const InputDecoration(labelText: 'Ubicación'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _tagInputController,
              decoration: InputDecoration(
                labelText: 'Añadir tag',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _agregarTag(_tagInputController.text),
                ),
              ),
              onFieldSubmitted: _agregarTag,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _tags
                  .map((tag) => Chip(
                        label: Text(tag),
                        onDeleted: () => setState(() => _tags.remove(tag)),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notasController,
              decoration: const InputDecoration(labelText: 'Notas'),
              maxLines: 4,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _guardando ? null : _guardar,
              child: Text(_esEdicion ? 'Guardar cambios' : 'Crear restaurante'),
            ),
          ],
        ),
      ),
    );
  }
}
