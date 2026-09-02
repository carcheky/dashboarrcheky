# Plan — exhaustive code review of `dashboarrcheky` (lunasea/)

**Created:** 2026-09-02_204200
**Owner:** cmartinezv
**Branch:** `feature/add-pending-imports-tile`
**Scope:** código activo `lunasea/lib/` + tests + lint. **Excluido:**
`lunasea-cloud-functions/`, `lunasea-notification-service/`,
`lunasea-docs/`, otros top-level (marcados "no tocar" en AGENTS.md).

## Goal

Reporte exhaustivo de hallazgos en 6 dimensiones: arquitectura,
calidad, seguridad, performance, tests, i18n/UX. Cada task produce
**un finding concreto verificable** (path + comando + output
esperado), no prosa.

## Architecture

- Lectura por submódulo (no por archivo). Cada task enumera los
  archivos a leer, el patrón a buscar, y el comando de verificación.
- Tasks de **2-5 min de lectura** + **1 min de reporte**. Una task
  por archivo o por par de archivos relacionados.
- Findings se acumulan en **un único reporte** al final:
  `.hermes/plans/2026-09-02_204200-review-findings.md`
  (commit al terminar todas las tasks del track).

## Tech Stack

- `read_file` para archivos pequeños (<2k líneas).
- `terminal + grep/find/wc` para listados y conteos.
- `terminal + git diff` para verificar drift.
- `hermes -m deepseek-v4-pro --provider deepseek` para las 7 tasks
  marcadas **[Pro]** en Track A y las marcadas **[Pro]** en B, C, E, F.
- `hermes -m deepseek-v4-flash --provider deepseek` para la task
  **[Flash]** en Track B (bulk dependency audit).
- Resto: MiniMax-M3 (yo), default.

## Conventions

- **No editar código en esta review.** Reportar hallazgos, nada más.
- Cada finding es: `{path:line | severity | finding | suggested_fix}`.
- Severidad: `P0` (rompe build/seguridad), `P1` (drift/bug),
  `P2` (estilo/mejora), `P3` (cosmético).
- Si un finding requiere decisión arquitectónica grande (refactor,
  migración), no proponer el fix exacto; proponer el ADR que lo
  decidiría.

---

## Track A — Arquitectura & código activo (lunasea/lib/)

**Total:** 8 tasks · **6 M3, 2 Pro** · Coste estimado ~$0.06

### A1. Bootstrap, providers, recovery mode

- **Archivos:** `lunasea/lib/main.dart`, `lunasea/lib/core.dart`,
  `lunasea/lib/bootstrap.dart`, `lunasea/lib/system/recovery_mode/`,
  `lunasea/lib/modules.dart`, `lunasea/lib/vendor.dart`,
  `lunasea/lib/router/router.dart`
- **Buscar:** runZonedGuarded, MultiProvider, route registration,
  error fallback, `MaterialApp.title` vs `pubspec.display_name`.
- **Comando verificación:**
  ```
  wc -l lunasea/lib/main.dart lunasea/lib/core.dart lunasea/lib/modules.dart
  grep -nE 'MultiProvider|ChangeNotifierProvider|MaterialApp\.title' lunasea/lib/main.dart
  ```
- **Deliverable:** tabla con state-per-module, providers declarados,
  ruta de fallback en crash.
- **Modelo:** M3

### A2. API layer per service

- **Archivos:** `lunasea/lib/api/{sonarr,radarr,sabnzbd,nzbget,tautulli,wake_on_lan}/`
- **Buscar:** qué usa `@RestApi` (Retrofit), qué usa Dio crudo,
  controllers, interceptors, error handling, retry policy.
- **Comando verificación:**
  ```
  grep -rl '@RestApi\|RestApi()' lunasea/lib/api/
  grep -rl 'class .*Controller' lunasea/lib/api/
  for s in sonarr radarr sabnzbd nzbget tautulli wake_on_lan; do echo "=== $s ==="; find lunasea/lib/api/$s -name '*.dart' | wc -l; done
  ```
- **Deliverable:** tabla servicio × (Retrofit|Dio) × (controllers
  count) × (interceptors count).
- **Modelo:** M3 (lectura comparada)

### A3. Lidarr como excepción estructural **[Pro]**

- **Archivos:** `lunasea/lib/modules/lidarr/core/api/`
  (verificar que `lib/api/lidarr/` NO existe), comparar contra
  `lunasea/lib/api/sonarr/`.
