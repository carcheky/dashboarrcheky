# Dashboard "Stack Widgets" — Plan Maestro

> **Plan, no código.** No se toca nada del proyecto hasta que este documento
> esté aprobado. Tras aprobación, cada feature se ejecuta con
> `spec-driven-feature` (1 spec `docs/specs/<slug>/` por widget, branch
> `feature/<slug>`, sub-agente `feature-builder`).

## Goal

Añadir **tres widgets nuevos al Dashboard** de dashboarrcheky para que el
usuario vea de un vistazo qué requiere su atención en Sonarr y Radarr sin
tener que abrir cada servicio en la web.

## Contexto y supuestos

- **Proyecto:** dashboarrcheky, fork Flutter/Dart de LunaSea. Branch actual:
  `beta`. Estado limpio. SDK Flutter >=3.27 <4.0.
- **Patrón Dashboard existente:** tiles por módulo en
  `lunasea/lib/modules/dashboard/routes/dashboard/widgets/`, alimentados por
  `lib/modules/dashboard/core/state.dart` (`DashboardState`,
  `ChangeNotifier`).
- **Ya existe:** vista de calendario en
  `routes/dashboard/pages/calendar.dart` + `widgets/calendar_view.dart`.
  **No** se duplica — queda fuera de scope.
- **Servicios en uso:** solo Sonarr y Radarr. Lidarr no instalado. Readarr no
  existe como módulo en este fork. Ambos quedan out of scope en esta tanda.
- **API ya disponible:** `lib/api/sonarr/` y `lib/api/radarr/` (Dio +
  Retrofit). Falta verificar que los endpoints necesarios estén ya mapeados
  (ver § "Verificación previa al primer commit" abajo).
- **Localización:** `localization/dashboard/en.json`. Nuevas claves i18n se
  añaden ahí.

## Forma de organizar el trabajo (decidido)

- **Specs en repo:** 1 carpeta `docs/specs/<slug>/{requirements,design,tasks}.md`
  por widget. Tres commits, branch `feature/<slug>`. Skill:
  `.agents/skills/spec-driven-feature/SKILL.md`.
- **Roadmap:** las tres filas nuevas se añaden a `docs/roadmap.md` sección
  "Next — medium horizon", enlazando a `docs/features/<slug>.md`.
- **Kanban externo:** GitHub Projects, columnas = `proposed / in-progress /
  review / shipped`. Los ítems del Project se crean desde
  `docs/features/<slug>.md`. Sincronización manual (no bidireccional). Setup
  en § "GitHub Projects setup".

## Las tres features (orden de ejecución recomendado)

| # | Slug | Widget | Esfuerzo | Depende de |
|---|------|--------|----------|------------|
| 1 | `add-pending-imports-tile` | Descargas pendientes de import manual (Sonarr+Radarr) con botón "Importar ahora" (selector Move/Copy-Hardlink, **Copy-Hardlink preseleccionado**) + "Abrir en web" | M | — |
| 2 | `add-disk-space-tile` | Espacio libre en ruta destino de Sonarr y Radarr (alerta si <10%) | S | — |
| 3 | `add-stack-health-tile` | Semáforo verde/amarillo/rojo por servicio activo (Sonarr+Radarr), basado en `/system/status` | S | — |

**Por qué este orden:** A es la feature más valiosa (ataque directo al
problema del enunciado) y la más compleja (modal de manualImport). B y C son
rápidas y se pueden meter entre medias. B y C son **independientes entre sí**
y se pueden paralelizar en branches distintos si se quiere.

---

## Feature 1 — `add-pending-imports-tile`

### Goal

Tile en el Dashboard que muestra, agregadas por servicio, las descargas de
Sonarr y Radarr en estado `completed / warning / failed / delay`. Cada fila
tiene dos acciones:

