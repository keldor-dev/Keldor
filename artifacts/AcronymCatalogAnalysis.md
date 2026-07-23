# Keldor Acronym Catalog Analysis

## Scope and baseline

This report analyzes `src/Keldor/Resources/Acronyms.json` as it existed at the start of the normalization work.
The baseline already includes the 523 curated records added immediately before this task.

| Measure | Baseline |
|---|---:|
| Total records | 2,131 |
| Unique acronym strings (case-insensitive) | 1,834 |
| Unique acronym-and-meaning pairs (case-insensitive) | 2,131 |
| Categories | 14 |
| Exact duplicate groups | 0 |
| Exact duplicate records beyond the preferred copy | 0 |
| Clear punctuation-only near-duplicate groups | 1 |
| Acronyms with multiple meanings | 227 |

## Records per category

| Category | Records |
|---|---:|
| Business and Program Management | 153 |
| Cloud | 251 |
| Cybersecurity | 120 |
| Development | 1 |
| Development and DevOps | 68 |
| EOIR and Immigration | 76 |
| General | 767 |
| Government | 149 |
| HAM Radio | 10 |
| Identity and Access Management | 62 |
| Information Technology | 362 |
| Infrastructure | 67 |
| Networking | 44 |
| Operating System | 1 |

`Development` overlaps `Development and DevOps` and should be consolidated. `Operating System` is covered by
`Infrastructure`. `HAM Radio` is too narrow for the controlled taxonomy; its radio and signaling records fit
`Networking`.

## Schema and structural validation

- Missing required properties: **0**
- Unexpected properties: **0**
- Null property values: **0**
- Blank `Acronym` values: **0**
- Blank `Meaning` values: **0**
- Blank `Category` values: **0**
- Leading or trailing whitespace: **0**
- Duplicate spaces in property values: **0**
- Invalid JSON: **0**
- Unsorted records: **0**

Every baseline record has the four expected properties in the expected order.

## Exact and near duplicates

No exact duplicate records or duplicate acronym-and-meaning pairs were present.

One clear punctuation-only near duplicate was found:

| Acronym | Variant 1 | Variant 2 | Decision |
|---|---|---|---|
| CBA | Certificate Based Authentication | Certificate-Based Authentication | Prefer the hyphenated compound modifier and consolidate. |

Additional meaning pairs appear semantically equivalent but need either normalization or manual judgment:

- `AKS`: `Azure AKS cluster` / `Azure Kubernetes Service`
- `DNS`: `Domain Name Service` / `Domain Name System`
- `ITSM`: `Information Technology Service Management` / `IT Service Management`
- `SATA`: `Serial Advanced Technology Attachment` / `Serial ATA`
- `SIEM`: `Security Incident Event Management` / `Security Information and Event Management`
- `URI`: `Uniform Resource Identifier` / `Universal Resource Identifier`
- `VERA`: `Voluntary Early Retirement Authority` / `Voluntary Early Retirement Authorization`
- `ZCC`: `Zscaler Client Connect` / `Zscaler Client Connector [ZAPP]`

The preferred, authoritative form should be retained where the other form is demonstrably erroneous. Ambiguous
historical or organization-specific variants should remain for manual review.

## Acronyms with multiple meanings

The following 227 acronym strings have two or more meanings. Alternate meanings are expected and must not be
collapsed merely because the acronym is shared:

