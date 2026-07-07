# Keldor Architecture

This directory captures major architectural decisions for Keldor.

Architecture Decision Records explain why the project is designed the way it is. They are intended to protect deliberate engineering decisions from being accidentally undone later because the original context was lost.

## Architecture Decision Records

| ADR | Title | Status |
|---|---|---|
| [ADR-0001](decisions/ADR-0001-platform-aware-module-loading.md) | Platform-Aware Module Loading | Accepted |
| [ADR-0002](decisions/ADR-0002-configuration-format.md) | Use a PowerShell Script for Configuration | Accepted |
| [ADR-0003](decisions/ADR-0003-public-private-module-layout.md) | Public and Private Module Layout | Accepted |
| [ADR-0004](decisions/ADR-0004-powershell-engineering-standard.md) | Formal PowerShell Engineering Standard | Accepted |
| [ADR-0005](decisions/ADR-0005-backward-compatibility-policy.md) | Backward Compatibility Policy | Accepted |
| [ADR-0006](decisions/ADR-0006-build-time-code-generation.md) | Build-Time Code Generation | Proposed |
| [ADR-0007](decisions/ADR-0007-documentation-as-code.md) | Documentation as Code | Accepted |

## Historical Records

| ADR | Title | Status |
|---|---|---|
| [ADR-0006](decisions/ADR-0006-cross-platform-loading.md) | Cross-Platform Loading Model | Superseded by ADR-0001 |

## ADR Status Values

- `Proposed` — under consideration.
- `Accepted` — approved and currently guiding the project.
- `Superseded` — replaced by a newer ADR.
- `Deprecated` — no longer recommended, but retained for history.
