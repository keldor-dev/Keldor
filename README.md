# Keldor

[![PowerShell Gallery Version](https://img.shields.io/powershellgallery/v/Keldor?label=PowerShell%20Gallery)](https://www.powershellgallery.com/packages/Keldor)
[![PowerShell Gallery Downloads](https://img.shields.io/powershellgallery/dt/Keldor?label=Downloads)](https://www.powershellgallery.com/packages/Keldor)
[![PSScriptAnalyzer](https://github.com/keldor-dev/Keldor/actions/workflows/powershell.yml/badge.svg)](https://github.com/keldor-dev/Keldor/actions/workflows/powershell.yml)
[![DevSkim](https://github.com/keldor-dev/Keldor/actions/workflows/devskim.yml/badge.svg)](https://github.com/keldor-dev/Keldor/actions/workflows/devskim.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://github.com/keldor-dev/Keldor/blob/master/LICENSE)

![Keldor Logo](src/Keldor/Resources/keldor-logo.png)

Keldor is a PowerShell automation toolkit for systems administration, help desk operations, and enterprise engineering workflows.

## Why Keldor

- 330+ automation-focused functions
- Active Directory and infrastructure operations support
- Platform-aware loading for Windows, macOS, and Linux
- Utility functions for remediation, reporting, and conversions
- Reusable snippets and helper tooling for day-to-day admin work

## Quick Start

### Prerequisites

1. Windows PowerShell 5.1 on a Microsoft-supported Windows version, or a Microsoft-supported PowerShell 7 release
   beginning with PowerShell 7.4
2. Optional modules/features based on function usage:
   - ActiveDirectory module
   - NetIQ DRA PowerShell REST Extensions
   - LAPS (AdmPwd.PS)
   - Microsoft.Exchange.Management.PowerShell.Admin (for Exchange-specific commands)

### Install

Install for all users:

```powershell
Install-Module Keldor
```

Install for current user only:

```powershell
Install-Module Keldor -Scope CurrentUser
```

## Configuration

### Secret retrieval

Use `Get-KeldorSecret` or its `Get-KDSecret` alias to retrieve plaintext secrets through Keldor's provider abstraction. The default `Auto` provider tries OnePassword CLI, Microsoft.PowerShell.SecretManagement, and `KELDOR_SECRET_<NAME>` environment variables in that order.

Use `Set-KeldorSecret` or its `Set-KDSecret` alias to write secrets through the same provider model. Writes use one selected provider only; the Environment provider writes process-scoped variables that disappear when the process exits.

Use `Remove-KeldorSecret` or its `Remove-KDSecret` alias to remove a secret from one selected provider. Environment removals affect only the current process and do not remove values configured outside the current PowerShell process.

Use `Get-KeldorSecretProvider` or its `Get-KDSecretProvider` alias to inspect the secret providers known to Keldor, their auto-selection priority, and non-sensitive availability details.

Use `Test-KeldorSecretProvider` or its `Test-KDSecretProvider` alias to run safe, read-only operational checks against one or more providers without retrieving, creating, modifying, or removing secrets.

### Initial configuration

Run the config command and update values for your environment:

```powershell
Set-WSToolsConfig
```

The command name is retained for backward compatibility. It opens the Keldor config file so you can tune paths and environment-specific settings.

### Remote patch settings

For remote `.msu` installation workflows, edit `InstallRemote.ps1` in your installed module path and set `$PatchFolderPath` to your remote patch directory.

## Platform-Aware Loading

Keldor loads functions based on the OS importing the module:

- `Common` functions load on all platforms
- `Windows` functions load only on Windows
- `macOS` functions load only on macOS
- `Linux` functions load only on Linux

If platform detection returns `Unknown`, Keldor loads the Common command layer only. Unsupported PowerShell editions
and versions fail module import before configuration or command loading.

## PowerShell Compatibility

Keldor supports Windows PowerShell 5.1 on Windows versions that remain supported by Microsoft. Keldor also supports
Microsoft-supported PowerShell 7 release lines beginning with PowerShell 7.4. Retired PowerShell releases are not
supported. PowerShell 7.6 LTS is the preferred development, automation, and CI runtime.

The current tested Core lines are PowerShell 7.4, 7.5, and 7.6. This list is lifecycle-bound, not permanent. See the
[compatibility policy](docs/compatibility.md) and
[lifecycle review policy](docs/development/powershell-lifecycle-policy.md).

### Module folder structure

```text
Public/
  Common/
  Windows/
  macOS/
  Linux/
Private/
  Common/
  Windows/
  macOS/
  Linux/
```

Functions in `Public` are exported. Functions in `Private` are internal helpers and are not exported.

## Cross-Platform System Information

Use `Get-KeldorSystemInfo` for a normalized local inventory object, or use its focused feeder commands independently:

```powershell
Get-KeldorSystemInfo
Get-KeldorOperatingSystem
Get-KeldorLinuxDistribution
Get-KeldorKernel
Get-KeldorUptime
Get-KeldorHardwareInfo
```

The commands return structured objects with native dates, durations, numbers, and stable Keldor type names. They also
support configured PowerShell-remoting targets and reusable `PSSession` objects. See the
[system-information architecture](docs/architecture/system-information.md) for contracts and remote limitations.

## Acronym Catalog

Search, retrieve, count, and export the bundled acronym catalog with `Find-KeldorAcronym`, `Get-KeldorAcronym`, and
`Export-KeldorAcronym`. Supplemental JSON catalogs can be included without collapsing alternate meanings. See the
[acronym command guide](docs/acronyms.md).

## Remote Command Orchestration

Use `Invoke-KeldorCommand` as Keldor's canonical local and remote execution entry point:

```powershell
Invoke-KeldorCommand -Local -ScriptBlock { Get-KeldorSystemInfo }

'server01', 'server02' |
    Invoke-KeldorCommand -ScriptBlock { Get-KeldorSystemInfo }
```

It supports local execution, caller-owned `PSSession` reuse, WSMan through `ComputerName`, and PowerShell remoting over
SSH through `HostName` on supported PowerShell 7 runtimes. Structured per-target results are the default; `RawOutput`
is opt-in. Keldor does not enable remoting, configure SSH or firewalls, modify TrustedHosts, persist credentials, or
install Keldor remotely. See the
[remote command orchestration architecture](docs/architecture/remote-command-orchestration.md).

## Adding Functions

- Add cross-platform exported functions to `Public/Common`
- Add Windows-only exported functions to `Public/Windows`
- Add macOS-only exported functions to `Public/macOS`
- Add Linux-only exported functions to `Public/Linux`
- Add internal helpers to matching `Private/*` folders
- Follow the [Keldor PowerShell Engineering Standard](docs/standards/Keldor_PowerShell_Engineering_Standard.md)

## Build Tooling

Reusable build implementation is maintained in `Keldor.Build.PowerShell`. This repository keeps only
`build.config.psd1` and a thin `build.ps1` entry point. Install the pinned build dependency, then build from the
repository root:

```powershell
Install-Module Keldor.Build.PowerShell -RequiredVersion 0.2.0 -Scope CurrentUser
./build.ps1 -Task Build
```

The build dependency is not a runtime dependency and is excluded from the published Keldor package. See
[Local Development](docs/development/local-build.md) for the explicit unpublished-module override.

## Visual Studio Code Snippets

To load Keldor PowerShell snippets, run:

```powershell
Set-PowerShellJSON
```

Or manually copy `powershell.json` from the module folder into your user snippets location.

Workspace snippets are also available in `.vscode/Keldor.code-snippets` when this repository is open in VS Code.

## Documentation

- [Engineering Standards](docs/standards/README.md)
- [Keldor General Engineering Standard](docs/standards/Keldor_General_Engineering_Standard.md)
- [Keldor PowerShell Engineering Standard](docs/standards/Keldor_PowerShell_Engineering_Standard.md)
- [Versioning Policy](docs/development/versioning-policy.md)
- [Release Process](docs/development/release-process.md)
- [Canonical Publishing Runbook](https://github.com/keldor-dev/Keldor.Build.PowerShell/blob/main/docs/publishing/keldor-release.md)
- [PowerShell Compatibility](docs/compatibility.md)
- [PowerShell Lifecycle Review](docs/development/powershell-lifecycle-policy.md)
- [Cross-Platform System Information](docs/architecture/system-information.md)
- [Remote Command Orchestration](docs/architecture/remote-command-orchestration.md)
- [Acronym Commands](docs/acronyms.md)
- Docs site: https://docs.keldor.dev
- Repository: https://github.com/keldor-dev/Keldor

## Issues and Requests

Open an issue for bugs, requests, or ideas:

https://github.com/keldor-dev/Keldor/issues
