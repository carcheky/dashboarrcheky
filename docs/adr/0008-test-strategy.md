# ADR-0008: Test strategy for `lunasea/`

## Status

Accepted. 2026-09-02.

## Context

El repo arranca con **0 tests** (Track E del plan de revisión
exhaustiva 2026-09-02, F-E*). Esto bloquea:

- Refactors seguros (ej. migración Lidarr ADR-0007, ~8-12h de
  split de monolith 762 LOC; sin tests = regresión silenciosa).
- Cualquier CI gate de calidad (no hay workflow de `flutter test`).
- Confianza en `flutter pub upgrade` mayor.

Tres decisiones que tomar: qué testear, con qué herramientas, y
cuándo se vuelve gate.

## Decision

Adoptamos estrategia **estratificada con foco en state + controllers**,
mockeando solo la red, con **golden tests selectivos** y gate **blando
hoy, duro por módulo en Fase 2**.

### 1. Qué testear primero / qué NO (al menos no aún)

| Prioridad | Capa | Razón |
|-----------|------|-------|
| **Primero** | `*State` (reset, `fetch*`, `notifyListeners`) | Más regressions por $ invertido. Cambio barato. |
| **Primero** | Controllers Dio puros (transforman response → modelo) | Sin UI, sin storage; test = `expect(ctrl.parse(json), model)`. |
| **Primero** | Funciones puras (extensions, helpers de `lib/utils/`) | Triviales;覆盖率 90%. |
| **Segundo** | Widgets primitivas (`LunaBlock`, `LunaListView`, `LunaButton`) | Golden para evitar regresiones de estilo. |
| **Segundo** | `ModulesPage` (Dashboard) | 1 golden test que valida el orden + estados vacíos. |
| **Tercero** | Stateful widgets de cada ruta | Tests de comportamiento, no de pixel. |
| **NO aún** | Integration tests (app completa en device) | Coste de mantenimiento > valor sin CI real. |
| **NO aún** | Los ~100 controllers de los 7 módulos | Cubrir los 2-3 críticos por módulo basta. |
| **NO** | Golden de `CalendarView` / `ScheduleView` | Red + reloj = flaky inevitable. |
| **NO** | Golden con `LunaNetworkImage` | I/O red en tests = flaky. |

### 2. Proporción por tipo

- **Unit 70%** — state + controllers + puras.
- **Widget 25%** — comportamiento (no pixel salvo golden selectivos).
- **Integration 5%** — happy path de 1 ruta por módulo (smoke).

### 3. Golden tests: sí, selectivos

| Widget | Golden | Por qué |
|--------|--------|---------|
| `LunaBlock` (variantes empty/full/error) | sí | Pieza fundamental del UI; regressions visibles. |
| `LunaListView*` (3 variantes) | sí | Estilo del fork depende de esto. |
| `LunaButton` (3 variants) | sí | Color/typography/iconos. |
| `ModulesPage` (Dashboard, 1 estado) | sí | Validar que renderiza los 6-9 tiles activos. |
| `CalendarView` / `ScheduleView` | NO | `DateTime.now()` + `TableCalendar` + red = flaky. |
| Cualquier cosa con `LunaNetworkImage` | NO | I/O. |

Golden se commitean a `test/goldens/<widget>_goldens.dart`. Si el
render cambia legítimamente, `flutter test --update-goldens` en local
y commit del PNG. CI no debe auto-actualizar.

### 4. Mocks: `mocktail`, no `mockito`

- `mocktail` (sin codegen, sin build_runner extra).
- **Mockea la red** (Dio) vía el seam que ya existe:
  `SonarrAPI.from(LunaProfile)` se reemplaza por
  `SonarrAPI.from(Dio client)`. **Hoy ese seam no existe** — añadir
  en la primera PR de tests (ver Plan, paso 2).
- **Hive real in-memory** (`Hive.init(Directory.systemTemp.createTempSync().path)`).
  Más fiel que mockear.
- **Provider**: `.value` con `ChangeNotifierProvider<LunaSonarrState>(value: state)`
  en el widget test. Sin `MockProvider`.

Regla: **mockea la red, no el estado ni el storage.** Mockear el state
es probar tu propio mock.

### 5. Cobertura objetivo **por capa** (no global)

| Capa | Target | Por qué |
|------|--------|---------|
| Funciones puras (`lib/utils`, `lib/extensions`) | **90%** | Barato; máximo valor. |
| `*State` | **80%** | Reset + fetch* + notifyListeners cubiertos. |
| Controllers Dio | **70%** | Happy path + 1-2 errores por controller. |
| Widgets primitivas | **40%** | Golden + 1 test de comportamiento. |
| Stateful widgets de rutas | **30%** | Smoke; cobertura exhaustiva = maintenance hell. |
| **Global** | sin objetivo | Engaña; el % global sube con tests baratos. |

