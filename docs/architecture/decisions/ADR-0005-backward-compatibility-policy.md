# ADR-0005: Supported PowerShell Runtime Policy

| Property | Value |
|---|---|
| Status | Accepted |
| Date | 2026-07-16 |
| Supersedes | The 2026-07-07 legacy-runtime form of ADR-0005 |
| Decision Owner | Keldor Development Team |
| Applies To | Keldor PowerShell compatibility decisions |

## Context

Keldor previously treated PowerShell 7+, Windows PowerShell 5.1, and Windows PowerShell 2.0 where practical as
compatibility goals. That policy complicated the loader, platform detection, object construction, testing, and
documentation while implying support for retired and insecure runtime lines.

Numeric version comparison is insufficient because PowerShell Core 6.x and retired PowerShell 7 lines are numerically
greater than Windows PowerShell 5.1. PowerShell edition and lifecycle both matter.

## Decision

Keldor supports:

1. Windows PowerShell 5.1 on Windows versions that remain supported by Microsoft.
2. Microsoft-supported PowerShell 7 release lines beginning with PowerShell 7.4.

At adoption, positive coverage includes PowerShell 7.4, 7.5, and 7.6. PowerShell 7.6 LTS is the preferred development,
automation, and CI runtime. Support for 7.4 and 7.5 is temporary and ends when lifecycle review raises the baseline.

Keldor rejects Windows PowerShell below 5.1, PowerShell Core 6.x, PowerShell 7.0-7.3, and unknown editions. The manifest
sets the numeric 5.1 minimum and edition metadata; an early root-module guard enforces the complete policy.

Shared production code must parse in Windows PowerShell 5.1. It avoids PowerShell 7-only parser syntax even though the
preferred development runtime is newer. Platform-specific dependencies remain isolated by folder and deterministic
loading.

## Consequences

### Positive

- Removes obsolete parser and platform-detection workarounds.
- Establishes a deterministic, testable import boundary.
- Aligns positive testing with maintained Microsoft runtime lines.
- Preserves Windows PowerShell 5.1 for supported Windows enterprise environments.
- Separates production compatibility from the preferred development runtime.

### Negative

- Users on dropped runtime lines must upgrade before importing the next Keldor major version.
- Shared files cannot use PowerShell 7-only syntax while Windows PowerShell 5.1 remains supported.
- Maintainers must review lifecycle state and periodically raise the Core minimum.

## Enforcement and Maintenance

The loader does not query the internet or embed a lifecycle-date database. The checked-in
[compatibility matrix](../../compatibility.md),
[lifecycle review policy](../../development/powershell-lifecycle-policy.md), CI, and release process control the tested
runtime set.

Dropping a supported runtime or raising a runtime minimum is a semantic-versioning major change. The migration does not
itself select or publish a release version.
