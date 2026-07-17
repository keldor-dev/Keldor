function ConvertTo-KeldorWindowsDateTime {
    [CmdletBinding()]
    param(
        [AllowNull()]
        [object]$Value
    )

    if ($null -eq $Value) { return $null }
    if ($Value -is [datetime]) { return [datetime]$Value }
    if ($Value -is [datetimeoffset]) { return [datetimeoffset]$Value }

    try {
        [Management.ManagementDateTimeConverter]::ToDateTime([string]$Value)
    } catch {
        try { [datetime]$Value } catch { $null }
    }
}
