# Keldor Input & Output Standard

| Property | Value |
|---|---|
| Version | 2.0 |
| Status | Stable |
| Applies To | Keldor public functions and user-facing command output |
| Last Updated | 2026-07-16 |

## Purpose

This standard defines canonical parameter names, output property names, compatibility rules, and migration guidance for Keldor public functions.

It extends the [Keldor General Engineering Standard](Keldor_General_Engineering_Standard.md) and the [Keldor PowerShell Engineering Standard](Keldor_PowerShell_Engineering_Standard.md). Its goal is to make Keldor commands feel like one coherent toolkit: predictable inputs, stable objects, and migration paths that do not surprise existing users.

## Scope

This standard applies to:

- Public function parameter names and aliases.
- Structured output property names.
- Compatibility aliases for renamed parameters.
- Legacy output property preservation.
- Migration planning for existing Keldor commands.

This standard does not require:

- Immediate breaking changes to existing functions.
- Immediate output object reshaping.
- Immediate `PSTypeName` adoption for legacy object contracts.
- Rewriting unrelated command logic.

## Fleet and Infrastructure Contract

Fleet-oriented and infrastructure-oriented commands must accept pipeline-friendly inputs and emit normalized,
structured objects with stable property names and native PowerShell/.NET types.

This rule applies to server inventory, remote execution, system health, service management, storage and filesystem
health, network diagnostics, patch and package status, Azure resources, Azure Arc-enabled servers, virtualization,
Nutanix and other infrastructure integrations, certificate and TLS inspection, fleet reporting, configuration
compliance, CMDB discovery or reconciliation, and monitoring or remediation workflows. It is also recommended whenever
pipeline composition and structured output provide meaningful value.

The contract is required for new commands in this scope. Existing commands follow the compatibility and migration rules
in this document and the [fleet migration audit](../development/fleet-command-migration-audit.md).

## Pipeline Input

Public commands that logically operate on one or more objects must support pipeline input when practical and
semantically appropriate. Use `ValueFromPipeline = $true`, `ValueFromPipelineByPropertyName = $true`, or both. Do not
add pipeline binding when it would be ambiguous or unsafe.

Pipeline-aware commands must use the lifecycle blocks that their behavior needs:

- Use `begin` for one-time initialization.
- Use `process` for each incoming item or target.
- Use `end` only for aggregation, finalization, or cleanup.
- Do not collect all input in memory unless aggregation is part of the command contract.

### Canonical Target Parameters

`ComputerName` is the canonical public parameter for a DNS name, FQDN, NetBIOS name, or IP address that identifies a
remote system. Do not expose separate `ComputerName` and `HostName` parameters for the same identity.

```powershell
[Parameter(
    Mandatory = $true,
    ValueFromPipeline = $true,
    ValueFromPipelineByPropertyName = $true
)]
[Alias('HostName', 'DnsHostName', 'Name')]
[ValidateNotNullOrEmpty()]
[string[]]
$ComputerName
```

Aliases may be reduced when they conflict with command semantics. Existing aliases remain compatibility-sensitive.

Use `InputObject` for a documented rich-object contract, not as an unstructured dumping ground:

```powershell
[Parameter(Mandatory = $true, ValueFromPipeline = $true)]
[ValidateNotNull()]
[object[]]
$InputObject
```

Help must identify the properties or types accepted through `InputObject`. Prefer a more specific parameter or type
when the accepted value has a well-defined domain name.

Use `PSSession` when an existing session can be reused. Commands that accept both `ComputerName` and `PSSession` must
use meaningful, separate parameter sets and must not reconnect when a valid session is supplied.

## Remote and Fleet Parameters

Use these names when the capability is implemented and meaningful; do not add unused fleet parameters:

```text
ComputerName
InputObject
PSSession
Credential
KeyFilePath
Port
Transport
ThrottleLimit
ConnectionTimeout
OperationTimeout
RetryCount
RetryDelay
SessionOption
```

- `Credential` must be `[pscredential]`. Plaintext password parameters are prohibited. Credential contents must never
  appear in output, logs, verbose messages, or errors.
- `KeyFilePath` identifies an SSH private key. Validate syntax without eagerly reading or resolving the path when that
  would break remoting. Never emit key contents.
