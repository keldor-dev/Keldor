# Keldor Engineering Standards

This directory contains the canonical engineering standards for the Keldor ecosystem.

## Standards

| Standard | Purpose |
|---|---|
| [Keldor General Engineering Standard](Keldor_General_Engineering_Standard.md) | Language-agnostic engineering, repository, security, documentation, testing, and release expectations. |
| [Keldor PowerShell Engineering Standard](Keldor_PowerShell_Engineering_Standard.md) | PowerShell-specific design, style, compatibility, documentation, testing, and maintainability rules. |
| [Keldor Input & Output Standard](Keldor_Input_Output_Standard.md) | Canonical parameters, fleet pipeline and output contracts, compatibility rules, and migration guidance. |

## Standard Hierarchy

Keldor projects should follow the general engineering standard first, then apply the language-specific standard for the project type.

```text
Keldor General Engineering Standard
└── Keldor PowerShell Engineering Standard
    └── Keldor Input & Output Standard
```

Future language standards should follow the same pattern:

- Keldor Python Engineering Standard
- Keldor .NET Engineering Standard
- Keldor Node Engineering Standard
- Keldor Go Engineering Standard

## Versioning

Each standard includes document metadata with a version and status.

Repositories may declare which standard version they target. This allows Keldor standards to evolve without making every older repository instantly non-compliant.
