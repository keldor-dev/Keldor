# PowerShell Runtime Compatibility Migration Audit

| Property | Value |
|---|---|
| Status | Active implementation record |
| Audited | 2026-07-16 |
| Scope | Keldor source, tests, build, CI, documentation, templates, snippets, and generated configuration sources |
| Target | Windows PowerShell 5.1 and supported PowerShell 7 release lines beginning with 7.4 |

## Purpose

This report records the compatibility workarounds and runtime assumptions found before the PowerShell baseline was
raised. It is the migration record for the breaking compatibility change; historical references in this document are
intentional and must not be interpreted as current support claims.

The audit covered PowerShell, manifest, JSON, YAML, Markdown, XML, C#, and type/format data extensions. Production
PowerShell files were also parsed with the available PowerShell parser. The initial audit found 322 production
PowerShell files and no parser errors under PowerShell 7.5.2. Actual Windows PowerShell 5.1 parsing and import remain CI
requirements because a PowerShell 7 parser cannot prove 5.1 compatibility.

## Classification Summary

| Finding | Affected files | Classification | Rationale and action |
|---|---|---|---|
| Manifest minimum was PowerShell 3.0 | `src/Keldor/Keldor.psd1` | Modernize | Set the numeric minimum to 5.1 and declare Desktop and Core editions. Add a runtime guard because manifest version comparison alone cannot reject Core 6.x or Core 7.0-7.3. |
| Root loader required PowerShell 3 and used recursive, unsorted discovery | `src/Keldor/Keldor.psm1` | Modernize | Raise the requirement to 5.1, validate the runtime first, load only intended direct children in stable order, and make required load failures terminating. |
| Configuration and classes ran as `ScriptsToProcess` before root-module validation | `src/Keldor/Keldor.psd1`, `src/Keldor/config.ps1`, `src/Keldor/classes.ps1` | Modernize | Remove `ScriptsToProcess`; load configuration and classes from the root module after runtime validation. |
| Runtime exports and manifest exports both used broad behavior | `src/Keldor/Keldor.psd1`, `src/Keldor/Keldor.psm1` | Modernize | Use explicit manifest export metadata and one runtime export step for commands actually loaded on the current platform. |
| Runtime/platform detection included `RuntimeInformation`, environment platform IDs, and WMI fallbacks | `src/Keldor/Public/Common/Get-KeldorPlatform.ps1` | Remove | These branches existed to keep PowerShell 2.0/3.0 working. Use the Desktop-edition Windows rule and supported Core automatic platform variables. |
| Loader called an exported function to select platform folders | `src/Keldor/Keldor.psm1`, `src/Keldor/Public/Common/Get-KeldorPlatform.ps1` | Modernize | Introduce a minimal private bootstrap detector used by both the loader and public canonical API. This removes the circular foundation dependency. |
| Windows system inventory fell back to WMI when CIM was absent | `src/Keldor/Private/Windows/Get-KeldorWindowsManagementObject.ps1`, `src/Keldor/Private/Windows/Get-KeldorWindowsSystemSnapshot.ps1` | Remove | `Get-CimInstance` exists in the Windows PowerShell 5.1 baseline. The old fallback existed for pre-CIM runtimes. |
| System snapshots substituted Desktop when `PSEdition` was missing | `src/Keldor/Private/Common/New-KeldorSystemSnapshot.ps1` | Remove | Every supported runtime exposes `PSEdition`; the fallback existed for obsolete Windows PowerShell versions. |
| Classes documentation and implementation referenced the PowerShell 2.0 object model | `src/Keldor/classes.ps1` | Modernize | Remove the obsolete support claim. The class itself already requires PowerShell 5.1 syntax. |
| Global configuration and Keldor object state | `src/Keldor/config.ps1`, `src/Keldor/classes.ps1`, configuration-consuming public commands | Requires manual review | The state predates the loader and is used by many public commands. It is retained for this compatibility change to avoid redesigning configuration semantics. Remaining global state is documented technical debt; no new global state is introduced. |
| `New-Object PSObject`/`Add-Member` object construction | `Get-PowerShellVariable.ps1`, `Get-ADComplianceReport.ps1`, `Get-FileMetaData.ps1`, `Get-PrivilegedGroup.ps1`, `classes.ps1` | Requires manual review | These patterns are not all proven to exist solely for PowerShell 2.0. Preserve public property order and behavior until each output contract is tested; new templates use `[pscustomobject]`. |
| WMF 3/4/5 configuration placeholders and example paths | `src/Keldor/config.ps1`, `src/Keldor/Examples/config_example.ps1` | Remove | They advertise obsolete runtime installation inputs and are unused by the supported loader. |
| PowerShell 2.0/3.0 templates and snippet entries | `docs/standards/powershell/templates/README.md`, `.vscode/Keldor.code-snippets`, `src/Keldor/Resources/powershell.json` | Remove | Templates must target the shared Windows PowerShell 5.1 parser baseline and must not generate legacy object shims. |
| Standards and ADRs treated PowerShell 2.0/3.0 as goals | `docs/standards/Keldor_PowerShell_Engineering_Standard.md`, ADR-0002, ADR-0004, ADR-0005, architecture guides | Modernize | Replace current guidance with the authoritative 5.1 and supported-PowerShell-7 policy. Preserve superseded reasoning only where clearly marked historical. |
| Generic “5.1+” and “7+” support statements | README and development documentation | Modernize | Replace numeric shorthand with edition-aware, lifecycle-aware language so Core 6.x and retired 7.x lines are not implied to be supported. |
| Build scripts had no explicit runtime requirement | `build.ps1` | Modernize | Set a 5.1 parser floor for portability while documenting and checking PowerShell 7.6 as the preferred build runtime. Runtime compatibility tests remain separate. |
| CI only ran analyzer on Linux | `.github/workflows/powershell.yml` | Modernize | Add Windows PowerShell 5.1 import/test coverage and PowerShell 7.6 jobs on Windows, Linux, and macOS, plus supported-line checks where installation is reliable. |
| Tests exercised legacy platform fallbacks | `src/Keldor/Tests/Get-KeldorPlatform.Tests.ps1` | Remove | Replace with supported Desktop/Core detection tests and runtime-policy unit tests using injected version/edition data. |
| No import-time lifecycle lookup existed | Loader and build | Retain | Import must remain offline. Lifecycle retirement is managed through release review, CI, and documentation rather than an online query or embedded retirement database. |

