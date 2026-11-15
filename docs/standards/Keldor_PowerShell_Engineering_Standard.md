# Keldor PowerShell Engineering Standard

| Property | Value |
|---|---|
| Version | 1.3 |
| Status | Stable |
| Applies To | All Keldor PowerShell projects |
| Last Updated | 2026-11-14 |

## Purpose

This standard defines the preferred engineering, documentation, compatibility, security, and style conventions for Keldor PowerShell projects.

It inherits from the [Keldor General Engineering Standard](Keldor_General_Engineering_Standard.md).

## Engineering Philosophy

Keldor PowerShell code should be secure, predictable, discoverable, and useful in real administrative and enterprise environments.

PowerShell commands should feel like a coherent toolkit, not a pile of unrelated scripts wearing the same hoodie.

## Design Principles

### Objects Over Text

Commands should return structured objects by default. Formatting belongs to the caller, format views, or documentation examples.

### Secure by Default

Validate inputs, avoid unsafe dynamic execution, do not hardcode secrets, and minimize privilege requirements.

### Cross-Platform by Default

New commands should support Windows, macOS, and Linux unless the command is inherently platform-specific.

### Supported Runtime Compatibility

Windows PowerShell 5.1 and Microsoft-supported PowerShell 7 release lines beginning with 7.4 are supported. PowerShell
7.6 LTS is preferred for development, automation, and CI. Shared production code must retain the Windows PowerShell 5.1
parser baseline.

### Discoverable

Public commands should include comment-based help, `HelpUri`, examples, and matching documentation pages.

### Consistent

Similar commands should use similar parameter names, aliases, output object shapes, error behavior, and documentation structure.

### Predictable

Commands should avoid hidden side effects. State-changing commands should support `-WhatIf` and `-Confirm` through `ShouldProcess`.

### Composable

Commands should work well in the pipeline and return objects suitable for filtering, exporting, and further automation.

## Compatibility Targets

Supported production runtimes:

- Windows PowerShell 5.1 on Microsoft-supported Windows versions.
- Microsoft-supported PowerShell 7 release lines beginning with 7.4.

PowerShell 7.6 LTS is the preferred development, automation, formatting, documentation, and CI runtime. Retired
PowerShell releases are not compatibility targets.

## Formatting

PowerShell source uses four spaces for each indentation level. Tabs are not permitted.

Keldor uses One True Brace Style (OTBS): opening braces remain on the same line as the associated statement, and
`else`, `elseif`, `catch`, and `finally` remain on the same line as the preceding closing brace.

### Functions and Lifecycle Blocks

```powershell
function Get-KeldorThing {
    [CmdletBinding()]
    param()

    begin {
        $Items = @()
    }

    process {
        $Items += Get-KeldorItem
    }

    end {
        $Items
    }

    clean {
        Remove-Variable -Name Items -ErrorAction SilentlyContinue
    }
}
```

Use `clean` only in code whose declared compatibility target supports it.

### Control Flow and Loops

```powershell
if ($Condition) {
    Invoke-Something
} elseif ($OtherCondition) {
    Invoke-OtherThing
} else {
    Invoke-DefaultThing
}

switch ($Status) {
    'Ready' {
        Start-KeldorThing
    }
    default {
        Write-Warning 'The Keldor thing is not ready.'
    }
}

foreach ($Item in $Items) {
    Write-Output $Item
}
```

### Error Handling

```powershell
try {
    Invoke-Something -ErrorAction Stop
} catch {
    Write-Error -ErrorRecord $_
} finally {
    Remove-Variable -Name TemporaryValue -ErrorAction SilentlyContinue
}
```

### Scriptblocks and Classes

```powershell
$ActiveItems = $Items | Where-Object {
    $_.IsEnabled
}

class KeldorThing {
    [string]$Name

    KeldorThing([string]$Name) {
        $this.Name = $Name
    }
}
```

