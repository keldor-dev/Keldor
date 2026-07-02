# Module Layout

## Philosophy

Keldor follows a feature-oriented layout with a clear separation between public commands, private implementation, documentation, and build assets.

## Repository Structure

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
- Backward compatibility whenever possible
