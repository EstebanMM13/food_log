import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:path/path.dart' as p;

import '../../core/photo_storage.dart';
import '../../domain/repositories/categoria_repository.dart';
import '../../domain/repositories/plato_repository.dart';
import '../../domain/repositories/recordatorio_repository.dart';
import '../../domain/repositories/restaurante_repository.dart';
import 'app_database.dart';

/// Thrown by [importarDesdeZip] when the selected file is neither a valid
/// zip nor a valid JSON backup payload, so the caller can show a clear
/// message instead of a raw [FormatException].
class BackupInvalidoException implements Exception {
  const BackupInvalidoException();

  @override
  String toString() =>
      'El archivo seleccionado no es una copia de seguridad válida de Food Log.';
}

/// Current shape version of the backup payload.
///
/// v1 was a plain JSON file with no photos at all (no `fotoPath` field in
/// the payload). v2 is distributed as a `.zip` containing a `backup.json`
/// entry (the same JSON shape as v1, plus a `fotoPath` field per
/// restaurant/dish holding just the photo's file *name* — never its
/// absolute path, which is specific to each device/install) and a `fotos/`
/// folder with the actual photo files those names refer to.
///
/// [importarDesdeZip] still accepts a raw v1 JSON file for backwards
/// compatibility, imported without photos since v1 never carried any.
const backupFormatVersion = 2;

/// Builds a full JSON dump of the database: every restaurant with its tags,
/// dishes, reminders and custom categories.
///
/// Shares the same "restaurantes" root shape as `assets/seed_restaurantes.json`
/// (see seed_loader.dart) plus the fields the one-time seed doesn't need
/// (recordatorios, categorias, plato comentario, fotoPath).
///
/// `fotoPath` here is only ever a bare file name (see [backupFormatVersion])
/// — pair this with [exportarComoZip] to also carry the actual photo bytes.
Future<String> exportDatabaseToJson({
  required RestauranteRepository restaurantes,
  required PlatoRepository platos,
  required RecordatorioRepository recordatorios,
  required CategoriaRepository categorias,
}) async {
  final lista = await restaurantes.watchAll().first;

  final restaurantesJson = <Map<String, dynamic>>[];
  for (final restaurante in lista) {
    final tags = await restaurantes.watchTagsFor(restaurante.id).first;
    final platosDelRestaurante = await platos.watchByRestaurante(restaurante.id).first;
    final recordatoriosDelRestaurante =
        await recordatorios.watchByRestaurante(restaurante.id).first;
    final categoriasDelRestaurante =
        await categorias.watchByRestaurante(restaurante.id).first;

    restaurantesJson.add({
      'nombre': restaurante.nombre,
      'ubicacion': restaurante.ubicacion,
      'notas': restaurante.notas,
      'visitas': restaurante.visitas,
      'fotoPath':
          restaurante.fotoPath == null ? null : p.basename(restaurante.fotoPath!),
      'tags': tags.map((t) => t.nombre).toList(),
      'platos': platosDelRestaurante
          .map((plato) => {
                'tipo': plato.tipo,
                'nombre': plato.nombre,
                'puntuacion': plato.puntuacion,
                'comentario': plato.comentario,
                'fotoPath': plato.fotoPath == null ? null : p.basename(plato.fotoPath!),
              })
          .toList(),
      'recordatorios': recordatoriosDelRestaurante
          .map((r) => {'texto': r.texto, 'hecho': r.hecho})
          .toList(),
      'categorias': categoriasDelRestaurante
          .map((c) => {'nombre': c.nombre, 'orden': c.orden})
          .toList(),
    });
  }

  final payload = {
    'version': backupFormatVersion,
    'exportedAt': DateTime.now().toIso8601String(),
    'restaurantes': restaurantesJson,
  };

  return const JsonEncoder.withIndent('  ').convert(payload);
}

/// Builds the full v2 backup: a zip with `backup.json` (the same payload
/// [exportDatabaseToJson] produces) plus a `fotos/` folder holding every
/// photo file referenced by a restaurant or dish, so restoring the backup on
/// another device/install doesn't lose any images.
///
/// A `fotoPath` whose file no longer exists on disk (deleted by hand outside
/// the app, etc.) is silently skipped — same best-effort philosophy as
/// [PhotoStorage.borrarSiExiste].
Future<List<int>> exportarComoZip({
  required RestauranteRepository restaurantes,
  required PlatoRepository platos,
  required RecordatorioRepository recordatorios,
  required CategoriaRepository categorias,
}) async {
  final json = await exportDatabaseToJson(
    restaurantes: restaurantes,
    platos: platos,
    recordatorios: recordatorios,
    categorias: categorias,
  );

  final archive = Archive()..addFile(ArchiveFile.string('backup.json', json));

  final fotoPaths = <String>{
    for (final restaurante in await restaurantes.getAll())
      if (restaurante.fotoPath != null) restaurante.fotoPath!,
    for (final plato in await platos.watchAll().first)
      if (plato.fotoPath != null) plato.fotoPath!,
  };

  for (final fotoPath in fotoPaths) {
    final archivo = File(fotoPath);
    if (!await archivo.exists()) continue; // Borrada a mano, etc.: best-effort.
    List<int> bytes;
    try {
      bytes = await archivo.readAsBytes();
    } catch (_) {
      // Deleted/became unreadable between the exists() check above and this
      // read (race with something else touching the file): same best-effort
      // philosophy as the exists() check — skip this one photo rather than
      // aborting the whole export.
      continue;
    }
    archive.addFile(ArchiveFile.bytes('fotos/${p.basename(fotoPath)}', bytes));
  }

  return ZipEncoder().encode(archive);
}

