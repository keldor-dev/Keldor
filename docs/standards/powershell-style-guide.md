# Keldor PowerShell Style Guide

## Purpose

This guide defines the preferred PowerShell style for Keldor projects.

The goal is to keep Keldor code secure, readable, maintainable, and practical across Windows PowerShell and modern PowerShell versions.

## Priorities

Keldor PowerShell code should prioritize:

1. Security
2. Reliability
3. Readability
4. Maintainability
5. Portability
6. Performance

## Compatibility

PowerShell 7+ is the preferred runtime for new development.

Windows PowerShell 5.1 should be supported where practical.

PowerShell 2.0 compatibility may be preserved when it does not weaken security, correctness, readability, or maintainability.

## Function Layout

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
        https://docs.keldor.dev
    #>
    [CmdletBinding()]
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

Documentation should communicate what the user needs to know, not fill every possible PowerShell help field.

### Required for Public Functions

Use these sections by default:

- `.SYNOPSIS`
- `.DESCRIPTION`
- `.PARAMETER`
- `.EXAMPLE`
- `.OUTPUTS`
- `.LINK`

### Optional

Use these only when they add real value:

- `.INPUTS`
- `.NOTES`

`.INPUTS` is useful when pipeline behavior matters.

`.NOTES` is useful for operational caveats, compatibility warnings, security considerations, or unusual behavior.

Good `.NOTES` example:

```powershell
.NOTES
    This function avoids PowerShell 7-only syntax to preserve Windows PowerShell 5.1 compatibility.
```

### Discouraged by Default

Do not include these sections unless there is a specific tooling or documentation reason:

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

Git tracks authorship and history. The module manifest tracks module metadata. `#Requires` belongs at the top of a script when needed, not buried in help text.

## Begin, Process, and End Blocks

Do not create empty lifecycle blocks.

Prefer this for most functions:

```powershell
process {
    # Main logic
}
```

Use `begin` only when initialization is needed.

Use `end` only when cleanup, aggregation, or final output is needed.

Avoid this:

```powershell
begin {}
process {}
end {}
```

Empty blocks add noise and make functions harder to scan.

## CmdletBinding

Use `[CmdletBinding()]` for public functions.

Use `SupportsShouldProcess` for destructive or state-changing actions:

```powershell
[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
```

## Parameters

Use this attribute order:

1. `[Parameter()]`
2. Validation attributes
3. Type
4. Variable name
5. Default value, if needed

Example:

```powershell
[Parameter(Mandatory = $true)]
[ValidateNotNullOrEmpty()]
[string]$Path
```

Use named parameter options for clarity:

```powershell
[Parameter(Mandatory = $true, Position = 0)]
```

Avoid unclear positional-only behavior.

## Approved Verbs

Public function names must use approved PowerShell verbs.

Use:

```powershell
Get-Verb
```

when choosing a verb.

## Output

Functions should emit objects, not formatted text.

Prefer typed objects or objects with a meaningful `PSTypeName`:

```powershell
[pscustomobject]@{
    PSTypeName = 'Keldor.Thing'
    Name       = $Name
    Path       = $Path
}
```

For PowerShell 2.0-compatible code, use `New-Object PSObject` with `Add-Member`.

## Error Handling

Use terminating errors when execution cannot safely continue.

Prefer:

```powershell
throw "Unable to resolve path '$Path'."
```

Avoid empty catch blocks.

Do not hide errors unless the failure is expected and handled intentionally.

## Logging and Messaging

Use:

- `Write-Verbose` for diagnostic information
- `Write-Debug` for troubleshooting details
- `Write-Warning` for recoverable concerns
- `Write-Error` for non-terminating errors
- `throw` for terminating errors

Avoid `Write-Host` in reusable functions unless directly writing host output is the purpose of the function.

## Security

Do not hardcode secrets.

Avoid unsafe dynamic execution such as `Invoke-Expression`.

Validate user input before using it in paths, commands, filters, or external process arguments.

Do not log credentials, tokens, API keys, connection strings, or sensitive environment details.

## Formatting

Use:

- Four-space indentation
- LF line endings
- UTF-8 encoding
- One final newline
- Clear blank lines between logical sections

Avoid trailing whitespace.