- **Importar ahora** — modal nativo con `POST /api/v3/command` (Sonarr) /
  `POST /api/v3/manualimport` (Radarr). El modal lista las carpetas
  detectadas por el servicio en la ruta de descarga del item; el usuario
  elige una; el modal muestra un selector de **modo de import** con dos
  opciones (`Move` / `Copy-Hardlink`), **Copy-Hardlink preseleccionado por
  defecto** (el usuario quiere siempre hardlink). Copy-Hardlink hace
  hardlink real si el setting `copyUsingHardlinks` está ON en el *arr
  (Media Management); copia real si está OFF. Move mueve el archivo y
  rompe el seeding del torrent/usenet.
- **Abrir en web** — deep-link a la web UI de Sonarr/Radarr en
  `/activity/queue` (no hay URL estable por item individual, verificado).

**Verificado:**
- `importMode` en la API de Sonarr/Radarr acepta `move` o `copy`
  (string). `Auto` existe en algunas versiones pero el usuario no lo
  quiere — fuera del selector.
- No hay setting configurable por defecto en el *arr (Sonarr issue #8510
  cerrado como not_planned) — irrelevante: nuestro tile siempre pasa
  `importMode` en el body.
- El UI oficial de *arr Manual Import muestra las mismas 2 opciones
  ("Move" / "Copy/Hardlink").
- Hardlink NO es un valor separado — depende del setting global
  `copyUsingHardlinks` (Media Management) del *arr.

### Archivos a tocar

| Path | Estado actual | Cambio | Por qué |
|------|---------------|--------|---------|
| `lunasea/lib/api/sonarr/controllers/queue.dart` | ✅ existe | nada | `SonarrControllerQueue.get()` ya mapeado |
| `lunasea/lib/api/sonarr/models/queue/queue_record.dart` | ✅ existe | nada | campo `status` ya es enum `SonarrQueueStatus` con `COMPLETED/WARNING/FAILED/DELAY` |
| `lunasea/lib/api/sonarr/types/queue_status_type.dart` | ✅ existe | nada | enum completo |
| `lunasea/lib/api/radarr/commands/queue.dart` | ✅ existe | nada | `RadarrCommandHandlerQueue.get()` ya mapeado |
| `lunasea/lib/api/radarr/models/queue/queue_record.dart` | ✅ existe | nada | idem Sonarr |
| `lunasea/lib/api/radarr/types/queue_record_status.dart` | ✅ existe | nada | idem |
| `lunasea/lib/api/sonarr/controllers/system.dart` + `get_status.dart` | ✅ existe | nada | `SonarrStatus` ya tiene `version` |
| `lunasea/lib/api/radarr/commands/system.dart` + `get_status.dart` | ✅ existe | nada | `RadarrSystemStatus` ya tiene `version` |
| `lunasea/lib/api/radarr/models/manual_import/*.dart` (5 archivos) | ✅ existe | nada | `RadarrManualImport`, `RadarrManualImportFile`, `RadarrManualImportUpdate`, `RadarrManualImportUpdateData`, `RadarrManualImportRejection` |
| `lunasea/lib/api/radarr/types/import_mode.dart` | ✅ existe | nada | `RadarrImportMode` con `COPY, MOVE` |
| `lunasea/lib/api/radarr/commands/command.dart` + `command/manual_import.dart` | ✅ existe | nada | `RadarrCommandHandlerCommand.manualImport(files, importMode)` ya mapeado |
| `lunasea/lib/api/radarr/commands/manual_import.dart` + `get_manual_import.dart` | ✅ existe | nada | `RadarrCommandHandlerManualImport.get(folder)` ya mapeado |
| `lunasea/lib/api/sonarr/models/manual_import/*.dart` (5 archivos nuevos) | ❌ falta | **crear** | paralelo a Radarr |
| `lunasea/lib/api/sonarr/types/import_mode.dart` | ❌ falta | **crear** | paralelo a `RadarrImportMode` |
| `lunasea/lib/api/sonarr/controllers/command/manual_import.dart` | ❌ falta | **crear** | paralelo a `RadarrCommandHandlerCommand.manualImport` |
| `lunasea/lib/api/sonarr/controllers/manual_import.dart` | ❌ falta | **crear** | paralelo a `RadarrCommandHandlerManualImport.get` |
| `lunasea/lib/api/sonarr/controllers/command.dart` | existe, sin `manualImport` | añadir método | wiring del nuevo handler |
| `lunasea/lib/api/sonarr/controllers/manual_import_controller.dart` | ❌ falta | **crear** | fachada del controller |
| `lunasea/lib/modules/dashboard/core/state.dart` | existe | añadir `pendingImports` cache + `refreshPendingImports()` | estado compartido |
| `lunasea/lib/modules/dashboard/routes/dashboard/widgets/tile_pending_imports.dart` | ❌ falta | **crear** | el tile |
| `lunasea/lib/modules/dashboard/routes/dashboard/widgets/pending_import_row.dart` | ❌ falta | **crear** | fila por item |
| `lunasea/lib/modules/dashboard/routes/dashboard/widgets/pending_import_modal.dart` | ❌ falta | **crear** | modal de manualImport con selector Move/Copy-Hardlink |
| `lunasea/lib/router/routes/dashboard.dart` | existe | registrar ruta si el modal abre pantalla completa | opcional |
| `localization/dashboard/en.json` | existe | añadir claves | i18n |
| `docs/specs/add-pending-imports-tile/{requirements,design,tasks}.md` | ❌ falta | **crear** | spec |
| `docs/features/add-pending-imports-tile.md` | ❌ falta | **crear** | doc del feature |
| `docs/roadmap.md` | existe | añadir fila en "Next" | visibilidad |

