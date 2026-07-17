# Keldor PowerShell Templates

These templates represent the canonical implementation patterns for the Keldor PowerShell Engineering Standard.

## Templates

| Template | Purpose |
|---|---|
| `AdvancedFunction.ps1` | Standard public function template. |
| `ShouldProcessFunction.ps1` | Standard state-changing function template with `-WhatIf` and `-Confirm` support. |
| `FleetReadOnlyFunction.ps1` | Read-only `ComputerName` pipeline, health result, and mixed-target failure pattern. |
| `FleetInputObjectFunction.ps1` | Documented rich `InputObject` pipeline pattern. |
| `FleetSessionFunction.ps1` | Meaningful `ComputerName` and reusable `PSSession` parameter sets plus remote result. |
| `FleetShouldProcessFunction.ps1` | Per-target state change with pipeline binding and `ShouldProcess`. |
| `Module.psm1` | Standard module loader pattern. |
| `Module.psd1` | Standard module manifest pattern. |
| `Pester.Tests.ps1` | Standard Pester test scaffold. |
| `Class.ps1` | Optional class template for the supported PowerShell baseline. |
| `Enum.ps1` | Optional enum template for the supported PowerShell baseline. |

Use the fleet templates only when the
[fleet and infrastructure contract](../../Keldor_Input_Output_Standard.md#fleet-and-infrastructure-contract) applies.
They use syntax valid in Windows PowerShell 5.1 and supported PowerShell 7 releases. Simple commands should continue to
use the general templates without irrelevant connection or fleet parameters.
