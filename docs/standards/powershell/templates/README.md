# Keldor PowerShell Templates

These templates represent the canonical implementation patterns for the Keldor PowerShell Engineering Standard.

## Templates

| Template | Purpose |
|---|---|
| `AdvancedFunction.ps1` | Standard public function template. |
| `ShouldProcessFunction.ps1` | Standard state-changing function template with `-WhatIf` and `-Confirm` support. |
| `Module.psm1` | Standard module loader pattern. |
| `Module.psd1` | Standard module manifest pattern. |
| `Pester.Tests.ps1` | Standard Pester test scaffold. |
| `Class.ps1` | Optional class template for PowerShell 5.1+ / 7+ code. |
| `Enum.ps1` | Optional enum template for PowerShell 5.1+ / 7+ code. |

PowerShell 2.0-compatible modules should avoid classes and enums.
