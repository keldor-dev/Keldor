# ADR-0003: Public and Private Module Layout

| Property | Value |
|---|---|
| Status | Accepted |
| Date | 2026-07-07 |
| Decision Owner | Keldor Development Team |
| Applies To | Keldor PowerShell module structure |

## Context

Keldor contains a large and growing set of PowerShell functions.

Some functions are intended to be public commands exported to users. Others are internal helpers used by the module implementation.

A flat module structure would make it difficult to distinguish public API from internal implementation details.

## Decision

Keldor will use separate `Public` and `Private` directories.

Files under `Public` represent exported functions.

Files under `Private` represent internal helper functions and implementation details.

Platform folders may exist under both public and private roots:

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

This structure makes the module easier to navigate and helps preserve a clear boundary between public API and internal implementation.

It also allows the module loader to export public functions automatically while still dot-sourcing private helpers for internal use.

## Consequences

### Positive

- Clear distinction between public commands and internal helpers.
- Simpler automated exports.
- Easier code review and navigation.
- Scales better than a flat file structure.
- Supports platform-aware loading.

### Negative

- Developers must place files in the correct folder.
- Moving a function between public and private changes the module API.
- Private functions are still dot-sourced and must avoid name collisions.

## Alternatives Considered

### Flat Function Directory

Rejected because it does not clearly distinguish public commands from private helpers.

### Manual Export Lists Only

Rejected because it adds maintenance overhead and is error-prone for a large module.

### Separate Private Module

Rejected for now because it increases packaging complexity without enough benefit.

## Future Considerations

Keldor.Build.PowerShell may validate that public function file names match function names and that private helper functions are not exported.