- `Transport` must use explicit validated values when multiple transports are supported. A typical set is `Auto`,
  `WSMan`, `SSH`, and `Local`. Help must state the `Auto` selection order and its security implications.
- `ThrottleLimit` must be positive, conservatively bounded by default, and documented as caller-tunable for network,
  endpoint, and policy constraints. Unlimited concurrency must not be the default.
- `ConnectionTimeout`, `OperationTimeout`, and `RetryDelay` use seconds. Include the unit in help.
- `RetryCount` is the number of additional attempts after the initial attempt. Do not retry authentication,
  authorization, invalid-parameter, or other clearly non-transient failures unless explicitly documented. Prefer
  bounded backoff for transient failures.

## Parameter Sets

Each parameter set must represent a meaningful execution path. Do not create sets that differ only cosmetically.

```powershell
[CmdletBinding(DefaultParameterSetName = 'ComputerName')]
param(
    [Parameter(
        Mandatory = $true,
        ParameterSetName = 'ComputerName',
        ValueFromPipeline = $true,
        ValueFromPipelineByPropertyName = $true
    )]
    [Alias('HostName', 'DnsHostName')]
    [ValidateNotNullOrEmpty()]
    [string[]]$ComputerName,

    [Parameter(
        Mandatory = $true,
        ParameterSetName = 'Session',
        ValueFromPipeline = $true
    )]
    [ValidateNotNull()]
    [System.Management.Automation.Runspaces.PSSession[]]$PSSession
)
```

## Canonical Parameter Naming Rules

Public parameters must use clear PascalCase names that describe the value being supplied.

Prefer established PowerShell conventions where they exist. Use the same canonical parameter name for the same concept across all public functions.

| Concept | Canonical Parameter |
|---|---|
| Target computer or remote host | `ComputerName` |
| User identity | `UserName` |
| Group identity | `GroupName` |
| Input filesystem path | `Path` |
| Output or destination filesystem path | `DestinationPath` |
| Registry key or value path | `RegistryPath` |
| IP address | `IPAddress` |
| Operating system name | `OperatingSystem` |
| CPU or OS architecture | `Architecture` |
| Operating system build number | `BuildNumber` |

### Parameter Guidance

- Use `ComputerName`, not `Computer`, `Host`, `Machine`, `Server`, or `Name`, when the value targets one or more computers.
- Use `UserName`, not `User`, `Username`, `LoggedOn`, or `Name`, when the value identifies a user.
- Use `GroupName`, not `Group`, when the value identifies a group.
- Use `Path` for input paths.
- Use `DestinationPath` for output paths, copied files, generated files, exports, and save locations.
- Use `RegistryPath` for registry paths; avoid `FullPath` when the path is specifically a registry location.
- Use `IPAddress`, not `IP`, `IPs`, `IPv4`, or `Address`, for an IP address parameter.
- Use `BuildNumber`, not `Build`, for OS build numbers.
- Boolean switch parameters should describe the action or mode clearly. Avoid vague switch names such as `Yes`, `No`, `On`, or `Off` for new public functions.

## Canonical Output Property Naming Rules

Structured output must use stable, descriptive PascalCase property names.

Fleet commands must return objects as their primary success output. `Write-Host`, `Format-Table`, `Format-List`, and
`Out-String` are presentation-boundary tools and must not produce a reusable command's primary result. Use explicit,
ordered `[pscustomobject]` definitions. Property order is a public usability characteristic and must be intentional.

```powershell
$result = [pscustomobject][ordered]@{
    ComputerName = $resolvedComputerName
    IsSuccessful = $true
    Status       = 'Healthy'
    CheckedAt    = [datetimeoffset]::UtcNow
}

$result.PSObject.TypeNames.Insert(0, 'Keldor.SystemHealthResult')
$result
```

Defined public fleet contracts require a stable type name. Use `Keldor.<Entity>`, `Keldor.<Entity>Result`, or
`Keldor.<Provider>.<Entity>`, for example `Keldor.SystemInfo`, `Keldor.RemoteCommandResult`, `Keldor.Azure.Server`,
`Keldor.Linux.Package`, or `Keldor.CertificateStatus`. Do not introduce a .NET class only to attach a type name, and do
not change an established public type name without a compatibility plan.

Recommended property order is:

