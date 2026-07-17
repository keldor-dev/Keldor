# Module Layout

## Philosophy

Keldor follows a feature-oriented layout with a clear separation between public commands, private implementation, documentation, and build assets.

## Repository Structure

At the repository root, `build.ps1` is a thin consumer of `Keldor.Build.PowerShell` and `build.config.psd1` contains
only Keldor-specific relative paths and metadata. Reusable staging, versioning, packaging, and publishing code is not
owned by this repository.

```text
Keldor/
│
├── Public/
├── Private/
├── Classes/
├── Enums/
├── Resources/
├── Tests/
├── docs/
├── build/
├── Keldor.psd1
└── Keldor.psm1
```

## Public

Contains all exported commands.

One function per file.

## Private

Contains helper functions.

Nothing in this folder is exported.

## Classes

Contains PowerShell classes used throughout the module.

## Enums

Contains reusable enumerations.

## Resources

Static assets including:

- icons
- templates
- configuration
- localization
- embedded files

## Tests

Contains unit and integration tests.

## docs

Developer documentation.

Public documentation lives in the separate `keldor-dev/docs` repository.

## Design Principles

- One function per file
- Small focused functions
- Cross-platform where practical
- Public API stability
- Windows PowerShell 5.1 parser compatibility in shared production files
- Supported PowerShell 7 release lines beginning with PowerShell 7.4

## Deterministic Loading Order

The source loader uses this dependency order:

1. Runtime validation.
2. Module configuration and shared classes.
3. Foundational private helpers and Common private functions.
4. Current-platform private functions.
5. Common public functions, including `Get-KeldorPlatform`.
6. Current-platform public functions.
7. Aliases and exports.

Files are discovered only as direct `*.ps1` children of the intended folder, filtered for temporary/hidden names, and
sorted by full path before dot-sourcing. Required load failures terminate import and name the responsible file.

## Remaining Global Configuration State

`config.ps1` and `classes.ps1` retain the historical `$Global:KeldorConfig` and `$Global:Keldor` contracts because many
public commands and the tray application consume them. The root loader does not introduce additional global state.
Replacing these variables requires a separate configuration-contract migration with consumer tests; the
[runtime migration audit](../development/powershell-runtime-migration-audit.md) records that follow-up.
