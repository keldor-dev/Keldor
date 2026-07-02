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

1. Determine the current operating system.
2. Load all Common functions.
3. Load only the matching platform-specific functions.
4. Export only public functions that were loaded.

## Platform Detection

Keldor supports:

- Windows PowerShell 5.1
- PowerShell 7+

Older versions of PowerShell do not expose `$IsWindows`, `$IsMacOS`, or `$IsLinux`, so Keldor uses a compatibility helper to determine the platform.

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
