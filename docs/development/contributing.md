# Contributing

Thank you for contributing to Keldor.

## Goals

Keldor aims to provide a modern, cross-platform PowerShell toolkit with a consistent user experience.

Shared production code must parse and run on Windows PowerShell 5.1 and supported PowerShell 7 release lines beginning
with 7.4. Use PowerShell 7.6 LTS for primary development and CI. Do not introduce PowerShell 7-only parser syntax into
files loaded by Windows PowerShell 5.1.

## Coding Standards

- One public function per file.
- One private helper per file.
- Use approved PowerShell verbs.
- Prefer pipeline support where appropriate.
- Include comment-based help.
- Every public function should define a `HelpUri`.
- Every public function should include a `.LINK` section pointing to the online documentation.
- Use four spaces and never tabs in PowerShell files.
- Use OTBS braces, including `} else {`, `} elseif {`, `} catch {`, and `} finally {`.
- Keep lines within 120 characters except for documented indivisible-literal exceptions.
- Follow [the PowerShell engineering standard](../standards/Keldor_PowerShell_Engineering_Standard.md).

## Does the Fleet Contract Apply?

Use the [fleet and infrastructure contract](../standards/Keldor_Input_Output_Standard.md#fleet-and-infrastructure-contract)
when a command operates across computers or infrastructure resources, performs remote work, inventories systems or
cloud resources, checks health or compliance, manages services/storage/networking/patches/certificates, reconciles a
CMDB, or participates in monitoring or remediation.

Before implementation, answer these questions:

1. Does the command logically process one or more targets or rich input objects? If yes, design pipeline binding.
2. Is the target a computer? Use `ComputerName`; use `InputObject` for a documented rich-object contract and
   `PSSession` for reusable sessions.
3. Does it change external or persistent state? If yes, preserve per-target `ShouldProcess` behavior.
4. Will callers filter, group, sort, export, report, serialize, or reconcile the result? Define a stable structured
   object with native types, intentional order, and a Keldor type name.
5. Can one target fail while others succeed? Return a normalized result for each target and preserve successful output.

Start with the dedicated [fleet templates](../standards/powershell/templates/README.md). Do not add fleet-only parameters
to simple commands where they have no useful meaning. Existing public contracts are compatibility-sensitive; record
uncertain modernization work in the [fleet migration audit](fleet-command-migration-audit.md).

## Formatting and Analysis

Install PSScriptAnalyzer and use the repository configuration:

```powershell
Invoke-ScriptAnalyzer -Path ./src -Recurse -Settings ./PSScriptAnalyzerSettings.psd1
```

Format a file with the same configuration:

```powershell
$Path = './src/Keldor/Keldor.psm1'
$Content = Get-Content -LiteralPath $Path -Raw
$Formatted = Invoke-Formatter -ScriptDefinition $Content -Settings ./PSScriptAnalyzerSettings.psd1
Set-Content -LiteralPath $Path -Value $Formatted -NoNewline
```

A second formatter run must produce no changes.

## Cross-Platform Guidelines

Before adding a command, determine whether it belongs in:

- Common
- Windows
- macOS
- Linux

Avoid introducing platform-specific behavior into Common functions.

## Pull Requests

Please ensure:

- Code builds successfully.
- Documentation is updated.
- New public commands include online help.
- Breaking changes are documented.
- The PowerShell lifecycle matrix is reviewed when the change affects runtime compatibility.

## Documentation

Public documentation is maintained in the `keldor-dev/docs` repository.

Developer documentation belongs in this repository.
