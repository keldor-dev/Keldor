# Local Development

## Requirements

- PowerShell 7.x (recommended)
- Windows PowerShell 5.1 (supported)
- Git

Optional:

- Pester
- PSScriptAnalyzer

## Clone

```powershell
git clone https://github.com/keldor-dev/Keldor.git
```

## Import

```powershell
Import-Module .\Keldor.psd1 -Force
```

## Verify

```powershell
Get-Command -Module Keldor
```

## Documentation

Online documentation is maintained separately in the `keldor-dev/docs` repository which links to:

https://docs.keldor.dev

## Platform Testing

Verify imports on:

- Windows
- Linux
- macOS

where possible.

## Optional Validation

If available:

- Run Pester
- Run PSScriptAnalyzer

These tools are optional and are not required for development.