/// How many rows of each kind got added by [importDatabaseFromJson] /
/// [importarDesdeZip].
class ImportSummary {
  final int restaurantes;
  final int platos;
  final int recordatorios;
  final int categorias;

  const ImportSummary({
    required this.restaurantes,
    required this.platos,
    required this.recordatorios,
    required this.categorias,
  });
}

/// Parses [raw] as a plain v1 JSON payload (no photos) and inserts every
/// restaurant as a brand new row. Kept for backwards compatibility with old
/// backups — new exports go through [exportarComoZip]/[importarDesdeZip]
/// instead, which also carry photos.
Future<ImportSummary> importDatabaseFromJson(
  String raw, {
  required AppDatabase db,
  required RestauranteRepository restaurantes,
  required PlatoRepository platos,
  required RecordatorioRepository recordatorios,
  required CategoriaRepository categorias,
}) {
  final Map<String, dynamic> data;
  try {
    data = jsonDecode(raw) as Map<String, dynamic>;
  } on FormatException {
    throw const BackupInvalidoException();
  } on TypeError {
    throw const BackupInvalidoException();
  }
  return _insertarDesdeMapa(
    data,
    db: db,
    restaurantes: restaurantes,
    platos: platos,
    recordatorios: recordatorios,
    categorias: categorias,
  );
}

/// Restores a backup produced by [exportarComoZip] (a zip with
/// `backup.json` + `fotos/`), or a raw v1 JSON file for backwards
/// compatibility (no photos, since v1 never had any).
///
/// If [zipBytes] doesn't decode as a valid zip containing a `backup.json`
/// entry, it's treated as an old plain-JSON v1 backup instead of failing
/// outright. This covers both a genuine decode failure (`ArchiveException`)
/// and the `archive` package's own behavior of silently returning an empty
/// [Archive] for bytes that aren't zip-shaped at all, rather than throwing.
///
/// If the file is neither a valid zip nor valid JSON (garbage, a picture
/// picked by mistake, a truncated file), a [BackupInvalidoException] is
/// thrown instead of letting the raw `FormatException` from `utf8.decode`/
/// `jsonDecode` leak out to the caller.
Future<ImportSummary> importarDesdeZip(
  List<int> zipBytes, {
  required AppDatabase db,
  required RestauranteRepository restaurantes,
  required PlatoRepository platos,
  required RecordatorioRepository recordatorios,
  required CategoriaRepository categorias,
}) async {
  Archive? archivoDecodificado;
  try {
    archivoDecodificado = ZipDecoder().decodeBytes(zipBytes);
  } on ArchiveException {
    archivoDecodificado = null;
  }

  final entradaJson = archivoDecodificado?.findFile('backup.json');
  if (entradaJson == null) {
    // Not a v2 zip (or no backup.json inside it): assume it's an old plain
    // v1 JSON backup (no photos).
    final Map<String, dynamic> data;
    try {
      final raw = utf8.decode(zipBytes);
      data = jsonDecode(raw) as Map<String, dynamic>;
    } on FormatException {
      // Neither a valid zip nor valid JSON: not a Food Log backup at all.
      throw const BackupInvalidoException();
    } on TypeError {
      // Valid JSON, but not shaped like a backup payload (e.g. a bare array
      // or string instead of an object).
      throw const BackupInvalidoException();
    }
    return _insertarDesdeMapa(
      data,
      db: db,
      restaurantes: restaurantes,
      platos: platos,
      recordatorios: recordatorios,
      categorias: categorias,
    );
  }

  final archive = archivoDecodificado!;
  final data = jsonDecode(utf8.decode(entradaJson.content)) as Map<String, dynamic>;

  Future<String?> resolverFoto(String? nombreArchivoFoto) async {
    if (nombreArchivoFoto == null) return null;
    final entradaFoto = archive.findFile('fotos/$nombreArchivoFoto');
    if (entradaFoto == null) return null;
    return PhotoStorage.guardarBytes(entradaFoto.content, nombreArchivoFoto);
  }

  return _insertarDesdeMapa(
    data,
    db: db,
    restaurantes: restaurantes,
    platos: platos,
    recordatorios: recordatorios,
    categorias: categorias,
    resolverFoto: resolverFoto,
  );
}

