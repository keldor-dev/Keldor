# Acronym commands

Keldor bundles a structured acronym catalog and provides three cross-platform runtime commands:

```powershell
Find-KeldorAcronym <Search> [-Exact] [-AdditionalCatalogPath <string[]>]
Get-KeldorAcronym [[-Acronym] <string[]>] [-Category <string[]>] [-All]
    [-AdditionalCatalogPath <string[]>] [-ExcludeKeldorCatalog]
Export-KeldorAcronym [-Path] <string> [-Format <Json|Csv|Markdown|Html>]
    [-Acronym <string[]>] [-Category <string[]>] [-AdditionalCatalogPath <string[]>]
    [-Force] [-PassThru] [-WhatIf] [-Confirm]
```

Aliases are `Find-KDAcronym`, `Get-KDAcronym`, and `Export-KDAcronym`.

`Find-KeldorAcronym` performs a case-insensitive literal partial search across acronym, meaning, category, and notes.
`-Exact` searches only complete acronym values. `Get-KeldorAcronym` returns structured records suitable for standard
PowerShell grouping, sorting, and counting. Exact duplicate records from supplemental catalogs are removed, while
distinct meanings remain available.

```powershell
Find-KeldorAcronym DOJ
'API', 'DNS' | Find-KDAcronym -Exact
Get-KeldorAcronym | Group-Object Category | Sort-Object Count -Descending
Get-KeldorAcronym -AdditionalCatalogPath ./EOIR.json -ExcludeKeldorCatalog
Get-KeldorAcronym -Category Government |
    Export-KeldorAcronym -Path ./Government.md
```

Export supports deterministic JSON, CSV, Markdown, and HTML. Existing files are protected unless `-Force` is used.

Catalog changes belong in a local development checkout and are implemented by `Keldor.Build.PowerShell`, not by the
installed runtime module. Acronym removal remains a manual operation so historical meanings are preserved.
Candidate discovery and catalog merging remain deferred to
[Keldor issue 39](https://github.com/keldor-dev/Keldor/issues/39) and
[Keldor issue 40](https://github.com/keldor-dev/Keldor/issues/40).
