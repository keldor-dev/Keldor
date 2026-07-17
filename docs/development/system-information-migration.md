# System Information Command Migration

| Property | Value |
|---|---|
| Status | Active deprecation plan |
| Date | 2026-07-16 |
| Canonical architecture | [Cross-Platform System Information](../architecture/system-information.md) |
| Removal target | Keldor 1.0.0 |

## Decisions

Repository source, help, tests, aliases, changelog references, and internal call sites were searched before selecting
the compatibility strategy. No internal production caller uses the four named legacy commands. Their exported names and
aliases remain potential external APIs, so they are retained as thin wrappers until Keldor 1.0.0.

| Legacy command | Current behavior and parameters | Historical output | Replacement | Migration method | Compatibility layer | Deprecation status | Internal callers updated | Documentation and tests |
|---|---|---|---|---|---|---|---|---|
| `Get-ComputerModel` | Optional pipeline-aware `ComputerName[]`; Windows WMI model query | `ComputerName`, `DomainRole`, `Manufacturer`, `Model`, `PorV`, `Type` | `Get-KeldorHardwareInfo` | Old WMI discovery removed; project normalized hardware into the old property order | Wrapper; existing `Get-Model` function alias metadata retained. `DomainRole` is null because it is not a hardware property and cannot be reconstructed safely | Deprecated; remove in 1.0.0 | None existed | Help names replacement; wrapper and shape tests added |
| `Get-SerialNumber` | Optional `ComputerName[]`; Windows WMI BIOS query | `ComputerName`, `SerialNumber`; failure used `NA` | `Get-KeldorHardwareInfo` | Old WMI discovery removed; project normalized serial number and retain `NA` only in legacy failure output | Wrapper; existing `Get-SN` function alias metadata retained | Deprecated; remove in 1.0.0 | None existed | Help names replacement; delegation and shape tests added |
| `Get-UpTime` | Optional `ComputerName[]`; Windows WMI boot query | Boot date, formatted total hours, component day/hour/minute/second values; string failure shape | `Get-KeldorUptime` | Old WMI discovery removed; project native uptime into historical fields | Wrapper; historical casing retained | Deprecated; remove in 1.0.0 | None existed | Help names replacement; native and compatibility tests added |
| `Test-Online` | Optional `ComputerName[]`; three ICMP echo requests | `Name`, vague string `Status` | `Test-ResponseTime` | Old direct ping implementation removed; invoke the existing explicit ICMP latency command once per target | Wrapper preserving `Name` and `Status` | Deprecated; remove in 1.0.0 | None existed | Help clarifies ICMP-only meaning; delegation tests added |

The wrappers issue a verbose deprecation message once per invocation, not a warning per pipeline object.

`Get-Model` and `Get-SN` were function alias attributes but were not in the module loader's explicit exported-alias list.
This migration preserves that metadata and does not broaden the public alias surface.

## Remote Compatibility

The new cross-platform commands use PowerShell remoting rather than direct legacy WMI targeting. A remote target must
have a compatible Keldor module installed. Existing sessions are preferred, especially for SSH targets. This deliberate
boundary avoids creating a second remoting framework before `Invoke-KeldorCommand` exists.

## Additional Overlapping Commands

The audit also found `Get-ComputerHWInfo`, `Get-HWInfo`, and `Get-OperatingSystem`. Their outputs include broader or
different Windows-only data, and replacing them in this change would be compatibility-sensitive. They remain unchanged
and are queued for separate migration after their external contracts are captured in tests.

## Consumer Migration

Use the canonical commands in new automation:

```powershell
Get-KeldorHardwareInfo |
    Select-Object Manufacturer, Model, SerialNumber

Get-KeldorUptime |
    Select-Object ComputerName, LastBootTime, Uptime

Test-ResponseTime -RemoteAddress server01
```
