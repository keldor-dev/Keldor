# Fleet Command Migration Audit

| Property | Value |
|---|---|
| Status | Active backlog |
| Audit date | 2026-07-16 |
| Scope | `src/Keldor/Public/**/*.ps1` |
| Governing standard | [Keldor Input & Output Standard](../standards/Keldor_Input_Output_Standard.md#fleet-and-infrastructure-contract) |

## Purpose

This checked-in backlog identifies existing public commands that are likely fleet-oriented or infrastructure-oriented
and records safe future migration work. It is not an authorization to change established public contracts without
compatibility review.

## Method and Baseline

The audit reviewed all 262 public command files and searched for target identity parameters, sessions, credentials,
PowerShell remoting, SSH, CIM/WMI, cloud/platform terms, services, disks, networking, certificates, patching, and remote
execution. It also searched for host/formatting output, loose hashtables, display units, vague timestamp/Boolean/target
names, array target parameters without pipeline binding, incidental output, and divergent success/failure shapes.

Baseline observations:

- `Invoke-KeldorCommand` is the canonical orchestration contract for new remote work. Existing inventory commands are
  intentionally deferred for a focused, non-recursive migration that preserves their local snapshot collectors.

- 85 public files reference `ComputerName`; 76 declare it as a string array.
- Only 14 `ComputerName` files contain either pipeline-binding attribute, and each still needs command-level review to
  confirm that the binding applies to the target parameter.
- `Get-LockedOutLocation` invokes `Format-Table` in production output.
- `Get-UserLogonLogoffTime` invokes `Format-List` internally as part of a text-processing pipeline.
- `Get-KeldorPlatform` uses `Write-Host` only for its explicit `-PrintToHost` presentation mode; its default output is a
  platform value, so this is classified as compliant for the audited concern.
- Many legacy remote commands return useful objects but lack stable Keldor type names and pipeline binding.

The repository-wide formatting baseline is enforced by AST tests. New violations are not silently exempted; a baseline
change requires this report and its test data to be reviewed together.

## Classification Definitions

| Classification | Meaning |
|---|---|
| Compliant | Meets the applicable audited contract or uses display output only through an explicit presentation mode. |
| Low-risk improvement | An additive change appears feasible after focused compatibility tests. |
| Compatibility-sensitive | Existing parameter, output, stream, or behavior consumers may rely on the current contract. |
| Requires redesign | Success/failure shape, execution model, concurrency, or presentation behavior needs deliberate redesign. |
| Not applicable | The command is interactive, local-only, presentation-oriented, or otherwise outside the fleet contract. |

## Detailed Findings

| Command | Platform folder | Classification | Current input contract | Current output contract | Issue | Recommended future contract | Compatibility risk | Priority |
|---|---|---|---|---|---|---|---|---|
| `Get-KeldorPlatform` | Common | Compliant | No fleet target; optional presentation switch | Platform string by default; host message only when requested | None for fleet output | Retain current explicit presentation boundary | Low | P4 |
| `Get-ComputerADSite` | Windows | Low-risk improvement | `ComputerName[]`; pipeline binding present | Structured object with canonical and legacy site properties | No stable type name; verify binding and failure behavior | Preserve properties; add documented `Keldor.ActiveDirectory.SiteResult` after tests | Medium | P2 |
| `Get-ComputerModel` | Windows | Compatibility-sensitive | Optional pipeline-aware `ComputerName[]` | Historical six-property model object | Superseded by a wider hardware contract | Deprecated wrapper over `Get-KeldorHardwareInfo`; remove in 1.0.0 | Medium | Completed |
| `Get-HWPerformanceScore` | Windows | Low-risk improvement | `ComputerName[]`; pipeline marker present | Native CIM/WMI-derived object | Binding and object shape vary by execution path | Normalize documented properties while retaining legacy fields | Medium | P3 |
| `Get-SplunkStatus` | Windows | Compatibility-sensitive | Optional `ComputerName[]`; no pipeline binding | Object with `ComputerName`, `Status`, and legacy `SplunkStatus` | Local branch references an unset loop variable; no typed failure result or type name | Per-target service-health result; preserve `SplunkStatus` | High | P1 |
| `Get-SerialNumber` | Windows | Compatibility-sensitive | Optional `ComputerName[]` | Historical two-property serial object with `NA` failure sentinel | Superseded by normalized hardware inventory | Deprecated wrapper over `Get-KeldorHardwareInfo`; remove in 1.0.0 | Medium | Completed |
| `Get-UpTime` | Windows | Compatibility-sensitive | Optional `ComputerName[]` | Formatted total and component duration properties | Superseded by native uptime contract | Deprecated wrapper over `Get-KeldorUptime`; remove in 1.0.0 | High | Completed |
| `Test-Online` | Windows | Compatibility-sensitive | Optional `ComputerName[]` | ICMP result with `Name` and vague `Status` | Name obscures ICMP-only semantics | Deprecated wrapper over `Test-ResponseTime`; remove in 1.0.0 | High | Completed |
| `Test-ResponseTime` | Windows | Compatibility-sensitive | `RemoteAddress[]` aliases `ComputerName`; throttle support | Structured latency summary | Target parameter is noncanonical; output depends on ping response shape | Preserve alias behavior; plan canonical `ComputerName` parameter and numeric latency fields | High | P2 |
| `Get-PSVersion` | Windows | Requires redesign | Optional `ComputerName[]`; no pipeline binding | Object with version and OS values encoded as strings | Environment-specific ignore defaults; failure sentinels and version strings change semantics | Native `[version]`, structured errors, documented ignore input, stable type name | High | P1 |
| `Get-CurrentUser` | Windows | Requires redesign | Mandatory `ComputerName[]`; no pipeline binding | Incidental leading success-stream string; object uses `Computer`/`LoggedOn`; failure goes to host | Leaks display text and has inconsistent target/error contracts | Per-target user-session result with canonical identity and structured failure | High | P1 |
| `Get-WSToolsVersion` | Windows | Requires redesign | `-Remote` plus optional `ComputerName[]` | Object uses vague `Date`; failures use `NA` strings | Remote mode and target input are coupled; version/time types vary | Meaningful parameter sets; `[version]`, `UpdatedAt`, and per-target diagnostics | High | P2 |
| `Get-SCCMPendingUpdate` | Windows | Compatibility-sensitive | Optional `ComputerName[]`; commented pipeline marker | Objects produced locally or through `Invoke-Command` | Remoting metadata and target identity may differ; no per-target failure object | Patch-status result with canonical target, stable type, and structured failure | High | P1 |
| `Save-UpdateHistory` | Windows | Requires redesign | `ComputerName[]`, `ThrottleLimit`; no pipeline binding | Primarily writes remote CSV files; remoting output may leak | Side effect/output contract and per-target reporting are unclear | Per-target save result with path, success, errors, timing, and per-target `ShouldProcess` review | High | P1 |
| `Get-CertificateInventory` | Windows | Compatibility-sensitive | Remote inventory inputs; array processing | Wide certificate inventory object | Certificate dates/status and target contract require capture before normalization | `Keldor.CertificateStatus` with native dates and compatibility properties | High | P2 |
| `Get-Drive` | Windows | Compatibility-sensitive | Remote computer array | Drive measurements include legacy naming/display choices | Units and failure behavior are not a defined public contract | Native byte/percentage fields and per-target structured errors | High | P2 |
| `Get-NetworkLevelAuthentication` | Windows | Compatibility-sensitive | Optional `ComputerName[]`; no pipeline binding | Similar objects across branches with status-like strings | No stable type name; failure and state are conflated | Compliance result with nullable Boolean, defined status, and errors | Medium | P2 |
| `Get-LockedOutLocation` | Windows | Requires redesign | Single AD identity | Formatted table followed by a different event object shape | Formatting command consumes primary data; two unrelated shapes share success stream | Structured lockout observations with separate documented object families | High | P1 |
| `Get-UserLogonLogoffTime` | Windows | Requires redesign | Event/user filters | Internally formats objects then parses display text | Machine-readable values are destroyed before output | Preserve event values as native structured properties; format only in examples/views | High | P1 |
| `Initialize-GPUpdate` | Windows | Compatibility-sensitive | Optional `ComputerName[]`; no pipeline binding | Per-target object remotely; local execution emits native process output | Local/remote shapes differ; state-changing behavior lacks `ShouldProcess` | Per-target remote-operation result and per-target `ShouldProcess` | High | P1 |
| `Set-Reboot` | Windows | Compatibility-sensitive | Optional `ComputerName[]`; no pipeline binding | No documented success object; errors may terminate fleet processing | `ShouldProcess` exists, but one failure can stop later targets | Preserve command semantics; add pipeline binding and per-target result only with compatibility tests | High | P2 |
| `Clear-Patches` | Windows | Requires redesign | `ObjectList[]` aliases `ComputerName`; pipeline binding and custom concurrency | Per-target status objects from runspaces | Canonical identity is only an alias; runspace `ShouldProcess` and output/error contracts need review | Canonical `ComputerName`, bounded `ThrottleLimit`, normalized remote result, preserved aliases | High | P1 |
| `Install-SCCMUpdate` | Windows | Compatibility-sensitive | `ComputerName[]`; pipeline marker present | Per-target update/action output | State change, remote failures, and successful mixed-target output need contract tests | Per-target `ShouldProcess` plus normalized remediation result | High | P1 |
| `Open-ComputerManagement` | Windows | Not applicable | Optional single `ComputerName` | Launches an interactive management console | Interactive presentation command, not a composable inventory result | Retain targeted launcher behavior | Low | P4 |
| `Open-DeviceManager` | Windows | Not applicable | Optional single `ComputerName` | Launches an interactive management console | Interactive presentation command | Retain targeted launcher behavior | Low | P4 |

## Additional Candidate Inventory

The following command families remain queued for the same command-level review. They are not exempt from the standard:

- TLS, cipher, SMB, NLA, remediation, and configuration mutations: `Disable-*`, `Enable-*`, `Set-MS15124`,
  `Set-PrintNightmareFix`, `Set-RemediationValues`, `Set-SMBv1Fix`, and `Set-ServerConfig`.
- Inventory and health: `Get-BitLockerStatus`, `Get-ComputerHWInfo`, `Get-HBSSStatus`, `Get-HWInfo`, `Get-IEVersion`,
  `Get-InstalledProgram`, `Get-MTU`, `Get-NICInfo`, `Get-OperatingSystem`, `Get-ProcessorCapability`, `Get-USBDevice`,
  `Get-USBStorageDevice`, `Get-UpdateHistory`, `Get-WMIClass`, and `Get-WMINameSpace`.
- Remote action and patching: `Clear-DirtyShutdown`, `Clear-Space`, `Copy-UpdateHistory`, `Install-Patches`,
  `Repair-DuplicateSusClientID`, `Restart-ActiveDirectory`, `Restart-DNS`, `Restart-KDC`, `Start-SCCMUpdateScan`,
  `Sync-HBSSWithServer`, `Uninstall-HBSS`, `Update-ModulesFromLocalRepo`, and `Update-WSTools`.
- Interactive remote launchers are generally not applicable unless they begin returning reusable inventory data:
  `Connect-RDP`, `Open-DiskManagement`, `Open-EventViewer`, `Open-Services`, `Open-SharedFolders`, and
  `Open-WindowsUpdateLog`.

## Migration Rules

1. Capture the current input, output, stream, and per-target failure behavior in focused tests.
2. Prefer additive pipeline binding, aliases, properties, and type names when semantics are already compatible.
3. Do not rename or remove public properties in a low-risk migration.
4. Do not replace scalar or display output with objects unless compatibility is unquestionably preserved.
5. Migrate one object family per change and update this backlog when its classification changes.
6. Treat redesign items as explicit, separately reviewed work with semantic-versioning analysis.