- **Pregunta Pro:** ¿deberíamos migrar la API de Lidarr a
  `lib/api/lidarr/` para unificar el patrón canónico, o documentar
  la excepción? ¿Qué coste-beneficio?
- **Comando verificación:**
  ```
  ls lunasea/lib/api/lidarr 2>&1 | head
  find lunasea/lib/modules/lidarr -name '*.dart' | wc -l
  find lunasea/lib/api/sonarr -name '*.dart' | wc -l
  ```
- **Deliverable:** recomendación ADR-0007 (migrar | documentar)
  con pros/cons.
- **Modelo:** **Pro** (decisión arquitectónica multi-archivo)

### A4. Cobertura del spec `add-pending-imports-tile` **[Pro]**

- **Archivos:** los 3 specs +
  `lunasea/lib/api/sonarr/` (verificar que `types/import_mode.dart`
  y los modelos pendientes NO existen aún).
- **Pregunta Pro:** ¿qué falta crear exactamente? Lista enumerada
  con paths, en orden de implementación.
- **Comando verificación:**
  ```
  ls lunasea/lib/api/sonarr/types/ 2>&1
  grep -rln 'PendingImport\|ImportMode' lunasea/lib/ 2>&1
  ```
- **Deliverable:** lista enumerada de archivos a crear con tamaño
  estimado cada uno.
- **Modelo:** **Pro** (multi-file refactor planning)

### A5. State pattern por módulo

- **Archivos:** `lunasea/lib/modules/<svc>/core/state.dart` para
  sonarr, radarr, lidarr, sabnzbd, nzbget, tautulli, dashboard,
  search, settings, external_modules.
- **Buscar:** patrón común (ChangeNotifier + data + refresh*),
  desviaciones.
- **Comando verificación:**
  ```
  find lunasea/lib/modules -name 'state.dart' -exec wc -l {} \;
  ```
- **Deliverable:** tabla state × LOC × pattern.
- **Modelo:** M3

### A6. Widgets compartidos

- **Archivos:** `lunasea/lib/widgets/`
- **Buscar:** inventario de widgets Luna-prefixed.
- **Comando verificación:**
  ```
  find lunasea/lib/widgets -name '*.dart' | sort
  grep -E '^class Luna' lunasea/lib/widgets/**/*.dart | wc -l
  ```
- **Deliverable:** índice de widgets.
- **Modelo:** M3

### A7. Database / Hive

- **Archivos:** `lunasea/lib/database/`
- **Buscar:** boxes, migrations, @HiveField, defaultValue:.
- **Comando verificación:**
  ```
  find lunasea/lib/database -name '*.dart' -exec wc -l {} \;
  grep -rln '@HiveField' lunasea/lib/ | wc -l
  grep -rE '@HiveField\([0-9]+\)' lunasea/lib/ | grep -v 'defaultValue' | wc -l
  ```
- **Deliverable:** schema drift report (campos sin defaultValue).
- **Modelo:** M3

### A8. Routing tree

- **Archivos:** `lunasea/lib/router/`,
  `lunasea/lib/modules/<svc>/routes.dart`,
  `lunasea/lib/modules/<svc>/routes/<sub>/route.dart`
- **Buscar:** go_router shape, deep links, guards.
- **Comando verificación:**
  ```
  find lunasea/lib/router -name '*.dart' | sort
  find lunasea/lib/modules -name 'routes.dart' | wc -l
  ```
- **Deliverable:** mapa del route tree.
- **Modelo:** M3

---

## Track B — Seguridad & secrets

**Total:** 7 tasks · **5 M3, 1 Pro, 1 Flash** · Coste estimado ~$0.015

### B1. Secrets commiteados

- **Archivos:** todo `lunasea/`
- **Buscar:** API keys, tokens, passwords, urls con credenciales.
- **Comando verificación:**
  ```
  grep -rln 'api_key\|apiKey\|API_KEY\|password\|token\|secret' lunasea/lib/ lunasea/test/ 2>&1 | head
  ```
- **Deliverable:** lista de matches con contexto (path:line), o
  "clean".
- **Modelo:** M3

### B2. AndroidManifest permissions

- **Archivos:** `lunasea/android/app/src/main/AndroidManifest.xml`
- **Buscar:** permisos solicitados, intent-filters, exported
  components.
- **Comando verificación:**
  ```
  cat lunasea/android/app/src/main/AndroidManifest.xml
  ```
- **Deliverable:** lista de permisos + componentes exported.
- **Modelo:** M3

### B3. Network security config

- **Archivos:** `lunasea/android/app/src/main/res/xml/network_security_config.xml`,
  `lunasea/lib/system/network/`
