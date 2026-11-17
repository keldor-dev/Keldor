# Function architecture refactoring progress

2026-11-16. Source architecture pass completed for the active runtime and supporting build families.
Windows/Linux integration and legacy application-module modernization remain outside the completed validation.
Follow the existing PowerShell Engineering and Input/Output standards. This report does not define a new standard.

## Baseline and scope

- The primary repository was clean before work. No commits, pushes, or pull requests were made.
- AST inventory covered 340 function definitions in `src/Keldor` (273 under Public), including supporting scripts.
  This is a static dependency scan, not a claim that every implementation has had a complete behavioral review.
- Additional AST discovery covered sibling build, application-management, and documentation repositories.
  Generated `out`/`artifacts` copies, legacy build tooling, and historical code are not refactoring targets.
- Read repository AGENTS.md, contributor guidance, engineering standards, and input/output contracts first.
- All changes were first implemented and validated in an isolated copy. Runtime imports stayed offline.

## Implemented batch: inventory

Refactored `Get-KeldorSystemInfo`, `Get-KeldorOperatingSystem`, `Get-KeldorLinuxDistribution`,
`Get-KeldorKernel`, `Get-KeldorUptime`, and `Get-KeldorHardwareInfo`.

Each public source file now owns its structured result construction. The aggregate SystemInfo command reads one
snapshot directly instead of constructing five intermediate result objects. Memory and version conversions preserve
the original contracts. The Linux applicability check now resides in its public command.

- Eliminated six public pass-through implementations.
- Removed `ConvertTo-KeldorInventoryResult` and its generic Type dispatch.
- Replaced `Invoke-KeldorInventoryCollection` with `Get-KeldorInventorySnapshot`, which handles collection only.
  TargetKind still expresses the three meaningful transport contracts; it does not select unrelated operations.
- Removed six obsolete `New-Keldor*Result` inventory constructors. Eight private functions were retired and one
  collection helper added, a net reduction of seven. No exported command or alias was removed.
- Retained snapshot collection, per-target failure normalization, session ownership/cleanup, remote module execution,
  platform detection, OS-specific collectors, parsing, and virtualization helpers. These isolate real platform,
  resource-lifecycle, and data-acquisition responsibilities.
- Repository/ecosystem reference searches found no active consumers of the retired helpers outside this family.
  Generated package copies were excluded from source edits and rebuilt separately.

### Dependency comparison

Before, result construction required public command -> collection dispatcher -> result dispatcher -> constructor,
with further constructor/version-conversion calls for aggregate inventory (three to five custom delegation layers).
After, result construction is visible in the public file with at most one version-conversion dependency.

The collection path intentionally retains deeper calls: public command -> inventory snapshot collection -> local
snapshot selection -> platform collector -> platform parser/normalizer. OS identification also uses the loader-safe
bootstrap boundary. Remote collection retains its session execution boundary. These are real responsibilities;
the maximum depth of the entire collection graph has not been artificially reduced.

## Validation

| Check | Before | After |
|---|---:|---:|
| Full Pester, local build provider configured | 244 passed, 0 failed | 256 passed, 0 failed |
| Opt-in integration tests excluded | 2 | 2 |
| Repository-configured PSScriptAnalyzer | 0 findings | 0 findings |
| Syntax errors in indexed production source | 0 | 0 |
| Current macOS exported functions | 37 | 37 |

An initial run without the build-provider override had 237 passes and seven failures caused by the unavailable
installed `Keldor.Build.PowerShell` 0.2.0 module. Re-running both original and refactored copies with
`KELDOR_BUILD_MODULE_PATH` pointing to the existing local 0.2.0 repository resolved those failures without code changes.

- All 31 existing inventory tests pass. Internal-constructor tests now exercise public commands with mocked snapshots;
  their output assertions remain intact.
- Added 12 tests for per-target failures, credential forwarding, owned-session cleanup, supplied-session reuse,
  Linux applicability/terminating errors, unidentified failure objects, and exactly one local snapshot per command.
- Differential comparison of 44 complete output objects matched property order, values, native types, and PSTypeName.
  Fixtures covered populated/missing data on Windows, Linux, macOS, and unidentified failed targets.