`AA`, `AAR`, `ACA`, `ACE`, `ACS`, `ACT`, `AD`, `ADE`, `ADLS`, `ADO`, `ADS`, `AFS`, `AG`, `AKS`, `AMD`, `ANC`,
`App`, `ARP`, `ASA`, `ASE`, `ASR`, `ATO`, `AV`, `AVM`, `AWS`, `AZ`, `BA`, `Bas`, `BEK`, `BES`, `BIA`, `BLM`,
`BMC`, `BOD`, `BPA`, `C`, `CA`, `CAP`, `CAS`, `CBA`, `CC`, `CEF`, `CFR`, `CHAP`, `CI`, `CIA`, `CM`, `CMS`,
`CO`, `COOP`, `CP`, `CPM`, `CR`, `CS`, `CSA`, `CSAM`, `CSC`, `CSD`, `CSF`, `CSP`, `CSS`, `CVA`, `DA`, `DAM`,
`DAR`, `DAST`, `DCE`, `DDR`, `DEP`, `DES`, `DLA`, `DME`, `DML`, `DMS`, `DNA`, `DNS`, `DoD`, `DOE`, `DP`,
`DRP`, `DRS`, `DS`, `DTD`, `EA`, `EAP`, `ECS`, `EDC`, `EDR`, `EFS`, `EKU`, `EO`, `EPM`, `ESC`, `ESP`, `FCA`,
`FCI`, `FDE`, `FS`, `FSA`, `FTP`, `GAC`, `Gal`, `GPS`, `HCS`, `HSA`, `HUD`, `IC`, `ICD`, `ICE`, `ID`, `IDF`,
`IdM`, `IM`, `IMP`, `iOS`, `IoT`, `IP`, `IPMI`, `IRC`, `IRM`, `IS`, `ISA`, `ISDN`, `ISE`, `ISMS`, `IT`,
`ITSM`, `JCAM`, `JCON`, `KM`, `KMS`, `KVM`, `LGD`, `LOE`, `MAC`, `Map`, `MC`, `MCU`, `ML`, `MM`, `MOD`,
`MOF`, `MP`, `MS`, `MSA`, `MSP`, `MVP`, `NCC`, `NFC`, `NLA`, `NUMA`, `NYC`, `NYV`, `O&M`, `OA`, `OGC`,
`OIT`, `OPS`, `ORR`, `OS`, `OSC`, `OSD`, `OSI`, `PA`, `PAA`, `PaaS`, `PAT`, `PC`, `PCR`, `PEP`, `PFT`, `PHI`,
`PI`, `PIM`, `PIP`, `PIPE`, `PLA`, `POC`, `PSL`, `PTO`, `QRDS`, `RA`, `RAID`, `RAP`, `RDC`, `RF`, `RFC`,
`ROC`, `RPC`, `RSA`, `RSS`, `SA`, `SAS`, `SAST`, `SATA`, `SCA`, `SCEP`, `SCM`, `SD`, `SDLC`, `SE`, `SES`,
`SIEM`, `SM`, `SP`, `SPM`, `SPRA`, `SQL`, `SRA`, `SSC`, `SSE`, `SSIS`, `SSP`, `SSS`, `St`, `STA`, `TAR`,
`TS`, `URI`, `VDI`, `VERA`, `VIP`, `VPP`, `WAF`, `WAP`, `WAS`, and `ZCC`.

## Suspicious or malformed content

### High-confidence repair candidates

- `IPMI` has a second meaning containing two concatenated records:
  `Intelligent Platform Management Interface (IPMI)IPPre - Azure public IP address PREfix (IPPRE)`.
  A valid `IPMI` record already exists, so the concatenated record is malformed.
- `OMP` contains a second `OP` record appended to its meaning:
  `Office of Management Programs (OMP)OP - Office of Policy (OP)`. A separate valid `OP` record already exists.
- Mojibake affects `RSA`, `SAFe`, two `PIPE` meanings, `TMOS`, `YAGNI`, and `YAML`.
- `MECM` begins with the catalog-generation phrase `stands for`.
- Known casing errors occur in `DataBase`, `FireWall`, `HyperVisor`, `NameSpace`, `EndPoint`, `BluePrint`,
  `AntiVirus`, `file System`, `OPerations`, `IMprovement`, and `ARchive`.
- `No Fear` is not the official capitalization of the `NO FEAR Act`, and its meaning repeats the word `Act`.
- `PIM` contains `Process IMprovement plan`.
- `TMOS` is categorized as business management even though it is an F5 network operating system.
- `RHEL` is the only record in `Operating System`.
- `API` is the only record in `Development`.

### Inconsistent terminology

- `Command-Line Interface` and `command-line interface` appear with different casing. Descriptive uses should prefer
  `command-line interface`; official product names should be preserved.
- `Two-factor Authentication` and related multifactor terms use inconsistent title casing and hyphenation.
- `Database`, `Firewall`, `Hypervisor`, `Namespace`, `Endpoint`, and `Blueprint` have inconsistent internal casing.
- Azure resource naming abbreviations mix sentence-style descriptions with expansion-style meanings.
- Several general IT records are in `General` while comparable records already use a specific technical category.
- `DCIN` has a generated local file-path note rather than concise context.

## Suspicious acronym values

The catalog contains words or naming-convention abbreviations that may not be acronyms in the ordinary sense:

