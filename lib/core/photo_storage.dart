import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'ids.dart';

/// Persists photos attached to restaurants/dishes as plain files under the
/// app's own documents directory, instead of storing raw bytes in SQLite.
/// Only the resulting path is kept in the `fotoPath` column.
///
/// Included in the zip backup format (see backup_service.dart): the photo
/// files themselves travel inside the zip's `fotos/` folder, and this class
/// is also used to write them back into app storage on import.
class PhotoStorage {
  const PhotoStorage._();

  /// Subfolder (inside the app's documents directory) where every photo is
  /// copied to.
  static const _subfolder = 'fotos';

  /// Copies [origen] into the app's own storage under a fresh UUID name
  /// (keeping the original extension) and returns the absolute path to the
  /// copy. The original file picked by `image_picker` is left untouched —
  /// only our copy is ever referenced from the database, so it can be
  /// deleted independently later.
  static Future<String> guardar(File origen) async {
    final carpeta = await _carpetaFotos();
    final extension = p.extension(origen.path);
    final destino = File(p.join(carpeta.path, '${newId()}$extension'));
    await origen.copy(destino.path);
    return destino.path;
  }

  /// Deletes the file at [path] if it exists. Safe to call with `null` or a
  /// path that's already gone (e.g. deleted by hand outside the app).
  ///
  /// This is a best-effort cleanup: any filesystem failure (locked file,
  /// permission error, etc.) is swallowed rather than rethrown, so a photo
  /// cleanup problem never aborts the database operation that triggered it
  /// (an `update`/`delete` that already touched the DB must still complete
  /// and be reported as successful to the caller).
  static Future<void> borrarSiExiste(String? path) async {
    if (path == null || path.isEmpty) return;
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {
      // Ignored on purpose — see the best-effort note above.
    }
  }

  /// Writes [bytes] into the app's managed photo folder under a fresh UUID
  /// name (keeping [nombreArchivo]'s extension) and returns the absolute
  /// resulting path.
  ///
  /// Used by [backup_service.dart]'s zip import: photo bytes come from a
  /// `fotos/<nombreArchivo>` entry inside the backup zip rather than from a
  /// `File` already on disk, so [guardar] (which copies an existing `File`)
  /// doesn't fit directly — but the import philosophy is "duplicate, never
  /// merge" (every import creates brand new rows with fresh UUIDs), so the
  /// photo file backing each new row must be independent too. Reusing the
  /// zip's literal file name here would make re-importing the same backup
  /// (or importing it on a device where that name is already taken) alias
  /// the new row's `fotoPath` to an already-existing file — then deleting or
  /// replacing the photo on ONE row would silently delete it for every other
  /// row that happens to share that file. Always generating a fresh name
  /// avoids that entirely.
  static Future<String> guardarBytes(
    List<int> bytes,
    String nombreArchivo,
  ) async {
    final carpeta = await _carpetaFotos();
    final extension = p.extension(nombreArchivo);
    final destino = File(p.join(carpeta.path, '${newId()}$extension'));
    await destino.writeAsBytes(bytes);
    return destino.path;
  }

  static Future<Directory> _carpetaFotos() async {
    final documentos = await getApplicationDocumentsDirectory();
    final carpeta = Directory(p.join(documentos.path, _subfolder));
    if (!await carpeta.exists()) {
      await carpeta.create(recursive: true);
    }
    return carpeta;
  }
}
