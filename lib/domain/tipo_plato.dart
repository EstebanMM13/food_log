/// Categories offered in the dish form's dropdown. The database column
/// (`platos.tipo`) always stores the raw display string below, never the
/// enum name — this keeps imported data (which may contain values that
/// don't fit this list) readable without ever throwing.
enum TipoPlato { entrante, principal, postre, cafe, otro }

extension TipoPlatoX on TipoPlato {
  /// Human-readable label, and the exact string persisted to the database.
  String get label {
    switch (this) {
      case TipoPlato.entrante:
        return 'Entrante';
      case TipoPlato.principal:
        return 'Principal';
      case TipoPlato.postre:
        return 'Postre';
      case TipoPlato.cafe:
        return 'Café';
      case TipoPlato.otro:
        return 'Otro';
    }
  }
}

/// Maps a raw stored/imported string back to a [TipoPlato] for display
/// purposes (e.g. picking a dropdown default, choosing an icon). Falls
/// back to [TipoPlato.otro] for anything that doesn't match one of the
/// known labels, so unrecognized values (e.g. "Tapa" from the Obsidian
/// vault) never break the UI.
TipoPlato tipoPlatoFromString(String value) {
  final normalized = value.trim().toLowerCase();
  for (final tipo in TipoPlato.values) {
    if (tipo.label.toLowerCase() == normalized || tipo.name == normalized) {
      return tipo;
    }
  }
  return TipoPlato.otro;
}