### Verificación previa — RESULTADO

1. **`GET /api/v3/queue` (Sonarr+Radarr):** ✅ ya mapeado en ambos.
2. **Modelo `QueueRecord` con `status`:** ✅ ya es enum en ambos, incluye los 4 status que filtramos.
3. **`POST /api/v3/manualImport`:** ⚠️ Radarr ✅, Sonarr ❌ (hay que crearlo).
4. **`GET /api/v3/manualimport` (listado):** ⚠️ Radarr ✅, Sonarr ❌.
5. **`importMode`:** ✅ ambos soportan `move` / `copy`. Hardlink NO es una opción separada — es automático si `copyUsingHardlinks` está ON. **Decidido: el selector del modal será "Move / Copy-Hardlink", Copy-Hardlink preseleccionado.**
6. **Deep-link:** ⚠️ `/activity/queue` es lo más fiable. No hay URL estable por item. **Decidido: el botón "Abrir en web" apunta a `/activity/queue`.**
7. **Permisos Android:** sin cambios.

### Tareas (resumen; el spec `tasks.md` las expande a pasos de 2-5 min)

1. Spec `requirements.md` con criterios de aceptación Given/When/Then.
2. Spec `design.md` con la tabla de archivos arriba y el modelo de datos.
3. Spec `tasks.md` con tareas TDD por archivo.
4. Verificación previa (§ arriba) → commit `chore(spec): verify endpoints`.
5. Crear/ajustar modelos Retrofit → `npm run generate` → commit.
6. Crear `DashboardState.pendingImports` + `refreshPendingImports()` → tests.
7. Crear `tile_pending_imports.dart` con RefreshIndicator + ListView → tests
   de widget con `flutter_test`.
8. Crear `pending_import_row.dart` con los dos botones.
9. Crear `pending_import_modal.dart` con selector de importMode (hardlink
   preseleccionado).
10. Conectar todo en `state.dart`.
11. Localización (claves i18n en `en.json`).
12. `dart analyze lib/` limpio en Docker.
13. Build APK debug → `adb install` → smoke test en Pixel 9.
14. Commit final con footer `Docs: docs/specs/add-pending-imports-tile/design.md`
    y `Docs: docs/features/add-pending-imports-tile.md`.
15. Abrir PR contra `beta`. Marcar la fila en `roadmap.md` como `[x]` y en
    GitHub Projects como `shipped`.

### Riesgos

| Riesgo | Mitigación |
|--------|------------|
| `manualImport` no acepta `importMode` en la versión del usuario | fallback: omitir selector, dejar que el servicio use su default; documentar en `design.md` |
| Muchos items (50+) en la queue degradan rendimiento del tile | paginación server-side (`pageSize=20` por servicio); mostrar "ver más" |
| El usuario presiona "Importar" dos veces por error | botón pasa a `loading` y se deshabilita durante la petición; idempotency vía `commandId` si la API lo soporta |

