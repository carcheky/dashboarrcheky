# Architecture Decision Records

Why we did things the way we did.

| ADR                                              | Decision                                                |
|--------------------------------------------------|---------------------------------------------------------|
| [0001](0001-docker-build.md)                     | Build APKs inside Docker, not on the host.              |
| [0002](0002-branching-model.md)                  | master + beta + feature/* branches, SemVer tags.        |
| [0003](0003-docs-strategy.md)                    | mkdocs-formatted docs with selective AI loading.        |
| [0004](0004-toolchain-and-16kb-page-size.md)      | Android toolchain + 16 KB page-size compatibility plan. |
| [0005](0005-spec-driven-workflow.md)              | Spec phase (requirements/design/tasks) before code.     |
| [0006](0006-plans-in-repo.md)                    | `.hermes/plans/` is a tracked team artifact.            |
| [0007](0007-lidarr-api-exception.md)             | Lidarr API stays under `modules/` until strangler.    |
| [0008](0008-test-strategy.md)                    | Stratified testing: state → controllers → widgets.     |

## Format

Each ADR follows the lightweight MADR shape:

- **Context** — what was the problem
- **Decision** — what we chose
- **Consequences** — what it costs and what it buys

Keep them short. Update the relevant ADR (don't write a new one) when the
decision evolves.
