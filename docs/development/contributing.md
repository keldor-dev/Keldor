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
