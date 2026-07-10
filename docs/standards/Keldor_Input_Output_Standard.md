# Keldor Input & Output Standard

| Property | Value |
|---|---|
| Version | 1.0 |
| Status | Proposed |
| Applies To | Keldor public functions and user-facing command output |
| Last Updated | 2026-07-07 |

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
- Immediate `PSTypeName` adoption.
- Rewriting unrelated command logic.

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

- `IsEnabled`
- `IsInstalled`
- `IsOnline`
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

Avoid vague names:

- `Date`
- `Time`
- `When`
- `Timestamp`

Use `DateTime` values when practical. If the source system returns a string or filetime value and converting it would change behavior, preserve the legacy property and add a canonical converted property in a separate, tested change.

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

## Migration Policy

Keldor migration work must be incremental and low risk.

- Preserve old parameters as aliases.
- Preserve legacy output properties when removal would break users.
- Normalize one object family per PR.
- Do not introduce `PSTypeName` yet.
- Do not mix parameter normalization, output reshaping, formatting changes, and unrelated logic modernization in the same PR.
- Add or update Pester tests for parameter aliases and output contracts where practical.
- Prefer additive changes first, then documented deprecation, then major-version removal if needed.

### Suggested PR Order

1. Parameter-only normalization with aliases.
2. Output contract tests for one object family.
3. Add canonical output properties while preserving legacy properties.
4. Update help and examples to use canonical names.
5. Add formatting or type data only after output contracts stabilize.
6. Consider `PSTypeName` adoption in a future standard and migration plan.

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

### Phase 5: Future Type System Work

Do not introduce `PSTypeName` yet.

After canonical parameter and output names are stable, create a separate Keldor PSTypeName taxonomy standard and migrate one object family at a time.
