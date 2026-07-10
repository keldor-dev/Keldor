# Keldor PowerShell Engineering Standard

| Property | Value |
|---|---|
| Version | 1.1 |
| Status | Stable |
| Applies To | All Keldor PowerShell projects |
| Last Updated | 2026-07-10 |

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

### Backward Compatibility Where Practical

PowerShell 7+ is preferred. Windows PowerShell 5.1 should be supported where practical. PowerShell 2.0 compatibility may be preserved only when it does not weaken security, correctness, readability, or maintainability.

### Discoverable

Public commands should include comment-based help, `HelpUri`, examples, and matching documentation pages.

### Consistent

Similar commands should use similar parameter names, aliases, output object shapes, error behavior, and documentation structure.

### Predictable

Commands should avoid hidden side effects. State-changing commands should support `-WhatIf` and `-Confirm` through `ShouldProcess`.

### Composable

Commands should work well in the pipeline and return objects suitable for filtering, exporting, and further automation.

## Compatibility Targets

Preferred runtime:

- PowerShell 7+

Supported where practical:

- Windows PowerShell 5.1
- Windows PowerShell 2.0

PowerShell 2.0 compatibility is a compatibility goal, not a veto over secure or maintainable design.

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

| Feature | PowerShell 2.0 | Windows PowerShell 5.1 | PowerShell 7+ | Guidance |
|---|:---:|:---:|:---:|---|
| Advanced functions | Yes | Yes | Yes | Use for public commands. |
| Classes | No | Yes | Yes | Avoid in broadly compatible code. |
| Enums | No | Yes | Yes | Avoid when PS2 compatibility matters. |
| `[pscustomobject]` | Limited | Yes | Yes | Prefer for modern code; use `New-Object PSObject` for PS2-compatible code. |
| CIM cmdlets | No | Yes | Yes | Prefer CIM when PS2 compatibility is not required. |
| WMI cmdlets | Yes | Yes | Windows compatibility varies | Use for legacy Windows compatibility; treat as legacy. |
| `ForEach-Object -Parallel` | No | No | Yes | Avoid in shared module code unless explicitly PS7-only. |
| Ternary operator | No | No | Yes | Avoid in shared code. |
| Null-coalescing operators | No | No | Yes | Avoid in shared code. |
| `using namespace` | No | Yes | Yes | Avoid in broadly compatible module code. |
| `$IsWindows`, `$IsLinux`, `$IsMacOS` | No | No | Yes | Use compatibility helpers when targeting Windows PowerShell. |

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
| `ComputerName` | `Host`, `Name`, `Computer`, `CN` | Use for remote/system-targeting Windows functions. |
| `Credential` | `Cred` | Use only when credentials are accepted. |
| `InputObject` | `Input` | Use for pipeline-friendly object input. |
| `Path` | None by default | Add `LiteralPath` separately when literal behavior is needed. |

### ComputerName Pattern

For Windows remote/admin functions, prefer:

```powershell
[Parameter(Position = 0, ValueFromPipelineByPropertyName = $true)]
[Alias('Host', 'Name', 'Computer', 'CN')]
[ValidateNotNullOrEmpty()]
[string[]]$ComputerName = $env:COMPUTERNAME
```

## Pipeline Design

Support pipeline input when it makes the command more useful and predictable.

Use `ValueFromPipeline` for full object input.

Use `ValueFromPipelineByPropertyName` when matching common property names such as `ComputerName`, `Name`, or `Path`.

Pipeline-aware functions should generally use a `process` block.

## Object and Output Design

Commands should return objects, not formatted text.

Use PascalCase property names.

Use consistent property names across commands.

Prefer `ComputerName` over mixing `Computer`, `Comp`, and `Host` in output objects.

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

For PowerShell 2.0-compatible code, use:

```powershell
$Object = New-Object PSObject
$Object | Add-Member -MemberType NoteProperty -Name PSTypeName -Value 'Keldor.TypeName'
$Object | Add-Member -MemberType NoteProperty -Name ComputerName -Value $ComputerName
$Object
```

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

The standard should become enforceable through tooling, not just inspirational wall art.
