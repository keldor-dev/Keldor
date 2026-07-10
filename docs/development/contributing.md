# Contributing

Thank you for contributing to Keldor.

## Goals

Keldor aims to provide a modern, cross-platform PowerShell toolkit with a consistent user experience.

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

## Documentation

Public documentation is maintained in the `keldor-dev/docs` repository.

Developer documentation belongs in this repository.
