// Imports restaurant notes from the Obsidian vault into
// assets/seed_restaurantes.json, which the app loads on first run (see
// lib/data/local/seed_loader.dart) to populate the database.
//
// How to run:
//   dart run tool/import_obsidian.dart
//   dart run tool/import_obsidian.dart "D:\OBSIDIAN\Personal\Comida\Restaurantes"
//
// Each note is expected to look like:
//
//   ---
//   tipo:
//     - restaurante
//     - comida
//   nombre: Camelot
//   ubicacion: Castellón de la Plana
//   visitas: 7
//   tags:
//     - Español
//   ---
//   ```dataviewjs
//   ... (cosmetic Obsidian dashboard code, ignored) ...
//   ```
//   ## 🍽️ Platos
//   | Tipo      | Plato                      | Puntuación |
//   | --------- | -------------------------- | ---------- |
//   | Entrante  | Patatas con queso y bacon  | 9          |
//   ...
//   ## 📝 Notas
//   - some free text, one bullet per line
//   ## 🔄 Próxima vez pedir
//   -
//
// Table column padding is inconsistent across notes (some use
// `| Tipo | Plato | Puntuación |`, others `|Tipo|Plato|Puntuación|`) and
// scores can be decimals (e.g. 8.75) — the parsing below tolerates both.

import 'dart:convert';
import 'dart:io';

const _defaultVaultPath = r'D:\OBSIDIAN\Personal\Comida\Restaurantes';

void main(List<String> args) async {
  final vaultPath = args.isNotEmpty ? args[0] : _defaultVaultPath;
  final vaultDir = Directory(vaultPath);

  if (!vaultDir.existsSync()) {
    stderr.writeln('Vault directory not found: $vaultPath');
    exit(1);
  }

  final archivosMd = vaultDir
      .listSync()
      .whereType<File>()
      .where((f) => f.path.toLowerCase().endsWith('.md'))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));

  final restaurantes = <Map<String, dynamic>>[];

  for (final archivo in archivosMd) {
    final contenido = await archivo.readAsString();
    final restaurante = _parseNota(contenido, archivo.path);
    if (restaurante != null) {
      restaurantes.add(restaurante);
    }
  }

  final salida = {'restaurantes': restaurantes};
  final outFile = File('assets/seed_restaurantes.json');
  await outFile.create(recursive: true);
  await outFile.writeAsString(const JsonEncoder.withIndent('  ').convert(salida));

  stdout.writeln(
      'Imported ${restaurantes.length} restaurants from $vaultPath into ${outFile.path}');
}

Map<String, dynamic>? _parseNota(String contenido, String rutaArchivo) {
  final frontmatter = _extraerFrontmatter(contenido);
  if (frontmatter == null) {
    stderr.writeln('Skipping $rutaArchivo: no frontmatter found');
    return null;
  }

  final nombre = frontmatter['nombre'];
  if (nombre == null || nombre.isEmpty) {
    stderr.writeln('Skipping $rutaArchivo: no "nombre" in frontmatter');
    return null;
  }

  return {
    'nombre': nombre,
    'ubicacion': frontmatter['ubicacion'],
    'visitas': int.tryParse(frontmatter['visitas'] ?? '') ?? 0,
    'tags': frontmatter['tags'] ?? <String>[],
    'notas': _extraerNotas(contenido),
    'platos': _extraerPlatos(contenido),
  };
}

/// Parses the `---\n...\n---` YAML frontmatter block. Only handles the
/// small subset of YAML this vault actually uses (scalars and simple
/// `- item` list entries) — a full YAML parser would be overkill for a
/// format this consistent.
Map<String, dynamic>? _extraerFrontmatter(String contenido) {
  final match = RegExp(r'^---\s*\n(.*?)\n---', dotAll: true).firstMatch(contenido);
  if (match == null) return null;

  final lineas = match.group(1)!.split('\n');
  final resultado = <String, dynamic>{};
  String? claveActual;
  final listaActual = <String>[];

  void cerrarListaSiHace() {
    if (claveActual != null && listaActual.isNotEmpty) {
      resultado[claveActual] = List<String>.from(listaActual);
    }
  }

  for (final lineaOriginal in lineas) {
    final linea = lineaOriginal.trimRight();
    if (linea.trim().isEmpty) continue;

    final itemListaMatch = RegExp(r'^\s*-\s*(.*)$').firstMatch(linea);
    if (itemListaMatch != null && linea.startsWith(' ')) {
      final valor = itemListaMatch.group(1)!.trim();
      if (valor.isNotEmpty) listaActual.add(valor);
      continue;
    }

    final claveValorMatch = RegExp(r'^([A-Za-z0-9_]+):\s*(.*)$').firstMatch(linea);
    if (claveValorMatch != null) {
      cerrarListaSiHace();
      listaActual.clear();
      claveActual = claveValorMatch.group(1);
      final valor = claveValorMatch.group(2)!.trim();
      if (valor.isNotEmpty) {
        resultado[claveActual!] = valor;
        claveActual = null;
      }
      // If valor is empty, this key opens a list on the following lines
      // (e.g. `tags:` followed by `  - Español`).
    }
  }
  cerrarListaSiHace();

  return resultado;
}

/// Finds the dish table using the same loose pattern as the vault's own
/// dataviewjs blocks (`/\|.*Plato.*\|\s*\n(\|.*\n)+/`), then splits each
/// row on `|`, tolerant of inconsistent padding (`| a | b |` vs `|a|b|`).
List<Map<String, dynamic>> _extraerPlatos(String contenido) {
  final tableMatch = RegExp(r'\|.*Plato.*\|\s*\n(\|.*\n)+').firstMatch(contenido);
  if (tableMatch == null) return [];

  final lineas = tableMatch
      .group(0)!
      .split('\n')
      .map((l) => l.trim())
      .where((l) => l.startsWith('|'))
      .toList();

  // First line is the header (Tipo | Plato | Puntuación), second is the
  // `---|---|---` separator; dish rows start after that.
  final filasDeDatos = lineas.skip(2);

  final platos = <Map<String, dynamic>>[];
  for (final fila in filasDeDatos) {
    final columnas = fila.split('|').map((c) => c.trim()).toList();
    // Splitting "| a | b | c |" on "|" yields ["", "a", "b", "c", ""].
    if (columnas.length < 4) continue;
    final tipo = columnas[1];
    final nombrePlato = columnas[2];
    final puntuacion = double.tryParse(columnas[3]);
    if (tipo.isEmpty || nombrePlato.isEmpty || puntuacion == null) continue;
    platos.add({'tipo': tipo, 'nombre': nombrePlato, 'puntuacion': puntuacion});
  }
  return platos;
}

/// Grabs the free-text bullet lines under "## 📝 Notas", joined with
/// newlines. Ignores the (usually empty) leading `- ` bullet.
String? _extraerNotas(String contenido) {
  final match = RegExp(r'## 📝 Notas\s*\n(.*?)(?=\n##|\z)', dotAll: true).firstMatch(contenido);
  if (match == null) return null;

  final lineas = match
      .group(1)!
      .split('\n')
      .map((l) => l.trim())
      .where((l) => l.startsWith('-'))
      .map((l) => l.substring(1).trim())
      .where((l) => l.isNotEmpty)
      .toList();

  return lineas.isEmpty ? null : lineas.join('\n');
}
