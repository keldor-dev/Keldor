function New-KeldorCommandExecutionResult {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [object]$TargetDescriptor,

        [Parameter(Mandatory = $true)]
        [ValidateSet('ScriptBlock', 'KeldorCommand')]
        [string]$InvocationType,

        [string]$CommandName,

        [Parameter(Mandatory = $true)]
        [bool]$Succeeded,

        [Parameter(Mandatory = $true)]
        [string]$Status,

        [Parameter(Mandatory = $true)]
        [int]$AttemptCount,

        [Parameter(Mandatory = $true)]
        [datetimeoffset]$StartedAt,

        [Parameter(Mandatory = $true)]
        [datetimeoffset]$CompletedAt,

        [object[]]$Output = @(),

        [System.Management.Automation.ErrorRecord[]]$Errors = @(),

        [object]$NormalizedError,

        [bool]$WasTimedOut = $false,

        [Parameter(Mandatory = $true)]
        [guid]$CorrelationId
    )

    $result = [pscustomobject][ordered]@{
        ComputerName      = $TargetDescriptor.ComputerName
        Target            = $TargetDescriptor.Target
        TargetType        = $TargetDescriptor.TargetType
        Transport         = $TargetDescriptor.Transport
        SessionId         = $TargetDescriptor.SessionId
        InvocationType    = $InvocationType
        CommandName       = $CommandName
        Succeeded         = $Succeeded
        Status            = $Status
        AttemptCount      = $AttemptCount
        StartedAt         = $StartedAt
        CompletedAt       = $CompletedAt
        Duration          = $CompletedAt.Subtract($StartedAt)
        Output            = @($Output)
        Errors            = @($Errors)
        ErrorId           = if ($NormalizedError) { $NormalizedError.ErrorId } else { $null }
        ErrorCategory     = if ($NormalizedError) { $NormalizedError.ErrorCategory } else { $null }
        ErrorMessage      = if ($NormalizedError) { $NormalizedError.ErrorMessage } else { $null }
        ExceptionType     = if ($NormalizedError) { $NormalizedError.ExceptionType } else { $null }
        WasTimedOut       = $WasTimedOut
        WasRetried        = $AttemptCount -gt 1
        PowerShellVersion = if ($TargetDescriptor.Transport -eq 'Local') { $PSVersionTable.PSVersion } else { $null }
        RunspaceId        = if ($TargetDescriptor.Transport -eq 'Local') { $Host.Runspace.InstanceId } else { $null }
        CorrelationId     = $CorrelationId
    }
    $result.PSObject.TypeNames.Insert(0, 'Keldor.CommandExecutionResult')
    $result
}