---

## Feature 2 — `add-disk-space-tile`

### Goal

Tile en el Dashboard que muestra, por servicio activo (Sonarr/Radarr),
cuánto espacio libre queda en el disco donde está la ruta destino del
servicio. Alerta visual si queda <10% (icono naranja) o <5% (icono rojo).

### Archivos a tocar

| Path | Cambio | Por qué |
|------|--------|---------|
| `lunasea/lib/api/sonarr/sonarr_api.dart` | añadir `@GET('/api/v3/diskspace')` si falta | endpoint |
| `lunasea/lib/api/radarr/radarr_api.dart` | idem | idem |
| `lunasea/lib/api/.../models/disk_space.g.dart` | crear | modelo |
| `lunasea/lib/modules/dashboard/core/state.dart` | añadir `diskSpace` cache + `refreshDiskSpace()` | estado |
| `lunasea/lib/modules/dashboard/routes/dashboard/widgets/tile_disk_space.dart` | nuevo | el tile |
| `localization/dashboard/en.json` | nuevas claves | i18n |
| `docs/specs/add-disk-space-tile/*` | 3 archivos | spec |
| `docs/features/add-disk-space-tile.md` | nuevo | doc |
| `docs/roadmap.md` | nueva fila | visibilidad |

### Verificación previa

1. ¿`/api/v3/diskspace` ya está mapeado? Si no, añadir y re-generar.
2. El endpoint devuelve array de `{path, total, free, used}`. Hay que
   quedarse con el `free` de la ruta que coincide con `rootFolder` por
   defecto del servicio. **Decisión:** usar la primera ruta con más espacio
   libre (es la que más probablemente está montada como destino). Documentar
   en `design.md`.

### Tareas

1-15 análogas a Feature 1, pero más cortas (no hay modal, no hay deep-link,
es solo mostrar un número y un color).

### Riesgos

| Riesgo | Mitigación |
|--------|------------|
| Servicio configurado con varias `rootFolder` (ej. series vs anime) | mostrar todas en una lista plegable; default = la de más espacio |
| Disco NFS/CIFS reporta valores raros | redondear a GB y usar `free/total` ratio, no el valor absoluto |

---

## Feature 3 — `add-stack-health-tile`

### Goal

Tile en el Dashboard con un semáforo por servicio activo (Sonarr, Radarr):
- **Verde:** API responde 200 a `/api/v3/system/status` y `version` es
  reciente.
- **Amarillo:** API responde pero `version` es antigua (más de 6 meses del
  cutoff actual) — sin bloquear al usuario.
- **Rojo:** API no responde (timeout 5s, error 5xx, API key inválida).

### Archivos a tocar

| Path | Cambio | Por qué |
|------|--------|---------|
| `lunasea/lib/api/sonarr/sonarr_api.dart` | añadir `@GET('/api/v3/system/status')` si falta | endpoint |
| `lunasea/lib/api/radarr/radarr_api.dart` | idem | idem |
| `lunasea/lib/api/.../models/system_status.g.dart` | crear | modelo |
| `lunasea/lib/modules/dashboard/core/state.dart` | añadir `stackHealth` cache + `refreshStackHealth()` | estado |
| `lunasea/lib/modules/dashboard/routes/dashboard/widgets/tile_stack_health.dart` | nuevo | el tile |
| `localization/dashboard/en.json` | nuevas claves | i18n |
| `docs/specs/add-stack-health-tile/*` | 3 archivos | spec |
| `docs/features/add-stack-health-tile.md` | nuevo | doc |
| `docs/roadmap.md` | nueva fila | visibilidad |

### Verificación previa

1. ¿`/api/v3/system/status` ya está mapeado? Si no, añadir y re-generar.
2. `version` viene como string tipo `"4.0.3.929"`. Hay que parsear a
   `SemVer`. Verificar si LunaSea ya tiene `package:semver` o equivalente
   en `pubspec.yaml`. Si no, añadir `semver: ^2.1.0` (decisión ya tomada
   en `docs/conventions.md` al añadir dependencias).
