import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/photo_storage.dart';
import '../../data/local/app_database.dart';
import '../../domain/tipo_plato.dart';
import '../providers/repository_providers.dart';
import '../widgets/photo_picker_field.dart';

/// Add/edit form for a dish: type (dropdown + free-text fallback for
/// values that don't fit the enum), name and score (0-10 slider).
class PlatoFormScreen extends ConsumerStatefulWidget {
  final String restauranteId;
  final Plato? plato;

  /// Preselected category when adding a new dish from a specific
  /// [CategoriaPlatosSection] (e.g. tapping "Añadir" inside "Postres").
  /// Ignored in edit mode, where the dish's own type is used instead.
  final TipoPlato? tipoInicial;

  /// Preselected free-text category name when adding a new dish from a
  /// custom (user-defined) [CategoriaPlatosSection]. When set, the form
  /// starts on [TipoPlato.otro] with this value already filled in, but the
  /// dropdown stays fully editable. Ignored in edit mode.
  final String? tipoLibreInicial;

  const PlatoFormScreen({
    super.key,
    required this.restauranteId,
    this.plato,
    this.tipoInicial,
    this.tipoLibreInicial,
  });

  @override
  ConsumerState<PlatoFormScreen> createState() => _PlatoFormScreenState();
}

class _PlatoFormScreenState extends ConsumerState<PlatoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombreController;
  late final TextEditingController _tipoLibreController;
  late final TextEditingController _comentarioController;
  late TipoPlato _tipoSeleccionado;
  late double _puntuacion;
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

  bool get _esEdicion => widget.plato != null;

  /// Whether to show the free-text "specify type" field. Only relevant for
  /// dishes actually tied to a custom (user-defined) category: either being
  /// added from that category's own "Añadir" button ([tipoLibreInicial] set)
  /// or already carrying a custom category name when editing. A dish added
  /// straight into "Otros" doesn't need this — it just saves as "Otro".
  bool get _mostrarCampoLibre =>
      _tipoSeleccionado == TipoPlato.otro &&
      (widget.tipoLibreInicial != null ||
          (_esEdicion &&
              widget.plato!.tipo.trim().toLowerCase() != TipoPlato.otro.label.toLowerCase()));

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.plato?.nombre ?? '');
    if (widget.plato != null) {
      _tipoSeleccionado = tipoPlatoFromString(widget.plato!.tipo);
    } else if (widget.tipoLibreInicial != null) {
      _tipoSeleccionado = TipoPlato.otro;
    } else {
      _tipoSeleccionado = widget.tipoInicial ?? TipoPlato.entrante;
    }
    _tipoLibreController = TextEditingController(
      text: _tipoSeleccionado == TipoPlato.otro
          ? (widget.plato?.tipo ?? widget.tipoLibreInicial ?? '')
          : '',
    );
    _comentarioController = TextEditingController(text: widget.plato?.comentario ?? '');
    _puntuacion = widget.plato?.puntuacion ?? 5;
    _fotoPathOriginal = widget.plato?.fotoPath;
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
    _tipoLibreController.dispose();
    _comentarioController.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _guardando = true);

    final tipo = _mostrarCampoLibre ? _tipoLibreController.text.trim() : _tipoSeleccionado.label;
    final nombre = _nombreController.text.trim();
    final comentario =
        _comentarioController.text.trim().isEmpty ? null : _comentarioController.text.trim();
    final repo = ref.read(platoRepositoryProvider);

    if (_esEdicion) {
      await repo.update(widget.plato!.copyWith(
        tipo: tipo,
        nombre: nombre,
        puntuacion: _puntuacion,
        comentario: Value(comentario),
        fotoPath: Value(_fotoPath),
      ));
    } else {
      await repo.insert(
        restauranteId: widget.restauranteId,
        tipo: tipo,
        nombre: nombre,
        puntuacion: _puntuacion,
        comentario: comentario,
        fotoPath: _fotoPath,
      );
    }

    _guardado = true;
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_esEdicion ? 'Editar plato' : 'Nuevo plato')),
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
            DropdownButtonFormField<TipoPlato>(
              initialValue: _tipoSeleccionado,
              decoration: const InputDecoration(labelText: 'Tipo'),
              items: TipoPlato.values
                  .map((t) => DropdownMenuItem(value: t, child: Text(t.label)))
                  .toList(),
              onChanged: (value) => setState(() => _tipoSeleccionado = value!),
            ),
            if (_mostrarCampoLibre) ...[
              const SizedBox(height: 12),
              TextFormField(
                controller: _tipoLibreController,
                decoration: const InputDecoration(labelText: 'Especifica el tipo'),
                validator: (value) => (_mostrarCampoLibre && (value == null || value.trim().isEmpty))
                    ? 'Indica el tipo de plato'
                    : null,
              ),
            ],
            const SizedBox(height: 12),
            TextFormField(
              controller: _nombreController,
              decoration: const InputDecoration(labelText: 'Nombre del plato'),
              validator: (value) =>
                  (value == null || value.trim().isEmpty) ? 'El nombre es obligatorio' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _comentarioController,
              decoration: const InputDecoration(labelText: 'Comentario (opcional)'),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            Text('Puntuación: ${_puntuacion.toStringAsFixed(1)}'),
            Slider(
              value: _puntuacion,
              min: 0,
              max: 10,
              divisions: 40,
              label: _puntuacion.toStringAsFixed(1),
              onChanged: (value) => setState(() => _puntuacion = value),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _guardando ? null : _guardar,
              child: Text(_esEdicion ? 'Guardar cambios' : 'Añadir plato'),
            ),
          ],
        ),
      ),
    );
  }
}
