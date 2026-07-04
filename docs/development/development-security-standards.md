# Keldor Development & Security Standards

## Purpose

This document defines the engineering, security, and compatibility standards for all Keldor projects.

These standards are intended to produce modules that are:

- Secure by default
- Cross-platform
- Backwards compatible where practical
- Consistent across repositories
- Enterprise and government ready

---

## Security Standards

### Secure by Design

All Keldor projects should follow secure development practices throughout the software lifecycle.

Security should never be considered an optional feature.

---

### NIST Guidance

Where applicable, projects should align with:

- NIST SP 800-53 Rev. 5
- NIST Secure Software Development Framework (SSDF)
- NIST SP 800-218
- NIST Cybersecurity Framework (CSF)

Not every control applies to an open-source PowerShell module, but developers should implement applicable controls whenever practical.

---

### Department of Defense Guidance

Where practical, projects should also align with:

- DoD Secure Coding Guidelines
- DISA Security Technical Implementation Guides (STIGs)
- DoD Zero Trust principles
- DoD 8140 workforce expectations for secure automation

---

### Secure Coding

Code should:

- Validate all inputs
- Avoid command injection
- Avoid unsafe string interpolation
- Never execute user input directly
- Fail securely
- Provide useful error messages without exposing sensitive information

---

### Secrets

Secrets must never be:

- Hardcoded
- Stored in source control
- Embedded in examples

Use:

- SecretManagement
- Environment variables
- Platform credential stores

---

### Logging

Never log:

- Passwords
- Tokens
- API Keys
- Connection strings
- Personally Identifiable Information (PII)

---

### Dependencies

Dependencies should:

- Be minimized
- Be actively maintained
- Be reviewed for licensing
- Be scanned for vulnerabilities

---

## PowerShell Standards

### Supported Versions

Projects should support:

Preferred

- PowerShell 7+

Where practical

- Windows PowerShell 5.1

Legacy compatibility

- Windows PowerShell 2.0 when doing so does not significantly increase complexity or reduce maintainability.

Backward compatibility should never prevent important security improvements.

---

### Cross Platform

Modules should work on:

- Windows
- macOS
- Linux

Platform-specific code should be isolated behind helper functions whenever possible.

---

### Avoid Windows-only APIs

Do not assume availability of:

- Registry
- WMI
- COM
- WinForms
- Windows-only executables

Use .NET Standard APIs when possible.

---

### Approved Verbs

All exported functions must use approved PowerShell verbs.

---

### Error Handling

Use:

- Try/Catch
- Throw meaningful exceptions
- Write-Verbose
- Write-Debug

Avoid:

- Silent failures
- Empty catch blocks

---

### Parameter Design

Functions should:

- Support pipeline input where appropriate
- Support ShouldProcess for destructive actions
- Use ValidateSet where practical
- Use ValidatePattern where appropriate
- Include Help metadata

---

### Performance

Avoid:

- Unnecessary object creation
- Repeated pipeline enumeration
- Excessive Write-Host usage

Prefer streaming objects over building large collections in memory.

---

## Testing

Every public function should have automated tests.

Preferred frameworks:

- Pester

Tests should include:

- Happy path
- Invalid input
- Error conditions
- Cross-platform behavior

---

## Documentation

Public functions require:

- Comment-based help
- Examples
- Parameter descriptions

Repositories should include:

- README
- CHANGELOG
- LICENSE
- CONTRIBUTING

---

## Code Style

Follow the Keldor PowerShell Naming Standards.

Use:

- Four-space indentation
- UTF-8 encoding
- LF line endings
  - Repository source files shall use UTF-8 encoding and LF (\n) line endings. Git is responsible for any platform-specific conversion during checkout.
- Meaningful variable names
- Singular nouns for object variables

---

## Quality Gates

Before release:

- PSScriptAnalyzer passes
- Pester tests pass
- Documentation updated
- CHANGELOG updated
- Version incremented
- No known critical security issues

---

## Philosophy

Keldor prioritizes:

1. Security
2. Reliability
3. Readability
4. Maintainability
5. Portability
6. Performance

Code should be written as though it may one day be used in enterprise, government, or critical infrastructure environments.