1. Primary identity.
2. Parent or scope identity.
3. Platform or provider.
4. Primary result or state.
5. Detailed measurements.
6. Error details.
7. Timing and provenance.

Do not alphabetize properties when it makes the object harder to understand.

Use the same property name for the same concept across all object families. Do not use short aliases, abbreviations, or source-system field names as canonical properties unless they are industry standard.

| Concept | Canonical Output Property |
|---|---|
| Computer name | `ComputerName` |
| User name | `UserName` |
| Group name | `GroupName` |
| Filesystem path | `Path` |
| Destination filesystem path | `DestinationPath` |
| Registry path | `RegistryPath` |
| IP address | `IPAddress` |
| Operating system name | `OperatingSystem` |
| Architecture | `Architecture` |
| Build number | `BuildNumber` |
| Creation timestamp | `Created` |
| Modification timestamp | `Modified` |
| Collection timestamp | `CollectedAt` |
| Validation or check timestamp | `CheckedAt` |
| Normalized state | `Status` |
| Human-readable detail | `Message` |

### Output Guidance

- Use `ComputerName`, not `Computer` or `Name`, when the property identifies a computer.
- Use `UserName`, not `User`, `Username`, or `LoggedOn`, when the property identifies a user.
- Use `Path`, not `Directory`, when the value is a filesystem path.
- Use `RegistryPath`, not `FullPath`, for registry locations.
- Use `InterfaceName`, `InterfaceAlias`, and `InterfaceIndex`, not `Name`, `ConnectionID`, and `Index`, for network interfaces.
- Use `IPAddress`, not `IP`.
- Use `OperatingSystem`, not `OS`.
- Use `Architecture`, not `Bit`.
- Use `BuildNumber`, not `Build`.
- Use `Message` for human-readable detail. Do not overload `Status` with long explanatory text.

## Boolean Naming Rules

Boolean properties must read naturally as true or false.

Use:

- `IsSuccessful`
- `IsHealthy`
- `IsAvailable`
- `IsConnected`
- `IsCompliant`
- `IsEnabled`
- `IsInstalled`
- `HasChanges`
- `CanRestart`
- `IsExpired`
- `HasErrors`

Avoid:

- `Enabled`
- `Installed`
- `Online`
- `Expired`
- `Errors`

When preserving old output properties, keep the old boolean property if existing users may depend on it, and add the canonical `Is*` or `Has*` property in a separate compatibility-focused change.

## Date/Time Naming Rules

Date and time properties must explain what the timestamp means.

Use:

- `Created` for creation time.
- `Modified` for last modification time.
- `CollectedAt` for the time Keldor collected or generated the object.
- `CheckedAt` for the time Keldor performed a check or test.
- `StartedAt` and `CompletedAt` for operation boundaries.
- `DiscoveredAt`, `UpdatedAt`, and `LastSeenAt` for the named lifecycle event.

Avoid vague names:

- `Date`
- `Time`
- `When`
- `Timestamp`

Use `DateTime` values when practical. If the source system returns a string or filetime value and converting it would change behavior, preserve the legacy property and add a canonical converted property in a separate, tested change.

Prefer `[datetimeoffset]` when timezone and transport semantics matter. Use `[timespan]` for `Duration`, or a numeric
type for explicitly named values such as `DurationMilliseconds`.

## Native Types and Units

Public output contracts must preserve native values:

| Value | Preferred type |
|---|---|
| Boolean | `[bool]` |
| Count or byte quantity | Integer type |
| Percentage or measurement | Numeric type |
| Duration | `[timespan]` |
| Date/time | `[datetime]` or `[datetimeoffset]` |
| Version | `[version]` when semantically valid |
| IP address | `[System.Net.IPAddress]` when practical |
| URI | `[uri]` when practical |

Do not return display strings such as `15 GB`, `72%`, or `300 ms`. Use numeric properties with explicit names such as
`FreeSpaceBytes`, `FreeSpaceGB`, `FreeSpacePercent`, or `LatencyMilliseconds`. Output values must be invariant and
culture-neutral; localization belongs at the presentation boundary.

## Normalized Result Contracts

### Remote Command Result

`Keldor.RemoteCommandResult` uses this stable property order and meaning:

```text
ComputerName
IsSuccessful
Output
ErrorCategory
ErrorCode
ErrorMessage
StartedAt
CompletedAt
Duration
Transport
AttemptCount
```