Classes are appropriate only when the module's compatibility target supports them.

### Spacing

Use one space around assignment and binary operators and after commas. Apply the same spacing to attribute arguments,
hashtable entries, and named arguments where PowerShell syntax permits it.

```powershell
[Parameter(Mandatory = $true, Position = 0)]
[Alias('Host', 'Computer')]
[string]$ComputerName

$Parameters = @{
    Path        = $Path
    ErrorAction = 'Stop'
}
```

### Line Wrapping

The target maximum line length is 120 characters. Prefer syntax-aware wrapping over backticks.

Use splatting when a command has several parameters or becomes difficult to read:

```powershell
$Parameters = @{
    Path        = $Path
    Filter      = '*.ps1'
    Recurse     = $true
    ErrorAction = 'Stop'
}

Get-ChildItem @Parameters
```

For pipelines, place the pipe at the end of the preceding line and use one stage per continuation line:

```powershell
Get-ChildItem -Path $Path -Recurse |
    Where-Object { $_.Extension -eq '.ps1' } |
    Sort-Object -Property FullName
```

Wrap attributes using their parenthesized form:

```powershell
function Get-KeldorConfiguration {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSAvoidGlobalVars',
        '',
        Justification = 'Required for compatibility with the module configuration loader.'
    )]
    [CmdletBinding()]
    param()
}
```

Wrap compound Boolean expressions with one logical condition per line:

```powershell
if (
    $null -ne $CommandInfo -and
    $CommandInfo.Parameters.ContainsKey('PredictionSource') -and
    $PSCmdlet.ShouldProcess($Target, $Operation)
) {
    Invoke-Something
}
```

Short continuations may be indented by four spaces when splatting would add unnecessary complexity. Avoid backticks
unless no safer readable alternative exists.

Do not split strings in ways that change their value. Use here-strings for intentionally multiline content, format
expressions where appropriate, or intermediate variables when they improve clarity. Preserve external-command argument
ordering and quoting; wrapping must not change native argument-passing behavior.

URLs, `HelpUri` values, `.LINK` values, hashes, identifiers, and other indivisible literals may exceed 120 characters
when wrapping would harm correctness, usability, or copy-and-paste behavior.

## PowerShell Version Matrix

| Feature | Windows PowerShell 5.1 | Supported PowerShell 7 | Guidance |
|---|:---:|:---:|---|
| Advanced functions | Yes | Yes | Use for public commands. |
| Classes | Yes | Yes | Use only when they improve a stable design. |
| Enums | Yes | Yes | Use only when they improve a stable design. |
| `[pscustomobject]` and `[ordered]` | Yes | Yes | Prefer for structured output. |
| CIM cmdlets | Yes | Platform-dependent | Prefer for Windows management when behaviorally safe. |
| WMI cmdlets | Yes | Windows compatibility varies | Retain only for remote, vendor-provider, or tested fallback needs. |
| `ForEach-Object -Parallel` | No | Yes | Do not use in shared module code. |
| Ternary and null-coalescing operators | No | Yes | Do not use in shared module code. |
| `using namespace` | Yes | Yes | Use cautiously because module class discovery has parse-time behavior. |
| `$IsWindows`, `$IsLinux`, `$IsMacOS` | No | Yes | Use the Keldor platform helper outside its bootstrap implementation. |

## Naming Conventions

### Modules

Use PascalCase module names with clear ownership or purpose.

Examples:

```text
Keldor
Keldor.Build.PowerShell
Keldor.Build.Python
```

### Functions

Public functions must use approved PowerShell verbs.

```powershell
Get-Verb
```

Use singular nouns unless the noun is naturally plural.

Good:

```powershell
Get-KeldorProject
Test-KeldorRepository
Invoke-KeldorBuild
```

Avoid vague names:

```powershell
Do-Stuff
Run-Thing
Fix-Issue
```

### Variables

Use descriptive PascalCase variable names.

