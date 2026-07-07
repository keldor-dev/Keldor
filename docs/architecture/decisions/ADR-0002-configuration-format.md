# ADR-0002: Use a PowerShell Script for Configuration

| Property | Value |
|---|---|
| Status | Accepted |
| Date | 2026-07-07 |
| Decision Owner | Keldor Development Team |
| Applies To | Keldor configuration files |

## Context

Keldor requires a configuration mechanism that works consistently across a broad range of PowerShell versions and operating environments.

The project has the following compatibility goals:

- PowerShell 7+
- Windows PowerShell 5.1
- Windows PowerShell 2.0 where practical
- Windows, macOS, and Linux where possible

Keldor has historically been used in enterprise, government, and Department of Defense environments, including systems hardened according to DISA STIGs and other security baselines.

During development and production use, several alternative configuration formats exhibited compatibility or operational issues in older and hardened PowerShell environments.

Examples include:

- JSON
  - Requires `ConvertFrom-Json`, which is unavailable in Windows PowerShell 2.0.
  - Requires additional parsing and type conversion.
- PSD1
  - Requires `Import-PowerShellDataFile`, introduced in later PowerShell versions.
  - May encounter restrictions in older or highly locked-down environments.
- CSV
  - Suitable only for simple tabular data.
  - Cannot naturally represent nested configuration, arrays, or complex PowerShell types.

These limitations reduced portability across Keldor's supported environments.

## Decision

Keldor will use a PowerShell script, such as `Config.ps1`, as its primary configuration format.

The configuration script may return a hashtable, return a custom object, or assign configuration values directly within module scope depending on module requirements and backward compatibility needs.

Configuration files should remain declarative whenever practical and should avoid performing unnecessary work during module import.

## Rationale

### Maximum Compatibility

A PowerShell script executes natively across every supported PowerShell version, including Windows PowerShell 2.0.

No additional parsing cmdlets are required.

### Native PowerShell Types

Configuration values can naturally contain:

- Hashtables
- Arrays
- ScriptBlocks
- Version objects
- Regular expressions
- PSCustomObjects
- Other PowerShell-native types

No serialization or conversion is necessary.

### Dynamic Configuration

Configuration values may be computed when appropriate.

Examples include:

- User profile paths
- Temporary directories
- Platform-specific defaults
- Environment variables

### STIG and Enterprise Compatibility

PowerShell script configuration has proven more reliable than JSON, CSV, or PSD1 files on some hardened enterprise and Department of Defense systems.

Avoiding additional parsing mechanisms reduces compatibility issues across restrictive environments.

### Cross-Platform Support

The same configuration model functions consistently across Windows, macOS, and Linux where Keldor supports those platforms.

## Consequences

### Positive

- Maximum compatibility across supported PowerShell versions.
- No dependency on newer PowerShell parsing cmdlets.
- Simplified loading.
- Native PowerShell object support.
- Flexible configuration.
- Proven reliability in enterprise and DoD environments.

### Negative

- Configuration files are executable PowerShell code.
- Care must be taken to keep configuration focused on configuration rather than business logic.
- Configuration loading should avoid unnecessary side effects.

## Alternatives Considered

### JSON

Rejected due to PowerShell 2.0 compatibility and additional parsing requirements.

### PSD1

Rejected due to later PowerShell version requirements and observed compatibility issues on some hardened systems.

### CSV

Rejected because it cannot adequately represent hierarchical configuration.

### XML

Rejected because it introduces unnecessary complexity for Keldor's configuration requirements.

## Future Considerations

Future versions of Keldor.Build.PowerShell may validate configuration files to ensure they:

- remain primarily declarative
- avoid unnecessary execution during import
- follow Keldor engineering standards
- maintain backward compatibility

This decision should be revisited only if Keldor's compatibility targets change significantly.