- **Buscar:** cleartext traffic, cert pinning, TLS.
- **Comando verificación:**
  ```
  find lunasea/android -name 'network_security_config*'
  grep -rn 'cleartextTrafficPermitted\|certificatePinner' lunasea/lib/
  ```
- **Deliverable:** config report.
- **Modelo:** M3

### B4. Cifrado de credenciales en storage **[Pro]**

- **Archivos:** `lunasea/lib/database/`, específicamente el box
  donde se guardan profiles con API keys.
- **Pregunta Pro:** ¿las API keys se guardan en plaintext Hive?
  ¿Vale la pena cifrar? Trade-off seguridad/UX/performance.
- **Comando verificación:**
  ```
  grep -rln 'LunaProfile\|api_key' lunasea/lib/database/
  ```
- **Deliverable:** recomendación (cifrar | documentar | ignorar).
- **Modelo:** **Pro** (trade-off seguridad/UX)

### B5. url_launcher

- **Archivos:** busqueda en `lunasea/lib/`
- **Buscar:** `launchUrl` calls — ¿se filtra data sensible?
- **Comando verificación:**
  ```
  grep -rln 'launchUrl\|url_launcher' lunasea/lib/
  ```
- **Deliverable:** lista de usos con contexto.
- **Modelo:** M3

### B6. Webhooks

- **Archivos:** `webhooks.dart` en cada módulo
- **Buscar:** ¿verifica firma/HMAC?
- **Comando verificación:**
  ```
  find lunasea/lib -name '*webhook*'
  grep -rn 'HMAC\|signature\|verify' lunasea/lib/modules/*/core/webhooks* 2>&1
  ```
- **Deliverable:** report por webhook service.
- **Modelo:** M3

### B7. Audit de dependencias **[Flash]**

- **Archivos:** `lunasea/pubspec.yaml`, `pubspec.lock`
- **Buscar:** paquetes abandonados (sin release > 2 años), con
  CVEs conocidos conocidos, no-null-safety.
- **Comando verificación:**
  ```
  grep -A 200 '^dependencies:' lunasea/pubspec.yaml | head -100
  wc -l lunasea/pubspec.lock
  ```
- **Deliverable:** lista de paquetes sospechosos + verificación.
- **Modelo:** **Flash** (bulk text classification)

---

## Track C — Performance & tamaño

**Total:** 7 tasks · **6 M3, 1 Pro** · Coste estimado ~$0.01

### C1. Asset bloat

- **Archivos:** `lunasea/assets/`
- **Buscar:** imágenes/fonts no usados.
- **Comando verificación:**
  ```
  du -sh lunasea/assets/*
  find lunasea/assets -type f | wc -l
  ```
- **Deliverable:** lista de assets > 100 KB.
- **Modelo:** M3

### C2. Image cache leaks

- **Archivos:** `lunasea/lib/widgets/` + uso de `CachedNetworkImage`
- **Comando verificación:**
  ```
  grep -rln 'CachedNetworkImage\|Image.network' lunasea/lib/
  ```
- **Deliverable:** lista de usos + análisis de memory leak risk.
- **Modelo:** M3

### C3. Timer / polling

- **Archivos:** state.dart de cada módulo
- **Comando verificación:**
  ```
  grep -rn 'Timer\.periodic\|StreamSubscription' lunasea/lib/
  ```
- **Deliverable:** lista de timers + análisis.
- **Modelo:** M3

### C4. List virtualization

