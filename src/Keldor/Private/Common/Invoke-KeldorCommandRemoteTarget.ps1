function Invoke-KeldorCommandRemoteTarget {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [object]$TargetDescriptor,

        [Parameter(Mandatory = $true)]
        [scriptblock]$ScriptBlock,

        [object[]]$ArgumentList,

        [hashtable]$ConnectionParameter = @{},

        [System.Management.Automation.Job]$InitialJob,

        [System.Management.Automation.ErrorRecord]$InitialError,

        [datetimeoffset]$InitialStartedAt,

        [ValidateRange(0, 86400)]
        [int]$TimeoutSec,

        [ValidateRange(0, 10)]
        [int]$RetryCount,

        [ValidateRange(0, 3600)]
        [int]$RetryDelaySec,

        [Parameter(Mandatory = $true)]
        [ValidateSet('ScriptBlock', 'KeldorCommand')]
        [string]$InvocationType,

        [string]$CommandName,

        [Parameter(Mandatory = $true)]
        [guid]$CorrelationId
    )

    if ($PSBoundParameters.ContainsKey('InitialStartedAt')) {
        $startedAt = $InitialStartedAt
    } else {
        $startedAt = [datetimeoffset]::UtcNow
    }
    $attempt = 0
    $allErrors = @()
    $output = @()
    $status = 'Failed'
    $wasTimedOut = $false

    do {
        $attempt++
        $job = $null
        $attemptErrors = @()
        $attemptStartedAt = [datetimeoffset]::UtcNow
        try {
            Write-Verbose "Starting attempt $attempt for target '$($TargetDescriptor.Target)'."
            if ($attempt -eq 1 -and $InitialError) {
                throw $InitialError
            } elseif ($attempt -eq 1 -and $InitialJob) {
                $job = $InitialJob
                $attemptStartedAt = $startedAt
            } else {
                $job = Start-KeldorCommandJob `
                    -TargetDescriptor $TargetDescriptor `
                    -ScriptBlock $ScriptBlock `
                    -ArgumentList $ArgumentList `
                    -ConnectionParameter $ConnectionParameter
                $attemptStartedAt = [datetimeoffset]::UtcNow
            }

            if ($TimeoutSec -gt 0) {
                $elapsedSeconds = ([datetimeoffset]::UtcNow.Subtract($attemptStartedAt)).TotalSeconds
                $remainingSeconds = [math]::Max(0, $TimeoutSec - $elapsedSeconds)
                if ($remainingSeconds -gt 0) {
                    $completedJob = Wait-Job -Job $job -Timeout ([math]::Ceiling($remainingSeconds))
                } else {
                    $completedJob = $null
                }
            } else {
                $completedJob = Wait-Job -Job $job
            }

            if (-not $completedJob) {
                $wasTimedOut = $true
                $status = 'TimedOut'
                Stop-Job -Job $job -ErrorAction SilentlyContinue
                $timeoutException = New-Object System.TimeoutException (
                    "Target '$($TargetDescriptor.Target)' exceeded TimeoutSec ($TimeoutSec)."
                )
                $attemptErrors = @(New-Object System.Management.Automation.ErrorRecord (
                        $timeoutException,
                        'Keldor.RemoteInvocationTimedOut',
                        [System.Management.Automation.ErrorCategory]::OperationTimeout,
                        $TargetDescriptor.Target
                    ))
            } else {
                $receiveErrors = @()
                $output = @(Receive-Job -Job $job -ErrorAction SilentlyContinue -ErrorVariable receiveErrors)
                $attemptErrors = @($receiveErrors)
                foreach ($childJob in @($job.ChildJobs)) {
                    $attemptErrors += @($childJob.Error)
                }
                $attemptErrors = @($attemptErrors | Select-Object -Unique)
                if ($job.State -eq 'Completed' -and $attemptErrors.Count -eq 0) {
                    $status = 'Succeeded'
                } elseif (Test-KeldorRetryableRemoteError -ErrorRecord $attemptErrors) {
                    $status = 'ConnectionFailed'
                } else {
                    $status = 'Failed'
                }
            }
        } catch {
            $attemptErrors = @($_)
            if (Test-KeldorRetryableRemoteError -ErrorRecord $attemptErrors) {
                $status = 'ConnectionFailed'
            } else {
                $status = 'Failed'
            }
        } finally {
            if ($job) {
                Remove-Job -Job $job -Force -ErrorAction SilentlyContinue
            }
        }

        $allErrors += $attemptErrors
        $shouldRetry = $status -eq 'ConnectionFailed' -and $attempt -le $RetryCount
        if ($shouldRetry -and $RetryDelaySec -gt 0) {
            Write-Verbose "Waiting $RetryDelaySec second(s) before retrying '$($TargetDescriptor.Target)'."
            Start-Sleep -Seconds $RetryDelaySec
        }
    } while ($shouldRetry)

    $completedAt = [datetimeoffset]::UtcNow
    $normalizedError = $null
    if ($status -ne 'Succeeded') {
        $normalizedError = ConvertTo-KeldorCommandError -ErrorRecord ($allErrors | Select-Object -Last 1) -Status $status
    }
    New-KeldorCommandExecutionResult `
        -TargetDescriptor $TargetDescriptor `
        -InvocationType $InvocationType `
        -CommandName $CommandName `
        -Succeeded ($status -eq 'Succeeded') `
        -Status $status `
        -AttemptCount $attempt `
        -StartedAt $startedAt `
        -CompletedAt $completedAt `
        -Output $output `
        -Errors $allErrors `
        -NormalizedError $normalizedError `
        -WasTimedOut $wasTimedOut `
        -CorrelationId $CorrelationId
}
