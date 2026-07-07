# ADR-0006: Cross-Platform Loading Model

| Property | Value |
|---|---|
| Status | Accepted |
| Date | 2026-07-07 |
| Decision Owner | Keldor Development Team |
| Applies To | Keldor cross-platform module behavior |

## Context

Keldor supports a mix of common PowerShell functions and platform-specific administrative functions.

Some functions are inherently Windows-specific because they depend on features such as:

- Windows Registry
- WMI
- CIM classes that exist only on Windows
- COM objects
- Active Directory tools
- Windows service control behavior
- Microsoft management consoles

Other functions can run on Windows, macOS, and Linux.

Keldor needs to support both categories without forcing unsupported platforms to load or evaluate code that cannot work there.

## Decision

Keldor will use a cross-platform loading model based on explicit platform folders.

Common code belongs in `Common` folders.

Platform-specific code belongs in the folder for that platform.

```text
Common
Windows
macOS
Linux
```

Windows-only functions should not pretend to be cross-platform.

If a function requires Windows APIs, it should live under a Windows-specific folder and document that assumption.

## Rationale

Explicit platform folders make platform support clear from repository structure.

They also reduce accidental import failures on unsupported systems and make it easier to reason about module behavior.

This design supports cross-platform growth without weakening the usefulness of Windows-specific administration tooling.

## Consequences

### Positive

- Clear platform boundaries.
- Safer imports on macOS and Linux.
- Better contributor guidance.
- Easier future platform expansion.
- Avoids misleading support claims.

### Negative

- Some functionality is intentionally unavailable on some platforms.
- Folder placement mistakes can hide functions.
- Platform detection must fail safely.

## Alternatives Considered

### Runtime Checks Inside Every Function

Rejected as the primary model because unsupported functions would still load everywhere and increase noise.

### Separate Repositories Per Platform

Rejected because it would fragment the Keldor module ecosystem.

### Windows-Only Module

Rejected because Keldor is intended to support cross-platform PowerShell where practical.

## Future Considerations

Keldor.Build.PowerShell may validate platform folder placement and detect functions that use platform-specific APIs from `Common` folders.