3. Cutoff de "versión antigua": 6 meses es arbitrario. **Pregunta abierta
   P3:** ¿queremos un cutoff configurable por el usuario en settings, o
   hardcoded 6 meses? Recomendación: hardcoded para esta tanda, configurable
   en futura si lo pide el roadmap.

### Tareas

1-15 análogas a Feature 1, sin modal ni deep-link.

### Riesgos

| Riesgo | Mitigación |
|--------|------------|
| Servicio apagado causa timeout largo en el polling | timeout 5s por petición; mostrar rojo con texto "Sin respuesta" |
| API key inválida reporta 401, no queremos confundirlo con "apagado" | distinguir: 401 → rojo con texto "API key inválida — revisa Settings" |

---

## Refresco de datos (común a las 3 features)

- **Timer:** 60s mientras el Dashboard está visible (foreground + pantalla
  activa). Pausa cuando la app pasa a background o el usuario navega a otra
  pestaña del Dashboard.
- **Pull-to-refresh:** manual, anula el timer momentáneamente.
- **Implementación:** en `DashboardState`, un `Timer.periodic` que se
  cancela en `dispose()` y se reactiva en `initState()` de la página
  Dashboard. Usar `WidgetsBindingObserver` para detectar `AppLifecycleState`.

---

## GitHub Projects setup

Setup único antes de empezar el primer feature:

1. Crear Project en `jagandeepbrar/lunasea` (o el fork correspondiente a
   dashboarrcheky) llamado **"Stack Widgets"**. Visibilidad: público.
2. Columnas: `Backlog`, `In progress`, `Review`, `Shipped`.
3. Custom field **Status** = enum `proposed / in-progress / shipped` (espejo
   del `Status:` header en `docs/features/<slug>.md`).
4. Issues/tareas iniciales (uno por feature):
   - `[Feature] add-pending-imports-tile`
   - `[Feature] add-disk-space-tile`
   - `[Feature] add-stack-health-tile`
5. Cada issue enlaza a `docs/features/<slug>.md` en el cuerpo.
6. Cuando `feature-builder` abre un PR, mueve el issue a `In progress`. Al
   mergear, a `Shipped`.

> **Nota:** no se automatiza la sincronización. Es manual, como dice la
> convención del proyecto (ADR-0005).

---

## Cambios en `docs/roadmap.md`

Añadir tres filas en la sección **"Next — medium horizon"** (después de la
fila 7 actual, antes de "Later"):

| # | Item | Effort | Depends on | Spec |
|---|------|--------|------------|------|
| 8 | **Pending imports tile** — Dashboard tile que lista descargas en estado `completed/warning/failed/delay` de Sonarr y Radarr con acciones "Importar ahora" (modal `manualImport`, selector Move/Copy-Hardlink con Copy-Hardlink preseleccionado — el usuario quiere hardlink por defecto) y "Abrir en web" (`/activity/queue`). | M | — | `docs/features/add-pending-imports-tile.md` (proposed) |
| 9 | **Disk space tile** — espacio libre en ruta destino de cada *arr activo, alerta visual si <10%. | S | — | `docs/features/add-disk-space-tile.md` (proposed) |
| 10 | **Stack health tile** — semáforo por servicio (verde/amarillo/rojo) basado en `/system/status` y versión. | S | — | `docs/features/add-stack-health-tile.md` (proposed) |

Y una fila en **"Later"**:

| # | Item | Effort | Depends on | Spec |
|---|------|--------|------------|------|
| 11 | **Push notification cuando un download entra en `warning`** — requiere Firebase Messaging + permisos Android 13+ (POST_NOTIFICATIONS). | M | 8 | (proposed — spec tras mergear 8) |

Lidarr queda como **Later** también, fila nueva:

| 12 | Mismas tres features para Lidarr (importaciones pendientes, disco, salud) | M | 8, 9, 10 | — |