`Aplos`, `App`, `Avail`, `Bas`, `Cld`, `Con`, `Cosmos`, `Disk`, `Face`, `Func`, `Gal`, `Git`, `Hadoop`, `Host`,
`Hub`, `Ibid`, `Kafka`, `Lang`, `Log`, `Logic`, `Map`, `Maria`, `Migr`, `Ntf`, `Pack`, `Peer`, `Pview`, `Redis`,
`Rule`, `Share`, `Snap`, `Spark`, `Spch`, `Storm`, `Tax`, `Traf`, and `Trsl`.

Most appear to come from an Azure or Nutanix resource-naming convention. They are preserved pending a deliberate
decision about whether the catalog covers internal resource abbreviations in addition to acronyms.

## Possible corruption or concatenation

- The malformed second `IPMI` meaning and the `OMP`/`OP` combination are high-confidence concatenated records.
- `DOJ/EOIR-IRIES` is unusually long and compound, but it is a plausible system identifier and should be preserved.
- `Git` explicitly states that it is not an acronym. Preserve it for now because the record intentionally documents
  that fact, but consider moving non-acronym terminology to a separate glossary in a future change.

## Categories that appear redundant

| Current category | Controlled category | Rationale |
|---|---|---|
| Development | Development and DevOps | Direct overlap; only one record. |
| Operating System | Infrastructure | Operating platforms are explicitly covered by Infrastructure. |
| HAM Radio | Networking | Radio communications and signaling are networking concepts; only ten records. |

No additional category is necessary based on the baseline data.

## Records requiring manual review

- Azure and Nutanix word-based resource abbreviations listed under “Suspicious acronym values.”
- `AD`: `Active Directory` and `Microsoft Active Directory` appear equivalent, but a future canonical form may be
  `Active Directory Domain Services` depending on intended scope.
- `ATO`: `Authority To Operate` and `Authorization to Operate`.
- `BIA`: `Business Impact Analysis` and `Business Impact Assessment`.
- `EDR`: `Endpoint Detection and Response` and `Enterprise Detection & Response`.
- `EKU`: `Enhanced Key Usage` and `Extended Key Usage`; both occur in industry documentation.
- `JCAM`: three closely related DOJ/Justice expansions that may represent naming history.
- `JCON`: variants with and without `Automation`.
- `NUMA`: `Access` and `Architecture`.
- `PIPE`: current and historical SAFe terminology needs context rather than silent removal.
- `SPM`: the meaning `Bloomington` appears incomplete.
- `ISDN`: `It Still Does Nothing` is humorous rather than technical, but may be intentionally historical.
- `Git` and `Ibid` are explicitly non-acronym glossary terms.

## Initial normalization decisions

The normalization pass may safely:

1. Consolidate the three redundant categories.
2. Normalize deterministic property order, whitespace, approved terminology, and mojibake.
3. Remove the punctuation-only `CBA` duplicate.
4. Remove the malformed second `IPMI` record while preserving the valid definition.
5. Consolidate only demonstrably erroneous semantic duplicates.
6. Preserve all other alternate meanings and manual-review records.
7. Reassign clearly miscategorized technical records using the controlled taxonomy.

## Normalization outcome

The completed normalization produced the following result:

| Measure | Baseline | Final |
|---|---:|---:|
| Total records | 2,131 | 2,138 |
| Unique acronym strings | 1,834 | 1,852 |
| Unique acronym-and-meaning pairs | 2,131 | 2,138 |
| Categories | 14 | 11 |
| Exact duplicate groups | 0 | 0 |
| Repeated acronym-and-meaning pairs | 0 | 0 |
| Clear punctuation-only near-duplicate groups | 1 | 0 |

Changes applied:

- Consolidated `Development`, `HAM Radio`, and `Operating System` into the controlled taxonomy.
- Corrected or recategorized **314** existing records.
- Consolidated **10** clear near-duplicate records.
- Removed **1** malformed concatenated `IPMI` record.
- Repaired the concatenated `OMP` meaning while preserving the separate `OP` record.
- Added **18** externally verified, high-confidence proposals.
- Left **3** medium-confidence proposals in the proposal artifacts for manual review.
- Preserved the ambiguous and historical records identified in the manual-review section.

Final records per category:

| Category | Records |
|---|---:|
| Business and Program Management | 173 |
| Cloud | 263 |
| Cybersecurity | 152 |
| Development and DevOps | 99 |
| EOIR and Immigration | 79 |
| General | 648 |
| Government | 167 |
| Identity and Access Management | 94 |
| Information Technology | 187 |
| Infrastructure | 157 |
| Networking | 119 |
