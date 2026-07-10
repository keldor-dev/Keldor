function Get-Error {
    <#
.SYNOPSIS
    Gets Error.

.DESCRIPTION
    Gets Error.

.PARAMETER HowMany
    Specifies the How Many value.

.EXAMPLE
    Get-Error
    Runs Get-Error.

.OUTPUTS
    System.Object

.LINK
    https://docs.keldor.dev/powershell/keldor/Get-Error
#>

    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        "PSAvoidGlobalVars",
        "",
        Justification = "Have tried other methods and they do not work consistently."
    )]
    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Get-Error')]
    [Alias('Error')]
    param (
        [Parameter(
            Mandatory = $false,
            Position = 0
        )]
        [int32]$HowMany
    )

    $Errors = $Global:Error

    if ([string]::IsNullOrWhiteSpace($HowMany)) {
        [int32]$HowMany = $Errors.Count
    }

    $n = $HowMany - 1
    $logs = $Errors[0..$n]

    foreach ($log in $logs) {
        $scriptn = $log.InvocationInfo.ScriptName
        $line = $log.InvocationInfo.ScriptLineNumber
        $char = $log.InvocationInfo.OffsetInline
        $command = $log.InvocationInfo.Line.Trim()
        $exc = $log.Exception.GetType().fullname
        $mes = $log.Exception.message.Trim()
        [PSCustomObject]@{
            Exception = "[$exc]"
            Message   = $mes
            Script    = $scriptn
            Command   = $command
            Line      = $line
            Character = $char
        }
    }
}