/// Default `resolverFoto`: no zip to pull photo bytes from, so every
/// `fotoPath` filename resolves to "no photo".
Future<String?> _sinFoto(String? nombreArchivoFoto) async => null;

/// Shared insertion logic for both [importDatabaseFromJson] and
/// [importarDesdeZip]: walks the already-decoded [data] map and inserts
/// every restaurant (and its dishes/reminders/categories) as brand new rows
/// with fresh UUIDs generated by each repository's `insert` (see
/// lib/core/ids.dart). No attempt is made to match or merge with existing
/// data — importing the same payload twice creates duplicates, same
/// philosophy as the one-time seed import in seed_loader.dart.
///
/// [resolverFoto] turns a `fotoPath` filename from the JSON (or `null`) into
/// the absolute path to store in the new row. The default never resolves a
/// photo; [importarDesdeZip] passes a resolver that copies the matching zip
/// entry into [PhotoStorage] and returns the resulting absolute path.
///
/// The whole insertion loop runs inside a single [db] transaction: if any
/// row fails to insert partway through (a malformed entry, a repository
/// error, etc.), every row inserted earlier in this same import is rolled
/// back too, instead of leaving a partial import silently committed. Any
/// photo already copied into [PhotoStorage] during this same failed attempt
/// is also deleted, so a failed import never leaves orphaned rows or files
/// behind — it's all-or-nothing.
Future<ImportSummary> _insertarDesdeMapa(
  Map<String, dynamic> data, {
  required AppDatabase db,
  required RestauranteRepository restaurantes,
  required PlatoRepository platos,
  required RecordatorioRepository recordatorios,
  required CategoriaRepository categorias,
  Future<String?> Function(String? nombreArchivoFoto) resolverFoto = _sinFoto,
}) async {
  final fotosCopiadas = <String>[];

  Future<String?> resolverFotoConSeguimiento(String? nombreArchivoFoto) async {
    final resultado = await resolverFoto(nombreArchivoFoto);
    if (resultado != null) fotosCopiadas.add(resultado);
    return resultado;
  }

  try {
    return await db.transaction(() async {
      final lista = ((data['restaurantes'] as List?) ?? const [])
          .cast<Map<String, dynamic>>();

      var platosCount = 0;
      var recordatoriosCount = 0;
      var categoriasCount = 0;

      for (final item in lista) {
        final fotoRestaurante =
            await resolverFotoConSeguimiento(item['fotoPath'] as String?);
        final id = await restaurantes.insert(
          nombre: item['nombre'] as String,
          ubicacion: item['ubicacion'] as String?,
          notas: item['notas'] as String?,
          tags: ((item['tags'] as List?) ?? const []).cast<String>(),
          visitas: (item['visitas'] as num?)?.toInt() ?? 0,
          fotoPath: fotoRestaurante,
        );

        final platosDelRestaurante =
            ((item['platos'] as List?) ?? const []).cast<Map<String, dynamic>>();
        for (final plato in platosDelRestaurante) {
          final fotoPlato =
              await resolverFotoConSeguimiento(plato['fotoPath'] as String?);
          await platos.insert(
            restauranteId: id,
            tipo: plato['tipo'] as String,
            nombre: plato['nombre'] as String,
            puntuacion: (plato['puntuacion'] as num).toDouble(),
            comentario: plato['comentario'] as String?,
            fotoPath: fotoPlato,
          );
          platosCount++;
        }

        final recordatoriosDelRestaurante = ((item['recordatorios'] as List?) ?? const [])
            .cast<Map<String, dynamic>>();
        for (final recordatorio in recordatoriosDelRestaurante) {
          final recordatorioId = await recordatorios.insert(
            restauranteId: id,
            texto: recordatorio['texto'] as String,
          );
          if (recordatorio['hecho'] == true) {
            await recordatorios.setHecho(recordatorioId, true);
          }
        }
        recordatoriosCount += recordatoriosDelRestaurante.length;

        final categoriasDelRestaurante = ((item['categorias'] as List?) ?? const [])
            .cast<Map<String, dynamic>>();
        for (final categoria in categoriasDelRestaurante) {
          await categorias.insert(
            restauranteId: id,
            nombre: categoria['nombre'] as String,
          );
        }
        categoriasCount += categoriasDelRestaurante.length;
      }

      return ImportSummary(
        restaurantes: lista.length,
        platos: platosCount,
        recordatorios: recordatoriosCount,
        categorias: categoriasCount,
      );
    });
  } catch (_) {
    for (final fotoPath in fotosCopiadas) {
      await PhotoStorage.borrarSiExiste(fotoPath);
    }
    rethrow;
  }
}
