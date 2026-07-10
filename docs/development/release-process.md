# Release Process

## Overview

Every release should follow a predictable process to ensure module quality and documentation remain synchronized.

## Release Checklist

- Complete development.
- Resolve open blockers.
- Update documentation.
- Verify online help.
- Verify HelpUri values.
- Generate updateable help packages.
- Select the next version using the [Versioning Policy](versioning-policy.md).
- Update release notes.
- Publish documentation.
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

## Post Release

- Verify installation.
- Verify `Get-Help -Online`.
- Verify `Update-Help`.
- Close associated milestone.
