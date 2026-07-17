# PowerShell Lifecycle Review Policy

| Property | Current value |
|---|---|
| Minimum Windows PowerShell version | 5.1 |
| Minimum PowerShell Core version | 7.4 |
| Preferred development version | PowerShell 7.6 LTS |
| CI-tested versions | Windows PowerShell 5.1; PowerShell 7.4, 7.5, and 7.6 as defined in CI |
| Retired versions removed from CI | Windows PowerShell 2.0-5.0; PowerShell Core 6.x; PowerShell 7.0-7.3 |
| Documentation last reviewed | 2026-07-16 |
| Next known milestone | Review before the next Keldor release or when Microsoft changes a tested line's support status |

Maintainers review the PowerShell support matrix:

- before every Keldor major or minor release;
- when Microsoft releases a new PowerShell LTS version;
- when a supported PowerShell release approaches end of support; and
- at least quarterly while Keldor supports multiple PowerShell 7 release lines.

Each review checks Microsoft's current PowerShell and .NET lifecycle documentation and records the fields in the table
above. The review updates the compatibility matrix, runtime-guard minimum, CI jobs, development guidance, changelog,
and next known lifecycle milestone together.

Retired PowerShell lines are removed from positive CI coverage. Negative runtime-policy behavior is tested with
injected version and edition data; CI does not install retired runtimes solely to prove rejection. Raising the minimum
supported runtime is a breaking change and follows Keldor's semantic-versioning policy.

Production import never queries lifecycle services and does not embed a retirement-date database. The published code
minimum remains deterministic until a reviewed Keldor release raises it.