## WMI Review

### Removed as an obsolete runtime fallback

- `Public/Common/Get-KeldorPlatform.ps1`: WMI platform discovery was solely a pre-5.1 fallback.
- `Private/Windows/Get-KeldorWindowsManagementObject.ps1`: WMI fallback was solely for runtimes without CIM.

### Retained for Windows, remote-system, or vendor-provider behavior

The following files use WMI operations against remote Windows systems, WMI-only namespaces/classes, SCCM/MECM client
providers, vendor tooling, process creation, or established public command behavior. Converting them is not required to
drop old PowerShell parser support and may change remoting/authentication/serialization semantics. They are retained
for Windows PowerShell versus PowerShell Core differences or require command-specific manual review:

```text
InstallRemote.ps1
Public/Windows/Clear-Space.ps1
Public/Windows/Disable-3DES.ps1
Public/Windows/Enable-3DES.ps1
Public/Windows/Export-MessagesToPST.ps1
Public/Windows/Get-CertificateInventory.ps1
Public/Windows/Get-CurrentUser.ps1
Public/Windows/Get-HWInfo.ps1
Public/Windows/Get-LoggedOnUser.ps1
Public/Windows/Get-MTU.ps1
Public/Windows/Get-NICInfo.ps1
Public/Windows/Get-OperatingSystem.ps1
Public/Windows/Get-ProcessorCapability.ps1
Public/Windows/Get-SCCMInstallStatus.ps1
Public/Windows/Get-SCCMPendingUpdate.ps1
Public/Windows/Get-USBDevice.ps1
Public/Windows/Get-USBStorageDevice.ps1
Public/Windows/Get-User.ps1
Public/Windows/Get-WMIClass.ps1
Public/Windows/Get-WMINameSpace.ps1
Public/Windows/Get-WSLocalGroup.ps1
Public/Windows/Get-WSLocalUser.ps1
Public/Windows/Initialize-GPUpdate.ps1
Public/Windows/Install-SCCMUpdate.ps1
Public/Windows/Open-SCCMLogsFolder.ps1
Public/Windows/Set-AxwayConfig.ps1
Public/Windows/Set-RemoteDesktopCert.ps1
Public/Windows/Set-ServerConfig.ps1
Public/Windows/Start-SCCMUpdateScan.ps1
Public/Windows/Sync-HBSSWithServer.ps1
Public/Windows/Uninstall-HBSS.ps1
```

