# Remote Command Orchestration

`Invoke-KeldorCommand` is Keldor's canonical entry point for executing PowerShell code locally or through PowerShell
remoting. It establishes stable target, transport, result, error, timeout, retry, and session-ownership contracts
without reimplementing the remoting protocol.

## Execution model

| Target selector | Transport | Notes |
|---|---|---|
| `Local` | `Local` | Runs in the current runspace and creates no remoting session. |
| `Session` | Existing session transport | Reuses caller-owned `PSSession` objects. |
| `ComputerName` | `WSMan` | Uses native `Invoke-Command` WSMan parameters. |
| `HostName` | `SSH` | Requires a supported PowerShell 7 runtime and native SSH remoting. |

`ScriptBlock` forwards a script block and positional `ArgumentList` objects. `KeldorCommand` accepts only a validated
Keldor-style command name. It imports Keldor on the target, resolves the command from that module, and invokes it with
a parameter hashtable. It never builds executable command text and never uses `Invoke-Expression`.

The eight public parameter sets are `LocalScriptBlock`, `SessionScriptBlock`, `WsManScriptBlock`, `SshScriptBlock`,
`LocalKeldorCommand`, `SessionKeldorCommand`, `WsManKeldorCommand`, and `SshKeldorCommand`. Pipeline strings bind to
`ComputerName` by default. Targets are buffered so orchestration can retain order and apply bounded target batches.
Exact duplicates are preserved; distinct DNS spellings are not normalized or merged.

## Result contract

Structured mode returns one `Keldor.CommandExecutionResult` per target. Results from one invocation share one
`CorrelationId`. The stable properties are:

```text
ComputerName, Target, TargetType, Transport, SessionId, InvocationType, CommandName, Succeeded, Status,
AttemptCount, StartedAt, CompletedAt, Duration, Output, Errors, ErrorId, ErrorCategory, ErrorMessage,
ExceptionType, WasTimedOut, WasRetried, PowerShellVersion, RunspaceId, CorrelationId
```

Implemented status values are `Succeeded`, `Failed`, `TimedOut`, `ConnectionFailed`, `SessionUnavailable`, and
`Unsupported`. Implemented transport values are `Local`, `WSMan`, `SSH`, and the transport reported by an existing
session (or `ExistingSession` when unavailable). Timestamps are UTC `datetimeoffset` values, `Duration` is a
`timespan`, and `CorrelationId` is a `guid`. `Output` preserves objects and `Errors` preserves error records.

`RawOutput` writes unwrapped output to the success stream and normalized target failures to the error stream. It does
not mix envelopes with raw output, so Keldor timing and correlation metadata are unavailable in that mode. Native
remoting metadata such as `PSComputerName` remains when PowerShell supplies it.

Remote output follows PowerShell remoting serialization. Objects usually return as deserialized representations,
methods can be unavailable, property types can be adapted, and type names can have a `Deserialized.` prefix. Keldor
does not attempt unsafe object rehydration.

## Errors, timeouts, and retries

Invalid command-wide input is terminating. Structured mode records operational target failures in result objects;
raw mode emits normalized errors. Stable identifiers include:

- `Keldor.InvalidRemoteCommandName`
- `Keldor.RemoteConnectionFailed`
- `Keldor.RemoteInvocationFailed`
- `Keldor.RemoteInvocationTimedOut`
- `Keldor.RemoteSessionUnavailable`
- `Keldor.RemoteModuleUnavailable`
- `Keldor.RemoteCommandUnavailable`
- `Keldor.SshRemotingNotSupported`

`TimeoutSec` is the maximum elapsed time for one remote target attempt. On timeout, Keldor stops and removes only its
invocation job; it never removes the caller-owned session. Local execution stays in-process. Windows PowerShell 5.1 has
no safe general mechanism for cancelling an arbitrary in-process script block, so local timeout is not enforced.

`RetryCount` is the number of additional attempts after the first. Only failures conservatively classified as
transient connection or transport failures are eligible. Authentication, authorization, parameter binding, parsing,
command-not-found, missing-module, unsupported-transport, and remote command-logic failures are not retried. A script
block can cause a remote side effect before a connection failure becomes visible, so callers must consider idempotency.

`ConnectingTimeout` retains the native SSH meaning in milliseconds. `TimeoutSec` is a Keldor per-attempt limit. A
caller-supplied WSMan `SessionOption` is forwarded without mutation; native open, operation, and idle settings remain
independently effective.

## Session and security boundaries

Caller-supplied sessions are never removed, disposed, recreated, reconfigured, or silently reconnected. An unavailable
session returns `SessionUnavailable`. Keldor-created jobs are cleaned up after completion, failure, or timeout. This
version does not create a persistent session pool.

`Credential` accepts only `PSCredential` and is forwarded only to WSMan. SSH supports the native `UserName`,
`KeyFilePath`, `Port`, `Subsystem`, `ConnectingTimeout`, and `SSHTransport` parameters. Key contents and credentials are
never returned or logged. Windows PowerShell 5.1 returns `Keldor.SshRemotingNotSupported` before native binding fails.

Keldor does not probe transports, require ICMP, fall back between WSMan and SSH, enable remoting, configure SSH,
modify firewalls or TrustedHosts, change authentication policy, disable certificate validation, persist credentials,
install certificates, install Keldor remotely, or contact a package repository. `WhatIf` and `Confirm` belong to an
invoked command that implements `ShouldProcess`; Keldor does not simulate arbitrary code.

## Relationship to system information commands

`Get-KeldorSystemInfo`, `Get-KeldorOperatingSystem`, `Get-KeldorLinuxDistribution`, `Get-KeldorKernel`,
`Get-KeldorUptime`, and `Get-KeldorHardwareInfo` retain their current remoting helper for this change. A later migration
can move target orchestration onto the approved private engine while keeping existing local snapshot collectors as the
single source of data. The orchestration layer must call those local collectors remotely; inventory commands must not
call themselves through `Invoke-KeldorCommand`, which would create recursion.

## Deferred orchestration features

- Ephemeral Keldor execution and automatic remote module deployment
- Session pooling and persistent connection profiles
- Target inventory integration and discovery
- Background execution and disconnected sessions
- Cancellation and streaming result mode
- Cloud Run Command transports
- Rich progress reporting
- `Test-KeldorConnection`

These are extension points, not implied capabilities of the initial contract.
