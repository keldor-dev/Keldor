# PowerShell Compatibility

| Runtime | Supported | Notes |
|---|---:|---|
| Windows PowerShell 2.0 | No | Retired |
| Windows PowerShell 3.0 | No | Retired |
| Windows PowerShell 4.0 | No | Retired |
| Windows PowerShell 5.0 | No | Retired |
| Windows PowerShell 5.1 | Yes | Requires a Windows version still supported by Microsoft |
| PowerShell 6.x | No | Retired |
| PowerShell 7.0 | No | Retired |
| PowerShell 7.1 | No | Retired |
| PowerShell 7.2 | No | Retired |
| PowerShell 7.3 | No | Retired |
| PowerShell 7.4 | Yes, temporarily | Until Keldor raises its baseline |
| PowerShell 7.5 | Yes, temporarily | Until Keldor raises its baseline |
| PowerShell 7.6 LTS | Yes | Preferred development, automation, and CI runtime |

Last lifecycle review: 2026-07-16.

Keldor supports Windows PowerShell 5.1 on Windows versions that remain supported by Microsoft. Windows PowerShell 5.1
support follows the applicable Windows support channel and operating-system lifecycle; Keldor does not attempt to
identify the complete lifecycle status of the local Windows installation during import.

Keldor also supports Microsoft-supported PowerShell 7 release lines beginning with PowerShell 7.4. PowerShell 7 support
follows the PowerShell and underlying .NET lifecycle. Support for 7.4 or 7.5 is not permanent after Microsoft retires
those lines. Keldor is maintained by the Keldor project, not Microsoft.

## Enforcement

The module manifest sets `PowerShellVersion = '5.1'` and declares both `Desktop` and `Core` editions. That manifest value
is only a numeric minimum: by itself it cannot reject PowerShell Core 6.x or PowerShell 7.0-7.3. The root module therefore
runs the private `Test-KeldorPowerShellRuntime` guard before configuration and normal command loading. Unsupported or
unknown runtimes terminate only module import with error identifier `Keldor.UnsupportedPowerShellRuntime`.

The guard establishes a code minimum and does not query Microsoft lifecycle services during import. Release maintenance
raises the minimum when Microsoft retires the oldest tested line. See the
[PowerShell lifecycle policy](development/powershell-lifecycle-policy.md).

## Migrating from an Unsupported Runtime

- Windows PowerShell 2.0-5.0 users must upgrade to Windows PowerShell 5.1 on a supported Windows operating system.
- PowerShell Core 6.x and PowerShell 7.0-7.3 users must upgrade to a currently supported PowerShell 7 release.
- Windows PowerShell 5.1 and PowerShell 7 can coexist on Windows. Their executables are normally `powershell.exe` and
  `pwsh`, respectively.
- Keldor does not install or upgrade PowerShell, modify Windows Management Framework, bypass organizational
  software-management controls, or change execution policy during import.

Use Microsoft's current PowerShell installation and lifecycle documentation when planning an upgrade. Organizational
deployment and operating-system policy remain the responsibility of the system owner.

## Shared-Code Constraint

Production files loaded on both editions use syntax understood by Windows PowerShell 5.1. Shared code does not use
PowerShell 7-only operators, `ForEach-Object -Parallel`, the `clean` block, or unguarded PowerShell 7-only automatic
variables. Platform-specific dependencies are isolated by the loader.
