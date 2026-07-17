# Versioning Policy

Keldor uses standard Semantic Versioning:

```text
MAJOR.MINOR.PATCH
```

The authoritative development version is the `ModuleVersion` in `src/Keldor/Keldor.psd1`. Normal development builds copy that manifest as-is and do not permanently rewrite source files.

## Reset to 0.1.0

Keldor previously used calendar-style versions such as `2024.12.1`. Those Keldor packages existed only in a private ProGet repository and are removed before using the new versioning scheme. Because there is no public Keldor release history to preserve, the Keldor package version resets to `0.1.0`.

WSTools is a separate package with an independent published version history. WSTools versions do not determine Keldor versions.

## Version Selection

Increment `MAJOR` for breaking public changes, including:

- Removing or renaming an exported command or alias.
- Removing or renaming a public parameter.
- Making a previously optional parameter mandatory.
- Changing parameter behavior incompatibly.
- Changing established output object types or property contracts incompatibly.
- Dropping a supported operating system or PowerShell version.
- Introducing an incompatible configuration or persistence format.
- Changing documented behavior in a way that requires consumers to modify existing automation.

Increment `MINOR` for backward-compatible features, including:

- Adding an exported command.
- Adding a backward-compatible parameter or alias.
- Adding a backward-compatible output property.
- Adding platform support.
- Adding a meaningful capability without breaking existing consumers.

Increment `PATCH` for backward-compatible maintenance, including:

- Bug fixes.
- Documentation corrections.
- Test improvements.
- Internal refactoring.
- Performance improvements with no public behavioral change.
- Build, packaging, or metadata corrections.

## Prereleases

Prerelease versions use a SemVer suffix:

```text
0.2.0-preview.1
0.2.0-preview.2
0.2.0-rc.1
0.2.0
```

PowerShell module manifests keep the numeric `ModuleVersion` separate from prerelease metadata. For example, `0.2.0-preview.1` is packaged as `ModuleVersion = '0.2.0'` with `PrivateData.PSData.Prerelease = 'preview.1'`.

## Build and Release Commands

Validate the source manifest:

```powershell
./build.ps1 -Task Validate
```

Create a normal development build:

```powershell
./build.ps1 -Task Build
```

Prepare a release package with an explicit version:

```powershell
./build.ps1 -Task Release -Version '0.1.0'
```

After release preparation and documentation validation, follow the canonical
[Keldor publishing runbook](https://github.com/keldor-dev/Keldor.Build.PowerShell/blob/main/docs/publishing/keldor-release.md).
It promotes the same staged artifact through SHRepo and then the PowerShell Gallery.

Do not use CI run numbers, dates, years, months, or commit counts as public package version components. CI identifiers may be used for build records, but the Git tag, GitHub release, module manifest, changelog, and package version must agree on the public SemVer version.

Git tags use this format:

```text
v0.1.0
```

## Release Checklist

- Select the next SemVer version using this policy.
- Confirm the changelog has an `Unreleased` section and, when preparing a release, an appropriate release heading.
- Run `./build.ps1 -Task Validate`.
- Run the Pester test suite.
- Run `./build.ps1 -Task Release -Version '<version>'`.
- Confirm `out/Keldor/Keldor.psd1` contains the selected version.
- Confirm the tag name is `v<version>`.
- Confirm the GitHub release, module manifest, changelog, and package version agree.
- Publish the staged artifact through SHRepo and the PowerShell Gallery by following the canonical publishing runbook.
