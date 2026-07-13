# Informe del proyecto — Food Log

_Última actualización: 2026-07-05_

## 1. De qué va este proyecto

Food Log nace de un hábito que ya llevabas tiempo practicando en Obsidian
(`D:\OBSIDIAN\Personal\Comida`): cada vez que ibas a un bar o restaurante,
apuntabas una nota con lo que pedías y una puntuación, para saber qué
merece la pena la próxima vez (o para que un conocido lo consulte antes de
ir). Ese vault ya tenía 9 restaurantes reales con sus platos, dashboards en
Dataview con estadísticas, buscador, etc.

La idea de este proyecto es llevar ese mismo hábito a una app Flutter
multiplataforma (móvil primero, pero corre igual en Windows/Linux/macOS),
en dos fases explícitas:

1. **Fase actual — 100% local.** La app funciona sola en tu móvil, sin
   backend ni cuentas. Sirve para "mira este bar, te enseño el móvil".
2. **Fase futura — opcional.** Si el uso diario confirma que la app te
   sustituye bien la nota de Obsidian, se puede añadir un backend
   (Supabase o similar) para que un conocido vea tus reseñas en vivo, sin
   reescribir el resto de la app.

Esa decisión de "local ahora, compartido después" es la que condicionó
varias decisiones técnicas de la fase 1, explicadas abajo.

## 2. Arquitectura y decisiones técnicas

| Decisión | Elegido | Por qué |
|---|---|---|
| Persistencia | `drift` sobre SQLite | El prototipo inicial usaba `sqflite` con SQL crudo y mapeo manual fila↔objeto (sin migraciones versionadas). Con solo 5 tablas, `drift` da esquema type-safe, migraciones y **streams reactivos** — la lista se actualiza sola al insertar un plato, sin `setState` disperso. |
| IDs | `UUID` (String), no autoincremental | Consecuencia directa de la fase 2 (compartir/backend): un ID autoincremental local choca en cuanto sincronizas entre dispositivos o usuarios. Se paga el coste ahora para no migrar datos después. |
| Estado | `Riverpod` | Reemplazo estándar de `Provider` en el ecosistema Flutter actual; se lleva bien con streams async de `drift` y no depende de `BuildContext` para leer estado. |
| Capas | `domain` / `data` / `presentation`, pragmático | `domain` define contratos (interfaces de repositorio), `data` los implementa con drift, `presentation` consume vía providers. Sin un caso de uso por cada acción — sería sobre-ingeniería para 2-3 entidades. Las entidades de dominio son directamente las clases que genera `drift` (sin mapper manual duplicado). |
| Navegación | `Navigator.push` simple | 5 pantallas no justifican `go_router`; se añadirá si la app crece a un punto donde deep-linking o rutas nombradas aporten valor real. |

### Esquema de base de datos

```
restaurantes      id (PK), nombre, ubicacion, visitas, notas, createdAt, updatedAt
tags              id (PK), nombre (único)
restaurante_tags  restauranteId + tagId (join, PK compuesta)
platos            id (PK), restauranteId (FK), tipo, nombre, puntuacion, createdAt
recordatorios     id (PK), restauranteId (FK), texto, hecho
```

`tipo` de plato es texto libre en la base de datos (no hay un `CHECK`
cerrado): en Dart existe un `enum TipoPlato` con los valores habituales
(Entrante/Principal/Postre/Café/Otro) para el desplegable del formulario,
pero un valor no reconocido nunca rompe una fila.

`recordatorios` es la única mejora real sobre lo que hacía Obsidian: ahí
"Próxima vez pedir" era una lista de texto suelta; aquí es una tabla propia
que se puede marcar como "ya lo pedí" en vez de borrar a mano.

## 3. Qué se hizo en esta sesión

El proyecto ya existía como un prototipo de aprendizaje
(`flutter create` + `sqflite` con SQL crudo, modelos mínimos sin tags ni
visitas, datos de ejemplo hardcodeados). Se reescribió por completo según
la arquitectura de la sección anterior.

**Eliminado:**
- `lib/db/base_datos.dart` (acceso SQL crudo con sqflite)
- `lib/models/restaurante.dart`, `lib/models/plato.dart` (modelos mínimos)
- `test/widget_test.dart` (test del contador de la plantilla de `flutter create`)

**Creado:**
- `lib/data/local/` — tablas de `drift` (`restaurantes`, `tags`,
  `restaurante_tags`, `platos`, `recordatorios`), `app_database.dart` y su
  código generado, `seed_loader.dart` (carga el JSON de Obsidian en el
  primer arranque si la base está vacía).
- `lib/data/repositories/` — implementación de los repositorios sobre `drift`.
- `lib/domain/` — interfaces de repositorio, `enum TipoPlato`, modelos de
  vista (`RestauranteResumen`, `Estadisticas`).
- `lib/presentation/` — providers de Riverpod, 5 pantallas
  (`home_screen`, `restaurante_detail_screen`, `restaurante_form_screen`,
  `plato_form_screen`, `estadisticas_screen`) y widgets reutilizables
  (`restaurante_card`, `plato_tile`, `rating_badge`).
