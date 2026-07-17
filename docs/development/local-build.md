# Local Development

## Requirements

- PowerShell 7.6 LTS (preferred for build, formatting, documentation, and primary tests)
- Windows PowerShell 5.1 on a supported Windows version (production compatibility testing)
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

## Build

From the repository root, create a local build:

```powershell
./build.ps1 -Task Build
```

Release packages require an explicit semantic version:

```powershell
./build.ps1 -Task Release -Version '0.1.0'
```

See the [Versioning Policy](versioning-policy.md) for release version selection.

## Documentation

Online documentation is maintained separately in the `keldor-dev/docs` repository which links to:

https://docs.keldor.dev

## Platform Testing

Verify imports on:

- Windows
- Linux
- macOS

where possible.

## Validation Strategy

Run the full Pester and PSScriptAnalyzer validation under PowerShell 7.6. Run manifest validation, actual module import,
shared-file parsing, and compatible smoke tests under Windows PowerShell 5.1. The test harness may use different Pester
versions on the two runtimes; Windows PowerShell 5.1 coverage must not be silently skipped.

PowerShell 7.4 and 7.5 are compatibility lines only while they remain in Keldor's documented matrix. See the
[compatibility policy](../compatibility.md).