`Output` may hold one or more native PowerShell objects and must not be stringified merely for serialization.
`AttemptCount` is the total number of attempts actually made. One failed target must not suppress successful target
results unless the caller explicitly requests terminating behavior.

### Health and Compliance Result

`Keldor.SystemHealthResult` and domain-specific health types should use this shape when the properties apply:

```text
ComputerName
CheckName
IsHealthy
Status
Severity
Message
CurrentValue
ExpectedValue
ErrorCategory
ErrorCode
ErrorMessage
CheckedAt
```

Allowed severity values are `Informational`, `Warning`, `Critical`, and `Unknown`. Allowed health status values are
`Passed`, `Failed`, `Skipped`, and `Unknown`. A skipped or unavailable check must not report `IsHealthy = $true`.
When compatibility permits, use `IsHealthy = $null` and `Status = 'Unknown'` for an indeterminate result.

## Streams and Per-Target Failure

- The success stream contains only objects in the documented public contract. Capture or suppress incidental command
  and method output.
- The verbose stream describes non-sensitive target selection, transport selection, retries, provider choice,
  pagination, and progress details.
- The warning stream reports recoverable concerns, but never replaces a structured per-target failure result.
- Use non-terminating errors for individual target failures when other targets can continue. Honor `-ErrorAction`.
- Use terminating errors for invalid command-wide configuration, invalid authentication configuration, unsupported
  parameter combinations, missing dependencies that prevent all execution, and corrupted internal state.
- Never emit an error and then report the same operation as successful. Never expose credentials, tokens, secrets,
  connection strings, key material, or stack traces as normal output.

## Fleet State Changes and ShouldProcess