Good:

```powershell
$ComputerName
$RegistryPath
$CurrentUser
$ConnectionString
```

Avoid unclear names except in very small loop scopes:

```powershell
$Comp
$Reg
$temp
$x
```

### Collections

Use singular/plural intentionally.

```powershell
$Computer
$Computers
$User
$Users
$Item
$Items
```

### Booleans

Boolean variables should read naturally.

```powershell
$IsAdmin
$IsInstalled
$HasAccess
$SupportsRemoting
```

Avoid vague boolean names such as `$Admin` or `$Installed`.

## Function Architecture and Readability

Prioritize code clarity over abstraction for abstraction's sake. Write for the next developer who must understand and
maintain the function. These requirements apply to new work and scoped refactoring; existing functions do not need a
rewrite solely to satisfy these design objectives.

### One-File Comprehension Principle

Keep a public function's primary operational logic in its own source file whenever practical. A developer who
understands PowerShell but is unfamiliar with this repository should be able to identify the operation, systems,
services or APIs, native commands, processing steps, input validation, error handling, returned values, and custom
function dependencies and their purpose by reading that file. Avoid requiring several other custom files to understand
a straightforward operation. This is a design objective, not a prohibition against dependencies.

Use descriptive names, explicit steps, logical organization, straightforward control flow, limited hidden dependencies,
clear error handling, predictable structured output, and comments explaining intent. Do not sacrifice clarity for brevity.

### Indirection and Private Helpers

Avoid pass-through wrappers, parameter-renaming functions, single-purpose forwarding functions, and delegation layers
that add no meaningful behavior. Do not extract a helper merely because code could theoretically be reused or to remove
a few simple repeated lines.

Private helpers are appropriate for demonstrated reuse across functions, substantial complexity or algorithms, shared
security or validation, consistent output construction, platform boundaries, resource lifecycle management, or genuinely
shared behavior. Generally inline single-use helpers unless isolation substantially improves readability, testability,
safety, or maintainability.

Wrappers and delegation are permitted for backward compatibility, public API stability, meaningful orchestration,
platform abstraction, security boundaries, or substantial reusable functionality. Explain the architectural reason where
it is not obvious. Alternative command aliases may be appropriate only for an identical command contract; they must not
conceal incompatible behavior. This does not permit using aliases instead of full command names in implementation code.

### Specific Operations and Legitimate Orchestration

A public operational function should own its specific behavior. Avoid routing unrelated operations through a generic
dispatcher that hides the native query or state change. For example, a chain such as
`Get-EOIRADReplicationHealth` → `Invoke-EOIRADHealthCheck` → `Invoke-EOIRADServiceOperation` obscures a simple replication
query. Prefer keeping the operation-specific implementation in the public file.

A dispatcher is acceptable for a genuine extensibility mechanism, shared execution framework, or necessary operational
contract. Document that contract and why dispatch is necessary.

Orchestration functions may coordinate meaningful independent operations, including enterprise AD health assessments,
multi-system inventory, combined diagnostics, deployment, build/release, and cross-platform workflows. Keep useful
checks independently callable where practical. Do not copy entire implementations into an orchestrator to avoid calls.

### Custom Function Call Depth

Count custom-function delegation along a call path starting at the public entry point: the entry point itself is zero,
its custom callee is one layer, and that callee's custom callee is two. Count custom calls across modules as well as
private helpers; do not count native PowerShell cmdlets, external commands, or external APIs. Independent sibling calls
in an orchestrator do not add depth to each other.

| Custom delegation layers | Review guideline |
|---|---|
| 0–1 | Preferred for ordinary operational functions. |
| 2 | Acceptable when each layer has a distinct responsibility. |
| 3 or more | Flag for architectural review and explain the value of the layers. |

These are guidelines, not hard limits. Meaningful complex workflows may require deeper chains. Do not reject a workflow
solely because of depth or introduce an automatic depth-based rejection gate.

