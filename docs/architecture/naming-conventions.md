# Naming Conventions

## Philosophy

Keldor follows Microsoft's PowerShell design guidelines wherever practical. Commands should be predictable, discoverable, and consistent across the module.

## Functions

- Use approved PowerShell verbs.
- Prefer singular nouns.
- Avoid abbreviations unless they are industry standard.
- Use PascalCase.

Examples:

```powershell
Get-ComputerModel
Get-BIOSInformation
Set-RegistryValue
Test-IsAdministrator
```

Avoid:

```powershell
Get-PCModel
Do-Thing
RunStuff
```

## Private Functions

Private helper functions follow the same naming conventions as public functions.

Private functions:

- Are stored under `Private/`
- Are never exported
- May be prefixed with `Internal` when appropriate

Examples:

```powershell
Get-KeldorPlatform
Resolve-ModuleRoot
Test-WindowsRegistry
```

## Variables

Use descriptive PascalCase variable names.

Good:

```powershell
$ComputerName
$OperatingSystem
$ModuleRoot
```

Avoid unnecessary abbreviations.

## Parameters

- Use full descriptive names.
- Prefer common PowerShell parameter names.
- Support pipeline input where appropriate.

## Files

One function per file.

The filename should exactly match the function name.

Example:

```text
Public/Common/
    Get-ComputerModel.ps1

Private/Common/
    Get-KeldorPlatform.ps1
```

## Classes

Classes use PascalCase.

```text
ComputerInventory
ModuleConfiguration
```

## Enums

Enums use PascalCase with descriptive values.

## Documentation

Every public function should include:

- Comment-based help
- `.SYNOPSIS`
- `.DESCRIPTION`
- `.PARAMETER`
- `.EXAMPLE`
- `.LINK`
- `HelpUri`

The `.LINK` and `HelpUri` should both reference the same documentation page.

## Cross-Platform Naming

Avoid Windows-specific terminology in Common functions whenever possible.

Prefer:

```powershell
Get-OperatingSystem
```

over:

```powershell
Get-WindowsVersion
```

unless the command is intentionally Windows-only.