Pipeline support does not change the repository's
[`SupportsShouldProcess` rules](Keldor_PowerShell_Engineering_Standard.md#cmdletbinding). A fleet command that changes
external or persistent state must set `SupportsShouldProcess = $true` and call `$PSCmdlet.ShouldProcess()` for each
target or discrete change. Read-only inventory, discovery, inspection, and health commands must not add
`SupportsShouldProcess`.

## Result/Status Naming Rules

Use `Status` for normalized result state.

Good `Status` values are short and suitable for filtering:

```text
Succeeded
Failed
Skipped
Online
Offline
Available
Unavailable
Compliant
NonCompliant
Unknown
```

Use `Message` for human-readable details:

```powershell
[pscustomobject]@{
    ComputerName = 'SERVER01'
    Status       = 'Failed'
    Message      = 'The remote registry service is unavailable.'
}
```

Do not place long explanatory text in `Status` when a separate `Message` property is appropriate.

## Legacy Alias Compatibility Guidance

When renaming a public parameter:

1. Add the canonical parameter name.
2. Preserve the previous parameter name as an alias.
3. Preserve commonly used legacy aliases unless they are unsafe or ambiguous.
4. Update comment-based help to document the canonical parameter name.
5. Do not remove old aliases in the same PR that introduces the canonical name.

Example:

```powershell
param(
    [Parameter(Mandatory = $true)]
    [Alias('User', 'Username', 'SamAccountName')]
    [string]$UserName
)
```

Parameter aliases are the preferred compatibility mechanism. Do not keep duplicate parameters that represent the same value unless PowerShell binding rules require it.

## Legacy Output Property Compatibility Guidance

Output property changes are higher risk than parameter name changes because users commonly pipe, filter, export, and serialize Keldor output.

When normalizing output:

1. Preserve legacy output properties when removal would break users.
2. Add canonical properties rather than renaming destructively.
3. Keep the existing default display shape unless the PR is explicitly scoped to output formatting.
4. Avoid changing property types in the same PR as property-name normalization.
5. Document legacy properties as compatibility properties when help is updated.

Example additive migration:

```powershell
[pscustomobject]@{
    Computer     = $ComputerName   # legacy
    ComputerName = $ComputerName   # canonical
    Status       = 'Online'
}
```

Legacy output properties may be removed only in a documented major-version migration.

## Good and Bad Parameter Names

| Bad | Good | Reason |
|---|---|---|
| `Computer` | `ComputerName` | Matches PowerShell convention and pipeline property names. |
| `Host` | `ComputerName` | `Host` conflicts with PowerShell host terminology. |
| `User` | `UserName` | Clarifies identity value. |
| `Username` | `UserName` | Uses consistent PascalCase word boundary. |
| `Group` | `GroupName` | Clarifies identity value. |
| `DirectoryName` | `Path` | A directory path is still a path. |
| `Destination` | `DestinationPath` | Clarifies that the value is a path. |
| `FullPath` | `RegistryPath` | Clarifies registry-specific meaning. |
| `IP` | `IPAddress` | Avoids abbreviation drift. |
| `Build` | `BuildNumber` | Clarifies numeric OS build. |
| `Yes` / `No` | `Enable` / `Disable` or `IsEnabled` | Avoids unclear switch behavior. |

## Good and Bad Output Properties

| Bad | Good | Reason |
|---|---|---|
| `Computer` | `ComputerName` | Consistent computer identity property. |
| `User` | `UserName` | Consistent user identity property. |
| `Group` | `GroupName` | Consistent group identity property. |
| `Directory` | `Path` | The value is a filesystem path. |
| `FullPath` | `RegistryPath` | Registry path should be explicit. |
| `IP` | `IPAddress` | Avoids abbreviation drift. |
| `OS` | `OperatingSystem` | Clear and searchable. |
| `Bit` | `Architecture` | Describes the concept accurately. |
| `Build` | `BuildNumber` | Clarifies numeric build. |
| `Date` | `Created`, `Modified`, `CollectedAt`, or `CheckedAt` | Explains timestamp meaning. |
| `When` | `Created`, `Modified`, `CollectedAt`, or `CheckedAt` | Avoids vague timing. |
| `Enabled` | `IsEnabled` | Boolean reads naturally. |
| `Installed` | `IsInstalled` | Boolean reads naturally. |
| `Errors` | `HasErrors` | Boolean reads naturally. |

## Public API Compatibility

Keldor migration work must be incremental and low risk.

- New fleet commands must comply with this standard.
- Existing commands without an established contract should move toward it through small, tested changes.
- Existing commands with known consumers require compatibility review before changing parameter names, aliases,
  parameter sets, type names, property names, property types, state values, or stream behavior.
- Preserve old parameters as aliases.
- Preserve legacy output properties when removal would break users.
- Normalize one object family per PR.
- Add a stable `PSTypeName` only when the object shape already represents a defined contract and compatibility is
  demonstrated.
- Do not mix parameter normalization, output reshaping, formatting changes, and unrelated logic modernization in the same PR.
- Add or update Pester tests for parameter aliases and output contracts where practical.
- Prefer additive changes first, then documented deprecation, then major-version removal if needed.

### Suggested PR Order

1. Parameter-only normalization with aliases.
2. Output contract tests for one object family.
3. Add canonical output properties while preserving legacy properties.
4. Update help and examples to use canonical names.
5. Add formatting or type data only after output contracts stabilize.
6. Add the documented Keldor `PSTypeName` after the object family is stable and compatibility is demonstrated.

## Initial Implementation Roadmap

### Phase 1: Input Normalization

Normalize low-risk parameter names and preserve aliases:

- `Build` to `BuildNumber`.
- `ImagePath` to `Path`.
- `FileName` to `Path`.
- `DirectoryName` to `Path`.
- `IP` and `IPs` to `IPAddress`.
- `User`, `Username`, and `SamAccountName` to `UserName`.
- `Destination` to `DestinationPath`.

### Phase 2: Contract Tests

Add parser or command-metadata tests that verify:

- Canonical parameter names exist.
- Legacy aliases remain available.
- Mandatory path and identity parameters have safe validation.
- Public output contracts are captured before reshaping.

### Phase 3: Low-Risk Output Normalization

Start with small, stable object families:

- Build number conversion.
- Directory statistics.
- Update history.
- Certificate inventory.
- Simple process result objects.

### Phase 4: Higher-Risk Output Families

Defer wide or mixed-domain outputs until tests are strong:

- Hardware inventory.
- Network interface inventory.
- Endpoint security status.
- Active Directory compliance reports.
- Local user and group inventory.

### Phase 5: Type Name Adoption

After a canonical object family is stable, assign its documented Keldor type name one family at a time. Preserve
established type names and use a compatibility plan for any unavoidable change.
