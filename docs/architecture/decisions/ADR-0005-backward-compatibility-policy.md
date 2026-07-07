# ADR-0005: Backward Compatibility Policy

| Property | Value |
|---|---|
| Status | Accepted |
| Date | 2026-07-07 |
| Decision Owner | Keldor Development Team |
| Applies To | Keldor PowerShell compatibility decisions |

## Context

Keldor is intended to work in modern PowerShell environments and older enterprise environments.

The project has historically targeted environments that may include:

- PowerShell 7+
- Windows PowerShell 5.1
- Windows PowerShell 2.0 where practical
- Hardened enterprise systems
- Department of Defense and STIG-aligned systems
- Systems with limited or outdated PowerShell capabilities

Modern PowerShell features can improve readability and developer productivity, but they may break compatibility with older systems.

## Decision

Keldor will follow a compatibility policy based on practical support rather than absolute support for every old feature.

Compatibility targets are:

1. PowerShell 7+ as the preferred runtime.
2. Windows PowerShell 5.1 where practical.
3. Windows PowerShell 2.0 where practical and safe.

Compatibility must not override security, correctness, or maintainability.

## Rationale

Keldor's value comes partly from working in restrictive and legacy environments where many modern tools fail.

However, supporting older PowerShell versions cannot come at the cost of unsafe code, broken behavior, or unmaintainable implementation.

This policy allows Keldor to preserve compatibility where it matters while still evolving over time.

## Consequences

### Positive

- Preserves usefulness in legacy and hardened environments.
- Makes compatibility expectations explicit.
- Avoids accidental use of unsupported syntax in shared code.
- Allows modern PowerShell features when compatibility does not matter.

### Negative

- Some code must avoid newer syntax.
- Some implementations may be more verbose than modern PowerShell equivalents.
- Contributors must understand which compatibility target applies to a function.

## Guidance

Shared code should avoid PowerShell 7-only features unless the function is explicitly PowerShell 7-only.

PowerShell 2.0-compatible code should avoid:

- classes
- enums
- `using namespace`
- null-coalescing operators
- ternary operators
- `ForEach-Object -Parallel`
- `Import-PowerShellDataFile`
- `ConvertFrom-Json`

PowerShell 2.0-compatible code may prefer:

- `New-Object PSObject`
- `Add-Member`
- WMI where CIM is unavailable
- simple hashtables and arrays

## Alternatives Considered

### PowerShell 7+ Only

Rejected because it would reduce Keldor's usefulness in older enterprise and government environments.

### Windows PowerShell 2.0 Everywhere

Rejected because it would unnecessarily constrain modern and cross-platform development.

### No Compatibility Policy

Rejected because unclear compatibility expectations lead to inconsistent code and accidental breakage.

## Future Considerations

Keldor.Build.PowerShell should eventually support compatibility validation by target profile.

For example:

```powershell
Test-KeldorCompatibility -Target PowerShell51
Test-KeldorCompatibility -Target PowerShell20
```

This decision should be revisited if Keldor formally drops support for Windows PowerShell 2.0 or 5.1.
