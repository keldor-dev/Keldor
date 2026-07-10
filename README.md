# Keldor

[![PowerShell Gallery Version](https://img.shields.io/powershellgallery/v/Keldor?label=PowerShell%20Gallery)](https://www.powershellgallery.com/packages/Keldor)
[![PowerShell Gallery Downloads](https://img.shields.io/powershellgallery/dt/Keldor?label=Downloads)](https://www.powershellgallery.com/packages/Keldor)
[![PSScriptAnalyzer](https://github.com/keldor-dev/Keldor/actions/workflows/powershell.yml/badge.svg)](https://github.com/keldor-dev/Keldor/actions/workflows/powershell.yml)
[![DevSkim](https://github.com/keldor-dev/Keldor/actions/workflows/devskim.yml/badge.svg)](https://github.com/keldor-dev/Keldor/actions/workflows/devskim.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://github.com/keldor-dev/Keldor/blob/master/LICENSE)

![Keldor Logo](https://github.com/keldor-dev/Keldor/blob/6562686bdf7e852ba74f9805ef1439a7b1096386/src/Keldor/Resources/keldor-logo.png)

Keldor is a PowerShell automation toolkit for systems administration, help desk operations, and enterprise engineering workflows.

## Why Keldor

- 330+ automation-focused functions
- Active Directory and infrastructure operations support
- Platform-aware loading for Windows, macOS, and Linux
- Utility functions for remediation, reporting, and conversions
- Reusable snippets and helper tooling for day-to-day admin work

## Quick Start

### Prerequisites

1. PowerShell 5.1+ (PowerShell 7+ supported for many functions)
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

If platform detection fails, Keldor safely loads only common functions and warns instead of failing module import.

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

## Adding Functions

- Add cross-platform exported functions to `Public/Common`
- Add Windows-only exported functions to `Public/Windows`
- Add macOS-only exported functions to `Public/macOS`
- Add Linux-only exported functions to `Public/Linux`
- Add internal helpers to matching `Private/*` folders
- Follow the [Keldor PowerShell Engineering Standard](docs/standards/Keldor_PowerShell_Engineering_Standard.md)

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
- Docs site: https://docs.keldor.dev
- Repository: https://github.com/keldor-dev/Keldor

## Issues and Requests

Open an issue for bugs, requests, or ideas:

https://github.com/keldor-dev/Keldor/issues
