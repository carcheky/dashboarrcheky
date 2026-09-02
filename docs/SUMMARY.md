# Docs SUMMARY

> Resumen de qué vive dónde. Este doc existe porque la doc del fork
> tiene dos doc-sets para features que se solapan: **`docs/specs/`**
> y **`docs/features/`**. `AGENTS.md` y `docs/conventions.md` solo
> mencionan el segundo; este SUMMARY es el único sitio donde se
> reconcilian los dos. Si te pierdes, lee este archivo primero.

## Specs vs Features — cuál es cuál

| | `docs/specs/<slug>/` | `docs/features/<slug>.md` |
|---|---|---|
| **Qué es** | Plan técnico (3 archivos) | Doc user-facing (1 archivo) |
| **Cuándo se crea** | **Antes** de tocar código | **Cuando se mergea** el código |
| **Audiencia** | Devs + AI agents | Usuarios finales |
| **Plantilla** | `docs/specs/TEMPLATE/{requirements,design,tasks}.md` | `docs/features/TEMPLATE.md` |
| **Estado en roadmap** | `[~]` mientras está en spec | `[x]` cuando se mergea |
| **Decisión de fondo** | ADR-0005 (spec-driven workflow) | ADR-0003 (docs strategy) |
| **Commit footer** | No se commitea (el spec va antes) | `Docs: docs/features/<slug>.md` |

**No son intercambiables.** El spec es el "qué + cómo" que escribe
el dev/IA antes de codear; el feature doc es la nota de release que
lee el usuario. Un PR que mergea código debe tener los dos creados
(spec aprobado antes, feature doc en el commit).

## Otros doc-sets relacionados

| Carpeta | Qué vive ahí | Plantilla |
|---------|--------------|-----------|
| `docs/specs/` | Planes técnicos antes de codear (3 archivos por spec) | `docs/specs/TEMPLATE/` |
| `docs/features/` | Notas de release cuando se mergea una feature | `docs/features/TEMPLATE.md` |
| `docs/fixes/` | Bug fixes shipped (1 archivo por fix) | `docs/fixes/TEMPLATE.md` |
| `docs/adr/` | Decisiones arquitectónicas (1 por decisión) | MADR shape, ver [adr/0001-docker-build.md](adr/0001-docker-build.md) |
| `docs/modules/` | Doc de cada módulo/servicio | Patrón libre, ver `sonarr.md` |
| `docs/api/` | Capas cross-cutting (HTTP, Hive, routing) | Libre |
| `docs/reference/` | Tooling (toolchain, env vars, codegen) | Libre |
| `docs/operations/` | Ops (GitHub Pages, etc.) | Libre |
| `docs/sessions/` | (legacy) session handoffs — ahora en `.agents/sessions/` | — |

## Workflow típico de una feature

```
1. Pillar un item de docs/roadmap.md (o proponer uno nuevo)
2. Copiar docs/specs/TEMPLATE → docs/specs/<slug>/
3. Rellenar requirements.md → design.md → tasks.md
4. PR con los 3 archivos → aprobación → merge a master
   (status del row en roadmap: [ ] → [~])
5. Branch feature/<slug> desde master
6. Implementar tasks.md
7. Build + smoke test + dart analyze
8. PR → merge a beta
9. Crear docs/features/<slug>.md (rellenar de tasks.md + commit msgs)
10. Flip row en roadmap ([~] → [x]), entrada en timeline.md "Past"
11. Commit con footer "Docs: docs/features/<slug>.md"
12. PR a master
```

## Cuándo NO crear un spec

Cambios que no justifican `docs/specs/`:

- Bug fixes triviales (1 archivo, comportamiento obvio) → van
  directo a `docs/fixes/<slug>.md` al mergear.
- Refactors sin cambio de comportamiento.
- Cambios de tooling (Gradle, AGP, lint config).
- Cambios de doc solamente.

Regla práctica: si cabe en 1 commit y no toca el flujo de usuario,
es fix/doc/tooling. Si toca comportamiento, modelo de datos, o
cambia >1 módulo, es feature → spec primero.

## Cómo el router de AGENTS.md mapea a esto

| AGENTS.md dice | Acción real |
|----------------|-------------|
| "New feature → `docs/features/TEMPLATE.md`" | Incompleto. También `docs/specs/TEMPLATE/`. |
| "Bug fix → `docs/fixes/TEMPLATE.md`" | OK. |
| "HTTP endpoint → `docs/api/http.md`" | Actualizado 2026-09-02 (rutas reales). |
| "Hive schema → `docs/api/hive.md`" | OK. |
| "Route change → `docs/api/routing.md`" | OK pero `routing.md` aún no corregido (paths). |
| "Why a decision → `docs/adr/index.md`" | OK. |
| "New feature → spec en `docs/specs/`" | **Implícito.** No estaba en AGENTS.md hasta este patch. |
