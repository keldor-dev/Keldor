function New-KeldorUptimeResult {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [object]$Snapshot
    )

    $value = $Snapshot.Uptime
    $uptime = $value.Uptime
    $result = [pscustomobject][ordered]@{
        ComputerName  = $Snapshot.ComputerName
        Platform      = $Snapshot.Platform
        LastBootTime  = $value.LastBootTime
        CurrentTime   = $value.CurrentTime
        Uptime        = $uptime
        TotalDays     = if ($null -ne $uptime) { [double]$uptime.TotalDays } else { $null }
        TotalHours    = if ($null -ne $uptime) { [double]$uptime.TotalHours } else { $null }
        TotalMinutes  = if ($null -ne $uptime) { [double]$uptime.TotalMinutes } else { $null }
        Source        = $value.Source
        IsSuccessful  = $Snapshot.IsSuccessful
        ErrorCategory = $Snapshot.ErrorCategory
        ErrorCode     = $Snapshot.ErrorCode
        ErrorMessage  = $Snapshot.ErrorMessage
        CollectedAt   = $Snapshot.CollectedAt
    }
    $result.PSObject.TypeNames.Insert(0, 'Keldor.Uptime')
    $result
}