### 6. Naming + estructura

```
lunasea/test/
├── fixtures/<module>/<thing>.json       # JSON crudo de la API
├── mocks/<thing>_mock.dart              # mocktail MockXxx
├── state/<module>_state_test.dart       # espejo del path src/
├── controllers/<module>_<ctrl>_test.dart
├── widget/<widget>_test.dart
├── goldens/<widget>_goldens.dart
└── helpers/                             # pumpWith(), fakeProfile(), etc.
```

- File naming: **espejo del path** (`lib/modules/sonarr/core/state.dart`
  → `test/state/sonarr_state_test.dart`).
- Group por clase: `group('LunaSonarrState', () { ... })`.
- Tests describen **comportamiento**, no implementación
  (`test('fetchAll updates state on success', ...)`,
  no `test('calls _doFetch', ...)`).

### 7. Orden de implementación

1. **Paso 0 (este PR):** `flutter_test` + `mocktail` en `pubspec.yaml`.
   Workflow `test.yml` mínimo (lint + test). Sin tests todavía.
2. **Paso 1:** seam `SonarrAPI.from(Dio)` (1 archivo, 1 PR).
3. **Paso 2:** 3 sample tests (este PR, los de E2):
   - `test/state/sonarr_state_test.dart` — `fetchAll` happy path.
   - `test/controllers/sonarr_command_controller_test.dart` — parse JSON.
   - `test/widget/luna_block_test.dart` — comportamiento + 1 golden.
4. **Paso 3:** replicar a Radarr + Lidarr (siguiendo el patrón Sonarr).
5. **Paso 4:** Golden del set curado (5 widgets + ModulesPage).
6. **Paso 5:** SABnzbd / NZBGet / Tautulli (menos crítico).
7. **Paso 6:** Dashboard (último, depende del resto).

### 8. Gate

- **Hoy (Fase 1):** gate **blando**. Reviewer humano puede pedir
  tests pero no bloquea merge.
- **Fase 2 (cuando Fase 1 esté madura):** gate **duro por módulo
  delta**. Un PR que toque `lib/modules/<m>/` sin tests nuevos para
  `<m>` no pasa CI. Nunca global contra línea base 0%.
- **Nunca:** "el PR debe mantener ≥X% cobertura". Esa métrica es
  ruidosa y anima a gaming.

### 9. Riesgos

| Riesgo | Mitigación |
|--------|-----------|
| **Tests flaky** (red, reloj, shimmer) | Aisla con `FakeAsync`; mockea Dio; nunca en golden. |
| **`DateTime.now()` en código de producción** | Inyectar `Clock` (paquete `clock`); cubrir en la primera PR que aparezca. |
| **Speed de `flutter test` frío** | Sharded (`--concurrency=4`); CI en runner con >4 cores. |
| **Estáticos de Hive (`Hive.initFlutter`)** | Usar `Hive.init(tempDir)` en `setUpAll`; único refactor necesario (1 línea). |
| **i18n** (`easy_localization` con locale `'en'` fijo en `main.dart`) | Tests fuerzan `Locale('en')` en `setUp`. |
| **`google_fonts` requiere red** | Cachear en `setUpAll` o mockear con archivo `.ttf` vacío en test. |

## Consequences

### Positive

- Refactors como ADR-0007 (Lidarr strangler) se vuelven seguros.
- `flutter pub upgrade` mayor pasa de "yoga" a proceso verificable.
- Onboarding de nuevos contribuidores: tests son la doc de comportamiento.
- CI gate (incluso blando) reduce regressions silenciosas.

### Negative

- Coste inicial ~2-3 días (setup + 3 samples + workflow).
- Maintenance burden: tests rotos en PRs refactor = ruido.
- Riesgo de "test theater": cubrir 90% de `*State` sin cubrir lo
  que importa. **Mitigación:** code review + el rule "test comportamiento,
  no implementación".

### Open questions

- **¿Sharded CI en GitHub Actions?** Hoy hay 8 workflows de build
  pero no de test. Plan: añadir `test.yml` con matriz por OS (Linux
  para speed, macOS para iOS-specific si surge). Decidir tras
  primer PR con tests.
- **¿`integration_test` package?** Diferido hasta que CI madure
  (Fase 2+).

## References

- `.hermes/plans/2026-09-02_204200-review-findings.md` (F-E1-1 origen)
- `.hermes/plans/2026-09-02_204200-exhaustive-review.md` (Track E)
- `docs/adr/0005-spec-driven-workflow.md` — formato MADR tomado de aquí
- `docs/adr/0006-plans-in-repo.md`
- Flutter testing docs: <https://docs.flutter.dev/testing>
- `mocktail`: <https://pub.dev/packages/mocktail>
- DeepSeek V4-Pro external review, 2026-09-02 (Track E1)