### Reuse, Dependencies, and Maintainability

Evaluate extraction by the amount and complexity of repeated logic, likelihood of shared changes, inconsistency risk,
number of consumers, readability, testing, and maintenance needs. A few simple duplicated lines may be clearer than a
new abstraction. Consolidate substantial duplicated business logic, security-sensitive behavior, and shared contracts
where consistency is essential. Do not add a dependency solely to eliminate minor duplication.

For substantial custom dependencies, explain the helper's purpose when unclear, why the dependency exists, important
side effects, platform limitations, and significant external dependencies in implementation comments or documentation.
Do not require verbose commentary for trivial calls or change existing comment-based help conventions.

Judge architecture by ease of understanding, troubleshooting and modification, predictability, testability, reliability,
compatibility, security, and appropriate reuse. Function count, reuse percentage, and total line count alone are not
quality measures. The goal is to remove unnecessary complexity while retaining valuable helpers.

Preserve public commands, parameter binding, aliases, output schemas, and compatibility contracts. Architecture guidance
does not authorize API changes or bulk rewrites; use the existing deprecation and migration process for breaking changes.

### Keldor Application

Preserve Windows, Linux, and macOS compatibility and the declared Windows PowerShell 5.1 parser baseline. Retain the
canonical platform helper and bootstrap boundary where they provide compatibility or loading value. Platform-specific
helpers must provide meaningful value; avoid unnecessary abstraction around native commands. Keep build-time tooling
separate from runtime modules and preserve the existing fleet, remoting, input/output, security, and testing contracts.

## Function Design

Use this layout for most public functions:

```powershell
function Get-KeldorThing {
    <#
    .SYNOPSIS
        Gets a Keldor thing.

    .DESCRIPTION
        Gets a Keldor thing from the specified path.

    .PARAMETER Path
        Specifies the path to inspect.

    .EXAMPLE
        Get-KeldorThing -Path .

        Gets a Keldor thing from the current directory.

    .OUTPUTS
        Keldor.Thing

    .LINK
        https://docs.keldor.dev/powershell/keldor/Get-KeldorThing
    #>
    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Get-KeldorThing')]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Path
    )

    process {
        # Function logic goes here.
    }
}
```

## Comment-Based Help

Keldor uses a lean default comment-help format.

Required for public functions:

- `.SYNOPSIS`
- `.DESCRIPTION`
- `.PARAMETER`
- `.EXAMPLE`
- `.OUTPUTS`
- `.LINK`

Optional only when useful:

- `.INPUTS`
- `.NOTES`

Discouraged by default:

- `.COMPONENT`
- `.FUNCTIONALITY`
- `.ROLE`
- `.FORWARDHELPTARGETNAME`
- `.FORWARDHELPCATEGORY`
- `.REMOTEHELPRUNSPACE`
- `.EXTERNALHELP`
- Author
- Created date
- Last modified date
- Version
- Requirements

Git tracks authorship and history. Module manifests track module metadata. `#Requires` belongs at the top of scripts when needed, not buried in help text.

## HelpUri and Links

Public functions should include a `HelpUri` in `[CmdletBinding()]`.

The `HelpUri` value should match the `.LINK` value.

Format:

```text
https://docs.keldor.dev/powershell/keldor/<FunctionName>
```

Example:

```powershell
function Get-KeldorThing {
    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Get-KeldorThing')]
    param()
}
```

## Begin, Process, End, and Clean Blocks

Do not create empty lifecycle blocks.

Use `process` for most functions.

Use `begin` only for initialization.

Use `end` only for cleanup, aggregation, or final output.

Use `clean` only for cleanup that must run when a pipeline is stopped early, and only when the compatibility target
supports the `clean` block.

Avoid:

```powershell
begin {}
process {}
end {}
```

## CmdletBinding

Use `[CmdletBinding()]` for public functions.

