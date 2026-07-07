# ADR-0004: Formal PowerShell Engineering Standard

| Property | Value |
|---|---|
| Status | Accepted |
| Date | 2026-07-07 |
| Decision Owner | Keldor Development Team |
| Applies To | Keldor PowerShell projects |

## Context

Keldor is evolving from a collection of PowerShell functions into a broader ecosystem of modules, build tooling, documentation, snippets, and repository templates.

A simple style guide is not enough to capture the engineering expectations for this ecosystem.

Keldor needs a standard that covers:

- security
- compatibility
- documentation
- naming
- function design
- parameter design
- output objects
- error handling
- performance
- testing
- repository hygiene
- future automation

## Decision

Keldor will maintain a formal PowerShell Engineering Standard.

The standard will be versioned and treated as the canonical reference for PowerShell development across Keldor projects.

The current standard is:

```text
Keldor PowerShell Engineering Standard v1.0
```

## Rationale

A formal engineering standard gives Keldor a consistent technical identity.

It also gives contributors and future maintainers a clear reference for how PowerShell code should be written, reviewed, documented, tested, and eventually validated through automation.

The standard should be more than formatting guidance. It should describe the design philosophy behind Keldor PowerShell code.

## Consequences

### Positive

- Creates a consistent development baseline.
- Improves maintainability.
- Helps contributors understand project expectations.
- Supports future automation through Keldor.Build.PowerShell.
- Reduces drift between modules.

### Negative

- Adds documentation that must be maintained.
- May require gradual modernization of older functions.
- Some legacy code may not immediately conform.

## Alternatives Considered

### Informal Conventions

Rejected because informal conventions are easy to forget and hard to enforce.

### Style Guide Only

Rejected because Keldor needs standards for security, compatibility, testing, documentation, and architecture, not only formatting.

### External Style Guide

Rejected because Keldor has unique requirements around PowerShell 2.0, STIG-hardened systems, platform-aware loading, and DoD-adjacent environments.

## Future Considerations

Keldor.Build.PowerShell should eventually provide validation commands that enforce selected parts of the standard.

Examples include:

```powershell
Test-KeldorEngineeringStandard
Test-KeldorCommentHelp
Test-KeldorHelpUri
Test-KeldorNaming
Test-KeldorCompatibility
Test-KeldorSecurity
```