- Exact runtime command metadata comparison preserved exports, aliases, parameter sets, parameter types, and attributes.
  Public parameter/attribute source blocks were preserved across all platforms.
- Build with the existing local build provider succeeded without publishing. Its package contains the new collection
  helper and excludes the retired helpers. Source manifest versions remain unchanged.
- Analyzer configuration includes the Windows PowerShell 5.1 compatible-syntax check. Native Windows PowerShell 5.1,
  Windows/Linux integration, real WSMan/SSH targets, and credentials were not exercised on this macOS host.

## Reviewed abstractions retained

- Legacy `Get-UpTime`, `Get-SerialNumber`, `Get-ComputerModel`, and `Test-Online` preserve supported historical schemas.
- `Get-KeldorPlatform` retains the loader-safe bootstrap implementation rather than duplicating platform detection.
- URL launch commands retain shared configured URL resolution, platform launch behavior, and ShouldProcess handling.
- Secret commands retain provider selection, credential/secure-string handling, and vendor boundaries; these are
  meaningful provider contracts, not unrelated-operation dispatchers.
- `Invoke-KeldorCommand` retains target validation, job/session lifecycle, retries, timeout handling, remote execution,
  and result/error normalization. Deep paths need these distinct responsibilities.
- Acronym commands retain catalog loading/caching and meaningful filtering/export behavior.
- Build-provider dispatch in sibling repositories is a real extension contract and remains outside the runtime module.

## Continued comprehensive pass

- Revisited all remaining custom-call and single-use-helper candidates across the runtime source. The retained
  dependencies above provide platform, provider, security, lifecycle, parsing, or compatibility value.
- Inlined the OnePassword write rejection into `Set-KeldorSecret` and removed the single-use
  `Set-KeldorSecretToOnePassword` helper. The public file now shows the executable-presence check and the existing
  unsupported-write error. This does not enable a new write method. ShouldProcess still runs before any provider probe.
- Added two tests for the missing CLI and WhatIf preventing the CLI probe. Existing provider, SecureString, Force,
  exception-sanitization, alias, and output tests remain intact.
- Current runtime inventory: 332 definitions, down from 340. Seven public implementations have been refactored in
  total; six forwarding implementations were eliminated. Nine private definitions were retired and one collection
  helper added across both passes. The generic result dispatcher was removed; collection now has no result-Type dispatch.
- The [function inventory](function-architecture-inventory.csv) records all current source definitions, custom
  dependencies, dynamic invocation counts, and self-recursion. It is a source index, not a depth rejection gate or a
  substitute for integration tests. Native/external commands are not counted as custom delegation.
- Reviewed the nine Keldor.Build, 25 Keldor.Build.PowerShell, and five documentation-tool definitions. Build provider
  callbacks remain a legitimate extension mechanism. Isolated suites pass: Keldor.Build 2/2; Keldor.Build.PowerShell 37/37.
  An initial combined test-session invocation had 15 setup failures; separate supported sessions pass without changes.
- Reviewed the 46 legacy application-management definitions. That module's loader scans Public/Private, while the
  actual scripts are under Functions and are not loaded. Reconnecting them would change exports and expose old state-
  changing installer workflows. No new shared installer engine or export expansion was introduced under this refactor.
  The eleven legacy build-generator definitions and nine standards templates are not active runtime targets.

Final full runtime Pester: **258 passed, zero failed, two opt-in integration tests excluded**. Analyzer: **zero findings**.
Actual exports and parameter metadata still match the pre-refactor baseline exactly. The package build succeeds, and
source manifest versions are unchanged. New source and test files parse successfully on the available PowerShell host.

## Remaining work outside the source refactor

1. Run native Windows PowerShell 5.1 and Windows/Linux integration against controlled fixtures, including retained
   remoting/platform/secret-provider paths. Static compatibility analysis does not replace these runtime checks.
2. Scope a separate functional modernization of the disconnected application-management module before changing its
   loader, exports, installer semantics, or concurrency implementation. Its substantial duplication is recorded, not
   silently converted into a new runtime dependency.
3. Preserve supported legacy wrappers and provider boundaries unless a separately tested compatibility change is
   authorized. Do not update generated package copies by hand.
