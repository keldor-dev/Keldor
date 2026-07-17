# Cross-Platform System Information

## Overview

Keldor's system-information foundation provides stable, structured inventory for Windows, Linux, and macOS.
`Get-KeldorSystemInfo` is the aggregate command. The other commands expose focused contracts that can be used
independently:

```text
Get-KeldorSystemInfo
├── Get-KeldorOperatingSystem
│   └── Get-KeldorLinuxDistribution (Linux only)
├── Get-KeldorKernel
├── Get-KeldorUptime
└── Get-KeldorHardwareInfo
```

All commands use the [fleet input and output contract](../standards/Keldor_Input_Output_Standard.md#fleet-and-infrastructure-contract).

## Collection Architecture

Each target produces one private raw snapshot. Public commands project that snapshot into ordered result contracts.
`Get-KeldorSystemInfo` creates all feeder projections from the same snapshot, so it does not repeat operating-system,
kernel, uptime, or hardware queries.

The public type names are:

| Command | Type name |
|---|---|
| `Get-KeldorSystemInfo` | `Keldor.SystemInfo` |
| `Get-KeldorOperatingSystem` | `Keldor.OperatingSystem` |
| `Get-KeldorLinuxDistribution` | `Keldor.LinuxDistribution` |
| `Get-KeldorKernel` | `Keldor.Kernel` |
| `Get-KeldorUptime` | `Keldor.Uptime` |
| `Get-KeldorHardwareInfo` | `Keldor.HardwareInfo` |

Properties retain native types. Dates are dates, uptime is `[timespan]`, memory bytes are integers, memory gigabytes and
uptime totals are numeric, and Boolean properties remain Boolean or `$null`.

## Platform Sources

| Platform | Sources |
|---|---|
| Windows | CIM, Windows product registry, and .NET runtime APIs |
| Linux | `/etc/os-release`, `/usr/lib/os-release`, `/proc`, `/sys/class/dmi/id`, and `uname` |
| macOS | `sw_vers`, `uname`, `sysctl`, .NET monotonic uptime, and narrow `system_profiler SPHardwareDataType` output |

The Linux os-release parser treats file contents as data. It does not source the file or evaluate substitutions.
Collectors do not require root for ordinary inventory. Optional inaccessible properties remain `$null`.

## Null and Applicability Semantics

Unknown or unavailable values are `$null`; placeholder strings such as `N/A` and `Unknown` are not used in new
contracts. A missing optional serial number, firmware date, DMI property, or virtualization signature does not make the
overall result fail.

`IsVirtualMachine` is `$null` when evidence is insufficient. It is not set to false merely because no known signature
was found.

`Get-KeldorLinuxDistribution` is available on every platform so scripts can discover it consistently, but it is
applicable only to Linux targets. Windows and macOS targets produce a non-terminating `InvalidOperation` error and no
fabricated Linux success object. Linux-distribution properties in `Keldor.SystemInfo` are `$null` on other platforms.

## Targeting and Remoting

Every command has `Local`, `ComputerName`, and `PSSession` parameter sets:

- Local collection is the default and requires no target parameter.
- `PSSession` reuses caller-supplied sessions without reconnecting.
- `ComputerName` creates one standard PowerShell session per target, uses it once, and removes it.
- `Credential` is available only in the `ComputerName` parameter set.

Remote collection requires a compatible Keldor module on the target. Keldor does not enable remoting or modify WSMan,
SSH, firewall, TrustedHosts, or authentication settings. `ComputerName` uses the host's configured default PowerShell
remoting transport. Use an existing SSH-backed `PSSession` for Linux or macOS when appropriate.

Connection failures return a structured failure result for that target and do not suppress successful results from
other targets. Parallel fleet orchestration and a general transport abstraction remain future responsibilities of the
planned `Invoke-KeldorCommand` command family.

## Examples

```powershell
Get-KeldorSystemInfo |
    Select-Object ComputerName, Platform, OperatingSystem, Model, SerialNumber

Get-KeldorHardwareInfo |
    Select-Object Manufacturer, Model, SerialNumber

Get-KeldorUptime |
    Select-Object ComputerName, LastBootTime, Uptime

'server01', 'server02' |
    Get-KeldorSystemInfo |
    Export-Csv -Path ./system-inventory.csv -NoTypeInformation

Get-PSSession |
    Get-KeldorKernel |
    ConvertTo-Json -Depth 3
```

## Future Consumers

The contracts are intended to support health checks, fleet inventory, Azure Arc enrichment, CMDB discovery,
ServiceNow reconciliation, and virtualization or Nutanix integrations. Those integrations must consume these objects
without adding cloud authentication, network discovery, or provider dependencies to the core collectors.
