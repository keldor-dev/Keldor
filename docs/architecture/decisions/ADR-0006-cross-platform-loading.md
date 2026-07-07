# ADR-0006: Cross-Platform Loading Model

| Property | Value |
|---|---|
| Status | Superseded |
| Date | 2026-07-07 |
| Superseded By | [ADR-0001: Platform-Aware Module Loading](ADR-0001-platform-aware-module-loading.md) |

## Summary

This ADR has been superseded by [ADR-0001: Platform-Aware Module Loading](ADR-0001-platform-aware-module-loading.md).

The cross-platform loading guidance originally captured here has been merged into ADR-0001 so that Keldor has one canonical decision covering:

- platform-aware loading
- `Common`, `Windows`, `macOS`, and `Linux` folders
- platform-specific function isolation
- safe imports on unsupported platforms
- future validation and build-time loader generation

This file is retained only as a historical redirect.
