# Platform-Aware Module Loading

## Overview

Keldor loads only the commands applicable to the operating system on which the module is imported while maintaining a
consistent public API across supported platforms.

This approach minimizes unnecessary dependencies, reduces startup overhead, and allows Keldor to support Windows,
macOS, and Linux without maintaining separate modules.

## Supported Platforms

Keldor supports:

- Windows PowerShell 3.0 through 5.1
- PowerShell 7+
- Windows
- macOS
- Linux

Individual foundation commands may use legacy-compatible detection techniques where practical, but this does not expand
the supported PowerShell versions of the complete Keldor module.

## Folder Structure

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

Common commands are available on every supported platform. Platform-specific commands are loaded only when their folder
matches the current platform.

## Foundation Cmdlets

Foundation cmdlets provide core functionality used throughout Keldor. They are intentionally lightweight, stable, and
safe for other public and private commands to call.

A foundation cmdlet should be:

- public when consumers and downstream modules benefit from the same behavior
- minimally dependent on other commands
- safe to call during module initialization when required
- compatible with every platform supported by its documented contract
- thoroughly tested
- performance-conscious because it may be called frequently
- governed by a stable public API

`Get-KeldorPlatform` and the cross-platform
[system-information family](system-information.md) are foundation cmdlets. They are intentionally public so scripts,
third-party modules, and downstream Keldor modules can use the same normalized platform and inventory contracts.

Foundation cmdlets are architectural building blocks. Changes to their names, output contracts, or behavior require
careful compatibility review.

## Platform Detection

`Get-KeldorPlatform` is the canonical source of operating-system platform detection for Keldor.

Its return values are contractually fixed as:

- `Windows`
- `macOS`
- `Linux`
- `Unknown`

The spelling and capitalization of these values are part of the public API. In particular, Apple platforms must be
reported as `macOS`, not `MacOS`, `Mac OS`, `OSX`, or `Darwin`.

The command identifies the operating-system family only. It does not identify the distribution, edition, version, build,
or processor architecture.

Consumers must include a default path for `Unknown` rather than assuming platform detection always succeeds.

## Module Loading Process

During module import:

1. Load all private and public Common functions.
2. Determine the current operating system with `Get-KeldorPlatform`.
3. Load only the matching platform-specific private and public functions.
4. Export only public functions that were loaded.

The complete Common layer must load before Keldor calls `Get-KeldorPlatform`. This guarantees that the foundation cmdlet
is available before platform-specific commands are selected.

Common commands may call `Get-KeldorPlatform` when they execute, but function definitions must not invoke
platform-dependent behavior while they are being loaded.

The loading process must avoid circular dependencies between foundation commands, Common commands, and
platform-specific commands.

## Developer Guidelines

New Keldor commands must use `Get-KeldorPlatform` for platform-specific branching.

Do not introduce new direct platform-detection checks using:

- `$IsWindows`
- `$IsMacOS`
- `$IsLinux`
- `RuntimeInformation`
- WMI or CIM operating-system queries
- `uname`
- `sw_vers`
- similar operating-system detection mechanisms

Use the canonical result instead:

```powershell
switch (Get-KeldorPlatform) {
    'Windows' {
        # Windows-specific behavior
    }

    'macOS' {
        # macOS-specific behavior
    }

    'Linux' {
        # Linux-specific behavior
    }

    default {
        # Unsupported or undetected platform
    }
}
```

Existing commands must not add new direct platform checks. Duplicate or near-duplicate platform-detection logic is
technical debt because it prevents compatibility fixes from being made in one place.

When existing duplicate detection logic is encountered, migrate it to `Get-KeldorPlatform` when the change is low-risk
and does not alter the command's documented behavior.

## API Stability

Because `Get-KeldorPlatform` is a foundation cmdlet, its output contract is considered stable.

The following changes are potentially breaking and require compatibility review:

- renaming the command
- changing an existing return value
- changing the capitalization of a return value
- replacing the string output with an enum or custom object
- removing support for a documented platform
- changing module-loading order in a way that makes the command unavailable to dependent commands

Additional platforms may be supported in the future. Consumers should compare against documented values and retain a
default branch for values they do not recognize.

## Benefits

- Centralized platform detection
- Consistent behavior for internal and external consumers
- Smaller command surface on each platform
- Reduced startup overhead
- Easier compatibility maintenance
- Cleaner separation of platform-specific code
- Improved cross-platform support

## Future Improvements

- Identify additional foundation cmdlets
- Add architecture validation for duplicate platform-detection logic
- Evaluate optional feature packs
- Evaluate lazy-loading of large command groups
- Evaluate a plugin architecture
