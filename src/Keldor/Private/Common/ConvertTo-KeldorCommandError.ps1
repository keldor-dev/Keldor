function ConvertTo-KeldorCommandError {
    [CmdletBinding()]
    param(
        [System.Management.Automation.ErrorRecord]$ErrorRecord,

        [ValidateSet('Failed', 'TimedOut', 'ConnectionFailed', 'SessionUnavailable', 'Unsupported')]
        [string]$Status = 'Failed'
    )

    $errorId = 'Keldor.RemoteInvocationFailed'
    $category = 'NotSpecified'
    $message = 'The command invocation failed.'
    $exceptionType = $null

    if ($ErrorRecord) {
        $category = [string]$ErrorRecord.CategoryInfo.Category
        $message = $ErrorRecord.Exception.Message
        $exceptionType = $ErrorRecord.Exception.GetType().FullName

        foreach ($knownId in @(
                'Keldor.RemoteModuleUnavailable',
                'Keldor.RemoteCommandUnavailable',
                'Keldor.SshRemotingNotSupported',
                'Keldor.RemoteSessionUnavailable'
            )) {
            if ($ErrorRecord.FullyQualifiedErrorId -match [regex]::Escape($knownId)) {
                $errorId = $knownId
                break
            }
        }
    }

    if ($Status -eq 'TimedOut') {
        $errorId = 'Keldor.RemoteInvocationTimedOut'
        $category = 'OperationTimeout'
    } elseif ($Status -eq 'ConnectionFailed') {
        $errorId = 'Keldor.RemoteConnectionFailed'
    } elseif ($Status -eq 'SessionUnavailable') {
        $errorId = 'Keldor.RemoteSessionUnavailable'
        $category = 'ResourceUnavailable'
    } elseif ($Status -eq 'Unsupported') {
        $errorId = 'Keldor.SshRemotingNotSupported'
        $category = 'NotImplemented'
    }

    [pscustomobject][ordered]@{
        ErrorId       = $errorId
        ErrorCategory = $category
        ErrorMessage  = $message
        ExceptionType = $exceptionType
    }
}
