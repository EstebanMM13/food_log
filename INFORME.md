# Informe del proyecto — Food Log

_Última actualización: 2026-07-13_

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

Desde la última revisión de este informe, el proyecto pasó de prototipo
sin commitear a un repo con 36 commits, licencia, CI y un release con APK
descargable — y de un MVP funcional a una app con identidad visual propia
("Cuaderno": paleta parchment/terracota/sepia) y varias mejoras de UX
pedidas tras usarla en el móvil real.

## 2. Arquitectura y decisiones técnicas

| Decisión | Elegido | Por qué |
|---|---|---|
| Persistencia | `drift` sobre SQLite | El prototipo inicial usaba `sqflite` con SQL crudo y mapeo manual fila↔objeto (sin migraciones versionadas). Con solo 6 tablas, `drift` da esquema type-safe, migraciones y **streams reactivos** — la lista se actualiza sola al insertar un plato, sin `setState` disperso. |
| IDs | `UUID` (String), no autoincremental | Consecuencia directa de la fase 2 (compartir/backend): un ID autoincremental local choca en cuanto sincronizas entre dispositivos o usuarios. Se paga el coste ahora para no migrar datos después. |
| Estado | `Riverpod` | Reemplazo estándar de `Provider` en el ecosistema Flutter actual; se lleva bien con streams async de `drift` y no depende de `BuildContext` para leer estado. |
| Capas | `domain` / `data` / `presentation`, pragmático | `domain` define contratos (interfaces de repositorio), `data` los implementa con drift, `presentation` consume vía providers. Sin un caso de uso por cada acción — sería sobre-ingeniería para pocas entidades. Las entidades de dominio son directamente las clases que genera `drift` (sin mapper manual duplicado). |
| Navegación | `Navigator.push` simple | Las pantallas actuales no justifican `go_router`; se añadirá si la app crece a un punto donde deep-linking o rutas nombradas aporten valor real. |
| Categorías de plato | Enum fijo (`Entrante/Principal/Postre/Otro`) + tabla `categorias` por restaurante | Se retiró `TipoPlato.cafe` del enum: en la práctica un restaurante puede necesitar secciones propias ("Bebidas", "Tapas") que no encajan en un enum cerrado. Se añadió `categorias` como tabla de categorías personalizadas por restaurante, mientras `platos.tipo` sigue siendo texto libre para no romper datos importados. |
| Tema | Claro/oscuro siguiendo el sistema, con toggle manual persistido | Añadido después del MVP inicial; el toggle manual se guarda para no depender solo de la preferencia del SO. |

### Esquema de base de datos

```
restaurantes      id (PK), nombre, ubicacion, visitas, notas, createdAt, updatedAt
tags              id (PK), nombre (único)
restaurante_tags  restauranteId + tagId (join, PK compuesta)
categorias        id (PK), restauranteId (FK), nombre, orden
platos            id (PK), restauranteId (FK), tipo, nombre, puntuacion, comentario, createdAt
recordatorios     id (PK), restauranteId (FK), texto, hecho
```

`tipo` de plato sigue siendo texto libre en la base de datos (no hay un
`CHECK` cerrado): en Dart existe un `enum TipoPlato` (Entrante/Principal/
Postre/Otro) para el desplegable del formulario, con fallback a `Otro`
para cualquier valor no reconocido — así un valor importado nunca rompe
una fila. `categorias` es la capa nueva encima de eso: permite que un
restaurante tenga secciones propias más allá de las fijas.

`recordatorios` ahora también se puede borrar directamente (antes solo se
marcaban como hechos), y `platos.comentario` permite anotar texto libre
por plato (ya existía en el informe anterior).

## 3. Qué se hizo en esta sesión (histórico completo hasta el commit d260f3c)

El proyecto ya existía como un prototipo de aprendizaje (`flutter create` +
`sqflite` con SQL crudo). Se reescribió por completo con la arquitectura de
la sección anterior, y a partir de ahí se hizo el primer commit y se siguió
iterando. Resumen por bloques:

**Reescritura inicial y primer commit** (`33fd1e3`…`340b17c`): capas
domain/data/presentation, drift, providers de Riverpod, 5 pantallas,
importador del vault de Obsidian, tests unitarios y de widget.

**Documentación y CI** (`f5a35ab`, `7f4b219`, `8d12f05`): README con
arquitectura y setup, workflow de GitHub Actions para `flutter analyze` +
`flutter test`.

**Funcionalidades nuevas:**
- `9ff2d0a` — exportar/importar JSON completo (el pendiente que quedaba
  del MVP original, ya resuelto).
- `012d4a1`, `f92eeb1` — tema oscuro siguiendo el sistema, luego toggle
  manual claro/oscuro con persistencia.
- `6b2c871` — se dejó de auto-sembrar la base de datos en el primer
  arranque (sustituido más adelante por el diálogo de bienvenida).