- **Archivos:** pages/*.dart de los módulos grandes
- **Buscar:** `LunaListView` con/sin `itemExtent`.
- **Comando verificación:**
  ```
  grep -rln 'LunaListView\|ListView\.builder' lunasea/lib/ | wc -l
  ```
- **Deliverable:** % de listas sin itemExtent.
- **Modelo:** M3

### C5. print/debugPrint

- **Comando verificación:**
  ```
  grep -rn '^\s*print(\|^\s*debugPrint(' lunasea/lib/ | wc -l
  ```
- **Deliverable:** count.
- **Modelo:** M3

### C6. APK size baseline

- **Comando verificación:**
  ```
  find lunasea/build/app/outputs/flutter-apk -name '*.apk' -exec ls -la {} \; 2>&1 | head
  ```
  (si no hay build, anotar N/A)
- **Deliverable:** APK size, o "no build available".
- **Modelo:** M3

### C7. Dashboard jank analysis **[Pro]**

- **Archivos:** `lunasea/lib/modules/dashboard/routes/dashboard/pages/calendar.dart`,
  `schedule.dart`
- **Pregunta Pro:** trade-off diseño vs perf — ¿qué optimizaciones
  tienen mejor relación esfuerzo/beneficio?
- **Deliverable:** recomendaciones priorizadas.
- **Modelo:** **Pro** (trade-off diseño/perf)

---

## Track D — Calidad & consistencia (todo M3, $0)

**Total:** 9 tasks

### D1. dart analyze

- **Comando:**
  ```
  docker compose -f lunasea/docker-compose.android.yml run --rm build bash -c 'cd /app && flutter analyze lib/ 2>&1 | tail -50'
  ```
  (o `cd lunasea && flutter analyze lib/` si hay SDK local)
- **Deliverable:** count errors/warnings.
- **Modelo:** M3

### D2. dart format check

- **Comando:**
  ```
  cd lunasea && dart format --set-exit-if-changed --output=none lib/ 2>&1 | head
  ```
- **Deliverable:** lista de archivos mal formateados, o "all good".
- **Modelo:** M3

### D3. print/debugPrint count

- Reusar C5 si se hizo; sino D5 (TODO/FIXME/HACK).

### D4. TODO/FIXME/HACK

- **Comando:**
  ```
  grep -rEn 'TODO|FIXME|HACK|XXX' lunasea/lib/ | head -40
  ```
- **Deliverable:** count + lista priorizada.
- **Modelo:** M3

### D5. Naming `Luna*` convention

- **Comando:**
  ```
  grep -rEn '^class [A-Z]' lunasea/lib/ --include='*.dart' | grep -vE '^.*:class Luna' | head
  ```
- **Deliverable:** clases públicas sin prefijo Luna.
- **Modelo:** M3

### D6. Barrel consistency

- **Comando:**
  ```
  for m in sonarr radarr lidarr sabnzbd nzbget tautulli search settings dashboard external_modules; do
    if [ -f lunasea/lib/modules/$m.dart ]; then echo "$m: HAS barrel"; else echo "$m: NO barrel"; fi
  done
  ```
- **Deliverable:** tabla.
- **Modelo:** M3

### D7. .g.dart hand-edited

- **Comando:**
  ```
  for f in $(find lunasea/lib -name '*.g.dart'); do
    if ! head -1 "$f" | grep -q '// GENERATED'; then echo "POSSIBLE HAND-EDIT: $f"; fi
  done | head
  ```
- **Deliverable:** lista.
- **Modelo:** M3

### D8. @HiveField position

- **Comando:**
  ```
  grep -rE '@HiveField\([0-9]+\)' lunasea/lib/ --include='*.dart' -A1 | grep -B1 'defaultValue:' | head -10
  ```
- **Deliverable:** campos con defaultValue fuera de fin (raro).
- **Modelo:** M3

### D9. Branding drift (LunaSea vs dashboarrcheky)

- **Comando:**
  ```
  grep -rEn "'LunaSea'|\"LunaSea\"|app\.lunasea" lunasea/lib/ lunasea/android/app/ lunasea/pubspec.yaml
  ```
- **Deliverable:** lista de menciones a renombrar.
- **Modelo:** M3

---

## Track E — Tests (roadmap item 10)

**Total:** 3 tasks · **2 M3, 1 Pro** · Coste estimado ~$0.02

### E1. Test strategy ADR **[Pro]**

- **Pregunta Pro:** ¿qué testear primero? ¿qué NO testear?
  ¿unit vs widget vs integration? ¿golden tests para el Dashboard?
- **Deliverable:** propuesta de estrategia en formato ADR.
- **Modelo:** **Pro** (decisión arquitectónica)

### E2. Sample test per layer (proof-of-concept)

- 3 archivos pequeños: `test/state/sonarr_state_test.dart`,
  `test/widget/dashboard_modules_test.dart`, `test/api/sonarr_controller_test.dart`.
- **Comando verificación:**
  ```
  cd lunasea && flutter test test/state/sonarr_state_test.dart 2>&1 | tail
  ```
- **Deliverable:** 3 archivos commiteados + reporte de tests que
  pasan.
- **Modelo:** M3

### E3. CI integration

- Archivo: `lunasea/.github/workflows/test.yml`
- **Deliverable:** workflow que corre `flutter test` en cada push.
- **Modelo:** M3

---

## Track F — Internacionalización & UX

**Total:** 5 tasks · **4 M3, 1 Pro** · Coste estimado ~$0.01

### F1. easy_localization setup

- **Archivos:** `lunasea/lib/main.dart`, `lunasea/assets/translations/`
- **Comando:**
  ```
  ls lunasea/assets/translations/
  grep -n 'easy_localization\|Locale' lunasea/lib/main.dart
  ```
- **Deliverable:** report de locales soportados.
- **Modelo:** M3

### F2. Strings hardcoded

- **Comando:**
  ```
  grep -rEn "Text\('|Text\(\"" lunasea/lib/ --include='*.dart' | grep -v '\.tr(' | head
  ```
- **Deliverable:** count de strings hardcoded.
- **Modelo:** M3

### F3. Accessibility audit **[Pro]**

- **Archivos:** muestreo de widgets principales
- **Pregunta Pro:** ¿Semantics widgets presentes? ¿contraste
  suficiente? ¿font scaling soportado?
- **Deliverable:** report por componente.
- **Modelo:** **Pro** (juicio UX/a11y)

### F4. Empty / error / loading states

- **Archivos:** pages/ de cada módulo
- **Comando:**
  ```
  grep -rln 'isEmpty\|isLoading\|hasError' lunasea/lib/modules/*/routes/
  ```
- **Deliverable:** % de páginas con los 3 estados.
- **Modelo:** M3

### F5. Touch target sizes

- **Comando:**
  ```
  grep -rEn 'padding:|minHeight:|size:' lunasea/lib/widgets/buttons/ 2>&1 | head
  ```
- **Deliverable:** análisis de tamaños.
- **Modelo:** M3

---

## Execution order

1. **D1 → D9** (Track D primero, son M3 y limpian el campo antes de
   auditar arquitectura).
2. **A1, A2, A5, A6, A7, A8** (Track A M3 puro, lectura).
3. **A3, A4** (Track A Pro, decisiones).
4. **B1-B7** (Track B, mezcla).
5. **C1-C7** (Track C, mezcla).
6. **F1-F5** (Track F, mezcla).
7. **E1, E2, E3** (Track E, último; si lo decide el usuario).

**Reglas de ejecución:**
- Cada task lee **antes de** escribir cualquier nota de finding.
- Cada task verifica su finding con el comando documentado antes
  de reportarlo.
- **No skip un comando porque "ya sé la respuesta".** Confirmación
  mecánica siempre.
- Cuando Pro esté asignado, **delegar la task entera** — el
  reporte Pro entra al reporte global sin re-procesar.

## Risks

- **Track D1 (`flutter analyze`) requiere Docker** si no hay SDK
  Flutter local. Si no hay Docker, dejar la task con "N/A —
  requiere Docker build" y seguir.
- **Track A4 (spec coverage)** puede revelar que la spec está
  incompleta antes de empezar la implementación. Eso es **expected
  output**, no un blocker.
- **Track B4 (cipher at rest)** puede recomendar cifrar Hive, lo
  cual implica una migración. Si pasa, dejar el finding como
  "P1 + ADR propuesto" sin implementar.

## Definition of done (this plan)

- [ ] Las 39 tasks ejecutadas con su comando de verificación
      completado (o anotadas N/A con razón).
- [ ] Reporte global escrito en
      `.hermes/plans/2026-09-02_204200-review-findings.md`
      con tabla resumen (severidad × count) + lista enumerada de
      findings P0/P1.
- [ ] Reporte commit + push al origin.
- [ ] Working tree clean.

## Cost summary

| Track | M3 | Pro | Flash | Coste |
|-------|----|----|-------|-------|
| A | 6 | 2 | 0 | ~$0.06 |
| B | 5 | 1 | 1 | ~$0.015 |
| C | 6 | 1 | 0 | ~$0.01 |
| D | 9 | 0 | 0 | $0 |
| E | 2 | 1 | 0 | ~$0.02 |
| F | 4 | 1 | 0 | ~$0.01 |
| **TOTAL** | **32** | **6** | **1** | **~$0.115** |

## References

- Review previa (deepseek-v4-pro): 11 hallazgos confirmados + 7
  nuevos. Detalles en conversación 20260902_215641_354ca1.
- `.hermes/plans/2026-09-01_120124-dashboard-stack-widgets.md` —
  plan maestro de `add-pending-imports-tile`.
- `docs/specs/add-pending-imports-tile/{requirements,design,tasks}.md`
- `docs/adr/0005-spec-driven-workflow.md` — workflow bajo el cual
  se ejecuta este plan.
- `docs/adr/0006-plans-in-repo.md` — política de tracking de plans.
- `docs/reference/models.md` — tabla de routing de modelos.
