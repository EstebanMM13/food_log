import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/photo_storage.dart';
import '../../core/theme/app_theme.dart';
import 'foto_thumbnail.dart';

/// Form field for the optional restaurant/dish photo: shows the current
/// photo (or a themed placeholder), and a button to replace/add or remove
/// it via camera or gallery.
///
/// This widget only manages the *file on disk* — it copies whatever
/// `image_picker` returns into the app's own storage (see
/// [PhotoStorage.guardar]) and reports the new path back through
/// [onFotoPathChanged]. It never touches the database; the owning form
/// decides what to persist, and the repository layer is responsible for
/// deleting a photo file that gets replaced or orphaned (see
/// RestauranteRepositoryImpl/PlatoRepositoryImpl).
class PhotoPickerField extends StatelessWidget {
  final String? fotoPath;
  final ValueChanged<String?> onFotoPathChanged;

  const PhotoPickerField({
    super.key,
    required this.fotoPath,
    required this.onFotoPathChanged,
  });

  Future<void> _elegirFoto(BuildContext context) async {
    final opcion = await showModalBottomSheet<_OpcionFoto>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Hacer una foto'),
              onTap: () => Navigator.of(context).pop(_OpcionFoto.camara),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Elegir de la galería'),
              onTap: () => Navigator.of(context).pop(_OpcionFoto.galeria),
            ),
            if (fotoPath != null)
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('Quitar foto'),
                onTap: () => Navigator.of(context).pop(_OpcionFoto.quitar),
              ),
          ],
        ),
      ),
    );

    if (opcion == null) return;

    if (opcion == _OpcionFoto.quitar) {
      onFotoPathChanged(null);
      return;
    }

    final origen = opcion == _OpcionFoto.camara
        ? ImageSource.camera
        : ImageSource.gallery;
    final elegida = await ImagePicker().pickImage(
      source: origen,
      maxWidth: 1600,
      imageQuality: 85,
    );
    if (elegida == null) return;

    final rutaGuardada = await PhotoStorage.guardar(File(elegida.path));
    onFotoPathChanged(rutaGuardada);
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).extension<BrandAccentColors>();
    return Row(
      children: [
        FotoThumbnail(
          fotoPath: fotoPath,
          size: 72,
          borderRadius: const BorderRadius.all(Radius.circular(12)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _elegirFoto(context),
            icon: Icon(Icons.add_a_photo_outlined, color: accent?.accentInk),
            label: Text(fotoPath == null ? 'Añadir foto' : 'Cambiar foto'),
          ),
        ),
      ],
    );
  }
}

enum _OpcionFoto { camara, galeria, quitar }
