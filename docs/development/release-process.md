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
- Update module version.
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

Keldor follows Semantic Versioning.

- Major
- Minor
- Patch

## GitHub

Create:

- Release tag
- GitHub Release
- Release notes

## PowerShell Gallery

Publish only after documentation has been successfully deployed.

Documentation should always be available before users update the module.

## Post Release

- Verify installation.
- Verify `Get-Help -Online`.
- Verify `Update-Help`.
- Close associated milestone.