Use `SupportsShouldProcess` when a command makes a meaningful external or persistent state change. This includes
creating or registering resources, modifying configuration, installing software, copying or restoring data, joining
systems, mounting resources, repairing or updating systems, restarting or stopping services, and synchronization that
changes either side. The decision is based on behavior, not the cmdlet verb; read-only `Import`, `Save`, or `Copy`
commands do not need `ShouldProcess` merely because of their names.

```powershell
function Remove-KeldorThing {
    [CmdletBinding(
        SupportsShouldProcess = $true,
        ConfirmImpact = 'Medium',
        HelpUri = 'https://docs.keldor.dev/powershell/keldor/Remove-KeldorThing'
    )]
    param()
}
```

Read-only commands should not implement `ShouldProcess`.

Use `ConfirmImpact = 'Low'` for routine reversible changes, `Medium` for meaningful changes that deserve user
awareness, and `High` for destructive or difficult-to-reverse operations. Reserve `High` for operations where the
default confirmation prompt is warranted.

Call `ShouldProcess` immediately before the state change. Use a concise target that identifies the affected resource
and an action phrase that describes the operation:

```powershell
if ($PSCmdlet.ShouldProcess($Path, 'Remove Keldor thing')) {
    Remove-Item -Path $Path -Force
}
```

Under `-WhatIf`, the state-changing operation must not run. Under `-Confirm`, each meaningful operation should provide
an understandable prompt. Avoid prompts for discovery, validation, and other read-only work.

When calling a nested command that supports `ShouldProcess`, prevent duplicate prompts by guarding the operation in the
outer command and using `-Confirm:$false` for the nested call. Forward `-WhatIf` only when the outer command intentionally
delegates the decision instead of making its own `ShouldProcess` call.

## Parameter Design

Use this parameter attribute order:

1. `[Parameter()]`
2. `[Alias()]`, when applicable
3. Validation attributes
4. Type
5. Variable name
6. Default value, if needed

Example:

```powershell
[Parameter(Mandatory = $true, Position = 0)]
[ValidateNotNullOrEmpty()]
[string]$Path
```

Prefer named parameter options with spaces around `=`:

```powershell
Mandatory = $true
```

Avoid:

```powershell
Mandatory=$true
```

### Standard Parameter Aliases

| Canonical Parameter | Standard Aliases | Notes |
|---|---|---|
| `ComputerName` | `HostName`, `DnsHostName`, `Name` | Reduce aliases when they conflict with command semantics. Preserve established legacy aliases for compatibility. |
| `Credential` | `Cred` | Use only when credentials are accepted. |
| `InputObject` | `Input` | Use for pipeline-friendly object input. |
| `Path` | None by default | Add `LiteralPath` separately when literal behavior is needed. |

### ComputerName Pattern

