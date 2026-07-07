# Keldor General Engineering Standard

| Property | Value |
|---|---|
| Version | 1.0 |
| Status | Stable |
| Applies To | All Keldor repositories |
| Last Updated | 2026-07-07 |

## Purpose

This standard defines baseline engineering expectations for all Keldor repositories, regardless of language or platform.

Language-specific standards inherit from this document and add implementation details for each ecosystem.

## Engineering Philosophy

Keldor projects should be:

1. Secure by default
2. Reliable under normal and failure conditions
3. Readable by future maintainers
4. Maintainable across versions
5. Portable where practical
6. Testable and documented
7. Consistent across repositories

## Design Principles

### Secure by Default

Projects should avoid insecure defaults, hardcoded secrets, unsafe dynamic execution, and unnecessary privilege requirements.

### Least Surprise

Similar commands, modules, repositories, and documentation should behave consistently.

### Discoverable

Public behavior should be documented, searchable, and easy to understand from repository structure and help content.

### Automatable

Builds, tests, analysis, packaging, and releases should be scriptable and repeatable.

### Standards Become Tooling

Standards should eventually map to automated checks in Keldor build tooling.

## Repository Structure

Every Keldor repository should have a predictable structure appropriate for its language and purpose.

Recommended root files:

- `.editorconfig`
- `.gitattributes`
- `.gitignore`
- `.markdownlint.json`
- `.markdownlintignore`
- `README.md`
- `CHANGELOG.md`
- `CONTRIBUTING.md`
- `SECURITY.md`
- `LICENSE`

Recommended directories:

- `.github/workflows/`
- `docs/`
- `src/`
- `tests/` or `Tests/`, depending on language convention
- `build/`

## Documentation Standards

Each repository should include a clear `README.md` with:

- Purpose
- Installation or usage
- Basic examples
- Compatibility notes
- Documentation links
- Issue or support guidance

Documentation should avoid stale metadata that Git already tracks, such as per-file author and last modified dates.

## Security Standards

Keldor projects should align with secure development practices and applicable guidance from:

- NIST Secure Software Development Framework
- NIST SP 800-53 where applicable
- DoD cybersecurity expectations where applicable
- DISA STIG principles where practical

Projects must not commit secrets, tokens, passwords, private keys, or environment-specific credentials.

## Dependency Management

Dependencies should be:

- Minimized
- Actively maintained
- Versioned where appropriate
- Reviewed for license compatibility
- Scanned for vulnerabilities when tooling supports it

## Git Standards

Repositories should use:

- LF line endings for source-controlled text files
- UTF-8 encoding
- Meaningful commit messages
- Pull requests for reviewed changes when practical
- Semantic version tags for releases

## Versioning

Keldor projects should use semantic versioning:

```text
MAJOR.MINOR.PATCH
```

Increment:

- `MAJOR` for breaking changes
- `MINOR` for backward-compatible features
- `PATCH` for backward-compatible fixes

## Release Process

A release should not occur until:

- Tests pass
- Static analysis passes
- Documentation is updated
- Changelog is updated
- Version numbers are updated
- Known critical security issues are addressed or documented

## CI/CD Expectations

Repositories should use CI where practical to validate:

- Formatting and linting
- Static analysis
- Tests
- Security checks
- Build/package generation

## Testing Expectations

Public behavior should have tests where practical.

Tests should cover:

- Happy path
- Invalid input
- Failure behavior
- Compatibility assumptions
- Security-sensitive behavior

## Licensing

Keldor repositories should include an explicit license file.

The preferred default license is MIT unless a repository has a specific reason to use another license.

## Code Review Process

Code review should consider:

- Security
- Maintainability
- Compatibility
- Documentation
- Test coverage
- Consistency with Keldor standards

## Future Enforcement

Future Keldor build tooling should provide checks such as:

- `Test-KeldorRepository`
- `Test-KeldorDocumentation`
- `Test-KeldorSecurity`
- `Test-KeldorCompatibility`
- `Test-KeldorEngineeringStandard`

The goal is for Keldor standards to become enforceable quality gates, not shelfware with nice headings.