- `22b1143`, `ed4fc0f` — categorías de plato personalizables por
  restaurante (tabla `categorias`), retirando `TipoPlato.cafe` del enum.
- `096c2dd` — edición rápida de notas del restaurante in-place.
- `97f0e49` — se impide crear restaurantes con nombre duplicado; borrar un
  plato se fusionó en su menú de edición.
- `bc7b57e`, `05bc8a6`, `bfaf5ea` — diálogo de bienvenida en el primer
  arranque con datos de ejemplo opcionales (evita duplicar restaurantes de
  muestra; corrige un deadlock basado en streams).
- `261e7f0`, `b2d99cc`, `2ab42d6` — splash screen propio con el nombre de
  la app bajo el logo, legible también en modo oscuro.
- `9d6b547` — rebrand visual "Cuaderno": paleta parchment/terracota/sepia.
- `074c074`, `6182201` — contraste del tema mejorado, color de puntuación
  (`rating`) de marca en vez de `Colors.amber` fijo.
- `d4f6582` — se omite el campo "especifica el tipo" al añadir un plato
  directamente en "Otros".

**Pulido y correcciones menores** (`c03690a`, `07edcbf`, `7264e21`,
`811817b`, `9bb418a`): espaciado en las tarjetas de inicio, truncado de
nombres de plato largos, nombre completo del restaurante visible en el
detalle, uso consistente de "Food Log" (con espacio), limpieza de widgets
sin uso (`PlatoTile`, `RatingBadge`), silenciado de un error ruidoso de
caché incremental de Kotlin en Windows.

**Legal y release** (`7da7642`, `95a6752`, `d260f3c`): licencia "todos los
derechos reservados", enlace al último release con APK descargable desde
el README, capturas de pantalla añadidas al README.

### Funcionalidades actuales

1. ✅ Listado de restaurantes con buscador (nombre/ubicación/tags).
2. ✅ Detalle: datos básicos, platos por categoría (fijas + personalizadas),
   notas editables in-place, recordatorios marcables y borrables, botón
   para registrar una visita.
3. ✅ Alta/edición de restaurante (con tags como chips editables,
   protección contra nombres duplicados).
4. ✅ Alta/edición de plato (tipo/categoría, nombre, puntuación, comentario).
5. ✅ Estadísticas globales: media general, más visitados, mejor
   valorados, platos más repetidos, restaurantes por ubicación, tags más
   usados.
6. ✅ Exportar/importar todos los datos a JSON.
7. ✅ Tema claro/oscuro, siguiendo el sistema o con toggle manual persistido.
8. ✅ Diálogo de bienvenida en el primer arranque, con opción de cargar
   datos de ejemplo.

## 4. Bugs encontrados y corregidos

Además de los dos ya documentados en la primera versión de este informe
(timer pendiente en el test de widget; `sqlite3_flutter_libs` en versión
stub que rompía toda operación de base de datos), durante esta fase se
corrigieron:

- Un deadlock basado en streams al cargar datos de ejemplo desde el
  diálogo de bienvenida, y restaurantes de muestra duplicados si se
  invocaba más de una vez (`05bc8a6`).
- El splash screen no era legible en modo oscuro (`2ab42d6`).
- El campo "especifica el tipo" aparecía también al añadir un plato ya
  dentro de la categoría "Otros", siendo redundante (`d4f6582`).
- Un error ruidoso (no bloqueante) de caché incremental de Kotlin en
  compilaciones desde Windows (`811817b`).

## 5. Estado actual

- Repo con 36 commits, working tree limpio — todo está commiteado.
- `flutter analyze` y `flutter test` corren en CI (GitHub Actions) en cada
  push.
- Licencia "todos los derechos reservados" añadida.
- Hay un release publicado con APK descargable, enlazado desde el README,
  con capturas de pantalla de la app.
- Versión actual: `1.0.0+1`.

## 6. Mejoras futuras

En orden aproximado de cuándo tendría sentido abordarlas:

- **Fotos de platos**: `image_picker` + guardar la ruta local del archivo
  junto al plato.
- **Backend compartido** (Supabase o similar): permite que varias personas
  vean/editen las mismas reseñas. Los UUID y la separación domain/data ya
  están pensados para que este cambio no obligue a reescribir la UI.
- **Geolocalización / mapa**: mostrar los restaurantes en un mapa, o
  autocompletar la ubicación al dar de alta uno nuevo.
- **Migrar a `sqlite3` v3**: la versión de `sqlite3_flutter_libs` en uso
  avisa en su propio README que solo se mantiene "hasta principios de
  2026" — en algún momento conviene migrar a `sqlite3` v3 y su sistema de
  native assets (requiere también actualizar `drift` a una versión que lo
  soporte).
- **`go_router`**: solo si la app crece más allá de las pantallas actuales
  y hace falta deep-linking o rutas con nombre.
