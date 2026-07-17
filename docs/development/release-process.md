# Release Process

## Overview

Every release should follow a predictable process to ensure module quality and documentation remain synchronized.
Keldor releases require the pinned `Keldor.Build.PowerShell` version installed by CI. Never publish Keldor with a
local development override.

## Release Checklist

- Complete development.
- Resolve open blockers.
- Update documentation.
- Verify online help.
- Verify HelpUri values.
- Generate updateable help packages.
- Complete the [PowerShell lifecycle review](powershell-lifecycle-policy.md) and update the compatibility matrix.
- Select the next version using the [Versioning Policy](versioning-policy.md).
- Update release notes.
- Publish documentation.
- Confirm Keldor.Build.PowerShell 0.2.0 is published and installable.
- Publish to the PowerShell Gallery.

## Documentation

Before every release:

- Update command reference pages.
- Verify examples.
- Publish Docusaurus site.
- Upload HelpInfo.xml and CAB packages.

## Versioning

Keldor follows Semantic Versioning as described in the [Versioning Policy](versioning-policy.md). The authoritative development version is `ModuleVersion` in `src/Keldor/Keldor.psd1`. Release packages are prepared with an explicit version:

```powershell
./build.ps1 -Task Release -Version '0.1.0'
```

Development builds do not permanently rewrite the source manifest:

```powershell
./build.ps1 -Task Build
```

Dropping older PowerShell runtimes is a breaking change. The source manifest remains at its development version until
release preparation selects the next major version; this refactor does not invent or publish that version.

## GitHub

Create:

- Release tag in `vMAJOR.MINOR.PATCH` format
- GitHub Release
- Release notes

## PowerShell Gallery

Publish only after documentation has been successfully deployed.

Documentation should always be available before users update the module.

```powershell
./build.ps1 -Task Publish -Version '0.1.0' -Repository PSGallery
```

The API key must come from the release environment or CI secret context; it does not belong in
`build.config.psd1`. The build module prepares `out/Keldor`, verifies the target version, and publishes only after
`ShouldProcess` approval.

## Cross-Repository Order

1. Merge, validate, and publish Keldor.Build.PowerShell 0.2.0.
2. Confirm the exact version can be installed from the repository used by Keldor CI.
3. Merge the Keldor consumer and CI changes.
4. Build, test, and inspect the Keldor package before any Keldor release.

## Post Release

- Verify installation.
- Verify `Get-Help -Online`.
- Verify `Update-Help`.
- Close associated milestone.
