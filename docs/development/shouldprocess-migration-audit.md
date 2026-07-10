# ShouldProcess Migration Audit

| Property | Value |
|---|---|
| Status | Backlog |
| Audited | 2026-07-10 |
| Scope | Public commands identified during the repository style audit |

## Purpose

This audit applies the behavior-based `ShouldProcess` policy in the Keldor PowerShell Engineering Standard. It does not
change command behavior. Each command should be migrated in a small, reviewed batch with focused tests and documentation.

## Classifications

### Clearly Requires `ShouldProcess`

| Command | Reason |
|---|---|
| `Copy-PowerShellJSON` | Creates a directory and overwrites the user's VS Code snippets file. |
| `Add-UserJavaException` | Changes persistent Java exception-site configuration. |
| `Copy-UpdateHistory` | Copies persistent report data. |
| `Copy-UserProfile` | Copies profile data and changes the destination filesystem. |
| `Copy-VSCodeSettingsToProfile` | Creates and writes VS Code profile files. |
| `Import-MOF` | Rewrites a MOF file and compiles it into WMI policy state. |
| `Install-Patches` | Installs operating-system updates. |
| `Install-SCCMUpdate` | Initiates installation of Configuration Manager updates. |
| `Install-WSTools` | Copies and installs workstation tooling. |
| `Join-File` | Creates a joined output file. |
| `Mount-HomeDrive` | Mounts a persistent or session-visible drive. |
| `Register-ADSIEdit` | Registers system components. |
| `Register-NotificationApp` | Creates registry keys and values. |
| `Register-Schema` | Registers or modifies directory schema state. |
| `Repair-DuplicateSusClientID` | Changes registry state and restarts services. |
| `Restore-WindowsUpdate` | Restores or changes Windows Update configuration. |
| `Save-HelpToFile` | Writes help content to the destination filesystem. |
| `Save-MaintenanceReport` | Writes a maintenance report. |
| `Save-UpdateHistory` | Creates directories and writes update-history reports. |
| `Sync-HBSSWithServer` | Initiates endpoint synchronization that can change local state. |
| `Sync-InTune` | Starts the management synchronization scheduled task. |
| `Uninstall-HBSS` | Removes endpoint security software and related state. |
| `Update-BrokenInheritance` | Modifies access-control inheritance. |
| `Update-HelpFromFile` | Updates installed PowerShell help. |
| `Update-McAfeeSecurity` | Starts a security-product update process. |
| `Update-ModulesFromLocalRepo` | Updates installed modules. |
| `Update-VisioStencils` | Copies and replaces Visio stencil files. |
| `Update-WSTools` | Updates workstation tooling. |

### Requires Manual Behavioral Review

| Command | Reason |
|---|---|
| `Import-DRAModule` | Changes session state by importing a module, but PowerShell import commands do not normally expose `WhatIf`; review caller expectations before adding it. |

### Does Not Require `ShouldProcess`

| Command | Reason |
|---|---|
| `Import-XML` | Reads and parses XML without changing external or persistent state. |

## Compatibility Checklist

For each migration:

1. Add `SupportsShouldProcess = $true` and select `ConfirmImpact` from the operation's reversibility and risk.
2. Place `$PSCmdlet.ShouldProcess($Target, $Action)` immediately before the state change.
3. Verify that `-WhatIf` performs no state-changing nested calls.
4. Verify `-Confirm` prompt target and action wording.
5. Avoid duplicate prompts from nested commands that already support `ShouldProcess`.
6. Test direct calls, pipeline calls, internal callers, aliases, and error paths.
7. Update comment-based help and examples for `-WhatIf` behavior.
8. Treat cmdlet metadata changes and the new common parameters as public compatibility considerations.

Implement clearly related commands together, starting with low-risk filesystem writers, followed by configuration and
registry changes, service operations, software installation, and security tooling.