For new fleet and remote functions, follow the canonical pattern in the
[Input & Output Standard](Keldor_Input_Output_Standard.md#canonical-target-parameters). Existing local-default commands
may retain an optional parameter and legacy aliases when changing them would be breaking.

```powershell
[Parameter(
    Mandatory = $true,
    ValueFromPipeline = $true,
    ValueFromPipelineByPropertyName = $true
)]
[Alias('HostName', 'DnsHostName', 'Name')]
[ValidateNotNullOrEmpty()]
[string[]]$ComputerName
```

## Pipeline Design

Support pipeline input when it makes the command more useful and predictable.

Use `ValueFromPipeline` for full object input.

Use `ValueFromPipelineByPropertyName` when matching common property names such as `ComputerName`, `Name`, or `Path`.

Pipeline-aware functions should generally use a `process` block.

Fleet and infrastructure commands are governed by the
[Fleet and Infrastructure Contract](Keldor_Input_Output_Standard.md#fleet-and-infrastructure-contract), including
canonical target parameters, parameter sets, concurrency, timeout and retry semantics, normalized result types,
per-target failure behavior, and compatibility requirements.

## Object and Output Design

Commands should return objects, not formatted text.

Use PascalCase property names.

Use consistent property names across commands.

Prefer `ComputerName` over mixing `Computer`, `Comp`, and `Host` in output objects.

Defined public fleet contracts must use an intentional property order and stable Keldor `PSTypeName`. Keep native
values as native types and put units in property names rather than display strings. See the
[Input & Output Standard](Keldor_Input_Output_Standard.md#canonical-output-property-naming-rules) for the normative
rules and result contracts.

### Object Property Order

Use this order when practical:

1. Identity: `ComputerName`, `Name`, `Id`
2. Classification: `Type`, `Category`, `Source`
3. Configuration: paths, settings, options
4. Measurements: counts, sizes, durations
5. State: `Status`, `IsEnabled`, `IsRunning`, `IsInstalled`
6. Diagnostics: event-specific timestamps, `Error`, `Warning`, `Message`

Example:

```powershell
[pscustomobject]@{
    PSTypeName   = 'Keldor.Network.Interface'
    ComputerName = $ComputerName
    Name         = $Name
    Id           = $Id
    IPAddress    = $IPAddress
    MacAddress   = $MacAddress
    Status       = $Status
    IsUp         = $IsUp
    CheckedAt    = Get-Date
}
```

Boolean output properties should read naturally as Boolean values: `IsEnabled`, `IsAvailable`, `IsInstalled`,
`HasChanges`, or `CanRestart`. Existing public properties must be preserved when renaming would break consumers. Add the
canonical property alongside the legacy property, test both, document the compatibility property, and remove it only in
a planned major-version migration.

Timestamp properties must identify the recorded event. Prefer names such as `CreatedAt`, `UpdatedAt`, `CheckedAt`,
`DiscoveredAt`, `InstalledAt`, `StartedAt`, `CompletedAt`, and `LastSeenAt`; avoid `Timestamp`, `Date`, and `Time`.
Return `[datetime]` values by default or `[datetimeoffset]` when timezone and transport semantics matter. Do not format a
timestamp as a string unless the public output contract explicitly requires a string.

Use `[pscustomobject]` and `[ordered]` for new structured output. Preserve older object construction only when a tested
public contract requires incremental migration.

## Error Handling

Use terminating errors when execution cannot safely continue.

Use non-terminating errors when processing can continue for other input objects.

Avoid empty `catch` blocks.

If returning fallback objects from `catch`, include enough diagnostic context to explain the failure.

### Error and Message Matrix

| Mechanism | Use When |
|---|---|
| `Write-Verbose` | Diagnostic information useful during normal troubleshooting. |
| `Write-Debug` | Developer-focused troubleshooting details. |
| `Write-Information` | User-facing informational stream output. |
| `Write-Warning` | Recoverable concern that may affect results. |
| `Write-Error` | Non-terminating error for one item while continuing. |
| `throw` | Terminating error when execution cannot safely continue. |

## Logging and Messaging

Avoid `Write-Host` in reusable functions unless direct host output is the purpose of the command.

Do not log secrets, tokens, passwords, connection strings, private keys, or sensitive environment details.

## Security

Security-sensitive code should:

- Validate input paths, names, filters, registry keys, and command arguments
- Avoid `Invoke-Expression`
- Avoid shell injection
- Quote external process arguments carefully
- Use least privilege
- Avoid storing secrets in files or source code
- Avoid writing sensitive data to logs
- Prefer explicit allow lists over broad matching when practical

## Cross-Platform Development

New commands should be cross-platform unless inherently platform-specific.

Use:

```powershell
Join-Path
```

instead of string-building paths.

Avoid hardcoded path separators.

Place platform-specific public commands under the matching platform folder:

```text
Public/Common
Public/Windows
Public/macOS
Public/Linux
```

Windows-only commands should avoid pretending to be cross-platform. Say what they are. No trench coat required.

## Performance

Prefer `foreach` over `ForEach-Object` for in-memory collections when readability and performance matter.

Avoid `+=` on arrays inside loops for large collections.

Cache expensive lookups.

Stream output when practical instead of accumulating large arrays.

Filter as close to the data source as practical.

## Testing

Every public command should eventually have Pester tests.

Tests should cover:

- Successful operation
- Invalid input
- Missing dependencies
- Platform assumptions
- Security-sensitive behavior
- Error paths

## Documentation Standards

Every public cmdlet should eventually have:

- Comment-based help
- `HelpUri`
- Function-specific documentation page
- At least one example
- Pester tests
- Changelog entry for behavior changes

## Repository Standards

PowerShell repositories should include:

- `.editorconfig`
- `.gitattributes`
- `.gitignore`
- `.markdownlint.json`
- `.markdownlintignore`
- `README.md`
- `CHANGELOG.md`
- `CONTRIBUTING.md`
- `SECURITY.md`
- `LICENSE`
- `PSScriptAnalyzerSettings.psd1`
- `.github/workflows/`

Run the checked-in formatter configuration with:

```powershell
Get-ChildItem -Path ./src -Recurse -File -Include *.ps1, *.psm1, *.psd1 |
    ForEach-Object {
        $Content = Get-Content -LiteralPath $_.FullName -Raw
        $Formatted = Invoke-Formatter -ScriptDefinition $Content -Settings ./PSScriptAnalyzerSettings.psd1
        Set-Content -LiteralPath $_.FullName -Value $Formatted -NoNewline
    }
```

## Deprecation Policy

Do not remove public commands without a transition plan.

When behavior changes:

1. Document the replacement.
2. Add warnings when appropriate.
3. Update docs and changelog.
4. Remove only in a major version when practical.

## Legacy Modernization Policy

Existing legacy functions do not need to be rewritten only for style.

When touching a legacy function, modernize nearby code when practical:

- Remove author/date metadata from `.NOTES`
- Normalize `HelpUri` and `.LINK`
- Normalize spacing around `=`
- Prefer lowercase `param`
- Remove excessive blank lines
- Replace end-of-block comments like `}#foreach` when they add no value
- Improve output property consistency
- Add `ShouldProcess` to modifying functions

## Code Review Checklist

Reviewers should ask:

- Can a developer new to the repository understand the operation from the public source file?
- Does each helper, wrapper, or dispatcher provide meaningful value, with non-obvious exceptions documented?
- Are custom call paths three or more layers deep reviewed for distinct responsibilities rather than rejected by depth?
- Is reuse justified by complexity, consistency, security, or maintenance rather than line count alone?
- Are meaningful orchestration, dependency purposes, and public compatibility contracts preserved?

- Does the function use an approved verb?
- Does it use the Keldor function layout?
- Does it include lean comment-based help?
- Does `HelpUri` match `.LINK`?
- Are parameters named and ordered consistently?
- Are inputs validated?
- Does it return objects instead of formatted text?
- Are output properties consistent with similar commands?
- Does a modifying command support `ShouldProcess`?
- Are secrets avoided?
- Are platform assumptions clear?
- Are tests included or planned?
- Is documentation updated?
- Is the changelog updated for behavior changes?

## Future Enforcement

`Keldor.Build.PowerShell` should eventually provide automated checks such as:

- `Test-KeldorEngineeringStandard`
- `Test-KeldorRepository`
- `Test-KeldorDocumentation`
- `Test-KeldorCommentHelp`
- `Test-KeldorHelpUri`
- `Test-KeldorNaming`
- `Test-KeldorCompatibility`
- `Test-KeldorSecurity`
- `Test-KeldorPerformance`
- `Test-KeldorStyle`

Architecture and call-depth judgments require contextual review; automated findings must not become arbitrary depth
limits. Other objective standards should become enforceable through tooling.
