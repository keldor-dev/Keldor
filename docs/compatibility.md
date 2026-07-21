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
| PowerShell 7.2 | Best effort | Intended for restricted enterprise and government environments; warning emitted during import |
| PowerShell 7.3 | Best effort | Intended for restricted enterprise and government environments; warning emitted during import |
| PowerShell 7.4 | Yes, temporarily | Until Keldor raises its fully supported baseline |
| PowerShell 7.5 | Yes, temporarily | Until Keldor raises its fully supported baseline |
| PowerShell 7.6 LTS | Yes | Preferred development, automation, and CI runtime |

Last lifecycle review: 2026-07-20.

Keldor supports Windows PowerShell 5.1 on Windows versions that remain supported by Microsoft. Windows PowerShell 5.1
support follows the applicable Windows support channel and operating-system lifecycle; Keldor does not attempt to
identify the complete lifecycle status of the local Windows installation during import.

Keldor fully supports Microsoft-supported PowerShell 7 release lines beginning with PowerShell 7.4. PowerShell 7 support
follows the PowerShell and underlying .NET lifecycle. Support for 7.4 or 7.5 is not permanent after Microsoft retires
those lines. Keldor is maintained by the Keldor project, not Microsoft.

PowerShell 7.2 and 7.3 are accepted on a best-effort basis for restricted enterprise and government environments where a
newer runtime may not be available. Import continues, but Keldor emits a warning recommending PowerShell 7.6 LTS and
noting that some commands may require a newer runtime. Best-effort compatibility does not guarantee that every command,
dependency, or future feature will work on those retired runtime lines.

## Enforcement

The module manifest sets `PowerShellVersion = '5.1'` and declares both `Desktop` and `Core` editions. That manifest value
is only a numeric minimum: by itself it cannot reject PowerShell Core 6.x or distinguish among PowerShell 7 release lines.
The root module therefore runs the private `Test-KeldorPowerShellRuntime` guard before configuration and normal command
loading.

The guard applies these outcomes:

- Windows PowerShell 5.1 and PowerShell 7.4 or later continue without a compatibility warning.
- PowerShell 7.2 and 7.3 continue loading with a best-effort compatibility warning.
- Unsupported or unknown runtimes terminate only module import with error identifier
  `Keldor.UnsupportedPowerShellRuntime`.

The guard establishes a code minimum and does not query Microsoft lifecycle services during import. Release maintenance
may raise the fully supported baseline while retaining an explicitly documented best-effort tier when operationally
necessary. See the [PowerShell lifecycle policy](development/powershell-lifecycle-policy.md).

## Migrating from an Unsupported or Best-Effort Runtime

- Windows PowerShell 2.0-5.0 users must upgrade to Windows PowerShell 5.1 on a supported Windows operating system.
- PowerShell Core 6.x and PowerShell 7.0-7.1 users must upgrade to PowerShell 7.2 or later before importing Keldor.
- PowerShell 7.2 and 7.3 users should upgrade to PowerShell 7.6 LTS when organizational policy permits.
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
