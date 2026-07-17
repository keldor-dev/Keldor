function Invoke-KeldorCommand {
    <#
    .SYNOPSIS
        Executes PowerShell code locally or through an explicit remoting transport.

    .DESCRIPTION
        Provides Keldor's canonical orchestration entry point for local execution, caller-owned PSSession reuse,
        WSMan targets, and PowerShell remoting over SSH. By default, it returns one
        Keldor.CommandExecutionResult per target. Exact duplicate targets are preserved in input order.

        Script blocks and arguments are forwarded as objects. Remote output follows normal PowerShell remoting
        serialization rules and may contain deserialized objects without their original methods. The KeldorCommand
        mode imports Keldor on the target, resolves only a command from that module, and invokes it with object-based
        parameter splatting. Keldor is not installed or copied to the target automatically.

        TimeoutSec applies to each remote attempt. Local execution remains in-process and cannot be cancelled safely
        on Windows PowerShell 5.1, so TimeoutSec is recorded but not enforced for Local targets. RetryCount applies
        only to failures classified as transient connection or transport failures. Caller-supplied sessions are never
        removed, reconfigured, reconnected, or disposed.

        This command does not support ShouldProcess because it cannot determine whether caller-supplied code changes
        state. WhatIf and Confirm behavior belongs to an invoked command that implements ShouldProcess.

    .PARAMETER Local
        Selects in-process execution on the current computer without creating a remoting session.

    .PARAMETER Session
        Specifies caller-owned PSSession objects to reuse. Unavailable sessions produce per-target failure results.

    .PARAMETER ComputerName
        Specifies WSMan targets. Values may be supplied through the pipeline and are buffered for orchestration.

    .PARAMETER HostName
        Specifies SSH remoting targets. SSH remoting requires PowerShell 7.4 or later.

    .PARAMETER ScriptBlock
        Specifies PowerShell code to execute. Keldor does not parse, rewrite, or stringify the script block.

    .PARAMETER ArgumentList
        Specifies objects forwarded positionally to ScriptBlock.

    .PARAMETER KeldorCommand
        Specifies an installed Keldor command name to resolve and invoke on the selected target.

    .PARAMETER Parameter
        Specifies named parameter values forwarded as objects to KeldorCommand.

    .PARAMETER Credential
        Specifies a PSCredential for WSMan. Credential contents are never logged or returned.

    .PARAMETER Authentication
        Specifies the native WSMan authentication mechanism. Keldor does not enable or reconfigure authentication.

    .PARAMETER Port
        Specifies the WSMan or SSH port passed to Invoke-Command.

    .PARAMETER UseSSL
        Uses WSMan over HTTPS. Keldor does not install certificates or disable certificate validation.

    .PARAMETER ConfigurationName
        Specifies an existing WSMan endpoint configuration.

    .PARAMETER SessionOption
        Specifies an existing WSMan PSSessionOption. Keldor does not mutate the object.

    .PARAMETER UserName
        Specifies the SSH user name.

    .PARAMETER KeyFilePath
        Specifies an SSH private-key path. Keldor does not read or return key contents.

    .PARAMETER Subsystem
        Specifies the SSH subsystem passed to Invoke-Command.

    .PARAMETER ConnectingTimeout
        Specifies the native SSH connection timeout in milliseconds.

    .PARAMETER SSHTransport
        Explicitly selects the native SSH transport switch for HostName execution.

    .PARAMETER ThrottleLimit
        Specifies the conservative maximum target concurrency. The initial implementation uses bounded target batches.

    .PARAMETER TimeoutSec
        Specifies the maximum elapsed seconds for each remote target attempt. Zero disables the Keldor timeout.

    .PARAMETER RetryCount
        Specifies additional connection-only attempts after the initial attempt. The default is zero.

    .PARAMETER RetryDelaySec
        Specifies the delay in seconds between eligible connection retries.

    .PARAMETER RawOutput
        Writes command output directly and writes normalized failures to the error stream instead of returning result
        envelopes. Per-target Keldor metadata is unavailable, but native remoting metadata remains when present.

    .EXAMPLE
        Invoke-KeldorCommand -Local -ScriptBlock { Get-KeldorSystemInfo }

        Executes a script block locally and returns a structured execution result.

    .EXAMPLE
        Invoke-KeldorCommand -ComputerName 'server01', 'server02' -ScriptBlock { hostname }

        Executes through WSMan for multiple targets.

    .EXAMPLE
        'server01', 'server02' | Invoke-KeldorCommand -ScriptBlock { Get-Date }

        Buffers pipeline targets and executes them as WSMan targets.

    .EXAMPLE
        $sessions = Get-PSSession
        Invoke-KeldorCommand -Session $sessions -ScriptBlock { Get-KeldorSystemInfo }

        Reuses caller-owned sessions. Sessions can also be passed directly with -Session $sessions.

    .EXAMPLE
        Invoke-KeldorCommand -HostName 'linux01.example.com' -UserName 'automation' `
            -KeyFilePath $keyPath -ScriptBlock { $PSVersionTable }

        Executes through PowerShell remoting over SSH on a supported PowerShell runtime.

    .EXAMPLE
        Invoke-KeldorCommand -ComputerName 'server01' -KeldorCommand 'Get-KeldorSystemInfo'

        Imports Keldor on the target and invokes an installed Keldor command.

    .EXAMPLE
        Invoke-KeldorCommand -Local -KeldorCommand 'Get-KeldorOperatingSystem' -Parameter @{}

        Invokes a validated local Keldor command with named parameters.

    .EXAMPLE
        Invoke-KeldorCommand -ComputerName 'server01' -ScriptBlock { Get-Service } -RawOutput

        Writes remoting output directly without Keldor result envelopes.

    .EXAMPLE
        Invoke-KeldorCommand -ComputerName 'server01' -ScriptBlock { Get-Date } `
            -TimeoutSec 30 -RetryCount 1 -RetryDelaySec 2

        Applies a per-attempt timeout and one connection-only retry.

    .INPUTS
        System.String and System.Management.Automation.Runspaces.PSSession.

    .OUTPUTS
        Keldor.CommandExecutionResult, or unwrapped command output when RawOutput is used.

    .NOTES
        ComputerName selects WSMan, HostName selects SSH, Session reuses its existing transport, and Local uses no
        remoting transport. Keldor does not probe or fall back between transports and does not require ICMP.

    .LINK
        https://docs.keldor.dev/powershell/keldor/Invoke-KeldorCommand
    #>
    [CmdletBinding(
        DefaultParameterSetName = 'WsManScriptBlock',
        HelpUri = 'https://docs.keldor.dev/powershell/keldor/Invoke-KeldorCommand'
    )]
    [OutputType('Keldor.CommandExecutionResult')]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = 'LocalScriptBlock')]
        [Parameter(Mandatory = $true, ParameterSetName = 'LocalKeldorCommand')]
        [switch]$Local,

        [Parameter(Mandatory = $true, ParameterSetName = 'SessionScriptBlock', ValueFromPipeline = $true)]
        [Parameter(Mandatory = $true, ParameterSetName = 'SessionKeldorCommand', ValueFromPipeline = $true)]
        [ValidateNotNull()]
        [System.Management.Automation.Runspaces.PSSession[]]$Session,

        [Parameter(
            Mandatory = $true,
            ParameterSetName = 'WsManScriptBlock',
            Position = 0,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [Parameter(
            Mandatory = $true,
            ParameterSetName = 'WsManKeldorCommand',
            Position = 0,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [Alias('DnsHostName')]
        [ValidateNotNullOrEmpty()]
        [string[]]$ComputerName,

        [Parameter(
            Mandatory = $true,
            ParameterSetName = 'SshScriptBlock',
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [Parameter(
            Mandatory = $true,
            ParameterSetName = 'SshKeldorCommand',
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [ValidateNotNullOrEmpty()]
        [string[]]$HostName,

        [Parameter(Mandatory = $true, ParameterSetName = 'LocalScriptBlock')]
        [Parameter(Mandatory = $true, ParameterSetName = 'SessionScriptBlock')]
        [Parameter(Mandatory = $true, ParameterSetName = 'WsManScriptBlock')]
        [Parameter(Mandatory = $true, ParameterSetName = 'SshScriptBlock')]
        [ValidateNotNull()]
        [scriptblock]$ScriptBlock,

        [Parameter(ParameterSetName = 'LocalScriptBlock')]
        [Parameter(ParameterSetName = 'SessionScriptBlock')]
        [Parameter(ParameterSetName = 'WsManScriptBlock')]
        [Parameter(ParameterSetName = 'SshScriptBlock')]
        [object[]]$ArgumentList,

        [Parameter(Mandatory = $true, ParameterSetName = 'LocalKeldorCommand')]
        [Parameter(Mandatory = $true, ParameterSetName = 'SessionKeldorCommand')]
        [Parameter(Mandatory = $true, ParameterSetName = 'WsManKeldorCommand')]
        [Parameter(Mandatory = $true, ParameterSetName = 'SshKeldorCommand')]
        [ValidateNotNullOrEmpty()]
        [string]$KeldorCommand,

        [Parameter(ParameterSetName = 'LocalKeldorCommand')]
        [Parameter(ParameterSetName = 'SessionKeldorCommand')]
        [Parameter(ParameterSetName = 'WsManKeldorCommand')]
        [Parameter(ParameterSetName = 'SshKeldorCommand')]
        [hashtable]$Parameter = @{},

        [Parameter(ParameterSetName = 'WsManScriptBlock')]
        [Parameter(ParameterSetName = 'WsManKeldorCommand')]
        [pscredential]$Credential,

        [Parameter(ParameterSetName = 'WsManScriptBlock')]
        [Parameter(ParameterSetName = 'WsManKeldorCommand')]
        [System.Management.Automation.Runspaces.AuthenticationMechanism]$Authentication,

        [Parameter(ParameterSetName = 'WsManScriptBlock')]
        [Parameter(ParameterSetName = 'WsManKeldorCommand')]
        [Parameter(ParameterSetName = 'SshScriptBlock')]
        [Parameter(ParameterSetName = 'SshKeldorCommand')]
        [ValidateRange(1, 65535)]
        [int]$Port,

        [Parameter(ParameterSetName = 'WsManScriptBlock')]
        [Parameter(ParameterSetName = 'WsManKeldorCommand')]
        [switch]$UseSSL,

        [Parameter(ParameterSetName = 'WsManScriptBlock')]
        [Parameter(ParameterSetName = 'WsManKeldorCommand')]
        [string]$ConfigurationName,

        [Parameter(ParameterSetName = 'WsManScriptBlock')]
        [Parameter(ParameterSetName = 'WsManKeldorCommand')]
        [System.Management.Automation.Remoting.PSSessionOption]$SessionOption,

        [Parameter(ParameterSetName = 'SshScriptBlock')]
        [Parameter(ParameterSetName = 'SshKeldorCommand')]
        [string]$UserName,

        [Parameter(ParameterSetName = 'SshScriptBlock')]
        [Parameter(ParameterSetName = 'SshKeldorCommand')]
        [string]$KeyFilePath,

        [Parameter(ParameterSetName = 'SshScriptBlock')]
        [Parameter(ParameterSetName = 'SshKeldorCommand')]
        [string]$Subsystem,

        [Parameter(ParameterSetName = 'SshScriptBlock')]
        [Parameter(ParameterSetName = 'SshKeldorCommand')]
        [ValidateRange(0, 2147483647)]
        [int]$ConnectingTimeout,

        [Parameter(ParameterSetName = 'SshScriptBlock')]
        [Parameter(ParameterSetName = 'SshKeldorCommand')]
        [switch]$SSHTransport,

        [ValidateRange(1, 256)]
        [int]$ThrottleLimit = 32,

        [ValidateRange(0, 86400)]
        [int]$TimeoutSec = 0,

        [ValidateRange(0, 10)]
        [int]$RetryCount = 0,

        [ValidateRange(0, 3600)]
        [int]$RetryDelaySec = 1,

        [switch]$RawOutput
    )

    begin {
        $targetBuffer = New-Object System.Collections.ArrayList
        $correlationId = [guid]::NewGuid()
    }

    process {
        if ($PSCmdlet.ParameterSetName -like 'WsMan*') {
            foreach ($targetName in $ComputerName) {
                [void]$targetBuffer.Add($targetName)
            }
        } elseif ($PSCmdlet.ParameterSetName -like 'Ssh*') {
            foreach ($targetName in $HostName) {
                [void]$targetBuffer.Add($targetName)
            }
        } elseif ($PSCmdlet.ParameterSetName -like 'Session*') {
            foreach ($targetSession in $Session) {
                [void]$targetBuffer.Add($targetSession)
            }
        }
    }

    end {
        if ($KeldorCommand -and -not (Test-KeldorRemoteCommandName -Name $KeldorCommand)) {
            $message = "KeldorCommand '$KeldorCommand' is not an approved Keldor command name."
            $exception = New-Object System.ArgumentException $message, 'KeldorCommand'
            $record = New-Object System.Management.Automation.ErrorRecord (
                $exception,
                'Keldor.InvalidRemoteCommandName',
                [System.Management.Automation.ErrorCategory]::InvalidArgument,
                $KeldorCommand
            )
            $PSCmdlet.ThrowTerminatingError($record)
        }

        if ($PSCmdlet.ParameterSetName -like 'WsMan*' -or $PSCmdlet.ParameterSetName -like 'Ssh*') {
            foreach ($targetName in $targetBuffer) {
                if ([string]::IsNullOrWhiteSpace([string]$targetName) -or [string]$targetName -match '[\x00-\x20]') {
                    $message = "Remote target '$targetName' is empty or contains whitespace or control characters."
                    $exception = New-Object System.ArgumentException $message
                    $record = New-Object System.Management.Automation.ErrorRecord (
                        $exception,
                        'Keldor.InvalidRemoteTarget',
                        [System.Management.Automation.ErrorCategory]::InvalidArgument,
                        $targetName
                    )
                    $PSCmdlet.ThrowTerminatingError($record)
                }
            }
        }

        $isKeldorInvocation = $PSCmdlet.ParameterSetName -like '*KeldorCommand'
        $invocationType = if ($isKeldorInvocation) { 'KeldorCommand' } else { 'ScriptBlock' }
        $commandName = if ($isKeldorInvocation) { $KeldorCommand } else { $null }
        if ($isKeldorInvocation) {
            $executionScript = New-KeldorRemoteCommandScriptBlock
            $executionArguments = @($KeldorCommand, $Parameter)
        } else {
            $executionScript = $ScriptBlock
            $executionArguments = $ArgumentList
        }

        if ($PSCmdlet.ParameterSetName -like 'Ssh*' -and $PSVersionTable.PSEdition -eq 'Desktop') {
            foreach ($targetName in $targetBuffer) {
                $descriptor = [pscustomobject]@{
                    ComputerName = $targetName
                    Target       = $targetName
                    TargetType   = 'HostName'
                    Transport    = 'SSH'
                    SessionId    = $null
                    TargetObject = $null
                }
                $startedAt = [datetimeoffset]::UtcNow
                $errorInfo = ConvertTo-KeldorCommandError -Status Unsupported
                $result = New-KeldorCommandExecutionResult `
                    -TargetDescriptor $descriptor `
                    -InvocationType $invocationType `
                    -CommandName $commandName `
                    -Succeeded $false `
                    -Status 'Unsupported' `
                    -AttemptCount 0 `
                    -StartedAt $startedAt `
                    -CompletedAt ([datetimeoffset]::UtcNow) `
                    -NormalizedError $errorInfo `
                    -CorrelationId $correlationId
                if ($RawOutput) {
                    Write-Error -Message $result.ErrorMessage -Category NotImplemented `
                        -ErrorId $result.ErrorId -TargetObject $result.Target
                } else {
                    $result
                }
            }
            return
        }

        if ($PSCmdlet.ParameterSetName -like 'Local*') {
            $descriptor = [pscustomobject]@{
                ComputerName = [Environment]::MachineName
                Target       = [Environment]::MachineName
                TargetType   = 'Local'
                Transport    = 'Local'
                SessionId    = $null
                TargetObject = $null
            }
            $startedAt = [datetimeoffset]::UtcNow
            $localErrors = @()
            $localOutput = @()
            try {
                if ($isKeldorInvocation) {
                    try {
                        $resolvedCommand = Get-Command -Name $KeldorCommand -Module Keldor `
                            -CommandType Function, Cmdlet -ErrorAction Stop
                    } catch {
                        $message = "Keldor command '$KeldorCommand' is not available locally."
                        $exception = New-Object System.Management.Automation.CommandNotFoundException `
                            $message, $_.Exception
                        $record = New-Object System.Management.Automation.ErrorRecord (
                            $exception,
                            'Keldor.RemoteCommandUnavailable',
                            [System.Management.Automation.ErrorCategory]::ObjectNotFound,
                            $KeldorCommand
                        )
                        throw $record
                    }
                    $localScriptBlock = {
                        param($Command, $CommandParameter)
                        & $Command @CommandParameter
                    }
                    $localArgumentList = @($resolvedCommand, $Parameter)
                } else {
                    $localScriptBlock = $executionScript
                    $localArgumentList = $executionArguments
                }

                $localInvokeParameters = @{
                    ScriptBlock  = {
                        param($CommandScript, $CommandArguments)
                        $errorCollection = $ExecutionContext.SessionState.PSVariable.GetValue('global:Error')
                        $initialErrorCount = $errorCollection.Count
                        $runnerOutput = @()
                        $runnerErrors = @()
                        try {
                            $contextVariables = New-Object (
                                'System.Collections.Generic.List[System.Management.Automation.PSVariable]'
                            )
                            $contextVariables.Add((New-Object System.Management.Automation.PSVariable (
                                        'ErrorActionPreference',
                                        [System.Management.Automation.ActionPreference]::SilentlyContinue
                                    )))
                            $runnerOutput = @(
                                $CommandScript.InvokeWithContext($null, $contextVariables, $CommandArguments)
                            )
                            $newErrorCount = $errorCollection.Count - $initialErrorCount
                            if ($newErrorCount -gt 0) {
                                $runnerErrors = @($errorCollection[0..($newErrorCount - 1)])
                            }
                        } catch {
                            $runnerErrors = @($_)
                        }

                        [pscustomobject]@{
                            Output = $runnerOutput
                            Errors = $runnerErrors
                        }
                    }
                    ArgumentList = @($localScriptBlock, $localArgumentList)
                    ErrorAction  = 'Stop'
                }
                $localInvocation = Invoke-Command @localInvokeParameters
                $localOutput = @($localInvocation.Output)
                $localErrors = @($localInvocation.Errors)
                $status = if ($localErrors.Count -gt 0) { 'Failed' } else { 'Succeeded' }
            } catch {
                $localErrors = @($_)
                $status = 'Failed'
            }
            $completedAt = [datetimeoffset]::UtcNow
            $normalizedError = if ($localErrors) {
                ConvertTo-KeldorCommandError -ErrorRecord $localErrors[0]
            } else {
                $null
            }
            $result = New-KeldorCommandExecutionResult `
                -TargetDescriptor $descriptor `
                -InvocationType $invocationType `
                -CommandName $commandName `
                -Succeeded ($status -eq 'Succeeded') `
                -Status $status `
                -AttemptCount 1 `
                -StartedAt $startedAt `
                -CompletedAt $completedAt `
                -Output $localOutput `
                -Errors $localErrors `
                -NormalizedError $normalizedError `
                -CorrelationId $correlationId
            if ($RawOutput) {
                $localOutput
                if (-not $result.Succeeded) {
                    Write-Error -Message $result.ErrorMessage -Category NotSpecified `
                        -ErrorId $result.ErrorId -TargetObject $result.Target
                }
            } else {
                $result
            }
            return
        }

        $connectionParameter = @{}
        foreach ($name in @(
                'Credential', 'Authentication', 'Port', 'UseSSL', 'ConfigurationName', 'SessionOption',
                'UserName', 'KeyFilePath', 'Subsystem', 'ConnectingTimeout', 'SSHTransport'
            )) {
            if ($PSBoundParameters.ContainsKey($name)) {
                $connectionParameter[$name] = $PSBoundParameters[$name]
            }
        }

        $descriptors = @()
        $inputIndex = 0
        foreach ($targetValue in $targetBuffer) {
            if ($PSCmdlet.ParameterSetName -like 'Session*') {
                $transport = if ($targetValue.Transport) { [string]$targetValue.Transport } else { 'ExistingSession' }
                $descriptors += [pscustomobject]@{
                    ComputerName = $targetValue.ComputerName
                    Target       = $targetValue.ComputerName
                    TargetType   = 'Session'
                    Transport    = $transport
                    SessionId    = $targetValue.InstanceId
                    TargetObject = $targetValue
                    InputIndex   = $inputIndex
                }
            } elseif ($PSCmdlet.ParameterSetName -like 'WsMan*') {
                $descriptors += [pscustomobject]@{
                    ComputerName = [string]$targetValue
                    Target       = [string]$targetValue
                    TargetType   = 'ComputerName'
                    Transport    = 'WSMan'
                    SessionId    = $null
                    TargetObject = $null
                    InputIndex   = $inputIndex
                }
            } else {
                $descriptors += [pscustomobject]@{
                    ComputerName = [string]$targetValue
                    Target       = [string]$targetValue
                    TargetType   = 'HostName'
                    Transport    = 'SSH'
                    SessionId    = $null
                    TargetObject = $null
                    InputIndex   = $inputIndex
                }
            }
            $inputIndex++
        }

        Write-Verbose "Correlation $correlationId is executing $($descriptors.Count) target(s)."
        $resultRecords = @()
        for ($offset = 0; $offset -lt $descriptors.Count; $offset += $ThrottleLimit) {
            $lastIndex = [math]::Min($offset + $ThrottleLimit - 1, $descriptors.Count - 1)
            $batch = @()
            foreach ($descriptor in @($descriptors[$offset..$lastIndex])) {
                if ($descriptor.TargetType -eq 'Session' -and $descriptor.TargetObject.State -ne 'Opened') {
                    $startedAt = [datetimeoffset]::UtcNow
                    $sessionException = New-Object System.InvalidOperationException (
                        "Session '$($descriptor.SessionId)' is not opened and will not be reconnected."
                    )
                    $sessionError = New-Object System.Management.Automation.ErrorRecord (
                        $sessionException,
                        'Keldor.RemoteSessionUnavailable',
                        [System.Management.Automation.ErrorCategory]::ResourceUnavailable,
                        $descriptor.TargetObject
                    )
                    $errorInfo = ConvertTo-KeldorCommandError -ErrorRecord $sessionError -Status SessionUnavailable
                    $invalidSessionResult = New-KeldorCommandExecutionResult `
                        -TargetDescriptor $descriptor `
                        -InvocationType $invocationType `
                        -CommandName $commandName `
                        -Succeeded $false `
                        -Status 'SessionUnavailable' `
                        -AttemptCount 0 `
                        -StartedAt $startedAt `
                        -CompletedAt ([datetimeoffset]::UtcNow) `
                        -Errors @($sessionError) `
                        -NormalizedError $errorInfo `
                        -CorrelationId $correlationId
                    $resultRecords += [pscustomobject]@{
                        InputIndex = $descriptor.InputIndex
                        Result     = $invalidSessionResult
                    }
                    continue
                }

                $initialStartedAt = [datetimeoffset]::UtcNow
                $initialJob = $null
                $initialError = $null
                try {
                    $initialJob = Start-KeldorCommandJob `
                        -TargetDescriptor $descriptor `
                        -ScriptBlock $executionScript `
                        -ArgumentList $executionArguments `
                        -ConnectionParameter $connectionParameter
                } catch {
                    $initialError = $_
                }
                $batch += [pscustomobject]@{
                    Descriptor = $descriptor
                    Job        = $initialJob
                    Error      = $initialError
                    StartedAt  = $initialStartedAt
                }
            }

            foreach ($item in $batch) {
                $remoteResult = Invoke-KeldorCommandRemoteTarget `
                    -TargetDescriptor $item.Descriptor `
                    -ScriptBlock $executionScript `
                    -ArgumentList $executionArguments `
                    -ConnectionParameter $connectionParameter `
                    -InitialJob $item.Job `
                    -InitialError $item.Error `
                    -InitialStartedAt $item.StartedAt `
                    -TimeoutSec $TimeoutSec `
                    -RetryCount $RetryCount `
                    -RetryDelaySec $RetryDelaySec `
                    -InvocationType $invocationType `
                    -CommandName $commandName `
                    -CorrelationId $correlationId
                $resultRecords += [pscustomobject]@{
                    InputIndex = $item.Descriptor.InputIndex
                    Result     = $remoteResult
                }
            }
        }

        $results = @(
            $resultRecords |
                Sort-Object -Property InputIndex |
                ForEach-Object { $_.Result }
        )

        if ($RawOutput) {
            foreach ($result in $results) {
                $result.Output
                if (-not $result.Succeeded) {
                    $category = [System.Management.Automation.ErrorCategory]::NotSpecified
                    Write-Error -Message $result.ErrorMessage -Category $category `
                        -ErrorId $result.ErrorId -TargetObject $result.Target
                }
            }
        } else {
            $results
        }
    }
}