---

## Cambios en `docs/timeline.md`

Cuando cada feature se mergee, añadir fila nueva en la sección
correspondiente con el slug y la versión (siguiente semver después del
último merge).

---

## Cambios en `docs/index.md` y `docs/modules/dashboard.md`

- `docs/modules/dashboard.md`: añadir los tres nuevos tiles a la lista de
  "Key files" (`tile_pending_imports.dart`, `tile_disk_space.dart`,
  `tile_stack_health.dart`) y actualizar "Adding a tile" si el patrón
  cambia.
- `docs/index.md`: si menciona los tiles actuales, añadir los nuevos.

---

## Preguntas abiertas

- **P1. ~~¿`POST /api/v3/manualImport` acepta `importMode`?~~** RESUELTA.
  Ambos servicios (Sonarr v3+ y Radarr v3+) aceptan `importMode: 'move' |
  'copy'`. Hardlink NO es valor válido — es automático vía
  `copyUsingHardlinks` en Media Management del *arr. El tile ofrece 2
  opciones (Move / Copy-Hardlink), Copy-Hardlink preseleccionado.
- **P2. ~~Deep-link estable por item.~~** RESUELTA. No existe. El botón
  "Abrir en web" apunta a `/activity/queue`.
- **P3.** Cutoff de "versión antigua" en el tile de salud — ¿6 meses
  hardcoded o configurable? **Recomendación:** hardcoded 6 meses para
  esta tanda; configurable es su propio feature futuro si el roadmap lo
  pide.
- **P4.** ¿Los 3 timers de 60s independientes (uno por feature) o un único
  timer en `DashboardState` que refresca las 3 caches a la vez? **Recom
  endación:** timer único en `DashboardState` que itera sobre las 3 caches;
  menos timers, menos `setState`, mejor para batería. **Decidir al ejecutar
  feature A** (la primera), las otras dos reutilizan.
- **P5.** Pendiente verificar `pubspec.yaml` para `package:semver` (necesario
  para parsear `SonarrStatus.version` y `RadarrSystemStatus.version` en el
  tile de salud). Si no está, añadir como dependencia.

---

## Done when (este plan está "shipped" cuando)

- [ ] Las 3 features están mergeadas a `beta`.
- [ ] Cada feature tiene su spec de 3 archivos en `docs/specs/<slug>/`.
- [ ] Cada feature tiene su `docs/features/<slug>.md` con estado `shipped`.
- [ ] `docs/roadmap.md` tiene las 3 filas con `[x]`.
- [ ] `docs/timeline.md` tiene 3 filas nuevas con la versión.
- [ ] `docs/modules/dashboard.md` lista los 3 nuevos tiles.
- [ ] GitHub Project "Stack Widgets" tiene los 3 issues en `Shipped`.
- [ ] APK debug instalado en Pixel 9, los 3 tiles visibles y funcionales.
- [ ] `dart analyze lib/` limpio en Docker tras cada merge.

## Out of scope (explícito)

- Lidarr (no instalado).
- Readarr (módulo no existe).
- Push notifications de warning (futuro, fila 11 del roadmap).
- Notificación cuando el disco entra en rojo (futuro).
- Vista unificada "Estado del stack" como pantalla completa (futuro si lo
  pide el roadmap).
- Selector de importMode configurable globalmente (cada modal de cada fila
  lo elige — el default sigue siendo hardlink).

## Ver también

- `.agents/skills/spec-driven-feature/SKILL.md` — workflow de cada feature.
- `.agents/skills/plan/SKILL.md` — este documento.
- `docs/architecture.md` — capas del proyecto.
- `docs/modules/dashboard.md` — patrón actual de tiles.
- `docs/modules/sonarr.md` / `docs/modules/radarr.md` — APIs y state.
- `docs/api/http.md` — Dio + Retrofit.
- `docs/api/hive.md` — si alguna feature necesita persistencia (probablemente
  ninguna en esta tanda, pero verificar al ejecutar).
- `docs/roadmap.md` — punto de partida.
- `docs/workflow.md` — branching y releases.
