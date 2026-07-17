# Build and Test Keldor Locally on macOS

This guide explains how to build the Keldor PowerShell module locally on macOS, import it from the local build output, and test commands before publishing or packaging.

## Prerequisites

Install or update to PowerShell 7.6 LTS, the preferred Keldor development and build runtime:

Homebrew is the recommended way to install PowerShell on macOS for most users. It is usually the easiest way to install and keep PowerShell updated.

If PowerShell was installed with Homebrew, update it with:

```bash
brew update
brew upgrade --cask powershell
```

If PowerShell is not installed yet via Homebrew:

```bash
brew install --cask powershell
```

If PowerShell was installed manually (not through Homebrew), update it by downloading the latest macOS `.pkg` from:

https://github.com/PowerShell/PowerShell/

Then run the installer (example):

```bash
sudo installer -pkg ~/Downloads/powershell-7.6.0-osx-x64.pkg -target /
```

Replace the file name with the version and architecture you downloaded.

Verify PowerShell is available:

```bash
pwsh --version
```

### Recommended Developer Modules

For local development, install these modules:

- PSReadLine
- Pester
- PSScriptAnalyzer
- PlatyPS (recommended when working on documentation)

PSReadLine is typically already included with Homebrew-installed PowerShell, but installing it explicitly is safe for developer environments.

Install or update these modules:

```powershell
Install-Module PSReadLine -Scope CurrentUser -Force -SkipPublisherCheck
Install-Module Pester -Scope CurrentUser -Force -SkipPublisherCheck
Install-Module PSScriptAnalyzer -Scope CurrentUser -Force
Install-Module PlatyPS -Scope CurrentUser -Force
```

Verify module availability:

```powershell
Get-Module -ListAvailable PSReadLine, Pester, PSScriptAnalyzer, PlatyPS |
    Select-Object Name, Version, Path |
    Sort-Object Name
```

From PowerShell, confirm the platform:

```powershell
$PSVersionTable
$IsMacOS
```

## Clone the Repository

```bash
git clone https://github.com/keldor-dev/Keldor.git
cd Keldor
```

## Confirm the Module Structure

The module should contain:

```text
src/Keldor/
├── Public/
│   ├── Common/
│   ├── Windows/
│   ├── macOS/
│   └── Linux/
├── Private/
│   ├── Common/
│   ├── Windows/
│   ├── macOS/
│   └── Linux/
├── Keldor.psd1
└── Keldor.psm1
```

On macOS, Keldor should load:

```text
Private/Common
Public/Common
Private/macOS
Public/macOS
```

Windows-only and Linux-only functions should not load.

## Build the Module Locally

Install the exact build dependency first:

```powershell
Install-Module Keldor.Build.PowerShell -RequiredVersion 0.2.0 -Scope CurrentUser
```

From the repository root:

```powershell
./build.ps1 -Task Build
```

The built module is written to `out/Keldor`. Release packages require an explicit semantic version:

```powershell
./build.ps1 -Task Release -Version '0.1.0'
```

To test an unpublished local checkout of the build module, pass it explicitly:

```powershell
./build.ps1 -Task Build -BuildModulePath ../Keldor.Build.PowerShell
```

See the [Versioning Policy](versioning-policy.md) for release version selection.

## Import the Local Build

Remove any previously loaded Keldor module:

```powershell
Remove-Module Keldor -Force -ErrorAction SilentlyContinue
```

Import the module directly from the local build:

```powershell
Import-Module (Join-Path $BuildModule 'Keldor.psd1') -Force -Verbose
```

Verify the module loaded from the local build path:

```powershell
Get-Module Keldor | Select-Object Name, Version, Path
```

## List Available Commands

```powershell
Get-Command -Module Keldor
```

On macOS, this should include Common and macOS commands only.

## Test Platform-Aware Loading

Confirm Keldor detects macOS:

```powershell
Get-Command -Module Keldor | Sort-Object Name
```

If Windows-only commands appear, check that they are located under:

```text
Public/Windows
Private/Windows
```

If macOS commands do not appear, check that they are located under:

```text
Public/macOS
Private/macOS
```

## Run PSScriptAnalyzer

Install PSScriptAnalyzer if needed:

```powershell
Install-Module PSScriptAnalyzer -Scope CurrentUser -Force
```

Run analysis against the source module:

```powershell
Invoke-ScriptAnalyzer -Path ./src/Keldor -Recurse
```

## Run Tests

If the repository has Pester tests:

```powershell
Install-Module Pester -Scope CurrentUser -Force -SkipPublisherCheck
Invoke-Pester ./src/Keldor/Tests
```

If tests are stored elsewhere, run:

```powershell
Get-ChildItem -Path . -Recurse -Directory -Filter Tests
```

Then point `Invoke-Pester` at the correct folder.

## Optional: Add Local Build to PSModulePath

For repeated local testing, add the `out` folder to the current PowerShell session:

```powershell
$env:PSModulePath = "$BuildRoot$([IO.Path]::PathSeparator)$env:PSModulePath"
```

Then import normally:

```powershell
Remove-Module Keldor -Force -ErrorAction SilentlyContinue
Import-Module Keldor -Force
```

Verify the imported path:

```powershell
Get-Module Keldor | Select-Object Name, Path
```

## Clean Rebuild

Use this when switching branches or after major layout changes:

```powershell
Remove-Module Keldor -Force -ErrorAction SilentlyContinue
Remove-Item ./out/Keldor -Recurse -Force -ErrorAction SilentlyContinue
Copy-Item ./src/Keldor ./out/Keldor -Recurse -Force
Import-Module ./out/Keldor/Keldor.psd1 -Force -Verbose
```

## Common Issues

### Module imports but commands are missing

Check that public functions are under one of these folders:

```text
Public/Common
Public/macOS
```

Each function file should usually match the function name:

```text
Get-Something.ps1
```

### macOS-specific functions do not load

Confirm the folder name is exactly:

```text
macOS
```

Not:

```text
MacOS
macos
Mac
```

### Import loads the installed Gallery version instead

Check the module path:

```powershell
Get-Module Keldor | Select-Object Name, Version, Path
```

Import directly from the local build path:

```powershell
Import-Module ./out/Keldor/Keldor.psd1 -Force
```

### Function changes are not appearing

Reload the module:

```powershell
Remove-Module Keldor -Force -ErrorAction SilentlyContinue
Import-Module ./out/Keldor/Keldor.psd1 -Force
```

If needed, rebuild the output folder:

```powershell
Remove-Item ./out/Keldor -Recurse -Force
Copy-Item ./src/Keldor ./out/Keldor -Recurse -Force
```

## Recommended Local Development Loop

```powershell
Remove-Module Keldor -Force -ErrorAction SilentlyContinue
Remove-Item ./out/Keldor -Recurse -Force -ErrorAction SilentlyContinue
Copy-Item ./src/Keldor ./out/Keldor -Recurse -Force
Import-Module ./out/Keldor/Keldor.psd1 -Force
Get-Command -Module Keldor
Invoke-ScriptAnalyzer -Path ./src/Keldor -Recurse
```
