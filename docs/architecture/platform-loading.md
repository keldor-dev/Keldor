# Platform-Aware Module Loading

## Overview

Keldor is designed to load only the functions applicable to the operating system on which it is imported.

This minimizes unnecessary dependencies, reduces startup overhead, and allows the project to support Windows, macOS, and Linux without maintaining separate modules.

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

## Loading Process

During module import:

1. Load all private and public Common functions.
2. Determine the current operating system with `Get-KeldorPlatform`.
3. Load only the matching platform-specific functions.
4. Export only public functions that were loaded.

## Platform Detection

`Get-KeldorPlatform` is a foundational public command and the canonical source of platform detection for the module. Its
case-sensitive return values are contractually fixed as `Windows`, `macOS`, `Linux`, and `Unknown`. Platform-specific
branching must compare against those exact values.

New commands must call `Get-KeldorPlatform` rather than directly checking `$IsWindows`, `$IsMacOS`, `$IsLinux`,
`RuntimeInformation`, WMI, `uname`, or another platform-detection mechanism. Existing commands must not add new direct
checks. Duplicate platform-detection logic is technical debt because centralizing detection allows compatibility fixes
to be made in one place.

The loader imports the complete Common layer before calling `Get-KeldorPlatform`, ensuring that the foundation command
is available before platform-specific public or private commands are loaded. Common commands may call it when they run,
but must not invoke platform-dependent behavior while their function definitions are being loaded.

The module supports:

- Windows PowerShell 3.0 through 5.1
- PowerShell 7+

The `Get-KeldorPlatform` implementation also remains compatible with Windows PowerShell 2.0 so it can safely use legacy
.NET and WMI fallbacks when embedded or tested independently. Older Windows PowerShell versions do not expose the modern
automatic platform variables or `RuntimeInformation` APIs.

## Benefits

- Smaller command surface
- Better startup performance
- Easier maintenance
- Cleaner separation of platform-specific code
- Improved cross-platform support

## Future Improvements

- Plugin architecture
- Optional feature packs
- Lazy-loading of large command groups