- `tool/import_obsidian.dart` — script (`dart run tool/import_obsidian.dart`)
  que lee tus 9 notas reales de `D:\OBSIDIAN\Personal\Comida\Restaurantes`
  y genera `assets/seed_restaurantes.json`, que la app importa sola en el
  primer arranque.
- `test/data/restaurante_repository_test.dart` y
  `test/widget/home_screen_test.dart` — tests unitarios y de widget.

**Dependencias:** se quitó `sqflite`; se añadieron `drift`,
`sqlite3_flutter_libs`, `path`, `flutter_riverpod`, `uuid` (dependencias) y
`drift_dev`, `build_runner` (dev, para generar el código de `drift`).

### Funcionalidades del MVP

1. ✅ Listado de restaurantes con buscador (nombre/ubicación/tags).
2. ✅ Detalle: datos básicos, platos, notas, recordatorios marcables,
   botón para registrar una visita.
3. ✅ Alta/edición de restaurante (con tags como chips editables).
4. ✅ Alta/edición de plato (tipo, nombre, puntuación).
5. ✅ Estadísticas globales: media general, más visitados, mejor
   valorados, platos más repetidos, restaurantes por ubicación, tags más
   usados — replica el dashboard "Restaurantes General" que ya tenías en
   Obsidian.
6. ⏳ **Pendiente:** exportar/importar JSON manual (sustituto de
   "compartir con un conocido" mientras no haya backend). Estaba en el
   plan original pero no se llegó a construir en esta sesión — ver sección
   de mejoras futuras.

## 4. Bugs encontrados y corregidos durante la verificación

Dos bugs reales aparecieron al verificar el proyecto, ambos ya arreglados
y confirmados por ti en tu dispositivo:

1. **Timer pendiente en el test de widget.** `drift` programa un timer
   interno para cerrar el caché de una query reactiva justo al cancelarse
   el último listener. El test cerraba la base de datos con
   `addTearDown(db.close)`, que corre demasiado tarde — `flutter_test`
   verifica que no queden timers pendientes antes de ejecutar esos
   callbacks. Se cambió a `await db.close()` explícito al final del test.

2. **La app se quedaba cargando y luego lanzaba "Invalid argument(s)".**
   `pubspec.yaml` había fijado `sqlite3_flutter_libs: ^0.6.0+eol` — una
   versión que, según su propio README, "ya no hace nada" (es un stub de
   transición hacia `sqlite3` v3). Como `drift` sigue sobre `sqlite3` v2.x,
   la app no tenía librería nativa de SQLite disponible en tiempo de
   ejecución: por eso fallaba tanto la carga inicial como el alta de un
   restaurante nuevo (cualquier operación sobre la base de datos fallaba
   igual). Se fijó `sqlite3_flutter_libs: ^0.5.26` (resolvió a `0.5.42`,
   versión real con los `CMakeLists.txt` de bundling nativo). Tras el
   cambio hubo que regenerar el código de `drift` con
   `dart run build_runner build --force-jit`, porque el modo AOT por
   defecto de `build_runner` choca con los build hooks nativos que trae
   `sqlite3`.

## 5. Estado actual

- `flutter analyze`: sin warnings ni errores.
- `flutter test`: 5/5 en verde.
- Importador probado contra el vault real: `assets/seed_restaurantes.json`
  contiene los 9 restaurantes con sus platos.
- App confirmada funcionando en dispositivo real: carga los restaurantes
  y permite crear uno nuevo.
- **Nada está commiteado todavía** — los cambios siguen en el working
  tree, a la espera de que decidas cuándo hacer el commit.

## 6. Mejoras futuras

En orden aproximado de cuándo tendría sentido abordarlas:

- **Exportar/Importar JSON manual** (pendiente del MVP original): botón en
  la app para exportar todos los datos a un JSON y otro para importarlo —
  sustituto barato de "compartir con un conocido" mientras no haya backend.
- **Fotos de platos**: `image_picker` + guardar la ruta local del archivo
  junto al plato.
- **Backend compartido** (Supabase o similar): la fase 2 mencionada en la
  sección 1 — permite que varias personas vean/editen las mismas reseñas.
  Los UUID y la separación domain/data ya están pensados para que este
  cambio no obligue a reescribir la UI.
- **Geolocalización / mapa**: mostrar los restaurantes en un mapa, o
  autocompletar la ubicación al dar de alta uno nuevo.
- **Migrar a `sqlite3` v3**: la versión de `sqlite3_flutter_libs` usada
  ahora (`0.5.42`) avisa en su propio README que solo se mantiene "hasta
  principios de 2026" — en algún momento conviene migrar a `sqlite3` v3 y
  su sistema de native assets (requiere también actualizar `drift` a una
  versión que lo soporte).
- **`go_router`**: solo si la app crece más allá de las 5 pantallas
  actuales y hace falta deep-linking o rutas con nombre.
