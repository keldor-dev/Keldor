# ADR-0008: Fleet Command and Pipeline Contract

| Property | Value |
|---|---|
| Status | Accepted |
| Date | 2026-07-16 |
| Decision Owner | Keldor Development Team |
| Applies To | Fleet, remote-management, infrastructure, health, cloud, compliance, and remediation commands |

## Context

Keldor contains public commands created across different eras and operational contexts. Their target parameters,
pipeline behavior, output shapes, value types, error handling, and display behavior vary. That variation makes fleet
automation harder to compose with filtering, grouping, sorting, export, reporting, CMDB and ServiceNow workflows, and
remote execution.

Keldor's platform-aware loader and backward-compatibility policy also mean that normalization cannot be a broad rewrite
of existing Windows-oriented commands. The repository needs an enforceable rule for new work and an incremental path
for legacy commands.

## Decision

Fleet-oriented and infrastructure-oriented commands must accept pipeline-friendly inputs and emit normalized,
structured objects with stable property names and native PowerShell/.NET types.

The normative contract is maintained in the
[Keldor Input & Output Standard](../../standards/Keldor_Input_Output_Standard.md#fleet-and-infrastructure-contract).

## Scope

The decision covers system and server inventory, remote execution, health and compliance, service and storage
management, network diagnostics, patch/package state, cloud and Azure/Arc resources, virtualization and infrastructure
providers, certificate/TLS inspection, fleet reporting, CMDB workflows, monitoring, and remediation. Other commands
should adopt it when structured pipeline composition has meaningful value.

It does not require pipeline input where binding would be ambiguous or unsafe, and it does not add fleet parameters to
commands that do not implement those capabilities.

## Required Input Conventions

- `ComputerName` is the canonical remote-system identity. `HostName` and other non-conflicting names may be aliases.
- `InputObject` accepts a documented rich-object contract.
- `PSSession` accepts reusable sessions and uses a distinct parameter set from `ComputerName`.
- Relevant connection parameters use the canonical names and semantics in the Input & Output Standard.
- Pipeline-aware commands stream through `process`; they aggregate only when behavior requires it.
- Mutable fleet commands retain per-target or per-operation `ShouldProcess` calls.

## Required Output Conventions

- Success output is structured and machine-consumable, not preformatted text.
- Defined contracts use ordered properties and stable `Keldor.*` type names.
- Booleans, timestamps, durations, measurements, versions, addresses, and URIs retain native types where practical.
- Units appear in property names instead of formatted values.
- Per-target failure objects use stable diagnostic properties and do not suppress successful target results.
- Verbose, warning, and error streams supplement rather than replace structured results.

## Compatibility Implications

New commands in scope must comply. Existing commands without a stable contract should migrate through additive, tested
changes. Existing parameters, aliases, parameter sets, type names, property names and types, state values, and stream
behavior are potential public APIs. Breaking changes require compatibility review, deprecation where practical, and
semantic-versioning treatment.

## Consequences

### Positive

- Fleet output composes predictably with PowerShell and enterprise integrations.
- Native values remain sortable, filterable, serializable, and culture-neutral.
- Templates and scoped tests prevent new contract drift.
- Platform-specific implementations can share one public design language.

### Negative

- Authors must design and document object contracts before implementation.
- Stable contracts constrain later renaming and type changes.
- Legacy commands will remain inconsistent until migrated deliberately.
- Per-target result handling adds implementation and test work.

## Alternatives Considered

### Continue With Command-Specific Conventions

Rejected because consumers would continue adapting every command before composing fleet workflows.

### Refactor Every Existing Command Immediately

Rejected because widespread parameter, stream, and object changes would create unacceptable compatibility risk.

### Require a Shared .NET Result Class

Rejected because a stable `PSTypeName` and explicit object contract provide interoperability without imposing class and
runtime-version constraints. Classes remain appropriate only when they add meaningful validation or behavior.

### Require Pipeline Input for Every Command

Rejected because some commands are command-wide, interactive, unsafe to bind implicitly, or otherwise not naturally
item-oriented.

## Migration Approach

The checked-in [fleet migration audit](../../development/fleet-command-migration-audit.md) records current candidates,
contracts, risk, and priority. Migration proceeds one object family at a time: capture behavior in tests, make additive
input improvements, add compatible canonical properties or type names, update help, and reserve breaking removals for a
planned major version.
