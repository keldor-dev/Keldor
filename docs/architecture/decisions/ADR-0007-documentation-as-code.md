# ADR-0007: Documentation as Code

| Property | Value |
|---|---|
| Status | Accepted |
| Date | 2026-07-07 |
| Decision Owner | Keldor Development Team |
| Applies To | Keldor documentation, standards, snippets, and public command design |

## Context

Keldor is not only a PowerShell module. It is becoming an ecosystem of modules, engineering standards, build tooling, templates, snippets, and documentation.

For that ecosystem to remain maintainable, documentation must live close to the code it describes and evolve with code changes.

Keldor also needs documentation to support users working in enterprise, government, and hardened environments where design rationale matters as much as implementation details.

## Decision

Keldor will treat documentation as source-controlled project code.

Documentation should be maintained alongside implementation changes and reviewed as part of normal engineering work.

Public PowerShell commands should eventually include:

- comment-based help
- `HelpUri`
- function-specific documentation pages
- examples
- tests where practical
- changelog entries for behavior changes

Architectural decisions should be captured as ADRs.

Engineering expectations should be captured in versioned standards.

Templates and VS Code snippets should align with the same documented standards.

## Rationale

Documentation as code keeps project knowledge from living only in memory, chat history, or tribal knowledge.

It also helps prevent future contributors from accidentally undoing deliberate decisions because the original reasoning was not obvious from the implementation.

Keldor's documentation, standards, templates, snippets, and build tooling should reinforce each other rather than drifting apart.

## Consequences

### Positive

- Design rationale is preserved.
- Public commands become easier to discover and use.
- Standards are easier to enforce.
- Snippets and templates can stay aligned with documented conventions.
- Future build tooling can validate documentation expectations.

### Negative

- Documentation must be maintained with code changes.
- Pull requests may require documentation updates.
- Standards and ADRs must be versioned and curated to avoid becoming clutter.

## Alternatives Considered

### Documentation After Release

Rejected because delayed documentation is more likely to be incomplete, inaccurate, or forgotten.

### External Wiki Only

Rejected because documentation should be versioned with the source code and reviewed with code changes.

### Comment Help Only

Rejected because comment-based help is necessary but not sufficient for architecture, standards, examples, and long-form guidance.

## Future Considerations

Keldor.Build.PowerShell should eventually validate documentation expectations, including:

- missing comment-based help
- missing `HelpUri`
- mismatched `HelpUri` and `.LINK`
- missing function documentation pages
- missing changelog entries for behavior changes
- standards conformance

Documentation validation should produce structured results suitable for local builds and CI.
