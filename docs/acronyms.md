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

## Catalog schema

The bundled catalog is a UTF-8 JSON array. Every record uses these properties in this order:

```json
{
  "Acronym": "API",
  "Meaning": "Application Programming Interface",
  "Category": "Development and DevOps",
  "Notes": "A defined interface used by software components to communicate."
}
```

`Acronym`, `Meaning`, and `Category` cannot be blank. Use an empty string when a record does not need a note.
Notes should add concise vendor, agency, historical, replacement, or ambiguity context rather than repeat the
meaning.

## Approved category taxonomy

Use the most specific applicable category:

| Category | Use for |
|---|---|
| Business and Program Management | Acquisition, contracts, projects, programs, governance, budgeting, planning, change management, service management, and business operations |
| Cloud | Cloud providers, cloud-native services, cloud architecture, and cloud resource abbreviations |
| Cybersecurity | Vulnerabilities, attacks, controls, incident response, encryption, security testing, and security frameworks |
| Development and DevOps | Programming, APIs, source control, CI/CD, software engineering, build systems, databases, containers, and orchestration |
| EOIR and Immigration | EOIR organizations, immigration courts and law, immigration case processing, and EOIR-specific systems |
| General | Concepts that do not fit a more specific approved category |
| Government | Agencies, laws, regulations, federal roles, government-wide programs, and official government organizations |
| Identity and Access Management | Authentication, authorization, identity providers, directory services, privileged access, credentials, identity-related certificates, and identity governance |
| Information Technology | Broad IT concepts that do not fit a more specific technical category |
| Infrastructure | Servers, storage, virtualization, operating platforms, hardware, data centers, and infrastructure platforms |
| Networking | Routing, switching, DNS, IP addressing, load balancing, network protocols, firewalls used as network infrastructure, WAN, and LAN technologies |

Do not introduce a new category merely because a term is unfamiliar. Prefer `General` only after considering the
specific technical, business, federal, and EOIR categories.

## Alternate meanings and duplicates

The same acronym may have multiple legitimate meanings. Preserve each distinct meaning as its own record and use
`Notes` when context is needed to distinguish historical, vendor-specific, agency-specific, or otherwise ambiguous
usage.

Duplicate detection is case-insensitive:

- An exact duplicate has equivalent acronym, meaning, category, and notes values and must not be added.
- Records with the same acronym and meaning but different metadata should be reviewed and consolidated unless the
  metadata distinction is intentional and documented.
- Near duplicates that differ only by punctuation or capitalization should use one verified canonical form.
- Similar-looking records must not be collapsed when they represent genuinely different meanings.

Removal is normally manual because the catalog intentionally retains historical and alternate meanings. Remove a
record only when it is demonstrably malformed, an exact duplicate, or a verified incorrect expansion.

## Proposing additions

Before adding an acronym:

1. Confirm that the same or an equivalent meaning is not already present.
2. Verify the expansion with an authoritative vendor, standards-body, government, or official project source.
3. Assign the most specific approved category.
4. Record useful context in `Notes` without copying the meaning.
5. Document the proposal, source, relevance, and confidence in the task's proposal artifacts.
6. Add only high-confidence proposals automatically; leave medium- and low-confidence terminology for review.

Catalog-writing commands are provided by the sibling `Keldor.Build.PowerShell` development module. They sort the
catalog deterministically and prevent exact duplicates.

## Local validation

The catalog quality tests run automatically with the repository's Pester suite and therefore run in the existing
PowerShell CI workflow:

```powershell
Invoke-Pester ./src/Keldor/Tests/AcronymCatalog.Tests.ps1
```

The tests validate JSON parsing, UTF-8 encoding without a BOM, schema and property order, required values, approved
categories, duplicates, deterministic sorting, whitespace, known capitalization errors, mojibake, generated
`stands for` prefixes, and a strong concatenated-record pattern.

For a quick inventory:

```powershell
$catalog = Get-Content ./src/Keldor/Resources/Acronyms.json -Raw |
    ConvertFrom-Json

$catalog.Count
$catalog | Group-Object Category | Sort-Object Name
$catalog | Group-Object Acronym, Meaning | Where-Object Count -GT 1
```
