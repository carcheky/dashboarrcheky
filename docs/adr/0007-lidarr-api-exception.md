# ADR-0007: Lidarr API path exception (strangler migration)

## Status

Proposed. 2026-09-02.

## Context

Lidarr es el único servicio cuya API vive bajo
`lib/modules/lidarr/core/api/` en vez del canónico
`lib/api/<svc>/{controllers,models,types}/` que siguen Sonarr/Radarr.
SABnzbd/NZBGet usan además Retrofit (`@RestApi`), que ni Sonarr/Radarr
ni Lidarr adoptan.

Forma actual de Lidarr (verificada por V4-Pro en revisión 2026-09-02):

- `lib/modules/lidarr/core/api/api.dart` — **762 LOC, monolith**.
  14 controllers inlineados.
- `lib/modules/lidarr/core/api/data/*.dart` — 14 modelos (3 con
  `.g.dart`).
- Consumo: **22 call sites directos desde routes/widgets** (no vía
  state). La factory `LidarrAPI.from(LunaProfile)` recibe el profile
  en cada llamada.
- HTTP: Dio crudo (igual que Sonarr/Radarr).
- `lib/api/lidarr/` **no existe**.

Las 5 servicios cubren 6+1 formas distintas de estructurar una API;
el fork está en transición.

## Decision

**Aceptar la excepción ahora; migrar incrementalmente (strangler).**

- Cada **nuevo endpoint de Lidarr** se escribe en
  `lib/api/lidarr/controllers/<resource>/<verb>.dart` siguiendo el
  patrón de Sonarr (no commands/, no monolith).
- Cada endpoint **existente** se mueve al patrón canónico **solo
  cuando se toque por otra razón** (bug fix, refactor, dependency
  bump). No se programa una migración big-bang.
- Mantener `LidarrAPI.from(LunaProfile)` como facade en
  `lib/modules/lidarr/core/api/api.dart` durante la transición.
  Internamente delega a los nuevos controllers. Cero cambios en
  los 22 call sites.
- Cuando todos los controllers estén en `lib/api/lidarr/`, mover la
  factory al nuevo path y borrar `lib/modules/lidarr/core/api/`.

### Por qué no migrar ahora

1. **Refactor puro, cero cambio funcional.** El módulo funciona hoy.
2. **Sin tests** (Track E del review 2026-09-02 confirma 0 tests
   globales). Cualquier regresión semántica de los 22 call sites es
   invisible sin cobertura.
3. **Rama actual** (`feature/add-pending-imports-tile`) ya está a
   mitad de una feature de Sonarr. AGENTS.md: "touch only what the
   task needs". Mezclar un refactor de 8-12h con una feature es
   anti-patrón.
4. **Coste estimado** (V4-Pro): split del monolith 4-6h + 22 call
   sites 2-3h + regenerate `.g.dart` 0.5h + smoke test device 1-2h
   = **~8-12h (1-1.5 días)**. Merece su propio PR.

### Por qué no documentar la excepción y ya

Considerado y **rechazado**: dejar el monolith indefinidamente crea
deuda permanente que cada contribuidor nuevo tiene que descubrir.
El strangler pone fecha de salida implícita (próximo feature Lidarr
dispara al menos 1 movimiento).

## Consequences

### Positive

- Cero churn durante features de otros módulos.
- Mejora progresiva: cada movimiento deja el módulo un poco más
  cerca del patrón canónico.
- Tests se pueden añadir **al lado del nuevo código** y al
  refactorizar el viejo, sin presión.
- Riesgo acotado: 1 movimiento por feature = diff pequeño = review
  manejable.

### Negative

- **Dos formas durante la transición** (monolith + controllers).
  Contribuidores deben saber que "lo nuevo va en api/lidarr/, lo
  viejo se queda donde está hasta que se toque".
- Riesgo de que **la transición nunca termine** si Lidarr no se
  toca durante meses. Mitigación: añadir un TODO en
  `lib/modules/lidarr/core/api/api.dart` con la fecha objetivo
  ("review Q1 2027") y un link a este ADR.

### Reversibility

Total. Si en algún momento se decide migrar todo de golpe, el
strangler no impide nada — solo habremos dejado controllers en su
sitio definitivo.

## References

- `.hermes/plans/2026-09-02_204200-review-findings.md` (F-A3-1 origen)
- `.hermes/plans/2026-09-02_204200-exhaustive-review.md` (Track A3)
- `docs/api/http.md` — patrón canónico Sonarr/Radarr
- `docs/modules/lidarr.md` — doc del módulo
- DeepSeek V4-Pro external review, 2026-09-02 (Track A3)
