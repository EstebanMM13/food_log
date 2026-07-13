<p align="center">
  <img src="assets/branding/icon.png" width="112" alt="Food Log icon" />
</p>

<h1 align="center">Food Log</h1>

<p align="center">
  A local-first Flutter app for tracking restaurants, dishes and ratings — the restaurant notebook you'd otherwise keep scattered across notes apps, turned into something that actually queries and aggregates your data.
</p>

<p align="center">
  <a href="https://github.com/EstebanMM13/food_log/actions/workflows/ci.yml">
    <img src="https://github.com/EstebanMM13/food_log/actions/workflows/ci.yml/badge.svg" alt="CI status" />
  </a>
  <a href="https://github.com/EstebanMM13/food_log/releases/latest">
    <img src="https://img.shields.io/github/v/release/EstebanMM13/food_log" alt="Latest release" />
  </a>
</p>

<p align="center">
  <a href="https://github.com/EstebanMM13/food_log/releases/latest">Download the Android APK</a>
</p>

---

## Why

I used to keep a note per restaurant in Obsidian — what I ordered, a score, a
reminder for next time — with a Dataview dashboard on top for stats. It
worked, but it wasn't built for the job: no structured queries, no shared
access, and any pattern across restaurants (best-rated dish type, most-visited
places, tags I keep gravitating to) had to be eyeballed by hand.

Food Log is that habit rebuilt as a proper app: same data, real relational
storage, and a stats screen that answers the questions the notes never could.

## Features

- **Restaurant list** with search by name, location or tag.
- **Restaurant detail**: info, dish list, free-text notes, "order next time"
  reminders you can check off, one-tap visit counter.
- **Add/edit restaurant** with tags as editable chips.
- **Add/edit dish** with type, name and score.
- **Global statistics**: overall average, most-visited places, top-rated
  places, most-repeated dishes, restaurants by location, most-used tags.
- **Custom dish categories** per restaurant, beyond the fixed Entrantes/Platos/
  Postres sections (e.g. "Bebidas", "Tapas").
- **JSON export/import**: back up the full database to a JSON file, or import
  one back in — a cheap stand-in for "share with a friend" before there's a
  backend.
- **Dark mode**, following the system's light/dark preference by default, with
  a manual toggle that overrides it and persists across restarts.
- **Obsidian vault import**: a companion script converts an existing Obsidian
  vault of restaurant notes into a JSON file you can load through the app's
  own import action.

## Screenshots

> _Coming soon._

## Tech stack & architecture

| Layer | Choice | Why |
|---|---|---|
| Persistence | [`drift`](https://drift.simonbinder.eu/) over SQLite | Type-safe schema, versioned migrations, and reactive streams — the UI updates automatically on writes, no manual `setState` plumbing. |
| IDs | UUIDs, not autoincrement | A local autoincrement ID becomes a liability the moment data needs to sync across devices or users — paying that cost upfront avoids a data migration later. |
| State management | [`Riverpod`](https://riverpod.dev/) | Plays well with `drift`'s async streams and doesn't depend on `BuildContext` to read state. |
| Layering | `domain` / `data` / `presentation` | `domain` defines repository contracts, `data` implements them with `drift`, `presentation` consumes them through providers. No use-case-per-action ceremony — that would be over-engineering for a handful of entities. |
| Navigation | Plain `Navigator.push` | Five screens don't justify a routing package; would be revisited if the app grows enough to need deep-linking. |

### Data model

```
restaurantes      id (PK), nombre, ubicacion, visitas, notas, createdAt, updatedAt
tags              id (PK), nombre (unique)
restaurante_tags  restauranteId + tagId (composite PK, join table)
platos            id (PK), restauranteId (FK), tipo, nombre, puntuacion, comentario, createdAt
recordatorios     id (PK), restauranteId (FK), texto, hecho
categorias        id (PK), restauranteId (FK), nombre, orden
```

### Project structure

```
lib/
  core/           shared utilities (id generation, theme)
  domain/         repository interfaces, enums, view models
  data/           drift schema + repository implementations
  presentation/   Riverpod providers, screens, widgets
tool/             one-off scripts (Obsidian vault importer)
test/             repository and widget tests
```

## Getting started

Requires the Flutter SDK (Dart `^3.10`).

```bash
flutter pub get
dart run build_runner build --force-jit
flutter run
```

> `--force-jit` is required here: `sqlite3`'s native build hooks aren't
> compatible with `build_runner`'s default AOT compilation mode.

## Testing

```bash
flutter test
```

## Importing your own data (optional)

The app starts empty and never adds data on its own — use the "Importar
datos" action (top-right menu on the home screen) to load a JSON backup, your
own or someone else's.

If you keep restaurant notes in an Obsidian vault with the frontmatter shape
this project expects, `tool/import_obsidian.dart` converts them into that same
JSON shape:

```bash
dart run tool/import_obsidian.dart "path/to/your/vault"
```

## Roadmap

- [ ] Dish photos
- [ ] Shared backend (Supabase or similar) so multiple people can see/edit the
      same reviews — the domain/data split and UUIDs are already there to
      make this a non-rewrite
- [ ] Map view / location autocomplete

## License

All rights reserved — see [LICENSE](LICENSE). This repository is shared
publicly for portfolio purposes; it isn't open source.
