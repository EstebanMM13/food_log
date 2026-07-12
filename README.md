<p align="center">
  <img src="assets/branding/icon.png" width="112" alt="FoodLog icon" />
</p>

<h1 align="center">FoodLog</h1>

<p align="center">
  A local-first Flutter app for tracking restaurants, dishes and ratings — the restaurant notebook you'd otherwise keep scattered across notes apps, turned into something that actually queries and aggregates your data.
</p>

---

## Why

I used to keep a note per restaurant in Obsidian — what I ordered, a score, a
reminder for next time — with a Dataview dashboard on top for stats. It
worked, but it wasn't built for the job: no structured queries, no shared
access, and any pattern across restaurants (best-rated dish type, most-visited
places, tags I keep gravitating to) had to be eyeballed by hand.

FoodLog is that habit rebuilt as a proper app: same data, real relational
storage, and a stats screen that answers the questions the notes never could.

## Features

- **Restaurant list** with search by name, location or tag.
- **Restaurant detail**: info, dish list, free-text notes, "order next time"
  reminders you can check off, one-tap visit counter.
- **Add/edit restaurant** with tags as editable chips.
- **Add/edit dish** with type, name and score.
- **Global statistics**: overall average, most-visited places, top-rated
  places, most-repeated dishes, restaurants by location, most-used tags.
- **One-time Obsidian import**: a companion script parses an existing
  Obsidian vault of restaurant notes and seeds the database with it.

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
platos            id (PK), restauranteId (FK), tipo, nombre, puntuacion, createdAt
recordatorios     id (PK), restauranteId (FK), texto, hecho
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
dart run build_runner build --delete-conflicting-outputs
flutter run
```

## Testing

```bash
flutter test
```

## Importing your own data (optional)

If you keep restaurant notes in an Obsidian vault with the frontmatter shape
this project expects, `tool/import_obsidian.dart` converts them into the seed
JSON the app loads on first launch:

```bash
dart run tool/import_obsidian.dart "path/to/your/vault"
```

## Roadmap

- [ ] Manual JSON export/import (a cheap stand-in for "share with a friend"
      before there's a backend)
- [ ] Dish photos
- [ ] Shared backend (Supabase or similar) so multiple people can see/edit the
      same reviews — the domain/data split and UUIDs are already there to
      make this a non-rewrite
- [ ] Map view / location autocomplete
