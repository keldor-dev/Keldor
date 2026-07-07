# ADR-0001: Platform-Aware Module Loading

| Property | Value |
|---|---|
| Status | Accepted |
| Date | 2026-07-07 |
| Decision Owner | Keldor Development Team |
| Applies To | Keldor PowerShell module loading |

## Context

Keldor contains functions that are common across platforms and functions that are specific to Windows, macOS, or Linux.

Loading every function on every platform can cause avoidable import failures when a file references platform-specific APIs, commands, registry paths, WMI classes, COM objects, or external tools that do not exist on the current operating system.

Keldor also needs a simple development model where contributors can add functions to predictable folders without manually editing a large monolithic module file.

## Decision

Keldor will use platform-aware module loading.

Common functions are loaded on all supported platforms.

Platform-specific functions are loaded only when the current platform matches the function folder.

The canonical folder groups are:

```text
Public/Common
Public/Windows
Public/macOS
Public/Linux
Private/Common
Private/Windows
Private/macOS
Private/Linux
```

## Rationale

Platform-aware loading allows Keldor to support cross-platform PowerShell while still retaining useful Windows-specific administrative functions.

This design reduces import failures, isolates platform-specific dependencies, and keeps the developer workflow simple.

A function can be added to the appropriate folder and loaded automatically without maintaining a static import list by hand.

## Consequences

### Positive

- Reduces cross-platform import failures.
- Allows Windows-only functionality to exist safely beside cross-platform functionality.
- Keeps the module structure understandable.
- Supports future expansion for macOS and Linux.
- Avoids a giant manually maintained loader file.

### Negative

- Module import requires runtime file discovery.
- Incorrect folder placement can hide functions on some platforms.
- Platform detection must be reliable and conservative.

## Alternatives Considered

### Load All Functions on All Platforms

Rejected because platform-specific functions may fail during import on unsupported systems.

### Separate Modules Per Platform

Rejected for now because it would increase packaging, discovery, and maintenance complexity.

### Static Import List

Rejected for source development because it increases maintenance overhead when adding or removing functions.

## Future Considerations

Keldor.Build.PowerShell may eventually generate an optimized platform-aware loader during build time.

That would preserve the current source layout while reducing runtime import overhead.