New work should prefer CIM where behaviorally equivalent. Each retained command needs focused Windows and remote-target
tests before migration; bulk replacement is unsafe.

## Cross-Platform Boundary Audit

- Direct operating-system detection in production was limited to `Get-KeldorPlatform.ps1`; the loader also depended on
  that exported command. The refactor centralizes detection in a private bootstrap helper and keeps
  `Get-KeldorPlatform` as the fixed public API.
- Windows-only WMI, registry, COM, `System.Windows.Forms`, and management-console code is under Windows-specific files,
  except standalone Windows artifacts such as `Keldor_SystemTrayApp.ps1` and `InstallRemote.ps1`. Those artifacts are
  not discovered by the platform loader.
- Common production files contain no detected PowerShell 7-only parser operators. Native command and remoting behavior
  remains covered by focused command tests rather than being rewritten as part of the loader change.
- Linux and macOS private collectors are isolated by platform folder. Folder name `macOS` maps to public value `macOS`.

## Dependency Audit

The production manifest has no required module dependency. Active Directory, DRA, LAPS, Exchange, OnePassword CLI,
SecretManagement, SCCM/MECM providers, and vendor tools are command-level optional integrations. Pester,
PSScriptAnalyzer, and PlatyPS are development dependencies and must not be added to the production manifest.

Development policy uses PowerShell 7.6 for build, formatting, documentation, and primary tests. Windows PowerShell 5.1
uses a compatible test path for manifest validation, actual import, parser coverage, and smoke/behavioral tests.

## Security Audit Notes

- No import-time network access, execution-policy change, remoting enablement, certificate-validation bypass, or
  `ServicePointManager` mutation was found in the loader.
- No obsolete TLS initialization is required for module import. Commands that explicitly configure Windows TLS state
  remain platform-specific administrative operations and are not invoked at import.
- Global configuration state and executable `config.ps1` are retained public-compatibility concerns. Import continues
  to load only repository-owned, fixed paths relative to `$PSScriptRoot`; no untrusted discovery path is accepted.
- The new loader fails closed on unknown editions and required file load errors and never calls `exit` or `Write-Host`.

## Breaking-Change and Release Classification

Keldor uses Semantic Versioning and currently has `ModuleVersion = '0.1.0'`. Dropping Windows PowerShell 2.0-5.0,
PowerShell Core 6.x, and PowerShell 7.0-7.3 is a breaking change and requires the next major version. This migration does
not select, publish, or write that release version into the source manifest. Release preparation must choose the major
version through the normal release process.

## Deferred Manual Reviews

- Replace legacy global configuration with module-scoped state only after all public configuration consumers and the
  tray application have an explicit migration contract.
- Migrate retained WMI commands individually, starting with local standard CIM classes and leaving SCCM/vendor WMI
  providers until their supported management APIs are confirmed.
- Normalize older object-construction patterns only after public output shapes are captured in tests.
- Review standalone Windows scripts for modern remoting and executable selection independently of module import.
